@isTest
private class FieldSetControllerTest {
    @isTest
    static void testGetFieldNames() {
        // Define test data
        String contextObjectType = 'Leave_Request__c';
        String fieldSetName = 'Leave_Approval_Field'; // Field set name to test

        // Call the method being tested
        Test.startTest();
        List<String> result = FieldSetController.getFieldNames(contextObjectType, fieldSetName);
        Test.stopTest(); // Verify the result
        System.assertEquals(8, result.size(), 'Expected number of fields in the field set');

        // Add more assertions as needed
        System.assertEquals('Employee_Name__c', result[0], 'First field in the field set');
        System.assertEquals('Applied_Leave_Date__c', result[1], 'Second field in the field set');
        System.assertEquals('From_Date__c', result[2], 'Third field in the field set');
        System.assertEquals('To_Date__c', result[3], 'Fourth field in the field set');
        System.assertEquals('Leave_Duration__c', result[4], 'Fifth field in the field set');
        System.assertEquals('Number_of_Days__c', result[5], 'Sixth field in the field set');
        System.assertEquals('Reason_for_Leave__c', result[6], 'Seventh field in the field set');
        System.assertEquals('Status__c', result[7], 'Eighth field in the field set');
    }
}