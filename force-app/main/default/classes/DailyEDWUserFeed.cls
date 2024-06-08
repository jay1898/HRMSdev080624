/*
Created By: Sachin Padhiyar
Created Date: 10/08/2020 
Purpose: DailyEDWUserFeed to fetch all the data of User POST all the records to external URL.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


public class DailyEDWUserFeed implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    public dateTime validFromDate;
    public List<User> lstUser = new List<User>() ;
    public List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
    public String generatedCSVFile ='';
    public dateTime currentDate= system.Now();
    public string squery;
    public string header='';
    public string finalstr;
    public String fileRow = '';
    public string adlId;
    Integer cnt = 0;
    public list<String> fieldSet = new list<String>();
    public Map<String,EDW_Object_Mapping__mdt> edwmap;
    public Exception[] errors = new Exception[0];
    public List<Endpoint_Configuration__mdt> edwMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EDW_Integration'];
    public Boolean testClassException;
    public class OppException extends Exception {} 
    //Constructor to defined the value and use within the batch publicly
    public DailyEDWUserFeed(dateTime validFrom,dateTime validTo,string TxnId) {
        testClassException=testClassException;
        adlId=TxnId;
        this.validToDate=validTo;
        this.validFromDate=validFrom;
        edwmap= new Map<String,EDW_Object_Mapping__mdt>([select Field_Api_Name__c,Source_Object__c,MasterLabel,Csv_Column_Sequence__c from EDW_Object_Mapping__mdt where Source_Object__c='User' ORDER BY Csv_Column_Sequence__c ASC]);
        for(EDW_Object_Mapping__mdt fields :edwmap.values()){
            fieldSet.add(fields.Field_Api_Name__c);
            header+=(string.isNotBlank(header))?'|'+fields.MasterLabel : fields.MasterLabel;
        }
        squery='SELECT '+string.join(fieldSet,',')+' FROM User WHERE EDW_Last_Modified__c >= :validFromDate AND  EDW_Last_Modified__c <= :validToDate';
    }
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(squery);
        
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<User> scope) {
        try{ 
            if(string.isBlank(finalstr)){
                finalstr = header ;
            }
            fileRow = '';
            for(User objUser : scope){
                cnt++;
                for(EDW_Object_Mapping__mdt fields :edwmap.values()){
                    if(fields.Field_Api_Name__c.indexOf('.') > -1){
                        if(string.isNotBlank(fileRow)){
                            if((objUser.getSobject(fields.Field_Api_Name__c.split('\\.')[0]))!=null && (objUser.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])!=null)){
                                fileRow = fileRow +'|"'+string.valueOf(objUser.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])).replace('"','')+'"';
                            }
                            else{
                                fileRow=fileRow+'|""';
                            }
                        }
                        else{
                            if((objUser.getSobject(fields.Field_Api_Name__c.split('\\.')[0]))!=null && string.valueOf(objUser.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))!=null){
                                fileRow = '"'+string.valueOf(objUser.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])).replace('"','')+'"';
                            }
                            else{
                                fileRow='""';
                            }
                        }
                    }
                    else{
                        if(string.isNotBlank(fileRow)){
                            if(objUser.get(fields.Field_Api_Name__c)!=null){
                                fileRow = fileRow +'|"'+string.valueOf(objUser.get(fields.Field_Api_Name__c)).replace('"','')+'"';
                            }
                            else{
                                fileRow = fileRow +'|""';
                            }
                        }
                        else{
                            if(string.valueOf(objUser.get(fields.Field_Api_Name__c))!=null){
                                fileRow = '"'+string.valueOf(objUser.get(fields.Field_Api_Name__c)).replace('"','')+'"';
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
                throw new OppException('User Test exception');
            }
        }catch(Exception e) {
            errors.add(e);
            List<String> userIds=new List<String>();
            for(User objuser : scope){
                userIds.add(objuser.Id);
            }
            string allExeError = string.join(errors,',');
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.User__c=true;
            objApexExe.Apex_Class__c='DailyEDWUserFeed';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            
            objApexExe.Message__c = e.getMessage()+ ' '+string.join(userIds,',');
            insert objApexExe;
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        // Code to do the POST Request
        String responseBody;
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
		//String cummulativeResponse = 'Records Processed: ' + String.ValueOf(cnt);
        Integer itr = 0;        
        Boolean sendComplete = true;
        try{
            if(String.isNotBlank(finalstr)){
               
                string Filename= 'User-'+ adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+String.Valueof(itr)+'.csv';
                string token=edwMetaData[0].Token__c;
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(edwMetaData[0].Endpoint__c);
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
                system.debug('response is :: ' + response);
                if(response.getStatus() == 'SUCCESS' || (response.getStatusCode() == 200 || response.getStatusCode() == 201))
                    responseBody = response.getBody();
                else
                {
                    responseBody = response.getBody();
                    sendComplete = false;
                }
            }
            
            List<AsyncApexJob> listAsyncApex=[SELECT ApexClass.Name,JobType, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate,ExtendedStatus, Id FROM AsyncApexJob Where jobtype='BatchApex' and apexclass.name='DailyEDWUserFeed' order by createddate desc limit 1];
            system.debug('@@'+JSON.serialize(listAsyncApex));
            Apex_Debug_Log__c[] errorApex =  [SELECT Id FROM Apex_Debug_Log__c WHERE EDW_Transaction_ID__c=:adlId and Apex_Class__c like 'DailyEDW%' and type__c <> 'Complete'  LIMIT 1];
            
          
            Http finalhttp = new Http();
            HttpRequest finalrequest = new HttpRequest();
            finalrequest.setMethod('POST');
            finalrequest.setHeader('Authorization', 'Bearer ' + edwMetaData[0].Token__c);
            String endPoint = edwMetaData[0].Endpoint__c;
           
            if(listAsyncApex.size()>0)
                if(listAsyncApex[0].NumberOfErrors>0 || listAsyncApex[0].ExtendedStatus!=null || (!sendComplete)|| (errorApex.size() > 0))
                	endPoint = endPoint.replace('Completed','Failure');
             finalrequest.setEndpoint(endPoint);
            finalrequest.setHeader('Content-Type', 'application/json');
            finalrequest.setTimeout(120000);
           // finalrequest.setBodyasblob(blob.valueOf('Completed'));
            HttpResponse finalresponse;
            if(!test.isRunningTest()){
                finalresponse = finalhttp.send(finalrequest);
            }
            else{
                finalresponse = MapLocationCalloutMock.respond(finalrequest);
            }
         //   cummulativeResponse += finalresponse.getBody();
            
            
            
            
            objApex.User__c=true;
            objApex.Apex_Class__c='DailyEDWUserFeed';
            objApex.Method__c='GET';
            objApex.Type__c='Complete';
            objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            if(String.isBlank(finalstr))
                objApex.Message__c = 'No Record Found on User';
            //if(String.isNotBlank(responseBody))
            objApex.Message__c = 'Records Processed: '+String.ValueOf(cnt) + ' '+responseBody +'go file:'+finalresponse + ' Endpoint:' +endPoint;
            objApex.EDW_Transaction_ID__c=adlId;
            insert objApex;
            
       
            
            if(String.isNotBlank(finalstr)){
                String csvname= 'User-'+ objApex.Id +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
            // TODO: Add DebugLog
            // check all the batch job finish successfully or not
           // List<AsyncApexJob> listAsyncApex=[SELECT ApexClass.Name,JobType, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate,ExtendedStatus, Id FROM AsyncApexJob Where jobtype='BatchApex' and apexclass.name='DailyEDWUserFeed' order by createddate desc limit 1];
            system.debug('@@'+JSON.serialize(listAsyncApex));
            if(listAsyncApex.size()>0){
                if(listAsyncApex[0].NumberOfErrors>0 || listAsyncApex[0].ExtendedStatus!=null ){
                    Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
                    objApexExe.Opportunity__c=true;
                    objApexExe.Apex_Class__c='DailyEDWUserFeed';
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
                throw new OppException('User Test exception');
            }
        }catch(Exception e) {
            
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.User__c=true;
            objApexErr.Apex_Class__c='DailyEDWUserFeed';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            if(String.isBlank(finalstr))
            {
                objApexErr.Message__c = 'No Record Found on User';
                objApexErr.Type__c='Complete';
            }
            
            insert objApexErr;
        }
      /*  finally{
            //Calling batch process for next object
            DailyEDWServiceTerritoryFeed objExecuteProcess = new DailyEDWServiceTerritoryFeed(validFromDate,validToDate,objApex.Id);
            Database.executeBatch( objExecuteProcess, 1000);
        }*/
        
        
    }
    
}