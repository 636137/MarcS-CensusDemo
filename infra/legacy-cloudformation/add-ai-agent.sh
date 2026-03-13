#!/bin/bash

INSTANCE_ID=$1
REGION=${AWS_REGION:-us-east-1}

if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: $0 <connect-instance-id>"
    echo "Example: $0 1d3555df-0f7a-4c78-9177-d42253597de2"
    exit 1
fi

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Creating AI Agent for Census Survey Collection          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Instance: $INSTANCE_ID"
echo "Region: $REGION"
echo ""

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Step 1: Create Bedrock Agent for Census Survey
echo "1. Creating Bedrock Agent..."

AGENT_NAME="CensusSurveyAgent"
AGENT_INSTRUCTION="You are a helpful census survey assistant. Your role is to:
1. Greet the caller warmly and explain this is a census survey
2. Verify the caller's address
3. Collect household size (number of people living at the address)
4. Ask if anyone in the household is under 18 years old
5. Confirm all information with the caller
6. Provide a confirmation number
7. Thank them for participating

Always be polite, clear, and patient. If the caller refuses to participate, thank them and end the call politely."

# Create Bedrock Agent
AGENT_ID=$(aws bedrock-agent create-agent \
    --agent-name "$AGENT_NAME" \
    --agent-resource-role-arn "arn:aws:iam::${ACCOUNT_ID}:role/AmazonBedrockExecutionRoleForAgents_census" \
    --foundation-model "anthropic.claude-3-sonnet-20240229-v1:0" \
    --instruction "$AGENT_INSTRUCTION" \
    --region "$REGION" \
    --query 'agent.agentId' \
    --output text 2>&1)

if [[ $AGENT_ID == a-* ]]; then
    echo "   ✅ Bedrock Agent created: $AGENT_ID"
else
    echo "   ⚠️  Using existing agent or creating via console"
    AGENT_ID="MANUAL_SETUP_REQUIRED"
fi

# Step 2: Create Lambda for Agent Actions
echo ""
echo "2. Creating Agent Action Lambda..."

cat > /tmp/census_agent_lambda.py << 'LAMBDA_EOF'
import json
import boto3
import os
from datetime import datetime
import random

dynamodb = boto3.resource('dynamodb')
responses_table = dynamodb.Table(os.environ.get('CENSUS_TABLE', 'CensusResponses'))
addresses_table = dynamodb.Table(os.environ.get('ADDRESS_TABLE', 'CensusAddresses'))

def lambda_handler(event, context):
    print(f"Event: {json.dumps(event)}")
    
    action = event.get('actionGroup', '')
    function = event.get('function', '')
    parameters = event.get('parameters', [])
    
    # Convert parameters to dict
    params = {p['name']: p['value'] for p in parameters}
    
    if function == 'verifyAddress':
        return verify_address(params)
    elif function == 'saveSurveyData':
        return save_survey_data(params)
    elif function == 'generateConfirmation':
        return generate_confirmation(params)
    else:
        return {
            'response': {
                'actionGroup': action,
                'function': function,
                'functionResponse': {
                    'responseBody': {
                        'TEXT': {
                            'body': json.dumps({'error': 'Unknown function'})
                        }
                    }
                }
            }
        }

def verify_address(params):
    phone = params.get('phoneNumber', '')
    
    try:
        response = addresses_table.query(
            IndexName='PhoneNumberIndex',
            KeyConditionExpression='phoneNumber = :phone',
            ExpressionAttributeValues={':phone': phone}
        )
        
        if response['Items']:
            address = response['Items'][0]
            result = {
                'verified': True,
                'address': f"{address['streetAddress']}, {address['city']}, {address['state']} {address['zipCode']}"
            }
        else:
            result = {'verified': False, 'message': 'Address not found'}
            
    except Exception as e:
        result = {'verified': False, 'error': str(e)}
    
    return {
        'response': {
            'actionGroup': 'CensusSurveyActions',
            'function': 'verifyAddress',
            'functionResponse': {
                'responseBody': {
                    'TEXT': {
                        'body': json.dumps(result)
                    }
                }
            }
        }
    }

def save_survey_data(params):
    case_id = f"CENSUS-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000, 9999)}"
    
    try:
        responses_table.put_item(
            Item={
                'caseId': case_id,
                'timestamp': datetime.now().isoformat(),
                'phoneNumber': params.get('phoneNumber', ''),
                'address': params.get('address', ''),
                'householdSize': int(params.get('householdSize', 0)),
                'hasMinors': params.get('hasMinors', 'unknown'),
                'status': 'completed',
                'collectionMethod': 'ai-agent'
            }
        )
        
        result = {'success': True, 'caseId': case_id}
    except Exception as e:
        result = {'success': False, 'error': str(e)}
    
    return {
        'response': {
            'actionGroup': 'CensusSurveyActions',
            'function': 'saveSurveyData',
            'functionResponse': {
                'responseBody': {
                    'TEXT': {
                        'body': json.dumps(result)
                    }
                }
            }
        }
    }

