@isTest
public class KnowledgeTriggerTest {
    
    @TestSetup
    static void makeData(){
        knowledge__kav newArticle = new knowledge__kav(Title='test',summary='xyz',urlname='xyz', Question__c = 'test', Answer__c = 'test');
        insert newArticle;
        insert new Content_Stack_API_Details__c(Knowledge_Article_URL__c = 'www.test.com', Authorization__c = 'test', API_Key__c = 'test');
    }


    @isTest
    static void testArticlePublishAPI() {
        Test.setMock(HttpCalloutMock.class, new TechseeMockResponseGenrator());
        Test.startTest();
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav LIMIT 1];
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        Database.executeBatch(new SendKnowledgeArticleBatch(), 1);
        Test.stopTest();
    }
}