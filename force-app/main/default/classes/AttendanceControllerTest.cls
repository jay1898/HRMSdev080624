@isTest
private class AttendanceControllerTest {

    @TestSetup
    static void makeData() {
        Contact con1 = new Contact(LastName='test 1',Email='test@gmail.com');
        Contact con2 = new Contact(LastName='test 2',Email='tests@gmail.com');

        insert new List<Contact>{con1, con2};

        Employee__c employeeRecord = new Employee__c();
        employeeRecord.Name = 'TEST EMP';
        employeeRecord.Joining_Date__c = Date.today().addMonths(-6);
        employeeRecord.Username__c = 'testuser';
        employeeRecord.Email__c = 'test@gmail.com';
        employeeRecord.Date_of_Birth__c = Date.today();
        employeeRecord.Emergency_Contact_No__c = '9426582649';
        employeeRecord.First_Name__c = 'Test';
        employeeRecord.Last_Name__c = 'Emp';
        employeeRecord.Gender__c = 'Male';
        employeeRecord.Personal_Email__c = 'testpersonal@gmail.com';
        insert employeeRecord;

        Employee__c employeeRecord1 = new Employee__c();
        employeeRecord1.Name = 'TEST EM';
        employeeRecord1.Joining_Date__c = Date.today().addMonths(-5);
        employeeRecord1.Username__c = 'testusers';
        employeeRecord1.Email__c = 'tests@gmail.com';
        employeeRecord1.Date_of_Birth__c = Date.today();
        employeeRecord1.Emergency_Contact_No__c = '9426582659';
        employeeRecord1.First_Name__c = 'Test';
        employeeRecord1.Last_Name__c = 'Em';
        employeeRecord1.Gender__c = 'Male';
        employeeRecord1.Personal_Email__c = 'testpersonal1@gmail.com';
        insert employeeRecord1;

        Attendance__c attendance = new Attendance__c();
        attendance.Employee__c = employeeRecord.Id;
        attendance.Date__c = Date.newInstance(2024, 4, 4);
        attendance.Override_Absent__c = 'P';
        insert attendance;

        Attendance__c attendance1 = new Attendance__c();
        attendance1.Employee__c = employeeRecord.Id;
        attendance1.Date__c = Date.newInstance(2024, 4, 5);
        attendance1.Override_Absent__c = 'FHL';
        insert attendance1;
        
        Attendance__c attendance2 = new Attendance__c();
        attendance2.Employee__c = employeeRecord.Id;
        attendance2.Date__c = Date.newInstance(2024, 4, 3);
        attendance2.Override_Absent__c = 'SHL';
        insert attendance2;

        Attendance__c attendance3 = new Attendance__c();
        attendance3.Employee__c = employeeRecord.Id;
        attendance3.Date__c = DateTime.now().date();
        insert attendance3;
        
        
        Clock_In_Out__c clockInOut = new Clock_In_Out__c();
        clockInOut.Employee__c = employeeRecord.Id;
        clockInOut.Clock_In_Time__c = DateTime.newInstance(2024, 4, 3, 9, 55, 0);
        clockInOut.Clock_Out_Time__c = DateTime.newInstance(2024, 4, 3, 19, 05, 0);
        clockInOut.Attendance__c = attendance.Id;
        insert clockInOut;

        Clock_In_Out__c clockInOut1 = new Clock_In_Out__c();
        clockInOut1.Employee__c = employeeRecord.Id;
        clockInOut1.Clock_In_Time__c = DateTime.newInstance(2024, 4, 5, 9, 58, 0);
        clockInOut1.Clock_Out_Time__c = DateTime.newInstance(2024, 4, 5, 14, 05, 0);
        clockInOut1.Attendance__c = attendance1.Id;
        insert clockInOut1;

        Clock_In_Out__c clockInOut2 = new Clock_In_Out__c();
        clockInOut2.Employee__c = employeeRecord.Id;
        clockInOut2.Clock_In_Time__c = DateTime.newInstance(2024, 4, 4, 14, 50, 0);
        clockInOut2.Clock_Out_Time__c = DateTime.newInstance(2024, 4, 4, 19, 15, 0);
        clockInOut2.Attendance__c = attendance2.Id;
        insert clockInOut2;

        Clock_In_Out__c clockInOut3 = new Clock_In_Out__c();
        clockInOut3.Employee__c = employeeRecord.Id;
        clockInOut3.Clock_In_Time__c = DateTime.newInstance(DateTime.now().date(), Time.newInstance(9, 0, 0, 0));
        clockInOut3.Attendance__c = attendance3.Id;
        insert clockInOut3;
    }

