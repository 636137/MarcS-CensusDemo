# Government CCaaS in a Box - Census Enumerator

[![AWS](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com)
[![CloudFormation](https://img.shields.io/badge/IaC-CloudFormation-blue)](cloudformation/)

## Overview

Complete, production-ready Amazon Connect contact center for conducting census surveys with AI capabilities. Deploy a full contact center infrastructure in ~10 minutes using CloudFormation.

**🚀 One-Command Deployment** | **📊 5 Queues & 4 Routing Profiles** | **🤖 AI-Powered** | **📋 20 Contact Lens Rules** | **✅ 4 QA Forms**

### What You Get

| Component | Description |
|-----------|-------------|
| **Amazon Connect Instance** | Full contact center with voice/chat, ContactLens analytics, call recording |
| **5 Queues** | GeneralInquiries, SurveyCompletion, TechnicalSupport, SpanishLanguage, Escalations |
| **4 Routing Profiles** | GeneralAgent, TechnicalSupport, SpanishAgent, Supervisor |
| **Lambda Backend** | Serverless functions for survey logic, DynamoDB integration, Bedrock AI |
| **DynamoDB Tables** | Census responses and address lookup storage |
| **Lex Bot** | Natural language understanding for voice interactions |
| **S3 Storage** | Call recordings with 7-year retention |
| **IAM Security** | Least-privilege roles and encryption at rest |
| **AI Agent** | Bedrock-powered conversational agent for self-service survey collection |
| **Contact Lens Rules** | 20 real-time and post-call rules with automated categorization |
| **Evaluation Forms** | 4 comprehensive QA forms (21 questions) for quality assurance |

## Quick Start (10 minutes)

### Prerequisites
- AWS Account with admin access
- AWS CLI configured (`aws configure`)
- Basic familiarity with Amazon Connect

### One-Command Deployment

```bash
git clone https://github.com/636137/MarcS-CensusDemo
cd MarcS-CensusDemo/cloudformation
./deploy-full.sh
```

**That's it!** The script automatically:
- ✅ Packages Lambda code
- ✅ Creates S3 bucket
- ✅ Deploys CloudFormation stack
- ✅ Loads sample data
- ✅ Tests Lambda function
- ✅ Displays Connect console URL

### Manual Deployment (Advanced)

<details>
<summary>Click to expand manual steps</summary>

```bash
# 1. Clone repository
git clone https://github.com/636137/MarcS-CensusDemo
cd MarcS-CensusDemo

# 2. Package Lambda function
cd lambda
zip lambda.zip index.js package.json
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws s3 mb s3://census-lambda-${ACCOUNT_ID}
aws s3 cp lambda.zip s3://census-lambda-${ACCOUNT_ID}/

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

</details>

### Configure Contact Center

1. **Access Connect Console**
   - Get URL from CloudFormation outputs
   - Example: `https://census-enumerator-XXXX.my.connect.aws/connect/home`

2. **Create Admin User**
   - Users → Add new user
   - Assign admin security profile

3. **Add Contact Lens Evaluation Forms (Optional)**
   ```bash
   cd cloudformation
   ./add-evaluation-forms.sh YOUR_INSTANCE_ID
   ```
   This adds 4 comprehensive evaluation forms (21 questions total):
   - **Compliance & Security** (4 questions): PII, privacy, script adherence
   - **Call Quality & Service** (6 questions): Sentiment, communication, professionalism
   - **Survey & Data Quality** (5 questions): Address, household, data verification
   - **Issue Resolution** (6 questions): Escalations, language, technical issues

4. **Add Contact Lens Rules (Optional)**
   ```bash
   cd cloudformation
   ./add-contact-lens-rules.sh YOUR_INSTANCE_ID
   ```
   This adds 20 Contact Lens rules with categories:
   
   **Real-time Rules (10):**
   - PII Detection, Negative Sentiment, Escalation Requests
   - Profanity Detection, Survey Refusals, Language Barriers
   - Technical Issues, Callback Requests, Compliance Issues
   - High-Priority Cases
   
   **Post-call Rules (10):**
   - Script Compliance, Data Verification, Confirmation Numbers
   - Survey Completion, Customer Satisfaction (Positive/Negative)
   - Call Duration (Long/Short), Follow-up Required
   - Privacy Compliance
   
   **Note:** Requires Contact Lens to be enabled on the instance.
   Enable in Connect console: Analytics and optimization → Contact Lens

5. **Add AI Agent for Self-Service (Optional)**
   ```bash
   cd cloudformation
   ./add-ai-agent.sh YOUR_INSTANCE_ID
   ```
   This creates an AI-powered conversational agent using Amazon Bedrock:
   - **Natural conversation** for survey collection
   - **Address verification** and data validation
   - **Automated data storage** in DynamoDB
   - **Confirmation number** generation
   - **Seamless fallback** to human agent if needed
   
   See [AI Agent Setup Guide](docs/AI_AGENT_SETUP.md) for complete instructions.

6. **Claim Phone Number**
   - Channels → Phone numbers → Claim number
   - Select DID or toll-free

6. **Import Contact Flow**
   - Routing → Contact flows → Create contact flow
   - Import: `cloudformation/simple-contact-flow.json`
   - Publish the flow

7. **Assign Number to Flow**
   - Phone numbers → Edit → Assign to contact flow

8. **Test**
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
- **5 Queues** - GeneralInquiries, SurveyCompletion, TechnicalSupport, SpanishLanguage, Escalations
- **4 Routing Profiles** - GeneralAgent, TechnicalSupport, SpanishAgent, Supervisor
- **Lambda Function** - `CensusAgentBackend` with DynamoDB + Bedrock access
- **DynamoDB Tables** - `CensusResponses`, `CensusAddresses`
- **S3 Bucket** - Call recordings with lifecycle policies
- **IAM Roles** - Least-privilege execution roles
- **CloudWatch Logs** - Centralized logging

### Queue Configuration

| Queue | Purpose | Max Contacts |
|-------|---------|--------------|
| **GeneralInquiries** | General census questions | 50 |
| **SurveyCompletion** | Complete census survey | 100 |
| **TechnicalSupport** | Portal and technical help | 30 |
| **SpanishLanguage** | Spanish-speaking assistance | 50 |
| **Escalations** | Supervisor escalations | 20 |

### Routing Profiles

| Profile | Queues | Voice | Chat |
|---------|--------|-------|------|
| **GeneralAgent** | GeneralInquiries, SurveyCompletion | 1 | 3 |
| **TechnicalSupport** | TechnicalSupport | 1 | 2 |
| **SpanishAgent** | SpanishLanguage | 1 | 3 |
| **Supervisor** | All queues | 1 | 5 |

### Optional Components
- **Lex Bot** - Natural language understanding
- **Bedrock Integration** - Generative AI responses
- **Contact Lens** - Real-time analytics and sentiment (requires manual enablement)
- **4 Evaluation Forms** - Comprehensive quality assurance (21 questions total)
- **20 Contact Lens Rules** - Real-time alerts and post-call categories (script provided)

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

## Troubleshooting

### "S3 bucket does not exist" Error
```bash
# Create bucket manually
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws s3 mb s3://census-lambda-${ACCOUNT_ID}
```

### "Instance alias already exists" Error
```bash
# Use unique instance name
aws cloudformation create-stack \
  --stack-name census-connect \
  --template-body file://census-connect.yaml \
  --parameters ParameterKey=InstanceAlias,ParameterValue=census-enumerator-$(date +%s) \
  --capabilities CAPABILITY_IAM
```

### Stack Creation Failed
```bash
# Check error details
aws cloudformation describe-stack-events \
  --stack-name census-connect \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
```

### Lambda Function Errors
```bash
# View logs
aws logs tail /aws/lambda/CensusAgentBackend --follow
```

### Connect Instance Not Accessible
- Verify instance is ACTIVE: `aws connect list-instances`
- Check IAM permissions for Connect access
- Ensure you're in correct region (us-east-1)

## Cleanup

### Complete Removal (One Command)

```bash
cd cloudformation
./cleanup.sh
```

This removes **everything**:
- CloudFormation stack
- Amazon Connect instance
- Lambda function
- DynamoDB tables (all data)
- S3 buckets (all recordings)
- CloudWatch logs

**Warning:** This is permanent and cannot be undone!

### Manual Cleanup (Advanced)

<details>
<summary>Click to expand manual cleanup steps</summary>

```bash
# Delete CloudFormation stack
aws cloudformation delete-stack \
  --stack-name census-connect \
  --region us-east-1

# Empty and delete S3 buckets
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws s3 rm s3://census-lambda-${ACCOUNT_ID} --recursive
aws s3 rb s3://census-lambda-${ACCOUNT_ID} --force
aws s3 rm s3://census-recordings-${ACCOUNT_ID} --recursive
aws s3 rb s3://census-recordings-${ACCOUNT_ID} --force
```

</details>

## Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Detailed setup instructions
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues and solutions
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
