public class KnowledgeTriggerHandler implements ITrigger{
    public static Boolean RUN_TRIGGER   = true;

    public KnowledgeTriggerHandler() {

    }

    public void bulkBefore() {
        KnowledgeTriggerHandlerService.prepareDataBeforeEvent(Trigger.new);
    }


    public void bulkAfter() {
        KnowledgeTriggerHandlerService.prepareDataAfterEvent(Trigger.new);
    }


    public void beforeInsert(List<Knowledge__kav> newList) {
       
    }


    public void beforeUpdate(Map<Id,SObject> newMap, Map<Id, SObject> oldMap) {
    }


    public void beforeDelete(List<Knowledge__kav> oldRecords, Map<ID, SObject> oldRecordMap) {

    }


    public void afterInsert(List<Knowledge__kav> newList, Map<Id, SObject> newMap) {
        
    }


    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
//        KnowledgeTriggerHandlerService.sendPublishedArticleToContentstack((Map<Id,Knowledge__kav>) newMap, (Map<Id,Knowledge__kav>) oldMap);
    }


    public void afterDelete(List<Knowledge__kav> oldRecords, Map<ID, SObject> oldRecordMap) {
    }


    public void andFinally(List<Knowledge__kav> newList, Map<ID, SObject> newMap) {

    }
}