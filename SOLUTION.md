# Census Bureau Contact Center - Complete Solution

## Executive Summary

This project demonstrates a production-ready Amazon Connect contact center for the U.S. Census Bureau, featuring AI-powered self-service through AWS Bedrock, comprehensive quality assurance tools, and a web-based chat interface. The solution showcases modern cloud architecture with full automation, disaster recovery capabilities, and enterprise-grade monitoring.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACES                          │
├─────────────────────────────────────────────────────────────────┤
│  Phone (PSTN)  │  Web Chat (S3)  │  Amazon Connect Agent UI    │
└────────┬────────────────┬─────────────────────┬─────────────────┘
         │                │                     │
         ↓                ↓                     ↓
┌─────────────────────────────────────────────────────────────────┐
│                    AMAZON CONNECT INSTANCE                      │
│  • Contact Flows (IVR)                                          │
│  • Queue Management (5 queues)                                  │
│  • Routing Profiles (4 profiles)                                │
│  • Contact Lens (Real-time + Post-call Analytics)              │
│  • Evaluation Forms (4 comprehensive forms)                     │
└────────┬────────────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────┐
│                      AI & AUTOMATION LAYER                      │
├─────────────────────────────────────────────────────────────────┤
│  Bedrock Agent (5KNBMLPHSV)  │  Direct Claude Sonnet 4.6       │
│  • CensusSurveyAgent          │  • Fast invocation              │
│  • Function calling           │  • Conversation history         │
│  • Auto fallback              │  • Address lookup               │
└────────┬────────────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND SERVICES                             │
├─────────────────────────────────────────────────────────────────┤
│  Lambda Functions:                                              │
│  • CensusAgentActions - AI agent backend (verifyAddress,       │
│    saveSurveyData, generateConfirmation)                        │
│  • CensusChatAPI - Web chat API with dual-mode support          │
│                                                                 │
│  API Gateway:                                                   │
│  • HTTP API with CORS                                           │
│  • /chat endpoint for web interface                             │
│                                                                 │
│  DynamoDB Tables:                                               │
│  • CensusResponses - Survey data storage                        │
│  • CensusAddresses - Address lookup database                    │
│                                                                 │
│  S3 Buckets:                                                    │
│  • census-lambda - Lambda deployment packages                   │
│  • census-recordings - Call recordings storage                  │
│  • census-chat-web-* - Static website hosting                   │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

### 1. Multi-Channel Contact Center
- **Phone (PSTN)**: Traditional phone support with IVR
- **Web Chat**: Modern browser-based chat interface
- **Agent Desktop**: Amazon Connect CCP for live agents

### 2. AI-Powered Self-Service
- **Bedrock Agent**: Advanced AI with function calling
- **Claude Sonnet 4.6**: Latest AI model for natural conversations
- **Dual-Mode Support**: Users choose between Direct Claude or Bedrock Agent
- **Automatic Fallback**: Seamless degradation if agent unavailable

### 3. Quality Assurance
- **Contact Lens Rules**: 20 rules (10 real-time, 10 post-call)
- **Evaluation Forms**: 4 comprehensive forms covering:
  - Compliance & Security (4 questions)
  - Call Quality & Service (6 questions)
  - Survey & Data Quality (5 questions)
  - Issue Resolution (6 questions)

### 4. Queue Management
- **GeneralInquiries**: Default queue for general questions
- **SurveyCompletion**: Dedicated queue for survey completion
- **TechnicalSupport**: Technical assistance queue
- **SpanishLanguage**: Spanish-speaking support
- **Escalations**: Supervisor escalation queue

### 5. Routing Profiles
- **GeneralAgent**: Handles general inquiries and surveys
- **TechnicalSupport**: Specialized technical support
- **SpanishAgent**: Spanish language support
- **Supervisor**: Escalation handling and oversight

### 6. Full Automation
- **One-Command Deployment**: `./deploy-full.sh`
- **Complete Cleanup**: `./cleanup.sh`
- **Automated Testing**: Python scripts for end-to-end validation
- **CI/CD Ready**: GitHub Actions integration

