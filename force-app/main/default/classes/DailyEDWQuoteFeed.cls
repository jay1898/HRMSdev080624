/*
Created By: Sachin Padhiyar
Created Date: 10/08/2020 
Purpose: DailyEDWQuoteFeed to fetch all the data of Quote POST all the records to external URL.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


public class DailyEDWQuoteFeed implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    public dateTime validFromDate;
    public List<Quote> lstQuote = new List<Quote>() ;
    public List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
    public String generatedCSVFile ='';
    public dateTime currentDate= system.Now();
    public string squery;
    public string header='';
    public string finalstr;
    public String fileRow = '';
    public string adlId;
    String newAdlId;
    String contentDocumentId;
    Boolean isError = false;
    Integer cnt = 0;
    public list<String> fieldSet = new list<String>();
    public set<Id> OppIds = new set<Id>();
    public Map<String,EDW_Object_Mapping__mdt> edwmap;
    public Exception[] errors = new Exception[0];
    public List<Endpoint_Configuration__mdt> edwMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EDW_Integration'];
    public Boolean testClassException;
    public class OppException extends Exception {} 
    //Constructor to defined the value and use within the batch publicly
    public DailyEDWQuoteFeed(dateTime validFrom,dateTime validTo,string TxnId,set<Id> OppIds) {
        testClassException=testClassException;
        adlId=TxnId;
        this.OppIds=OppIds;
        this.validToDate=validTo;
        this.validFromDate=validFrom;
        /*edwmap= new Map<String,EDW_Object_Mapping__mdt>([select Field_Api_Name__c,Source_Object__c,MasterLabel,Csv_Column_Sequence__c from EDW_Object_Mapping__mdt where Source_Object__c='Quote' ORDER BY Csv_Column_Sequence__c ASC]);
        for(EDW_Object_Mapping__mdt fields :edwmap.values()){
            fieldSet.add(fields.Field_Api_Name__c);
            header+=(string.isNotBlank(header))?'|'+fields.MasterLabel : fields.MasterLabel; 
        }*/
        Header= 'OpportunityId|PQM_Quote_ID__c|Id|Forecasted__c|Estimated_Book_Date__c';
        //squery='SELECT '+string.join(fieldSet,',')+' FROM Quote WHERE OpportunityId IN :OppIds';
        squery='SELECT OpportunityId,PQM_Quote_ID__c,Id,Forecasted__c,Estimated_Book_Date__c FROM Quote WHERE OpportunityId IN :OppIds';
    }
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(squery);
        
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<Quote> scope) {
        try{ 
            /*if(string.isBlank(finalstr)){
finalstr = header ;
}*/
            List<ContentVersion> lstContentVersion = new List<ContentVersion>();
            if(string.isBlank(newAdlId)){
                finalstr = header;
            }else{
                lstContentVersion = [SELECT Title,VersionData,ContentDocumentId,ContentSize FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true];
                if(lstContentVersion != null && !lstContentVersion.isEmpty()){
                    if(lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size))
                        finalstr = header;
                    else
                        finalstr = '';
                }
                
            }
            fileRow = '';
            for(Quote objQuote : scope){
                fileRow='';
                cnt++;
                fileRow = fileRow+'"'+ (objQuote.OpportunityId!=null?objQuote.OpportunityId:'')+ '"';
                fileRow = fileRow +'|"'+(objQuote.PQM_Quote_ID__c!=null?objQuote.PQM_Quote_ID__c:'')+ '"';
                fileRow = fileRow +'|"'+(objQuote.Id!=null?objQuote.Id:'')+ '"';
                fileRow = fileRow +'|"'+(objQuote.Forecasted__c!=null?String.valueOf(objQuote.Forecasted__c):'')+ '"';
                fileRow = fileRow +'|"'+(objQuote.Estimated_Book_Date__c!=null?String.valueOf(objQuote.Estimated_Book_Date__c)+' 00:00:00':'')+ '"';
                // fileRow = fileRow +'|"'+(objQuote.Estimated_Book_Date__c!=null?String.valueOf(objQuote.Estimated_Book_Date__c):'')+ '"';
                
                
                
                /*for(EDW_Object_Mapping__mdt fields :edwmap.values()){
                    if(fields.Field_Api_Name__c.indexOf('.') > -1){
                        if(string.isNotBlank(fileRow)){
                            if((objQuote.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])!=null)){
                                fileRow = fileRow +'|"'+string.valueOf(objQuote.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])).replace('"','')+'"';
                            }
                            else{
                                fileRow=fileRow+'|""';
                            }
                        }
                        else{
                            if(string.valueOf(objQuote.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))!=null){
                                fileRow = '"'+string.valueOf(objQuote.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])).replace('"','')+'"';
                            }
                            else{
                                fileRow='""';
                            }
                        }
                    }
                    else{
                        if(string.isNotBlank(fileRow)){
                            if(objQuote.get(fields.Field_Api_Name__c)!=null){
                                fileRow = fileRow +'|"'+string.valueOf(objQuote.get(fields.Field_Api_Name__c)).replace('"','')+'"';
                            }
                            else{
                                fileRow = fileRow +'|""';
                            }
                        }
                        else{
                            if(string.valueOf(objQuote.get(fields.Field_Api_Name__c))!=null){
                                fileRow = '"'+string.valueOf(objQuote.get(fields.Field_Api_Name__c)).replace('"','')+'"';
                            }
                            else{
                                fileRow= '""';
                            }
                        }
                    }
                } */
                if(String.isNotBlank(fileRow))
                    finalstr+= '\n'+fileRow;
                fileRow='';
            }
            if(String.isBlank(newAdlId)){
                Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
                objApex.Quote__c = true;
                objApex.Apex_Class__c='DailyEDWQuoteFeed';
                objApex.Method__c='GET';
                objApex.Type__c='Information';
                objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
                if(String.isBlank(finalstr))
                    objApex.Message__c = 'No Record Found on Quote';
                insert objApex;
                newAdlId = objApex.Id;
                objApex.EDW_Transaction_ID__c=adlId;
                update objApex;
                
                String csvname= 'Quote-'+ objApex.Id +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
                //Insert the csv file in File object
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = Blob.valueOf(finalstr);
                ContVerFile.Title = csvname; 
                ContVerFile.ContentLocation= 's';
                ContVerFile.PathOnClient= csvname;
                insert ContVerFile;
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = objApex.Id;
                cDe.ShareType = 'I';
                cDe.Visibility = 'AllUsers';
                insert cDe;
                contentDocumentId = conDoc;
            }else{
                //List<ContentVersion> lstContentVersion = [SELECT Title,VersionData,ContentDocumentId,ContentSize FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true];
                
                if(lstContentVersion != null && lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size)){
                    //Insert the csv file in File object
                    String csvname= 'Quote-'+ newAdlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
                    ContentVersion ContVerFile = new ContentVersion();
                    ContVerFile.VersionData = Blob.valueOf(finalstr);
                    ContVerFile.Title = csvname; 
                    ContVerFile.ContentLocation= 's';
                    ContVerFile.PathOnClient= csvname;
                    insert ContVerFile;
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
                    ContentDocumentLink cDe = new ContentDocumentLink();
                    cDe.ContentDocumentId = conDoc;
                    cDe.LinkedEntityId = newAdlId;
                    cDe.ShareType = 'I';
                    cDe.Visibility = 'AllUsers';
                    insert cDe;
                    contentDocumentId = conDoc;
                }else{
                    ContentVersion ContVerFile = new ContentVersion();
                    Blob data = lstContentVersion[0].VersionData;
                    String versionData = data.toString() + '\n' + finalstr;
                    ContVerFile.VersionData = Blob.valueOf(versionData);
                    ContVerFile.Title = lstContentVersion[0].Title; 
                    ContVerFile.ContentLocation= 's';
                    ContVerFile.PathOnClient= lstContentVersion[0].Title;
                    ContVerFile.ContentDocumentId = contentDocumentId;
                    insert ContVerFile;
                } 
            }
            lstContentVersion.clear();
            fileRow='';
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Quote Test exception');
            }
        }catch(Exception e) {
            errors.add(e);
            string allExeError = string.join(errors,',');
            List<String> quoteIds=new List<String>();
            for(Quote objQuote : scope){
                quoteIds.add(objQuote.Id);
            }
            isError = true;
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Quote__c=true;
            objApexExe.Apex_Class__c='DailyEDWQuoteFeed';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            objApexExe.Message__c = e.getMessage()+ ' '+string.join(quoteIds,',');
            objApexExe.EDW_Transaction_ID__c=adlId;
            insert objApexExe;
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        
        
        // Code to do the POST Request
        
        String cummulativeResponse = 'Records Processed: ' + String.ValueOf(cnt);
        Integer itr = 0;
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        try{
            if(String.isNotBlank(newAdlId)){
                objApex = [SELECT Id FROM Apex_Debug_Log__c WHERE Id =: newAdlId LIMIT 1];
                // UserBatchprocess objExecuteProcess = new UserBatchprocess(validFromDate,validToDate,objApex.Id);
                //Database.executeBatch( objExecuteProcess, 1000);
                List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :newAdlId];
                Set<Id> ContentDocumentIdSet = new Set<Id>();
                for(ContentDocumentLink temp : cdlList){
                    ContentDocumentIdSet.add(temp.ContentDocumentId);
                }
                if (!ContentDocumentIdSet.isEmpty()) {
                    for (ContentVersion conVer : [SELECT Title,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :ContentDocumentIdSet AND IsLatest = TRUE] ) {
                        system.debug('Data there is' + conVer.Title);
                        itr++;
                        String responseBody;
                        String Filename= 'Quote-'+ adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+String.Valueof(itr)+'.csv';
                        string token=edwMetaData[0].Token__c;
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        String endPoint = edwMetaData[0].Endpoint__c;
                        endPoint = endPoint.replace('Completed','Success');
                        if(isError)
                            endPoint = endPoint.replace('Success','Failure');
                        request.setEndpoint(endPoint);
                        request.setMethod('POST');
                        request.setBodyAsBlob(ServiceTerritoryExportBatchHandler.buildNew(EncodingUtil.base64Encode(conVer.VersionData), Filename));
                        request.setHeader('Authorization', 'Bearer '+token);
                        request.setHeader('Content-Type', 'multipart/form-data; boundary='+ServiceTerritoryExportBatchHandler.getBoundary());
                        request.setTimeout(120000);
                        HttpResponse response;
                        if(!test.isRunningTest()){
                            response = http.send(request);
                        }
                        else{
                            response = MapLocationCalloutMock.respond(request);
                        }
                        system.debug('response is :: ' + response);
                        if(response.getStatus() == 'SUCCESS' || response.getStatusCode() ==200 || response.getStatusCode() ==201 )
                            responseBody = response.getBody();
                        else{
                            responseBody = response.getBody();
                            isError = true;
                        }
                        if(String.isNotBlank(responseBody))
                            cummulativeResponse = cummulativeResponse+responseBody;
                    }
                }
                objApex.Message__c = cummulativeResponse;
                If (isError)
                    objApex.type__c = 'Error';
                Else
                	objApex.type__c = 'Complete';
                
                update objApex;                
               // objApex.type__c = 'Complete';
               // update objApex;
            }//end of newAdlId not null
            
            // check all the batch job finish successfully or not
            List<AsyncApexJob> listAsyncApex=[SELECT ApexClass.Name,JobType, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate,ExtendedStatus, Id FROM AsyncApexJob Where jobtype='BatchApex' and apexclass.name='DailyEDWQuoteFeed' order by createddate desc limit 1];
            system.debug('@@'+JSON.serialize(listAsyncApex));
            if(listAsyncApex.size()>0){
                if(listAsyncApex[0].NumberOfErrors>0 || listAsyncApex[0].ExtendedStatus!=null  || test.isRunningTest()){
                    Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
                    objApexExe.Opportunity__c=true;
                    objApexExe.Apex_Class__c='DailyEDWQuoteFeed';
                    objApexExe.Method__c='GET';
                    objApexExe.Type__c='Error';
                    objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+'AsyncApexJob Id :'+listAsyncApex[0].Id;
                    objApexExe.Stack_Trace__c='Some Exception which can not handle '+listAsyncApex[0].ExtendedStatus;
                    objApexExe.Message__c ='No Of Failed Batch '+listAsyncApex[0].NumberOfErrors ;
                    objApexExe.EDW_Transaction_ID__c=adlId;
                    insert objApexExe;
                }
            }
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Quote Test exception');
            } 
        }catch(Exception e) {
            
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Quote__c=true;
            objApexErr.Apex_Class__c='DailyEDWQuoteFeed';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            if(String.isBlank(finalstr))
                objApexErr.Message__c = 'No Record Found on Quote';
            objApexErr.EDW_Transaction_ID__c=adlId;
            insert objApexErr;
        }
        finally{
            //Calling batch process for next object
            DailyEDWUserFeed objExecuteProcess = new DailyEDWUserFeed(validFromDate,validToDate,adlId);
            Database.executeBatch( objExecuteProcess, 1000);
        }
        
        
    }
    
}