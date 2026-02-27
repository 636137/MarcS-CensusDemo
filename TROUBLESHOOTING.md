# Troubleshooting Guide

## Common Deployment Issues

### 1. S3 Bucket Errors

#### "NoSuchBucket" or "S3 bucket does not exist"

**Cause:** Lambda code bucket not created before stack deployment

**Solution:**
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws s3 mb s3://census-lambda-${ACCOUNT_ID} --region us-east-1
cd lambda
zip lambda.zip index.js package.json
aws s3 cp lambda.zip s3://census-lambda-${ACCOUNT_ID}/
```

#### "BucketAlreadyExists"

**Cause:** Bucket name already taken globally

**Solution:** S3 bucket names must be globally unique. The template uses `census-lambda-ACCOUNT_ID` which should be unique, but if it fails:
```bash
# Use different bucket name
aws s3 mb s3://census-lambda-${ACCOUNT_ID}-$(date +%s)
# Update CloudFormation template with new bucket name
```

### 2. CloudFormation Stack Errors

#### "Instance alias already exists"

**Cause:** Connect instance with same alias already exists

**Solution:**
```bash
# Option 1: Delete existing instance
aws connect delete-instance --instance-id EXISTING_INSTANCE_ID

# Option 2: Use unique alias
aws cloudformation create-stack \
  --stack-name census-connect \
  --template-body file://census-connect.yaml \
  --parameters ParameterKey=InstanceAlias,ParameterValue=census-enumerator-$(date +%s) \
  --capabilities CAPABILITY_IAM
```

#### "Stack already exists"

**Cause:** Previous deployment with same stack name

**Solution:**
```bash
# Delete old stack first
aws cloudformation delete-stack --stack-name census-connect
aws cloudformation wait stack-delete-complete --stack-name census-connect

# Then redeploy
./deploy-full.sh
```

#### "CREATE_FAILED" status

**Cause:** Various reasons - check specific resource

**Solution:**
```bash
# View detailed error
aws cloudformation describe-stack-events \
  --stack-name census-connect \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].[LogicalResourceId,ResourceStatusReason]' \
  --output table

# Common fixes:
# - IAM permissions: Add CAPABILITY_IAM flag
# - Service limits: Request quota increase
# - Region support: Use us-east-1 or us-west-2
```

### 3. Lambda Function Issues

#### Lambda invocation fails

**Cause:** Missing permissions or incorrect code

**Solution:**
```bash
# Test Lambda directly
aws lambda invoke \
  --function-name CensusAgentBackend \
  --cli-binary-format raw-in-base64-out \
  --payload '{"action":"lookupAddress","phoneNumber":"5555551234"}' \
  response.json

# Check logs
aws logs tail /aws/lambda/CensusAgentBackend --follow

# Verify IAM role
aws lambda get-function --function-name CensusAgentBackend \
  --query 'Configuration.Role'
```

#### "Cannot find module" error

**Cause:** Missing dependencies in Lambda package

**Solution:**
```bash
cd lambda
npm install
zip -r lambda.zip index.js package.json node_modules/
aws s3 cp lambda.zip s3://census-lambda-${ACCOUNT_ID}/

# Update Lambda
aws lambda update-function-code \
  --function-name CensusAgentBackend \
  --s3-bucket census-lambda-${ACCOUNT_ID} \
  --s3-key lambda.zip
```

### 4. DynamoDB Issues

#### "Table does not exist"

**Cause:** Stack creation incomplete or table deleted

**Solution:**
```bash
# Check if tables exist
aws dynamodb list-tables --query 'TableNames[?contains(@, `Census`)]'

# If missing, redeploy stack
aws cloudformation update-stack \
  --stack-name census-connect \
  --template-body file://census-connect.yaml \
  --capabilities CAPABILITY_IAM
```

#### "AccessDeniedException"

**Cause:** Lambda role missing DynamoDB permissions

**Solution:**
```bash
# Verify Lambda has DynamoDB policy
aws iam list-attached-role-policies \
  --role-name census-connect-LambdaExecutionRole-*

# Should include AmazonDynamoDBFullAccess or custom policy
```

### 5. Amazon Connect Issues

#### Cannot access Connect console

**Cause:** IAM permissions or instance not ready

**Solution:**
```bash
# Check instance status
aws connect list-instances --region us-east-1

# Get instance details
aws connect describe-instance \
  --instance-id YOUR_INSTANCE_ID \
  --region us-east-1

# Verify status is ACTIVE
```

#### No phone numbers available

**Cause:** Region doesn't support phone numbers or quota reached

**Solution:**
```bash
# Check available phone numbers
aws connect search-available-phone-numbers \
  --target-arn YOUR_INSTANCE_ARN \
  --phone-number-country-code US \
  --phone-number-type DID

