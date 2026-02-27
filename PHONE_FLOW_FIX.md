# Fix Phone Number Contact Flow Association

## Issue
Phone number +18332895330 is playing "Amazon Connect will not simulate rolling dice" message, which means it's using the Sample AB test flow instead of a proper inbound flow.

## Solution (2 minutes via Console)

### Step 1: Open Amazon Connect Console
1. Go to: https://console.aws.amazon.com/connect/
2. Select instance: **census-enumerator-9652**
3. Click "View phone numbers" in left menu

### Step 2: Edit Phone Number
1. Find phone number: **+18332895330**
2. Click on the phone number
3. Click "Edit"

### Step 3: Associate Contact Flow
1. In "Contact flow / IVR" dropdown, select:
   - **Sample inbound flow (first contact experience)**
   
   OR create a new flow:
   - Click "Create new contact flow"
   - Add "Play prompt" block with text:
     ```
     Thank you for calling the U.S. Census Bureau.
     This call may be recorded for quality assurance.
     Please stay on the line to speak with a representative.
     ```
   - Add "Transfer to queue" block → Select "GeneralInquiries"
   - Save and publish as "Census Survey Flow"
   - Go back and select this flow

2. Click "Save"

### Step 4: Test
Call **+18332895330** - you should now hear the proper greeting instead of the dice message.

## Alternative: Via CLI (Already Attempted)

The following command was run but association may take time to propagate:

```bash
aws connect associate-phone-number-contact-flow \
  --phone-number-id 2f2c10bc-a87f-479b-98ce-28cacddc66a9 \
  --instance-id 1d3555df-0f7a-4c78-9177-d42253597de2 \
  --contact-flow-id 36e2032a-a020-4b94-953a-4f2dcd40df5e \
  --region us-east-1
```

If this was just run, wait 2-3 minutes and try calling again.

## Verification

After fixing, when you call +18332895330 you should hear:
- A proper greeting (not dice message)
- Queue music or transfer to agent
- Professional census experience

## Current Status

- ✅ Phone number claimed: +18332895330
- ✅ Instance configured: census-enumerator-9652
- ⚠️  Contact flow association: Needs console verification
- ✅ Queues configured: GeneralInquiries, etc.
- ✅ Agents ready: Can log into CCP

The infrastructure is complete - just needs the contact flow association verified in the console.
