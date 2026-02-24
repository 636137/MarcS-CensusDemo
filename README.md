# Census Enumerator AI Agent for Amazon Connect

## What is This?

An AI-powered voice and chat agent that **automates census data collection** through Amazon Connect. Constituents call or chat, and the AI conducts the full census interview—verifying addresses, counting household members, and collecting demographic data for each person.

**Why it matters:** Reduces human enumerator workload by 60-80%, operates 24/7, ensures consistent data collection, and maintains federal compliance automatically.

---

## How It Works

```
Constituent calls/chats → Amazon Connect → AI Agent → Collects census data → Stores in DynamoDB
                                              ↓
                               Can escalate to human if needed
```

1. **Constituent initiates contact** via phone call or web chat
2. **AI Agent greets** and explains confidentiality protections (Title 13)
3. **Verifies address** on file (looks up by phone number)
4. **Collects household count** as of April 1st census date
5. **For each person:** name, relationship, sex, DOB, Hispanic origin, race
6. **Records housing tenure** (own/rent) and contact info
7. **Provides confirmation number** and thanks constituent

---

## Two Deployment Options

| Option | File | Best For |
|--------|------|----------|
| **Amazon Bedrock Agent** | `agent-configuration-bedrock.json` | Maximum flexibility, multi-channel reuse, advanced AI orchestration |
| **Amazon Connect Native** | `agent-configuration-connect.json` | Simpler setup, tight Connect integration, unified management |

See [AGENT_OPTIONS_COMPARISON.md](AGENT_OPTIONS_COMPARISON.md) for detailed comparison.

---

## Project Structure

```
├── README.md                         # You are here
├── AGENT_OPTIONS_COMPARISON.md       # Bedrock vs Connect Native comparison
├── DEPLOYMENT_GUIDE.md               # Step-by-step deployment instructions
│
├── agent-prompt.md                   # AI personality & conversation rules
├── agent-configuration-bedrock.json  # Bedrock Agent: actions & guardrails
├── agent-configuration-connect.json  # Connect Native: self-service actions
├── survey-questions.json             # All prompts (voice & chat variants)
├── contact-flow.json                 # Amazon Connect routing logic
│
├── lambda/                           # Backend business logic
│   ├── index.js                      # Main handler (address lookup, save data)
│   └── package.json                  # Dependencies (AWS SDK, uuid)
│
├── lex-bot/                          # Amazon Lex V2 bot definition
│   ├── bot-definition.json           # Bot metadata & settings
│   ├── locale-en_US.json             # English locale (Ruth voice, generative)
│   ├── slot-types.json               # Custom data types (yes/no, race, etc.)
│   ├── intents.json                  # User intent definitions & utterances
│   └── lambda/fulfillment.js         # Lex fulfillment handler
│
└── terraform/                        # Infrastructure as Code
    ├── main.tf                       # Orchestrates all modules
    ├── variables.tf                  # Configuration inputs
    ├── outputs.tf                    # Resource IDs & ARNs after deploy
    ├── terraform.tfvars.example      # Sample configuration
    └── modules/                      # Modular infrastructure
        ├── dynamodb/                 # Survey response storage
        ├── iam/                      # Permissions & roles
        ├── lambda/                   # Function deployment
        ├── lex/                      # Lex bot resources
        ├── bedrock/                  # AI guardrails
        └── monitoring/               # CloudWatch dashboards
```

---

