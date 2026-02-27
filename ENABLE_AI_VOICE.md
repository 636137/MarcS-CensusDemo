# Enable AI Voice with Amazon Q

## Current Status

✅ Infrastructure ready:
- Bedrock Agent configured (5KNBMLPHSV)
- Lambda backend working (CensusAgentActions)
- Phone number active (+18332895330)
- CloudFormation template deployed

⚠️ Amazon Q not enabled (requires console - 5 minutes)

## Step 1: Enable Amazon Q (Console - 5 minutes)

### Instructions

1. **Open Amazon Connect Console**
   - Go to: https://console.aws.amazon.com/connect/
   - Select instance: **census-enumerator-9652**

2. **Navigate to Amazon Q**
   - In left menu, scroll down to "Amazon Q"
   - Click "Amazon Q"

3. **Enable Amazon Q**
   - Click "Enable Amazon Q" button
   - Review terms and click "Enable"
   - Wait 3-5 minutes for activation
   - Status will change to "Enabled"

4. **Verify Enablement**
   - Refresh the page
   - You should see "Amazon Q: Enabled"

## Step 2: Create Bedrock Integration (Automatic)

After Amazon Q is enabled, update the CloudFormation stack:

```bash
cd cloudformation

aws cloudformation update-stack \
  --stack-name census-amazon-q \
  --use-previous-template \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# Wait for completion
aws cloudformation wait stack-update-complete \
  --stack-name census-amazon-q \
  --region us-east-1

echo "✅ Bedrock Agent integrated!"
```

Or manually in console:

1. Go to Amazon Connect → Amazon Q
2. Click "Add" under "Generative AI"
3. Select "Amazon Bedrock Agent"
4. Enter Agent ID: **5KNBMLPHSV**
5. Enter Alias ID: **FYO3N8QDLX**
6. Click "Add"

## Step 3: Create AI Voice Contact Flow

### Option A: Import Pre-built Flow

1. Go to Connect Console → Contact flows
2. Create new contact flow: "Census AI Voice"
3. Import: `cloudformation/census-ai-voice-flow.json`
4. Publish

### Option B: Build in Designer

1. Create new contact flow
2. Add blocks:
   - **Set recording behavior** → Enable
   - **Play prompt** → "Thank you for calling the U.S. Census Bureau. I'm your AI assistant."
   - **Invoke Amazon Q** → Select Bedrock Agent (5KNBMLPHSV)
   - **Transfer to queue** → GeneralInquiries (fallback)
   - **Disconnect**

3. Connect blocks in order
4. Save and Publish

## Step 4: Associate with Phone Number

1. Go to Phone numbers
2. Click: +18332895330
3. Edit
4. Select: "Census AI Voice" flow
5. Save

## Step 5: Test

Call **+18332895330**

You should hear:
```
"Thank you for calling the U.S. Census Bureau. 
 I'm your AI assistant and I'll help you complete 
 your census survey today."
```

Then have a conversation:
- AI: "May I have your phone number?"
- You: "555-555-1234"
- AI: "I found your address: 123 Main Street. Is this correct?"
- You: "Yes"
- AI: "How many people live at this address?"
- You: "4 people"
- AI: "Are any of them under 18?"
- You: "Yes, 2 children"
- AI: "Thank you! Your confirmation number is CENSUS-20260227-XXXX"

## What This Enables

### Full AI Voice Conversation
- Natural language understanding
- Context-aware responses
- Function calling (verifyAddress, saveSurveyData)
- Confirmation number generation
- Seamless agent handoff if needed

### Features
- ✅ Voice-to-text (automatic)
- ✅ AI processing (Bedrock Agent)
- ✅ Text-to-speech (automatic)
- ✅ Lambda function calls
- ✅ DynamoDB storage
- ✅ Call recording
- ✅ Contact Lens analytics
- ✅ Agent handoff capability

## Architecture

```
Caller
  ↓
+18332895330
  ↓
Contact Flow
  ↓
Amazon Q (enabled)
  ↓
Bedrock Agent (5KNBMLPHSV)
  ↓
Lambda Functions
  ├─ verifyAddress
  ├─ saveSurveyData
  └─ generateConfirmation
  ↓
DynamoDB
```

## Troubleshooting

### Issue: "Amazon Q not available"
**Solution**: Complete Step 1 to enable Amazon Q

### Issue: "Agent not found"
**Solution**: Verify Bedrock Agent ID (5KNBMLPHSV) and Alias (FYO3N8QDLX)

### Issue: Lambda timeout
**Solution**: Increase timeout in contact flow to 30 seconds

### Issue: No response from AI
**Solution**: Check Lambda function logs and Bedrock Agent permissions

## Cost Impact

With Amazon Q enabled:
- Amazon Q: ~$0.20 per conversation
- Bedrock: ~$0.03 per conversation
- Total AI cost: ~$0.23 per AI-handled call

Compared to:
- Live agent: ~$5-10 per call (labor cost)

**Savings**: ~95% cost reduction for AI-handled calls

## Current vs. With Amazon Q

### Current (Without Amazon Q)
```
Call → Greeting → Queue → Live Agent
```
- All calls require live agents
- Higher cost
- Limited hours
- Queue wait times

### With Amazon Q
```
Call → AI Assistant → Complete Survey → Done
                    ↓ (if needed)
                    Live Agent
```
- Most calls handled by AI
- 24/7 availability
- Instant response
- Lower cost
- Agents handle complex cases only

## Status

- ✅ Bedrock Agent: Configured
- ✅ Lambda Backend: Working
- ✅ Phone Number: Active
- ✅ CloudFormation: Deployed
- ⚠️ Amazon Q: **Needs enablement (5 minutes)**
- ⚠️ Integration: **Automatic after Q enabled**
- ⚠️ Contact Flow: **Import provided file**

**Time to full AI voice**: ~10 minutes after enabling Amazon Q
