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


public with sharing class PellaImagesTriggerHandler {
    //this method is copying the images attached to pella images object onto opportunity object
    public void addFileOnOpportunity(Map<Id,Pella_Images__c> oldMap,List<Pella_Images__c> lstNew){
        Map<Id,Id> mapOfPellaImagesIdToOppId = new Map<Id,Id>();
        //Looping over the new pella images to get the opportunity ids
        for(Pella_Images__c objPellaImage : lstNew){
            if(objPellaImage.Opportunity__c != Null && (oldMap == Null || (oldMap != Null && 
                                                                           (oldMap.get(objPellaImage.Id).opportunity__c == Null || oldMap.get(objPellaImage.Id).opportunity__c != objPellaImage.opportunity__c)))){
                                                                               mapOfPellaImagesIdToOppId.put(objPellaImage.Id,objPellaImage.Opportunity__c);
                                                                           }
        }
        //validating if opportunity is present on any pella image record
        if(!mapOfPellaImagesIdToOppId.values().isEmpty()){
            //Quering all the attachments related to the pella image records
            List<Attachment> lstPellaAttachments = [SELECT Id,Name,Body,ParentId FROM Attachment WHERE ParentId IN: mapOfPellaImagesIdToOppId.keySet()];
            List<ContentVersion> lstContentVersion = new List<ContentVersion>();
            //Iterating over attachments to create a content version object
            for(Attachment objAttachment : lstPellaAttachments){
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = objAttachment.Body;
                cv.Title = objAttachment.Name;
                cv.PathOnClient = objAttachment.Name;
                lstContentVersion.add(cv);
            }
            insert lstContentVersion;
            //Quering the newly created content version records to get the automatically inserted contentdocumentid
            List<ContentVersion> lstNewContentVersion = [SELECT Id,Title,ContentDocumentId FROM ContentVersion WHERE Id IN: lstContentVersion];
            Map<String,Id> mapOfTitleToContentDocumentId = new Map<String,Id>();
            //iterating over content version to build a relationship of content name and contentdocumentid
            for(ContentVersion objContentVersion : lstNewContentVersion){
                mapOfTitleToContentDocumentId.put(objContentVersion.Title,objContentVersion.ContentDocumentId);
            }
            List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
            //Again iterating over attachments to create a content document link between opportunity and insert content document
            for(Attachment objAttachment : lstPellaAttachments){
                if(mapOfTitleToContentDocumentId.containsKey(objAttachment.Name)){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = mapOfTitleToContentDocumentId.get(objAttachment.Name);
                    cdl.LinkedEntityId = mapOfPellaImagesIdToOppId.get(objAttachment.ParentId);
                    cdl.ShareType = 'I';
                    lstContentDocumentLink.add(cdl);
                }
            }
            //DML for inserting content document link records
            insert lstContentDocumentLink;
        }
    }
}