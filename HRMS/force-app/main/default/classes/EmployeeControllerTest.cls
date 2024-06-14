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
            Clocked_In_Out_Status__c = 'Clock-in' 
        );
        upsert testEmployee;
        
        
        String result = EmployeeController.updateData(testEmployee.Id, 'Clock-in');
        
        System.assertNotEquals(null, result);
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
            Email__c = 'testemail@gmail.com'
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
            Email__c = 'testemail@gmail.com'
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
            Email__c = 'testemail@gmail.com'
            
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
        
        // Create a test Employee__c record
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
        );
        insert testEmployee;
        
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
            Email__c = 'testemail@gmail.com'
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
            Email__c = 'testemail@gmail.com'
            
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
            Email__c = 'testemail@gmail.com'
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
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Email__c = 'test@example.com',
            Password__c = 'Admin@123'
        );
        insert testEmployee;

        String result = EmployeeController.getUserEmailAndSendEmail(testEmployee.Username__c);
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testUpdatePassword() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
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
            Email__c = 'testemail@gmail.com'
            
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
            Email__c = 'testemail@gmail.com'
            
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
    static void testUpdateWorkFromHomeStatus() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMPLOYEE',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com'
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
        String updateLeave = EmployeeController.updateLeaveRequestStatus(leaveReqObj.Id,leaveReqObj.Status__c);
        Test.stopTest();
        
        System.assertEquals(newStatus, updatedStatus);
        
        Work_From_Home__c updatedRecord = [SELECT Status__c FROM Work_From_Home__c WHERE Id = :testRecord.Id LIMIT 1];
        System.assertEquals(newStatus, updatedRecord.Status__c);
    }


}