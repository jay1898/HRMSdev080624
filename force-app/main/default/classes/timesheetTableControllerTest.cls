@isTest
public class timesheetTableControllerTest {
    @isTest
    static void gettimesheetDataTest() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'shrikant@gmail.com'
        );
        insert testEmployee;
        Attendance__c testAttendance = new Attendance__c();
        testAttendance.Employee__c = testEmployee.Id;
        testAttendance.Date__c = Date.today();
        insert testAttendance;
        
        Project_Name__c testProject = new Project_Name__c();
        testProject.Name = 'Project check';
        insert testProject;
        
        Employee_Project__c testEmployeeProject = new Employee_Project__c(
            Employee__c = testEmployee.Id,
            Project_Name__c=testProject.Id
        );
        insert testEmployeeProject;
        system.debug('testEmployeeProject--------->'+testEmployeeProject);
        Map<String, Object> result = timesheetTableController.gettimesheetData(testEmployee.Id);
        
        System.assertEquals(true, result.containsKey('TaskType'));
        System.assertEquals(true, result.containsKey('ActEstHour'));
        System.assertEquals(true, result.containsKey('ProjectName'));
    }
    
    @isTest
    static void saveTimesheetRecordsTest() {
        
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'shrikant@gmail.com'
        );
        insert testEmployee;
        
        Date selectedDate = Date.today(); 
        
        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = selectedDate
        );
        insert testAttendance;
        String jsonString = '{"DRS":[{"TimeSheetRecordId":"","TimeSheetDate":"' + selectedDate + '","EmployeeId":"' + testEmployee.Id + '","TaskDescription":"jkil","TicketNo":"N2G-123","ProjectName":"N2G","EstimatedHour":"","ActualHour":"1","TaskType":"Documentation"}],"Date":"' + selectedDate + '"}';
        Object timesheetList = (Object)JSON.deserializeUntyped(jsonString);
        
        Test.startTest();
        timesheetTableController.saveTimesheetRecords(timesheetList, testEmployee.Id, selectedDate);
        Test.stopTest();
        
        List<Timesheet__c> timesheetRecords = [SELECT Id FROM Timesheet__c];
        System.assertEquals(1, timesheetRecords.size());
    }
    
    @isTest
    static void timesheetTableController() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'shrikant@gmail.com';
        
        insert testEmployee;
        
        String jsonString = '{"DRS":[{"TimeSheetRecordId":"","TimeSheetDate":"2023-09-25","EmployeeId":"' + testEmployee.Id + '","TaskDescription":"jkil","TicketNo":"N2G-123","ProjectName":"N2G","EstimatedHour":"","ActualHour":"1","TaskType":"Documentation"}],"Date":"2023-09-25"}';
        Object timesheetList = (Object)JSON.deserializeUntyped(jsonString);
        Date selectedDate = Date.newInstance(2023, 9, 1);
        
        Attendance__c attendanceRecord = new Attendance__c();
        attendanceRecord.Employee__c = testEmployee.Id;
        attendanceRecord.Date__c = selectedDate;
        insert attendanceRecord;
        
        Test.startTest();
        
        timesheetTableController.saveTimesheetRecords(timesheetList, testEmployee.Id, selectedDate);
        
        Test.stopTest();
        
        List<Timesheet__c> timesheetRecords = [SELECT Id, Date__c, Employee__c, Project_Name__c, Task_Type__c, Ticket_No__c, Task_Description__c, Estimated_Hours__c, Actual_Hours__c, Total_Hours__c, Attendance__c FROM Timesheet__c];
        System.assertEquals(1, timesheetRecords.size());
        
    }
    
    @isTest
    static void testgetAttendanceData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'shrikant@gmail.com'
        );
        insert testEmployee;
        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = Date.today() 
            
        );
        insert testAttendance;
        List<Attendance__c> Attend = timesheetTableController.getAttendanceData(null);
        System.assertNotEquals(null, Attend);
    }
    
    @isTest
    static void getEployeeRole() {
    Contact con = new Contact(LastName='test', Email='shrikant@gmail.com');
    insert con;

    List<Employee__c> Employees = new List<Employee__c>();

    Employee__c testEmployee1 = new Employee__c();
    testEmployee1.Name = 'TEST';
    testEmployee1.Last_Name__c = 'Test1';
    testEmployee1.Username__c = 'testuser';
    testEmployee1.Password__c = 'Admin@123';
    testEmployee1.Email__c = 'shrikant@gmail.com';
    testEmployee1.Role__c = 'Project Manager';
    Employees.add(testEmployee1); 

    Employee__c testEmployee2 = new Employee__c();
    testEmployee2.Name = 'TESTR';
    testEmployee2.Last_Name__c = 'Test1';
    testEmployee2.Username__c = 'testuserr';
    testEmployee2.Password__c = 'Admin@r123';
    testEmployee2.Email__c = 'shrikant1@gmail.com';
    testEmployee2.Role__c = 'Project Manager';
    Employees.add(testEmployee2);

    insert Employees;
        
    Test.startTest();
    List<Employee__c> result = timesheetTableController.getEployeeRole();
    Test.stopTest();
}

    
    @isTest
	static void getProjectWiseHours() {
    Contact con = new Contact(LastName='test', Email='shrikant@gmail.com');
    insert con;

    Project_Name__c project = new Project_Name__c(Name = 'HRMS', isBillable__c = true);
    insert project;

    Project_Alloted_Hour__c proALLotedHr = new Project_Alloted_Hour__c(
        Alloted_Hours__c = 5,
        Date__c = Date.today(),
        Project__c = project.Id
    );
    insert proALLotedHr;

    Employee__c testEmployee = new Employee__c(
        Name = 'TEST',
        Username__c = 'testuser',
        Password__c = 'Admin@123',
        Email__c = 'shrikant@gmail.com'
    );
    insert testEmployee;

    Attendance__c testAttendance = new Attendance__c(
        Employee__c = testEmployee.Id,
        Date__c = Date.today()
    );
    insert testAttendance;

    Timesheet__c timesheetrecord = new Timesheet__c(
        Attendance__c = testAttendance.Id,
        Employee__c = testEmployee.Id,
        IsLocked__c = false,
        Ticket_No__c = 'opop',
        Task_Type__c = 'Standup Call',
        Estimated_Hours__c = '2',
        Actual_Hours__c = '1.5',
        Project_Name__c = project.Name,
        Task_Description__c = 'Test Task Description',
        Date__c = Date.today()
    );
    insert timesheetrecord;
        
        Timesheet__c anotherTimesheetWithProject = new Timesheet__c(
        Attendance__c = testAttendance.Id,
        Employee__c = testEmployee.Id,
        IsLocked__c = false,
        Ticket_No__c = 'opop',
        Task_Type__c = 'Standup Call',
        Estimated_Hours__c = '2',
        Actual_Hours__c = '2.5',  
        Project_Name__c = project.Name,
        Task_Description__c = 'Another Test Task Description',
        Date__c = Date.today()
    );
    insert anotherTimesheetWithProject;
    Test.startTest();
    String result = timesheetTableController.getProjectWiseHours(Date.today());
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
}
    @isTest
    static void getProjectAllotedHours() {
        Date selectedDate = Date.today();
        
        Contact con = new Contact(LastName='test', Email='shrikant@gmail.com');
   		 insert con;

    	Project_Name__c project = new Project_Name__c(Name = 'HRMS', isBillable__c = true);
    	insert project;

    	Project_Alloted_Hour__c proALLotedHr = new Project_Alloted_Hour__c(
        Alloted_Hours__c = 5,
        Date__c = Date.today(),
        Project__c = project.Id
    	);
    	insert proALLotedHr;

    	Employee__c testEmployee = new Employee__c(
        Name = 'TEST',
        Username__c = 'testuser',
        Password__c = 'Admin@123',
        Email__c = 'shrikant@gmail.com'
    	);
    	insert testEmployee;

   	    Attendance__c testAttendance = new Attendance__c(
        Employee__c = testEmployee.Id,
        Date__c = Date.today()
    	);
    	insert testAttendance;
	
        list<Timesheet__c> timesheetlist = new list<Timesheet__c>();
        Timesheet__c timesheetrecord = new Timesheet__c(
        Attendance__c = testAttendance.Id,
        Employee__c = testEmployee.Id,
        IsLocked__c = false,
        Ticket_No__c = 'opop',
        Task_Type__c = 'Standup Call',
        Estimated_Hours__c = '2',
        Actual_Hours__c = '1.5',
        Project_Name__c = project.Name,
        Task_Description__c = 'Test Task Description',
        Date__c = Date.today()
    	);
        timesheetlist.add(timesheetrecord);
        Timesheet__c anotherTimesheetWithProject = new Timesheet__c(
        Attendance__c = testAttendance.Id,
        Employee__c = testEmployee.Id,
        IsLocked__c = false,
        Ticket_No__c = 'opop',
        Task_Type__c = 'Standup Call',
        Estimated_Hours__c = '2',
        Actual_Hours__c = '2.5', 
        Project_Name__c = project.Name,
        Task_Description__c = 'Another Test Task Description',
        Date__c = Date.today()
    );
        timesheetlist.add(anotherTimesheetWithProject);
		insert timesheetlist;
        List<Project_Alloted_Hour__c> result = timesheetTableController.getProjectAllotedHours(selectedDate);
    }

    @isTest
    static void getTimesheetRecordsBasedonDateTest() {
        Contact con=new Contact(LastName='test',Email='shrikant@gmail.com');
        insert con;
        
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testuser';
        //testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'shrikant@gmail.com';
        insert testEmployee;
        
        Date selectedDate = Date.today(); 
        
        Attendance__c testAttendance = new Attendance__c();
        testAttendance.Employee__c = testEmployee.Id;
        testAttendance.Date__c = selectedDate;
        insert testAttendance;
        
        Timesheet__c timesheetrecord = new Timesheet__c();
        timesheetrecord.Attendance__c = testAttendance.Id;
        timesheetrecord.Employee__c = testEmployee.Id;
        timesheetrecord.IsLocked__c = false;
        timesheetrecord.Ticket_No__c = 'opop';
        timesheetrecord.Task_Type__c = 'Standup Call';
        timesheetrecord.Estimated_Hours__c = '2';
        timesheetrecord.Actual_Hours__c = '1.5';
        timesheetrecord.Project_Name__c = 'N2G';
        timesheetrecord.Task_Description__c = 'Test Task Description';
        timesheetrecord.Date__c = selectedDate;
        insert timesheetrecord;
        
        List<Timesheet__c> timesheetrecordList = new List<Timesheet__c>();
        Timesheet__c timesheetrecord1 = new Timesheet__c();
        timesheetrecord1.Attendance__c = testAttendance.Id;
        timesheetrecord1.Employee__c = testEmployee.Id;
        timesheetrecord1.IsLocked__c = false;
        timesheetrecord1.Ticket_No__c = 'opop';
        timesheetrecord1.Task_Type__c = 'Standup Call';
        timesheetrecord1.Estimated_Hours__c = '2';
        timesheetrecord1.Actual_Hours__c = '1.5';
        timesheetrecord1.Project_Name__c = 'N2G';
        timesheetrecord1.Task_Description__c = 'Test Task Description';
        timesheetrecord1.Date__c = selectedDate;
        insert timesheetrecord1;
        timesheetrecordList.add(timesheetrecord1);
        
        Test.startTest();
        timesheetTableController.getTimesheetRecordsBasedonDate(selectedDate, testEmployee.Id);
        timesheetTableController.getTimesheet(testEmployee.Id);
        timesheetTableController.deleteTimeSheetRecord(timesheetrecord.Id);        
        timesheetTableController.getTimesheetRecords(testEmployee.Id);
        timesheetTableController.getIsLockedFieldValue(testEmployee.Id);
        Test.stopTest();
    }
    @isTest
    static void testgetEmployeeData() {
        Contact con=new Contact(LastName='test',Email='shrikant@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testemail@gmail.com';
        testEmployee.Email__c = 'shrikant@gmail.com';
        testEmployee.Number_of_Leaves__c = 10;
        
        insert testEmployee;
        
        Employee__c result = timesheetTableController.getEmployeeData(testEmployee.Id);
        
        System.assertNotEquals(null, result);
        
    }
    @isTest
    static void getProjectAllottedHoursTest(){
        Contact con=new Contact(LastName='test',Email='shrikant@gmail.com');
        insert con;
        
        Project_Name__c project = new Project_Name__c();
        project.Name = 'HRMS';
        project.isBillable__c = true;
        
        insert project;
        
        Project_Alloted_Hour__c proALLotedHr = new Project_Alloted_Hour__c();
        proALLotedHr.Alloted_Hours__c = 5;
        proALLotedHr.Date__c = Date.today();
        proALLotedHr.Project__c = project.Id;
        
        insert proALLotedHr;
        
        List<Project_Alloted_Hour__c> proALLotedHrList = new List<Project_Alloted_Hour__c>();
        Project_Alloted_Hour__c proALLotedHr1 = new Project_Alloted_Hour__c();
        proALLotedHr1.Alloted_Hours__c = 5;
        proALLotedHr1.Date__c = Date.today();
        proALLotedHr1.Project__c = project.Id;
        insert proALLotedHr1;
        proALLotedHrList.add(proALLotedHr1);
        
        proALLotedHr1.Alloted_Hours__c = 40;
        update proALLotedHr1;
        
        delete proALLotedHr;
        Test.startTest();
        
        List<Project_Alloted_Hour__c> allotedHoursList = timesheetTableController.getProjectAllottedHours(project.Id);
        List<Project_Alloted_Hour__c> allotedHrList = timesheetTableController.getProjectAllotedHours(proALLotedHr.Date__c);
        List<Project_Alloted_Hour__c> newAllotedHoursList = new List<Project_Alloted_Hour__c>{
            new Project_Alloted_Hour__c( 
                Alloted_Hours__c = 5,
                Date__c = Date.today(),
                Project__c = project.Id
            )
                };
        timesheetTableController.saveProjectAllottedHours(proALLotedHrList);
        timesheetTableController.insertProjectAllotedHour(proALLotedHr.Date__c, proALLotedHr.Alloted_Hours__c, project.Id);
        Test.stopTest();         
    }
    
  
    
    @isTest
    static void testDeleteProjectAllottedHour() {
        Contact con=new Contact(LastName='test',Email='shrikant@gmail.com');
        insert con;
        
        Project_Name__c project = new Project_Name__c();
        project.Name = 'HRMS';
        project.isBillable__c = true;
        
        insert project;
        
        Project_Alloted_Hour__c testRecord = new Project_Alloted_Hour__c();
        testRecord.Alloted_Hours__c = 5;
        testRecord.Date__c = Date.today();
        testRecord.Project__c = project.Id;
        
        insert testRecord;
        
        Test.startTest();
        timesheetTableController.deleteProjectAllottedHour(testRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetProjects() {
        List<Project_Name__c> testProjects = new List<Project_Name__c>();
        for (Integer i = 0; i < 3; i++) {
            testProjects.add(new Project_Name__c(
                Name = 'Test Project ' + i,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(10),
                isBillable__c = true
            ));
        }
        insert testProjects;
        
        Test.startTest();
        List<Project_Name__c> result = timesheetTableController.getProjects();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Returned list should not be null');
        System.assertEquals(3, result.size(), 'Unexpected number of projects returned');
        
        for (Project_Name__c project : result) {
            System.assertNotEquals(null, project.Id, 'Project Id should be populated');
            System.assertNotEquals(null, project.Name, 'Project Name should be populated');
            System.assertNotEquals(null, project.Main_Project_Name__c, 'Main Project Name should be populated');
            System.assertNotEquals(null, project.Start_Date__c, 'Start Date should be populated');
            System.assertNotEquals(null, project.End_Date__c, 'End Date should be populated');
            System.assertEquals(true, project.isBillable__c, 'isBillable should be true');
        }
    }
    
    @isTest
    static void testDeleteProjectAllotedHourRecord() {        
        Contact con=new Contact(LastName='test',Email='shrikant@gmail.com');
        insert con;
        
        Project_Name__c project = new Project_Name__c();
        project.Name = 'HRMS';
        project.isBillable__c = true;
        
        insert project;
        Project_Alloted_Hour__c proALLotedHr = new Project_Alloted_Hour__c();
        proALLotedHr.Alloted_Hours__c = 5;
        proALLotedHr.Date__c = Date.today();
        proALLotedHr.Project__c = project.Id;
        
        insert proALLotedHr;
        
        Test.startTest();
        String result = timesheetTableController.deleteProjectAllotedHourRecord(proALLotedHr.Id);
        Test.stopTest();
    }

  
    @isTest
    static void testDeleteProjectAllotedHourRecordWithBlankId() {
        Test.startTest();
        String result = timesheetTableController.deleteProjectAllotedHourRecord('');
        Test.stopTest();
        
    }
    
    @isTest
	static void saveProjectAllotedRecordsTest() {
    // Create test data
    Contact con = new Contact(LastName='test', Email='shrikant@gmail.com');
    insert con;

    Employee__c testEmployee = new Employee__c(
        Name = 'TEST',
        Username__c = 'testuser',
        Password__c = 'Admin@123',
        Email__c = 'shrikant@gmail.com'
    );
    insert testEmployee;

    Date selectedDate = Date.today();

    Attendance__c testAttendance = new Attendance__c(
        Employee__c = testEmployee.Id,
        Date__c = selectedDate
    );
    insert testAttendance;

    Project_Name__c project = new Project_Name__c();
    project.Name = 'HRMS';
    project.isBillable__c = true;
    insert project;
    String insertJsonString = '{"Pmdd":[{"Id":"","Project__c":"' + project.Id + '","Alloted_Hours__c":"123","No_of_Dev_QA_s__c":"2","PM_Billable_Hours__c":"5","TotalHR__c":"10"}],"Date":"' + selectedDate + '"}';
    Object insertTimesheetList = (Object)JSON.deserializeUntyped(insertJsonString);

    Project_Alloted_Hour__c existingRecord = new Project_Alloted_Hour__c(
        Project__c = project.Id,
        Alloted_Hours__c = 50, 
        Date__c = selectedDate
    );
    insert existingRecord;

    String updateJsonString = '{"Pmdd":[{"Id":"' + existingRecord.Id + '","Project__c":"' + project.Id + '","Alloted_Hours__c":"150","No_of_Dev_QA_s__c":"3","PM_Billable_Hours__c":"8","TotalHR__c":"15"}],"Date":"' + selectedDate + '"}';
    Object updateTimesheetList = (Object)JSON.deserializeUntyped(updateJsonString);

    Test.startTest();
    String updateResult = timesheetTableController.saveProjectAllotedRecords(updateTimesheetList, selectedDate, false);
    Test.stopTest();

}
  
    @isTest
    static void getProjectNamesTest(){
                
        Contact con=new Contact(LastName='test',Email='shrikant@gmail.com');
        insert con;
        
        Project_Name__c project = new Project_Name__c();
        project.Name = 'HRMS';
        project.isBillable__c = true;
        
        insert project;        
                
        Test.startTest();
        timesheetTableController.getProjectNames();
        Test.stopTest();

       
        
    }
    
}