    @isTest
    static void getAttendanceDataTest() {
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];

        Test.startTest();
        String attendanceData = AttendanceController.getAttendanceData(4, 2024, employee.Id);
        Test.stopTest();

        System.assertEquals(attendanceData, '{"2024-04-05":{"totalTimeSpan":"4 Hrs: 7 Mins","presentStatus":"FHL","onTimeArrivalStatus":true,"manualPresentStatus":"FHL","clockOut":"2024-04-05 14:05:00","clockIn":"2024-04-05 09:58:00"},"2024-04-04":{"totalTimeSpan":"4 Hrs: 25 Mins","presentStatus":"SHL","onTimeArrivalStatus":false,"manualPresentStatus":"SHL","clockOut":"2024-04-04 19:15:00","clockIn":"2024-04-04 14:50:00"},"2024-04-03":{"totalTimeSpan":"9 Hrs: 10 Mins","presentStatus":"P","onTimeArrivalStatus":true,"manualPresentStatus":"P","clockOut":"2024-04-03 19:05:00","clockIn":"2024-04-03 09:55:00"}}');
    }

    @isTest
    static void getAttendanceDataTestForHavingNoAttendance() {
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];

        Test.startTest();
        String attendanceData = AttendanceController.getAttendanceData(2, 2024, employee.Id);
        Test.stopTest();

        System.assertEquals(attendanceData, null);
    }

    @isTest
    static void getAttendanceDataTestForNullTest() {

        Test.startTest();
        String attendanceData = AttendanceController.getAttendanceData(2, 2024, null);
        Test.stopTest();

        System.assertEquals(attendanceData, null);
    }

    @isTest
    static void getHolidaysByMonthTest() {

        Test.startTest();
        Map<String, String> holidayData = AttendanceController.getHolidaysByMonth(2, 2030);
        Test.stopTest();
        
        System.assertEquals(holidayData.size(), 7);
    }

    @isTest
    static void getHolidaysByMonthTestForNullTest() {
        
        Test.startTest();
        Map<String, String> holidayData = AttendanceController.getHolidaysByMonth(null, 2024);
        Test.stopTest();

        System.assertEquals(holidayData, null);
    }

    @isTest
    static void getFirstClockInDateTest(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];

        Clock_In_Out__c firstClockInRecord = [SELECT Id, Clock_In_Time__c FROM Clock_In_Out__c WHERE Clock_In_Time__c =: DateTime.newInstance(2024, 4, 3, 9, 55, 0) LIMIT 1];
        
        Test.startTest();
        Map<String, String> firstClockIn = AttendanceController.getFirstClockInDate(employee.Id);
        Test.stopTest();

        System.assertEquals(firstClockIn.get('date'), String.valueOf(firstClockInRecord.Clock_In_Time__c.date()));
        System.assertEquals(firstClockIn.get('month'), String.valueOf(firstClockInRecord.Clock_In_Time__c.month()));
        System.assertEquals(firstClockIn.get('year'), String.valueOf(firstClockInRecord.Clock_In_Time__c.year()));
    }

    @isTest
    static void getFirstClockInDateTestForHavingNoFirstClockInDate(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'TEST EM' LIMIT 1];

        Test.startTest();
        Map<String, String> firstClockIn = AttendanceController.getFirstClockInDate(employee.Id);
        Test.stopTest();

        System.assertEquals(firstClockIn, null);
    }

    @isTest
    static void getCurrentDayClockInTest(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];

        Test.startTest();
        Map<String, String> currentDayClockIn = AttendanceController.getCurrentDayClockIn(employee.Id);
        Test.stopTest();

        System.assertEquals(currentDayClockIn.get('time'), '09:00');
    }
}