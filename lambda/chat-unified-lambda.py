import json
import boto3
import os

bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')
bedrock_agent_runtime = boto3.client('bedrock-agent-runtime', region_name='us-east-1')
lambda_client = boto3.client('lambda', region_name='us-east-1')

conversations = {}

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        session_id = body.get('sessionId')
        input_text = body.get('inputText')

        # Handle greeting trigger
        if input_text == '__greeting__':
            input_text = 'Greet the customer warmly and ask for their phone number to begin the census survey.'
        use_agent = body.get('useAgent', False)  # true = Bedrock Agent, false = Direct Claude
        
        if use_agent:
            # Try Bedrock Agent first
            try:
                response = bedrock_agent_runtime.invoke_agent(
                    agentId='5KNBMLPHSV',
                    agentAliasId='FYO3N8QDLX',
                    sessionId=session_id,
                    inputText=input_text
                )
                
                response_text = ''
                for event in response['completion']:
                    if 'chunk' in event:
                        chunk = event['chunk']
                        if 'bytes' in chunk:
                            response_text += chunk['bytes'].decode('utf-8')
                
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*',
                        'Access-Control-Allow-Methods': 'POST, OPTIONS',
                        'Access-Control-Allow-Headers': 'Content-Type'
                    },
                    'body': json.dumps({
                        'response': response_text,
                        'sessionId': session_id,
                        'method': 'bedrock-agent'
                    })
                }
            except Exception as agent_error:
                # Fall back to direct Claude if agent fails
                print(f"Agent failed: {agent_error}, falling back to direct Claude")
                use_agent = False
        
        # Direct Claude invocation
        if session_id not in conversations:
            conversations[session_id] = []
        
        conversations[session_id].append({
            'role': 'user',
            'content': input_text
        })
        
        system_prompt = """You are a helpful U.S. Census Bureau survey assistant. Guide the caller through:
1. Ask for phone number
2. When you get a phone number like 555-555-1234, tell them you're looking up their address
3. Ask household size
4. Ask if anyone is under 18
5. Confirm all information
6. Thank them and provide a confirmation number

Be warm, professional, and concise. Keep responses under 100 words."""
        
        payload = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 300,
            "system": system_prompt,
            "messages": conversations[session_id][-10:]
        }
        
        response = bedrock_runtime.invoke_model(
            modelId='us.anthropic.claude-sonnet-4-6',
            body=json.dumps(payload)
        )
        
        result = json.loads(response['body'].read())
        assistant_message = result['content'][0]['text']
        
        conversations[session_id].append({
            'role': 'assistant',
            'content': assistant_message
        })
        
        # Check if we need to call Lambda for address lookup
        if any(phone in input_text.replace('-', '') for phone in ['5555551234', '555-555-1234']):
            try:
                lambda_response = lambda_client.invoke(
                    FunctionName='CensusAgentActions',
                    Payload=json.dumps({
                        "actionGroup": "CensusSurveyActions",
                        "function": "verifyAddress",
                        "parameters": [{"name": "phoneNumber", "value": "5555551234"}]
                    })
                )
                lambda_result = json.loads(lambda_response['Payload'].read())
                address_data = json.loads(lambda_result['response']['functionResponse']['responseBody']['TEXT']['body'])
                assistant_message += f"\n\nI found your address: {address_data['address']}. Is this correct?"
            except Exception as e:
                print(f"Lambda call failed: {e}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'response': assistant_message,
                'sessionId': session_id,
                'method': 'direct-claude'
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e),
                'response': 'I apologize, but I\'m having trouble processing your request. Please try again.'
            })
        }
