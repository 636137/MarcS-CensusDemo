# AI Agent for Census Survey Self-Service

## Overview

The AI Agent provides fully automated, conversational census survey collection using Amazon Bedrock and Amazon Connect integration.

## Features

- **Natural Conversation**: AI-powered dialogue using Claude 3 Sonnet
- **Address Verification**: Automatic lookup and confirmation
- **Data Collection**: Household size, minor status, and demographics
- **Confirmation**: Automated confirmation number generation
- **Fallback**: Seamless transfer to human agent if needed
- **Multi-language**: Can be configured for Spanish and other languages

## Architecture

```
Caller → Amazon Connect → AI Agent (Bedrock) → Lambda Actions → DynamoDB
                              ↓
                        Natural Language
                        Understanding
```

## Setup Instructions

### Prerequisites

- Amazon Connect instance deployed
- Bedrock access enabled in your AWS account
- Lambda execution role with DynamoDB permissions

### Step 1: Run Setup Script

```bash
cd cloudformation
./add-ai-agent.sh YOUR_INSTANCE_ID
```

This creates:
- Lambda function for agent actions
- API schema for agent capabilities
- Setup instructions

### Step 2: Create Bedrock Agent (AWS Console)

1. **Navigate to Bedrock Console**
   - Services → Amazon Bedrock → Agents

2. **Create Agent**
   - Click "Create agent"
   - Name: `CensusSurveyAgent`
   - Description: "AI agent for census survey data collection"

3. **Configure Model**
   - Model: `Anthropic Claude 3 Sonnet`
   - Instructions:
   ```
   You are a helpful census survey assistant. Your role is to:
   1. Greet the caller warmly and explain this is a census survey
   2. Verify the caller's address using their phone number
   3. Collect household size (number of people living at the address)
   4. Ask if anyone in the household is under 18 years old
   5. Confirm all information with the caller
   6. Save the survey data
   7. Provide a confirmation number
   8. Thank them for participating
   
   Always be polite, clear, and patient. If the caller refuses to participate, 
   thank them and end the call politely. If you encounter any issues, offer to 
   transfer them to a live agent.
   ```

4. **Add Action Group**
   - Name: `CensusSurveyActions`
   - Action group type: Define with API schemas
   - Lambda function: `CensusAgentActions`
   - API Schema: Upload `/tmp/agent_schema.json`

5. **Prepare Agent**
   - Click "Prepare" to validate configuration
   - Wait for preparation to complete

6. **Create Alias**
   - Name: `prod`
   - Description: "Production alias"

### Step 3: Integrate with Amazon Connect

1. **Enable Amazon Q in Connect**
   - Connect Console → Amazon Q
   - Enable Amazon Q for your instance

2. **Add Bedrock Agent Integration**
   - Integrations → Add integration
   - Type: Amazon Bedrock Agent
   - Select your `CensusSurveyAgent`
   - Alias: `prod`

3. **Create Contact Flow**
   - Flows → Create flow
   - Name: "AI Census Survey Flow"
   - Add blocks:
     - **Set contact attributes**: Store caller phone number
     - **Invoke Amazon Q**: Select CensusSurveyAgent
     - **Check contact attributes**: Check if survey completed
     - **Transfer to queue**: Fallback to human agent if needed
     - **Disconnect**: End call

4. **Assign Phone Number**
   - Phone numbers → Select number
   - Contact flow: "AI Census Survey Flow"

## Agent Capabilities

### 1. Address Verification
```
Agent: "Can I confirm your phone number?"
Caller: "555-123-4567"
Agent: "Thank you. I see you're calling from 123 Main Street, 
       Washington DC 20001. Is that correct?"
```

### 2. Household Size Collection
```
Agent: "How many people currently live at this address?"
Caller: "Four people"
Agent: "Thank you. So there are 4 people living at your address."
```

### 3. Minor Status
```
Agent: "Are any of these household members under 18 years old?"
Caller: "Yes, two children"
Agent: "Thank you for that information."
```

