#!/bin/bash

################################################################################
# Census Bureau Contact Center - Full Deployment Script
#
# This script deploys the complete Amazon Connect contact center infrastructure
# including Lambda functions, DynamoDB tables, S3 buckets, queues, and routing.
#
# Usage: ./deploy-full.sh
#
# Prerequisites:
#   - AWS CLI configured with credentials
#   - Account: 593804350786, Region: us-east-1
#   - Administrator or equivalent permissions
#
# What this deploys:
#   - Amazon Connect instance with unique suffix
#   - 5 queues (General, Survey, Technical, Spanish, Escalations)
#   - 4 routing profiles (General, Technical, Spanish, Supervisor)
#   - Lambda function (CensusAgentBackend)
#   - 2 DynamoDB tables (CensusResponses, CensusAddresses)
#   - 2 S3 buckets (lambda code, call recordings)
#   - Sample data for testing
#
# Outputs:
#   - Connect Instance ID
#   - Connect Instance Alias
#   - Lambda Function ARN
#   - DynamoDB Table Names
#   - S3 Bucket Names
################################################################################

set -e  # Exit on any error

# Configuration
STACK_NAME="census-connect"
TEMPLATE_FILE="census-connect.yaml"
REGION="us-east-1"

# Generate unique suffix for Connect instance (4 random digits)
UNIQUE_SUFFIX=$(shuf -i 1000-9999 -n 1)

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Census Bureau Contact Center - Full Deployment          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Configuration:"
echo "  Stack Name: $STACK_NAME"
echo "  Region: $REGION"
echo "  Instance Suffix: $UNIQUE_SUFFIX"
echo ""

# Validate CloudFormation template
echo "→ Validating CloudFormation template..."
aws cloudformation validate-template \
  --template-body file://$TEMPLATE_FILE \
  --region $REGION > /dev/null

echo "✅ Template is valid"
echo ""

# Deploy CloudFormation stack
echo "→ Deploying CloudFormation stack..."
echo "  This will take 5-10 minutes..."
echo ""

aws cloudformation deploy \
  --template-file $TEMPLATE_FILE \
  --stack-name $STACK_NAME \
  --parameter-overrides InstanceAliasSuffix=$UNIQUE_SUFFIX \
  --capabilities CAPABILITY_IAM \
  --region $REGION

echo ""
echo "✅ Stack deployed successfully!"
echo ""

# Get stack outputs
echo "→ Retrieving stack outputs..."
echo ""

INSTANCE_ID=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`ConnectInstanceId`].OutputValue' \
  --output text)

INSTANCE_ALIAS=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`ConnectInstanceAlias`].OutputValue' \
  --output text)

LAMBDA_ARN=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`LambdaFunctionArn`].OutputValue' \
  --output text)

# Display results
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  DEPLOYMENT COMPLETE                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Amazon Connect Instance:"
echo "  Instance ID: $INSTANCE_ID"
echo "  Instance Alias: $INSTANCE_ALIAS"
echo "  Console URL: https://console.aws.amazon.com/connect/v2/app/instances/$INSTANCE_ID"
echo ""
echo "Lambda Function:"
echo "  ARN: $LAMBDA_ARN"
echo ""
echo "DynamoDB Tables:"
echo "  • CensusResponses (survey data)"
echo "  • CensusAddresses (phone lookup)"
echo ""
echo "S3 Buckets:"
echo "  • census-lambda (Lambda code)"
echo "  • census-recordings (call recordings)"
echo ""
echo "Queues Created:"
echo "  • GeneralInquiries"
echo "  • SurveyCompletion"
echo "  • TechnicalSupport"
echo "  • SpanishLanguage"
echo "  • Escalations"
echo ""
echo "Routing Profiles Created:"
echo "  • GeneralAgent"
echo "  • TechnicalSupport"
echo "  • SpanishAgent"
echo "  • Supervisor"
echo ""
echo "Next Steps:"
echo "  1. Add evaluation forms:"
echo "     ./add-evaluation-forms.sh $INSTANCE_ID"
echo ""
echo "  2. Add Contact Lens rules (requires Contact Lens enabled):"
echo "     ./add-contact-lens-rules.sh $INSTANCE_ID"
echo ""
echo "  3. Deploy AI agent:"
echo "     ./add-ai-agent.sh"
echo ""
echo "  4. Test the deployment:"
echo "     python3 /tmp/comprehensive-test.py"
echo ""
