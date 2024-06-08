global class Batch_DeleteExpiredPost_Notification Implements Database.Batchable<sObject>,Schedulable, Database.stateful, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator( 'SELECT Id,CreatedDate, Active__c, Description__c, Employee__c, Expiration_Date__c, Type__c, Content__c, Announced_by__c, Announced_by__r.Name  FROM Notification__c  WHERE Type__c = \'Post\'  AND  (Expiration_Date__c  != Null OR Expiration_Date__c < TODAY ) ORDER BY CreatedDate DESC' );
    }
    global void execute(Database.BatchableContext bc, List<Notification__c> notificationRecords)
    {   
        Set<Id> notificationIdSet = new Set<Id>();
        if(notificationRecords.size() > 0){
            for(Notification__c rec: notificationRecords){
                notificationIdSet.add(rec.Id);
            }
            if(!notificationIdSet.isEmpty()){
                Set<Id> ContentDocumentIds = new Set<Id>();
                List<ContentDocumentLink> recordFilesList = [Select Id, ContentDocumentId from ContentDocumentLink where LinkedEntityId IN :notificationIdSet];
                if(recordFilesList.size()>0){
                    for(ContentDocumentLink recordCDL : recordFilesList){
                        ContentDocumentIds.add(recordCDL.ContentDocumentId);
                    }
                    delete recordFilesList;
                    if(!ContentDocumentIds.isEmpty()) {
                        List<ContentDocument> documentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :ContentDocumentIds];
                        if(documentsToDelete.size()>0) {
                            delete documentsToDelete;
                        }
                    }
                }
            }
            delete notificationRecords;
        }
    }
    global void finish(Database.BatchableContext bc)
    {
    }
    global void execute(SchedulableContext sc) {
        Batch_DeleteExpiredPost_Notification b = new Batch_DeleteExpiredPost_Notification(); 
        database.executebatch(b,200);
    }

}