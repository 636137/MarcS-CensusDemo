# Census Bureau Contact Center - Amazon Connect Demo

[![AWS](https://img.shields.io/badge/AWS-Amazon%20Connect-orange)](https://aws.amazon.com/connect/)
[![Bedrock](https://img.shields.io/badge/AWS-Bedrock%20AI-blue)](https://aws.amazon.com/bedrock/)
[![CloudFormation](https://img.shields.io/badge/IaC-CloudFormation-green)](https://aws.amazon.com/cloudformation/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Production-ready Amazon Connect contact center for U.S. Census Bureau survey collection, featuring AI-powered self-service via AWS Bedrock Agent, comprehensive quality assurance, and web-based chat interface.

## 🚀 Quick Start

```bash
git clone https://github.com/636137/MarcS-CensusDemo.git
cd MarcS-CensusDemo/cloudformation

./deploy-full.sh
./add-evaluation-forms.sh [INSTANCE_ID]
./add-contact-lens-rules.sh [INSTANCE_ID]
./add-ai-agent.sh
```

## 🎯 Live Demo

| Channel | Details |
|---------|---------|
| 📞 Phone | +18332895330 (toll-free) |
| 💬 Web Chat | http://census-chat-web-1772224618.s3-website-us-east-1.amazonaws.com/census-chat.html |

## ✨ Features

### Multi-Channel Support
- 📞 **Phone (PSTN)**: Inbound calls with AI greeting and queue routing
- 💬 **Web Chat**: Browser-based chat powered by Bedrock Agent
- 🖥️ **Agent Desktop**: Amazon Connect CCP for live agents

### AI-Powered Self-Service
- 🤖 **Bedrock Agent**: Claude Sonnet 4.6 with function calling (verifyAddress, saveSurveyData, generateConfirmation)
- 🧵 **Strands AgentCore**: AWS Strands SDK agent — same tools, modern framework, selectable from web UI
- 🔍 **Address Lookup**: Automatic phone-to-address resolution via DynamoDB
- 📋 **Survey Collection**: Guided household data collection with confirmation numbers
- 👋 **Auto Greeting**: Agent speaks first on every call and chat session

### Quality Assurance
- 📊 **Contact Lens**: 20 rules (10 real-time, 10 post-call)
- 📝 **Evaluation Forms**: 4 QA forms (21 questions)
- 🎯 **Analytics**: Real-time sentiment and categorization

### Queue Management
- 5 specialized queues (General, Survey, Technical, Spanish, Escalations)
- 4 routing profiles with skills-based routing

## 🏗️ Architecture

```
┌─────────────┐
│   Users     │ (Phone, Web Chat, Agent Desktop)
└──────┬──────┘
       │
       ↓
┌─────────────────────────────────┐
│    Amazon Connect Instance      │
│  census-enumerator-9652         │
│  • Contact Flow (Strands Agent) │
│  • Queue Management             │
│  • Contact Lens Analytics       │
└──────┬──────────────────────────┘
       │
       ↓
┌─────────────────────────────────┐
│    AI Agent Layer               │
│  • CensusStrandsAgent (default) │  ← Strands AgentCore (AWS SDK)
│  • CensusSurveyAgent (Bedrock)  │  ← Legacy Bedrock Agent
│  Both use Claude Sonnet 4.6     │
└──────┬──────────────────────────┘
       │
       ↓
┌─────────────────────────────────┐
│      Backend Services           │
│  • CensusAgentActions (Lambda)  │
│  • CensusResponses (DynamoDB)   │
│  • CensusAddresses (DynamoDB)   │
└─────────────────────────────────┘
```

## 📦 Deployed Resources

| Resource | Name / ID |
|----------|-----------|
| Amazon Connect | census-enumerator-9652 (`1d3555df-0f7a-4c78-9177-d42253597de2`) |
| Phone Number | +18332895330 (toll-free) |
| Bedrock Agent | CensusSurveyAgent (`5KNBMLPHSV`) — Claude Sonnet 4.6 |
| Lambda | CensusAgentActions (Python 3.11) — Bedrock Agent backend |
| Lambda | CensusChatAPI (Python 3.11) — Bedrock Agent web chat |
| Lambda | CensusStrandsAgent (Python 3.11) — Strands AgentCore |
| DynamoDB | CensusResponses, CensusAddresses |
| Web Chat | S3 static site |

## 👤 Default Admin User

| Field | Value |
|-------|-------|
| Username | `chendren` |
| Name | Chad Hendren |
| Email | chaddhendren@maximus.com |
| Security Profile | Admin |
| Routing Profile | Basic Routing Profile |
| Phone | +14029732385 (Soft Phone) |
| Temp Password | `Temp@<AccountId>` |

Pre-loaded address record: **Chad Hendren, 123 Main St, Elkhorn, NE 68022** (phone `4029732385`)

## 🧪 Testing

```bash
# Test address lookup
aws lambda invoke --function-name CensusAgentActions \
  --cli-binary-format raw-in-base64-out \
  --payload '{"actionGroup":"CensusSurveyActions","function":"verifyAddress","parameters":[{"name":"phoneNumber","value":"5555551234"}]}' \
  --region us-east-1 output.json && cat output.json

# Test web chat API
aws lambda invoke --function-name CensusChatAPI \
  --cli-binary-format raw-in-base64-out \
  --payload '{"body":"{\"sessionId\":\"test-001\",\"inputText\":\"Hello, I need to complete my census survey\"}"}' \
  --region us-east-1 output.json && cat output.json

# Check DynamoDB data
aws dynamodb scan --table-name CensusAddresses --region us-east-1
aws dynamodb scan --table-name CensusResponses --region us-east-1
```

## 🔒 Security

- IAM least-privilege roles for all Lambda functions and Bedrock Agent
- DynamoDB and S3 encryption at rest
- TLS 1.2+ in transit
- CloudTrail audit logging

## 💰 Cost Estimate (~100 contacts/day)

| Service | Monthly Cost |
|---------|-------------|
| Amazon Connect | ~$30 |
| Contact Lens | ~$90 |
| Bedrock AI | ~$3 |
| Lambda + DynamoDB + S3 | <$7 |
| **Total** | **~$130** |

## 📚 Documentation

- [SOLUTION.md](SOLUTION.md) — Full architecture and design
- [DEPLOYMENT_COMPLETE.md](DEPLOYMENT_COMPLETE.md) — Deployment status and feature matrix
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Common issues and fixes
- [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md) — DR runbooks
- [FEDRAMP_COMPLIANCE.md](FEDRAMP_COMPLIANCE.md) — Compliance notes

## 🗑️ Cleanup

```bash
cd cloudformation && ./cleanup.sh
```

---

**Version**: 1.2.0 | **Region**: us-east-1 | **Last Updated**: 2026-02-27

<!-- BEGIN COPILOT CUSTOM AGENTS -->
## GitHub Copilot Custom Agents (Maximus Internal)

This repository includes **GitHub Copilot custom agent profiles** under `.github/agents/` to speed up planning, documentation, and safe reviews.

### Included agents
- `implementation-planner` — Creates detailed implementation plans and technical specifications for this repository.
- `readme-creator` — Improves README and adjacent documentation without modifying production code.
- `security-auditor` — Performs a read-only security review (secrets risk, risky patterns) and recommends fixes.

### How to invoke

- **GitHub.com (Copilot coding agent):** select the agent from the agent dropdown (or assign it to an issue) after the `.agent.md` files are on the default branch.
- **GitHub Copilot CLI:** from the repo folder, run `/agent` and select one of the agents, or run:
  - `copilot --agent <agent-file-base-name> --prompt "<your prompt>"`
- **IDEs:** open Copilot Chat and choose the agent from the agents dropdown (supported IDEs), backed by the `.github/agents/*.agent.md` files.

References:
- Custom agents configuration: https://docs.github.com/en/copilot/reference/custom-agents-configuration
- Creating custom agents: https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents
<!-- END COPILOT CUSTOM AGENTS -->
