@isTest(SeeAllData=false)
private class EmpUploadDocumentClsTest {
    
    @isTest
    static void testUploadEmpDocument() {
        Account accRecord = new Account(
            Name = 'The Pepsico Company',
            Rating = 'Hot'
        );

        insert accRecord;

        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion cv = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            Document_Name__c = 'Test Document Name',
           VersionData = bodyBlob
        );
        insert cv;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId  FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = accRecord.Id;
        contentlink.ContentDocumentId = contentVersion_2.ContentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        System.assertEquals(contentlink.ContentDocumentId, contentVersion_2.ContentDocumentId);
        
        String contentDocumentId = cv.Id;
        String EmployeeId = accRecord.Id; // Replace with a valid EmployeeId
        String FileName = 'Updated Test Document Name';
        String DocumentName = 'Updated Test Document';
        
        Test.startTest();
        String result = EmpUploadDocumentCls.uploadEmpDocument(contentDocumentId, EmployeeId, FileName, DocumentName);
   		String base64Data = EmpUploadDocumentCls.fetchImage(fileName, accRecord.Id);
        List<Map<String, String>> base65Data = EmpUploadDocumentCls.fetchAllImages(fileName, accRecord.Id);
        String contentVersionId = EmpUploadDocumentCls.uploadFile(base64Data, fileName);
        EmpUploadDocumentCls.deleteFileById(contentVersionId);
        EmpUploadDocumentCls.deleteFileByIdName(EmployeeId,fileName);
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Upload should be successful');
        System.assertNotEquals('', base64Data, 'Base64 data should not be empty');


     
    }
}