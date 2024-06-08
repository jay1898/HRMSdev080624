/*
Created By: Sachin Padhiyar
Created Date: 10/08/2020 
Purpose: QuoteBatchprocess to fetch all the data of Quote POST all the records to external URL.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


public class DailyEDWEventFeed implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    public dateTime validFromDate;
    public List<Event> lstEvent = new List<Event>() ;
    public List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
    public String generatedCSVFile ='';
    public dateTime currentDate= system.Today();
    public string squery;
    public string header='';
    public string finalstr;
    public string Eventfinalstr;
    public String fileRow = '';
    public string adlId;
    public list<String> fieldSet = new list<String>();
    public Map<String,EDW_Object_Mapping__mdt> edwmap;
    public Exception[] errors = new Exception[0];
    public List<Endpoint_Configuration__mdt> edwMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EDW_Integration'];
    public Boolean testClassException;
    public class OppException extends Exception {} 
    
    // Newly Added Variables
    public String contentDocumentId;
    List<ContentVersion> lstContentVersion = new List<ContentVersion>();
    public String newAdlId;
    Boolean isError = false;
    
    //Constructor to defined the value and use within the batch publicly
    public DailyEDWEventFeed(dateTime validFrom,dateTime validTo,string TxnId,string Taskfinalstr) {
        testClassException=testClassException;
        this.Eventfinalstr = Taskfinalstr;
        adlId=TxnId;
        this.validToDate=validTo;
        this.validFromDate=validFrom;
        edwmap= new Map<String,EDW_Object_Mapping__mdt>([select Field_Api_Name__c,Source_Object__c,MasterLabel,Csv_Column_Sequence__c from EDW_Object_Mapping__mdt where Source_Object__c='Event' ORDER BY Csv_Column_Sequence__c ASC]);
        for(EDW_Object_Mapping__mdt fields :edwmap.values()){
            fieldSet.add(fields.Field_Api_Name__c);
            header+=(string.isNotBlank(header))?';'+fields.MasterLabel : fields.MasterLabel;
        }
        squery='SELECT '+string.join(fieldSet,',')+' FROM Event WHERE EDW_Last_Modified__c >= :validFromDate AND  EDW_Last_Modified__c <= :validToDate';
    }
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(squery);
        
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<Event> scope) {
        try{ 
            // Clear CV from Last Execution
            lstContentVersion.clear();
            
            // If first time then that mean create new CSV
            if(string.isBlank(newAdlId)){
                finalstr = header ;
            }
            // Else Use Old CSV
            else{
                lstContentVersion = [SELECT Title,VersionData,ContentDocumentId,ContentSize FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true];
                if(lstContentVersion != null && !lstContentVersion.isEmpty()){
                    if(lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size) )
                        finalstr = header;
                    else
                        finalstr = '';
                }
            }
            
            fileRow = '';
            for(Event objEvent : scope){
                for(EDW_Object_Mapping__mdt fields :edwmap.values()){
                    if(fields.Field_Api_Name__c.indexOf('.') > -1){
                        if(string.isNotBlank(fileRow)){
                            if((objEvent.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])!=null)){
                                fileRow = fileRow +';"'+string.valueOf(objEvent.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))+'"';
                            }
                            else{
                                fileRow=fileRow+';""';
                            }
                        }
                        else{
                            if(string.valueOf(objEvent.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))!=null){
                                fileRow = '"'+string.valueOf(objEvent.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))+'"';
                            }
                            else{
                                fileRow='""';
                            }
                        }
                    }
                    else{
                        if(string.isNotBlank(fileRow)){
                            if(objEvent.get(fields.Field_Api_Name__c)!=null){
                                fileRow = fileRow +';"'+string.valueOf(objEvent.get(fields.Field_Api_Name__c))+'"';
                            }
                            else{
                                fileRow = fileRow +';""';
                            }
                        }
                        else{
                            if(string.valueOf(objEvent.get(fields.Field_Api_Name__c))!=null){
                                fileRow = '"'+string.valueOf(objEvent.get(fields.Field_Api_Name__c))+'"';
                            }
                            else{
                                fileRow= '""';
                            }
                        }
                    }
                }
                if(String.isNotBlank(fileRow))
                    finalstr+= '\n'+fileRow;
                fileRow='';
            }
            
            if(String.isBlank(newAdlId)){
                Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
                objApex.Apex_Class__c='DailyEDWEventFeed';
                objApex.Method__c='GET';
                objApex.Activity__c=true;
                objApex.Type__c='Information';
                objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
                if(String.isBlank(finalstr))
                    objApex.Message__c = 'No Record Found on EventTerritory';
                insert objApex;
                
                newAdlId = objApex.Id;
                
                objApex.EDW_Transaction_ID__c=objApex.Id;
                update objApex;
                
                if(String.isNotBlank(finalstr)){
                    string csvname= 'Activity-'+ objApex.Id +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
                    insert cDe;
                    
                    contentDocumentId = conDoc;
                }
            }
            else{
                // New CSV
                if(lstContentVersion != null && lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size) )
                {
                    string csvname= 'Activity-'+ newAdlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
                    
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
                }
                // Update Old CSV
                else
                {
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
            finalstr = '';
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Event Test exception');
            }
        }
        catch(Exception e) {
            errors.add(e);
            string allExeError = string.join(errors,',');
            List<String> eventIds=new List<String>();
            for(Event objEvent : scope){
                eventIds.add(objEvent.Id);
            }
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Apex_Class__c='DailyEDWEventFeed';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            objApexExe.Message__c = e.getMessage() + ' '+string.join(eventIds,',');
            insert objApexExe;
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        String cummulativeResponse = ' \n Event related Data:: ';
        
        Boolean sendComplete = true;
        
        try{
            if(String.isNotBlank(newAdlId)){
                objApex = [SELECT Id, Message__c, Apex_Class__c FROM Apex_Debug_Log__c WHERE Id =: newAdlId LIMIT 1];
                objApex.Apex_Class__c +=' AND DailyEDWEventFeed';
                List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :newAdlId];
                Set<Id> ContentDocumentIdSet = new Set<Id>();
                for(ContentDocumentLink temp : cdlList){
                    ContentDocumentIdSet.add(temp.ContentDocumentId);
                }
                
                if (!ContentDocumentIdSet.isEmpty()) {
                    for (ContentVersion conVer : [SELECT Title,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :ContentDocumentIdSet AND IsLatest = TRUE] ) {
                        System.debug('CSVFileName:: ' + conVer.Title);
                        String responseBody;
                        String Filename= 'Activity-' + adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
                        string token = edwMetaData[0].Token__c;
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
                        if(response.getStatus() == 'SUCCESS' && (response.getStatusCode() == 200 || response.getStatusCode() == 201))
                            responseBody = response.getBody();
                        else{
                            responseBody = response.getBody();
                            sendComplete = false;
                        }
                        if(String.isNotBlank(responseBody))
                            cummulativeResponse = cummulativeResponse + responseBody;
                    }
                }
                
                objApex.Message__c += cummulativeResponse;
                update objApex;
            }//end of newAdlId not null
            
            
            // TODO: Add DebugLog
            Http finalhttp = new Http();
            HttpRequest finalrequest = new HttpRequest();
            finalrequest.setMethod('POST');
            finalrequest.setHeader('Authorization', 'Bearer ' + edwMetaData[0].Token__c);
            finalrequest.setEndpoint(edwMetaData[0].Endpoint__c);
            finalrequest.setHeader('Content-Type', 'application/json');
            finalrequest.setTimeout(120000);
            finalrequest.setBodyasblob(blob.valueOf('Completed'));
            HttpResponse finalresponse;
            if(!test.isRunningTest()){
                finalresponse = finalhttp.send(finalrequest);
            }
            else{
                finalresponse = MapLocationCalloutMock.respond(finalrequest);
            }
            cummulativeResponse += finalresponse.getBody();
            
            // check all the batch job finish successfully or not
            List<AsyncApexJob> listAsyncApex=[SELECT ApexClass.Name,JobType, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate,ExtendedStatus, Id FROM AsyncApexJob Where jobtype='BatchApex' and apexclass.name='DailyEDWEventFeed' order by createddate desc limit 1];
            system.debug('@@'+JSON.serialize(listAsyncApex));
            if(listAsyncApex.size()>0){
                if(listAsyncApex[0].NumberOfErrors>0 || listAsyncApex[0].ExtendedStatus!=null ){
                    Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
                    objApexExe.Opportunity__c=true;
                    objApexExe.Apex_Class__c='DailyEDWEventFeed';
                    objApexExe.Method__c='GET';
                    objApexExe.Type__c='Error';
                    objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+'AsyncApexJob Id :'+listAsyncApex[0].Id;
                    objApexExe.Stack_Trace__c='Some Exception which can not handle '+listAsyncApex[0].ExtendedStatus;
                    objApexExe.Message__c ='No Of Failed Batch '+listAsyncApex[0].NumberOfErrors ;
                    insert objApexExe;
                }
            }
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Event Test exception');
            }
        }
        catch(Exception e) {
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Activity__c=true;
            objApexErr.Apex_Class__c='DailyEDWEventFeed';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            if(String.isBlank(finalstr))
                objApexErr.Message__c = 'No Record Found on EventTerritory';
            insert objApexErr;
        }
    }
}