@isTest
public class LeaveAndWFHControllerTest {
    
    @isTest
    static void testGetWFHData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        // Call the getWFHData method
        Map<String, Object> result = LeaveAndWFHController.getWFHData();
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testSaveWFHData() {
        
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testemail@gmail.com';
        testEmployee.Email__c = 'testemail@gmail.com';
        insert testEmployee;
        

        String empRecordId = testEmployee.Id;
        Decimal numberOfDays = 2; 
        String fromDate = '2023-01-01'; 
        String toDate = '2023-01-03';
        String reason = 'Test Reason';
        String wfhType = 'Remote';
        Datetime currentDatetime = Datetime.now();
        Date formattedDate = currentDatetime.date();
        
        String sampleJson = '{"FromDate": "2023-01-01", "ToDate": "2023-01-03", "Reason": "Test Reason", "wfhType": "Remote"}';

         Work_From_Home__c controller = new Work_From_Home__c();

        Test.startTest();
        try {
            String wfhId = LeaveAndWFHController.saveWFHData(
                (Object)JSON.deserializeUntyped(sampleJson),
                empRecordId,
                numberOfDays
            );
           System.assertNotEquals(null, wfhId, 'WFH record should be created successfully.');
        } catch (Exception ex) {
            System.debug('Exception Message: ' + ex.getMessage());
        }
    
    }
    
    @isTest
    static void testGetLeaveData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Map<String, Object> result = LeaveAndWFHController.getLeaveData();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testgetLeaveRequests() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = 'TEST';
        testEmployee.Username__c = 'testemail@gmail.com';
        testEmployee.Email__c = 'testemail@gmail.com';
        testEmployee.Number_of_Leaves__c = 1000;
        
        insert testEmployee;
        
        Employee__c result = LeaveAndWFHController.getLeaveRequests(testEmployee.Id);
        
        System.assertNotEquals(null, result);
        
    }
    
    @isTest
    static void testSaveLeaveData() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST',
            Username__c = 'testuser',
            Password__c = 'Admin@123',
            Email__c = 'testemail@gmail.com',
            Number_of_Leaves__c = 100
        );
        insert testEmployee;
        
        Leave_Request__c leaveReqObj =  new Leave_Request__c ();
        leaveReqObj.To_Date__c = Date.Today();
        leaveReqObj.From_Date__c =Date.Today();
        leaveReqObj.Reason_for_Leave__c	= 'Test Reason';
        leaveReqObj.Leave_Type__c = 'Paid Leave';
        leaveReqObj.Employee__c = testEmployee.Id;
        Insert leaveReqObj;
        
       /* Decimal numberOfDays = 2;
        Decimal paidLeave = 2;
        Decimal unpaidLeave = 2;*/
        
        
        // Test data
        String empRecordId = testEmployee.Id; 
        Decimal numberOfDays = 2; 
        Decimal paidLeave = 2;
        Decimal unpaidLeave = 0;
        Decimal paidLeave1 = 0;
        Decimal unpaidLeave1 = 2;
        
        String fromDate = '2023-01-01'; 
        String toDate = '2023-01-03';
        String reason = 'Test Reason';
        String leaveDuration = 'Full Day';
        String fromDateLeaveDurationOption = '2023-01-01';
        String toDateleaveDurationOption = '2023-01-02';
        

        String sampleJson = '{"FromDate": "2023-01-01", "ToDate": "2023-01-03", "Reason": "Test Reason", "leaveDuration": "Full Day", "fromDateLeaveDurationOption": "First half", "toDateleaveDurationOption": "First half"}';

        Test.startTest();
        try {
            // Call the saveLeaveData method with the sample JSON data
            String result = LeaveAndWFHController.saveLeaveData(
                (Object)JSON.deserializeUntyped(sampleJson),
                empRecordId,
                numberOfDays,
                paidLeave,
                unpaidLeave
            );
            
              String result1 = LeaveAndWFHController.saveLeaveData(
                (Object)JSON.deserializeUntyped(sampleJson),
                empRecordId,
                numberOfDays,
                paidLeave1,
                unpaidLeave1
            );

            // Verify that the records were created successfully
            System.assertEquals('Records created successfully', result, 'Method should return success message.');
            System.assertEquals('Records created successfully', result1, 'Method should return success message.');

        } catch (Exception ex) {
            System.debug('Exception Message: ' + ex.getMessage());
        }

    }
    
}