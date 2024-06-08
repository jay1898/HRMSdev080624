@isTest
public class AttendanceTriggerHandlerTest {
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
        
        Attendance__c attendance = new Attendance__c();
        attendance.Date__c= Date.newInstance(2024,01,06);
        attendance.Employee__c=testEmployee.id;
        insert attendance;
        
        List<Attendance__c> attendanceList = [SELECT Id,Is_Holiday__c FROM Attendance__c WHERE Date__c = :attendance.Date__c LIMIT 1]; 
        System.assertEquals(true, attendanceList[0].Is_Holiday__c);
    }
}