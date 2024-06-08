/*
Created By      : Rahul Sangwan
Created Date    : 10 July 2023
Purpose         : This is a Service Class for CaseEscalationTrigger. 
----------------------------------------------------------------------------------------------
Modified By     : Rahul Sangwan
Modified Date.  : 13th July
Purpose         : Added updateCaseEscalationOwner method.
----------------------------------------------------------------------------------------------
*/
public class CaseEscalationTriggerService implements ITriggerService{
    
    static List<QueueSobject> caseEscalationQueueList = new List<QueueSobject>();
    
    public static void prepareDataBeforeEvent(List<Case_Escalation__c> newList) {
        if(caseEscalationQueueList.isEmpty()) caseEscalationQueueList = CaseEscalationTriggerModel.getQueuesRelatedToCaseEscalation();
    }
    
    
    public static void prepareDataAfterEvent(List<Case_Escalation__c> newList) {
    }
    
    /*
    *   Created By      : Subhash Panchani
    *   Added on        : 25 September 2023
    *   Purpose         : This method will count total number of case escalations and update count to parent case
    *   User Story      : SCS-750
    */
    public static void updateCaseEscalationCount(List<Case_Escalation__c> newList,Map<id,Case_Escalation__c> oldCEMap,boolean afterInsert,boolean afterUpdate, boolean afterDelete){
        Set<Id> caseIdsToUpdate = new Set<Id>();
        
        if (afterInsert || afterUpdate) {
            for (Case_Escalation__c escalation : newList) {
                if (escalation.Case__c != null) {
                    if(afterUpdate && (oldCEMap.get(escalation.Id)).Case__c != escalation.Case__c){
                        caseIdsToUpdate.add(oldCEMap.get(escalation.Id).Case__c);
                    }
                    caseIdsToUpdate.add(escalation.Case__c);
                }
            }
        }
        
        if (afterDelete) {
            for (Case_Escalation__c escalation : oldCEMap.values()) {
                if (escalation.Case__c != null) {
                    caseIdsToUpdate.add(escalation.Case__c);
                }
            }
        }
        
        Map<Id, List<Case_Escalation__c>> caseIdToCountSum = new Map<Id, List<Case_Escalation__c>>();
        List<Case_Escalation__c> CEList=CaseEscalationTriggerModel.getCasesFromCaseEscalation(caseIdsToUpdate);
        for (Case_Escalation__c result : CEList) {
            if (!caseIdToCountSum.containsKey(result.Case__c)) {
                caseIdToCountSum.put(result.Case__c, new List<Case_Escalation__c>{result});
            }
            else{
                caseIdToCountSum.get(result.Case__c).add(result);
            }
        }
        // Update the Case records with the calculated SUM values
        List<Case> casesToUpdate = new List<Case>();
        for (Id caseId : caseIdsToUpdate) {
            Case caseRecord = new Case(Id = caseId);
            caseRecord.Case_Escalation_Count__c = caseIdToCountSum.containsKey(caseId)?caseIdToCountSum.get(caseId).size():0;
            casesToUpdate.add(caseRecord);
        }
        
        // Update the Case records
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
    
}