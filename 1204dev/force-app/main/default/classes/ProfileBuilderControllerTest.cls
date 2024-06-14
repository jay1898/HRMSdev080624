@isTest
public class ProfileBuilderControllerTest {
    
    @isTest
    public static void testGetEmployeeNames() {
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMP',
            Username__c = 'testuserr',
            Password__c = 'Admin@1234',
            Email__c = 'testemail1@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556666',
            Gender__c = 'Male',
            First_Name__c = 'AKASH',
            Last_Name__c = 'LAKKAD',
            Personal_Email__c = 'jay12246@gmail.com'
        );
        insert testEmployee;
        
        Test.startTest();
        List<Employee__c> employeeList = ProfileBuilderController.getEmployeeNames();
        Test.stopTest();
        
        // Retrieve the expected list of Employee__c records
        List<Employee__c> expectedEmployeeList = [SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Phone__c FROM Employee__c ORDER BY Name ASC];
        
        // Verify the results
        System.assertEquals(expectedEmployeeList.size(), employeeList.size(), 'Incorrect number of records returned');
        
        // Verify that the records are sorted by Name in ascending order
        for (Integer i = 0; i < employeeList.size() - 1; i++) {
            System.assert(employeeList[i].Name <= employeeList[i + 1].Name, 'Records are not sorted correctly');
        }
    }

    
    @isTest
    public static void testGetSkillsPicklistValues() {
        Test.startTest();
        List<Map<String, String>> picklistValues = ProfileBuilderController.getSkillsPicklistValues();
        Test.stopTest();
        System.assertEquals(null,picklistValues , 'Incorrect number of records returned');

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
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556666';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'AKASH';
        testEmployee.Last_Name__c = 'LAKKAD';
        testEmployee.Personal_Email__c = 'jay12246@gmail.com';
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
        Experience__c exp1 = ProfileBuilderController.saveExperience(
            'Test Employer',
            'Test Job Title',
            Date.today(),
            Date.today().addDays(30),
            'Test Description',
            testEmployee.Id,
            null
        );
        Test.stopTest();
        
        // Retrieve the inserted Experience record from the database
        Experience__c insertedExp = [SELECT Id, Name, Job_Title__c, Start_Date__c, End_Date__c, Description__c, Employee__c FROM Experience__c WHERE Id = :exp1.Id LIMIT 1];
        
        // Assert that the Experience record was inserted correctly
        System.assertNotEquals(null, insertedExp.Id, 'Experience record should be inserted');
        System.assertEquals('Test Employer', insertedExp.Name, 'Name should match');
        System.assertEquals('Test Job Title', insertedExp.Job_Title__c, 'Job Title should match');
        System.assertEquals(Date.today(), insertedExp.Start_Date__c, 'Start Date should match');
        System.assertEquals(Date.today().addDays(30), insertedExp.End_Date__c, 'End Date should match');
        System.assertEquals('Test Description', insertedExp.Description__c, 'Description should match');
        System.assertEquals(testEmployee.Id, insertedExp.Employee__c, 'Employee Id should match');
        
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
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556666';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'AKASH';
        testEmployee.Last_Name__c = 'LAKKAD';
        testEmployee.Personal_Email__c = 'jay12246@gmail.com';
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
        // Call the method under test
        Experience__c updatedExperience = ProfileBuilderController.saveExperience(
            exp.Name,
            exp.Job_Title__c,
            exp.Start_Date__c,
            exp.End_Date__c,
            exp.Description__c,
            exp.Employee__c,
            exp.Id
        );
        Test.stopTest();
        
        // Retrieve the updated Experience record from the database
        Experience__c updatedExpFromDB = [SELECT Id, Name, Job_Title__c, Start_Date__c, End_Date__c, Description__c, Employee__c FROM Experience__c WHERE Id = :exp.Id LIMIT 1];
        
        // Assert that the Experience record was updated correctly
        System.assertEquals(exp.Name, updatedExpFromDB.Name, 'Name should be updated');
        System.assertEquals(exp.Job_Title__c, updatedExpFromDB.Job_Title__c, 'Job Title should be updated');
        System.assertEquals(exp.Start_Date__c, updatedExpFromDB.Start_Date__c, 'Start Date should be updated');
        System.assertEquals(exp.End_Date__c, updatedExpFromDB.End_Date__c, 'End Date should be updated');
        System.assertEquals(exp.Description__c, updatedExpFromDB.Description__c, 'Description should be updated');        
    } 
    
    @isTest
    public static void testGetHelpTextSummary() {
        /*Test.startTest();
        String inputStr = 'Test Input';
        List<HelpText__c> helpTextList = ProfileBuilderController.getHelpTextSummary(inputStr);
        Test.stopTest();*/
        
                
        List<HelpText__c> helpTextList = new List<HelpText__c>{
            new HelpText__c(Instructions__c = 'Test help text 1', IsActive__c = true, Type__c = 'Summary'),
                new HelpText__c(Instructions__c = 'Test help text 2', IsActive__c = true, Type__c = 'Summary'),
                new HelpText__c(Instructions__c = 'Another help text', IsActive__c = false, Type__c = 'Summary'),
                new HelpText__c(Instructions__c = 'Yet another help text', IsActive__c = true, Type__c = 'Experience')
                };
                    insert helpTextList;
        
        // Call the method with a valid input string
        Test.startTest();
        String inputStr = 'Test';
        List<HelpText__c> result = ProfileBuilderController.getHelpTextSummary(inputStr);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(2, result.size(), 'Incorrect number of help text records returned');
        for (HelpText__c helpText : result) {
            System.assertEquals(true, helpText.Instructions__c.containsIgnoreCase(inputStr), 'Incorrect help text returned');
        }
    }
    
    @isTest
    public static void testGetHelpTextExperience() {
        /*Test.startTest();
String inputStr = 'Test Input';
List<HelpText__c> helpTextList = ProfileBuilderController.getHelpTextExperience(inputStr);
Test.stopTest();*/
        
        List<HelpText__c> helpTextList = new List<HelpText__c>{
            new HelpText__c(Instructions__c = 'Test help text 1', IsActive__c = true, Type__c = 'Experience'),
                new HelpText__c(Instructions__c = 'Test help text 2', IsActive__c = true, Type__c = 'Experience'),
                new HelpText__c(Instructions__c = 'Another help text', IsActive__c = false, Type__c = 'Experience'),
                new HelpText__c(Instructions__c = 'Yet another help text', IsActive__c = true, Type__c = 'Summary')
                };
                    insert helpTextList;
        
        // Call the method with a valid input string
        Test.startTest();
        String inputStr = 'Test';
        List<HelpText__c> result = ProfileBuilderController.getHelpTextExperience(inputStr);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(2, result.size(), 'Incorrect number of help text records returned');
        for (HelpText__c helpText : result) {
            System.assertEquals(true, helpText.Instructions__c.containsIgnoreCase(inputStr), 'Incorrect help text returned');
        }
    }
	
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
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556666';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'AKASH';
        testEmployee.Last_Name__c = 'LAKKAD';
        testEmployee.Personal_Email__c = 'jay12246@gmail.com';
        testEmployee.Certificate__c = 'Admin';
        insert testEmployee;
        // Add test data as needed
        String wrapperText = '{"Id":"' + testEmployee.Id + '","Skills__c":"Apex;SOQL;SOSL;Visualforce;LWC;AURA;HTML;CSS;JavaScript;Communication;Dashboards","Certificate__c":"Admin;PD1;PD2;App Builder;Javascript;Vlocity consultant;Vlocity Devloper;Associate"}';
        Test.startTest();
        ProfileBuilderController.updateEmployeeRecord(wrapperText);
        Test.stopTest();
         // Retrieve the updated record
        Employee__c updatedEmployee = [SELECT Id, Skills__c, Certificate__c FROM Employee__c WHERE Id = :testEmployee.Id];
        // Assert that the record was updated correctly
        System.assertEquals('Apex;SOQL;SOSL;Visualforce;LWC;AURA;HTML;CSS;JavaScript;Communication;Dashboards', updatedEmployee.Skills__c);
        System.assertEquals('Admin;PD1;PD2;App Builder;Javascript;Vlocity consultant;Vlocity Devloper;Associate', updatedEmployee.Certificate__c);
    }
    
    @isTest
    public static void testGetListOfExperience() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'AKASH LAKKAD';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'jay12246@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556666';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'AKASH';
        testEmployee.Last_Name__c = 'LAKKAD';
        testEmployee.Personal_Email__c = 'jay12246@gmail.com';
        insert testEmployee;
        
        Experience__c exp1 = new Experience__c(
            Employee__c = testEmployee.Id,
            Name = 'Experience 1',
            Job_Title__c = 'Software Developer',
            Start_Date__c = Date.today().addDays(-365),
            End_Date__c = Date.today(),
            Description__c = 'Experience 1 Description'
        );
        Experience__c exp2 = new Experience__c(
            Employee__c = testEmployee.Id,
            Name = 'Experience 2',
            Job_Title__c = 'Project Manager',
            Start_Date__c = Date.today().addDays(-730),
            End_Date__c = Date.today().addDays(-365),
            Description__c = 'Experience 2 Description'
        );
        insert new List<Experience__c>{exp1, exp2};
        
        Test.startTest();
        List<Experience__c> experienceList = ProfileBuilderController.getListOfExperience(testEmployee.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, experienceList, 'Experience list should not be null');
        
        System.assertEquals(2, experienceList.size(), 'Incorrect number of experience records returned');
        
        System.assertEquals('Experience 1', experienceList[0].Name, 'Incorrect Name for the first experience record');
        System.assertEquals('Software Developer', experienceList[0].Job_Title__c, 'Incorrect Job Title for the first experience record');
    }
    
    @isTest
    public static void testgetSkillList() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        // Add test data as needed
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'AKASH LAKKAD';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'jay12246@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556666';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'AKASH';
        testEmployee.Last_Name__c = 'LAKKAD';
        testEmployee.Personal_Email__c = 'jay12246@gmail.com';
        testEmployee.Skills__c = 'SOSL';
        insert testEmployee;
        Test.startTest();
        String expList = ProfileBuilderController.getSkillList(testEmployee.Id);
        Test.stopTest();
        System.assertEquals(testEmployee.Skills__c, expList, 'Incorrect skills returned');
    }
    
    @isTest
    public static void testgetCertificateList() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        // Add test data as needed
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'AKASH LAKKAD';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'jay12246@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556666';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'AKASH';
        testEmployee.Last_Name__c = 'LAKKAD';
        testEmployee.Personal_Email__c = 'jay12246@gmail.com';
        testEmployee.Certificate__c = 'Admin';
        insert testEmployee;
        Test.startTest();
        String expList = ProfileBuilderController.getCertificateList(testEmployee.Id);
        Test.stopTest();
        System.assertEquals(testEmployee.Certificate__c, expList, 'Incorrect certificate returned');

    }
    
    @isTest
    public static void testgetProfessionalSummary() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        // Add test data as needed
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'AKASH LAKKAD';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'jay12246@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556666';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'AKASH';
        testEmployee.Last_Name__c = 'LAKKAD';
        testEmployee.Personal_Email__c = 'jay12246@gmail.com';
        testEmployee.Professional_Summary__c = 'testing for text area';
        insert testEmployee;
        Test.startTest();
        String expList = ProfileBuilderController.getProfessionalSummary(testEmployee.Id);
        Test.stopTest();
		System.assertEquals(testEmployee.Professional_Summary__c, expList, 'Incorrect Professional Summary returned');
    }    
}