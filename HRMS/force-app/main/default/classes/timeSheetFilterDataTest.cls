@isTest
private class timeSheetFilterDataTest {
    
    @isTest
    static void testGetTimesheetData() {
        
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;

        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testemail@gmail.com',
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;

        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = Date.Today()
        );
        insert testAttendance;

        Project_Name__c testProject = new Project_Name__c(
            Name = 'Test Project',
            Default_Active__c = true,
            Project_Manager__c = testEmployee.Id
        );
        insert testProject;

        Clock_In_Out__c clk = new Clock_In_Out__c(
            Employee__c = testEmployee.Id,
            Attendance__c = testAttendance.Id,
            Daily_Hours__c = 5
        );
        insert clk;

        Timesheet__c testTimesheet = new Timesheet__c(
            Employee__c = testEmployee.Id,
            Project_Name__c = testProject.Id,
            Ticket_No__c = '123',
            Task_Description__c = 'Test Task',
            Total_Hours__c = 8,
            Date__c = Date.today(),
            Attendance__c = testAttendance.Id,
            Task_Type__c = 'Standup Call',
            Actual_Hours__c = '1.5',
            Clock_In_Out__c = clk.Id
        );
        insert testTimesheet;

        List<Timesheet__c> result = TimeSheetFilterData.getTimesheetData(
            Date.today(),
            new List<String>{'Test Project'},
            new List<String>{'Test Employee'}
        );

        delete testTimesheet;
        delete clk;
        delete testAttendance;
        delete testEmployee;
        delete testProject;
    }

    @isTest
    static void testGetEmployeeNames() {
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;

        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testemail@gmail.com',
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;

        List<Employee__c> result = TimeSheetFilterData.getEmployeeNames();

        System.assertEquals(1, result.size(), 'Unexpected result size');
        System.assertEquals('TEST', result[0].Name, 'Unexpected Employee Name');
        delete testEmployee;
    }

    @isTest
    static void testProjectNames() {
        
        Project_Name__c testProject = new Project_Name__c(
            Name = 'Test Project',
            Default_Active__c = true
        );
        insert testProject;

        List<Project_Name__c> result = TimeSheetFilterData.projectNames();

        System.assertEquals(1, result.size(), 'Unexpected result size');
        System.assertEquals('Test Project', result[0].Name, 'Unexpected Project Name');
        
        delete testProject;
    }
}