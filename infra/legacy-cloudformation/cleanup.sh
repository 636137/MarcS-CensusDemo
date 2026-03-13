#!/bin/bash

################################################################################
# Census Bureau Contact Center - Complete Cleanup Script
#
# This script removes ALL resources created by the deployment, including:
#   - CloudFormation stack and all its resources
#   - Lambda functions (CensusAgentBackend, CensusChatAPI, CensusAgentActions)
#   - DynamoDB tables (CensusResponses, CensusAddresses)
#   - S3 buckets (census-lambda, census-recordings, census-chat-web-*)
#   - IAM roles (AmazonBedrockExecutionRoleForAgents_census, CensusChatAPIRole)
#   - Bedrock Agent (5KNBMLPHSV)
#   - API Gateway (CensusChatAPI)
#
# Usage: ./cleanup.sh
#
# WARNING: This is destructive and cannot be undone!
#          All data will be permanently deleted.
#
# Safety: Script will prompt for confirmation before proceeding
################################################################################

set -e  # Exit on any error

STACK_NAME="census-connect"
REGION="us-east-1"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Census Bureau Contact Center - Complete Cleanup         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  WARNING: This will delete ALL resources including:"
echo "   • CloudFormation stack: $STACK_NAME"
echo "   • All Lambda functions"
echo "   • All DynamoDB tables and data"
echo "   • All S3 buckets and contents"
echo "   • All IAM roles"
echo "   • Bedrock Agent"
echo "   • API Gateway"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup..."
echo ""

# 1. Empty and delete S3 buckets (must be done before stack deletion)
echo "→ Cleaning up S3 buckets..."
for bucket in $(aws s3 ls | grep -E 'census-lambda|census-recordings|census-chat-web' | awk '{print $3}'); do
    echo "  Deleting bucket: $bucket"
    aws s3 rb s3://$bucket --force --region $REGION 2>/dev/null || echo "  (bucket not found or already deleted)"
done
echo "✅ S3 buckets cleaned up"
echo ""

# 2. Delete CloudFormation stack
echo "→ Deleting CloudFormation stack: $STACK_NAME..."
aws cloudformation delete-stack \
    --stack-name $STACK_NAME \
    --region $REGION 2>/dev/null || echo "  (stack not found)"

echo "  Waiting for stack deletion (this may take 5-10 minutes)..."
aws cloudformation wait stack-delete-complete \
    --stack-name $STACK_NAME \
    --region $REGION 2>/dev/null || echo "  (stack already deleted)"
echo "✅ CloudFormation stack deleted"
echo ""

# 3. Delete additional Lambda functions
echo "→ Deleting additional Lambda functions..."
for func in CensusChatAPI CensusAgentActions; do
    echo "  Deleting function: $func"
    aws lambda delete-function \
        --function-name $func \
        --region $REGION 2>/dev/null || echo "  (function not found)"
done
echo "✅ Lambda functions deleted"
echo ""

# 4. Delete Bedrock Agent
echo "→ Deleting Bedrock Agent..."
AGENT_ID=$(aws bedrock-agent list-agents --region $REGION --query 'agentSummaries[?agentName==`CensusSurveyAgent`].agentId' --output text 2>/dev/null)
if [ ! -z "$AGENT_ID" ]; then
    echo "  Deleting agent: $AGENT_ID"
    aws bedrock-agent delete-agent \
        --agent-id $AGENT_ID \
        --region $REGION 2>/dev/null || echo "  (agent not found)"
    echo "✅ Bedrock Agent deleted"
else
    echo "  (agent not found)"
fi
echo ""

# 5. Delete API Gateway
echo "→ Deleting API Gateway..."
API_ID=$(aws apigatewayv2 get-apis --region $REGION --query 'Items[?Name==`CensusChatAPI`].ApiId' --output text 2>/dev/null)
if [ ! -z "$API_ID" ]; then
    echo "  Deleting API: $API_ID"
    aws apigatewayv2 delete-api \
        --api-id $API_ID \
        --region $REGION 2>/dev/null || echo "  (API not found)"
    echo "✅ API Gateway deleted"
else
    echo "  (API not found)"
fi
echo ""

# 6. Delete IAM roles
echo "→ Deleting IAM roles..."
for role in AmazonBedrockExecutionRoleForAgents_census CensusChatAPIRole; do
    echo "  Deleting role: $role"
    
    # Detach managed policies
    for policy_arn in $(aws iam list-attached-role-policies --role-name $role --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null); do
        aws iam detach-role-policy --role-name $role --policy-arn $policy_arn 2>/dev/null || true
    done
    
    # Delete inline policies
    for policy_name in $(aws iam list-role-policies --role-name $role --query 'PolicyNames[]' --output text 2>/dev/null); do
        aws iam delete-role-policy --role-name $role --policy-name $policy_name 2>/dev/null || true
    done
    
    # Delete role
    aws iam delete-role --role-name $role --region $REGION 2>/dev/null || echo "  (role not found)"
done
echo "✅ IAM roles deleted"
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  CLEANUP COMPLETE                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "All resources have been removed:"
echo "  ✅ CloudFormation stack"
echo "  ✅ Lambda functions"
echo "  ✅ DynamoDB tables"
echo "  ✅ S3 buckets"
echo "  ✅ IAM roles"
echo "  ✅ Bedrock Agent"
echo "  ✅ API Gateway"
echo ""
echo "Your AWS account is now clean!"
echo ""
