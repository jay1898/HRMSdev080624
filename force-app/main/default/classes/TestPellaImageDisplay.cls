/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: This class is fetching Pella Images based on keyword entered in the search box.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/


@isTest
public class TestPellaImageDisplay {
    static testMethod void testData() {
        //Insert Pella Image
        string key='Test';
        Pella_Images__c testPellaImage = new Pella_Images__c();
        testPellaImage.Name='Test Image' ;
        insert testPellaImage;
        //Insert Attachment
        Attachment objAttachment = new Attachment();
        objAttachment.Name='Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        objAttachment.body=bodyBlob;
        objAttachment.ParentId=testPellaImage.id;
        insert objAttachment;
        //Intializing the wrapper
        PellaImageDisplay.AttachmentWrapper objAttachmentWrapper = new PellaImageDisplay.AttachmentWrapper(objAttachment);
        objAttachmentWrapper.attachmentId='objAttachment.id';
        objAttachmentWrapper.attachmentName=objAttachment.Name;
        objAttachmentWrapper.attachmentUrl='/servlet/servlet.FileDownload?file=' + objAttachment.Id;
        //calling the fetchPellaImages method from PellaImageDisplay
        PellaImageDisplay.fetchPellaImages(key);
        
    }
}