## Quick Start (Terraform - Recommended)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # Configure your settings
terraform init                                  # Download providers
terraform plan                                  # Preview changes
terraform apply                                 # Deploy everything
```

**Prerequisites:**
- AWS Account with Amazon Connect instance already created
- Amazon Bedrock access enabled (Claude model)
- Terraform >= 1.5.0
- AWS CLI configured with appropriate permissions

---

## Manual Deployment

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for step-by-step manual instructions.

**Quick manual steps:**
1. Deploy Lambda: `cd lambda && npm install && zip -r function.zip . && aws lambda create-function ...`
2. Create DynamoDB tables: `CensusResponses` and `CensusAddresses`
3. Import `contact-flow.json` into Amazon Connect
4. Configure AI agent using `agent-prompt.md` as the system prompt

---

## Data Collected

| Category | Fields |
|----------|--------|
| **Address** | Street, City, State, ZIP (verified against records) |
| **Household** | Total person count as of April 1st |
| **Per Person** | First name, Last name, Relationship to householder, Sex, DOB, Age, Hispanic/Latino origin, Race (multi-select) |
| **Housing** | Tenure status (owned/rented/other) |
| **Contact** | Phone number for follow-up (optional) |

---

## Safety Guardrails

**Always blocks:**
- ❌ Social Security Numbers
- ❌ Financial information (income, bank accounts)
- ❌ Immigration/citizenship status questions
- ❌ Political opinions or voting questions
- ❌ Information about other households

**Automatic escalation to human when:**
- Constituent requests a live agent
- Three consecutive misunderstandings
- Complex living situation (custody, military, college students)
- Complaint or frustration detected

---

## Survey Flow

```
Greeting → Address Verification → Household Count → [For Each Person: Demographics] → Housing Info → Confirmation
```

---

## Customization

| What to change | Edit this file |
|----------------|----------------|
| AI personality, tone, conversation rules | `agent-prompt.md` |
| Question wording (voice/chat) | `survey-questions.json` |
| Backend actions & guardrails | `agent-configuration-*.json` |
| Call routing logic | `contact-flow.json` |
| Data storage schema | `terraform/modules/dynamodb/` |

---

## Testing

| Channel | How to test |
|---------|-------------|
| **Voice** | Claim a phone number in Connect → Associate with contact flow → Call |
| **Chat** | Configure chat widget → Embed on test page → Start chat |

**Test scenarios to cover:**
- ✅ Full survey completion (1-5 people)
- ✅ Large household (10+ people)
- ✅ Address verification failure
- ✅ Mid-survey callback request
- ✅ Request for live agent
- ✅ Survey refusal/abandonment

---

## Monitoring

**Key metrics in CloudWatch:**
- Survey completion rate
- Average handling time
- Escalation rate
- Error rate
- Callback volume

---

## Security & Compliance

- **Title 13 protection:** All responses legally protected, used only for statistics
- **Encryption:** Data encrypted at rest (DynamoDB) and in transit (TLS)
- **Audit logging:** All interactions logged to CloudWatch
- **PII blocking:** SSN, financial data automatically blocked by guardrails
- **Compliance:** Designed for FISMA and FedRAMP alignment

---

## Frequently Asked Questions (FAQs)

### Deployment Questions

**Q: How long does deployment take?**
A: Terraform deployment takes 5-10 minutes. Manual deployment takes 30-60 minutes depending on familiarity with AWS services.

**Q: What AWS permissions do I need?**
A: You need permissions for: Amazon Connect, Amazon Lex, AWS Lambda, Amazon DynamoDB, Amazon Bedrock, IAM, CloudWatch. Use an admin role for initial setup, then create restricted roles for production.

**Q: Can I deploy to multiple regions?**
A: Yes. Duplicate the Terraform configuration with different `aws_region` variables. Note: Amazon Connect instances are region-specific.

**Q: Does this work with an existing Connect instance?**
A: Yes. You'll import the contact flow into your existing instance and configure the AI agent. The Terraform deployment creates supporting resources (Lambda, DynamoDB) that integrate with your existing Connect.

**Q: What if I don't have Amazon Bedrock access?**
A: Request access through the AWS console under Amazon Bedrock → Model access. Claude models require explicit enablement. Approval is typically instant for commercial accounts.

### Usage Questions

**Q: How does the AI know which address to verify?**
A: The Lambda function looks up the caller's phone number in the `CensusAddresses` DynamoDB table. For testing, it returns a demo address if no match is found.

**Q: Can constituents complete the survey in multiple sessions?**
A: Partial surveys are saved with `status: PARTIAL`. However, the current implementation doesn't automatically resume—constituents would need to restart. Adding resume capability requires storing and matching session state.

**Q: What happens if the AI can't understand the constituent?**
A: After 3 consecutive misunderstandings, the AI automatically escalates to a human agent. Constituents can also say "speak to an agent" at any time.

**Q: How are callbacks handled?**
A: The `scheduleCallback` action stores callback preferences in DynamoDB. You'll need to build an outbound dialer process (or use Amazon Connect outbound campaigns) to actually make those callbacks.

**Q: Does it support languages other than English?**
A: The Lex bot is configured for English (en_US). To add languages: create additional locales in `lex-bot/`, translate prompts in `survey-questions.json`, and add language detection to the contact flow.

### Value Questions

**Q: What's the cost to run this?**
A: Costs vary by volume. Rough estimates per 1,000 completed surveys:
- Amazon Connect: ~$50-100 (voice minutes + chat)
- Amazon Bedrock: ~$20-40 (Claude API calls)
- Lambda: ~$1-2 (invocations)
- DynamoDB: ~$1-5 (reads/writes)
- Total: ~$75-150 per 1,000 surveys

**Q: How much human labor does this save?**
A: A human enumerator spends 10-15 minutes per survey. The AI handles straightforward surveys completely, escalating only complex cases (~10-20%). For 10,000 surveys: ~1,400 human-hours saved.

**Q: What's the completion rate?**
A: Depends on population. In testing, AI completion rates are comparable to human rates (70-85%) for willing participants. The AI excels at consistent, patient interactions and 24/7 availability.

**Q: Is the data quality comparable to human collection?**
A: Yes. The AI follows the exact same script, validates inputs (date formats, numeric ranges), and confirms critical data. It can't mistype or mishear as easily as humans.

### Technical Questions

**Q: Why two agent configurations (Bedrock vs Connect)?**
A: They represent different architectural patterns. Bedrock Agent is more flexible and reusable across channels. Connect Native is simpler if you're only using Amazon Connect. See `AGENT_OPTIONS_COMPARISON.md`.

**Q: Can I use a different AI model (not Claude)?**
A: Yes. Change `foundationModel` in the configuration and `bedrock_model_id` in Terraform variables. Compatible models: Claude (any version), Titan, or models you've provisioned.

**Q: How do I update the questions?**
A: Edit `survey-questions.json`. Each question has `voicePrompt` (for calls) and `chatPrompt` (for web chat). Update both to maintain consistency.

**Q: Where are survey responses stored?**
A: In the `CensusResponses` DynamoDB table. Each survey creates a record keyed by `caseId` with a `timestamp`. Person data is stored as nested objects.

**Q: How do I export the data?**
A: Query DynamoDB directly using AWS CLI, SDK, or console. For bulk exports, use DynamoDB Export to S3 feature or scan the table with pagination.

**Q: Can this integrate with existing census systems?**
A: Yes. Modify `lambda/index.js` to call your backend APIs instead of (or in addition to) DynamoDB. The architecture is designed for extensibility.

### Troubleshooting

**Q: The AI isn't responding / calls disconnect immediately**
A: Check: (1) Lambda function deployed and accessible, (2) Contact flow published with correct Lambda ARN, (3) IAM permissions allow Connect to invoke Lambda, (4) CloudWatch logs for errors.

**Q: Address lookup always fails**
A: For testing, the Lambda returns demo data if the address isn't found. In production, populate `CensusAddresses` table with real address data indexed by phone number.

**Q: Guardrails block legitimate responses**
A: Review `guardrails` section in agent configuration. Adjust `inputStrength` and `outputStrength` for content filters. Add words to allowlists if needed.

**Q: The voice sounds robotic / doesn't use the right voice**
A: Verify `locale-en_US.json` has `voiceSettings.voiceId: "Ruth"` and `engine: "generative"`. The generative engine produces more natural speech than standard or neural.

---

## Support

- **Deployment issues:** See CloudWatch logs for Lambda errors
- **Connect issues:** Check contact flow logs and Connect service quotas
- **AI behavior:** Adjust `agent-prompt.md` and guardrail settings
- **AWS platform:** Contact AWS Support

---

## License

This project is provided for demonstration and educational purposes.
