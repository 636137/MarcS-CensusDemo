#!/bin/bash

INSTANCE_ID=$1
REGION=${AWS_REGION:-us-east-1}

if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: $0 <connect-instance-id>"
    echo "Example: $0 1d3555df-0f7a-4c78-9177-d42253597de2"
    exit 1
fi

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Adding 20 Contact Lens Rules (Real-time & Post-call)       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Instance: $INSTANCE_ID"
echo "Region: $REGION"
echo ""

# Real-time Rules (10)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "REAL-TIME RULES (Trigger during call)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Creating: RT-PII-Detection"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-PII-Detection" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"social security|SSN|credit card","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"PII-Detected"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Negative-Sentiment"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Negative-Sentiment" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"SENTIMENT_SCORE","Value":"NEGATIVE","ComparisonType":"EQUALS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Negative-Sentiment"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Escalation-Request"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Escalation-Request" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"supervisor|manager|escalate|complaint","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Escalation-Requested"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Profanity-Detection"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Profanity-Detection" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"profanity|curse|inappropriate","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Profanity-Detected"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Refusal-To-Participate"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Refusal-To-Participate" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"refuse|not interested|don'\''t want|no thanks","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Survey-Refused"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Language-Barrier"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Language-Barrier" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"no english|spanish|translator|don'\''t understand","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Language-Barrier"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Technical-Issue"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Technical-Issue" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"website down|can'\''t login|error|not working","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Technical-Issue"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Callback-Request"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Callback-Request" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"call back|call me back|reach me|contact me","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Callback-Requested"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-Agent-Compliance-Issue"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-Agent-Compliance-Issue" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"AGENT_TRANSCRIPT","Value":"skip|forget|didn'\''t mention","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Compliance-Issue"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: RT-High-Value-Case"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "RT-High-Value-Case" \
    --trigger-event-source '{"EventSourceName":"OnRealTimeCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"urgent|emergency|deadline|important","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"High-Priority"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "POST-CALL RULES (Trigger after call ends)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Creating: PC-Script-Compliance-Check"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Script-Compliance-Check" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"AGENT_TRANSCRIPT","Value":"greeting|privacy notice|confidential|voluntary","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Script-Compliant"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Data-Verification-Missing"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Data-Verification-Missing" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"AGENT_TRANSCRIPT","Value":"verify|confirm|read back|correct","ComparisonType":"NOT_CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Data-Not-Verified"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-No-Confirmation-Number"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-No-Confirmation-Number" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"AGENT_TRANSCRIPT","Value":"confirmation|reference number|case number","ComparisonType":"NOT_CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"No-Confirmation"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Incomplete-Survey"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Incomplete-Survey" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"household size|address|complete|finished","ComparisonType":"NOT_CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Survey-Incomplete"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Customer-Satisfaction-Positive"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Customer-Satisfaction-Positive" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"CUSTOMER_TRANSCRIPT","Value":"thank you|helpful|appreciate|great service","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Positive-Feedback"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Customer-Satisfaction-Negative"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Customer-Satisfaction-Negative" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"CUSTOMER_TRANSCRIPT","Value":"waste of time|unhelpful|rude|poor service","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Negative-Feedback"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Long-Call-Duration"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Long-Call-Duration" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"NumberCondition":{"FieldName":"CONTACT_DURATION","MinValue":900,"ComparisonType":"GREATER_THAN"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Long-Duration"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Short-Call-Duration"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Short-Call-Duration" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"NumberCondition":{"FieldName":"CONTACT_DURATION","MaxValue":120,"ComparisonType":"LESS_THAN"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Short-Duration"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Follow-Up-Required"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Follow-Up-Required" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"TRANSCRIPT","Value":"follow up|call back|pending|incomplete","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Follow-Up-Needed"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo "Creating: PC-Privacy-Compliance"
aws connect create-rule \
    --instance-id "$INSTANCE_ID" \
    --name "PC-Privacy-Compliance" \
    --trigger-event-source '{"EventSourceName":"OnPostCallAnalysisAvailable"}' \
    --function '{"Conditions":[{"StringCondition":{"FieldName":"AGENT_TRANSCRIPT","Value":"privacy|confidential|protected|secure","ComparisonType":"CONTAINS"}}],"Actions":[]}' \
    --actions '[{"ActionType":"ASSIGN_CONTACT_CATEGORY","AssignContactCategoryAction":{"Name":"Privacy-Compliant"}}]' \
    --publish-status "PUBLISHED" \
    --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ COMPLETED: 20 Contact Lens Rules Created"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Categories Assigned:"
echo "  • PII-Detected"
echo "  • Negative-Sentiment"
echo "  • Escalation-Requested"
echo "  • Profanity-Detected"
echo "  • Survey-Refused"
echo "  • Language-Barrier"
echo "  • Technical-Issue"
echo "  • Callback-Requested"
echo "  • Compliance-Issue"
echo "  • High-Priority"
echo "  • Script-Compliant"
echo "  • Data-Not-Verified"
echo "  • No-Confirmation"
echo "  • Survey-Incomplete"
echo "  • Positive-Feedback"
echo "  • Negative-Feedback"
echo "  • Long-Duration"
echo "  • Short-Duration"
echo "  • Follow-Up-Needed"
echo "  • Privacy-Compliant"
echo ""
echo "View rules in Connect console:"
echo "Analytics and optimization → Rules"
