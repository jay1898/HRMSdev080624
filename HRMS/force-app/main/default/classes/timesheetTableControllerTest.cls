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
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;
        Attendance__c testAttendance = new Attendance__c();
        testAttendance.Employee__c = testEmployee.Id;
        testAttendance.Date__c = Date.today();
        insert testAttendance;
        
        Project_Name__c testProject = new Project_Name__c();
        testProject.Name = 'Project check';
        //Main_Project__c = testProject.Name;
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
        // Create necessary test data
        // 
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;
        
        Date selectedDate = Date.today(); 
        
        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = selectedDate
        );
        insert testAttendance;
        
        // Prepare input data
        String jsonString = '{"DRS":[{"TimeSheetRecordId":"","TimeSheetDate":"' + selectedDate + '","EmployeeId":"' + testEmployee.Id + '","TaskDescription":"jkil","TicketNo":"N2G-123","ProjectName":"N2G","EstimatedHour":"","ActualHour":"1","TaskType":"Documentation"}],"Date":"' + selectedDate + '"}';
        Object timesheetList = (Object)JSON.deserializeUntyped(jsonString);
        
        // Call the method to be tested
        Test.startTest();
        timesheetTableController.saveTimesheetRecords(timesheetList, testEmployee.Id, selectedDate);
        Test.stopTest();
        
        // Verify the results
        List<Timesheet__c> timesheetRecords = [SELECT Id FROM Timesheet__c];
        System.assertEquals(1, timesheetRecords.size());
    }
    @isTest
    static void timesheetTableController() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create test data
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'testemail@gmail.com';
        
        insert testEmployee;
        
        String jsonString = '{"DRS":[{"TimeSheetRecordId":"","TimeSheetDate":"2023-09-25","EmployeeId":"' + testEmployee.Id + '","TaskDescription":"jkil","TicketNo":"N2G-123","ProjectName":"N2G","EstimatedHour":"","ActualHour":"1","TaskType":"Documentation"}],"Date":"2023-09-25"}';
        Object timesheetList = (Object)JSON.deserializeUntyped(jsonString);
        Date selectedDate = Date.newInstance(2023, 9, 1);
        
        
        
        // Create test Attendance__c record
        Attendance__c attendanceRecord = new Attendance__c();
        attendanceRecord.Employee__c = testEmployee.Id;
        attendanceRecord.Date__c = selectedDate;
        insert attendanceRecord;
        
        Test.startTest();
        
        // Call the method to be tested
        timesheetTableController.saveTimesheetRecords(timesheetList, testEmployee.Id, selectedDate);
        
        Test.stopTest();
        
        // Verify the results
        List<Timesheet__c> timesheetRecords = [SELECT Id, Date__c, Employee__c, Project_Name__c, Task_Type__c, Ticket_No__c, Task_Description__c, Estimated_Hours__c, Actual_Hours__c, Total_Hours__c, Attendance__c FROM Timesheet__c];
        
        System.assertEquals(1, timesheetRecords.size());
        
    }
    @isTest
    static void testgetAttendanceData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;
        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = Date.today() // Use today's date for testing
            
        );
        insert testAttendance;
        //String employeeId = testEmployee.Id;
        List<Attendance__c> Attend = timesheetTableController.getAttendanceData(testEmployee.Id);
        System.assertNotEquals(null, Attend);
    }
    @isTest
    static void getTimesheetRecordsBasedonDateTest() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testuser';
        //testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'testemail@gmail.com';
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
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testemail@gmail.com';
        testEmployee.Email__c = 'testemail@gmail.com';
        testEmployee.Number_of_Leaves__c = 10;
        
        insert testEmployee;
        
        Employee__c result = timesheetTableController.getEmployeeData(testEmployee.Id);
        
        System.assertNotEquals(null, result);
        
    }
    @isTest
    static void getProjectAllottedHoursTest(){
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
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
        
        // Get the existing Project_Alloted_Hour__c records
        List<Project_Alloted_Hour__c> allotedHoursList = timesheetTableController.getProjectAllottedHours(project.Id);
        List<Project_Alloted_Hour__c> allotedHrList = timesheetTableController.getProjectAllotedHours(proALLotedHr.Date__c);
        // Create new Project_Alloted_Hour__c records
        List<Project_Alloted_Hour__c> newAllotedHoursList = new List<Project_Alloted_Hour__c>{
            new Project_Alloted_Hour__c( 
                Alloted_Hours__c = 5,
                Date__c = Date.today(),
                Project__c = project.Id
            )
                // Add more records as needed
                };
                    timesheetTableController.saveProjectAllottedHours(proALLotedHrList);
        timesheetTableController.insertProjectAllotedHour(proALLotedHr.Date__c, proALLotedHr.Alloted_Hours__c, project.Id);
        Test.stopTest();         
    }
    @isTest
    static void testDeleteProjectAllottedHour() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
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
        
        // Call the method to delete the test record
        Test.startTest();
        timesheetTableController.deleteProjectAllottedHour(testRecord.Id);
        Test.stopTest();
        
        // Attempt to retrieve the deleted record
        //Project_Alloted_Hour__c deletedRecord = [SELECT Id FROM Project_Alloted_Hour__c WHERE Id = :testRecord.Id LIMIT 1];
        
        // Assert that the record no longer exists
        //System.assertEquals(null, deletedRecord, 'Record should be deleted');
    }
    @isTest
    static void testGetProjects() {
        // Create test data
        List<Project_Name__c> testProjects = new List<Project_Name__c>();
        for (Integer i = 0; i < 3; i++) {
            testProjects.add(new Project_Name__c(
                Name = 'Test Project ' + i,
                //Main_Project_Name__c = 'Main Project ' + i,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(10),
                isBillable__c = true
            ));
        }
        insert testProjects;
        
        // Call the method to get projects
        Test.startTest();
        List<Project_Name__c> result = timesheetTableController.getProjects();
        Test.stopTest();
        
        // Assert that the returned list is not null and contains the expected number of projects
        System.assertNotEquals(null, result, 'Returned list should not be null');
        System.assertEquals(3, result.size(), 'Unexpected number of projects returned');
        
        // Assert that each project has the expected fields populated
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
        
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
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
        
        // Call the method to delete the test record
        Test.startTest();
        String result = timesheetTableController.deleteProjectAllotedHourRecord(proALLotedHr.Id);
        Test.stopTest();
        
        /*// Attempt to retrieve the deleted record
Project_Alloted_Hour__c deletedRecord = [SELECT Id FROM Project_Alloted_Hour__c WHERE Id = :proALLotedHr.Id LIMIT 1];

// Assert that the record no longer exists
System.assertEquals(null, deletedRecord, 'Record should be deleted');

// Assert that the method returns 'success'
System.assertEquals('success', result, 'Method should return success');*/
    }
    @isTest
    static void testDeleteProjectAllotedHourRecordWithBlankId() {
        // Call the method with a blank Id
        Test.startTest();
        String result = timesheetTableController.deleteProjectAllotedHourRecord('');
        Test.stopTest();
        
        // Assert that the method returns 'unsuccess'
        //System.assertEquals('unsuccess', result, 'Method should return unsuccess');
    }
    @isTest
    static void saveProjectAllotedRecordsTest() {
        // Create necessary test data
        // 
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
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
        
        // Prepare input data
        String jsonString = '{"Pmdd":[{"TimeSheetRecordId":"","TimeSheetDate":"' + selectedDate + '","EmployeeId":"' + testEmployee.Id + '","Project__c":"'+ project.Id +'","Alloted_Hours__c":"123"}],"Date":"' + selectedDate + '"}';
        Object timesheetList = (Object)JSON.deserializeUntyped(jsonString);
        
        // Call the method to be tested
        Test.startTest();
        timesheetTableController.saveProjectAllotedRecords(timesheetList, selectedDate);
        Test.stopTest();
        
        // Verify the results
        //List<Timesheet__c> timesheetRecords = [SELECT Id FROM Timesheet__c];
        //System.assertEquals(1, timesheetRecords.size());
    }
    
    @isTest
    static void getProjectNamesTest(){
                
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
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