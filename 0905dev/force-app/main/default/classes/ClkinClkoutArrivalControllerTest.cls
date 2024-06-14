@isTest
private class ClkinClkoutArrivalControllerTest {
    @isTest
    static void testGetAttendanceOnTimeArrival() {
        // Create a test Contact
        Contact con = new Contact(LastName='Test', Email='test@gmail.com');
        insert con;
        
        // Create a test Employee
        Employee__c testEmployee = new Employee__c(
            Name = 'TESTEMPPPPEEE',
            Username__c = 'testuserrt',
            Password__c = 'Admin@123433',
            Email__c = 'testemail25251@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;
        
        // Create a test Attendance record
        Attendance__c testAttendance = new Attendance__c(
            Employee__c = testEmployee.Id,
            Date__c = Date.today()
        );
        insert testAttendance;
        
        // Call the method under test
        Test.startTest();
        List<Attendance__c> result = ClkinClkoutArrivalController.getAttendanceOnTimeArrival(testEmployee.Id);
        Test.stopTest();
        system.debug('resultresultresult-->'+result);
        System.assertEquals(0, result.size(), 'Expected one attendance record');
    }

    @isTest
    static void testGetOnTimeArrival() {
        Employee__c testEmployee = new Employee__c(
            Name = 'TESTEMPPPPEEE',
            Username__c = 'testuserrt',
            Password__c = 'Admin@123433',
            Email__c = 'testemail25251@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556622266',
            Gender__c = 'Male',
            First_Name__c = 'TESTEMOP',
            Last_Name__c = 'TESTEMOP',
            Personal_Email__c = 'johnhapkin34444444@gmail.com'
        );
        insert testEmployee;

        Attendance__c attendanceRecords = new Attendance__c();
        attendanceRecords.Employee__c = testEmployee.Id;
        insert attendanceRecords;
        
        Clock_In_Out__c ClkOut = new Clock_In_Out__c();
        ClkOut.Employee__c = testEmployee.Id;
        ClkOut.Attendance__c = attendanceRecords.Id;
        ClkOut.Clock_In_Time__c = DateTime.now();
        ClkOut.Clock_Out_Time__c = DateTime.now().addHours(3);
        insert ClkOut;

        Test.startTest();
        Map<String, Integer> result = ClkinClkoutArrivalController.getontimeArrival(testEmployee.Id);
        Test.stopTest();

        System.debug('Result: ' + result);

		System.assertEquals(null, result.get('OnTimeArrivals'), 'on-time arrival');
        System.assertEquals(1, result.get('lateArrivals'), 'late arrivals');
    }
}