global without sharing class SyncEBSContactsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{   
    global String query ; 
    global SyncEBSContactsBatch() {
        query = 'select account.recordtype.name , id , Org_Contact_ID__c, name from contact where account.recordtype.name = \'Pro_Lowes\' and org_contact_id__c = null' ;

       // if(!Test.isRunningTest()) query += ' AND Create_Quote_Shell__c = TRUE ' ; 
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        
        for(contact con : (List<contact>)scope )
        {
            try
            {

                
                EBSRestCallout.createUpdateContactToEBSData(con.id);
                
            }
            catch(Exception ex){ 
                new ApexDebugLog().createLog( new ApexDebugLog.Error( 'SyncEBSContactsBatch', 'contactSync', con.Id, ex, 'Integration' ));
            }
        }
        
        
    }

    global void finish(Database.BatchableContext BC) {

    }


}