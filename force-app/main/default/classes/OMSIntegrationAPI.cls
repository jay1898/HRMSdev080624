/*
Created By: Sachin Padhiyar
Created Date: 10/01/2020 
Purpose: OMS Integration to process the JSON and insert the records on Quote.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


@RestResource(urlMapping='/OMSQuoteIntegrationInfo/*')
global  class OMSIntegrationAPI {   
    @HttpPatch
    global static void dopatch() {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_OMS_Integration__c) ) return;
        else{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            // parse the JSON
            try {
                Apex_Debug_Log__c errorLog = new Apex_Debug_Log__c();
                errorLog.Apex_Class__c='OMSIntegrationAPI';
                errorLog.Method__c= 'dopatch'; 
                errorLog.Type__c= 'Information';
                Insert errorLog;
                
                //Insert the file in to the Attachment object
                Apex_Debug_Log__c adlErrObj = [select id from Apex_Debug_Log__c where id=:errorLog.id];
                Attachment attError=new Attachment(Name='OMS Integration');
                attError.Body=Blob.valueOf(RestContext.request.requestBody.toString());
                attError.ParentId=adlErrObj.id;
                insert attError;
                List<Object> results = (List<Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString().trim());
                set<Quote> lstQuoteData =new set<Quote>();
                List<string> lstwoPoNoQuoteData =new List<string>();
                List<string> lstsuccPoNoQuoteData =new List<string>();
                set<string> poNoSet = new set<string>();
                //Iterating the list of get each elemnt of the JSON
                for(Object objQuoteData :results){
                    Map<String, Object> resultsMap = (Map<String, Object>)objQuoteData;
                    string PoNumber = string.valueOf(resultsMap.get('PoNumber'));
                    Quote objQuote = new Quote();
                    if(PoNumber.length()>=4){
                        poNoSet.add(PoNumber);
                        
                    }
                }
                List<Quote> lstQuoteRecords = [select id,PO_Number__c,Initial_Requested_Date__c,Initial_Estimated_Ship_Date__c,
                                               Initial_Ship_Date__c,Ship_Complete_Date__c,Initial_Scheduled_Delivery_Date__c,
                                               Final_Scheduled_Delivery_Date__c,Initial_Install_Date__c,Final_Install_Date__c,OpportunityId
                                               FROM Quote
                                               where PO_Number__c IN:poNoSet
                                              ];
                Map<String, Quote> quoteRecordsMap = new Map<String, Quote>();
                for(Quote objQuoteRecors :lstQuoteRecords){
                    quoteRecordsMap.put(objQuoteRecors.PO_Number__c,objQuoteRecors);
                }
                List<String> listOppIdToUpdate=new List<String>();
                Set<Id> setOfQuoteId = new Set<Id>();
                for(Object objQuoteUpdatedData :results){
                    Map<String, Object> resultsUpdatedMap = (Map<String, Object>)objQuoteUpdatedData;
                    Map<String, Object> resultsMapBranch = (Map<String, Object>)resultsUpdatedMap.get('PellaToBranch');
                    Map<String, Object> resultsMapCust = (Map<String, Object>)resultsUpdatedMap.get('BranchToCust');
                    string PoNumberUpdated = string.valueOf(resultsUpdatedMap.get('PoNumber'));
                    Quote objUpdatedQuote = new Quote();
                    if(quoteRecordsMap.containskey(PoNumberUpdated)){
                        if(!setOfQuoteId.contains(quoteRecordsMap.get(PoNumberUpdated).Id)){
                            if(String.isNotBlank(PoNumberUpdated)){
                                objUpdatedQuote.PO_Number__c=PoNumberUpdated;
                            }
                            //String variables to handls the Date fields
                            string initialDate = string.valueOf(resultsMapBranch.get('InitialRequestedDate'));
                            string initialEst = string.valueOf(resultsMapBranch.get('InitialEstimatedShip'));
                            string initialShip = string.valueOf(resultsMapBranch.get('InitialShipDate'));
                            string shipComp = string.valueOf(resultsMapBranch.get('ShipCompleteDate'));
                            string initialScDeli = string.valueOf(resultsMapCust.get('InitialScheduledDeliveryDate'));
                            string initialScDe = string.valueOf(resultsMapCust.get('FinalScheduledDeliveryDate'));
                            string finalSc= string.valueOf(resultsMapCust.get('InitialInstallDate'));
                            string intialIns= string.valueOf(resultsMapCust.get('FinalInstallDate'));
                            objUpdatedQuote.Initial_Requested_Date__c=string.isNotBlank(initialDate)?date.parse(initialDate):NULL;
                            objUpdatedQuote.Initial_Estimated_Ship_Date__c=string.isNotBlank(initialEst)?date.parse(initialEst):NULL;
                            objUpdatedQuote.Initial_Ship_Date__c=string.isNotBlank(initialShip)?date.parse(initialShip):NULL;
                            objUpdatedQuote.Ship_Complete_Date__c=string.isNotBlank(shipComp)?date.parse(shipComp):NULL;
                            objUpdatedQuote.Initial_Scheduled_Delivery_Date__c=string.isNotBlank(initialScDeli)?date.parse(initialScDeli):NULL;
                            objUpdatedQuote.Final_Scheduled_Delivery_Date__c=string.isNotBlank(initialScDe)?date.parse(initialScDe):NULL;
                            objUpdatedQuote.Initial_Install_Date__c=string.isNotBlank(finalSc)?date.parse(finalSc):NULL;
                            objUpdatedQuote.Final_Install_Date__c=string.isNotBlank(intialIns)?date.parse(intialIns):NULL;
                            objUpdatedQuote.Id=quoteRecordsMap.get(PoNumberUpdated).Id;
                            
                            if(objUpdatedQuote.Ship_Complete_Date__c!=null){
                                listOppIdToUpdate.add(quoteRecordsMap.get(PoNumberUpdated).OpportunityId);
                            }
                            lstQuoteData.add(objUpdatedQuote);
                            lstsuccPoNoQuoteData.add(PoNumberUpdated); 
                            setOfQuoteId.add(objUpdatedQuote.Id);
                        }
                    }
                    else{
                        lstwoPoNoQuoteData.add(PoNumberUpdated);
                    }
                }
                
                List<jSonResp> lstfinalResp = new List<jSonResp>();
                List<jSonResp> lstfinalSuccessResp = new List<jSonResp>();
                
                List<Quote> lstQuoteDataList =new List<Quote>(lstQuoteData);
                
                if(lstQuoteDataList.size()>0){
                    
                    Boolean quoteTrigger=QuoteTriggerHandler.isRecursive;   
                    QuoteTriggerHandler.isRecursive=true;
                    Database.SaveResult [] updateResult = Database.update(lstQuoteDataList, false); 
                    QuoteTriggerHandler.isRecursive=quoteTrigger; 
                    Integer count=0;
                    
                    // Added on 10-11 Update Opportunity Stage based on Shipment completed date
                    List<Opportunity> listOpp=new List<Opportunity>();
                    Set<Id> successfulyUpdatedQuoteIdSet = new Set<Id>();
                    if(listOppIdToUpdate.size()>0){
                        // possible fix for CPU timeout
                        listOpp=[SELECT Id,StageName,(SELECT Id,Forecasted__c,Ship_Complete_Date__c FROM Quotes order by lastmodifieddate desc) 
                                 FROM Opportunity Where id in :listOppIdToUpdate and recordType.Developername='Trade_Comm'];
                    }
                    List<Opportunity> listOpptoUpdate=new List<Opportunity>();
                    //Iterating the ressults to fetch the records which are un processed
                    for (Database.SaveResult sr : updateResult) {
                        if (sr.isSuccess()) {                            
                            // Operation was successful
                            // Added on 10-11  Update Opportunity Stage based on Shipment completed date
                            
                            successfulyUpdatedQuoteIdSet.add(sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors 
                            jSonResp finalResp = new jSonResp(); 
                            string error=''; 
                            string status='';              
                            for(Database.Error err : sr.getErrors()) {
                                error=error+err.getMessage()+ ',\n';
                                status=status+err.getStatusCode()+ ',\n';
                                
                            }
                            finalResp.code = status;
                            finalResp.msgeText = error;
                            finalResp.poNumber= lstQuoteDataList[count].PO_Number__c;
                            lstfinalResp.add(finalResp);
                        }
                        count++; 
                    } 
                    
                    // Update Opportunity Stage based on Shipment completed date
                    Set<Id> successfulQuoteOppIdSet = new Set<Id>();
                    for(Quote qte : [SELECT Id,OpportunityId FROM Quote WHERE Id IN : successfulyUpdatedQuoteIdSet]){
                        successfulQuoteOppIdSet.add(qte.OpportunityId);
                    }
                    
                    //Boolean isOppUpdate=false;
                    for(Opportunity Opp : listOpp){
                        // check if the opp is in the list of successful updated quote's parent opps
                        if(successfulQuoteOppIdSet.contains(opp.Id)){
                            Integer totalShipped=0,AllQuote=0;
                            for(Quote Q: Opp.Quotes){
                                if(Q.Forecasted__c){
                                    if(Q.Ship_Complete_Date__c!=null){
                                        totalShipped++;
                                    }
                                    AllQuote++;
                                }
                            }
                            // Check all linked quoted ship completed
                            if(AllQuote!=0 && AllQuote==totalShipped){
                                if(opp.StageName!='Closed Won'){
                                    opp.StageName='Closed Won';
                                    listOpptoUpdate.add(Opp);
                                }
                            } 
                        }
                        
                    }                   
                    if(listOpptoUpdate.size()>0){
                        Boolean OppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
                        OpportunityTriggerHandler.RUN_TRIGGER=false;
                        update listOpptoUpdate; 
                        OpportunityTriggerHandler.RUN_TRIGGER=OppTrigger;
                    }
                } 
                for(string errorString : lstwoPoNoQuoteData){
                    jSonResp finalRespUpdated = new jSonResp(); 
                    finalRespUpdated.code = 'Failed';
                    finalRespUpdated.msgeText = 'Po Number not found';
                    finalRespUpdated.poNumber= errorString;
                    lstfinalResp.add(finalRespUpdated);
                }
                for(string successString : lstsuccPoNoQuoteData){
                    jSonResp finalRespSuccUpdated = new jSonResp(); 
                    finalRespSuccUpdated.code = 'Success';
                    finalRespSuccUpdated.msgeText = 'Updated';
                    finalRespSuccUpdated.poNumber= successString;
                    lstfinalSuccessResp.add(finalRespSuccUpdated);
                }
                // Sending the response on successfull process of records
                if(lstfinalResp.size()>0){
                    string successRes='';
                    if(lstfinalSuccessResp.size()>0)
                        lstfinalResp.addAll(lstfinalSuccessResp);
                    successRes+=+JSON.serializePretty(lstfinalResp);
                    res.responseBody = Blob.valueOf(successRes );
                    //Handling exceptions and inserting them into ADL object
                    Apex_Debug_Log__c errorLogEx = new Apex_Debug_Log__c();
                    errorLogEx.Apex_Class__c='OMSIntegrationAPI';
                    errorLogEx.Message__c=  'The status code : 200 Ok';
                    errorLogEx.Method__c= 'dopatch';
                    errorLogEx.Type__c= 'Information';
                    //errorLogEx.Record_Id__c=JSON.serializePretty(lstfinalResp);
                    insert errorLogEx;
                    //Insert the file in to the Attachment object
                    Apex_Debug_Log__c adlOnj = [select id from Apex_Debug_Log__c where id=:errorLogEx.id];
                    Attachment att=new Attachment(Name='OMS Integration Response');
                    att.Body=Blob.valueOf(JSON.serializePretty(lstfinalResp));
                    att.ParentId=adlOnj.id;
                    insert att; 
                    //Handling exceptions and inserting them into ADL object
                    Apex_Debug_Log__c errorLogExRes = new Apex_Debug_Log__c();
                    errorLogExRes.Apex_Class__c='OMSIntegrationAPI';
                    errorLogExRes.Message__c=  'The status code : 200 Ok';
                    errorLogExRes.Method__c= 'dopatch';
                    errorLogExRes.Type__c= 'Information';
                    insert errorLogExRes;
                    Apex_Debug_Log__c adlOnjError = [select id from Apex_Debug_Log__c where id=:errorLogExRes.id];
                    //Insert the file in to the Attachment object
                    Attachment attObj=new Attachment(Name='OMS Integration Request');
                    attObj.Body=Blob.valueOf(RestContext.request.requestBody.toString());
                    attObj.ParentId=adlOnjError.id;
                    insert attObj; 
                }
                else{
                    res.responseBody = Blob.valueOf(JSON.serializePretty(lstfinalSuccessResp));
                    //Handling exceptions and inserting them into ADL object
                    Apex_Debug_Log__c errorLogSucc = new Apex_Debug_Log__c();
                    errorLogSucc.Apex_Class__c='OMSIntegrationAPI';
                    errorLogSucc.Message__c=  'The status code : 200 Ok';
                    errorLogSucc.Method__c= 'dopatch';
                    errorLogSucc.Type__c= 'Information';
                    insert errorLogSucc;
                    //Insert the file in to the Attachment object
                    Apex_Debug_Log__c adlObj = [select id from Apex_Debug_Log__c where id=:errorLogSucc.id];
                    Attachment attSucc=new Attachment(Name='OMS Integration');
                    attSucc.Body=Blob.valueOf(RestContext.request.requestBody.toString());
                    attSucc.ParentId=adlObj.id;
                    insert attSucc; 
                    //Handling exceptions and inserting them into ADL object
                    Apex_Debug_Log__c errorLogSuccRes = new Apex_Debug_Log__c();
                    errorLogSuccRes.Apex_Class__c='OMSIntegrationAPI';
                    errorLogSuccRes.Message__c=  'The status code : 200 Ok';
                    errorLogSuccRes.Method__c= 'dopatch';
                    errorLogSuccRes.Type__c= 'Information';
                    // errorLogSuccRes.Record_Id__c=JSON.serializePretty(lstfinalSuccessResp);
                    insert errorLogSuccRes;
                    Attachment attLogSucc=new Attachment(Name='OMS Integration');
                    attLogSucc.Body=Blob.valueOf(JSON.serializePretty(lstfinalSuccessResp));
                    attLogSucc.ParentId=adlObj.id;
                    insert attLogSucc; 
                }
                if(lstQuoteDataList.size()>0){
                    res.statusCode = 200;
                }
                else{res.statusCode = 200;}
                
            } catch (Exception e) {
                
                //Handling exceptions and inserting them into ADL object
                Apex_Debug_Log__c errorLog = new Apex_Debug_Log__c();
                errorLog.Apex_Class__c='OMSIntegrationAPI';
                errorLog.Message__c=  e.getMessage();
                errorLog.Method__c= 'dopatch'; 
                errorLog.Type__c= 'Information';
                errorLog.Stack_Trace__c= e.getStackTraceString() + ' CAUSE: ' + e.getCause() + ' LINE: ' + e.getLineNumber();
                Insert errorLog;
                
                //Insert the file in to the Attachment object
                Apex_Debug_Log__c adlErrObj = [select id from Apex_Debug_Log__c where id=:errorLog.id];
                Attachment attError=new Attachment(Name='OMS Integration');
                attError.Body=Blob.valueOf(RestContext.request.requestBody.toString());
                attError.ParentId=adlErrObj.id;
                insert attError; 
                
                // Sending the response on failure of records
                res.responseBody = Blob.valueOf(e.getMessage());
                res.statusCode = 400;
            }
            
        }  
    } 
    //Declaration of wrapper class
    public class jSonResp{
        public string code;
        public string msgeText;
        public string poNumber;
    }
}