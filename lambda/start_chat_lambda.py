import json
import boto3
import uuid

connect = boto3.client('connect', region_name='us-east-1')

INSTANCE_ID = '1d3555df-0f7a-4c78-9177-d42253597de2'
CONTACT_FLOW_ID = '4a2354b7-b179-400d-b175-82051ff9059d'

HEADERS = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
}

def lambda_handler(event, context):
    if event.get('requestContext', {}).get('http', {}).get('method') == 'OPTIONS':
        return {'statusCode': 200, 'headers': HEADERS, 'body': ''}

    try:
        body = json.loads(event.get('body', '{}'))
        display_name = body.get('displayName', 'Census Visitor')

        response = connect.start_chat_contact(
            InstanceId=INSTANCE_ID,
            ContactFlowId=CONTACT_FLOW_ID,
            ParticipantDetails={'DisplayName': display_name},
            ClientToken=str(uuid.uuid4()),
            ChatDurationInMinutes=60,
            SupportedMessagingContentTypes=['text/plain']
        )

        participant_token = response['ParticipantToken']

        # Store participant token as contact attribute so Lambda can fetch transcript
        connect.update_contact_attributes(
            InstanceId=INSTANCE_ID,
            InitialContactId=response['ContactId'],
            Attributes={'participantToken': participant_token}
        )

        return {
            'statusCode': 200,
            'headers': HEADERS,
            'body': json.dumps({
                'contactId': response['ContactId'],
                'participantId': response['ParticipantId'],
                'participantToken': participant_token
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': HEADERS,
            'body': json.dumps({'error': str(e)})
        }
