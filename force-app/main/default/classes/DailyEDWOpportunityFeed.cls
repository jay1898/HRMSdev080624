/*
Created By: Sachin Padhiyar
Created Date: 10/08/2020 
Purpose: DailyEDWOpportunityFeed to fetch all the data of Opportunity POST all the records to external URL.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


public class DailyEDWOpportunityFeed implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    public dateTime validFromDate;
    public List<Opportunity> lstOpportunity = new List<Opportunity>() ;
    public List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
    public String generatedCSVFile ='';
    public dateTime currentDate= system.now();
    public string squery;
    public string header='';
    public string finalstr;
    public String fileRow = '';
    public string adlId;
    String newAdlId;
    String contentDocumentId;
    Boolean isError = false;
    List<ContentVersion> lstContentVersion = new List<ContentVersion>();
    public list<String> fieldSet = new list<String>();
    public set<Id> OppIds = new set<Id>();
    public set<Id> accountIds = new set<Id>();
    public Map<String,EDW_Object_Mapping__mdt> edwmap;
    public Exception[] errors = new Exception[0];
    public List<Endpoint_Configuration__mdt> edwMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EDW_Integration'];
    public Boolean testClassException;
    public class OppException extends Exception {} 
    Id tradeCommRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
    
    //Constructor to defined the value and use within the batch publicly
    public DailyEDWOpportunityFeed(dateTime validFrom,dateTime validTo,string TxnId,Boolean testClassException) {
        testClassException=testClassException;
        adlId=TxnId;
        this.validToDate=validTo;
        this.validFromDate=validFrom;
        /*edwmap= new Map<String,EDW_Object_Mapping__mdt>([select Field_Api_Name__c, Source_Object__c, MasterLabel, Csv_Column_Sequence__c from EDW_Object_Mapping__mdt where Source_Object__c='Opportunity' ORDER BY Csv_Column_Sequence__c ASC]);
        for(EDW_Object_Mapping__mdt fields :edwmap.values()){
            fieldSet.add(fields.Field_Api_Name__c);
            header+=(string.isNotBlank(header))?'|'+fields.MasterLabel : fields.MasterLabel;
        }*/
        //Header= 'SalesforceOpportunityID|OpportunityBranchNumber|SalesforceBranchAccountId|OpportunityName|BusinessSegment|Stage|Status|CreatedDate|LastModifiedDate|City|Country|State|Street|Zipcode|MarketSegment|DeliveryDate|CloseDate|ProjectClosedDate|BookDatePQM|Probability %|Description|LostReason|SpecificationStatus|OpportunityOwnerId|ForecastCategory'; 
        Header= 'SalesforceOpportunityID|OpportunityBranchNumber|SalesforceBranchAccountId|OpportunityName|BusinessSegment|Stage|Status|CreatedDate|LastModifiedDate|City|Country|State|Street|Zipcode|BuildingType|ProjectType|DeliveryDate|CloseDate|ProjectClosedDate|BookDatePQM|Probability %|Description|LostReason|SpecificationStatus|OpportunityOwnerId|ForecastCategory'; 
        system.debug('tradeCommRecordTypeId :: ' + tradeCommRecordTypeId);
		//squery=label.EDWAllBatchLimit;
		squery='SELECT Book_Date_PQM__c,BusinessSegment__c,Probability,Delivery_Date__c,State__c,Building_Type__c,StageName,Branch_Number__c,ForecastCategoryName,Close_Reason__c,CloseDate,Name,AccountId,Country__c,Specification_Status__c,Street__c,OwnerId,Project_Type__c,Zipcode__c,CreatedDate,Id,Project_Closed_Date__c,City__c,Description,LastModifiedDate,Status__c, market_segment__c  FROM Opportunity WHERE EDW_Last_Modified__c >= :validFromDate AND  EDW_Last_Modified__c <= :validToDate AND RecordTypeId=:tradeCommRecordTypeId and accountId!=null ';
		//squery='SELECT '+string.join(fieldSet,',')+' FROM Opportunity WHERE RecordTypeId=:tradeCommRecordTypeId and Id in(\'0063i000009VCWS\',\'0063i000009T2Qk\')';

       // squery='SELECT '+string.join(fieldSet,',')+' FROM Opportunity  where (Book_Date_PQM__c >=  2019-12-01 OR CreatedDate >= 2019-12-01T00:00:00Z)  AND RecordTypeId=:tradeCommRecordTypeId';
    }
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(squery);
        
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        try{ 
            lstContentVersion.clear();
            if(string.isBlank(newAdlId)){
                finalstr = header;
            }else{
                lstContentVersion = [SELECT Title,VersionData,ContentDocumentId,ContentSize FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true];
                if(lstContentVersion != null && !lstContentVersion.isEmpty()){
                    if(lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size) )
                        finalstr = header;
                    else
                        finalstr = '';
                }
                
            }
            fileRow = '';
            System.debug('fileRow = ' +fileRow);
           for(Opportunity objOpp : scope){
               fileRow='';
               this.OppIds.add(objOpp.Id);
               if(objOpp.AccountId != null)
                   this.accountIds.add(objOpp.AccountId);
               
               fileRow = fileRow+'"'+(objOpp.Id!=null?+objOpp.Id:'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Branch_Number__c!=null?+objOpp.Branch_Number__c:'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.AccountId!=null?String.valueOf(objOpp.AccountId):'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Name!=null?''+objOpp.Name+'':'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.BusinessSegment__c!=null?objOpp.BusinessSegment__c:'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.StageName!=null?objOpp.StageName:'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Status__c!=null?objOpp.Status__c:'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.CreatedDate!=null?String.valueOf(objOpp.CreatedDate):'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.LastModifiedDate!=null?String.valueOf(objOpp.LastModifiedDate):'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.City__c!=null?objOpp.City__c:'').replace('"','')+ '"';  
               fileRow = fileRow +'|"'+(objOpp.Country__c!=null?objOpp.Country__c:'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.State__c!=null?objOpp.State__c:'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Street__c!=null?objOpp.Street__c:'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Zipcode__c!=null?objOpp.Zipcode__c:'').replace('"','')+ '"'; 
               fileRow = fileRow +'|"'+(objOpp.Market_Segment__c!=null?objOpp.Market_Segment__c:'').replace('"','')+ '"'; 
              // fileRow = fileRow +'|"'+(objOpp.Building_Type__c!=null?objOpp.Building_Type__c:'').replace('"','')+ '"'; 
              // fileRow = fileRow +'|"'+(objOpp.Project_Type__c!=null?objOpp.Project_Type__c:'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Delivery_Date__c!=null?String.valueOf(objOpp.Delivery_Date__c)+' 00:00:00':'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.CloseDate!=null?String.valueOf(objOpp.CloseDate)+' 00:00:00':'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Project_Closed_Date__c!=null?String.valueOf(objOpp.Project_Closed_Date__c):'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Book_Date_PQM__c!=null?String.valueOf(objOpp.Book_Date_PQM__c)+' 00:00:00':'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Probability!=null?String.valueOf(objOpp.Probability):'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Description!=null?objOpp.Description:'').replace('"','').replace('\n','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Close_Reason__c!=null?objOpp.Close_Reason__c:'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.Specification_Status__c!=null?objOpp.Specification_Status__c:'').replace('"','')+ '"';
               fileRow = fileRow +'|"'+(objOpp.OwnerId!=null?objOpp.OwnerId:'')+ '"';
               fileRow = fileRow +'|"'+(objOpp.ForecastCategoryName!=null?objOpp.ForecastCategoryName:'').replace('"','')+ '"';     
                /*for(EDW_Object_Mapping__mdt fields :edwmap.values()){
                    if(fields.Field_Api_Name__c.indexOf('.') > -1){
                        String parentRelation = fields.Field_Api_Name__c.split('\\.')[0];
                        String parentField = fields.Field_Api_Name__c.split('\\.')[1];
                        
                        string nullCheck='';
                        if(string.isNotBlank(fileRow)){
                            if((objOpp.getSobject(parentRelation).get(parentField)!=null)){
                                fileRow = fileRow +'|"'+string.valueOf(objOpp.getSobject(parentRelation).get(parentField)).replace('"','')+'"';
                            }
                            else{
                                fileRow=fileRow+'|""';
                            }
                        }
                        else{
                            if(string.valueOf(objOpp.getSobject(parentRelation).get(parentField))!=null){
                                fileRow = '"'+string.valueOf(objOpp.getSobject(parentRelation).get(parentField)).replace('"','')+'"';
                            }
                            else{
                                fileRow='""';
                            }
                        }
                    }else{
                        //this.OppIds.add(objOpp.Id);
                        string nullCheck='';
                        if(string.isNotBlank(fileRow)){
                            if(fields.Field_Api_Name__c == 'Description'){
                                if(objOpp.get(fields.Field_Api_Name__c)!=null){
                                    fileRow = fileRow +'|"'+string.valueOf(objOpp.get(fields.Field_Api_Name__c)).replace('"','').replace('\n','') + '"';
                                }
                                else{
                                    fileRow = fileRow +'|""';
                                }                                
                            }
                            else{                              
                                if(objOpp.get(fields.Field_Api_Name__c)!=null){
                                    fileRow = fileRow +'|"'+string.valueOf(objOpp.get(fields.Field_Api_Name__c)).replace('"','')+'"';
                                }
                                else{
                                    fileRow = fileRow +'|""';
                                }
                                
                            }
                        }
                        else{
                            if(fields.Field_Api_Name__c == 'Description'){
                                if(string.valueOf(objOpp.get(fields.Field_Api_Name__c))!=null){
                                    fileRow = '"' + string.valueOf(objOpp.get(fields.Field_Api_Name__c)).replace('"','') + '"';
                                }
                                else{
                                    fileRow= '""';
                                }
                            }
                            else{                                                             
                                if(string.valueOf(objOpp.get(fields.Field_Api_Name__c))!=null){
                                    fileRow = '"'+string.valueOf(objOpp.get(fields.Field_Api_Name__c)).replace('"','')+'"';
                                }
                                else{
                                    fileRow= '""';
                                }
                            }
                        }
                    }
                    System.debug('Heap Size used##'+Limits.getHeapSize());
                    System.debug('Heap Size Remaing##'+Limits.getLimitHeapSize());
                }*/
                System.debug('file Row###'+fileRow);
                if(String.isNotBlank(fileRow))
                    finalstr+= '\n'+fileRow;
                fileRow='';
            }
            if(String.isBlank(newAdlId)){
                Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
                objApex.Opportunity__c=true;
                objApex.Apex_Class__c='DailyEDWOpportunityFeed';
                objApex.Method__c='GET';
                objApex.Type__c='Information';
                objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
                if(String.isBlank(finalstr))
                    objApex.Message__c = 'No Record Found on Opportunity';
                insert objApex;
                newAdlId = objApex.Id;
                objApex.EDW_Transaction_ID__c= adlId; //objApex.Id;
                
                update objApex;
                //String csvname= 'Opportunity-'+ objApex.Id +'-'+'currentDate_'+'.csv';
                
                String csvname= 'Opportunity-'+ objApex.Id +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
                //if(lstContentVersion != null && !lstContentVersion.isEmpty()){
                if(lstContentVersion != null && lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size) ){
                    //Insert the csv file in File object
                    //String csvname= 'Opportunity-'+ objApex.Id +'-'+'currentDate_'+'.csv';
                    String csvname= 'Opportunity-'+ newAdlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
            finalstr='';
            lstContentVersion.clear();
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Opp Test exception');
            }
           
        }catch(Exception e) {
            errors.add(e);
            List<String> oppIds=new List<String>();
            for(Opportunity objOpp : scope){
                oppIds.add(objOpp.Id);
            }
            string allExeError = string.join(errors,',');
            isError = true;
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Opportunity__c=true;
            objApexExe.Apex_Class__c='DailyEDWOpportunityFeed';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            objApexExe.Message__c = e.getMessage()+ ' '+string.join(oppIds,',');
            insert objApexExe;
        }
        
    }   
    
    public void finish(Database.BatchableContext BC) {
       
        // Code to do the POST Request
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        String cummulativeResponse = 'Records Processed:'+ OppIds.size();
        Integer cnt = 0;
        try{
            if(String.isNotBlank(newAdlId)){
                objApex = [SELECT Id FROM Apex_Debug_Log__c WHERE Id =: newAdlId LIMIT 1];
                //AccountBatchprocess objExecuteProcess = new AccountBatchprocess(validFromDate,validToDate,newAdlId,OppIds,testClassException);
                //Database.executeBatch( objExecuteProcess, Integer.valueOf(Label.EDW_Batch_Size));
                List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :newAdlId];
                Set<Id> ContentDocumentIdSet = new Set<Id>();
                for(ContentDocumentLink temp : cdlList){
                    ContentDocumentIdSet.add(temp.ContentDocumentId);
                }
                
                if (!ContentDocumentIdSet.isEmpty()) {
                    for (ContentVersion conVer : [SELECT Title,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :ContentDocumentIdSet AND IsLatest = TRUE] ) {
                        system.debug('Data there is' + conVer.Title);
                        String responseBody;
                        cnt++;
                        //List<ContentVersion> lstContentVersion = [SELECT Title,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true LIMIT 1];
                        //string Filename='Opportunity-'+ adlId +'-'+currentDate+'.csv';
                        String Filename= 'Opportunity-'+ adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+String.valueof(cnt)+'.csv';
                        string token=edwMetaData[0].Token__c;
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        String endPoint = edwMetaData[0].Endpoint__c;
                        endPoint = endPoint.replace('Completed','Success');
                        /*if(isError)
                            endPoint = endPoint.replace('Success','Failure');*/
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
                        else
                        {
                            responseBody = response.getBody();
                            isError = true;
                        }   
                        if(String.isNotBlank(responseBody))
                            cummulativeResponse = cummulativeResponse+responseBody;
                        //objApex.Message__c = responseBody;
                        //conVerToUpdate.add(conVer);
                    }
                }
                objApex.Message__c = cummulativeResponse;
                If (isError)
                    objApex.type__c = 'Error';
                Else
                	objApex.type__c = 'Complete';
                update objApex;
            }//end of newAdlId not null
            
             // check all the batch job finish successfully or not
            List<AsyncApexJob> listAsyncApex=[SELECT ApexClass.Name,JobType, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate,ExtendedStatus, Id FROM AsyncApexJob Where jobtype='BatchApex' and apexclass.name='DailyEDWOpportunityFeed' order by createddate desc limit 1];
            system.debug('@@'+JSON.serialize(listAsyncApex));
            if(listAsyncApex.size()>0){
                if(listAsyncApex[0].NumberOfErrors>0 || listAsyncApex[0].ExtendedStatus!=null  || test.isRunningTest()){
                    Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
                    objApexExe.Opportunity__c=true;
                    objApexExe.Apex_Class__c='DailyEDWOpportunityFeed';
                    objApexExe.Method__c='GET';
                    objApexExe.Type__c='Error';
                    objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+'AsyncApexJob Id :'+listAsyncApex[0].Id;
                    objApexExe.Stack_Trace__c='Some Exception which can not handle '+listAsyncApex[0].ExtendedStatus;
                    objApexExe.Message__c ='No Of Failed Batch '+listAsyncApex[0].NumberOfErrors ;
                    objApex.EDW_Transaction_ID__c= adlId; 
                    insert objApexExe;
                }
            }
            
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Opp Test exception');
            }
        }catch(Exception e) {
            system.debug('Line  is 123:: ' + e.getLineNumber());
            system.debug('Message is 123:: ' + e.getMessage());
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Opportunity__c=true;
            objApexErr.Apex_Class__c='DailyEDWOpportunityFeed';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            objApex.EDW_Transaction_ID__c= adlId; 
            if(String.isBlank(finalstr))
            {
                objApexErr.Message__c = 'No Record Found on Opportunity';
                objApexErr.Type__c='Information';
            }
            
            insert objApexErr; 
        }
        finally{
            
            //Calling batch process for next object
            DailyEDWAccountFeed objExecuteProcess = new DailyEDWAccountFeed(validFromDate,validToDate,adlId,OppIds,testClassException,accountIds);
            Database.executeBatch( objExecuteProcess, Integer.valueOf(Label.EDW_Batch_Size));
        }
        
        
    }
    
}