/*
Created By      : Rahul Sangwan
Created Date    : 1 Sept 2023
Purpose         : This is a Service Class for KnowledgeTriggerHandler. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class KnowledgeTriggerHandlerService implements ITriggerService{
    
    public static void prepareDataBeforeEvent(List<Knowledge__kav> newList) {
        
    }


    public static void prepareDataAfterEvent(List<Knowledge__kav> newList) {
    }


    public static void sendPublishedArticleToContentstack(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {
        Set<Id> knowledgeIdSet      = new Set<Id>();
        for(Knowledge__kav knowledgeObj : newMap.values()) {
            if(knowledgeObj.PublishStatus == Constant.KNOWLEDGE_PUBLISH_STATUS && oldMap.get(knowledgeObj.Id).PublishStatus != knowledgeObj.PublishStatus) {
                knowledgeIdSet.add(knowledgeObj.Id);
            }
        }
        if(!knowledgeIdSet.isEmpty()) {
            sendArticles(knowledgeIdSet);
        }
    }


    @future(callout = true)
    static void sendArticles(Set<Id> knowledgeIdSet) {
        for(Id knowledgeId : knowledgeIdSet) {
            if(Limits.getLimitCallouts() > 0)
            SendKnowledgeArticleAPI.sendKnowledgeArticle(knowledgeId);
        }
    }

}