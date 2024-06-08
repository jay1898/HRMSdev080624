public without sharing class ReProcessDebugLogOfInboundPQM implements Database.Batchable<sObject>,Schedulable {
     
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(System.Label.ReProcessPQMInboundQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Apex_Debug_Log__c > records){
        try{
            
            for(Apex_Debug_Log__c  ADL :records){
                
                if(ADL.Message__c=='postData: Received Request' &&  ADL.Record_Id__c!=null && ADL.Record_Id__c.length()>14){
                    RestRequest reqst = new RestRequest();
                    RestResponse res = new RestResponse();

                    String JSONString = ADL.Record_Id__c.Substring(13,ADL.Record_Id__c.length());
                    reqst.requestBody = Blob.valueOf(JSONString) ;
                    RestContext.request = reqst;
                    RestContext.response = res;
                    ServicePOSTPQM.postData();
                }
            }
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ReProcessDebugLogOfInboundPQM', 'execute',JSON.serialize(records),ex, 'Internal'));
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        ReProcessDebugLogOfInboundPQM b = new ReProcessDebugLogOfInboundPQM(); 
        database.executebatch(b,1);
    }
}