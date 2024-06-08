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


public class TaskBatchprocess implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    public dateTime validFromDate;
    public List<Task> lstTask = new List<Task>() ;
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
    public Boolean testClassException;
    public class OppException extends Exception {} 
    //Constructor to defined the value and use within the batch publicly
    public TaskBatchprocess(dateTime validFrom,dateTime validTo,string TxnId) {
        testClassException=testClassException;
        adlId=TxnId;
        this.validToDate=validTo;
        this.validFromDate=validFrom;
        edwmap= new Map<String,EDW_Object_Mapping__mdt>([select Field_Api_Name__c,Source_Object__c,MasterLabel,Csv_Column_Sequence__c from EDW_Object_Mapping__mdt where Source_Object__c='Task' ORDER BY Csv_Column_Sequence__c ASC]);
        for(EDW_Object_Mapping__mdt fields :edwmap.values()){
            fieldSet.add(fields.Field_Api_Name__c);
            header+=(string.isNotBlank(header))?';'+fields.MasterLabel : fields.MasterLabel;
        }
        squery='SELECT '+string.join(fieldSet,',')+' FROM Task WHERE EDW_Last_Modified__c >= :validFromDate AND  EDW_Last_Modified__c <= :validToDate';
    }
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(squery);
        
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<Task> scope) {
        if(string.isBlank(finalstr)){
            finalstr = header ;
        }
        try{ 
            fileRow = '';
            for(Task objTask : scope){
                //fileRow = objTask.Id;
                for(EDW_Object_Mapping__mdt fields :edwmap.values()){
                    if(fields.Field_Api_Name__c.indexOf('.') > -1){
                        if(string.isNotBlank(fileRow)){
                            if((objTask.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1])!=null)){
                                fileRow = fileRow +';"'+string.valueOf(objTask.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))+'"';
                            }
                            else{
                                fileRow=fileRow+';""';
                            }
                        }
                        else{
                            if(string.valueOf(objTask.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))!=null){
                                fileRow = '"'+string.valueOf(objTask.getSobject(fields.Field_Api_Name__c.split('\\.')[0]).get(fields.Field_Api_Name__c.split('\\.')[1]))+'"';
                            }
                            else{
                                fileRow='""';
                            }
                        }
                    }
                    else{
                        if(string.isNotBlank(fileRow)){
                            if(objTask.get(fields.Field_Api_Name__c)!=null){
                                fileRow = fileRow +';"'+string.valueOf(objTask.get(fields.Field_Api_Name__c))+'"';
                            }
                            else{
                                fileRow = fileRow +';""';
                            }
                        }
                        else{
                            if(string.valueOf(objTask.get(fields.Field_Api_Name__c))!=null){
                                fileRow = '"'+string.valueOf(objTask.get(fields.Field_Api_Name__c))+'"';
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
                throw new OppException('Task Test exception');
            }
        }catch(Exception e) {
            errors.add(e);
            //errors.remove(null);
            string allExeError = string.join(errors,',');
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Activity__c=true;
            objApexExe.Apex_Class__c='ServiceTerritoryBatchprocess';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            
            objApexExe.Message__c = e.getMessage();
            insert objApexExe;
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        // Code to do the POST Request
        String responseBody;
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        try{
            
            objApex.Apex_Class__c='TaskBatchprocess';
            objApex.Method__c='GET';
            objApex.Activity__c=true;
            objApex.Type__c='Information';
            objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            if(String.isBlank(finalstr))
                objApex.Message__c = 'No Record Found on Task';
            if(String.isNotBlank(responseBody))
                objApex.Message__c = responseBody;
            insert objApex;
            objApex.EDW_Transaction_ID__c=objApex.Id;
            update objApex;
            if(String.isNotBlank(finalstr)){
                string csvname= 'Task-' + objApex.Id +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
                //Insert the csv file in File object
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = Blob.valueOf(finalstr);
                ContVerFile.Title = csvname; 
                ContVerFile.ContentLocation= 's';
                ContVerFile.PathOnClient= csvname;
                
            } 
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Task Test exception');
            }
        }catch(Exception e) {
            
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Activity__c=true;
            objApexErr.Apex_Class__c='TaskBatchprocess';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            if(String.isBlank(finalstr))
                objApexErr.Message__c = 'No Record Found on Task';
            
            insert objApexErr;
        }
        finally{
            
            //Calling batch process for next object
            EventBatchprocess objExecuteProcess = new EventBatchprocess (validFromDate,validToDate,objApex.Id,finalstr);
            Database.executeBatch( objExecuteProcess, 500);
        }
    }
}