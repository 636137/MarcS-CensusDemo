# Government CCaaS in a Box

## 🏛️ What is This?

A **complete, ready-to-deploy cloud contact center** designed for government agencies. Deploy an entire customer service operation—including an AI agent that conducts census surveys—with a single command.

**In plain English:** This project gives you everything you need to set up a professional call center in Amazon Web Services (AWS), complete with:
- An AI that can answer phones and conduct surveys automatically
- A web chat option for people who prefer typing
- Human agent routing when the AI needs help
- Call recording and quality monitoring
- Security and compliance for government use
- Disaster recovery and backup

Think of it as a "starter kit" for government contact centers that would normally take months to build.

---

## 🎯 Who is This For?

| Audience | Why You'd Use This |
|----------|-------------------|
| **Government IT Teams** | Deploy a FedRAMP-ready contact center without starting from scratch |
| **System Integrators** | Repeatable blueprint for government clients |
| **Census Bureaus** | Automate data collection with AI |
| **Agencies with Call Centers** | Modernize legacy phone systems with cloud AI |
| **AWS Learners** | Real-world example of Connect + Bedrock + Terraform |

---

## 🧩 What's Included?

This project has three main layers:

### Layer 1: The AI Census Agent
An artificial intelligence that conducts census surveys over phone or chat. It:
- Greets callers and explains confidentiality
- Verifies the caller's address
- Asks how many people live in the household
- Collects demographic information for each person
- Provides a confirmation number
- Can transfer to a human if needed

### Layer 2: Amazon Connect Contact Center
The complete phone/chat infrastructure:
- **Phone System**: Claim phone numbers, route calls, play hold music
- **Chat Widget**: Embed on any website
- **Agent Desktops**: Interface for human agents
- **Queues**: Route calls to the right teams
- **Recording**: Record and transcribe every interaction
- **Analytics**: Dashboard showing wait times, resolution rates, etc.

### Layer 3: Government Security & Compliance
Everything needed for FedRAMP authorization:
- **Encryption**: All data encrypted with keys you control
- **Audit Logs**: Every action recorded for 7 years
- **Network Security**: Private network connections, firewall rules
- **Backup**: Daily backups with disaster recovery
- **Compliance Monitoring**: Automatic security checks

---

## 📊 Visual Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        GOVERNMENT CCaaS IN A BOX                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   CONSTITUENTS                        AGENTS                                │
│   ┌─────────┐                        ┌─────────┐                           │
│   │  Phone  │────┐              ┌────│  Agent  │                           │
│   └─────────┘    │              │    │ Desktop │                           │
│   ┌─────────┐    │              │    └─────────┘                           │
│   │  Chat   │────┤              │                                          │
│   └─────────┘    │              │                                          │
│                  ▼              ▼                                          │
│            ┌──────────────────────────┐                                    │
│            │     AMAZON CONNECT       │                                    │
│            │  ┌────────────────────┐  │                                    │
│            │  │   AI CENSUS AGENT  │  │◄──── Handles 80% of calls          │
│            │  │  (Amazon Bedrock)  │  │      automatically                 │
│            │  └────────────────────┘  │                                    │
│            │  ┌────────────────────┐  │                                    │
│            │  │   HUMAN QUEUES     │  │◄──── Escalations & complex cases   │
│            │  └────────────────────┘  │                                    │
│            └──────────────────────────┘                                    │
│                        │                                                    │
│                        ▼                                                    │
│            ┌──────────────────────────┐                                    │
│            │     DATA STORAGE         │                                    │
│            │  Survey Responses        │                                    │
│            │  Call Recordings         │                                    │
│            │  Transcripts             │                                    │
│            └──────────────────────────┘                                    │
│                        │                                                    │
│                        ▼                                                    │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │                    FEDRAMP SECURITY LAYER                          │   │
│   │  🔐 Encryption  │  📋 Audit Logs  │  🛡️ Firewall  │  💾 Backups   │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
Government-CCaaS-in-a-Box/
│
├── 📄 README.md                         ◄── You are here
├── 📄 DEPLOYMENT_GUIDE.md               ◄── Step-by-step setup instructions
├── 📄 FEDRAMP_COMPLIANCE.md             ◄── Security controls documentation
├── 📄 AGENT_OPTIONS_COMPARISON.md       ◄── Bedrock vs Connect AI comparison
│
├── 🤖 AI AGENT CONFIGURATION
│   ├── agent-prompt.md                  ◄── AI personality & conversation rules
│   ├── agent-configuration-bedrock.json ◄── Amazon Bedrock Agent setup
│   ├── agent-configuration-connect.json ◄── Connect Native AI setup
│   ├── survey-questions.json            ◄── Census survey questions
│   └── contact-flow.json                ◄── Call routing logic
│
├── 📦 lambda/                           ◄── Backend code (Node.js)
│   ├── index.js                         ◄── Address lookup, save survey
│   └── package.json                     ◄── Dependencies
│
├── 🗣️ lex-bot/                          ◄── Voice recognition (Amazon Lex)
│   ├── bot-definition.json              ◄── Bot configuration
│   ├── locale-en_US.json                ◄── English language settings
│   ├── slot-types.json                  ◄── Custom data types
│   ├── intents.json                     ◄── What users can say
│   └── lambda/fulfillment.js            ◄── Response logic
│
└── 🏗️ terraform/                        ◄── Infrastructure as Code
    ├── main.tf                          ◄── Main orchestration
    ├── variables.tf                     ◄── Configuration options
    ├── outputs.tf                       ◄── What gets created
    ├── fedramp.tf                       ◄── FedRAMP compliance toggle
    ├── terraform.tfvars.example         ◄── Sample configuration
    │
    └── modules/                         ◄── Modular infrastructure components
        │
        ├── 📞 CONTACT CENTER
        │   ├── connect/                 ◄── Amazon Connect instance
        │   ├── connect-queues/          ◄── Call routing queues
        │   ├── connect-users/           ◄── Agent accounts
        │   └── contact-lens/            ◄── Call analytics & quality
        │
        ├── 🤖 AI/ML
        │   ├── lex/                      ◄── Voice/chat bot
        │   ├── bedrock/                  ◄── AI guardrails & safety
        │   └── lambda/                   ◄── Business logic functions
        │
        ├── 💾 DATA
        │   ├── dynamodb/                 ◄── Survey response database
        │   └── monitoring/               ◄── CloudWatch dashboards
        │
        └── 🔒 SECURITY (FedRAMP)
            ├── kms/                      ◄── Encryption keys
            ├── cloudtrail/               ◄── Audit logging
            ├── vpc/                      ◄── Network isolation
            ├── waf/                      ◄── Web firewall
            ├── config-rules/             ◄── Compliance monitoring
            ├── backup/                   ◄── Disaster recovery
            └── iam/                      ◄── Access control
