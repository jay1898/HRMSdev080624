trigger CaseEscalationTrigger on Case_Escalation__c (before insert, before update, before delete, after insert, after update, after delete) {

    CaseEscalationTriggerHandler handler = new CaseEscalationTriggerHandler();
    TriggerManager.handle(handler, 'Case_Escalation_Disable_Trigger__c'); 
}