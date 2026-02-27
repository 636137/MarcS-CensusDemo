#!/bin/bash
set -e

echo "=========================================="
echo "Census Enumerator - Complete Cleanup"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will DELETE ALL resources:"
echo "   - CloudFormation stack"
echo "   - Amazon Connect instance"
echo "   - Lambda function"
echo "   - DynamoDB tables (all data)"
echo "   - S3 buckets (all recordings)"
echo "   - CloudWatch logs"
echo ""
read -p "Are you sure? Type 'DELETE' to confirm: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo ""
echo "Starting cleanup..."

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=${AWS_REGION:-us-east-1}
STACK_NAME=${STACK_NAME:-census-connect}

echo "Account ID: $ACCOUNT_ID"
echo "Region: $REGION"
echo "Stack: $STACK_NAME"
echo ""

# 1. Empty S3 buckets (required before deletion)
echo "📦 Emptying S3 buckets..."
for BUCKET in "census-lambda-${ACCOUNT_ID}" "census-recordings-${ACCOUNT_ID}"; do
    if aws s3 ls "s3://${BUCKET}" 2>/dev/null; then
        echo "   Emptying s3://${BUCKET}..."
        aws s3 rm "s3://${BUCKET}" --recursive --region $REGION 2>/dev/null || true
    fi
done

# 2. Delete CloudFormation stack
echo "🗑️  Deleting CloudFormation stack..."
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION 2>/dev/null; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
    echo "   Waiting for stack deletion (this may take 5-10 minutes)..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION 2>/dev/null || true
    echo "   ✅ Stack deleted"
else
    echo "   ℹ️  Stack not found (already deleted)"
fi

# 3. Delete S3 buckets
echo "🗑️  Deleting S3 buckets..."
for BUCKET in "census-lambda-${ACCOUNT_ID}" "census-recordings-${ACCOUNT_ID}"; do
    if aws s3 ls "s3://${BUCKET}" 2>/dev/null; then
        aws s3 rb "s3://${BUCKET}" --force --region $REGION 2>/dev/null || true
        echo "   ✅ Deleted s3://${BUCKET}"
    fi
done

# 4. Delete orphaned Connect instances (if stack deletion failed)
echo "🗑️  Checking for orphaned Connect instances..."
INSTANCES=$(aws connect list-instances --region $REGION --query "InstanceSummaryList[?contains(InstanceAlias, 'census-enumerator')].Id" --output text 2>/dev/null || echo "")
if [ -n "$INSTANCES" ]; then
    for INSTANCE_ID in $INSTANCES; do
        echo "   Deleting instance: $INSTANCE_ID"
        aws connect delete-instance --instance-id $INSTANCE_ID --region $REGION 2>/dev/null || true
    done
    echo "   ✅ Orphaned instances deleted"
else
    echo "   ℹ️  No orphaned instances found"
fi

# 5. Delete CloudWatch log groups
echo "🗑️  Deleting CloudWatch logs..."
for LOG_GROUP in "/aws/lambda/CensusAgentBackend" "/aws/connect/census-enumerator"; do
    if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --region $REGION 2>/dev/null | grep -q "$LOG_GROUP"; then
        aws logs delete-log-group --log-group-name "$LOG_GROUP" --region $REGION 2>/dev/null || true
        echo "   ✅ Deleted $LOG_GROUP"
    fi
done

# 6. Delete orphaned DynamoDB tables (if stack deletion failed)
echo "🗑️  Checking for orphaned DynamoDB tables..."
for TABLE in "CensusResponses" "CensusAddresses"; do
    if aws dynamodb describe-table --table-name $TABLE --region $REGION 2>/dev/null; then
        aws dynamodb delete-table --table-name $TABLE --region $REGION 2>/dev/null || true
        echo "   ✅ Deleted table: $TABLE"
    fi
done

# 7. Delete orphaned Lambda functions
echo "🗑️  Checking for orphaned Lambda functions..."
if aws lambda get-function --function-name CensusAgentBackend --region $REGION 2>/dev/null; then
    aws lambda delete-function --function-name CensusAgentBackend --region $REGION 2>/dev/null || true
    echo "   ✅ Deleted Lambda function"
fi

echo ""
echo "=========================================="
echo "✅ Cleanup Complete!"
echo "=========================================="
echo ""
echo "All Census Enumerator resources have been deleted."
echo ""
echo "To redeploy, run: ./deploy-full.sh"
