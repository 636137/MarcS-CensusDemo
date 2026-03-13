import json
import boto3
import os
from datetime import datetime
import random

# Strands imports
from strands import Agent, tool
from strands.models import BedrockModel

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
addresses_table = dynamodb.Table(os.environ.get('ADDRESS_TABLE', 'CensusAddresses'))
responses_table = dynamodb.Table(os.environ.get('CENSUS_TABLE', 'CensusResponses'))
sessions_table = dynamodb.Table('CensusChatSessions')

@tool
def verify_address(phone_number: str) -> str:
    """Look up the address associated with a phone number.

    Args:
        phone_number: The caller's phone number to look up their address.
    """
    try:
        response = addresses_table.query(
            IndexName='PhoneNumberIndex',
            KeyConditionExpression='phoneNumber = :phone',
            ExpressionAttributeValues={':phone': phone_number.replace('-', '').replace(' ', '')}
        )
        if response['Items']:
            a = response['Items'][0]
            return json.dumps({
                'found': True,
                'address': f"{a['streetAddress']}, {a['city']}, {a['state']} {a['zipCode']}"
            })
        return json.dumps({'found': False, 'message': 'Address not found for that phone number.'})
    except Exception as e:
        return json.dumps({'found': False, 'error': str(e)})


@tool
def save_survey_data(phone_number: str, address: str, household_size: int, has_minors: str) -> str:
    """Save the completed census survey data.

    Args:
        phone_number: The caller's phone number.
        address: The confirmed household address.
        household_size: Number of people living at the address.
        has_minors: Whether anyone under 18 lives at the address (yes/no).
    """
    case_id = f"CENSUS-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000, 9999)}"
    try:
        responses_table.put_item(Item={
            'caseId': case_id,
            'timestamp': datetime.now().isoformat(),
            'phoneNumber': phone_number,
            'address': address,
            'householdSize': household_size,
            'hasMinors': has_minors,
            'status': 'completed',
            'collectionMethod': 'strands-agent'
        })
        return json.dumps({'success': True, 'caseId': case_id})
    except Exception as e:
        return json.dumps({'success': False, 'error': str(e)})


@tool
def generate_confirmation(case_id: str) -> str:
    """Generate a confirmation message for a completed survey.

    Args:
        case_id: The case ID returned from save_survey_data.
    """
    return json.dumps({
        'confirmation': f"Your confirmation number is {case_id}. Please keep this for your records. Thank you for completing your census survey!"
    })


SYSTEM_PROMPT = """You are a helpful U.S. Census Bureau survey assistant. Guide the caller through:
1. Ask for their phone number
2. Use verify_address to look up their address
3. Confirm the address with the caller
4. Ask how many people live at the address
5. Ask if anyone under 18 lives there
6. Use save_survey_data to save the information
7. Use generate_confirmation to provide a confirmation number
8. Thank them for participating

Be warm, professional, and concise. Keep responses under 150 words."""

ESCALATION_PHRASES = {'agent', 'live agent', 'human', 'representative', 'operator', 'speak to someone', 'talk to someone'}

def wants_agent(text: str) -> bool:
    t = text.lower().strip()
    return any(phrase in t for phrase in ESCALATION_PHRASES)

# Session store (in-memory cache + DynamoDB persistence)
sessions = {}

def load_session(contact_id):
    if contact_id in sessions:
        return sessions[contact_id]
    try:
        item = sessions_table.get_item(Key={'contactId': contact_id}).get('Item')
        if item:
            return json.loads(item['messages'])
    except Exception:
        pass
    return []

def save_session(contact_id, messages):
    sessions[contact_id] = messages
    try:
        sessions_table.put_item(Item={
            'contactId': contact_id,
            'messages': json.dumps(messages),
            'ttl': int(datetime.now().timestamp()) + 3600
        })
    except Exception:
        pass

def lambda_handler(event, context):
    # ── Amazon Connect invocation ──
    if 'Details' in event:
        params = event['Details'].get('Parameters', {})
        attrs = event['Details'].get('ContactData', {}).get('Attributes', {})
        contact_id = event['Details']['ContactData'].get('ContactId', 'connect-session')
        session_id = contact_id
        print(f"DEBUG params={params} attrs_keys={list(attrs.keys())}")

        # Try Parameters first (LambdaInvocationAttributes), then contact Attributes
        input_text = (params.get('inputText') or attrs.get('inputText', '')).strip()

        # If empty, fetch latest customer message from chat transcript
        if not input_text:
            participant_token = attrs.get('participantToken', '')
            if participant_token:
                try:
                    import boto3 as _boto3
                    pc = _boto3.client('connectparticipant', region_name='us-east-1')
                    conn_resp = pc.create_participant_connection(
                        ParticipantToken=participant_token,
                        Type=['CONNECTION_CREDENTIALS']
                    )
                    conn_token = conn_resp['ConnectionCredentials']['ConnectionToken']
                    transcript = pc.get_transcript(
                        ConnectionToken=conn_token,
                        MaxResults=20,
                        ScanDirection='BACKWARD',
                        SortOrder='DESCENDING'
                    )
                    for item in transcript.get('Transcript', []):
                        if item.get('ParticipantRole') == 'CUSTOMER' and item.get('Type') == 'MESSAGE':
                            input_text = item.get('Content', '').strip()
                            print(f"DEBUG transcript input: {input_text}")
                            break
                except Exception as e:
                    print(f"DEBUG transcript fetch failed: {e}")

        if not input_text or input_text == '__greeting__':
            input_text = 'Greet the customer and ask for their phone number to begin the census survey.'

        if wants_agent(input_text):
            raise Exception('ESCALATE_TO_AGENT')

        history = load_session(session_id)
        model = BedrockModel(model_id='us.anthropic.claude-sonnet-4-6', region_name='us-east-1')
        agent = Agent(
            model=model,
            tools=[verify_address, save_survey_data, generate_confirmation],
            system_prompt=SYSTEM_PROMPT,
            messages=history
        )
        result = agent(input_text)
        save_session(session_id, agent.messages)

        return {
            'response': str(result),
            'escalate': 'false',
            'sessionId': session_id,
            'engine': 'strands'
        }

    # ── HTTP / web chat invocation ──
    try:
        body = json.loads(event.get('body', '{}'))
        session_id = body.get('sessionId', 'default')
        input_text = body.get('inputText', '')

        if input_text == '__greeting__':
            input_text = 'Greet the customer and ask for their phone number to begin the census survey.'

        if wants_agent(input_text):
            return {
                'statusCode': 200,
                'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({
                    'response': 'Of course! To connect with a live agent, please call us at 1-833-289-5330 and say "agent" when prompted.',
                    'escalate': True,
                    'sessionId': session_id,
                    'engine': 'strands'
                })
            }

        if session_id not in sessions:
            sessions[session_id] = []

        model = BedrockModel(model_id='us.anthropic.claude-sonnet-4-6', region_name='us-east-1')
        agent = Agent(
            model=model,
            tools=[verify_address, save_survey_data, generate_confirmation],
            system_prompt=SYSTEM_PROMPT,
            messages=sessions[session_id]
        )
        result = agent(input_text)
        sessions[session_id] = agent.messages

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'response': str(result),
                'escalate': False,
                'sessionId': session_id,
                'engine': 'strands'
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }
