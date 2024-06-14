@isTest
private class EmployeeControllerTest {
    
    @isTest
    static void testGetEmployeeByUsernameAndPassword() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST EMPLOYEE';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'testemail@gmail.com';
        testEmployee.Clocked_In_Out_Status__c = 'Clock-in';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556622266';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'TESTEMOP';
        testEmployee.Last_Name__c = 'TESTEMOP';
        testEmployee.Personal_Email__c = 'johnhapkin34444444@gmail.com';
        insert testEmployee;
        system.debug('testEmployee------------->'+testEmployee);
        
        Attendance__c testAttendance = new Attendance__c();
        testAttendance.Employee__c = testEmployee.Id;
        testAttendance.Date__c = Date.today();
        insert testAttendance;
                
        Test.startTest();        
        String result = EmployeeController.getEmployeeByUsernameAndPassword(testEmployee.Username__c, testEmployee.Password__c);
        //System.assertNotEquals(null, result);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        upsert testEmployee;
        
        
        String result = EmployeeController.updateData(testEmployee.Id, 'Clock-in');
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetNotificationInformation() {
        // Create test data
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = 'TTtestuser01@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert testUser;
        
        /*  Notification__c notification1 = new Notification__c(
Type__c = 'Banner',
Group_Label__c = 'Group 1',
Order__c = 1,
Active__c = true
);
insert notification1;

// Assign notification to the user
Notification__c notification2 = new Notification__c();
notification2.Type__c = 'Side-Panel';
notification2.Group_Label__c = 'Group 2';
notification2.Order__c = 2;
notification2.Active__c = true;
//Employee__c = testUser.Id

insert notification2;*/
        
        Test.startTest();
        EmployeeController.getNotificationInformation(testUser.Username);
        Test.stopTest();
        
        // Assert that the method returns the expected number of notifications
        //System.assertEquals(2, notifications.size(), 'Number of notifications returned is incorrect');
        
        // You can add more specific assertions if needed
    }
    
    @isTest
    static void testGetUserRecordsDetails() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST EMPLOYEE';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'testemail@gmail.com';
        testEmployee.Date_of_Birth__c = Date.today();
        testEmployee.Emergency_Contact_No__c = '3454556622266';
        testEmployee.Gender__c = 'Male';
        testEmployee.First_Name__c = 'TESTEMOP';
        testEmployee.Last_Name__c = 'TESTEMOP';
        testEmployee.Personal_Email__c = 'johnhapkin34444444@gmail.com';
        insert testEmployee;
        
        Employee__c result = EmployeeController.getUserRecordsDetails(testEmployee.Username__c);
        
