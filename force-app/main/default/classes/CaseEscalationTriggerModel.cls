public class CaseEscalationTriggerModel {
    
    public static List<QueueSobject> getQueuesRelatedToCaseEscalation() {
        return [SELECT QueueId, Queue.Name, SobjectType 
                FROM QueueSobject 
                WHERE SobjectType = 'Case_Escalation__c'];
    }
    
     public static List<Case> getCaseRelatedToCaseEscalation(List<String> caseId) {
        return [SELECT Id,Owner.Name
                FROM Case 
                WHERE Id =: caseId];
    }
    
    public static List<Case_Escalation__c> getCasesFromCaseEscalation(Set<Id> caseId) {
        return [SELECT  Id,Case__c
                FROM Case_Escalation__c 
                WHERE Case__c =:caseId 
                AND Escalation_Status__c NOT in ('Complete','Canceled')];
    }
}