```

---

## 🚀 How to Deploy

### Prerequisites

Before starting, you need:
1. **An AWS Account** - Government accounts work best, but commercial works too
2. **AWS CLI installed** - Command-line tool for AWS ([install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
3. **Terraform installed** (version 1.5+) - Infrastructure tool ([install guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
4. **Amazon Bedrock access** - Request Claude model access in AWS Console

### Quick Start (5 Commands)

```bash
# 1. Download this project
git clone https://github.com/636137/MarcS-CensusDemo.git
cd MarcS-CensusDemo/terraform

# 2. Copy and edit the configuration file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings (see Configuration section below)

# 3. Initialize Terraform
terraform init

# 4. Preview what will be created
terraform plan

# 5. Deploy everything
terraform apply
```

**That's it!** In about 15-20 minutes, you'll have a complete contact center.

### Configuration Options

Edit `terraform.tfvars` to customize your deployment:

```hcl
# Basic Settings
project_name = "census-agent"      # Name prefix for all resources
environment  = "production"        # production, staging, or development
aws_region   = "us-east-1"         # AWS region to deploy to

# Connect Instance (creates a new contact center)
create_connect_instance = true     # Set to true to create new instance
connect_instance_alias  = "census-contact-center"

# AI Settings
bedrock_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"

# SECURITY: FedRAMP Compliance (HIGHLY RECOMMENDED FOR GOVERNMENT)
enable_fedramp_compliance = true   # Deploys all security controls
deploy_in_vpc             = true   # Private network
enable_waf                = true   # Web firewall
enable_backup             = true   # Automated backups
security_contact_email    = "security@agency.gov"
allowed_countries         = ["US"] # Restrict access to US only
```

---

## 🔒 FedRAMP Compliance Explained

**What is FedRAMP?** It's the government's security standard for cloud services. If you're deploying for a federal agency, you likely need FedRAMP compliance.

When you set `enable_fedramp_compliance = true`, the following security controls are automatically deployed:

### Security Controls Summary

| What | Why | FedRAMP Control |
|------|-----|-----------------|
| **Encryption Keys (KMS)** | All data encrypted with keys only you control | SC-12, SC-13, SC-28 |
| **Audit Logging (CloudTrail)** | Every action recorded for 7 years | AU-2, AU-3, AU-9, AU-12 |
| **Network Isolation (VPC)** | Private network, no public internet exposure | SC-7, SC-8, AC-4 |
| **Web Firewall (WAF)** | Block attacks, US-only access | SC-5, SI-3 |
| **Compliance Monitoring (Config)** | Automatic security checks | CA-7, CM-6 |
| **Automated Backups** | Daily/weekly/monthly backups | CP-9, CP-10 |

**Cost Impact:** FedRAMP controls add approximately $150-300/month to base costs.

For detailed control mappings, see [FEDRAMP_COMPLIANCE.md](FEDRAMP_COMPLIANCE.md).

---

## 🤖 The AI Census Agent

### How the Survey Works

```
1. GREETING
   "Hello! This is the Census Bureau AI assistant. This call 
   may be recorded for quality assurance. All information you 
   provide is protected under Title 13 of the U.S. Code."

