/*
Created By      : Subhash Panchani
Created Date    : 28 July 2023
Purpose         : This is a trigger for Case Quick Text with all relevant events.
----------------------------------------------------------------------------------------------
Modified By     : 
Modified Date.  :  
Purpose         :  
----------------------------------------------------------------------------------------------
*/
trigger CaseQuickTextTrigger on Case_Quick_Text__c (before insert, after insert, before update,after update) {
    CaseQuickTextTriggerHandler handler = new CaseQuickTextTriggerHandler();
    TriggerManager.handle(handler, 'Case_Quick_Text_Disable_Trigger__c'); 
}