        System.assertNotEquals(null, result);
        
    }
    
    @isTest
    static void testUpdateEmployeeRecord() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
			Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        Employee__c updatedEmployee = EmployeeController.updateEmployeeRecord(testEmployee.Username__c, true);
        System.assertNotEquals(null, updatedEmployee);
    }
    
    @isTest
    static void testInsertClockinRecords() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
			Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Create a test Attendance__c record related to the testEmployee
        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = Date.today() // Use today's date for testing
            // Total_Clock_In_Hours__c = 0 // Initialize the Total_Clock_In_Hours__c field
        );
        insert testAttendance;
        // Call the insertClockinRecords method
        String result = EmployeeController.insertClockinRecords(testEmployee.Id);
        
        // Verify that the method returned a result
        System.assertNotEquals(null, result);
        
        // You can add more assertions based on the expected outcomes
        // Example: System.assertEquals('expectedValue', actualValue);
        
        // Query the created Clock_In_Out__c record to ensure it was inserted
        Clock_In_Out__c insertedRecord = [SELECT Id FROM Clock_In_Out__c WHERE Employee__c = :testEmployee.Id];
        System.assertNotEquals(null, insertedRecord);
    }
    
    @isTest
    static void testUpdateClockoutRecords() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create a test Employee__c record
        Attendance__c testAtt = new Attendance__c(
            Date__c = date.Today()      
        );
        Insert testAtt;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
			Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
            
        );
        insert testEmployee;
        
        // Create a test Clock_In_Out__c record
        Clock_In_Out__c testClockInOut = new Clock_In_Out__c(
            Employee__c = testEmployee.Id,
            Clock_In_Time__c = Datetime.now().addMinutes(-60), // Clock in an hour ago
            Clock_Out_Time__c = null, // Clock out time is null initially
            Attendance__c = testAtt.Id
        );
        insert testClockInOut;
        
        // Call the updateClockoutRecords method
        String result = EmployeeController.updateClockoutRecords(testEmployee.Id, Datetime.now());
        
        // Verify that the method returned a result
        System.assertNotEquals(null, result);
        
    }
    @isTest
    static void testGetWFHData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Call the getWFHData method
        Map<String, Object> result = EmployeeController.getWFHData();
        System.assertNotEquals(null, result);
        
        
    }
    
    @isTest
    static void testGetLeaveData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Call the getLeaveData method
        Map<String, Object> result = EmployeeController.getLeaveData();
        
        // Verify that the method returned a result
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testSaveWFHData(){
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        List<Employee__c> EmployeeList = new List<Employee__c>();
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TESTRTTDFDDDS',
            Username__c = 'testuser1',
            Password__c = 'Admin@1231',
            Email__c = 'testemail@gmail1.com',
			Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        EmployeeList.add(testEmployee);
        
        Employee__c testEmployee1 = new Employee__c(
            Name = 'TESTRTGSSSSS',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
			Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        EmployeeList.add(testEmployee1);
        
        // Insert the records without specifying IDs
        if (!EmployeeList.isEmpty()) {
            insert EmployeeList;
        }
        
        // Create a test input map for wfhRequest
        Map<String, Object> wfhRequest = new Map<String, Object>{
            'FromDate' => '2023-09-25',
                'ToDate' => '2023-09-26',
                'Reason' => 'Test Reason',
                'wfhType' => 'ValidPicklistValue' // Use a valid picklist value
                
                };
                    Decimal numberOfDays = 2;
        
        // Call the saveWFHData method
        try {
            String result = EmployeeController.saveWFHData(wfhRequest, testEmployee.Id,numberOfDays);
            
            // Verify that the method returned a result
            System.assertNotEquals(null, result);
        } catch (Exception ex) {
            // Print the exception message for debugging
            System.debug('Exception Message: ' + ex.getMessage());
        }
    }
    
    @isTest
    static void testSaveLeaveData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
			Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        Leave_Request__c leaveReqObj =  new Leave_Request__c ();
        leaveReqObj.To_Date__c = Date.Today();
        leaveReqObj.From_Date__c =Date.Today();
        leaveReqObj.Reason_for_Leave__c	= 'Test Reason';
        leaveReqObj.Leave_Type__c = 'Paid Leave';
        leaveReqObj.Employee__c = testEmployee.Id;
        Insert leaveReqObj;
        
        Decimal numberOfDays = 2;
        Decimal paidLeave = 2;
        Decimal unpaidLeave = 2;
        
        String fromDate = '2023-01-01'; 
        String toDate = '2023-01-03';
        String reason = 'Test Reason';
        String leaveDuration = 'Full Day';
        String fromDateLeaveDurationOption = '2023-01-01';
        String toDateleaveDurationOption = '2023-01-02';
        
        String sampleJson = '{"FromDate": "2023-01-01", "ToDate": "2023-01-03", "Reason": "Test Reason", "leaveDuration": "Full Day", "fromDateLeaveDurationOption": "First half", "toDateleaveDurationOption": "First half"}';
        
        try {
            String result = EmployeeController.saveLeaveData(
                (Object)JSON.deserializeUntyped(sampleJson),
                testEmployee.Id,
                numberOfDays,
                paidLeave,
                unpaidLeave
            );
            // Verify that the method returned a result
            System.assertNotEquals(null, result);
            
            // You can add more assertions based on the expected outcomes
            // Example: System.assertEquals('expectedValue', actualValue);
        } catch (Exception ex) {
            // Print the exception message for debugging
            System.debug('Exception Message: ' + ex.getMessage());
        }
        //String result = EmployeeController.saveLeaveData(leaveRequest);
        
        // Verify that the method returned a result
        //System.assertNotEquals(null, result);
        
        // You can add more assertions based on the expected outcomes
        // Example: System.assertEquals('expectedValue', actualValue);
    }
    
    @isTest
    static void testUpdateClockOutTime() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
			Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
            
        );
        insert testEmployee;
        
        Attendance__c testAtt = new Attendance__c(
            Date__c = date.Today()      
        );
        Insert testAtt;
        
        // Create a test Clock_In_Out__c record
        Clock_In_Out__c testClockInOut = new Clock_In_Out__c(
            Employee__c = testEmployee.Id,
            Clock_In_Time__c = Datetime.now().addMinutes(-60), // Clock in an hour ago
            Clock_Out_Time__c = null, // Clock out time is null initially
            Attendance__c = testAtt.Id
        );
        insert testClockInOut;
        
        // Call the updateClockOutTime method
        EmployeeController.updateClockOutTime(testEmployee.Id, Datetime.now().format('yyyy-MM-dd HH:mm:ss'));
        EmployeeController.getClockInTime(testEmployee.Id);
        testClockInOut = [SELECT Clock_Out_Time__c FROM Clock_In_Out__c WHERE Id = :testClockInOut.Id];
        System.assertNotEquals(null, testClockInOut.Clock_Out_Time__c);
        
    }
    
    @isTest
    static void testGetClockInOutData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Attendance__c testAtt = new Attendance__c(
            Date__c = date.Today()      
        );
        Insert testAtt;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        Clock_In_Out__c testClockInOut = new Clock_In_Out__c(
            Employee__c = testEmployee.Id,
            Clock_In_Time__c = Datetime.now().addMinutes(-60), 
            Clock_Out_Time__c = null, 
            Attendance__c = testAtt.Id
        );
        insert testClockInOut;
        
        List<Clock_In_Out__c> result = EmployeeController.getClockInOutData(testEmployee.Id);
        
        System.assertNotEquals(null, result);
        
    }

    @isTest
    static void testGetUserEmailAndSendEmail() {
        // Create a test contact and related task
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;

        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Password__c = 'Admin@123',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;

        // Use DML to create an EmailMessage linked to the Task via an email service
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {'test@example.com'});
        email.setSubject('Test Email');
        email.setPlainTextBody('This is a test email.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        EmailMessage createdEmailMessage = [SELECT Id, ActivityId FROM EmailMessage WHERE ToAddress = 'test@example.com' LIMIT 1];
        System.assertNotEquals(null, createdEmailMessage, 'The email message should be created');

        Test.startTest();
        String result = EmployeeController.getUserEmailAndSendEmail(testEmployee.Username__c);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdatePassword() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        String result = EmployeeController.updatePassword('testuser', 'newpassword');
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testgetAttendanceTotalClockInHours() {
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
            
        );
        
        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = Date.today() 
        );
        insert testAttendance;
        
        String result = EmployeeController.getAttendanceTotalClockInHours(testEmployee.Id);
    }
    
    @isTest
    static void testGetWorkFromHomeRecords() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
            
        );
        
        Work_From_Home__c testRecord = new Work_From_Home__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(5),
            Reason__c = 'Test Reason',
            Applied_WFH_Date__c = Date.today(),
            Work_From_Home_Type__c = 'First Half WFH',
            Employee__c = testEmployee.Id,
            Status__c = 'Pending'
        );
        
        Test.startTest();
        List<Work_From_Home__c> result = EmployeeController.getWorkFromHomeRecords(testEmployee.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void getLeaveCountByType(){
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        //list<Leave_Request__c> NewEmplist = new list<Leave_Request__c>();
        Employee__c testEmployee = new Employee__c(
            Name = 'TREEEEYYYYYYYYRRRDDS',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        Leave_Request__c leaveRequest1 = new Leave_Request__c(
            Employee__c = testEmployee.Id,
            Leave_Type__c = 'Paid Leave',
            From_Date__c = Date.today(),
            To_Date__c = Date.today(),
            Reason_for_Leave__c = 'Test Reason',
            Status__c = 'Approved',
            Leave_Duration__c = null 
        );
        insert leaveRequest1;
        
        Leave_Request__c leaveRequest2 = new Leave_Request__c(
            Employee__c = testEmployee.Id,
            Leave_Type__c = 'Sick Leave',
            From_Date__c = Date.today(),
            To_Date__c = Date.today(),
            Reason_for_Leave__c = 'Test Reason',
            Leave_Duration__c = 'Custom',
            Status__c = 'Approved'
        );
        // insert leaveRequest2;
        
        Test.startTest();
        // Call the method under test
        Map<String, Decimal> leaveCountByTypeMap = EmployeeController.getLeaveCountByType(testEmployee.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateWorkFromHomeStatus() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        Work_From_Home__c testRecord = new Work_From_Home__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(5),
            Reason__c = 'Test Reason',
            Applied_WFH_Date__c = Date.today(),
            Work_From_Home_Type__c = 'First Half WFH',
            Employee__c = testEmployee.Id, // Assign the created employee's ID here
            Status__c = 'Pending'
        );
        insert testRecord;
        
        Leave_Request__c leaveReqObj =  new Leave_Request__c ();
        leaveReqObj.To_Date__c = Date.Today();
        leaveReqObj.From_Date__c =Date.Today();
        leaveReqObj.Reason_for_Leave__c	= 'Test Reason';
        leaveReqObj.Leave_Type__c = 'Paid Leave';
        leaveReqObj.Employee__c = testEmployee.Id;
        Insert leaveReqObj;
        
        leaveReqObj.Status__c = 'Pending';
        update leaveReqObj;
        
        Test.startTest();
        String newStatus = 'Approved';
        String updatedStatus = EmployeeController.updateWorkFromHomeStatus(testRecord.Id, newStatus);
        List<Leave_Request__c> lrList = EmployeeController.getLeaveRequestRecords(testRecord.Id);
        Employee__c ep = EmployeeController.getLeaveRequests(testEmployee.Id);
        EmployeeController.getWFHRequests(testEmployee.Id);
        String updateLeave = EmployeeController.updateLeaveRequestStatus(leaveReqObj.Id,leaveReqObj.Status__c);
        Test.stopTest();
        
        System.assertEquals(newStatus, updatedStatus);
        
        Work_From_Home__c updatedRecord = [SELECT Status__c FROM Work_From_Home__c WHERE Id = :testRecord.Id LIMIT 1];
        System.assertEquals(newStatus, updatedRecord.Status__c);
    }
    
    @isTest
    static void testGetNumberOfNonBusinessDays() {
        BusinessHours bHours = [SELECT Id FROM BusinessHours LIMIT 1]; 
        
        Date testStartDate = Date.newInstance(2023, 12, 19); 
        Date testEndDate = Date.newInstance(2023, 12, 31); 
        
        Test.startTest();
        Integer result = EmployeeController.getNumberOfNonBusinessDays(testStartDate.year() + '-' + testStartDate.month() + '-' + testStartDate.day(), 
                                                                       testEndDate.year() + '-' + testEndDate.month() + '-' + testEndDate.day());
        Test.stopTest();
    }
    
    @isTest
    static void testGetEmployeeDetails() {
        // Create and insert test contact
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;
        
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Password__c = 'Admin@123',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Test the getEmployeeDetails method
        Test.startTest();
        Employee__c result = EmployeeController.getEmployeeDetails(testEmployee.Id);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(testEmployee.Id, result.Id, 'The IDs should match');
        System.assertEquals(testEmployee.Email__c, result.Email__c, 'The emails should match');
    }
    
    @isTest
    static void testGetEmployeeAllDetails() {
        // Create and insert test contact
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;
        
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Password__c = 'Admin@123',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Test the getEmployeeAllDetails method
        Test.startTest();
        List<Employee__c> results = EmployeeController.getEmployeeAllDetails(testEmployee.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, results, 'The results should not be null');
        System.assertEquals(1, results.size(), 'The results should contain one employee');
        System.assertEquals(testEmployee.Id, results[0].Id, 'The IDs should match');
        System.assertEquals(testEmployee.Email__c, results[0].Email__c, 'The emails should match');
    }
    
    @isTest
    static void testFetchEmployeeDetails() {
        // Create and insert test contact
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;
        
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Password__c = 'Admin@123',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com',
            Aadhaar_Number__c = '123456789012',
            PAN_Card_Number__c = 'ABCDE1234F'
        );
        insert testEmployee;
        
        // Test the fetchEmployeeDetails method
        Test.startTest();
        List<Employee__c> result = EmployeeController.fetchEmployeeDetails(testEmployee.Id);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(1, result.size(), 'The result list should contain one employee');
        System.assertEquals(testEmployee.Id, result[0].Id, 'The IDs should match');
        System.assertEquals(testEmployee.Email__c, result[0].Email__c, 'The emails should match');
    }
    
    @isTest
    static void testFetchEmpEducationData() {
        // Create and insert test contact
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;
        
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Password__c = 'Admin@123',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Create and insert test employee education records
        Employee_Education__c edu1 = new Employee_Education__c(
            Degree_Name__c = 'Bachelor of Science',
            University_Name__c = 'University A',
            Start_Date__c = Date.today().addYears(-5),
            End_Date__c = Date.today().addYears(-3),
            Employee__c = testEmployee.Id
        );
        insert edu1;
        
        Employee_Education__c edu2 = new Employee_Education__c(
            Degree_Name__c = 'Master of Science',
            University_Name__c = 'University B',
            Start_Date__c = Date.today().addYears(-3),
            End_Date__c = Date.today().addYears(-1),
            Employee__c = testEmployee.Id
        );
        insert edu2;
        
        // Test the fetchEmpEducationData method
        Test.startTest();
        List<Map<String, Object>> eduDetails = EmployeeController.fetchEmpEducationData(testEmployee.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, eduDetails, 'The results should not be null');
        System.assertEquals(2, eduDetails.size(), 'The results list should contain two education records');
        
        Map<String, Object> firstEdu = eduDetails[0];
        System.assertEquals(edu2.Id, firstEdu.get('Id'), 'The IDs should match for the first record');
        System.assertEquals(edu2.Degree_Name__c, firstEdu.get('Degree_Name__c'), 'The degree names should match for the first record');
        
        Map<String, Object> secondEdu = eduDetails[1];
        System.assertEquals(edu1.Id, secondEdu.get('Id'), 'The IDs should match for the second record');
        System.assertEquals(edu1.Degree_Name__c, secondEdu.get('Degree_Name__c'), 'The degree names should match for the second record');
    }
    
    @isTest
    static void testFetchEmpExperienceData() {
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Create and insert test employee experience records
        Employee_Experience__c exp1 = new Employee_Experience__c(
            Position__c = 'Developer',
            Company_Location__c = 'Location A',
            Company_Name__c = 'Company A',
            Join_Date__c = Date.today().addYears(-3),
            Leave_Date__c = Date.today().addYears(-2),
            Employee__c = testEmployee.Id
        );
        insert exp1;
        
        Employee_Experience__c exp2 = new Employee_Experience__c(
            Position__c = 'Senior Developer',
            Company_Location__c = 'Location B',
            Company_Name__c = 'Company B',
            Join_Date__c = Date.today().addYears(-2),
            Leave_Date__c = Date.today().addYears(-1),
            Employee__c = testEmployee.Id
        );
        insert exp2;
        
        // Test the fetchEmpExperienceData method
        Test.startTest();
        List<Map<String, Object>> expDetails = EmployeeController.fetchEmpExperienceData(testEmployee.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, expDetails, 'The results should not be null');
        System.assertEquals(2, expDetails.size(), 'The results list should contain two experience records');
        
        Map<String, Object> firstExp = expDetails[0];
        System.assertEquals(exp2.Id, firstExp.get('Id'), 'The IDs should match for the first record');
        System.assertEquals(exp2.Position__c, firstExp.get('Position__c'), 'The positions should match for the first record');
        
        Map<String, Object> secondExp = expDetails[1];
        System.assertEquals(exp1.Id, secondExp.get('Id'), 'The IDs should match for the second record');
        System.assertEquals(exp1.Position__c, secondExp.get('Position__c'), 'The positions should match for the second record');
    }
    
	@isTest
    static void testUpdateEmployeeDetails() {
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Update details
        Employee__c updatedEmployee = new Employee__c(
            Id = testEmployee.Id,
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        
        // Test the updateEmployeeDetails method
        Test.startTest();
        EmployeeController.updateEmployeeDetails(updatedEmployee);
        Test.stopTest();
        
        // Verify the update
        Employee__c updatedEmp = [SELECT First_Name__c, Last_Name__c FROM Employee__c WHERE Id = :testEmployee.Id];
        System.assertEquals('TESTEMOP', updatedEmp.First_Name__c, 'The first names should match');
        System.assertEquals('TESTEMOP', updatedEmp.Last_Name__c, 'The last names should match');
    }

    @isTest
    static void testUpdateEmpEducationData() {
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Create and insert test education records
        Employee_Education__c edu = new Employee_Education__c(
            Degree_Name__c = 'Bachelor of Science',
            University_Name__c = 'University A',
            Start_Date__c = Date.today().addYears(-5),
            End_Date__c = Date.today().addYears(-3),
            Employee__c = testEmployee.Id
        );
        insert edu;
        
        // Prepare JSON data
        String jsonData = '[{"Id":"' + edu.Id + '","Degree_Name__c":"Updated Bachelor of Science","University_Name__c":"Updated University A","Start_Date__c":"' + Date.today().addYears(-5) + '","End_Date__c":"' + Date.today().addYears(-3) + '"}]';
        
        // Test the updateEmpEducationData method
        Test.startTest();
        EmployeeController.updateEmpEducationData(jsonData);
        Test.stopTest();
        
        // Verify the update
        Employee_Education__c updatedEdu = [SELECT Degree_Name__c, University_Name__c FROM Employee_Education__c WHERE Id = :edu.Id];
        System.assertEquals('Updated Bachelor of Science', updatedEdu.Degree_Name__c, 'The degree names should match');
        System.assertEquals('Updated University A', updatedEdu.University_Name__c, 'The university names should match');
    }

    @isTest
    static void testUpdateEmpExperienceData() {
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Create and insert test experience records
        Employee_Experience__c exp = new Employee_Experience__c(
            Position__c = 'Developer',
            Company_Location__c = 'Location A',
            Company_Name__c = 'Company A',
            Join_Date__c = Date.today().addYears(-3),
            Leave_Date__c = Date.today().addYears(-2),
            Employee__c = testEmployee.Id
        );
        insert exp;
        
        // Prepare JSON data
        String jsonData = '[{"Id":"' + exp.Id + '","Position__c":"Updated Developer","Company_Name__c":"Updated Company A","Company_Location__c":"Updated Location A","Join_Date__c":"' + Date.today().addYears(-3) + '","Leave_Date__c":"' + Date.today().addYears(-2) + '"}]';
        
        // Test the updateEmpExperienceData method
        Test.startTest();
        EmployeeController.updateEmpExperianceData(jsonData);
        Test.stopTest();
        
        // Verify the update
        Employee_Experience__c updatedExp = [SELECT Position__c, Company_Name__c, Company_Location__c FROM Employee_Experience__c WHERE Id = :exp.Id];
        System.assertEquals('Updated Developer', updatedExp.Position__c, 'The positions should match');
        System.assertEquals('Updated Company A', updatedExp.Company_Name__c, 'The company names should match');
        System.assertEquals('Updated Location A', updatedExp.Company_Location__c, 'The company locations should match');
    }
    
    @isTest
    static void testDeleteRecordById() {
        // Create and insert test employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '1234567890',
            Gender__c = 'Male',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Personal_Email__c = 'testuser@example.com'
        );
        insert testEmployee;

        // Create and insert test employee education record
        Employee_Education__c edu = new Employee_Education__c(
            Degree_Name__c = 'Bachelor of Science',
            University_Name__c = 'Test University',
            Start_Date__c = Date.today().addYears(-5),
            End_Date__c = Date.today().addYears(-3),
            Employee__c = testEmployee.Id
        );
        insert edu;

        // Create and insert test employee experience record
        Employee_Experience__c exp = new Employee_Experience__c(
            Position__c = 'Developer',
            Company_Location__c = 'Location A',
            Company_Name__c = 'Company A',
            Join_Date__c = Date.today().addYears(-3),
            Leave_Date__c = Date.today().addYears(-2),
            Employee__c = testEmployee.Id
        );
        insert exp;

        // Test deleting education record
        Test.startTest();
        EmployeeController.deleteRecordById(edu.Id, 'Employee_Education__c');
        Test.stopTest();

    }

    @isTest
    static void testGetAllPicklistValues() {
        // Test the getAllPicklistValues method
        Test.startTest();
        String result = EmployeeController.getAllPicklistValues();
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result, 'The result should not be null');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey('Gender'), 'The result should contain the Gender key');
        System.assert(resultMap.containsKey('BloodGroup'), 'The result should contain the BloodGroup key');
        System.assert(resultMap.containsKey('Nationality'), 'The result should contain the Nationality key');
    }

    @isTest
    static void testPicklistValues() {
        // Test the picklistValues method for Gender field
        Test.startTest();
        Map<String, String> genderValues = EmployeeController.picklistValues('Employee__c', 'Gender__c');
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, genderValues, 'The result should not be null');
        System.assert(genderValues.containsKey('Male'), 'The result should contain Male key');
        System.assert(genderValues.containsKey('Female'), 'The result should contain Female key');
    }
}