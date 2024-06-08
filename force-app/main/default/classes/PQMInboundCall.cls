/*
Created By: Sachin Padhiyar
Created Date: 04/11/2020
Purpose: Calling the Service POSTPQM class to Create Quote and Quote Line Items Which got failed and captured in Apex Log.
----------------------------------------------------------------------------------------------
Modified By: 
Modified Date: 
Purpose: 
------------------------------------------------------------------------------------------------
*/

public with sharing class PQMInboundCall{
    
    @AuraEnabled
    public static string docallout(String LogId) {
        try{
            Apex_Debug_Log__c  ADL=[Select id,Record_Id__c,Message__c From Apex_Debug_Log__c Where id=: LogId];
            if(ADL.Record_Id__c!=null && ADL.Record_Id__c.length()>14){
                RestRequest reqst = new RestRequest();
                RestResponse res = new RestResponse();
                
                String JSONString = ADL.Record_Id__c.Substring(13,ADL.Record_Id__c.length());
                reqst.requestBody = Blob.valueOf(JSONString) ;
                RestContext.request = reqst;
                RestContext.response = res;
                PQMQuoteWrapper.Response res1 = ServicePOSTPQM.postData();
                system.debug('--------'+ res1);
            }
            return 'Success';
        }
        catch(Exception ex){
            system.debug('----'+ ex.getmessage());
            return ex.getmessage();
        }
    }    
}