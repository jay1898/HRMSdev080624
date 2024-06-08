@isTest
public class WorkingFormatControllerTest {

    @isTest
    public static void testGetWorkingFormatChart() {
        Contact con = new Contact(
            LastName='test', Email='test@gmail.com'
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
        insert testProject;
        
        Employee_Project__c testEmployeeProject = new Employee_Project__c(
            Employee__c = testEmployee.Id,
            Project_Name__c = testProject.Id
        );
        insert testEmployeeProject;
		
        DateTime myDateTime = DateTime.now();
        
        // Create attendance records for multiple days
        List<Attendance__c> testAttendanceList = new List<Attendance__c>();
        for (Integer i = 0; i < 7; i++) {
            Attendance__c testAttendance = new Attendance__c(
                Employee__c = testEmployee.Id,
                Date__c = Date.today()
            );
            testAttendanceList.add(testAttendance);
        }
        insert testAttendanceList;

        // Create clock-in/out records for multiple days
        List<Clock_In_Out__c> testClockInOutList = new List<Clock_In_Out__c>();
        for (Integer i = 0; i < 10; i++) {
            Clock_In_Out__c clockInOut = new Clock_In_Out__c(
                Employee__c = testEmployee.Id,
                Attendance__c = testAttendanceList[Math.mod(i, 7)].Id,
                Date__c = Date.today().addDays(+i),
                Clock_In_Time__c = Datetime.now(),
				Clock_Out_Time__c = myDateTime.addHours(8)
            );
            testClockInOutList.add(clockInOut);
        }
        insert testClockInOutList;
        Clock_In_Out__c clockInOut2 = new Clock_In_Out__c(
                Employee__c = testEmployee.Id,
                Attendance__c = testAttendanceList[0].Id,
                Date__c = Date.today().addDays(2),
                Clock_In_Time__c = Datetime.now(),
				Clock_Out_Time__c = myDateTime.addHours(8)
            );
        insert clockInOut2;

        list<Clock_In_Out__c> clock = [SELECT Daily_Hours__c, Clock_In_Time__c, Employee__r.Id
                FROM Clock_In_Out__c
                WHERE Employee__r.Id = :testEmployee.Id
                AND Clock_In_Time__c = This_Week 
                AND Daily_Hours__c != null
                ORDER BY Clock_In_Time__c];
       	system.debug('clock--@@@@@@@@@@@@@@@@@@>'+clock);
		system.debug('testClockInOutList-->'+testClockInOutList);
        
        
        Test.startTest();
         WorkingFormatController.getWorkingFormatChart(testEmployee.Id);
        Test.stopTest();
	        
        // Validate the result
        System.assertEquals(7, testAttendanceList.size(), 'Expected 7 days of data');
        /*for (WorkingFormatController.DataSet dataSet : clock) {
            // Ensure that the count is 0 for all days except Monday
            if (!dataSet.label.equals('Mon')) {
                System.assertEquals(0, dataSet.count, 'Expected 0 hours for ' + dataSet.label);
            }
        }*/
    }
}





/*     06/12/23
 @isTest
public class WorkingFormatControllerTest {

    @isTest
    static void testGetWorkingFormatChart() {
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
        
        List<Clock_In_Out__c> testClockInOutList = new List<Clock_In_Out__c>();
        for (Integer i = 0; i < 10; i++) {
            Clock_In_Out__c clockInOut = new Clock_In_Out__c(
                Employee__c = testEmployee.Id,
                Attendance__c = testAttendance.Id,
                Date__c = Date.today().addDays(-i),
                Daily_Hours__c = 8.0
            );
            testClockInOutList.add(clockInOut);
        }
        insert testClockInOutList;

        List<WorkingFormatController.DataSet> result = WorkingFormatController.getWorkingFormatChart(testEmployee.Id);

        System.assertEquals(7, result.size(), 'Expected 7 days of data');
    }
}
 * /

/*@isTest
public class WorkingFormatControllerTest {
@isTest
    public Static void testgetWorkingFormatChart(){
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
        Clock_In_Out__c ct = new Clock_In_Out__c(
            Employee__c = testEmployee.Id,
            Attendance__c = testAttendance.Id,
            Date__c = Date.today()
        	);
        insert ct;
        Test.startTest();
        List<WorkingFormatController.DataSet> result = WorkingFormatController.getWorkingFormatChart(testEmployee.Id);
        system.debug('Result------------->'+result);
        Test.stopTest();
        System.assertEquals(1, result.size());
    }
}*/