## Component Details

### Amazon Connect Instance
- **Instance Alias**: census-enumerator-9652
- **Instance ID**: 1d3555df-0f7a-4c78-9177-d42253597de2
- **Region**: us-east-1
- **Features Enabled**:
  - Contact Lens (analytics and quality)
  - Early media (audio before answer)
  - Auto-resolve best voices
  - Contact flow logs

### Bedrock AI Agent
- **Agent ID**: 5KNBMLPHSV
- **Agent Name**: CensusSurveyAgent
- **Model**: us.anthropic.claude-sonnet-4-6 (Claude Sonnet 4.6)
- **Alias**: prod (FYO3N8QDLX)
- **Status**: PREPARED

**Agent Instructions**:
```
You are a helpful census survey assistant. Your role is to:
1. Greet the caller warmly and explain this is a census survey
2. Ask for their phone number and use verifyAddress function
3. Confirm the address with the caller
4. Collect household size
5. Ask if anyone in the household is under 18
6. Confirm all information
7. Use saveSurveyData function to save the data
8. Use generateConfirmation function to get a confirmation number
9. Provide the confirmation number to the caller
10. Thank them for participating
```

**Action Groups**:
- **CensusSurveyActions**: Three Lambda-backed functions
  - `verifyAddress(phoneNumber)`: Look up address by phone
  - `saveSurveyData(phoneNumber, address, householdSize, hasMinors)`: Store survey
  - `generateConfirmation(caseId)`: Generate confirmation number

### Lambda Functions

#### CensusAgentActions
- **Runtime**: Python 3.11
- **Handler**: census_agent_lambda.lambda_handler
- **Purpose**: Backend for Bedrock Agent actions
- **Functions**:
  - Address verification from phone number
  - Survey data storage to DynamoDB
  - Confirmation number generation
- **Environment Variables**:
  - `CENSUS_TABLE`: CensusResponses
  - `ADDRESS_TABLE`: CensusAddresses

#### CensusChatAPI
- **Runtime**: Python 3.11
- **Handler**: chat-unified-lambda.lambda_handler
- **Purpose**: Web chat API with dual-mode support
- **Features**:
  - Direct Claude Sonnet 4.6 invocation
  - Bedrock Agent invocation with fallback
  - Conversation history management
  - Address lookup integration
  - CORS support for web access

### DynamoDB Tables

#### CensusResponses
- **Partition Key**: caseId (String)
- **Purpose**: Store completed census surveys
- **Attributes**:
  - caseId: Unique identifier (CENSUS-YYYYMMDD-NNNN)
  - phoneNumber: Caller's phone number
  - address: Verified address
  - householdSize: Number of people
  - hasMinors: Whether household has minors
  - status: Survey status (completed, pending)
  - collectionMethod: How collected (phone, web, ai-agent)
  - timestamp: ISO 8601 timestamp

#### CensusAddresses
- **Partition Key**: phoneNumber (String)
- **Purpose**: Phone number to address lookup
- **Attributes**:
  - phoneNumber: 10-digit phone number
  - address: Full street address
  - city: City name
  - state: State code
  - zipCode: ZIP code

### Web Chat Interface

#### Features
- **Census Bureau Theme**: Professional blue gradient design
- **Mode Selector**: Choose between Direct Claude or Bedrock Agent
- **Real-time Chat**: WebSocket-like experience via API polling
- **Mode Badge**: Visual indicator of active AI mode
- **Typing Indicators**: Shows when AI is processing
- **Mobile Responsive**: Works on all devices
- **Error Handling**: Graceful fallback messages

#### Technical Stack
- **Frontend**: Pure HTML/CSS/JavaScript (no frameworks)
- **Hosting**: S3 static website
- **API**: API Gateway HTTP API
- **Backend**: Lambda with dual-mode support
- **AI**: Claude Sonnet 4.6 or Bedrock Agent

