@isTest
public class UserProjectWiseChartTest {
	@isTest
    public static void testgetUserProjectWiseChart(){
        Contact con=new Contact(
            LastName='test',Email='test@gmail.com'
        );
        insert con;
            Employee__c testEmployee = new Employee__c(
            Name = 'Test Employee',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;
        
        Project_Name__c testProject = new Project_Name__c();
        testProject.Name = 'Project check';
        //Main_Project__c = testProject.Name;
        insert testProject;
        
        Employee_Project__c testEmployeeProject = new Employee_Project__c(
            Employee__c = testEmployee.Id,
            Project_Name__c=testProject.Id
        );
        insert testEmployeeProject;

        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = Date.today() // Use today's date for testing
           
        );
        insert testAttendance;


        Timesheet__c timesheetrecord = new Timesheet__c();
        timesheetrecord.Attendance__c = testAttendance.Id;
        timesheetrecord.Employee__c = testEmployee.Id;
        timesheetrecord.IsLocked__c = false;
        timesheetrecord.Ticket_No__c = 'opop';
        timesheetrecord.Task_Type__c = 'Standup Call';
        timesheetrecord.Estimated_Hours__c = '2';
        timesheetrecord.Actual_Hours__c = '1.5';
        timesheetrecord.Total_Hours__c = 10;
        timesheetrecord.Project_Name__c = 'Project check';
       	timesheetrecord.Project__c =testProject.Id;
        timesheetrecord.Task_Description__c = 'Test Task Description';
        timesheetrecord.Date__c = Date.today();
        insert timesheetrecord;
        // Call the controller method
        Test.startTest();
        List<UserProjectWiseChart.UserTimeSheetData> result = UserProjectWiseChart.getUserProjectWiseChart(testEmployee.Id);
        Test.stopTest();  
        System.assertEquals(1, result.size());

    }
}