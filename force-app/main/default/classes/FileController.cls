/**
*   @Method:		getVersionFilesForWO, getVersionFilesForChildWolis
*   @Purpose:       To retrieve the files(jpg & png) associated to the Work Order and Work Order Line Items
*   @Author:        Vijay (eVerge)
*   @Date:          08/30/2023
**/
public with sharing class FileController {
	@AuraEnabled(cacheable=true)
    public static List<ContentVersion> getVersionFilesForWO(String woId) {
        try {
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :woId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : cdlList) {
                fileIDs.add(docLink.ContentDocumentId);
            }
            List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId, FileType, ContentSize, FileExtension, VersionNumber, CreatedDate 
                                           FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND (FileType = 'JPG' OR FileType = 'PNG') 
                                           ORDER BY CreatedDate DESC];
            return cvList;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getVersionFilesForChildWolis(String woId) {
        try {
            List<WorkOrderLineItem> woliList = [Select Id from WorkOrderLineItem where WorkOrderId =: woId];
            if (woliList.size() > 0) {
                    List<ID> woliIDs = new List<ID>();
                for (WorkOrderLineItem woli : woliList) {
                    woliIDs.add(woli.Id);
                }
                List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: woliIDs];
                List<ID> fileIDs = new List<ID>();
                for (ContentDocumentLink docLink : cdlList) {
                    fileIDs.add(docLink.ContentDocumentId);
                }
                List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId, FileType, ContentSize, FileExtension, VersionNumber, CreatedDate 
                                               FROM ContentVersion WHERE ContentDocumentId IN: fileIDs AND (FileType = 'JPG' OR FileType = 'PNG') 
                                               ORDER BY CreatedDate DESC];
                return cvList;
            } 
            else {
                return null;
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}