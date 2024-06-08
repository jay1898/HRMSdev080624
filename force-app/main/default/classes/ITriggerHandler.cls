public interface ITriggerHandler {

     void BeforeInsert(List<SObject> newItems);
 
    void BeforeUpdate(List<SObject> newItems,Map<Id, SObject> newItemMap, Map<Id, SObject> oldItems);
 
    void BeforeDelete(Map<Id, SObject> oldItems);
 
    void AfterInsert(Map<Id, SObject> newItems);
 
    void AfterUpdate(List<SObject> newItems,Map<Id, SObject> newItemMap, Map<Id, SObject> oldItems);
 
    void AfterDelete(Map<Id, SObject> oldItems);
 
    void AfterUndelete(Map<Id, SObject> oldItems);
}