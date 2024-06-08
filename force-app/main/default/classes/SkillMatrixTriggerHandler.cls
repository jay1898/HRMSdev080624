/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-03-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SkillMatrixTriggerHandler {

    public static void addNewSkillToAllEmployees() {
        Database.executeBatch(new AddSkillExistingEmployeeBatchClass());
    }

    public static void deleteSkillsFromEmployees(Map<Id, Skill_Matrix__c> oldSkillsMap) {
        if (oldSkillsMap != null && oldSkillsMap.size() > 0) {
            List<Skills_Set__c> skillSetsNeedToBeDeleted = [SELECT Id FROM Skills_Set__c WHERE Skill_Matrix__c  IN :oldSkillsMap.keySet()];

            if (skillSetsNeedToBeDeleted.size() > 0) {
                try {
                    delete skillSetsNeedToBeDeleted;
                } catch (Exception e) {
                    System.debug('Exception while skillset deletion===>'+e.getMessage());
                }
            }
        }
    }
}