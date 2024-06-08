/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SkillMatrixController {
    
    @AuraEnabled
    public static String getSkillMatrix(String employeeId){
        try {
            List<EmployeeSkills> empSkills = new List<EmployeeSkills>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId)) {
                List<Skills_Set__c> skillMatrix = [SELECT Id,Skill_Matrix__r.Name,Skill_Matrix__r.Is_Active__c,Employee__c,Currently_Being_Trained__c,Training_Reuired__c,Beginner__c,
                                Intermediate__c,Advanced__c,Outcome__c 
                                FROM Skills_Set__c
                                WHERE Employee__c =:employeeId AND Skill_Matrix__r.Is_Active__c = true];
                
                if (skillMatrix.size() > 0) {
                    for (Skills_Set__c s : skillMatrix) {
                        EmployeeSkills empskill = new EmployeeSkills();
                        empskill.Id = s.Id;
                        empskill.skillName = s.Skill_Matrix__r.Name;
                        empskill.TrainingRequired = s.Training_Reuired__c;
                        empskill.CurrentlyBeingTrained = s.Currently_Being_Trained__c;
                        empskill.Beginner = s.Beginner__c;
                        empskill.Intermediate = s.Intermediate__c;
                        empskill.Advanced = s.Advanced__c;
                        empskill.Outcome = Integer.valueOf(s.Outcome__c);

                        empSkills.add(empSkill);
                    }
                }
            }
            return JSON.serialize(empSkills);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateEmployeeSkillSet(String updatedSkills){
        try {
            List<EmployeeSkills> empSkills = (List<EmployeeSkills>)JSON.deserialize(updatedSkills, List<EmployeeSkills>.class);
            List<Skills_Set__c> updatedEmpSkills = new List<Skills_Set__c>();
            //System.debug('get'+empSkills);
            if (empSkills.size() > 0) {
                for (EmployeeSkills e : empSkills) {
                    Skills_Set__c s = new Skills_Set__c();
                    s.Id = e.Id;
                    s.Training_Reuired__c = e.TrainingRequired;
                    s.Currently_Being_Trained__c = e.CurrentlyBeingTrained;
                    s.Beginner__c = e.Beginner;
                    s.Intermediate__c = e.Intermediate;
                    s.Advanced__c = e.Advanced;
                    updatedEmpSkills.add(s);
                }

                if (updatedEmpSkills.size() > 0) {
                    update updatedEmpSkills;
                }
                return 'SUCESS';
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class EmployeeSkills {
        public Id Id;
        public String skillName;
        public Boolean TrainingRequired;
        public Boolean CurrentlyBeingTrained;
        public Boolean Beginner;
        public Boolean Intermediate;
        public Boolean Advanced;
        public Integer Outcome;

    }
}