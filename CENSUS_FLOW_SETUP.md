# Census Contact Flow Setup

## Quick Setup (1 Minute via Console)

The census-specific contact flow is ready to import. Follow these steps:

### Step 1: Import Contact Flow

1. **Open Amazon Connect Console**
   - Go to: https://console.aws.amazon.com/connect/
   - Select instance: **census-enumerator-9652**

2. **Create New Contact Flow**
   - Click "Contact flows" in left menu
   - Click "Create contact flow" button
   - Give it a name: **"Census Survey Inbound"**

3. **Import the Flow**
   - Click "Save" dropdown (top right)
   - Select "Import flow (beta)"
   - Upload file: `cloudformation/census-inbound-flow.json`
   - The flow will appear with all blocks configured

4. **Publish the Flow**
   - Click "Save" button
   - Click "Publish" button
   - Confirm publication

### Step 2: Associate with Phone Number

1. **Go to Phone Numbers**
   - Click "Phone numbers" in left menu
   - Find: **+18332895330**
   - Click on the phone number

2. **Edit Phone Number**
   - Click "Edit" button
   - In "Contact flow / IVR" dropdown:
     - Select: **"Census Survey Inbound"** (your new flow)
   - Click "Save"

### Step 3: Test

Call **+18332895330**

You'll hear:
```
"Thank you for calling the U.S. Census Bureau.
 This call may be recorded for quality assurance.
 Please stay on the line to complete your census survey
 with one of our representatives."
```

Then:
- Call recording starts
- Routed to GeneralInquiries queue
- Connected to available agent
- Or hear hold music if no agents available

## What This Flow Does

### Flow Diagram
```
Caller
  ↓
Enable Recording
  ↓
Play Greeting (Census message)
  ↓
Set Queue (GeneralInquiries)
  ↓
Transfer to Queue
  ↓
Connect to Agent
```

### Features
- ✅ Professional Census Bureau greeting
- ✅ Call recording enabled automatically
- ✅ Routes to GeneralInquiries queue
- ✅ Transfers to first available agent
- ✅ Handles errors gracefully
- ✅ Works with Contact Lens analytics
- ✅ Compatible with evaluation forms

## Testing as Agent

To receive calls:

1. **Log into CCP**
   - Go to your Connect instance URL
   - Click "Log in for emergency access"
   - Or use the CCP URL

2. **Set Status**
   - Set your status to "Available"
   - Select "GeneralInquiries" queue

3. **Receive Call**
   - Call +18332895330 from another phone
   - You'll receive the call in CCP
   - Answer and assist with census survey

4. **Use Evaluation Forms**
   - After call ends
   - Complete evaluation form
   - Submit for quality assurance

## File Location

The contact flow JSON is located at:
```
cloudformation/census-inbound-flow.json
```

This file contains the complete flow configuration and can be:
- Imported into any Connect instance
- Modified in the flow designer
- Version controlled in Git
- Shared across environments

## Troubleshooting

**Issue**: Still hearing dice message
- **Solution**: Make sure you selected the new flow in phone number settings
- **Wait**: Changes can take 1-2 minutes to propagate

**Issue**: Call disconnects immediately
- **Solution**: Check that GeneralInquiries queue exists and is active

**Issue**: No agents available
- **Solution**: Log into CCP and set status to Available

## Next Steps

After setting up the flow:

1. ✅ Test inbound calls
2. ✅ Train agents on census survey process
3. ✅ Use evaluation forms for QA
4. ✅ Review Contact Lens analytics
5. ✅ Customize flow as needed (add IVR menu, etc.)

## Status

- ✅ Flow file created: census-inbound-flow.json
- ✅ Queue configured: GeneralInquiries
- ✅ Phone number claimed: +18332895330
- ⚠️ Flow import: Requires console (1 minute)
- ⚠️ Phone association: Requires console (30 seconds)

**Total setup time**: ~2 minutes via console
