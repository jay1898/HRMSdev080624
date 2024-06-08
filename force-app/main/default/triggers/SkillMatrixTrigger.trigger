/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-03-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger SkillMatrixTrigger on Skill_Matrix__c  (after insert, before delete) {

    switch on Trigger.operationType {
        when AFTER_INSERT {
            SkillMatrixTriggerHandler.addNewSkillToAllEmployees();
        }
        when BEFORE_DELETE {
            SkillMatrixTriggerHandler.deleteSkillsFromEmployees(Trigger.oldMap);
        }
    }
}