public class EDWYearEndFeed implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    //Declaration Of variables to use publicly
    public dateTime validToDate;
    Public string recType='Branch Account'; 
    public dateTime validFromDate;
    public List<Account> lstAccount = new List<Account>() ;
     public list<String> fieldSet = new list<String>();
    public Map<String,EDW_Object_Mapping__mdt> edwmap;
    public List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
    public String generatedCSVFile ='';
    public dateTime currentDate= system.now();
    public string squery;
    public string header='SalesforcePartyAccountID|OraclePartyID|SalesforceBranchAccountID|ContractorProgramLevel|Program Change Date|SalesforceOwnerId|OwnerEBSUSername|MeetingFrequency|PCCID|"Year"|BranchNumber|YTDSaleS|YTDAssociatedSales|AccountRank|AccountStatus|PriorYear|PYSales|PYAssociatedSales|PYAccountRank|PYAccountStatus|PPY|PPYSales|PPYAssociatedSales|PPYAccountRank|PPYAccountStatus|Name|IdentifyingStreet|IdentifyingCity|IdentifyingState|IdentifyingCountry|IdentifyingZipcode|CreatedDate|PartyType';
    public string finalstr;
    public string adlId;
    String newAdlId;
    String contentDocumentId;

    Boolean isError = false;
    public String fileRow = '';
    public set<Id> OppIds = new set<Id>();
    public set<Id> allaccountIds = new set<Id>();
    
    public Exception[] errors = new Exception[0];
    public List<Endpoint_Configuration__mdt> edwMetaData = [SELECT Endpoint__c,Token__c,DeveloperName FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EDW_Integration'];
    public Integer Year = Date.Today().Year();
    public Boolean testClassException;
    public class OppException extends Exception {}
    //Id branchAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Account').getRecordTypeId();
    //Id orgAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pella Account').getRecordTypeId();
    public list<Id> recordTypes = new list<Id>();
    //Constructor to defined the value and use within the batch publicly
 
    //Start method of the batch to return the result
    public Database.QueryLocator start(Database.BatchableContext bc){
     squery='SELECT mdmrecid__c,ParentId,Id,Contractor_Program_Level__c,CPC_Change_Date__c,OwnerId,Owner.EBS_Username__c,Meeting_Frequency__c,PCC_ID__c,Primary_Branch_Number_Owner__c,Branch__r.T_C_Branch_Number__c, YTD_Sales__c,YTD_Associated_Sales__c,Account_Rank__c,Account_state__c,Prior_Year__c,PY_Sales__c,PY_Associated_Sales__c,PY_Account_Rank__c,PY_Account_Status__c,Prior_Prior_Year__c,PPY_Sales__c,PPY_Associated_Sales__c,PPY_Account_Rank__c,PPY_Account_Status__c,Name,Parent.BillingStreet,Parent.BillingCity,Parent.BillingState,Parent.BillingCountry,Parent.BillingPostalCode,CreatedDate,Parent.mdmrecid__c,RecordType.Name,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingCountry,PersonMailingPostalCode,type FROM Account WHERE RecordType.Name=:recType';
        return Database.getQueryLocator(squery);       
    }
    //Execute method of batch to process all the logic needs to be processed
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        try{ 
            
            if(string.isBlank(newAdlId)){
                finalstr = header;
            }else{
                List<ContentVersion> lstContentVersion = [SELECT Title,VersionData,ContentDocumentId,ContentSize FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true];
                if(lstContentVersion != null && !lstContentVersion.isEmpty()){
                    if(lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size) )
                        finalstr = header;
                    else
                        finalstr = '';
                }
                
            }
            for(Account objAcc : scope){
                String fileRow='';
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
                 if(objAcc.RecordType.Name == 'Branch Account'){
                    //system.debug('This is Branch' + objAcc.Id);
                    //fileRow = fileRow +'|"'+(objAcc.Parent.mdmrecid__c!=null?objAcc.Parent.mdmrecid__c:'')+ '"';
                    fileRow = fileRow +'|"'+(objAcc.Branch__r.T_C_Branch_Number__c!=null?objAcc.Branch__r.T_C_Branch_Number__c:'').replace('"','')+ '"';                     
                }else{
                    fileRow = fileRow +'|"'+(objAcc.Primary_Branch_Number_Owner__c!=null?objAcc.Primary_Branch_Number_Owner__c:'').replace('"','')+ '"';
                }
                //fileRow = fileRow +'|"'+(objAcc.Primary_Branch_Number_Owner__c!=null?objAcc.Primary_Branch_Number_Owner__c:'').replace('"','')+ '"';
                fileRow = fileRow +'|"'+(objAcc.YTD_Sales__c!=null?String.valueOf(objAcc.YTD_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.YTD_Associated_Sales__c!=null?String.valueOf(objAcc.YTD_Associated_Sales__c):'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Account_Rank__c!=null?objAcc.Account_Rank__c:'')+ '"';
                fileRow = fileRow +'|"'+(objAcc.Account_state__c!=null?objAcc.Account_state__c:'').replace('"','')+ '"';
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
                if(String.isNotBlank(fileRow))
                    finalstr+= '\n'+fileRow;
                fileRow = '';
            }
            system.debug('finalstr In account:: ' + finalstr);
            if(String.isBlank(newAdlId)){
                Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
                objApex.Account__c=true;
                objApex.Apex_Class__c='DailyEDWAccountFeed';
                objApex.Method__c='GET';
                objApex.Type__c='Information';
                objApex.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
                if(String.isBlank(finalstr))
                    objApex.Message__c = 'No Record Found on Account';
                insert objApex;
                newAdlId = objApex.Id;
                objApex.EDW_Transaction_ID__c=adlId;
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
                List<ContentVersion> lstContentVersion = [SELECT Title,VersionData,ContentDocumentId,ContentSize FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId And IsLatest=true];
                
                if(lstContentVersion != null && lstContentVersion[0].ContentSize >  Integer.valueOf(Label.EDW_Max_File_Size)){
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
            finalstr = '';

            if(Test.isRunningTest() && testClassException){
                throw new OppException('Account Test exception');
            }
        }catch(Exception e) {
            system.debug('Error is' + e.getStackTraceString());
            system.debug('Error is' + e.getMessage());
            system.debug('Error is' + e.getLineNumber());
            errors.add(e);
            List<String> accIds=new List<String>();
            for(Account objAcc : scope){
                oppIds.add(objAcc.Id);
            }
            string allExeError = string.join(errors,',');
            isError = true;
            Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
            objApexExe.Account__c=true;
            objApexExe.Apex_Class__c='DailyEDWAccountFeed';
            objApexExe.Method__c='GET';
            objApexExe.Type__c='Error';
            objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+allExeError;
            objApexExe.Stack_Trace__c=e.getStackTraceString();
            objApexExe.Message__c = e.getMessage()+ ' '+string.join(accIds,',');
            insert objApexExe;
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        
        // Code to do the POST Request
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        String cummulativeResponse = 'Records Processed:' +allaccountIds.size();
        Integer cnt =0;
        try{
            if(String.isNotBlank(newAdlId)){
                objApex = [SELECT Id FROM Apex_Debug_Log__c WHERE Id =: newAdlId LIMIT 1];
                //  QuoteBatchprocess objExecuteProcess = new QuoteBatchprocess(validFromDate,validToDate,objApex.Id,OppIds);
                // Database.executeBatch( objExecuteProcess, Integer.valueOf(Label.EDW_Batch_Size));
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
                        String Filename= 'Account-'+ adlId +'-'+String.valueOf(currentDate).replace(' ' , '_')+String.valueOf(cnt)+'.csv';
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
                objApex.Message__c = cummulativeResponse ;
                If (isError)
                    objApex.type__c = 'Error';
                Else
                	objApex.type__c = 'Complete';
                
                update objApex;
            }//end of newAdlId not null
            
            // check all the batch job finish successfully or not
          /*  List<AsyncApexJob> listAsyncApex=[SELECT ApexClass.Name,JobType, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate,ExtendedStatus, Id FROM AsyncApexJob Where jobtype='BatchApex' and apexclass.name='DailyEDWAccountFeed' order by createddate desc limit 1];
            system.debug('@@'+JSON.serialize(listAsyncApex));
            if(listAsyncApex.size()>0){
                if(listAsyncApex[0].NumberOfErrors>0 || listAsyncApex[0].ExtendedStatus!=null ){
                    Apex_Debug_Log__c objApexExe = new Apex_Debug_Log__c();
                    objApexExe.Opportunity__c=true;
                    objApexExe.Apex_Class__c='DailyEDWAccountFeed';
                    objApexExe.Method__c='GET';
                    objApexExe.Type__c='Error';
                    objApexExe.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate+'\n'+'AsyncApexJob Id :'+listAsyncApex[0].Id;
                    objApexExe.Stack_Trace__c='Some Exception which can not handle '+listAsyncApex[0].ExtendedStatus;
                    objApexExe.Message__c ='No Of Failed Batch '+listAsyncApex[0].NumberOfErrors ;
                    objApex.EDW_Transaction_ID__c=adlId;
                    insert objApexExe;
                }
            }*/
            
            if(Test.isRunningTest() && testClassException){
                throw new OppException('Account Test exception');
            }
                
        }catch(Exception e) {
            system.debug('Line  is :: ' + e.getLineNumber());
            system.debug('Message is :: ' + e.getMessage());
            Apex_Debug_Log__c objApexErr = new Apex_Debug_Log__c();
            objApexErr.Account__c=true;
            objApexErr.Apex_Class__c='DailyEDWAccountFeed';
            objApexErr.Method__c='GET';
            objApexErr.Type__c='Error';
            objApexErr.Record_Id__c='validFrom='+validFromDate+'&validTo='+validToDate;
            objApexErr.Stack_Trace__c=string.valueOf(e);
            objApex.EDW_Transaction_ID__c=adlId;
            if(String.isBlank(finalstr))
            {
                objApexErr.Message__c = 'No Record Found on Account';
                objApexErr.Type__c='Information';
            }
            
            insert objApexErr;
        }
        finally{
            //Calling batch process for next object
            system.debug('Complete');
        }
        
        
    }
    
}