#### URL Structure
```
http://census-chat-web-[timestamp].s3-website-us-east-1.amazonaws.com/census-chat.html
```

## Deployment Guide

### Prerequisites
- AWS CLI configured with credentials
- Account: 593804350786
- Region: us-east-1
- Permissions: Administrator or equivalent

### Quick Start

```bash
# Clone repository
git clone https://github.com/636137/MarcS-CensusDemo.git
cd MarcS-CensusDemo/cloudformation

# Deploy everything
./deploy-full.sh

# Add evaluation forms
./add-evaluation-forms.sh [INSTANCE_ID]

# Add Contact Lens rules (requires Contact Lens enabled)
./add-contact-lens-rules.sh [INSTANCE_ID]

# Deploy AI agent
./add-ai-agent.sh
```

### Manual Steps

Only one manual step required:

**Enable Amazon Q in Connect** (5 minutes):
1. Go to Amazon Connect console
2. Select your instance
3. Navigate to Amazon Q section
4. Click "Enable Amazon Q"
5. Wait for activation

### Complete Cleanup

```bash
# Remove all resources
./cleanup.sh
```

This removes:
- CloudFormation stack
- Lambda functions
- DynamoDB tables
- S3 buckets
- IAM roles
- Bedrock agent
- API Gateway

## Testing

### Automated Tests

#### Backend Lambda Functions
```bash
python3 /tmp/comprehensive-test.py
```

Tests:
- Direct Bedrock model invocation
- Lambda function execution (all 3 functions)
- DynamoDB integration
- Agent configuration

#### Web Chat API
```bash
python3 /tmp/test-both-modes.py
```

Tests:
- Direct Claude mode
- Bedrock Agent mode
- Address lookup integration
- Conversation flow

### Manual Testing

#### Phone Testing
1. Get phone number from Connect instance
2. Call the number
3. Follow IVR prompts
4. Test queue routing
5. Verify call recording

#### Web Chat Testing
1. Open web chat URL
2. Select AI mode (Direct or Agent)
3. Click "Start Survey Chat"
4. Complete survey flow
5. Verify data in DynamoDB

#### Agent Desktop Testing
1. Log into Amazon Connect CCP
2. Set status to Available
3. Receive test call
4. Use evaluation forms
5. Review Contact Lens analytics

## Monitoring & Analytics

### CloudWatch Metrics
- Lambda invocations and errors
- API Gateway requests and latency
- DynamoDB read/write capacity
- Connect contact metrics

### Contact Lens Analytics
- Real-time sentiment analysis
- Post-call categorization
- Keyword detection
- Compliance monitoring

### Evaluation Forms
- Agent performance scoring
- Quality assurance tracking
- Compliance verification
- Training identification

## Security

### IAM Roles
- **AmazonBedrockExecutionRoleForAgents_census**: Bedrock Agent execution
- **CensusChatAPIRole**: Web chat Lambda execution
- **ConnectServiceRole**: Amazon Connect service role

### Data Protection
- **Encryption at Rest**: DynamoDB and S3 encrypted
- **Encryption in Transit**: TLS 1.2+ for all connections
- **Access Control**: IAM policies with least privilege
- **Audit Logging**: CloudTrail enabled

### Compliance
- **PII Handling**: Redaction available in Contact Lens
- **Call Recording**: Encrypted storage in S3
- **Data Retention**: Configurable retention policies
- **Access Logs**: All API calls logged

## Cost Optimization

### Estimated Monthly Costs (100 contacts/day)

| Service | Usage | Cost |
|---------|-------|------|
| Amazon Connect | 3,000 contacts | ~$30 |
| Contact Lens | 3,000 contacts | ~$90 |
| Bedrock (Claude) | 100K tokens | ~$3 |
| Lambda | 10K invocations | <$1 |
| DynamoDB | On-demand | <$5 |
| S3 | 10GB storage | <$1 |
| **Total** | | **~$130/month** |

