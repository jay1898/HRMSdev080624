/**
*   @Author:        Kalyan Adham
*   @Date:          06/19/2020
*   @TaskSource:    
*   @Purpose:       Apex Class to read all the PQM Inbound Log files to get the Quote and Opp stages. 

*   @Updates:       
*/
public without sharing class PQMQuoteInboundBACBatch implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    String csvData='Opportunity PQM ID, PQM Status, Opportunity Stage , Quote Number, Book Date, Signed Contract Date, Total BAC Price\n';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(System.Label.ReProcessPQMInboundLogsQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Apex_Debug_Log__c > listApexDebug){
        string finalstr='';
        List<tempTable> testObject = new List<tempTable>();
        List<String> listOpps=new List<Id>();
        set<String> finaljsonList = new set<String>();
        For(Apex_Debug_Log__c reqBody : listApexDebug){
            
            IF(reqBody.Message__c.contains('postData: Received Request')){
                String jsonList = reqBody.Record_Id__c;
                finaljsonList.add(jsonList.substring(jsonList.indexOf('['),jsonList.length()));
            }
        }
        For(String reqBody : finaljsonList){
            
            List<PQMQuoteWrapper.Request> reqList = (List<PQMQuoteWrapper.Request>)JSON.deserialize(reqBody,List<PQMQuoteWrapper.Request>.class);
            for(PQMQuoteWrapper.Request req : reqList){
                if(req.opportunity!=null && req.opportunity!='' && !req.opportunity.isNumeric() ){
                    
                    tempTable ADLog=new tempTable();
                    ADLog.oppID = req.opportunity;       
                    ADLog.pqmStatus = req.status;
                    ADLog.quotenumber = req.quotenumber;
                    ADLog.bookdate = req.bookdate;
                    ADLog.quotedate = req.quotedate;
                    ADLog.signedContractdate = req.signedContractdate;
                    ADLog.totalBACprice = req.totalBACprice;
                    listOpps.add(req.opportunity);
                    testObject.add(ADLog);
                } 
                
            } 
        }
        Map<Id, String> Opplist = new Map<Id, String>();
        for(Opportunity Opp :[select Id, StageName from Opportunity where Id in :listOpps]) 
        {
            Opplist.put(Opp.Id, Opp.stagename);   
        }
        
        for(tempTable TT: testObject){
            If(Opplist.containsKey(TT.oppID)) {
                TT.oppStatus = Opplist.get(TT.oppID); 
            }
        }
        for(tempTable TT: testObject){
            
            finalstr += TT.oppID+','+TT.pqmStatus+','+TT.oppStatus+','+TT.quotenumber+','+TT.bookdate+','+TT.signedContractdate+','+TT.totalBACprice+'\n';   
        }
        csvData+=finalstr;
        List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'ServiceTerritory_To_EBS' ]; 
        
        //system.debug('@@csvData :: '+csvData);
        String fileName='PQMQuote.csv';
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        
        attachment.setFileName(fileName);
        attachment.setBody(blob.valueOf(csvData));
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        message.setSubject('PQM Files');
        message.setPlainTextBody('The report is attached.');
        message.setToAddresses( new String[] { 'adhamk@pella.com' } );
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        
        // HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(csvData,fileName);   
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        PQMQuoteInboundBACBatch b = new PQMQuoteInboundBACBatch(); 
        database.executebatch(b,1);
    }
    
    
    class tempTable{
        public String oppID;
        public String quotenumber;
        public String pqmStatus;
        public String oppStatus;
        public String bookdate;
        public String quotedate;
        public String signedContractdate;
        public String totalBACprice;
    }
    
}