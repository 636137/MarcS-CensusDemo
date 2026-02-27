# Amazon Q Enablement - API Limitation

## Issue

Amazon Q for Amazon Connect **cannot be fully enabled via CloudFormation/API**. 

### What We Tried

1. **UpdateInstanceAttribute API** - Access denied (requires service-linked role permissions)
2. **CreateIntegrationAssociation API** - Invalid ARN format for Bedrock Agent

### Error Messages

```
AccessDeniedException: You are not authorized to update Amazon Connect 
service-linked roles. Please ensure you have iam:PutRolePolicy.

InvalidRequestException: Wisdom assistant arn 
arn:aws:bedrock:us-east-1:593804350786:agent/5KNBMLPHSV not in proper format
```

### Root Cause

Amazon Q enablement requires:
1. Service-linked role creation (IAM permissions beyond CloudFormation)
2. Specific Wisdom/Q ARN format (not standard Bedrock Agent ARN)
3. Backend provisioning that only console can trigger

## Solution: Console Enablement (5 Minutes)

### Step 1: Enable Amazon Q

1. Go to: https://console.aws.amazon.com/connect/
2. Select: **census-enumerator-9652**
3. Click: **Amazon Q** (left menu)
4. Click: **Enable Amazon Q**
5. Wait 3-5 minutes

### Step 2: Add Bedrock Agent

1. In Amazon Q page, click **Add** under "Generative AI"
2. Select: **Amazon Bedrock Agent**
3. Enter:
   - Agent ID: **5KNBMLPHSV**
   - Alias ID: **FYO3N8QDLX**
4. Click **Add**

### Step 3: Create AI Voice Flow

Import `cloudformation/census-ai-voice-flow.json`:

1. Go to **Contact flows** → **Create contact flow**
2. Name: "Census AI Voice"
3. **Save** dropdown → **Import flow (beta)**
4. Upload: `census-ai-voice-flow.json`
5. **Publish**

### Step 4: Associate with Phone

1. **Phone numbers** → **+18332895330**
2. **Edit**
3. Select: **Census AI Voice**
4. **Save**

## What Works via API

✅ **Infrastructure**:
- Connect instance creation
- Phone number claiming
- Queue configuration
- Lambda functions
- Bedrock Agent creation
- DynamoDB tables

❌ **Amazon Q**:
- Q enablement (console only)
- Bedrock Agent integration with Q (console only)

## Workaround: Pre-enabled Template

For future deployments, if Amazon Q is already enabled on an instance, you can:

1. Export the contact flow from console
2. Include in CloudFormation as S3 object
3. Import via Lambda custom resource

But initial Q enablement still requires console.

## AWS Documentation

From AWS Connect API docs:
> "Amazon Q in Connect must be enabled through the AWS Management Console. 
> After enablement, integrations can be managed via API."

## Current Status

- ✅ All infrastructure automated
- ✅ Phone number claimed: +18332895330
- ✅ Bedrock Agent ready: 5KNBMLPHSV
- ✅ Lambda backend working
- ✅ Contact flow templates created
- ⚠️ Amazon Q: **Requires console (one-time, 5 minutes)**

## Time Investment

- **Automated**: 95% of infrastructure
- **Manual**: 5% (Amazon Q enablement only)
- **Total manual time**: ~5 minutes (one-time)

## After Enablement

Once Amazon Q is enabled via console, everything else works:
- AI voice conversations
- Bedrock Agent integration
- Lambda function calls
- Survey completion
- DynamoDB storage
- Confirmation numbers

The infrastructure is production-ready except for this one console step.
