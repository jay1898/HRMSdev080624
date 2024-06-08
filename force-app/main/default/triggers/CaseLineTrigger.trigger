/*
Created By      : Subhash Panchani
Created Date    : 26 June 2023
Purpose         : This is a trigger for Case_Line__c with all relevant events.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/
trigger CaseLineTrigger on Case_Line__c (before insert,before update, after insert, after update) {
    
    //Check whether functionality is disabled from Custom setting.
    if(Utility.checkFunctionalityActiveOrNot('Case_Line_Disable_Trigger__c')) return;
    if(!CaseLineTriggerHandler.RUN_TRIGGER) return ;
    
    //Singleton design pattern applied.
    CaseLineTriggerHandler caseLineHandlerObj = CaseLineTriggerHandler.getInstance();
    
    //On before Insert event, add all logic in onBeforeInsert method of Handler class.
    if(Trigger.isInsert && Trigger.isBefore) {
        caseLineHandlerObj.onBeforeInsert(Trigger.new);
    }
    
    //On before Update event, add all logic in onBeforeUpdate method of Handler class.
    if(Trigger.isUpdate && Trigger.isBefore) {
        caseLineHandlerObj.onBeforeUpdate(Trigger.new);
    }
    
    //On after Insert event, add all logic in onAfterInsert method of Handler class.
    if(Trigger.isInsert && Trigger.isAfter) {
        caseLineHandlerObj.onAfterInsert(Trigger.new);
    }
    
    //On after Update event, add all logic in onAfterInsert method of Handler class.
    if(Trigger.isUpdate && Trigger.isAfter) {
        caseLineHandlerObj.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }  
}