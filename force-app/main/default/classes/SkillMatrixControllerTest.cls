@isTest
public class SkillMatrixControllerTest {
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
        
        Skill_Matrix__c skill1 = new Skill_Matrix__c(Name = 'Skill1', Is_Active__c = true);
        Skill_Matrix__c skill2 = new Skill_Matrix__c(Name = 'Skill2', Is_Active__c = true);
        insert skill1;
        insert skill2;

        Skills_Set__c skillSet1 = new Skills_Set__c(Employee__c = emp1.Id, Skill_Matrix__c = skill1.Id);
        insert skillSet1;
    }

    @isTest
    static void testGetSkillMatrix() {
        Employee__c emp1 = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];

        Test.startTest();
        String result = SkillMatrixController.getSkillMatrix(emp1.Id);
        Test.stopTest();

        List<SkillMatrixController.EmployeeSkills> empSkills = (List<SkillMatrixController.EmployeeSkills>)JSON.deserialize(result, List<SkillMatrixController.EmployeeSkills>.class);

        System.assertNotEquals(null, empSkills);
        System.assertEquals(2, empSkills.size());
    }

    @isTest
    static void testGetSkillMatrixInvalidId() {

        Test.startTest();
        String result = SkillMatrixController.getSkillMatrix('InvalidId');
        Test.stopTest();

        List<SkillMatrixController.EmployeeSkills> empSkills = (List<SkillMatrixController.EmployeeSkills>)JSON.deserialize(result, List<SkillMatrixController.EmployeeSkills>.class);
        System.assertEquals(0, empSkills.size());
    }

    @isTest
    static void testUpdateEmployeeSkillSet() {
        Skills_Set__c skillSet = [SELECT Id FROM Skills_Set__c LIMIT 1];

        SkillMatrixController.EmployeeSkills empSkill = new SkillMatrixController.EmployeeSkills();
        empSkill.Id = skillSet.Id;
        empSkill.TrainingRequired = false;
        empSkill.CurrentlyBeingTrained = false;
        empSkill.Beginner = false;
        empSkill.Intermediate = true;
        empSkill.Advanced = false;

        List<SkillMatrixController.EmployeeSkills> empSkills = new List<SkillMatrixController.EmployeeSkills>{empSkill};
        String updatedSkillsJson = JSON.serialize(empSkills);

        Test.startTest();
        String result = SkillMatrixController.updateEmployeeSkillSet(updatedSkillsJson);
        Test.stopTest();

        System.assertEquals('SUCESS', result);

        Skills_Set__c updatedSkillSet = [SELECT Id, Training_Reuired__c, Currently_Being_Trained__c, Beginner__c, Intermediate__c, Advanced__c FROM Skills_Set__c WHERE Id = :skillSet.Id];
        System.assertEquals(false, updatedSkillSet.Training_Reuired__c);
        System.assertEquals(false, updatedSkillSet.Currently_Being_Trained__c);
        System.assertEquals(false, updatedSkillSet.Beginner__c);
        System.assertEquals(true, updatedSkillSet.Intermediate__c);
        System.assertEquals(false, updatedSkillSet.Advanced__c);
    }

    @isTest
    static void testUpdateEmployeeSkillSetEmptyList() {
        List<SkillMatrixController.EmployeeSkills> empSkills = new List<SkillMatrixController.EmployeeSkills>();
        String updatedSkillsJson = JSON.serialize(empSkills);

        Test.startTest();
        String result = SkillMatrixController.updateEmployeeSkillSet(updatedSkillsJson);
        Test.stopTest();

        System.assertEquals(null, result);
    }
}