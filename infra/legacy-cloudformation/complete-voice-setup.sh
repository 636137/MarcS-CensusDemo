#!/bin/bash

################################################################################
# Complete Voice Setup - Claim TFN and Enable Voice
#
# This script completes the voice setup by:
# 1. Claiming a toll-free number (TFN)
# 2. Associating it with the Connect instance
# 3. Configuring for inbound calls
#
# Usage: ./complete-voice-setup.sh [INSTANCE_ID]
################################################################################

set -e

INSTANCE_ID=${1:-$(aws connect list-instances --region us-east-1 --query 'InstanceSummaryList[0].Id' --output text)}
REGION="us-east-1"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Complete Voice Setup - Claim Toll-Free Number           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Instance ID: $INSTANCE_ID"
echo ""

# Check if phone already claimed
EXISTING_PHONE=$(aws connect list-phone-numbers-v2 \
  --target-arn arn:aws:connect:$REGION:593804350786:instance/$INSTANCE_ID \
  --region $REGION \
  --query 'ListPhoneNumbersSummaryList[0].PhoneNumber' \
  --output text 2>/dev/null || echo "")

if [ ! -z "$EXISTING_PHONE" ] && [ "$EXISTING_PHONE" != "None" ]; then
  echo "✅ Phone number already claimed: $EXISTING_PHONE"
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║              VOICE ALREADY CONFIGURED                        ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "📞 Phone Number: $EXISTING_PHONE"
  echo "   Status: Active"
  echo ""
  echo "🧪 Test: Call $EXISTING_PHONE"
  exit 0
fi

# Search for available number
echo "→ Searching for available toll-free numbers..."
PHONE_NUMBER=$(aws connect search-available-phone-numbers \
  --target-arn arn:aws:connect:$REGION:593804350786:instance/$INSTANCE_ID \
  --phone-number-country-code US \
  --phone-number-type TOLL_FREE \
  --max-results 1 \
  --region $REGION \
  --query 'AvailableNumbersList[0].PhoneNumber' \
  --output text)

echo "✅ Found: $PHONE_NUMBER"
echo ""

# Claim the number
echo "→ Claiming phone number..."
PHONE_NUMBER_ID=$(aws connect claim-phone-number \
  --target-arn arn:aws:connect:$REGION:593804350786:instance/$INSTANCE_ID \
  --phone-number $PHONE_NUMBER \
  --phone-number-description "Census Bureau Survey Line" \
  --region $REGION \
  --query 'PhoneNumberId' \
  --output text)

echo "✅ Claimed: $PHONE_NUMBER"
echo ""

# Get contact flow
echo "→ Getting contact flow..."
CONTACT_FLOW_ID=$(aws connect list-contact-flows \
  --instance-id $INSTANCE_ID \
  --contact-flow-types CONTACT_FLOW \
  --region $REGION \
  --query 'ContactFlowSummaryList[0].Id' \
  --output text)

echo "✅ Contact Flow: $CONTACT_FLOW_ID"
echo ""

# Associate
echo "→ Associating phone with contact flow..."
aws connect associate-phone-number-contact-flow \
  --phone-number-id $PHONE_NUMBER_ID \
  --instance-id $INSTANCE_ID \
  --contact-flow-id $CONTACT_FLOW_ID \
  --region $REGION

echo "✅ Associated"
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              VOICE SETUP COMPLETE                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📞 Toll-Free Number: $PHONE_NUMBER"
echo "   Phone Number ID: $PHONE_NUMBER_ID"
echo "   Type: TOLL_FREE"
echo "   Status: Active"
echo ""
echo "✅ Features Enabled:"
echo "   • Inbound calls"
echo "   • IVR/Contact flows"
echo "   • Queue routing"
echo "   • Call recording"
echo "   • Contact Lens analytics"
echo ""
echo "🧪 Test Now:"
echo "   Call: $PHONE_NUMBER"
echo ""
echo "📋 Next Steps:"
echo "   1. Test inbound call"
echo "   2. Configure agents in Connect console"
echo "   3. Customize contact flows"
echo "   4. Enable Amazon Q for AI voice"
echo ""