def generate_confirmation(params):
    case_id = params.get('caseId', '')
    confirmation = f"Your confirmation number is {case_id}. Please keep this for your records."
    
    return {
        'response': {
            'actionGroup': 'CensusSurveyActions',
            'function': 'generateConfirmation',
            'functionResponse': {
                'responseBody': {
                    'TEXT': {
                        'body': json.dumps({'confirmation': confirmation})
                    }
                }
            }
        }
    }
LAMBDA_EOF

# Package Lambda
cd /tmp
zip -q census_agent_lambda.zip census_agent_lambda.py

# Create Lambda function
LAMBDA_ARN=$(aws lambda create-function \
    --function-name CensusAgentActions \
    --runtime python3.11 \
    --role "arn:aws:iam::${ACCOUNT_ID}:role/census-connect-LambdaExecutionRole" \
    --handler census_agent_lambda.lambda_handler \
    --zip-file fileb://census_agent_lambda.zip \
    --environment "Variables={CENSUS_TABLE=CensusResponses,ADDRESS_TABLE=CensusAddresses}" \
    --region "$REGION" \
    --query 'FunctionArn' \
    --output text 2>&1)

if [[ $LAMBDA_ARN == arn:aws:lambda* ]]; then
    echo "   ✅ Lambda created: $LAMBDA_ARN"
else
    echo "   ⚠️  Lambda may already exist"
fi

# Step 3: Create Agent Action Group
echo ""
echo "3. Creating Agent Action Group..."

cat > /tmp/agent_schema.json << 'SCHEMA_EOF'
{
  "openapi": "3.0.0",
  "info": {
    "title": "Census Survey API",
    "version": "1.0.0",
    "description": "API for census survey data collection"
  },
  "paths": {
    "/verifyAddress": {
      "post": {
        "summary": "Verify caller address",
        "description": "Verify the caller's address using their phone number",
        "operationId": "verifyAddress",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "phoneNumber": {
                    "type": "string",
                    "description": "Caller's phone number"
                  }
                },
                "required": ["phoneNumber"]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Address verification result"
          }
        }
      }
    },
    "/saveSurveyData": {
      "post": {
        "summary": "Save survey data",
        "description": "Save collected census survey data",
        "operationId": "saveSurveyData",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "phoneNumber": {"type": "string"},
                  "address": {"type": "string"},
                  "householdSize": {"type": "integer"},
                  "hasMinors": {"type": "string"}
                },
                "required": ["phoneNumber", "householdSize"]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Survey data saved"
          }
        }
      }
    },
    "/generateConfirmation": {
      "post": {
        "summary": "Generate confirmation",
        "description": "Generate confirmation number for completed survey",
        "operationId": "generateConfirmation",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "caseId": {"type": "string"}
                },
                "required": ["caseId"]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Confirmation generated"
          }
        }
      }
    }
  }
}
SCHEMA_EOF

echo "   ✅ Agent schema created"

# Step 4: Instructions for manual setup
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SETUP COMPLETE - Manual Steps Required"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Files created:"
echo "  • /tmp/census_agent_lambda.py - Agent action Lambda"
echo "  • /tmp/agent_schema.json - API schema"
echo ""
echo "NEXT STEPS (Complete in AWS Console):"
echo ""
echo "1. Create IAM Role for Bedrock Agent:"
echo "   - Go to IAM → Roles → Create role"
echo "   - Service: Bedrock"
echo "   - Name: AmazonBedrockExecutionRoleForAgents_census"
echo "   - Attach policies: AmazonBedrockFullAccess, Lambda invoke"
echo ""
echo "2. Create Bedrock Agent:"
echo "   - Go to Bedrock → Agents → Create agent"
echo "   - Name: CensusSurveyAgent"
echo "   - Model: Claude 3 Sonnet"
echo "   - Instructions: (see above)"
echo ""
echo "3. Add Action Group to Agent:"
echo "   - In agent → Action groups → Add"
echo "   - Name: CensusSurveyActions"
echo "   - Lambda: CensusAgentActions"
echo "   - API Schema: Upload /tmp/agent_schema.json"
echo ""
echo "4. Prepare and Deploy Agent:"
echo "   - Click 'Prepare' to validate"
echo "   - Create alias: 'prod'"
echo ""
echo "5. Integrate with Amazon Connect:"
echo "   - Connect Console → Flows → Create flow"
echo "   - Add 'Invoke Amazon Q' block"
echo "   - Select your Bedrock agent"
echo "   - Configure voice settings"
echo ""
echo "Agent will handle:"
echo "  ✓ Address verification"
echo "  ✓ Household size collection"
echo "  ✓ Minor status inquiry"
echo "  ✓ Data confirmation"
echo "  ✓ Confirmation number generation"
echo "  ✓ DynamoDB storage"
