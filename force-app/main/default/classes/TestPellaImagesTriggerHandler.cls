/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: This is a trigger handler for sObject Pella Images to perform required operations.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/


@isTest
private class TestPellaImagesTriggerHandler {
    
    static testMethod void testData() {
        User usr = TestUtil.createUser(true);
        // Insert Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Insert Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        insert opp ;
        
        //Insert Pella Image
        Pella_Images__c testPellaImage = new Pella_Images__c();
        testPellaImage.Name='Test Image' ;
        
        insert testPellaImage;
        //Insert Attachment
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        Attachment objAttachment = new Attachment();
        objAttachment.Name='Test Attachment';
        objAttachment.ParentId=testPellaImage.id;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        objAttachment.body=bodyBlob;
        insert objAttachment;
        testPellaImage.Opportunity__c=opp.id;
        update testPellaImage;// update Pella Image
        List<Pella_Images__c> lstPella = new List<Pella_Images__c>();        
        lstPella.add(testPellaImage);
        Map<Id,Pella_Images__c> oldMap = new Map<Id,Pella_Images__c>();
        oldMap.put(testPellaImage.Id,testPellaImage);
        PellaImagesTriggerHandler objPellaImages = new PellaImagesTriggerHandler();
        objPellaImages.addFileOnOpportunity(oldMap,lstPella);
    }
    
    
}