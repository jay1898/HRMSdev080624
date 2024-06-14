@isTest
public class EmployeeTriggerHandler_T {
   @isTest
    static void testInsertAttendanceEmployee() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'Test Employee';
        testEmployee.Username__c = 'testuser';
        testEmployee.Password__c = 'Admin@123';
        testEmployee.Email__c = 'testemail@gmail.com';
        insert testEmployee;
        
        Test.startTest();
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c WHERE Employee__c = :testEmployee.Id LIMIT 1];       
        Test.stopTest();
        System.assertEquals(1, attendanceList.size(), 'Expected 1 Attendance record to be inserted.');
    }
}