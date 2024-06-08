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


public with sharing class PellaImageDisplay {
    //this method is called to fetch images whenever user enter keyword in search box
    @AuraEnabled(cacheable=true)
    public static List<AttachmentWrapper> fetchPellaImages(string searchKey){
        //casting entered string for a like operator
        String key = '%' + searchKey + '%';
        Set<Id> setOfPellaImageIds = new Set<Id>();
        //finding the pella images based on the name matches with searched string
        for(Pella_Images__c objPellaImage : [SELECT Id, Name FROM Pella_Images__c WHERE Name LIKE :key]){
            //creating a set of pella images id
            setOfPellaImageIds.add(objPellaImage.Id);
        }
        //check to verify if pella images found
        if(!setOfPellaImageIds.isEmpty()){
            List<AttachmentWrapper> lstAttachments = new List<AttachmentWrapper>();
            //Fetching the attachments related to the pella image records
            for(Attachment objAttachment : [SELECT Id, Name FROM Attachment WHERE ParentId IN: setOfPellaImageIds]){
                //creating a  list of attachents to display on screen
                lstAttachments.add(new AttachmentWrapper(objAttachment));
            }
            return lstAttachments;
        }
        return null;
    }
    
    //Wrapper class for attachments
    public class AttachmentWrapper{
        @AuraEnabled public String attachmentId;
        @AuraEnabled public String attachmentName;
        @AuraEnabled public String attachmentUrl;
        public AttachmentWrapper(Attachment attachment){
            attachmentId = attachment.Id;
            attachmentName = attachment.Name;
            attachmentUrl = '/servlet/servlet.FileDownload?file=' + attachment.Id;
        }
    }
}