/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-03-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class AddSkillExistingEmployeeBatchClass implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext BC){
		// collect the batches of records or objects to be passed to execute
		return Database.getQueryLocator('SELECT Id FROM Employee__c');
	}

	public void execute(Database.BatchableContext BC, List<Employee__c> scope){
		Map<Id, Employee__c> empMap = new Map<Id, Employee__c>(scope);
        Map<Id, Set<Id>> employeeIdToSkilsMap = new Map<Id, Set<Id>>();

        List<Skill_Matrix__c> skillList = [SELECT Id, Name FROM Skill_Matrix__c];
        List<Skills_Set__c> employeeSkillSetList = [SELECT Id, Employee__c, Skill_Matrix__c FROM Skills_Set__c WHERE Employee__c IN :empMap.keySet()];

        if (skillList.size() > 0) {
            List<Skills_Set__c> employeesNewSkillSet = new List<Skills_Set__c>();
            for (Skills_Set__c s : employeeSkillSetList) {
                if (!employeeIdToSkilsMap.containsKey(s.Employee__c)) {
                    employeeIdToSkilsMap.put(s.Employee__c, new Set<Id>{s.Skill_Matrix__c}); 
                }
                else {
                    Set<Id> skillSet = employeeIdToSkilsMap.get(s.Employee__c);
                    skillSet.add(s.Skill_Matrix__c);
                    employeeIdToSkilsMap.put(s.Employee__c, skillSet); 
                }
            }

            for (Id e : empMap.keySet()) {
                for (Skill_Matrix__c sk : skillList) {
                    if (employeeIdToSkilsMap.containsKey(e)) {
                        Set<Id> skillSet = employeeIdToSkilsMap.get(e);
                        if (!skillSet.contains(sk.Id)) {
                            Skills_Set__c ss = new Skills_Set__c(
                                Employee__c = e,
                                Skill_Matrix__c = sk.Id
                            );
                            employeesNewSkillSet.add(ss);
                        }   
                    }
                    else {
                        Skills_Set__c ss = new Skills_Set__c(
                                Employee__c = e,
                                Skill_Matrix__c = sk.Id
                        );
                        employeesNewSkillSet.add(ss);
                    }
                }
            }

            if (employeesNewSkillSet.size() > 0) {
                try {
                    insert employeesNewSkillSet;
                } catch (Exception e) {
                    System.debug('Exception while inserting employee skillset' +e.getMessage());
                }
            }
        }
	}

	public void finish(Database.BatchableContext BC){
		// execute any post-processing operations
        System.debug('Employee Skill Matrix batch run successfully!');
	}
}