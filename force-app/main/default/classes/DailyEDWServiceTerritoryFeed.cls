/*
Created By: Sachin Padhiyar
Created Date: 10/08/2020 
Purpose: UserBatchprocess to fetch all the data of User POST all the records to external URL.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


public class DailyEDWServiceTerritoryFeed  implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    public dateTime validFromDate;
    public List<ServiceTerritory> lstServiceTerritory = new List<ServiceTerritory>() ;
    public List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
    public String generatedCSVFile ='';
    public dateTime currentDate= system.Today();
    public string squery;
    public string header='';
    public string finalstr;
    public String fileRow = '';
    public string adlId;
    public list<String> fieldSet = new list<String>();
    public Map<String,EDW_Object_Mapping__mdt> edwmap;
    public Exception[] errors = new Exception[0];
    public List<Endpoint_Configuration__mdt> edwMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EDW_Integration'];
    public Boolean testClassException;
    public class OppException extends Exception {} 
    //Constructor to defined the value and use within the batch publicly
    public DailyEDWServiceTerritoryFeed(dateTime validFrom,dateTime validTo,string TxnId) {
        testClassException=testClassException;
        adlId=TxnId;
        this.validToDate=validTo;
        this.validFromDate=validFrom;
        edwmap= new Map<String,EDW_Object_Mapping__mdt>([select Field_Api_Name__c,Source_Object__c,MasterLabel,Csv_Column_Sequence__c from EDW_Object_Mapping__mdt where Source_Object__c='ServiceTerritory' ORDER BY Csv_Column_Sequence__c ASC]);
        for(EDW_Object_Mapping__mdt fields :edwmap.values()){
            fieldSet.add(fields.Field_Api_Name__c);
            header+=(string.isNotBlank(header))?'|'+fields.MasterLabel : fields.MasterLabel;
        }
        string zipcode='Zipcode';
        squery='SELECT '+string.join(fieldSet,',')+' FROM ServiceTerritory WHERE RecordType.Name=\'' + zipcode + '\'';
    }
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(squery);
        
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<ServiceTerritory> scope) {
        try{ 
            if(string.isBlank(finalstr)){
                finalstr = header ;
            }
            fileRow = '';
            for(ServiceTerritory objServiceTerritory : scope){
                //fileRow = objServiceTerritory.Id;
                for(EDW_Object_Mapping__mdt fields :edwmap.values()){
                    if(fields.Field_Api_Name__c.indexOf('.') > -1){
                        if(string.isNotBlank(fileRow)){
                            if((objServiceTerritory.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])!=null)){
                                fileRow = fileRow +'|"'+string.valueOf(objServiceTerritory.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])).replace('"','')+'"';
                            }
                            else{
                                fileRow=fileRow+'|""';
                            }
                        }
                        else{
                            if(string.valueOf(objServiceTerritory.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))!=null){
                                fileRow = '"'+string.valueOf(objServiceTerritory.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])).replace('"','')+'"';
                            }
                            else{
                                fileRow='""';
                            }
                        }
                    }
                    else{
                        if(string.isNotBlank(fileRow)){
                            if(objServiceTerritory.get(fields.Field_Api_Name__c)!=null){
                                fileRow = fileRow +'|"'+string.valueOf(objServiceTerritory.get(fields.Field_Api_Name__c)).replace('"','')+'"';
                            }
                            else{
                                fileRow = fileRow +'|""';
                            }
                        }
                        else{
                            if(string.valueOf(objServiceTerritory.get(fields.Field_Api_Name__c))!=null){
                                fileRow = '"'+string.valueOf(objServiceTerritory.get(fields.Field_Api_Name__c)).replace('"','')+'"';
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
                throw new OppException('Service Test exception');
            }
        }catch(Exception e) {
            errors.add(e);
            string allExeError = string.join(errors,',');
            List<String> STIds=new List<String>();
            for(ServiceTerritory obST : scope){
                STIds.add(obST.Id);
            }
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Territory__c=true;
            objApexExe.Apex_Class__c='DailyEDWServiceTerritoryFeed';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            
            objApexExe.Message__c = e.getMessage()+ ' '+string.join(STIds,',');
            insert objApexExe;
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        // Code to do the POST Request
        String responseBody;
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        try{
            if(String.isNotBlank(finalstr)){
                string Filename= 'ServiceTerritory-'+ adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
                string token=edwMetaData[0].Token__c;
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String endPoint = edwMetaData[0].Endpoint__c;
                endPoint = endPoint.replace('Completed','Success');
                request.setEndpoint(endPoint);
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
                if(response.getStatus() == 'SUCCESS' && response.getStatusCode() == 200)
                    responseBody = response.getBody();
                else
                    responseBody = response.getBody();
            }
            
            
            objApex.Territory__c=true;
            objApex.Apex_Class__c='DailyEDWServiceTerritoryFeed';
            objApex.Method__c='GET';
            objApex.Type__c='Information';
            objApex.Territory__c=true;
            objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            if(String.isBlank(finalstr))
                objApex.Message__c = 'No Record Found on ServiceTerritory';
            if(String.isNotBlank(responseBody))
                objApex.Message__c = responseBody;
            insert objApex;
            objApex.EDW_Transaction_ID__c=objApex.Id;
            update objApex;
            
            // check all the batch job finish successfully or not
            List<AsyncApexJob> listAsyncApex=[SELECT ApexClass.Name,JobType, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate,ExtendedStatus, Id FROM AsyncApexJob Where jobtype='BatchApex' and apexclass.name='DailyEDWServiceTerritoryFeed' order by createddate desc limit 1];
            system.debug('@@'+JSON.serialize(listAsyncApex));
            if(listAsyncApex.size()>0){
                if(listAsyncApex[0].NumberOfErrors>0 || listAsyncApex[0].ExtendedStatus!=null ){
                    Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
                    objApexExe.Opportunity__c=true;
                    objApexExe.Apex_Class__c='DailyEDWServiceTerritoryFeed';
                    objApexExe.Method__c='GET';
                    objApexExe.Type__c='Error';
                    objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+'AsyncApexJob Id :'+listAsyncApex[0].Id;
                    objApexExe.Stack_Trace__c='Some Exception which can not handle '+listAsyncApex[0].ExtendedStatus;
                    objApexExe.Message__c ='No Of Failed Batch '+listAsyncApex[0].NumberOfErrors ;
                    insert objApexExe;
                }
            }
            
            if(String.isNotBlank(finalstr)){
                string csvname= 'ServiceTerritory-'+ adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
                throw new OppException('Service Test exception');
            }
        }catch(Exception e) {
            
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Territory__c=true;
            objApexErr.Apex_Class__c='DailyEDWServiceTerritoryFeed';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            if(String.isBlank(finalstr))
                objApexErr.Message__c = 'No Record Found on ServiceTerritory';
            
            insert objApexErr;
        }
        finally{
            //Calling batch process for next object
            DailyEDWTaskFeed objExecuteProcess = new DailyEDWTaskFeed(validFromDate,validToDate,objApex.Id);
            Database.executeBatch( objExecuteProcess, 500);
        }
        
        
    }
    
}