2. ADDRESS VERIFICATION
   "I show your address as 123 Main Street, Anytown, State 12345.
   Is this correct?"

3. HOUSEHOLD COUNT
   "As of April 1st, how many people were living or staying 
   at this address?"

4. FOR EACH PERSON (repeat as needed)
   - First name, Last name
   - Relationship to person 1 (spouse, child, parent, etc.)
   - Sex (male/female)
   - Date of birth
   - Hispanic/Latino origin (yes/no)
   - Race (can select multiple)

5. HOUSING INFORMATION
   "Is this house owned, rented, or occupied without payment?"

6. CONFIRMATION
   "Your confirmation number is ABC123. Thank you for 
   completing the census!"
```

### Safety Features

The AI has built-in protections:

**What it will NEVER ask or accept:**
- ❌ Social Security Numbers
- ❌ Income or financial information
- ❌ Immigration status or citizenship
- ❌ Political opinions
- ❌ Information about neighbors

**When it transfers to a human:**
- Caller says "speak to a person" or "agent"
- Three misunderstandings in a row
- Complex situations (shared custody, military, students away at college)
- Caller expresses frustration

### Two AI Options

| Option | Best For | Complexity |
|--------|----------|------------|
| **Amazon Bedrock Agent** | Maximum flexibility, use AI across multiple channels | Medium |
| **Connect Native AI** | Simpler setup, everything stays in Connect | Easy |

See [AGENT_OPTIONS_COMPARISON.md](AGENT_OPTIONS_COMPARISON.md) for detailed comparison.

---

## 📞 Amazon Connect Contact Center

### What Gets Created

When `create_connect_instance = true`:

| Component | Description |
|-----------|-------------|
| **Connect Instance** | Your contact center "headquarters" |
| **Phone Numbers** | Claim toll-free or local numbers |
| **Contact Flows** | Call routing logic (IVR) |
| **Queues** | Where calls wait for agents |
| **Routing Profiles** | Which queues agents can take calls from |
| **Hours of Operation** | Business hours configuration |
| **Agent Accounts** | Login credentials for human agents |

### Contact Lens Analytics

Call quality monitoring includes:
- **Transcription**: Every call converted to text
- **Sentiment Analysis**: Detect caller mood (positive/negative/neutral)
- **Keyword Spotting**: Alert when specific words are said
- **Quality Scores**: Automatic evaluation of each call

---

## 💾 Data Storage

### Survey Responses

Stored in DynamoDB (a fast, serverless database):

```json
{
  "caseId": "CENSUS-2024-ABC123",
  "timestamp": "2024-03-15T14:30:00Z",
  "status": "COMPLETED",
  "address": {
    "street": "123 Main Street",
    "city": "Anytown",
    "state": "ST",
    "zip": "12345"
  },
  "householdCount": 3,
  "persons": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "relationship": "SELF",
      "sex": "Male",
      "dateOfBirth": "1985-06-15",
      "hispanicOrigin": "No",
      "race": ["White"]
    }
  ],
  "housing": {
    "tenure": "OWNED"
  },
  "contactInfo": {
    "phone": "+12025551234"
  }
}
```

### Data Security

- **Encrypted at rest**: AES-256 encryption using your KMS keys
- **Encrypted in transit**: TLS 1.2/1.3 for all connections
- **Access logged**: Every read/write recorded in CloudTrail
- **Backed up daily**: Automatic backups with 35-day retention

---

## 💰 Cost Estimate

### Monthly Costs by Scale

| Scale | Calls/Month | Chat/Month | Estimated Cost |
|-------|-------------|------------|----------------|
| **Small** | 1,000 | 500 | $300-500/month |
| **Medium** | 10,000 | 5,000 | $1,500-2,500/month |
| **Large** | 100,000 | 50,000 | $10,000-15,000/month |

### Cost Breakdown

| Service | What it does | Cost basis |
|---------|-------------|------------|
| **Amazon Connect** | Phone/chat infrastructure | ~$0.018/min voice, $0.004/message chat |
| **Amazon Bedrock (Claude)** | AI responses | ~$0.003/1K input tokens, $0.015/1K output tokens |
| **Amazon Lex** | Voice recognition | ~$0.004/voice request |
| **DynamoDB** | Data storage | ~$0.25/GB/month + read/write |
| **Lambda** | Backend code | ~$0.20/million requests |
| **FedRAMP modules** | Security controls | ~$150-300/month base |

**Note:** These are estimates. Actual costs depend on call duration, conversation length, and data volume. Use the [AWS Pricing Calculator](https://calculator.aws/) for precise estimates.

---

## 🔧 Customization Guide

| What You Want to Change | What to Edit |
|------------------------|--------------|
| AI personality and responses | [agent-prompt.md](agent-prompt.md) |
| Survey questions | [survey-questions.json](survey-questions.json) |
| Call routing logic | [contact-flow.json](contact-flow.json) |
| AI safety rules | `agent-configuration-*.json` |
| Database structure | `terraform/modules/dynamodb/` |
| Security settings | `terraform.tfvars` |
| Agent queues | `terraform/modules/connect-queues/` |

---

## ❓ Frequently Asked Questions

### Setup Questions

**Q: How long does deployment take?**
A: About 15-20 minutes for the full stack, including FedRAMP modules.

**Q: Do I need an existing AWS account?**
A: Yes, you need an AWS account. Government agencies can use AWS GovCloud for highest compliance.

**Q: Can I deploy to AWS GovCloud?**
A: Yes. Change `aws_region` to a GovCloud region (e.g., `us-gov-west-1`).

**Q: What permissions do I need?**
A: Administrator access for initial deployment. Create restricted roles for ongoing operations.

### Usage Questions

**Q: Can people complete the survey on a website instead of calling?**
A: Yes! The chat widget can be embedded on any website.

**Q: What if the AI doesn't understand someone?**
A: After 3 failed attempts, it transfers to a human agent.

**Q: Can this work in other languages?**
A: The base configuration is English only. Add more languages by creating additional Lex bot locales.

**Q: How do I train the AI on different questions?**
A: Edit `agent-prompt.md` (AI behavior) and `survey-questions.json` (specific questions).

### Cost Questions

**Q: What's the minimum cost to run this?**
A: Around $200-300/month for the base infrastructure with FedRAMP compliance, even with zero calls.

**Q: How can I reduce costs for development?**
A: Set `enable_fedramp_compliance = false` and `enable_backup = false` for dev environments.

**Q: Is this cheaper than human agents?**
A: For high-volume, repetitive surveys, yes. The AI handles ~80% of calls at roughly 1/10th the cost per interaction.

### Security Questions

**Q: Is this secure enough for government use?**
A: With `enable_fedramp_compliance = true`, it implements controls for FedRAMP Moderate baseline. Complete authorization requires organizational policies and a 3PAO assessment.

**Q: Where is the data stored?**
A: In your AWS account, in the region you specify. With FedRAMP mode, data never leaves your VPC.

**Q: Can I use this for PII (personally identifiable information)?**
A: Yes. The encryption, access controls, and audit logging are designed for PII handling.

### Support Questions

**Q: Something isn't working. Where do I look?**
A: Check CloudWatch Logs in the AWS Console. Each Lambda function logs errors there.

**Q: How do I update the AI behavior?**
A: Edit `agent-prompt.md` and redeploy with `terraform apply`.

**Q: Can I get professional support?**
A: AWS offers paid support plans. System integrators can also help deploy and customize this solution.

---

## 📚 Related Documentation

| Document | Description |
|----------|-------------|
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Detailed step-by-step deployment instructions |
| [FEDRAMP_COMPLIANCE.md](FEDRAMP_COMPLIANCE.md) | Complete FedRAMP control mapping and compliance guide |
| [AGENT_OPTIONS_COMPARISON.md](AGENT_OPTIONS_COMPARISON.md) | Bedrock Agent vs Connect Native AI comparison |

---

## 🏁 Quick Reference

### Key Terraform Commands

```bash
terraform init      # Download required providers
terraform plan      # Preview changes (safe, no modifications)
terraform apply     # Deploy or update infrastructure
terraform destroy   # Delete everything (careful!)
terraform output    # Show created resource IDs
```

### Key Files to Edit

```
terraform/terraform.tfvars   # Your configuration
agent-prompt.md              # AI behavior
survey-questions.json        # Question wording
contact-flow.json            # Call routing
```

### Key AWS Console Locations

```
Amazon Connect    → Your contact center dashboard
CloudWatch Logs   → Error logs and debugging
DynamoDB          → Survey response data
CloudTrail        → Audit logs
AWS Config        → Compliance status
```

---

## 📄 License

This project is provided for demonstration and educational purposes for government modernization initiatives.

---

## 🤝 Contributing

Contributions welcome! Please submit issues and pull requests to help improve this Government CCaaS solution.

---

**Built with ❤️ for Government Digital Transformation**
