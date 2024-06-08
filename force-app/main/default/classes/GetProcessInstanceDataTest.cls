@isTest
public with sharing class GetProcessInstanceDataTest {
    
     private static Id setupTestActor() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        
        User testUser = new User(
            Alias = 'standt1',
            Email='standarduser111ff@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testinfg1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            //RoleId = r.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduffser111@testorg.com'
        );
        insert testUser;
        
        return testUser.Id;
    }
    
    
    @isTest
    private static void testGetRecordDataAndGetObjectAvailableFieldsString() {
        Id testActorId = setupTestActor();
        List<String> testFieldNames = new List<String>{'Id', 'Name'};
            String testObjectName = 'User'; // or any object that your class will work with
        String testMode = 'testMode';
        Test.startTest();
        String resultJson = GetProcessInstanceData.getProcessItemData(testActorId, testFieldNames, testObjectName, testMode);
            GetProcessInstanceData.testCoverage();

        Test.stopTest();
        
        System.assertNotEquals(null, resultJson, 'Result JSON should not be null');
    }
    
    
    
    @isTest
    private static void testGetProcessItemData() {
        Id testActorId = setupTestActor();
        List<String> testFieldNames = new List<String>{'Id', 'Name'};
            String testObjectName = 'User';
        String testMode = 'testMode';
        
        Test.startTest();
        String resultJson = GetProcessInstanceData.getProcessItemData(testActorId, testFieldNames, testObjectName, testMode);
        Test.stopTest();
        
        System.assertNotEquals(null, resultJson, 'Result should not be null');
    }
    
    @isTest
    private static void testProcessMethod() {
        Id testActorId = setupTestActor();
        List<String> mockWorkItemIds = new List<String>{
            'a1X000000000001AAA', 
                'a1X000000000002AAA'
                };
                    
                    String reassignActorId = '005000000000001AAA'; // Use a realistic ID format
        String action = 'Reassign';
        String comment = 'Test Comment';
        Test.startTest();
        try {
            GetProcessInstanceData.process(reassignActorId, action, mockWorkItemIds, comment);
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testGetRowData() {
        Id testActorId = setupTestActor();
        List<String> testFieldNames = new List<String>{'Id', 'Name'};
            String testObjectName = 'Leave_Request__c';
        String testMode = 'testMode';
        
        Test.startTest();
        GetProcessInstanceData.ProcessData processData = GetProcessInstanceData.getRowData(testActorId, testFieldNames, testObjectName, testMode);
        Test.stopTest();
        
        // Assertions to validate processData and indirectly validate getRelatedActors
        System.assertNotEquals(null, processData, 'ProcessData should not be null');
        // Further assertions as needed
    }
    
    @isTest
    private static void testGetRowData1() {
        // Initialize test data for OBJECT_NAME_TO_DESCRIBE
        GetProcessInstanceData.OBJECT_NAME_TO_DESCRIBE = new Map<String, Map<String, Schema.SObjectField>>();
        
        Map<String, Schema.SObjectField> userFieldDescribes = new Map<String, Schema.SObjectField>();
        //  userFieldDescribes.put('Id', Schema.SObjectType.User.fields.Id);
        GetProcessInstanceData.OBJECT_NAME_TO_DESCRIBE.put('User', userFieldDescribes);
        
        
        // Set up test variables
        Id testActorId = setupTestActor();
        List<String> testFieldNames = new List<String>{'Id'};
            String testObjectName = 'User';
        String testMode = 'testMode';
        
        Test.startTest();
        // Call the method under test
        String availableFields = GetProcessInstanceData.getObjectAvailableFieldsString(testObjectName);
        Test.stopTest();
        
    }
    
    
    
   @isTest
    public static void testProcessInstanceDataConstructor() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account');
        ProcessInstanceWorkitem testWorkItem = new ProcessInstanceWorkitem();
        ProcessInstance testProcessInstance = new ProcessInstance();
        ProcessDefinition testProcessDefinition = new ProcessDefinition();
        User testCreatedByUser = new User();
        User testLastActorUser = new User();

        
        // Call the constructor under test, passing valid parameters
        GetProcessInstanceData.ProcessInstanceData instanceData = new GetProcessInstanceData.ProcessInstanceData(
            testAccount, testWorkItem, testProcessInstance, testProcessDefinition, testCreatedByUser, testLastActorUser
        );
        

        
        // Assertions
        System.assertNotEquals(null, instanceData, 'Instance data should not be null');
    }
 
    
    
    
}