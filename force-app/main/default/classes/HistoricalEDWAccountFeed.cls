/*
Created By: Sachin Padhiyar
Created Date: 10/08/2020 
Purpose: HistoricalEDWAccountFeed to fetch all the data of Account POST all the records to external URL.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


public class HistoricalEDWAccountFeed implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    public dateTime validFromDate;
    public List<Account> lstAccount = new List<Account>() ;
    public List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
    public String generatedCSVFile ='';
    public dateTime currentDate= system.now();
    public string squery;
    public string header='';
    public string finalstr;
    public string adlId;
    String newAdlId;
    String contentDocumentId;
    Boolean isError = false;
    public String fileRow = '';
    public set<Id> OppIds = new set<Id>();
    public set<Id> accountIds = new set<Id>();
    public Exception[] errors = new Exception[0];
    public List<Endpoint_Configuration__mdt> edwMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EDW_Integration'];
    public Integer Year = Date.Today().Year();
    public Boolean testClassException;
    public class OppException extends Exception {}
    //Id branchAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Account').getRecordTypeId();
    //Id orgAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pella Account').getRecordTypeId();
    public list<Id> recordTypes = new list<Id>();
    //Constructor to defined the value and use within the batch publicly
    public HistoricalEDWAccountFeed(dateTime validFrom,dateTime validTo,string TxnId,set<Id> OppIds,boolean testClassException , set<Id> accountIds) {
        testClassException=testClassException;
        adlId=TxnId;
        this.OppIds=OppIds;
        this.accountIds = accountIds;
        this.validToDate=validTo;
        this.validFromDate=validFrom;
        header='SalesforcePartyAccountID|OraclePartyID|SalesforceBranchAccountID|ContractorProgramLevel|Program Change Date|SalesforceOwnerId|OwnerEBSUSername|MeetingFrequency|PCCID|"Year"|BranchNumber|YTDSaleS|YTDAssociatedSales|AccountRank|AccountStatus|PriorYear|PYSales|PYAssociatedSales|PYAccountRank|PYAccountStatus|PPY|PPYSales|PPYAssociatedSales|PPYAccountRank|PPYAccountStatus|Name|IdentifyingStreet|IdentifyingCity|IdentifyingState|IdentifyingCountry|IdentifyingZipcode|CreatedDate|PartyType';
        squery='SELECT mdmrecid__c,ParentId,Id,Contractor_Program_Level__c,CPC_Change_Date__c,OwnerId,Owner.EBS_Username__c,Meeting_Frequency__c,PCC_ID__c,Primary_Branch_Number_Owner__c,branch__r.T_C_Branch_Number__c, YTD_Sales__c,YTD_Associated_Sales__c,Account_Rank__c,Account_state__c,Prior_Year__c,PY_Sales__c,PY_Associated_Sales__c,PY_Account_Rank__c,PY_Account_Status__c,Prior_Prior_Year__c,PPY_Sales__c,PPY_Associated_Sales__c,PPY_Account_Rank__c,PPY_Account_Status__c,Name,Parent.BillingStreet,Parent.BillingCity,Parent.BillingState,Parent.BillingCountry,Parent.BillingPostalCode,CreatedDate,Parent.mdmrecid__c,RecordType.Name,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingCountry,PersonMailingPostalcode,type FROM Account where Id IN :accountIds';
    }
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(squery);
        
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        try{ 
            /*if(string.isBlank(finalstr)){
                finalstr = header ;
            }*/
            system.debug('Account Scope Is'+scope);
            List<ContentVersion> lstContentVersion = new List<ContentVersion>();
            if(string.isBlank(newAdlId)){
                finalstr = header;
            }else{
                lstContentVersion = [SELECT Title,VersionData,ContentDocumentId,ContentSize FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true];
                if(lstContentVersion != null && !lstContentVersion.isEmpty()){
                    if(lstContentVersion[0].ContentSize > 1572864)
                        finalstr = header;
                    else
                        finalstr = '';
                }
            }
            fileRow = '';
            for(Account objAcc : scope){
                fileRow = '';
                /*if(objAcc.RecordType.Name == 'Person Account'){
                    fileRow = fileRow+'"'+objAcc.Id+ '"';
                }else{
                    if(objAcc.ParentId!=null)
                        fileRow = fileRow+'"'+objAcc.Id+ '"';
                else
                        fileRow = '';
                } */
                fileRow = fileRow+'""';
                    
                
                //fileRow = (objAcc.ParentId!=null?objAcc.ParentId:'')+ '"';
                if(objAcc.RecordType.Name == 'Branch Account'){
                    system.debug('This is Branch' + objAcc.Id);
                    fileRow = fileRow +'|"'+(objAcc.Parent.mdmrecid__c!=null?objAcc.Parent.mdmrecid__c:'')+ '"';
                }else{
                    fileRow = fileRow +'|"'+(objAcc.mdmrecid__c!=null?objAcc.mdmrecid__c:'')+ '"';
                }
                //fileRow = fileRow +'|"'+(objAcc.ParentId!=null?objAcc.ParentId:'')+ '"';
                /*if(objAcc.RecordType.Name == 'Person Account'){
                    fileRow = fileRow +'|"'+(objAcc.Id!=null?objAcc.Id:'')+ '"';
                }else{
                    fileRow = fileRow +'|"'+(objAcc.Id!=null?objAcc.Id:'')+ '"';
                }*/
                fileRow = fileRow +'|"'+(objAcc.Id != null?objAcc.Id:'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Contractor_Program_Level__c!=null?objAcc.Contractor_Program_Level__c:'').replace('"','')+ '"';
                fileRow = fileRow +'|"'+(objAcc.CPC_Change_Date__c!=null?String.valueOf(objAcc.CPC_Change_Date__c):'')+ '"';
               // fileRow = fileRow +'|"'+(objAcc.CPC_Change_Date__c!=null?String.valueOf(objAcc.CPC_Change_Date__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.OwnerId!=null?objAcc.OwnerId:'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Owner.EBS_Username__c!=null?objAcc.Owner.EBS_Username__c:'').replace('"','')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Meeting_Frequency__c!=null?objAcc.Meeting_Frequency__c:'').replace('"','')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PCC_ID__c!=null?objAcc.PCC_ID__c:'')+ '"';
                //fileRow = fileRow +'|"'+(objAcc.Prior_Year__c!=null?'2020':'')+ '"';
                //fileRow = fileRow +'|"'+(year!=null?String.valueOf():'')+ '"';
                 fileRow = fileRow +'|"'+(objAcc.Prior_Year__c!=null?string.valueof(integer.valueof( objAcc.Prior_Year__c)+1):'')+ '"';
                
               // fileRow = fileRow +'|"'+(objAcc.Primary_Branch_Number_Owner__c!=null?objAcc.Primary_Branch_Number_Owner__c:'').replace('"','')+ '"';
                if(objAcc.RecordType.Name == 'Branch Account'){
                    //system.debug('This is Branch' + objAcc.Id);
                    //fileRow = fileRow +'|"'+(objAcc.Parent.mdmrecid__c!=null?objAcc.Parent.mdmrecid__c:'')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.Branch__r.T_C_Branch_Number__c!=null?objAcc.Branch__r.T_C_Branch_Number__c:'').replace('"','')+ '"';                     
                }else{
                    fileRow = fileRow +'|"'+(objAcc.Primary_Branch_Number_Owner__c!=null?objAcc.Primary_Branch_Number_Owner__c:'').replace('"','')+ '"';
                } 
                fileRow = fileRow +'|"'+(objAcc.YTD_Sales__c!=null?String.valueOf(objAcc.YTD_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.YTD_Associated_Sales__c!=null?String.valueOf(objAcc.YTD_Associated_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Account_Rank__c!=null?objAcc.Account_Rank__c:'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Account_State__c!=null?objAcc.Account_state__c:'').replace('"','')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Prior_Year__c!=null?objAcc.Prior_Year__c:'')+ '"';
                //fileRow = fileRow +'|"'+(objAcc.Prior_Year__c!=null?'2019':'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PY_Sales__c!=null?String.valueOf(objAcc.PY_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PY_Associated_Sales__c!=null?String.valueOf(objAcc.PY_Associated_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PY_Account_Rank__c!=null?objAcc.PY_Account_Rank__c:'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PY_Account_Status__c!=null?objAcc.PY_Account_Status__c:'').replace('"','')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Prior_Prior_Year__c!=null?objAcc.Prior_Prior_Year__c:'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PPY_Sales__c!=null?String.valueOf(objAcc.PPY_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PPY_Associated_Sales__c!=null?String.valueOf(objAcc.PPY_Associated_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PPY_Account_Rank__c!=null?objAcc.PPY_Account_Rank__c:'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.PPY_Account_Status__c!=null?objAcc.PPY_Account_Status__c:'').replace('"','')+ '"';
                
                //fileRow = fileRow +'|"'+(objOpp.Name!=null?'"'+objOpp.Name+'"':'')+ '"';
                
                fileRow = fileRow +'|"'+(objAcc.Name!=null?''+objAcc.Name+'':'').replace('"','')+ '"';
                if(objAcc.RecordType.Name == 'Branch Account'){
                    fileRow = fileRow +'|"'+(objAcc.Parent.BillingStreet!=null?objAcc.Parent.BillingStreet:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.Parent.BillingCity!=null?objAcc.Parent.BillingCity:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.Parent.BillingState!=null?objAcc.Parent.BillingState:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.Parent.BillingCountry!=null?objAcc.Parent.BillingCountry:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.Parent.BillingPostalCode!=null?objAcc.Parent.BillingPostalCode:'').replace('"','')+ '"';
                }else{
                    fileRow = fileRow +'|"'+(objAcc.PersonMailingStreet!=null?objAcc.PersonMailingStreet:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.PersonMailingCity!=null?objAcc.PersonMailingCity:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.PersonMailingState!=null?objAcc.PersonMailingState:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.PersonMailingCountry!=null?objAcc.PersonMailingCountry:'').replace('"','')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.PersonMailingPostalCode!=null?objAcc.PersonMailingPostalCode:'').replace('"','')+ '"';
                }
                
                fileRow = fileRow +'|"'+(objAcc.CreatedDate!=null?String.valueOf(objAcc.CreatedDate):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.type!=null?String.valueOf(objAcc.type):'')+ '"';
                finalstr+= '\n'+fileRow;
                fileRow = '';
            }
            system.debug('finalstr In account:: ' + finalstr);
            if(String.isBlank(newAdlId)){
                Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
                objApex.Account__c=true;
                objApex.Apex_Class__c='AccountBatchprocess';
                objApex.Method__c='GET';
                objApex.Type__c='Information';
                objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
                if(String.isBlank(finalstr))
                    objApex.Message__c = 'No Record Found on Account';
                insert objApex;
                newAdlId = objApex.Id;
                objApex.EDW_Transaction_ID__c=objApex.Id;
                update objApex;
                //String csvname= 'Opportunity-'+ objApex.Id +'-'+'currentDate_'+'.csv';
                
                String csvname= 'Account-'+ objApex.Id +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
                
                if(lstContentVersion != null && lstContentVersion[0].ContentSize > 1572864){
                    //Insert the csv file in File object
                    //String csvname= 'Opportunity-'+ objApex.Id +'-'+'currentDate_'+'.csv';
                    String csvname= 'Account-'+ newAdlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Account Test exception');
            }
        }catch(Exception e) {
            system.debug('Error is' + e.getStackTraceString());
            system.debug('Error is' + e.getMessage());
            system.debug('Error is' + e.getLineNumber());
            errors.add(e);
            string allExeError = string.join(errors,',');
            isError = true;
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Account__c=true;
            objApexExe.Apex_Class__c='AccountBatchprocess';
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
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        //String cummulativeResponse = '';
        try{
            if(String.isNotBlank(newAdlId)){
                objApex = [SELECT Id FROM Apex_Debug_Log__c WHERE Id =: newAdlId LIMIT 1];
              //  QuoteBatchprocess objExecuteProcess = new QuoteBatchprocess(validFromDate,validToDate,objApex.Id,OppIds);
           // Database.executeBatch( objExecuteProcess, Integer.valueOf(Label.EDW_Batch_Size));
                /*List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :newAdlId];
                Set<Id> ContentDocumentIdSet = new Set<Id>();
                for(ContentDocumentLink temp : cdlList){
                    ContentDocumentIdSet.add(temp.ContentDocumentId);
                }
                if (!ContentDocumentIdSet.isEmpty()) {
                    for (ContentVersion conVer : [SELECT Title,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :ContentDocumentIdSet AND IsLatest = TRUE] ) {
                        system.debug('Data there is' + conVer.Title);
                        String responseBody;
                        String Filename= 'Account-'+ adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+'.csv';
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
                        if(response.getStatus() == 'SUCCESS' && response.getStatusCode() == 200)
                            responseBody = response.getBody();
                        else
                            responseBody = response.getBody();
                        if(String.isNotBlank(responseBody))
                            cummulativeResponse = cummulativeResponse+responseBody;
                    }
                }
                objApex.Message__c = cummulativeResponse;
                update objApex;*/
            }//end of newAdlId not null
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Account Test exception');
            }
        }catch(Exception e) {
            system.debug('Line  is :: ' + e.getLineNumber());
            system.debug('Message is :: ' + e.getMessage());
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Account__c=true;
            objApexErr.Apex_Class__c='AccountBatchprocess';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            if(String.isBlank(finalstr))
                objApexErr.Message__c = 'No Record Found on Account';
            
            insert objApexErr;
        }
       finally{
            //Calling batch process for next object
            HistoricalEDWQuoteFeed objExecuteProcess = new HistoricalEDWQuoteFeed(validFromDate,validToDate,objApex.Id,OppIds);
            Database.executeBatch( objExecuteProcess, Integer.valueOf(Label.EDW_Batch_Size));
        }
        
        
    }
    
}