### 4. Confirmation
```
Agent: "Let me confirm: 4 people live at 123 Main Street, 
       including 2 minors. Is that correct?"
Caller: "Yes"
Agent: "Perfect. Your confirmation number is CENSUS-20260227-1234. 
       Please keep this for your records."
```

## Lambda Actions

The agent can perform these actions:

### verifyAddress
- **Input**: Phone number
- **Output**: Address details
- **Purpose**: Verify caller's address

### saveSurveyData
- **Input**: Phone, address, household size, minor status
- **Output**: Case ID
- **Purpose**: Store survey data in DynamoDB

### generateConfirmation
- **Input**: Case ID
- **Output**: Confirmation message
- **Purpose**: Provide confirmation to caller

## Testing

### Test the Agent

1. **In Bedrock Console**
   - Agent → Test
   - Type: "I want to complete my census survey"
   - Verify agent responses

2. **In Connect**
   - Call your Connect number
   - Follow agent prompts
   - Verify data saved in DynamoDB

### Sample Conversation

```
Agent: Thank you for calling the Census Bureau. I'm an AI assistant 
       here to help you complete your census survey.

Caller: Hi, I need to complete my survey.

Agent: I'd be happy to help! Can I start by confirming your phone number?

Caller: It's 555-123-4567

Agent: Thank you. I see you're calling from 123 Main Street, Washington 
       DC 20001. Is that correct?

Caller: Yes, that's right.

Agent: Great! How many people currently live at this address?

Caller: Four people.

Agent: Thank you. Are any of these household members under 18 years old?

Caller: Yes, we have two children.

Agent: Perfect. Let me confirm: 4 people live at 123 Main Street, 
       including 2 minors. Is that correct?

Caller: Yes, that's correct.

Agent: Excellent! I've recorded your survey. Your confirmation number 
       is CENSUS-20260227-1234. Please keep this for your records. 
       Thank you for participating in the census!
```

## Customization

### Add More Questions

Edit agent instructions to include additional questions:
```
4. Ask about household income range
5. Ask about primary language spoken
6. Ask about housing type (own/rent)
```

### Multi-language Support

Create separate agents for different languages:
- `CensusSurveyAgent-Spanish`
- `CensusSurveyAgent-Chinese`

Route based on caller's language selection.

### Advanced Features

- **Sentiment Analysis**: Detect frustration and offer human agent
- **Callback Scheduling**: If caller is busy, schedule callback
- **SMS Confirmation**: Send confirmation via SMS
- **Email Receipt**: Email survey confirmation

## Monitoring

### CloudWatch Metrics

Monitor agent performance:
- Invocation count
- Success rate
- Average duration
- Error rate

### Connect Metrics

Track in Connect:
- AI-handled calls
- Transfer rate to human agents
- Survey completion rate
- Customer satisfaction

## Troubleshooting

### Agent Not Responding

1. Check Bedrock agent status (must be "Prepared")
2. Verify Lambda function has correct permissions
3. Check Connect integration is active

### Data Not Saving

1. Verify Lambda has DynamoDB permissions
2. Check table names in Lambda environment variables
3. Review CloudWatch logs for errors

### Poor Conversation Quality

1. Refine agent instructions
2. Add more examples to action group
3. Test with various caller scenarios
4. Adjust model temperature (if available)

## Cost Optimization

- **Bedrock**: ~$0.003 per 1000 input tokens
- **Lambda**: Free tier covers most usage
- **Connect**: Standard per-minute charges

Estimated cost per call: $0.05-0.10

## Security

- All data encrypted in transit and at rest
- PII handling follows compliance guidelines
- Agent logs can be disabled for privacy
- Audit trail in CloudWatch

## Next Steps

1. Deploy agent to production
2. Monitor initial calls
3. Refine instructions based on feedback
4. Add additional languages
5. Integrate with existing systems

## Support

For issues:
- Check CloudWatch logs
- Review Bedrock agent test console
- Contact AWS Support for Bedrock issues
