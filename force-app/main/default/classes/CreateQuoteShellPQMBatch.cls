global without sharing class CreateQuoteShellPQMBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable
{   
    global String query ; 
    global CreateQuoteShellPQMBatch() {
        query = 'SELECT Id,Account.recordType.DeveloperName,Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c, Account.Legacy_Party_Id__c,RecordTypeId,RecordType.DeveloperName,Account.Parent.Mdmrecid__c,Account.parent.BillingStreet,'+
            'Account.parent.BillingCity,Account.parent.BillingState,Business_Segment__c,BusinessSegment__c,Account.parent.BillingPostalCode,'+
            'Account.parent.BillingCountry,Account.Branch__r.Branch_Number__c,Account.Branch__r.T_C_Branch_Number__c, Account.PersonMailingStreet,'+
            ' Account.PersonMailingCity, Account.PersonMailingState, Account.Mdmrecid__c, Quote_Number_Shell__c, '+
            ' Account.PersonMailingPostalCode, Account.PersonMailingCountry, Account.Account_Status__c, Owner.LastName, Owner.FirstName, ' + 
            ' Description, CreatedDate, LastModifiedDate, Name, Owner.EBS_UserName__c, Account_Branch_Profile__r.Branch__r.Branch_Number__c, Create_Quote_Shell__c' + 
            ' FROM Opportunity ' + 
            ' WHERE Quote_Number_Shell__c = NULL AND PQM_Quote_Shell_Error_Message__c = NULL ' + 
            ' AND StageName = \'Active\' AND Status__c = \'Active\' AND Party_ID__c != NULL ' ;

        if(!Test.isRunningTest()) query += ' AND Create_Quote_Shell__c = TRUE ' ; 
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(System.SchedulableContext sc){
        Database.executeBatch(new CreateQuoteShellPQMBatch(), 1 );
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        
        for(Opportunity opp : (List<Opportunity>)scope )
        {
            try
            {

                System.debug('UAC: opp ' + opp);
                
                String prettyJSON =  OpportunityTriggerHandler.createJSONForPQM(opp);

                // Get end point from metadata settings 
                List<Endpoint_Configuration__mdt> qsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'QuoteShell' ]; 
                // Create a new HTTP request and post Opportunity info
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(qsMetaData[0].Endpoint__c);
                request.setMethod('POST');
                request.setHeader('Authorization', 'Bearer '+qsMetaData[0].Token__c);
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(120000);
                request.setBody(prettyJSON);
                
                HttpResponse response = http.send(request);
                // If not posted successfully then retry one more time
                if(response.getStatusCode() != 200) 
                {
                    response = http.send(request);
                    if(response.getStatusCode() != 200) 
                    {
                        new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'postToPQMFuture', prettyJSON, 'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(), null, 'Integration' ));
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        OpportunityTriggerHandler.RUN_TRIGGER = false ;
                        update new Opportunity(Id=opp.Id, PQM_Quote_Shell_Error_Message__c = response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody() );
                    }
                }else
                {
                    new ApexDebugLog().createLog( new ApexDebugLog.Information( 'OpportunityTriggerHandler', 'postToPQMFuture', prettyJSON, 'Success', 'Integration' ));
                    OpportunityTriggerHandler.EBSWrapper EW=(OpportunityTriggerHandler.EBSWrapper) JSON.deserialize(response.getBody(), OpportunityTriggerHandler.EBSWrapper.class);
                    Opportunity opportunity=new Opportunity();
                    opportunity.Id=opp.Id;
                    opportunity.Quote_Number_Shell__c=EW.QuoteNumber;
                    opportunity.Create_Quote_Shell__c = TRUE ;
                    update opportunity;
                    
                }
                System.debug('UAC: response ' + response.getBody() );
            }
            catch(Exception ex){ 
                new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'postToPQMFuture', opp.Id, ex, 'Integration' ));
            }
        }
        
        
    }

    global void finish(Database.BatchableContext BC) {

    }
}