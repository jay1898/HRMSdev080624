@IsTest
public class DeleteRedundantFiles_Batch_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for ContentVersion which will automatically create ContentDocument records
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            contentVersions.add(new ContentVersion(
                Title = 'TestVersion' + i,
                PathOnClient = 'TestVersion' + i + '.txt',
                VersionData = Blob.valueOf('Test data'),
                From_App_fileupload__c = 'RECRUITMENT_WEBSITE',
                IsLinkedWithCandidate__c = false
            ));
        }
        insert contentVersions;
    }
    
    @IsTest
    static void testBatchable() {
        // Start the test
        Test.startTest();
        
        // Execute the batch job
        DeleteRedundantFiles_Batch batchInstance = new DeleteRedundantFiles_Batch();
        Database.executeBatch(batchInstance, 200);
        
        // End the test
        Test.stopTest();
        
        // Verify that the ContentDocuments were deleted
        List<ContentDocument> remainingDocs = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE From_App_fileupload__c = 'RECRUITMENT_WEBSITE' AND IsLinkedWithCandidate__c = false)];
        System.assertEquals(0, remainingDocs.size(), 'All ContentDocuments should be deleted');
    }
    
    @IsTest
    static void testSchedulable() {
        // Start the test
        Test.startTest();
        
        // Execute the schedulable job
        DeleteRedundantFiles_Batch batchInstance = new DeleteRedundantFiles_Batch();
        String jobId = System.schedule('TestDeleteRedundantFilesJob', '0 0 0 * * ?', batchInstance);
        
        // End the test
        Test.stopTest();
        
        // Verify that the job was scheduled
        CronTrigger ct = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('TestDeleteRedundantFilesJob', ct.CronJobDetail.Name, 'Scheduled job name should match');
        System.assertEquals('WAITING', ct.State, 'Scheduled job state should be WAITING');
    }
}