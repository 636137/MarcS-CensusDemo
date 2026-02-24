# Government CCaaS in a Box

[![FedRAMP Ready](https://img.shields.io/badge/FedRAMP-Ready-blue)](FEDRAMP_COMPLIANCE.md)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)](terraform/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com)

## 🏛️ Overview

**Government CCaaS in a Box** is a complete, production-ready cloud contact center designed for government agencies. Deploy an entire customer service operation—including an AI agent that conducts census surveys—with a single Terraform command.

### What You Get

| Capability | Description |
|------------|-------------|
| **AI Census Agent** | Automated phone/chat agent that conducts surveys using Amazon Bedrock |
| **Full Contact Center** | Amazon Connect with queues, routing, recording, and agent desktops |
| **FedRAMP Security** | Complete security controls for government compliance |
| **Disaster Recovery** | Automated failover scripts and cross-region backup |
| **Automated Testing** | Validation module for continuous quality assurance |
| **Multi-Tenant Ready** | Architecture patterns for serving multiple agencies |

### Target Audience

| Audience | Use Case |
|----------|----------|
| **Government IT Teams** | Deploy FedRAMP-ready contact centers without starting from scratch |
| **System Integrators** | Repeatable blueprint for government clients |
| **Census Bureaus** | Automate data collection with AI |
| **Agencies with Call Centers** | Modernize legacy phone systems |
| **AWS Architects** | Reference implementation of Connect + Bedrock + Terraform |

---

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          GOVERNMENT CCaaS IN A BOX                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   CONSTITUENTS                              AGENTS                              │
│   ┌─────────┐                              ┌─────────┐                         │
│   │ 📞 Phone │────┐                    ┌────│  Agent  │                         │
│   └─────────┘    │                    │    │ Desktop │                         │
│   ┌─────────┐    │                    │    └─────────┘                         │
│   │ 💬 Chat  │────┤                    │                                        │
│   └─────────┘    │                    │                                        │
│                  ▼                    ▼                                        │
│            ┌──────────────────────────────────┐                                │
│            │        AMAZON CONNECT            │                                │
│            │  ┌────────────────────────────┐  │                                │
│            │  │    🤖 AI CENSUS AGENT      │  │◄──── Handles 80% of calls      │
│            │  │  (Amazon Bedrock + Lex)    │  │      automatically             │
│            │  └────────────────────────────┘  │                                │
│            │  ┌────────────────────────────┐  │                                │
│            │  │    👥 HUMAN QUEUES         │  │◄──── Escalations & complex     │
│            │  │  (General, Spanish, etc.)  │  │      cases                     │
│            │  └────────────────────────────┘  │                                │
│            │  ┌────────────────────────────┐  │                                │
│            │  │    📊 CONTACT LENS         │  │◄──── Sentiment, transcription  │
│            │  │  (Real-time analytics)     │  │      quality scoring           │
│            │  └────────────────────────────┘  │                                │
│            └──────────────────────────────────┘                                │
│                          │                                                      │
│                          ▼                                                      │
│            ┌──────────────────────────────────┐                                │
│            │         DATA LAYER               │                                │
│            │  ┌───────────┐  ┌───────────┐   │                                │
│            │  │ DynamoDB  │  │    S3     │   │                                │
│            │  │ (Surveys) │  │(Recordings)│   │                                │
│            │  └───────────┘  └───────────┘   │                                │
│            └──────────────────────────────────┘                                │
│                          │                                                      │
│   ┌─────────────────────────────────────────────────────────────────────────┐  │
│   │                        FEDRAMP SECURITY LAYER                           │  │
│   │  🔐 KMS      │ 📋 CloudTrail │ 🛡️ WAF │ 🌐 VPC │ ✅ Config │ 💾 Backup  │  │
│   │  Encryption  │  Audit Logs   │ Firewall│ Network│ Compliance│    DR     │  │
│   └─────────────────────────────────────────────────────────────────────────┘  │
│                          │                                                      │
│   ┌─────────────────────────────────────────────────────────────────────────┐  │
│   │                        VALIDATION & MONITORING                          │  │
│   │  🧪 Validation Module  │  📈 CloudWatch  │  🚨 Alarms  │  📄 Reports    │  │
│   └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
Government-CCaaS-in-a-Box/
│
├── 📄 DOCUMENTATION
│   ├── README.md                           ◄── You are here
│   ├── DEPLOYMENT_GUIDE.md                 ◄── Step-by-step deployment instructions
│   ├── FEDRAMP_COMPLIANCE.md               ◄── Security controls & compliance mapping
│   ├── SERVICE_QUOTAS_AND_LIMITS.md        ◄── AWS limits, multi-tenant sizing, gotchas
│   ├── DISASTER_RECOVERY.md                ◄── DR procedures, RTO/RPO, failover runbooks
│   ├── AGENT_OPTIONS_COMPARISON.md         ◄── Bedrock vs Connect Native AI comparison
│   ├── WELL_ARCHITECTED_LENS.json          ◄── Custom lens for AWS Console import
│   └── docs/
│       └── VALIDATION_MODULE.md            ◄── Automated testing documentation
│
├── 🤖 AI AGENT CONFIGURATION
│   ├── agent-prompt.md                     ◄── AI personality & conversation rules
│   ├── agent-configuration-bedrock.json    ◄── Amazon Bedrock Agent setup
│   ├── agent-configuration-connect.json    ◄── Connect Native AI setup
│   ├── survey-questions.json               ◄── Census survey question definitions
│   └── contact-flow.json                   ◄── Call routing logic (IVR)
│
├── 📦 lambda/                              ◄── Backend Lambda functions
│   ├── index.js                            ◄── Address lookup, survey save logic
│   └── package.json                        ◄── Node.js dependencies
│
├── 🗣️ lex-bot/                             ◄── Amazon Lex voice/chat bot
│   ├── bot-definition.json                 ◄── Bot configuration
│   ├── locale-en_US.json                   ◄── English language settings
│   ├── slot-types.json                     ◄── Custom data types (race, relationship)
│   ├── intents.json                        ◄── User intent definitions
│   └── lambda/
│       └── fulfillment.js                  ◄── Intent fulfillment logic
│
├── 🔧 scripts/                             ◄── Automation scripts
│   ├── validate.sh                         ◄── Run validation tests (CLI)
│   └── dr/                                 ◄── Disaster recovery scripts
│       ├── dr-controller.sh                ◄── Master DR orchestration
│       ├── failover-1-infrastructure.sh    ◄── Phase 1: Core infrastructure
│       ├── failover-2-connect.sh           ◄── Phase 2: Connect instance
│       ├── failover-3-agents.sh            ◄── Phase 3: AI components
│       ├── failback.sh                     ◄── Return to primary region
│       ├── sync-connect-config.sh          ◄── Sync Connect configuration
│       ├── validate-failover.sh            ◄── Verify DR readiness
│       └── dr-config.env.example           ◄── DR configuration template
│
└── 🏗️ terraform/                           ◄── Infrastructure as Code
    ├── main.tf                             ◄── Main orchestration
    ├── variables.tf                        ◄── All configuration options
    ├── outputs.tf                          ◄── Created resource references
    ├── fedramp.tf                          ◄── FedRAMP module orchestration
    ├── terraform.tfvars.example            ◄── Sample configuration file
    │
    └── modules/                            ◄── Modular Terraform components
        │
        ├── 📞 CONTACT CENTER
        │   ├── connect/                    ◄── Amazon Connect instance
        │   ├── connect-queues/             ◄── Call routing queues
        │   ├── connect-users/              ◄── Agent & supervisor accounts
        │   └── contact-lens/               ◄── Analytics, transcription, QA
        │
        ├── 🤖 AI / ML
        │   ├── lex/                        ◄── Amazon Lex bot (NLU)
        │   ├── bedrock/                    ◄── AI guardrails & safety filters
        │   └── lambda/                     ◄── Business logic functions
        │
        ├── 💾 DATA & MONITORING
        │   ├── dynamodb/                   ◄── Survey response storage
        │   ├── monitoring/                 ◄── CloudWatch dashboards & alarms
        │   └── validation/                 ◄── Automated testing infrastructure
        │
        ├── 🔒 SECURITY (FedRAMP)
        │   ├── kms/                        ◄── Customer-managed encryption keys
        │   ├── cloudtrail/                 ◄── API audit logging (7-year retention)
        │   ├── vpc/                        ◄── Network isolation & security groups
        │   ├── waf/                        ◄── Web application firewall
        │   ├── config-rules/               ◄── Compliance monitoring rules
        │   └── backup/                     ◄── Automated backup & DR
        │
        └── 🔐 IAM
            └── iam/                        ◄── Roles, policies, permissions
```

---

## 🚀 Quick Start

### Prerequisites

| Requirement | Version | Why |
|-------------|---------|-----|
| AWS CLI | 2.x | AWS authentication |
| Terraform | >= 1.5.0 | Infrastructure deployment |
| Node.js | >= 18 | Lambda functions |
| Amazon Bedrock | Claude access enabled | AI model |

### Deploy in 5 Commands

```bash
# 1. Clone the repository
git clone https://github.com/636137/MarcS-CensusDemo.git
cd MarcS-CensusDemo/terraform

# 2. Create your configuration file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings

# 3. Initialize Terraform
terraform init

# 4. Preview the deployment
terraform plan

# 5. Deploy everything
terraform apply
```

**Deployment time:** ~15-20 minutes for full stack including FedRAMP modules.

### Minimal Configuration

```hcl
# terraform.tfvars - Minimum required settings

project_name = "census-ccaas"
environment  = "production"
aws_region   = "us-east-1"
owner        = "your-agency"

# Create a new Connect instance
create_connect_instance = true
connect_instance_alias  = "census-contact-center"

# AI Configuration
bedrock_model_id = "anthropic.claude-sonnet-4-5-20250929-v1:0"

# RECOMMENDED: Enable FedRAMP compliance
enable_fedramp_compliance = true
```

---

## 🔒 FedRAMP Compliance

When `enable_fedramp_compliance = true`, the following security controls are automatically deployed:

| Module | What It Does | FedRAMP Controls |
|--------|--------------|------------------|
| **KMS** | Customer-managed encryption keys for all data | SC-12, SC-13, SC-28 |
| **CloudTrail** | API audit logging with 7-year retention | AU-2, AU-3, AU-9, AU-12 |
| **VPC** | Network isolation with private subnets | SC-7, SC-8, AC-4 |
| **WAF** | Web firewall with rate limiting, geo-blocking | SC-5, SI-3 |
| **Config Rules** | Continuous compliance monitoring | CA-7, CM-6 |
| **Backup** | Automated backups with cross-region copy | CP-9, CP-10 |

### Security Features

- **Encryption at rest**: AES-256 using customer-managed KMS keys
- **Encryption in transit**: TLS 1.2/1.3 enforced
- **Access logging**: Every API call logged to CloudTrail
- **Network isolation**: VPC with private subnets, no public IPs
- **Geographic restriction**: Optionally limit access to US only
- **PII protection**: Bedrock Guardrails block sensitive data

**Cost impact:** FedRAMP modules add approximately **$150-300/month**.

See [FEDRAMP_COMPLIANCE.md](FEDRAMP_COMPLIANCE.md) for complete control mappings.

---

## 🤖 AI Census Agent

### How the Survey Works

```
┌─────────────────────────────────────────────────────────────────┐
│  1. GREETING                                                    │
│     "Hello! This is the Census Bureau AI assistant..."          │
├─────────────────────────────────────────────────────────────────┤
│  2. ADDRESS VERIFICATION                                        │
│     "I show your address as 123 Main St. Is this correct?"      │
├─────────────────────────────────────────────────────────────────┤
│  3. HOUSEHOLD COUNT                                             │
│     "How many people were living at this address on April 1st?" │
├─────────────────────────────────────────────────────────────────┤
│  4. FOR EACH PERSON (loop)                                      │
│     • First name, Last name                                     │
│     • Relationship to Person 1                                  │
│     • Sex, Date of Birth                                        │
│     • Hispanic/Latino origin                                    │
│     • Race (can select multiple)                                │
├─────────────────────────────────────────────────────────────────┤
│  5. HOUSING INFORMATION                                         │
│     "Is this home owned, rented, or occupied without payment?"  │
├─────────────────────────────────────────────────────────────────┤
│  6. CONFIRMATION                                                │
│     "Your confirmation number is ABC123. Thank you!"            │
└─────────────────────────────────────────────────────────────────┘
```

### Safety & Guardrails

**The AI will NEVER ask for or accept:**
- ❌ Social Security Numbers
- ❌ Income or financial information
- ❌ Immigration status
- ❌ Political opinions
- ❌ Information about neighbors

**Automatic escalation to human when:**
- Caller says "agent" or "speak to a person"
- 3 consecutive misunderstandings
- Complex situations (students, military, shared custody)
- Caller expresses frustration

### AI Options Comparison

| Feature | Bedrock Agent | Connect Native AI |
|---------|---------------|-------------------|
| **Complexity** | Medium | Easy |
| **Flexibility** | Maximum customization | Simpler, integrated |
| **Multi-channel** | Voice + Chat + API | Voice + Chat |
| **Best for** | Complex workflows | Quick deployment |

See [AGENT_OPTIONS_COMPARISON.md](AGENT_OPTIONS_COMPARISON.md) for detailed comparison.

---

## 📞 Amazon Connect Contact Center

### Components Created

| Component | Purpose |
|-----------|---------|
| **Connect Instance** | Contact center "headquarters" |
| **Contact Flows** | IVR call routing logic |
| **Queues** | Census General, Spanish, Supervisor, Callback |
| **Routing Profiles** | Agent skill-based routing |
| **Hours of Operation** | Business hours (M-F 8am-8pm, Sat 9am-1pm) |
| **Security Profiles** | Agent, Supervisor, Admin access levels |
| **Users** | Pre-configured test agents and supervisors |

### Contact Lens Analytics

- **Real-time transcription**: Every call converted to text
- **Sentiment analysis**: Detect caller mood (positive/negative/neutral)
- **Keyword alerting**: Notify supervisors of specific phrases
- **Quality scores**: Automatic call evaluation
- **Custom vocabulary**: Census-specific terms for better accuracy

---

## 🧪 Validation Module

The Validation Module provides automated testing for deployments:

### Test Categories

| Category | What's Tested |
|----------|---------------|
| **Functional** | Connect instance, Lex bot, Lambda functions, DynamoDB tables |
| **AI Quality** | Intent recognition accuracy, response latency, guardrail effectiveness |
| **Security** | AWS Config compliance, FedRAMP conformance pack |

### Running Tests

```bash
# Run all validation tests
./scripts/validate.sh all

# Run specific test categories
./scripts/validate.sh functional
./scripts/validate.sh ai
./scripts/validate.sh security

# Check recent test status
./scripts/validate.sh status

# Download latest HTML report
./scripts/validate.sh report
```

### Enable in Terraform

```hcl
enable_validation_module = true
validation_notification_email = "alerts@agency.gov"
ai_accuracy_threshold = 0.85   # 85% minimum
ai_latency_threshold  = 3000   # 3 second max
```

**Cost:** ~$24/month for automated daily testing.

See [docs/VALIDATION_MODULE.md](docs/VALIDATION_MODULE.md) for full documentation.

---

## 🔄 Disaster Recovery

### DR Architecture

| Metric | Target |
|--------|--------|
| **RTO** (Recovery Time Objective) | 4 hours |
| **RPO** (Recovery Point Objective) | 1 hour |
| **Backup Frequency** | Daily full, hourly incremental |
| **Retention** | 35 days standard, 7 years compliance |

### DR Scripts

```bash
# Run full disaster recovery failover
./scripts/dr/dr-controller.sh failover

# Individual phases
./scripts/dr/failover-1-infrastructure.sh  # VPC, security
./scripts/dr/failover-2-connect.sh         # Connect instance
./scripts/dr/failover-3-agents.sh          # Lex, Lambda, Bedrock

# Return to primary region
./scripts/dr/failback.sh

# Sync Connect configuration between regions
./scripts/dr/sync-connect-config.sh

# Validate DR readiness
./scripts/dr/validate-failover.sh
```

### Setup DR

```bash
# 1. Copy and configure DR settings
cp scripts/dr/dr-config.env.example scripts/dr/dr-config.env
# Edit with your primary/secondary regions

# 2. Validate DR readiness
./scripts/dr/validate-failover.sh
```

See [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md) for complete runbooks.

---

## 📊 Service Quotas & Multi-Tenancy

### Key AWS Quotas

| Service | Default Limit | Consideration |
|---------|---------------|---------------|
| Connect concurrent calls | 100 | Request increase for production |
| Lex requests/second | 10,000 | Usually sufficient |
| Bedrock tokens/minute | Varies by model | Monitor usage |
| DynamoDB RCU/WCU | On-demand scales automatically | Use provisioned for predictable load |

### Multi-Tenant Architecture

The solution supports two multi-tenant patterns:

| Pattern | Use Case | Isolation |
|---------|----------|-----------|
| **Shared Infrastructure** | Cost-sensitive, similar agencies | Logical separation via tags |
| **Dedicated Instances** | High security, large agencies | Full AWS account separation |

### Tagging Strategy

```hcl
# All resources tagged for cost allocation and ABAC
tags = {
  Project     = "Government-CCaaS"
  Environment = "production"
  Agency      = "census-bureau"
  CostCenter  = "CC-12345"
  Compliance  = "FedRAMP-Moderate"
  DataClass   = "PII"
}
```

See [SERVICE_QUOTAS_AND_LIMITS.md](SERVICE_QUOTAS_AND_LIMITS.md) for complete guidance.

---

## 💰 Cost Estimates

### Monthly Costs by Scale

| Scale | Calls/Month | Estimated Cost |
|-------|-------------|----------------|
| **Development** | 100 | $200-300 |
| **Small** | 1,000 | $400-600 |
| **Medium** | 10,000 | $1,500-2,500 |
| **Large** | 100,000 | $10,000-15,000 |

### Cost Breakdown

| Service | Cost Basis |
|---------|------------|
| **Amazon Connect** | ~$0.018/min voice, $0.004/message chat |
| **Amazon Bedrock** | ~$0.003/1K input tokens, $0.015/1K output |
| **Amazon Lex** | ~$0.004/voice request |
| **DynamoDB** | ~$0.25/GB/month + throughput |
| **Lambda** | ~$0.20/million invocations |
| **FedRAMP Modules** | ~$150-300/month base |
| **Validation Module** | ~$24/month |

### Cost Optimization Tips

```hcl
# Development environment - disable expensive features
enable_fedramp_compliance = false
enable_backup = false
enable_validation_module = false

# Production - enable everything
enable_fedramp_compliance = true
enable_backup = true
enable_cross_region_backup = true
enable_validation_module = true
```

---

## 🔧 Configuration Reference

### All Terraform Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_name` | string | required | Resource name prefix |
| `environment` | string | required | dev/staging/production |
| `aws_region` | string | us-east-1 | Deployment region |
| `create_connect_instance` | bool | false | Create new Connect instance |
| `connect_instance_alias` | string | "" | Connect instance name |
| `bedrock_model_id` | string | claude-sonnet-4.5 | AI model |
| `enable_fedramp_compliance` | bool | false | Deploy security modules |
| `deploy_in_vpc` | bool | false | Use VPC network isolation |
| `enable_waf` | bool | false | Deploy web firewall |
| `enable_backup` | bool | true | Enable AWS Backup |
| `enable_cross_region_backup` | bool | false | Copy backups to DR region |
| `enable_validation_module` | bool | false | Deploy testing infrastructure |
| `ai_accuracy_threshold` | number | 0.85 | AI quality threshold |
| `ai_latency_threshold` | number | 3000 | Max AI response time (ms) |
| `notification_email` | string | "" | Alert email address |
| `waf_allowed_countries` | list | ["US"] | Geo-restriction |

### Key Files to Customize

| File | Purpose |
|------|---------|
| `terraform/terraform.tfvars` | Your deployment configuration |
| `agent-prompt.md` | AI personality and behavior |
| `survey-questions.json` | Census question wording |
| `contact-flow.json` | Call routing logic |

---

## ❓ Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| "Bedrock model not found" | Enable model access in AWS Console → Bedrock → Model access |
| "Connect instance creation failed" | Check Connect service quotas, ensure unique alias |
| "Lex bot not responding" | Verify bot is built and alias deployed |
| "Lambda timeout" | Increase memory/timeout in terraform variables |
| "FedRAMP deployment fails" | Ensure all required permissions for KMS, CloudTrail |

### Debugging Commands

```bash
# Check deployment status
terraform output

# View Lambda logs
aws logs tail /aws/lambda/{function-name} --follow

# Check Connect instance
aws connect describe-instance --instance-id {id}

# Verify Lex bot status
aws lexv2-models describe-bot --bot-id {id}

# Run validation tests
./scripts/validate.sh all
```

### Getting Help

1. **CloudWatch Logs**: Check Lambda function logs
2. **AWS Config**: View compliance status
3. **Validation Reports**: Run `./scripts/validate.sh report`
4. **CloudTrail**: Audit API calls for errors

---

## 📚 Documentation Index

| Document | Description |
|----------|-------------|
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Detailed step-by-step deployment |
| [FEDRAMP_COMPLIANCE.md](FEDRAMP_COMPLIANCE.md) | Security controls and compliance |
| [SERVICE_QUOTAS_AND_LIMITS.md](SERVICE_QUOTAS_AND_LIMITS.md) | AWS quotas, multi-tenant patterns |
| [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md) | DR procedures and runbooks |
| [AGENT_OPTIONS_COMPARISON.md](AGENT_OPTIONS_COMPARISON.md) | Bedrock vs Connect AI comparison |
| [docs/VALIDATION_MODULE.md](docs/VALIDATION_MODULE.md) | Automated testing documentation |
| [WELL_ARCHITECTED_LENS.json](WELL_ARCHITECTED_LENS.json) | AWS Well-Architected custom lens |
| [terraform/README.md](terraform/README.md) | Terraform-specific documentation |

### Import Well-Architected Custom Lens

```bash
# Import the custom lens for deployment review
aws wellarchitected import-lens \
  --json-string file://WELL_ARCHITECTED_LENS.json \
  --lens-alias "government-ccaas" \
  --region us-east-1
```

---

## 📋 Terraform Modules Reference

### Contact Center Modules

| Module | Description | Key Outputs |
|--------|-------------|-------------|
| `connect` | Amazon Connect instance | `instance_id`, `instance_arn` |
| `connect-queues` | Call queues and routing profiles | `queue_ids`, `routing_profile_ids` |
| `connect-users` | Agent and supervisor accounts | `user_ids`, `security_profile_ids` |
| `contact-lens` | Analytics rules and vocabulary | `rule_ids`, `vocabulary_id` |

### AI/ML Modules

| Module | Description | Key Outputs |
|--------|-------------|-------------|
| `lex` | Amazon Lex bot | `bot_id`, `bot_alias_id` |
| `bedrock` | Guardrails and safety filters | `guardrail_id`, `guardrail_arn` |
| `lambda` | Backend functions | `function_arns`, `function_names` |

### Security Modules (FedRAMP)

| Module | Description | Key Outputs |
|--------|-------------|-------------|
| `kms` | Encryption keys | `key_id`, `key_arn` |
| `cloudtrail` | Audit logging | `trail_arn`, `log_group_arn` |
| `vpc` | Network isolation | `vpc_id`, `subnet_ids` |
| `waf` | Web application firewall | `web_acl_arn` |
| `config-rules` | Compliance rules | `conformance_pack_arn` |
| `backup` | Automated backups | `vault_arn`, `plan_id` |

### Operational Modules

| Module | Description | Key Outputs |
|--------|-------------|-------------|
| `dynamodb` | Survey data storage | `table_names`, `table_arns` |
| `monitoring` | CloudWatch dashboards | `dashboard_url`, `alarm_arns` |
| `validation` | Automated testing | `state_machine_arn`, `report_bucket` |
| `iam` | Roles and policies | `role_arns` |

---

## 🏁 Quick Reference Commands

```bash
# Terraform
terraform init          # Initialize
terraform plan          # Preview
terraform apply         # Deploy
terraform destroy       # Teardown
terraform output        # Show outputs

# Validation
./scripts/validate.sh all        # Run all tests
./scripts/validate.sh status     # Check status
./scripts/validate.sh report     # Get report

# Disaster Recovery
./scripts/dr/validate-failover.sh    # Check DR readiness
./scripts/dr/dr-controller.sh failover   # Execute failover
./scripts/dr/failback.sh             # Return to primary

# AWS CLI
aws connect describe-instance --instance-id {id}
aws lexv2-models describe-bot --bot-id {id}
aws logs tail /aws/lambda/{function}
```

---

## 📄 License

This project is provided for demonstration and educational purposes for government modernization initiatives.

---

## 🤝 Contributing

Contributions welcome! Please submit issues and pull requests to help improve this Government CCaaS solution.

**Repository:** https://github.com/636137/MarcS-CensusDemo

---

**Built with ❤️ for Government Digital Transformation**
