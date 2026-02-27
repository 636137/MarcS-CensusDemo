#!/bin/bash
# Post-deployment automation script
# Run after CloudFormation stack is created

STACK_NAME="${1:-census-connect}"
REGION="${2:-us-east-1}"

echo "Configuring Connect instance..."

# Get stack outputs
INSTANCE_ID=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`ConnectInstanceId`].OutputValue' \
  --output text | cut -d'/' -f2)

FLOW_ID=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`ContactFlowId`].OutputValue' \
  --output text 2>/dev/null)

# Create admin user
echo "Creating admin user..."
ADMIN_USER=$(aws connect create-user \
  --instance-id $INSTANCE_ID \
  --username census-admin \
  --password "TempPass123!" \
  --identity-info FirstName=Census,LastName=Admin,Email=admin@example.com \
  --phone-config PhoneType=SOFT_PHONE,AutoAccept=true \
  --security-profile-ids $(aws connect list-security-profiles \
    --instance-id $INSTANCE_ID \
    --query 'SecurityProfileSummaryList[?Name==`Admin`].Id' \
    --output text) \
  --routing-profile-id $(aws connect list-routing-profiles \
    --instance-id $INSTANCE_ID \
    --query 'RoutingProfileSummaryList[0].Id' \
    --output text) \
  --region $REGION 2>/dev/null || echo "User may already exist")

echo "✓ Admin user: census-admin / TempPass123!"

# List available phone numbers
echo ""
echo "Available phone numbers to claim:"
aws connect search-available-phone-numbers \
  --target-arn arn:aws:connect:${REGION}:$(aws sts get-caller-identity --query Account --output text):instance/${INSTANCE_ID} \
  --phone-number-country-code US \
  --phone-number-type DID \
  --max-results 5 \
  --region $REGION \
  --query 'AvailableNumbersList[*].PhoneNumber' \
  --output table 2>/dev/null || echo "Run manually: aws connect search-available-phone-numbers"

echo ""
echo "To claim a number:"
echo "aws connect claim-phone-number --target-arn arn:aws:connect:${REGION}:ACCOUNT:instance/${INSTANCE_ID} --phone-number +1XXXXXXXXXX"

echo ""
echo "✓ Configuration complete"
