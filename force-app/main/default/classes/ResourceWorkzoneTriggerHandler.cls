public class ResourceWorkzoneTriggerHandler implements ITrigger{

    public static Boolean RUN_TRIGGER   = true;

    public ResourceWorkzoneTriggerHandler() {

    }

    public void bulkBefore() {
       ResourceWorkzoneTriggerHandlerService.prepareDataBeforeEvent(Trigger.new);
    }


    public void bulkAfter() {
       ResourceWorkzoneTriggerHandlerService.prepareDataAfterEvent(Trigger.new);
    }


    public void beforeInsert(List<Resource_Workzone__c> newList) {
    }

    
    public void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id, SObject> oldCaseMap) {
    }


    public void beforeDelete(List<Resource_Workzone__c> oldRecords, Map<ID, SObject> oldRecordMap) {

    }

    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 23 May 2023
    *   Purpose         : Method to be called on After Insert event.
    *   Input Param     : List of Case.
    *   Output Param    : void
    */
    public void afterInsert(List<Resource_Workzone__c> newList, Map<Id, SObject> newWZMap) {
        Map<Id,Resource_Workzone__c> newMap = (Map<Id,Resource_Workzone__c>) newWZMap;
        ResourceWorkzoneTriggerHandlerService.createWZZipCodeCoverageRecords(newList);
        
    }


    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    }


    public void afterDelete(List<Resource_Workzone__c> oldRecords, Map<ID, SObject> oldRecordMap) {
        ResourceWorkzoneTriggerHandlerService.deleteRelatedZipCodeCoverage(oldRecords);
    }

    
    public void andFinally(List<Resource_Workzone__c> newList, Map<ID, SObject> newMap) {
    }
}