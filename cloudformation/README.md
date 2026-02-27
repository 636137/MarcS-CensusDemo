# CloudFormation Deployment

This directory contains AWS CloudFormation templates for deploying the Census Enumerator contact center.

## Files

- **census-connect.yaml** - Main infrastructure template
  - Amazon Connect instance
  - Lambda function
  - DynamoDB tables
  - S3 bucket for recordings
  - IAM roles and permissions
  - CloudWatch logging

- **simple-contact-flow.json** - Basic contact flow
  - Greeting
  - Address lookup
  - Survey collection
  - Data storage

## Deployment

### Automated Deployment (Recommended)

```bash
cd ../cloudformation
./deploy-full.sh
```

The script automatically handles:
- Lambda packaging and S3 upload
- CloudFormation stack creation
- Sample data loading
- Validation and testing

### Manual Deployment

```bash
cd ../lambda
zip lambda.zip index.js package.json
aws s3 mb s3://census-lambda-$(aws sts get-caller-identity --query Account --output text)
aws s3 cp lambda.zip s3://census-lambda-$(aws sts get-caller-identity --query Account --output text)/
```

### 2. Deploy Stack

```bash
cd ../cloudformation
aws cloudformation create-stack \
  --stack-name census-connect \
  --template-body file://census-connect.yaml \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

### 3. Monitor Deployment

```bash
aws cloudformation wait stack-create-complete \
  --stack-name census-connect \
  --region us-east-1
```

### 4. Get Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name census-connect \
  --query 'Stacks[0].Outputs' \
  --output table
```

## Parameters

You can customize the deployment by modifying these parameters in the template:

- `InstanceAlias` - Unique name for Connect instance (default: census-enumerator-1050)
- `AdminEmail` - Email for admin notifications (default: admin@example.com)

## Outputs

The stack provides these outputs:

- `ConnectAccessURL` - Admin console URL
- `ConnectInstanceId` - Instance ID for API calls
- `LambdaFunctionArn` - Lambda function ARN
- `CensusTableName` - DynamoDB responses table
- `AddressTableName` - DynamoDB addresses table
- `RecordingsBucket` - S3 bucket name

## Post-Deployment

1. Access Connect console (use ConnectAccessURL output)
2. Create admin user
3. Claim phone number
4. Import contact flow from `simple-contact-flow.json`
5. Assign phone number to contact flow
6. Test by calling the number

## Cleanup

```bash
aws cloudformation delete-stack \
  --stack-name census-connect \
  --region us-east-1
```

Note: You may need to manually empty the S3 bucket before deletion.

## Troubleshooting

### Stack Creation Failed

Check events:
```bash
aws cloudformation describe-stack-events \
  --stack-name census-connect \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
```

### Lambda Function Errors

View logs:
```bash
aws logs tail /aws/lambda/CensusAgentBackend --follow
```

### Connect Instance Issues

Verify instance:
```bash
aws connect describe-instance \
  --instance-id YOUR_INSTANCE_ID \
  --region us-east-1
```
