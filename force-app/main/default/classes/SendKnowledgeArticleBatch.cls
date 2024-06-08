public class SendKnowledgeArticleBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String KNOWLEDGE_PUBLISH_STATUS = 'Online';
        return Database.getQueryLocator('Select Id from Knowledge__kav where PublishStatus =: KNOWLEDGE_PUBLISH_STATUS AND LastModifiedDate = TODAY'); 
    }


    public void execute(Database.BatchableContext BC, List<Knowledge__kav> scope){
        for(Knowledge__kav knowledgeObj : scope) {
            SendKnowledgeArticleAPI.sendKnowledgeArticle(knowledgeObj.Id);
        }
    }


    public void finish(Database.BatchableContext BC){
    }

}