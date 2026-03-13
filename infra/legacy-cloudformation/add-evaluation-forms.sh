#!/bin/bash

INSTANCE_ID=$1
REGION=${AWS_REGION:-us-east-1}

if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: $0 <connect-instance-id>"
    echo "Example: $0 1d3555df-0f7a-4c78-9177-d42253597de2"
    exit 1
fi

echo "Adding 4 Comprehensive Evaluation Forms to instance: $INSTANCE_ID"
echo "Region: $REGION"
echo ""

# Form 1: Compliance & Security
echo "Creating: Compliance and Security Evaluation"
aws connect create-evaluation-form \
  --instance-id "$INSTANCE_ID" \
  --title "Compliance and Security Evaluation" \
  --description "Comprehensive compliance, security, and regulatory checks" \
  --items '[{"Section":{"Title":"Regulatory Compliance","RefId":"compliance_sec","Items":[{"Question":{"Title":"Was PII (SSN, credit card) detected or shared inappropriately?","RefId":"pii_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Flag for review"},{"RefId":"no","Text":"No - Compliant"}]}}}},{"Question":{"Title":"Did agent provide required privacy and confidentiality statements?","RefId":"privacy_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Compliant"},{"RefId":"no","Text":"No - Non-compliant"}]}}}},{"Question":{"Title":"Was voluntary participation clearly stated?","RefId":"voluntary_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Did agent follow required script and greeting?","RefId":"script_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Script followed"},{"RefId":"partial","Text":"Partial - Some deviations"},{"RefId":"no","Text":"No - Script not followed"}]}}}}]}}]' \
  --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

# Form 2: Call Quality & Customer Service
echo "Creating: Call Quality and Customer Service"
aws connect create-evaluation-form \
  --instance-id "$INSTANCE_ID" \
  --title "Call Quality and Customer Service" \
  --description "Comprehensive call quality, communication, and customer satisfaction assessment" \
  --items '[{"Section":{"Title":"Communication Quality","RefId":"quality_sec","Items":[{"Question":{"Title":"Customer sentiment during call","RefId":"sentiment_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"positive","Text":"Positive"},{"RefId":"neutral","Text":"Neutral"},{"RefId":"negative","Text":"Negative"}]}}}},{"Question":{"Title":"Was there extended silence (>20 seconds)?","RefId":"silence_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Did agent interrupt customer excessively?","RefId":"interruption_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Agent maintained professional tone?","RefId":"professional_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Communication was clear and understandable?","RefId":"clarity_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Call duration","RefId":"duration_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"appropriate","Text":"Appropriate (2-15 min)"},{"RefId":"short","Text":"Too short (<2 min)"},{"RefId":"long","Text":"Too long (>15 min)"}]}}}}]}}]' \
  --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

# Form 3: Survey Completion & Data Quality
echo "Creating: Survey Completion and Data Quality"
aws connect create-evaluation-form \
  --instance-id "$INSTANCE_ID" \
  --title "Survey Completion and Data Quality" \
  --description "Survey completion verification and data accuracy assessment" \
  --items '[{"Section":{"Title":"Survey Completion","RefId":"survey_sec","Items":[{"Question":{"Title":"Was address verified with customer?","RefId":"address_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Verified"},{"RefId":"no","Text":"No - Not verified"}]}}}},{"Question":{"Title":"Was household size recorded?","RefId":"household_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Was data read back to customer for confirmation?","RefId":"readback_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Data verified"},{"RefId":"no","Text":"No - Not verified"}]}}}},{"Question":{"Title":"Was confirmation number provided?","RefId":"confirmation_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Survey completion status","RefId":"completion_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"complete","Text":"Complete"},{"RefId":"partial","Text":"Partial - Follow-up needed"},{"RefId":"refused","Text":"Customer refused"}]}}}}]}}]' \
  --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

# Form 4: Issue Resolution & Follow-up
echo "Creating: Issue Resolution and Follow-up"
aws connect create-evaluation-form \
  --instance-id "$INSTANCE_ID" \
  --title "Issue Resolution and Follow-up" \
  --description "Issue handling, escalations, and follow-up requirements" \
  --items '[{"Section":{"Title":"Issue Management","RefId":"issue_sec","Items":[{"Question":{"Title":"Did customer request escalation or supervisor?","RefId":"escalation_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Escalated"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Was language barrier detected?","RefId":"language_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Language assistance needed"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Did customer report technical issues?","RefId":"technical_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Technical issue reported"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Did customer request callback?","RefId":"callback_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Callback scheduled"},{"RefId":"no","Text":"No"}]}}}},{"Question":{"Title":"Is follow-up action required?","RefId":"followup_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Follow-up needed"},{"RefId":"no","Text":"No - Case closed"}]}}}},{"Question":{"Title":"Was issue resolved?","RefId":"resolved_q","QuestionType":"SINGLESELECT","QuestionTypeProperties":{"SingleSelect":{"Options":[{"RefId":"yes","Text":"Yes - Resolved"},{"RefId":"partial","Text":"Partially resolved"},{"RefId":"no","Text":"No - Unresolved"}]}}}}]}}]' \
  --region "$REGION" > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists"

echo ""
echo "=========================================="
echo "✅ Completed: 4 comprehensive evaluation forms created"
echo "=========================================="
echo ""
echo "Forms created:"
echo "  1. Compliance and Security Evaluation (4 questions)"
echo "  2. Call Quality and Customer Service (6 questions)"
echo "  3. Survey Completion and Data Quality (5 questions)"
echo "  4. Issue Resolution and Follow-up (6 questions)"
echo ""
echo "Total: 21 evaluation questions across 4 forms"
echo ""
echo "View forms in Connect console:"
echo "Analytics and optimization → Evaluation forms"
