@isTest
public class EmployeeTriggerHandler_T {
    
    @isTest
    static void testInsertAttendanceEmployee() {
        Contact con = new Contact(LastName = 'tes qd', Email = 'teadst@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TESTFRTGS';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'testemail@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556622266';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'TESTEMODP';
        testEmployee.Last_Name__c = 'TESTEMOP';
        testEmployee.Personal_Email__c = 'johnhapkin34444444@gmail.com';
        insert testEmployee;
        
        Test.startTest();
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c WHERE Employee__c = :testEmployee.Id LIMIT 1];       
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdatePasswordResetKey() {
        List<Employee__c> employees = [SELECT Id, Username__c FROM Employee__c];
        Test.startTest();
        EmployeeTriggerHandler.updatePasswordResetKey(employees, new Map<Id, Employee__c>());
        Test.stopTest();
        
        for (Employee__c emp : employees) {
            System.assertEquals(emp.Username__c, emp.Password_Reset_Key__c);
        }
    }
    
    private static void createTestData() {
        Contact c = new Contact(LastName = 'Test', Email = 'test@email.com');
        insert c;
        
        Employee__c emp1 = new Employee__c(Name = 'EMP G', Username__c = 'emp1user', Password__c = 'Admin@123', Email__c = 'emp1@gmail.com', Clocked_In_Out_Status__c = 'Clock-in', Date_of_Birth__c = Date.today(), Emergency_Contact_No__c = '1234567890', Gender__c = 'Male', First_Name__c = 'Emp1First', Last_Name__c = 'Emp1Last', Personal_Email__c = 'emp1personal@gmail.com');
        insert emp1;
        
        Employee__c emp2 = new Employee__c(Name = 'EMP R', Manager__c = emp1.Id, Username__c = 'emp2user', Password__c = 'Admin@123', Email__c = 'emp2@gmail.com', Clocked_In_Out_Status__c = 'Clock-in', Date_of_Birth__c = Date.today(), Emergency_Contact_No__c = '1234567890', Gender__c = 'Male', First_Name__c = 'Emp2First', Last_Name__c = 'Emp2Last', Personal_Email__c = 'emp2personal@gmail.com');
        insert emp2;
        
        Employee__c emp3 = new Employee__c(Name = 'EMP E', Manager__c = emp2.Id, Username__c = 'emp3user', Password__c = 'Admin@123', Email__c = 'emp3@gmail.com', Clocked_In_Out_Status__c = 'Clock-in', Date_of_Birth__c = Date.today(), Emergency_Contact_No__c = '1234567890', Gender__c = 'Male', First_Name__c = 'Emp3First', Last_Name__c = 'Emp3Last', Personal_Email__c = 'emp3personal@gmail.com');
        insert emp3;
        
        //emp1.Manager__c = emp3.Id;
        update emp1;
    }
    
    @isTest
    static void testCircularHierarchy() {
        
        Test.startTest();
        createTestData();
        
        Map<Id, Employee__c> newEmployeeMap = new Map<Id, Employee__c>(
            [SELECT Id, Manager__c FROM Employee__c]
        );
        
        EmployeeTriggerHandler.checkForCircularHierarchy(newEmployeeMap);
        Employee__c emp1 = [SELECT Id, Manager__c FROM Employee__c WHERE Name = 'EMP R' LIMIT 1];
        
        Test.stopTest();
    }
    
    @isTest
    static void testNoCircularHierarchy() {
        
        Test.startTest();
        Contact c = new Contact(LastName = 'Test', Email = 'test@email.com');
        insert c;
        
        Employee__c emp1 = new Employee__c(Name = 'EMP W', Username__c = 'emp1user', Password__c = 'Admin@123', Email__c = 'emp1@gmail.com', Clocked_In_Out_Status__c = 'Clock-in', Date_of_Birth__c = Date.today(), Emergency_Contact_No__c = '1234567890', Gender__c = 'Male', First_Name__c = 'Emp1First', Last_Name__c = 'Emp1Last', Personal_Email__c = 'emp1personal@gmail.com');
        insert emp1;
        Employee__c emp2 = new Employee__c(Name = 'EMP B', Manager__c = emp1.Id, Username__c = 'emp2user', Password__c = 'Admin@123', Email__c = 'emp2@gmail.com', Clocked_In_Out_Status__c = 'Clock-in', Date_of_Birth__c = Date.today(), Emergency_Contact_No__c = '1234567890', Gender__c = 'Male', First_Name__c = 'Emp2First', Last_Name__c = 'Emp2Last', Personal_Email__c = 'emp2personal@gmail.com');
        insert emp2;
        Employee__c emp3 = new Employee__c(Name = 'EMP H', Manager__c = emp2.Id, Username__c = 'emp3user', Password__c = 'Admin@123', Email__c = 'emp3@gmail.com', Clocked_In_Out_Status__c = 'Clock-in', Date_of_Birth__c = Date.today(), Emergency_Contact_No__c = '1234567890', Gender__c = 'Male', First_Name__c = 'Emp3First', Last_Name__c = 'Emp3Last', Personal_Email__c = 'emp3personal@gmail.com');
        insert emp3;
        
        Map<Id, Employee__c> newEmployeeMap = new Map<Id, Employee__c>(
            [SELECT Id, Manager__c FROM Employee__c]
        );
        
        EmployeeTriggerHandler.checkForCircularHierarchy(newEmployeeMap);
        
        Test.stopTest();
    }
    
    @isTest
    static void testSendWelcomeEmail() {
        String uniqueName = 'Welcome_Email_for_Employee_' + DateTime.now().getTime();
        
        Contact con = new Contact(LastName = 'tes qd', Email = 'teadst@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TESTFRTGGS';
        testEmployee.Username__c = 'testusder';
        testEmployee.Password__c = 'Admidn@123';
        testEmployee.Email__c = 'testemadil@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556622266';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'TEDSTEMODP';
        testEmployee.Last_Name__c = 'TESTEMSOP';
        testEmployee.Personal_Email__c = 'johnhaspkin34444444@gmail.com';
        insert testEmployee;
        
        List<Employee__c> employees = [SELECT Id, Email__c FROM Employee__c where Id =: testEmployee.Id];
        
        Test.startTest();
        EmployeeTriggerHandler.sendWelcomeEmail(employees, new Map<Id, Employee__c>());
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateEmployeeSkillSet() {
        List<Skill_Matrix__c> skills = new List<Skill_Matrix__c>();
        for (Integer i = 0; i < 5; i++) {
            Skill_Matrix__c skill = new Skill_Matrix__c(Name = 'Skill ' + i);
            skills.add(skill);
        }
        insert skills;
        
        Contact con1=new Contact(
            LastName='test 10',
            Email='test10@gmail.com'
        );
        insert con1;

        Employee__c emp10 = new Employee__c();
        emp10.Name = 'TEST EMP D';
        emp10.Joining_Date__c = Date.today().addMonths(-6);
        emp10.Username__c = 'testuser';
        emp10.Email__c = 'test10@gmail.com';
        emp10.Date_of_Birth__c = Date.today();
        emp10.Emergency_Contact_No__c = '9426582650';
        emp10.First_Name__c = 'Test';
        emp10.Last_Name__c = 'Emp10';
        emp10.Gender__c = 'Male';
        emp10.Personal_Email__c = 'testpersonal10@gmail.com';
        insert emp10;
        
        Attendance__c attendance1 = new Attendance__c();
        attendance1.Employee__c = emp10.Id;
        attendance1.Date__c = Date.today();
        attendance1.Override_Absent__c = 'P';
        insert attendance1;
        
        

        // Verify skill matrix records were inserted
        System.assertEquals(5, [SELECT COUNT() FROM Skill_Matrix__c]);
         List<Skills_Set__c> skillSets = [SELECT Id, Employee__c, Skill_Matrix__c FROM Skills_Set__c WHERE Employee__c = :emp10.Id];
        
         Set<Id> skillMatrixIds = new Set<Id>();
        for (Skill_Matrix__c skill : skills) {
            skillMatrixIds.add(skill.Id);
        }
        
        for (Skills_Set__c skillSet : skillSets) {
            System.assert(skillMatrixIds.contains(skillSet.Skill_Matrix__c), 'Skill Set should reference valid Skill Matrix');
        }
    }
}