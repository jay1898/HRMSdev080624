@isTest
public class SkillMatrixTriggerHandlerTest {

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
        
        Skill_Matrix__c skill1 = new Skill_Matrix__c(Name = 'Skill1');
        Skill_Matrix__c skill2 = new Skill_Matrix__c(Name = 'Skill2');
        insert skill1;
        insert skill2;

        Skills_Set__c skillSet1 = new Skills_Set__c(Employee__c = emp1.Id, Skill_Matrix__c = skill1.Id);
        Skills_Set__c skillSet2 = new Skills_Set__c(Employee__c = emp1.Id, Skill_Matrix__c = skill2.Id);
        insert skillSet1;
        insert skillSet2;
    }

    @isTest
    static void testAfterInsert() {
        Test.startTest();
        Skill_Matrix__c newSkill = new Skill_Matrix__c(Name = 'NewSkill');
        insert newSkill;

        List<Skills_Set__c> skillSets = [SELECT Id FROM Skills_Set__c WHERE Skill_Matrix__c = :newSkill.Id];
        Test.stopTest();
    }

    @isTest
    static void testBeforeDelete() {
        Skill_Matrix__c skillToDelete = [SELECT Id FROM Skill_Matrix__c LIMIT 1];
        
        List<Skills_Set__c> skillSets = [SELECT Id FROM Skills_Set__c WHERE Skill_Matrix__c = :skillToDelete.Id];
        
        Test.startTest();
        delete skillToDelete;
        List<Skills_Set__c> deletedSkillSets = [SELECT Id FROM Skills_Set__c WHERE Skill_Matrix__c = :skillToDelete.Id];
        System.assert(deletedSkillSets.isEmpty(), 'Associated skill sets should be deleted');
        Test.stopTest();
    }
}