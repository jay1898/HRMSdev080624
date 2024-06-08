@isTest
private class ResumeBuilderControllerTest {
    @isTest
    static void testGetResumeTemplate() {
        // Create test data: Template__c records
        Template__c template1 = new Template__c(Name = 'Template 1', IsActive__c = true);
        insert template1;
        
        Template__c template2 = new Template__c(Name = 'Template 2', IsActive__c = true);
        insert template2;
        
        // Create test data: ContentVersion records
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Test Document 1',
            VersionData = Blob.valueOf('Test document content'),
            PathOnClient = 'testDocument1.docx'
        );
        insert contentVersion1;
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Test Document 2',
            VersionData = Blob.valueOf('Test document content'),
            PathOnClient = 'testDocument2.jpg'
        );
        insert contentVersion2;
        
        // Query ContentDocumentId from ContentVersion records
        Id contentDocumentId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id].ContentDocumentId;
        Id contentDocumentId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion2.Id].ContentDocumentId;
        
        // Create test data: ContentDocumentLink records
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId1,
            LinkedEntityId = template1.Id,
            ShareType = 'V'
        );
        insert cdl1;
        
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId2,
            LinkedEntityId = template2.Id,
            ShareType = 'V'
        );
        insert cdl2;
        
        // Call the method to test
        Test.startTest();
        String resultJSON = ResumeBuilderController.getResumeTemplate();
        List<ResumeBuilderController.TemplateWrapper> result = (List<ResumeBuilderController.TemplateWrapper>)JSON.deserialize(resultJSON, List<ResumeBuilderController.TemplateWrapper>.class);
        Test.stopTest();
        
        // Assert the results
        System.assertEquals(2, result.size(), 'Expected two template wrapper objects');
        
    }
}