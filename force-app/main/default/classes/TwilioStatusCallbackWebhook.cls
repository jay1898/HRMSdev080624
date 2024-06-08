@RestResource(urlMapping = '/TwilioStatusCallbackWebhook/*')
// maps to https://pellacorp--pellaqa.sandbox.my.salesforce-sites.com/SMS/TwilioStatusCallbackWebhook/
global without sharing class TwilioStatusCallbackWebhook {
    @HttpPost
    global static void handlePost() {
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        system.debug('@@Info'+RestContext.request.requestBody.toString());
        system.debug('@@Info'+JSON.serialize(RestContext.request.params));
        Map <String, String> params=RestContext.request.params;
       
        if(params.containsKey('SmsSid')){
            List<TwilioMessage__c> TMList=[SELECT ID,Callback_Error_Code__c,Callback_Status__c FROM TwilioMessage__c Where MessageSid__c=:params.get('SmsSid') limit 1];
            if(TMList.size()>0){
                for(TwilioMessage__c TM : TMList){
                    TM.Callback_Error_Code__c=params.get('ErrorCode');
                    TM.Callback_Status__c=params.get('SmsStatus');
                }
                update TMList;
            }
            
            
        }
    }
    
}