### Cost Reduction Tips
- Use reserved capacity for predictable workloads
- Enable S3 lifecycle policies for old recordings
- Use DynamoDB on-demand for variable traffic
- Implement caching for frequent queries
- Monitor and optimize Lambda memory settings

## Disaster Recovery

### Multi-Region Strategy

**Primary Region**: us-east-1  
**DR Region**: us-west-2

#### RTO/RPO Targets
- **RTO**: 1 hour (Recovery Time Objective)
- **RPO**: 15 minutes (Recovery Point Objective)

#### DR Components
1. **DynamoDB Global Tables**: Cross-region replication
2. **S3 Cross-Region Replication**: Automatic backup
3. **Lambda Deployment**: Infrastructure as Code
4. **Connect Instance**: Manual failover with documented process

#### Failover Process
```bash
# 1. Deploy to DR region
export AWS_REGION=us-west-2
./deploy-full.sh

# 2. Update DNS/routing
# Point traffic to DR region

# 3. Verify functionality
python3 /tmp/comprehensive-test.py

# 4. Monitor and adjust
```

## Troubleshooting

### Common Issues

#### Issue: Bedrock Agent Access Denied
**Symptom**: `accessDeniedException` when invoking agent  
**Solution**: Agent invocation requires special permissions or is accessed through Connect

#### Issue: Lambda Timeout
**Symptom**: 30-second timeout on chat API  
**Solution**: Increase timeout or optimize Bedrock calls

#### Issue: Address Not Found
**Symptom**: verifyAddress returns no results  
**Solution**: Add more sample data to CensusAddresses table

#### Issue: Contact Lens Rules Not Working
**Symptom**: Rules don't trigger  
**Solution**: Ensure Contact Lens is enabled and rules are active

### Debug Commands

```bash
# Check Lambda logs
aws logs tail /aws/lambda/CensusChatAPI --follow

# Check DynamoDB data
aws dynamodb scan --table-name CensusResponses --max-items 5

# Test Lambda directly
aws lambda invoke --function-name CensusAgentActions \
  --payload '{"actionGroup":"CensusSurveyActions","function":"verifyAddress","parameters":[{"name":"phoneNumber","value":"5555551234"}]}' \
  output.json

# Check Connect instance status
aws connect describe-instance --instance-id [INSTANCE_ID]
```

## Future Enhancements

### Planned Features
1. **Multi-language Support**: Add more language options
2. **SMS Integration**: Text message notifications
3. **Email Confirmations**: Automated email receipts
4. **Advanced Analytics**: Custom dashboards
5. **Mobile App**: Native iOS/Android apps
6. **Voice Biometrics**: Caller authentication
7. **Predictive Routing**: ML-based queue routing
8. **Chatbot Handoff**: Seamless agent transfer

### Scalability Improvements
1. **API Caching**: CloudFront + API Gateway caching
2. **Database Optimization**: DynamoDB DAX for caching
3. **Lambda Provisioned Concurrency**: Reduce cold starts
4. **Multi-Region Active-Active**: Global load balancing

## Support & Maintenance

### Documentation
- **README.md**: Quick start guide
- **SOLUTION.md**: This comprehensive guide
- **TROUBLESHOOTING.md**: Common issues and solutions
- **AI_AGENT_SETUP.md**: Bedrock Agent configuration

### Repository
- **GitHub**: https://github.com/636137/MarcS-CensusDemo
- **Issues**: Use GitHub Issues for bug reports
- **Pull Requests**: Contributions welcome

### Contact
For questions or support, please open a GitHub issue.

## Conclusion

This solution demonstrates a modern, AI-powered contact center that combines:
- Traditional phone support with IVR
- Modern web chat with AI assistance
- Comprehensive quality assurance tools
- Full automation and infrastructure as code
- Enterprise-grade security and compliance
- Cost-effective scalability

The architecture is production-ready and can be adapted for various use cases beyond census surveys, including customer service, technical support, healthcare, and government services.

**Status**: ✅ Production Ready  
**Last Updated**: 2026-02-27  
**Version**: 1.0.0