# If none available:
# 1. Try different region
# 2. Request quota increase
# 3. Use toll-free numbers
```

#### Contact flow import fails

**Cause:** Invalid JSON or missing resources

**Solution:**
- Validate JSON: `cat simple-contact-flow.json | jq .`
- Ensure Lambda ARN is correct in flow
- Check all referenced resources exist

### 6. AWS CLI Issues

#### "Unable to locate credentials"

**Cause:** AWS CLI not configured

**Solution:**
```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

#### "Region not supported"

**Cause:** Service not available in selected region

**Solution:**
```bash
# Use supported regions for Connect
export AWS_DEFAULT_REGION=us-east-1
# or
export AWS_DEFAULT_REGION=us-west-2
```

### 7. Permission Issues

#### "AccessDenied" errors

**Cause:** IAM user/role lacks required permissions

**Solution:**
```bash
# Required permissions:
# - cloudformation:*
# - connect:*
# - lambda:*
# - dynamodb:*
# - s3:*
# - iam:CreateRole, iam:AttachRolePolicy
# - logs:*

# Attach admin policy (for testing only)
aws iam attach-user-policy \
  --user-name YOUR_USERNAME \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

## Validation Commands

### Pre-Deployment Checks

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check region
aws configure get region

# Check service availability
aws connect list-instances --region us-east-1

# Check quotas
aws service-quotas get-service-quota \
  --service-code connect \
  --quota-code L-AA7E6B4B
```

### Post-Deployment Validation

```bash
# Verify stack
aws cloudformation describe-stacks \
  --stack-name census-connect \
  --query 'Stacks[0].StackStatus'

# Verify Lambda
aws lambda get-function --function-name CensusAgentBackend

# Verify DynamoDB
aws dynamodb describe-table --table-name CensusResponses
aws dynamodb describe-table --table-name CensusAddresses

# Verify Connect instance
aws connect list-instances --query 'InstanceSummaryList[?InstanceAlias==`census-enumerator-1050`]'

# Test Lambda
aws lambda invoke \
  --function-name CensusAgentBackend \
  --cli-binary-format raw-in-base64-out \
  --payload '{"action":"lookupAddress","phoneNumber":"5555551234"}' \
  response.json && cat response.json
```

## Getting Help

### Check Logs

```bash
# CloudFormation events
aws cloudformation describe-stack-events \
  --stack-name census-connect \
  --max-items 20

# Lambda logs
aws logs tail /aws/lambda/CensusAgentBackend --follow

# Connect logs (if enabled)
aws logs tail /aws/connect/census-enumerator-1050 --follow
```

### Useful Commands

```bash
# List all resources in stack
aws cloudformation list-stack-resources \
  --stack-name census-connect

# Get stack outputs
aws cloudformation describe-stacks \
  --stack-name census-connect \
  --query 'Stacks[0].Outputs'

# Check service health
aws health describe-events --filter services=CONNECT

# View AWS service status
# https://health.aws.amazon.com/health/status
```

### Support Resources

- **AWS Support**: https://console.aws.amazon.com/support/
- **Amazon Connect Documentation**: https://docs.aws.amazon.com/connect/
- **GitHub Issues**: https://github.com/636137/MarcS-CensusDemo/issues
- **AWS Forums**: https://forums.aws.amazon.com/

## Clean Slate Recovery

If everything is broken, start fresh:

```bash
# 1. Delete stack
aws cloudformation delete-stack --stack-name census-connect
aws cloudformation wait stack-delete-complete --stack-name census-connect

# 2. Delete S3 buckets
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws s3 rb s3://census-lambda-${ACCOUNT_ID} --force
aws s3 rb s3://census-recordings-${ACCOUNT_ID} --force

# 3. Delete any orphaned Connect instances
aws connect list-instances --query 'InstanceSummaryList[?InstanceAlias==`census-enumerator-1050`].Id' --output text | \
  xargs -I {} aws connect delete-instance --instance-id {}

# 4. Wait 5 minutes for cleanup

# 5. Redeploy
cd MarcS-CensusDemo/cloudformation
./deploy-full.sh
```

## Known Limitations

1. **Phone number claiming**: Cannot be automated via CloudFormation (manual step required)
2. **Contact flow import**: Must be done via console (API doesn't support full import)
3. **Instance alias**: Must be globally unique in your account
4. **Region support**: Amazon Connect only available in select regions
5. **Service quotas**: Default limits may require increase for production use

## Performance Issues

### Slow deployment

**Normal:** Stack creation takes 8-10 minutes (Connect instance provisioning is slow)

**Too slow (>15 minutes):**
- Check AWS service health dashboard
- Try different region
- Check account limits

### Lambda timeout

**Cause:** Function taking too long (default 30s timeout)

**Solution:**
```bash
aws lambda update-function-configuration \
  --function-name CensusAgentBackend \
  --timeout 60
```

### DynamoDB throttling

**Cause:** Too many requests (on-demand mode should handle this)

**Solution:**
```bash
# Check metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name UserErrors \
  --dimensions Name=TableName,Value=CensusResponses \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# If throttled, tables are already on-demand mode
# Check for application bugs causing excessive requests
```
