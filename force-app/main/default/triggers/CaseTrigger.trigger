/*
Created By      : Rahul Sangwan
Created Date    : 8 May 2023
Purpose         : This is a trigger for Case with all relevant events.
----------------------------------------------------------------------------------------------
Modified By     : Rahul Sangwan 
Modified Date.  : 30 June 2023 
Purpose         : Implemented Trigger Interface 
----------------------------------------------------------------------------------------------
*/
trigger CaseTrigger on Case (before insert, after insert, before update,after update) {
    CaseTriggerHandler handler = new CaseTriggerHandler();
    TriggerManager.handle(handler, 'Case_Disable_Trigger__c'); 
}