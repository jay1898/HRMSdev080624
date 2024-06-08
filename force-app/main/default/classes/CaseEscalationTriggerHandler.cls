public class CaseEscalationTriggerHandler implements ITrigger{
    
    public CaseEscalationTriggerHandler() {
    }


    public void bulkBefore() {
        CaseEscalationTriggerService.prepareDataBeforeEvent(Trigger.new);
    }


    public void bulkAfter() {
        CaseEscalationTriggerService.prepareDataAfterEvent(Trigger.new);
    }


    public void beforeInsert(List<Case_Escalation__c> newList) {
        
    }


    public void beforeUpdate(Map<Id,SObject> newCaseEscMap, Map<Id, SObject> oldCaseEscMap) {
    }


    public void beforeDelete(List<Case_Escalation__c> oldRecords, Map<ID, SObject> oldMap) {
    }


    public void afterInsert(List<Case_Escalation__c> newList, Map<Id, SObject> newMap) {
        CaseEscalationTriggerService.updateCaseEscalationCount(newList,null,true,false,false);  
    }


    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        CaseEscalationTriggerService.updateCaseEscalationCount((List<Case_Escalation__c>)newMap.values(),(Map<Id,Case_Escalation__c>)oldMap,false,true,false);
    }


    public void afterDelete(List<Case_Escalation__c> oldRecords, Map<ID, SObject> oldMap) {
        CaseEscalationTriggerService.updateCaseEscalationCount(oldRecords,(Map<Id,Case_Escalation__c>)oldMap,false,false,true);
    }


    public void andFinally(List<Case_Escalation__c> newList, Map<ID, SObject> newMap) {
    }
}