const { DynamoDBClient, PutItemCommand, GetItemCommand, QueryCommand } = require('@aws-sdk/client-dynamodb');
const { marshall, unmarshall } = require('@aws-sdk/util-dynamodb');

const dynamodb = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const CENSUS_TABLE = process.env.CENSUS_TABLE_NAME || 'CensusResponses';
const ADDRESS_TABLE = process.env.ADDRESS_TABLE_NAME || 'CensusAddresses';

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event));
    
    const action = event.Details?.Parameters?.action || event.action;
    const phoneNumber = event.Details?.Parameters?.phoneNumber || 
                       event.Details?.ContactData?.CustomerEndpoint?.Address ||
                       event.phoneNumber;
    
    try {
        switch (action) {
            case 'lookupAddress':
                return await lookupAddress(phoneNumber);
            case 'saveSurvey':
                return await saveSurvey(event);
            default:
                return { statusCode: 200, message: 'Action processed', action };
        }
    } catch (error) {
        console.error('Error:', error);
        return { statusCode: 500, error: error.message };
    }
};

async function lookupAddress(phoneNumber) {
    const normalized = phoneNumber?.replace(/[\s\-\+]/g, '').replace(/^1/, '');
    
    try {
        const result = await dynamodb.send(new QueryCommand({
            TableName: ADDRESS_TABLE,
            IndexName: 'PhoneNumberIndex',
            KeyConditionExpression: 'phoneNumber = :phone',
            ExpressionAttributeValues: marshall({ ':phone': normalized })
        }));
        
        if (result.Items && result.Items.length > 0) {
            const address = unmarshall(result.Items[0]);
            return {
                statusCode: 200,
                found: true,
                streetAddress: address.streetAddress,
                city: address.city,
                state: address.state,
                zipCode: address.zipCode
            };
        }
        
        return {
            statusCode: 200,
            found: false,
            message: 'Address not found'
        };
    } catch (error) {
        console.error('Lookup error:', error);
        return { statusCode: 500, error: error.message };
    }
}

async function saveSurvey(event) {
    const caseId = `case-${Date.now()}`;
    const timestamp = new Date().toISOString();
    const householdCount = event.Details?.Parameters?.householdCount || event.householdCount || '0';
    
    try {
        await dynamodb.send(new PutItemCommand({
            TableName: CENSUS_TABLE,
            Item: marshall({
                caseId,
                timestamp,
                householdCount,
                phoneNumber: event.Details?.ContactData?.CustomerEndpoint?.Address || 'unknown',
                status: 'completed'
            })
        }));
        
        return {
            statusCode: 200,
            message: 'Survey saved',
            caseId,
            confirmationNumber: caseId.substring(5, 13)
        };
    } catch (error) {
        console.error('Save error:', error);
        return { statusCode: 500, error: error.message };
    }
}
