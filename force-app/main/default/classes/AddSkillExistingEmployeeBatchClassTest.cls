@isTest
public class AddSkillExistingEmployeeBatchClassTest {
	 @testSetup
    static void setup() {
        Contact con1=new Contact(
            LastName='test 1',
            Email='test@gmail.com'
        );
        insert con1;

        Employee__c emp1 = new Employee__c();
        emp1.Name = 'TEST EMP';
        emp1.Joining_Date__c = Date.today().addMonths(-6);
        emp1.Username__c = 'testuser';
        emp1.Email__c = 'test@gmail.com';
        emp1.Date_of_Birth__c = Date.today();
        emp1.Emergency_Contact_No__c = '9426582649';
        emp1.First_Name__c = 'Test';
        emp1.Last_Name__c = 'Emp';
        emp1.Gender__c = 'Male';
        emp1.Personal_Email__c = 'testpersonal@gmail.com';
        insert emp1;
        
        Attendance__c attendance1 = new Attendance__c();
        attendance1.Employee__c = emp1.Id;
        attendance1.Date__c = Date.today();
        attendance1.Override_Absent__c = 'P';
        insert attendance1;
        
        List<Skill_Matrix__c> skillMatrixList = new List<Skill_Matrix__c>();
        for (Integer i = 0; i < 3; i++) {
            skillMatrixList.add(new Skill_Matrix__c(Name = 'Skill ' + i));
        }
        insert skillMatrixList;

        Skills_Set__c skillSet1 = new Skills_Set__c(
            Employee__c = emp1.Id,
            Skill_Matrix__c = skillMatrixList[0].Id
        );
        insert skillSet1;
    }
    
    @isTest
    static void testAddSkillExistingEmployeeBatchClass() {

        Test.startTest();
        AddSkillExistingEmployeeBatchClass batch = new AddSkillExistingEmployeeBatchClass();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Skills_Set__c> allSkillsSet = [SELECT Id, Employee__c, Skill_Matrix__c FROM Skills_Set__c];

        List<Employee__c> employees = [SELECT Id FROM Employee__c];
        for (Employee__c emp : employees) {
            Set<Id> skills = new Set<Id>();
            for (Skills_Set__c ss : allSkillsSet) {
                if (ss.Employee__c == emp.Id) {
                    skills.add(ss.Skill_Matrix__c);
                }
                else{
                    skills.add(ss.Skill_Matrix__c);
                }
            }
            System.assertEquals(3, skills.size(), 'Each employee should have 3 skills');
        }
    }
}