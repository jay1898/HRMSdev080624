/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-31-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger EmployeeTrigger on Employee__c (before insert,after insert,before update) { 
    /*if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            EmployeeTriggerHandler.checkForCircularHierarchy(Trigger.newMap);
        }
    }
    if(Trigger.isInsert && trigger.isBefore){
        EmployeeTriggerHandler.updatePasswordResetKey(Trigger.new,Trigger.oldMap);
    }*/
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            EmployeeTriggerHandler.updatePasswordResetKey(Trigger.new, Trigger.oldMap);
        }
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            EmployeeTriggerHandler.checkForCircularHierarchy(Trigger.newMap);
        }
    }
    if(Trigger.isAfter){ 
       EmployeeTriggerHandler.sendWelcomeEmail(Trigger.new, Trigger.oldMap); 
       EmployeeTriggerHandler.createEmployeeSkillSet(Trigger.new, Trigger.oldMap);
    }
}