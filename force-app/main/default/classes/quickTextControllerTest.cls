@isTest
public class quickTextControllerTest {
    @isTest
    static void testGetQuickTexts() {
        // Create test data for Case_Quick_Text__c and Group
        
        User usr=testutil.createUser(false);
        usr.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Pella System Administrator'].Id;
        insert usr;
        
        system.runAs(usr){
            Group testQueue = new Group(Name = 'Test Queue', Type = 'Queue');
            insert testQueue;
            insert new GroupMember(GroupId=testQueue.Id,UserOrGroupId=UserInfo.getUserId());
            Group testQueueSecond = new Group(Name = 'Test Queue Second', Type = 'Queue');
            insert testQueueSecond;
            insert new GroupMember(GroupId=testQueueSecond.Id,UserOrGroupId=UserInfo.getUserId());
           
            Case_Quick_Text__c testQuickText1 = new Case_Quick_Text__c(
                Name = 'Test Quick Text 1',
                Message__c = 'Sample message for Test Quick Text 1',
                Queue_Name__c = testQueueSecond.Name,
                Folder_Hierarchy_Level_1__c = 'Folder Level 1',
                Folder_Hierarchy_Level_2__c = 'Folder Level 2',
                Active__c = TRUE
                //Folder_Hierarchy_Level_3__c = null
            );
            Case_Quick_Text__c testQuickText2 = new Case_Quick_Text__c(
                Name = 'Test Quick Text 2',
                Message__c = 'Sample message for Test Quick Text 2',
                Queue_Name__c = testQueue.Name,
                Folder_Hierarchy_Level_1__c = 'Folder Level 1',
                Folder_Hierarchy_Level_2__c = 'Folder Level 2',
                Active__c = TRUE
                //Folder_Hierarchy_Level_3__c = 'Folder Level 3'
            );
            Case_Quick_Text__c testQuickText3 = new Case_Quick_Text__c(
                Name = 'Test Quick Text 2',
                Message__c = 'Sample message for Test Quick Text 2',
                Queue_Name__c = testQueue.Name,
                Folder_Hierarchy_Level_1__c = 'Folder Level 1',
                Folder_Hierarchy_Level_2__c = null,
                Active__c = TRUE
                //Folder_Hierarchy_Level_3__c = 'Folder Level 3'
            );
            Case_Quick_Text__c testQuickText4 = new Case_Quick_Text__c(
                Name = 'Test Quick Text 2',
                Message__c = 'Sample message for Test Quick Text 2',
                Queue_Name__c = testQueue.Name,
                Folder_Hierarchy_Level_1__c = null,
                Folder_Hierarchy_Level_2__c = 'Folder Level 2',
                Active__c = TRUE
                //Folder_Hierarchy_Level_3__c = 'Folder Level 3'
            );
            
            insert new List<Case_Quick_Text__c>{testQuickText1, testQuickText2,testQuickText3,testQuickText4};
                
            Test.startTest();
                // Call the method being tested
                List<Map<String, Object>> result = quickTextController.getQuickTexts();
            Test.stopTest();
        }
    }

    @isTest
    static void testGetMetadataRecords() {

        Group testQueue = new Group(Name = 'Test Queue', Type = 'Queue');
        insert testQueue;

        Test.startTest();
        // Call the method being tested
        Boolean result = quickTextController.getMetadataRecords(testQueue.Id);
        Test.stopTest();

    }
}