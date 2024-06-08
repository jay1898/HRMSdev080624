trigger ResourceWorkzoneTrigger on Resource_Workzone__c (before insert, after insert, before update,after update, after delete) {

    ResourceWorkzoneTriggerHandler handler = new ResourceWorkzoneTriggerHandler();
    TriggerManager.handle(handler, 'Resource_WorkZone_Disable_Trigger__c'); 
}