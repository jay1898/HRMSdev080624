@RestResource(urlMapping = '/TwilioSmsWebhook/*')
// maps to https://pellacorp--piesdev.my.salesforce.com/services/apexrest/TwilioSmsWebhook/
global class TwilioWebhook {
	@HttpPost
	global static void handlePost() {
        RestContext.response.addHeader('Content-Type', 'application/json');

        Map<String, Object> reqParams = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());

        String fromNumber = (String) reqParams.get('From');
        String toNumber = (String) reqParams.get('To');
        String message = (String) reqParams.get('Body');
        
           system.debug('@@Info'+RestContext.request.requestBody.toString());
        system.debug('@@Info'+JSON.serialize(RestContext.request.params));

        if (fromNumber == null || message == null || toNumber == null) {
            RestContext.response.statusCode = TwilioHttpStatus.BAD_REQUEST;
            RestContext.response.responseBody = Blob.valueOf('{"msg": "missing required parameter"}');
            return;
        }

        try {
            RestContext.response.statusCode = TwilioHttpStatus.OK;
            RestContext.response.responseBody = Blob.valueOf('{"msg" : "saved message"}');
            
            TwilioMessenger.CreateMessageParams createParams = new TwilioMessenger.CreateMessageParams();
            createParams.direction = 'Inbound';
            createParams.msgBody = message;
            createParams.phone = fromNumber;
            createParams.status = 'Success';
            
            String topic = TwilioMessenger.getTopicFromSender(toNumber);
            TwilioMessage__c lastMessage = TwilioMessenger.getLastOutboundMessage(fromNumber, topic);            
            
            createParams.branchId = lastMessage.Branch__c;
            createParams.recordId = lastMessage.ParentID__c;
            createParams.topic = topic;
            TwilioMessenger.createMessage(createParams);
        } 
        catch (Exception error) {
            RestContext.response.statusCode = TwilioHttpStatus.INTERNAL_SERVER_ERROR;
            RestContext.response.responseBody = Blob.valueOf('{"error" : "internal server error", "msg": "' + error.getMessage() + '}"');
            
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
        }
	}
}