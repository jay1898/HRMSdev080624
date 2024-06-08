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


public class EventBatchprocess implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
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
    //Constructor to defined the value and use within the batch publicly
    public EventBatchprocess(dateTime validFrom,dateTime validTo,string TxnId,string Taskfinalstr) {
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
        if(string.isBlank(finalstr)){
            finalstr = header ;
        }
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        try{
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
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Event Test exception');
            }
        }catch(Exception e) {
            errors.add(e);
            string allExeError = string.join(errors,',');
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Apex_Class__c='EventBatchprocess';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            objApexExe.Message__c = e.getMessage();
            insert objApexExe;
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex=[select id,Message__c,Apex_Class__c from Apex_Debug_Log__c where EDW_Transaction_ID__c =:adlId];
        finalstr=finalstr+Eventfinalstr;
        String responseBody;
        try{
            if(String.isNotBlank(finalstr)){
                // Code to do the POST Request
                string Filename='Activity-'+ objApex.Id +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
                string token=edwMetaData[0].Token__c;
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(edwMetaData[0].Endpoint__c);
                request.setMethod('POST');
                request.setBodyAsBlob(ServiceTerritoryExportBatchHandler.buildNew(EncodingUtil.base64Encode(blob.valueOf(finalstr)), Filename));
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
                if(response.getStatus() == 'SUCCESS' && (response.getStatusCode() == 200 || response.getStatusCode() == 201)){
                    responseBody = response.getBody();
                    HttpRequest finalrequest = new HttpRequest();
                    String endPoint = edwMetaData[0].Endpoint__c;
                    finalrequest.setMethod('POST');
                    finalrequest.setBodyasblob(blob.valueOf('Completed'));
                    finalrequest.setHeader('Authorization', 'Bearer '+token);
                    finalrequest.setHeader('Content-Type', 'application/json');
                    finalrequest.setTimeout(120000);
                    
                    if(!test.isRunningTest()){
                        response = http.send(finalrequest);
                    }
                    else{
                        response = MapLocationCalloutMock.respond(request);
                    }
                    
                }
                else
                    responseBody = response.getBody();
                HttpRequest finalrequest = new HttpRequest();
                finalrequest.setEndpoint('https://apidev.pella.com/ebs-integration/v1/edwService?status=Error');
                finalrequest.setMethod('POST');
                finalrequest.setBodyasblob(blob.valueOf('Error'));
                finalrequest.setHeader('Authorization', 'Bearer '+token);
                finalrequest.setHeader('Content-Type', 'text/csv');
                finalrequest.setTimeout(120000);
                
                HttpResponse finalresponse;
                if(!test.isRunningTest()){
                    finalresponse = http.send(request);
                }
                else{
                    finalresponse = MapLocationCalloutMock.respond(request);
                }
            }
            objApex.Apex_Class__c+=' AND EventBatchprocess';
            if(String.isBlank(finalstr))
                objApex.Message__c += String.isNotBlank(objApex.Message__c)?  'AND No Record Found on Event': 'No Record Found on Event';
            if(String.isNotBlank(responseBody))
                objApex.Message__c = responseBody;
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
            }
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Event Test exception');
            }
        }catch(Exception e) {
            
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Activity__c=true;
            objApexErr.Apex_Class__c='EventBatchprocess';
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