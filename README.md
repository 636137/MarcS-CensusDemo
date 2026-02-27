# Government CCaaS in a Box - Census Enumerator

[![AWS](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com)
[![CloudFormation](https://img.shields.io/badge/IaC-CloudFormation-blue)](cloudformation/)

## Overview

Complete, production-ready Amazon Connect contact center for conducting census surveys with AI capabilities. Deploy a full contact center infrastructure in ~10 minutes using CloudFormation.

### What You Get

| Component | Description |
|-----------|-------------|
| **Amazon Connect Instance** | Full contact center with voice/chat, ContactLens analytics, call recording |
| **Lambda Backend** | Serverless functions for survey logic, DynamoDB integration, Bedrock AI |
| **DynamoDB Tables** | Census responses and address lookup storage |
| **Lex Bot** | Natural language understanding for voice interactions |
| **S3 Storage** | Call recordings with 7-year retention |
| **IAM Security** | Least-privilege roles and encryption at rest |

## Quick Start (10 minutes)

### Prerequisites
- AWS Account with admin access
- AWS CLI configured
- Basic familiarity with Amazon Connect

### Deploy Infrastructure

```bash
# 1. Clone repository
git clone https://github.com/636137/MarcS-CensusDemo
cd MarcS-CensusDemo

# 2. Package Lambda function
cd lambda
zip lambda.zip index.js package.json
aws s3 mb s3://census-lambda-YOUR_ACCOUNT_ID
aws s3 cp lambda.zip s3://census-lambda-YOUR_ACCOUNT_ID/

# 3. Deploy CloudFormation stack
cd ../cloudformation
aws cloudformation create-stack \
  --stack-name census-connect \
  --template-body file://census-connect.yaml \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# 4. Wait for completion (~8 minutes)
aws cloudformation wait stack-create-complete \
  --stack-name census-connect \
  --region us-east-1

# 5. Get outputs
aws cloudformation describe-stacks \
  --stack-name census-connect \
  --query 'Stacks[0].Outputs' \
  --output table
```

### Configure Contact Center

1. **Access Connect Console**
   - Get URL from CloudFormation outputs
   - Example: `https://census-enumerator-XXXX.my.connect.aws/connect/home`

2. **Create Admin User**
   - Users → Add new user
   - Assign admin security profile

3. **Claim Phone Number**
   - Channels → Phone numbers → Claim number
   - Select DID or toll-free

4. **Import Contact Flow**
   - Routing → Contact flows → Create contact flow
   - Import: `cloudformation/simple-contact-flow.json`
   - Publish the flow

5. **Assign Number to Flow**
   - Phone numbers → Edit → Assign to contact flow

6. **Test**
   - Call your number
   - Follow survey prompts
   - Check DynamoDB for responses

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CENSUS CONTACT CENTER                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Phone Call → Amazon Connect → Contact Flow                │
│                      ↓                                      │
│                Lambda Function                              │
│                      ↓                                      │
│                DynamoDB Tables                              │
│                                                             │
│  Optional: Lex Bot → Bedrock AI                            │
│                                                             │
│  Storage: S3 (recordings) + CloudWatch (logs)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
MarcS-CensusDemo/
├── cloudformation/
│   ├── census-connect.yaml          # Main infrastructure template
│   └── simple-contact-flow.json     # Basic contact flow
├── lambda/
│   ├── index.js                     # Full Lambda with Bedrock
│   ├── index-simplified.js          # Simplified Lambda (no dependencies)
│   └── package.json
├── lex-bot/
│   ├── bot-definition.json
│   ├── intents.json
│   └── slot-types.json
├── survey-questions.json            # Survey question definitions
├── contact-flow.json                # Advanced contact flow
├── agent-configuration-*.json       # AI agent configs
└── docs/
    ├── DEPLOYMENT_GUIDE.md
    ├── FEDRAMP_COMPLIANCE.md
    └── DISASTER_RECOVERY.md
```

## Deployed Resources

### Core Infrastructure
- **Amazon Connect Instance** - Contact center with ContactLens
- **Lambda Function** - `CensusAgentBackend` with DynamoDB + Bedrock access
- **DynamoDB Tables** - `CensusResponses`, `CensusAddresses`
- **S3 Bucket** - Call recordings with lifecycle policies
- **IAM Roles** - Least-privilege execution roles
- **CloudWatch Logs** - Centralized logging

### Optional Components
- **Lex Bot** - Natural language understanding
- **Bedrock Integration** - Generative AI responses
- **Contact Lens** - Real-time analytics and sentiment

## Testing

### Test Lambda Function
```bash
aws lambda invoke \
  --function-name CensusAgentBackend \
  --region us-east-1 \
  --cli-binary-format raw-in-base64-out \
  --payload '{"action":"lookupAddress","phoneNumber":"5555551234"}' \
  response.json

cat response.json
```

### Load Sample Data
```bash
aws dynamodb put-item \
  --table-name CensusAddresses \
  --item '{
    "addressId": {"S": "addr-001"},
    "phoneNumber": {"S": "5555551234"},
    "streetAddress": {"S": "123 Main Street"},
    "city": {"S": "Washington"},
    "state": {"S": "DC"},
    "zipCode": {"S": "20001"}
  }'
```

### View Logs
```bash
aws logs tail /aws/lambda/CensusAgentBackend --follow
```

## Cost Estimate

| Service | Usage | Monthly Cost |
|---------|-------|--------------|
| Amazon Connect | 1000 calls × 3 min | ~$54 |
| Lambda | 3000 invocations | Free tier |
| DynamoDB | On-demand | Free tier |
| S3 | 10GB recordings | ~$0.23 |
| **Total** | | **~$55/month** |

## Configuration

### Lambda Environment Variables
- `CENSUS_TABLE_NAME` - DynamoDB table for responses
- `ADDRESS_TABLE_NAME` - DynamoDB table for address lookups

### Contact Flow Actions
- `lookupAddress` - Find address by phone number
- `saveSurvey` - Store completed survey
- `scheduleCallback` - Request callback
- `generateConfirmation` - Create confirmation number

## Security

- ✓ Encryption at rest (DynamoDB, S3)
- ✓ Encryption in transit (TLS)
- ✓ IAM least-privilege roles
- ✓ VPC support (optional)
- ✓ CloudTrail logging
- ✓ Point-in-time recovery (DynamoDB)

## Cleanup

```bash
# Delete CloudFormation stack (removes all resources)
aws cloudformation delete-stack \
  --stack-name census-connect \
  --region us-east-1

# Delete S3 bucket
aws s3 rb s3://census-lambda-YOUR_ACCOUNT_ID --force
aws s3 rb s3://census-recordings-YOUR_ACCOUNT_ID --force
```

## Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Detailed setup instructions
- [FedRAMP Compliance](FEDRAMP_COMPLIANCE.md) - Government security controls
- [Disaster Recovery](DISASTER_RECOVERY.md) - DR procedures and RTO/RPO
- [Service Quotas](SERVICE_QUOTAS_AND_LIMITS.md) - AWS limits and scaling

## Support

- **Issues**: GitHub Issues
- **AWS Support**: Contact AWS Support for service-specific issues
- **Documentation**: See `docs/` directory

## License

This project is provided as-is for demonstration purposes.

## Acknowledgments

Built with Amazon Connect, Lambda, DynamoDB, Lex, and Bedrock.
