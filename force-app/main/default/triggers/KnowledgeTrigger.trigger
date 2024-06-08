/*
Created By      : Rahul Sangwan
Created Date    : 1 Sept 2023
Purpose         : This is a trigger for Knowledge Article with all relevant events.
----------------------------------------------------------------------------------------------
*/
trigger KnowledgeTrigger on Knowledge__kav (before insert, before update, after insert, after update) {

    KnowledgeTriggerHandler handler = new KnowledgeTriggerHandler();
    TriggerManager.handle(handler, 'Knowledge_Disable_Trigger__c'); 
}