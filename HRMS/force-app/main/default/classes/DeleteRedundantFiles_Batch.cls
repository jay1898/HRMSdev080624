public class DeleteRedundantFiles_Batch implements Database.Batchable<sObject>,Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('select Id, Title, ContentDocumentId, From_App_fileupload__c, IsLinkedWithCandidate__c from ContentVersion where From_App_fileupload__c = \'RECRUITMENT_WEBSITE\' and IsLinkedWithCandidate__c = false limit 50000');
    }
    public void execute(Database.BatchableContext bc, List<ContentVersion> records){
        List<Id> Ids = new List<Id>();
        for(ContentVersion cv: records)
        {
         	Ids.add(cv.ContentDocumentId);   
        }
        // process each batch of records
        List<ContentDocument> cdList = [select id from contentDocument where Id IN :Ids];
        System.debug('Found File '+cdList.size());
        delete cdList;
        System.debug('Delete Record Success from batch');
    }
    public void finish(Database.BatchableContext bc){
        
    }
    public void execute(SchedulableContext sc){
        DeleteRedundantFiles_Batch batchInstance = new DeleteRedundantFiles_Batch();
        Database.executeBatch(batchInstance,200);
    }
}