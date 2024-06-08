/*
Created By      : Subhash Panchani
Created Date    : 28 July 2023
Purpose         : This is a trigger handler for sObject Case Quick Text to perform required operations.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseQuickTextTriggerHandler implements ITrigger{
    Public static Boolean RUN_TRIGGER = TRUE ;
    
    public CaseQuickTextTriggerHandler() {
    }
    
    public void bulkBefore() {
    }
    
    public void bulkAfter() {
    }
    
    public void beforeInsert(List<Case_Quick_Text__c> casequickText) {
        try{
            CaseQuickTextTriggerHandlerService.checkNameQueueBeforeInsert(casequickText);
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('CaseQuickTextTriggerHandlerService', 'checkNameQueueBeforeInsert', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
    }
    public void beforeUpdate(Map<Id,SObject> newMap, Map<Id,SObject> oldMap) {
        try{
            CaseQuickTextTriggerHandlerService.checkNameQueueBeforeUpdate(newMap);
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('CaseQuickTextTriggerHandlerService', 'checkNameQueueBeforeUpdate', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        
    }
    
    public void beforeDelete(List<Case_Quick_Text__c> oldRecords, Map<ID, SObject> oldRecordMap) {
    }
    
    public void afterInsert(List<Case_Quick_Text__c> newList, Map<Id, SObject> newMap) {
    }
    
    public void afterUpdate(Map<Id, SObject> newCaseMap, Map<Id, SObject> oldCaseMap) {
    }
    
    public void afterDelete(List<Case_Quick_Text__c> oldRecords, Map<ID, SObject> oldRecordMap) {
    }
    
    public void andFinally(List<Case_Quick_Text__c> newList, Map<ID, SObject> newMap) {
    }
}