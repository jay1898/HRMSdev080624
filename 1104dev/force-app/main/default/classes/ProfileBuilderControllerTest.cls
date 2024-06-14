@isTest
public class ProfileBuilderControllerTest {
    
    @isTest
    public static void testGetEmployeeNames() {
        Test.startTest();
        List<Employee__c> employeeList = ProfileBuilderController.getEmployeeNames();
        Test.stopTest();
    }
    
    
    @isTest
    public static void testGetSkillsPicklistValues() {
        Test.startTest();
        List<Map<String, String>> picklistValues = ProfileBuilderController.getSkillsPicklistValues();
        Test.stopTest();
    }
    
    @isTest
    public static void testSaveExperience() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST EMPLOYEE';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'testemail@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        insert testEmployee;
        // Add test data as needed
        Experience__c exp = new Experience__c();
        exp.Name = 'Test Employer';
        exp.Job_Title__c = 'Test Job Title';
        exp.Start_Date__c = Date.today();
        exp.End_Date__c = Date.today().addDays(30);
        exp.Description__c = 'Test Description';
        exp.Employee__c = testEmployee.Id;
        exp.Id = null; // Set to null for insert
        //Insert exp;
        
        Test.startTest();
        Experience__c exp1 = ProfileBuilderController.saveExperience(exp.Name,  exp.Job_Title__c, exp.Start_Date__c, exp.End_Date__c, exp.Description__c, exp.Employee__c, exp.Id );
        Test.stopTest();
        
        
    }
    @isTest
    public static void testSaveExperience1() {
        
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST EMP';
        testEmployee.Username__c = 'testuserr';
        testEmployee.Password__c = 'Admin@1234';
        testEmployee.Email__c = 'testemail1@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        insert testEmployee;
        // Add test data as needed
        Experience__c exp = new Experience__c();
        exp.Name = 'Test Employer';
        exp.Job_Title__c = 'Test Job Title';
        exp.Start_Date__c = Date.today();
        exp.End_Date__c = Date.today().addDays(30);
        exp.Description__c = 'Test Description';
        exp.Employee__c = testEmployee.Id;
        exp.Id = null; // Set to null for insert
        Insert exp;
        
        
        List<Experience__c> expupd = [select Id,Name,Job_Title__c,Start_Date__c,End_Date__c,Description__c,Employee__c from Experience__c Where Id =:exp.Id Limit 10];
        expupd[0].Name = 'Test Employ';
        system.debug('expupd[0].Name'+expupd[0].Name);
        expupd[0].Job_Title__c = 'Test Job Title333';
        expupd[0].Start_Date__c = Date.today();
        expupd[0].End_Date__c = Date.today().addDays(25);
        expupd[0].Description__c = 'Test Descriptionfffgfg';
        //update expupd;
        
        Test.startTest();
        Experience__c exp2 = ProfileBuilderController.saveExperience(expupd[0].Name,expupd[0].Job_Title__c,expupd[0].Start_Date__c,expupd[0].End_Date__c,expupd[0].Description__c,exp.Employee__c,exp.Id);
        Test.stopTest();          
    }
    
    
    
    @isTest
    public static void testGetHelpTextSummary() {
        Test.startTest();
        String inputStr = 'Test Input';
        List<HelpText__c> helpTextList = ProfileBuilderController.getHelpTextSummary(inputStr);
        Test.stopTest();
    }
    
    @isTest
    static void testGetHelpTextExperience() {
        Test.startTest();
        String inputStr = 'Test Input';
        List<HelpText__c> helpTextList = ProfileBuilderController.getHelpTextExperience(inputStr);
        Test.stopTest();
        
    }
	/*
    @isTest
    public static void testUpdateEmployeeRecord() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        // Add test data as needed
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST EMPLOYEE';
        testEmployee.Username__c = 'Testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'jay122456@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        insert testEmployee;
        // Add test data as needed
        String wrapperText = '{"Name": "Test Employee"}'; // Example JSON string
        Test.startTest();
        ProfileBuilderController.updateEmployeeRecord(testEmployee.Id);
        Test.stopTest();
    }*/
    
    @isTest
    public static void testGetListOfExperience() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        // Add test data as needed
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'AKASH LAKKAD';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'jay12246@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        insert testEmployee;
        Test.startTest();
        List<Experience__c> experienceList = ProfileBuilderController.getListOfExperience(testEmployee.Id);
        Test.stopTest();
    }
}