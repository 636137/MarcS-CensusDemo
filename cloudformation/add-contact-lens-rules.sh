#!/bin/bash

INSTANCE_ID=$1
REGION=${AWS_REGION:-us-east-1}

if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: $0 <connect-instance-id>"
    echo "Example: $0 1d3555df-0f7a-4c78-9177-d42253597de2"
    exit 1
fi

echo "Adding 20 Contact Lens Evaluation Forms to instance: $INSTANCE_ID"
echo "Region: $REGION"
echo ""

# Array of evaluation forms
declare -a FORMS=(
    "PII Detection Alert|Alert when sensitive information like SSN or credit card is shared|Compliance Check|Was PII detected in conversation?"
    "Script Compliance|Verify agent follows required census script|Script Adherence|Did agent use proper greeting?"
    "Negative Sentiment Detection|Alert when customer sentiment turns negative|Sentiment Analysis|Customer sentiment level"
    "Extended Silence Alert|Detect silence periods exceeding 20 seconds|Call Quality|Was there extended silence?"
    "Agent Interruption Monitor|Track excessive agent interruptions of customer|Communication Quality|Did agent interrupt excessively?"
    "Required Compliance Keywords|Verify confidentiality and voluntary participation mentioned|Compliance Keywords|Were required compliance phrases used?"
    "Escalation Keywords|Detect supervisor manager or complaint keywords|Escalation Indicators|Did customer request escalation?"
    "Callback Request Tracking|Track and ensure callback requests are logged|Callback Management|Did customer request callback?"
    "Language Barrier Detection|Identify when language assistance is needed|Language Support|Was language barrier detected?"
    "Technical Issue Identification|Track portal website or system issues reported|Technical Issues|Did customer report technical issue?"
    "Survey Refusal Tracking|Track and categorize survey refusals|Participation Status|Did customer refuse to participate?"
    "Data Accuracy Verification|Ensure agent reads back data for confirmation|Data Quality|Was data read back to customer?"
    "Confirmation Number Provided|Verify confirmation number was given to customer|Call Closure|Was confirmation number provided?"
    "Call Duration Analysis|Flag unusually short or long calls for review|Call Metrics|Was call duration appropriate?"
    "Customer Satisfaction Indicators|Track thank you satisfied or dissatisfied keywords|Satisfaction|Customer satisfaction level"
    "Address Verification Complete|Confirm address was verified with customer|Address Verification|Was address verified?"
    "Household Size Captured|Verify household count was collected|Survey Completion|Was household size recorded?"
    "Follow-up Action Required|Flag cases requiring additional follow-up|Follow-up|Is follow-up needed?"
    "Overall Call Quality Assessment|Comprehensive quality evaluation for QA team|Quality Metrics|Professional tone maintained?"
    "Data Privacy Compliance|Verify data privacy statements were provided|Privacy Compliance|Were privacy statements given?"
)

COUNT=0
for FORM in "${FORMS[@]}"; do
    IFS='|' read -r TITLE DESC SECTION QUESTION <<< "$FORM"
    REF_ID="form_$(echo $TITLE | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | head -c 20)"
    
    echo "Creating: $TITLE"
    
    aws connect create-evaluation-form \
        --instance-id "$INSTANCE_ID" \
        --title "$TITLE" \
        --description "$DESC" \
        --items "[{\"Section\":{\"Title\":\"$SECTION\",\"RefId\":\"${REF_ID}_sec\",\"Items\":[{\"Question\":{\"Title\":\"$QUESTION\",\"RefId\":\"${REF_ID}_q1\",\"QuestionType\":\"SINGLESELECT\",\"QuestionTypeProperties\":{\"SingleSelect\":{\"Options\":[{\"RefId\":\"opt1\",\"Text\":\"Yes\"},{\"RefId\":\"opt2\",\"Text\":\"No\"}]}}}}]}}]" \
        --region "$REGION" \
        --output json > /dev/null 2>&1 && echo "   ✅ Created" || echo "   ⚠️  Already exists or error"
    
    ((COUNT++))
done

echo ""
echo "=========================================="
echo "✅ Completed: $COUNT evaluation forms processed"
echo "=========================================="
echo ""
echo "View forms in Connect console:"
echo "Analytics and optimization → Evaluation forms"
