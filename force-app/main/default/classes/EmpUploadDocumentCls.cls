global without sharing class EmpUploadDocumentCls {
   
    @AuraEnabled
    global static String uploadEmpDocument(String contentDocumentId, String EmployeeId,String FileName, String DocumentName) {
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        List<ContentVersion> cvList = [SELECT Id, Title, contentDocumentId FROM ContentVersion WHERE Id = :contentDocumentId];
        
        for (ContentVersion cv : cvList) {
            cv.Title = FileName;
            cv.Document_Name__c = DocumentName; 
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.LinkedEntityId = EmployeeId;
            conDocLink.ContentDocumentId = cv.contentDocumentId;
            conDocLink.Visibility = 'AllUsers';
            conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
            cdList.add(conDocLink);
        }
        
        if (!cdList.isEmpty()) {
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            results.addAll(Database.update(cvList, false));
            results.addAll(Database.insert(cdList, false));
            
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    System.debug('Error while saving: ' + result.getErrors()[0].getMessage());
                }
            }
        }
        
        return 'Success';
        
    }
    
    @AuraEnabled
    global static String fetchImage(String fileName, String EmployeeId) {
        String base64Data = '';
        
        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId 
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :EmployeeId 
                                                   AND ContentDocument.Title = :fileName 
                                                   ORDER BY ContentDocument.CreatedDate DESC 
                                                   LIMIT 1];
        
        if (!documentLinks.isEmpty()) {
            // Query ContentVersion using the ContentDocumentId from ContentDocumentLink
            List<ContentVersion> versions = [SELECT Id,VersionData 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId = :documentLinks[0].ContentDocumentId 
                                             ORDER BY CreatedDate DESC 
                                             LIMIT 1];
            
            if (!versions.isEmpty()) {
                base64Data = EncodingUtil.base64Encode(versions[0].VersionData);
            }
        }
        
        return base64Data;
    }
    
    @AuraEnabled
    global static List<Map<String, String>> fetchAllImages(String DocumentName, String EmployeeId) {
        List<Map<String, String>> imageDataList = new List<Map<String, String>>();
        
        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :EmployeeId 
                                                   ORDER BY ContentDocument.CreatedDate DESC];
        
        for (ContentDocumentLink docLink : documentLinks) {
            List<ContentVersion> versions = [SELECT Id, Title, VersionData, Document_Name__c
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId = :docLink.ContentDocumentId 
                                             AND Document_Name__c = :DocumentName 
                                             ORDER BY CreatedDate DESC 
                                             LIMIT 1];
            
            if (!versions.isEmpty()) {
                ContentVersion version = versions[0];
                Map<String, String> imageData = new Map<String, String>();
                imageData.put('base64Data', EncodingUtil.base64Encode(version.VersionData));
                imageData.put('title', version.Title);
                imageDataList.add(imageData);
            }
        }
        
        return imageDataList;
    }
    
    @AuraEnabled
    global static String uploadFile(String base64, String filename) {
        ContentVersion cv = createContentVersion(base64, filename);
        if (cv != null) {
            return cv.Id;
        }
        return null; // Handle error or return an appropriate value
    }
    
    
    public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getFileSizes(List<String> contentVersionIds) {
        if(contentVersionIds == null || contentVersionIds.isEmpty()) {
            return new List<ContentVersion>();
        }
        return [SELECT Id, Title, ContentSize, FileExtension, ContentDocumentId 
                FROM ContentVersion 
                WHERE Id IN :contentVersionIds];
    }
    
    @AuraEnabled
    public static void deleteFileById(String contentVersionId) {
        try {
            ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
            if (cv != null) {
                Id contentDocumentId = cv.ContentDocumentId;
                
                List<ContentDocument> docsToDelete = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
                delete docsToDelete;
                System.debug('File deleted successfully.');
            } else {
                throw new AuraHandledException('ContentVersion record not found.');
            }
        } catch(Exception e) {
            System.debug('Error deleting file: ' + e.getMessage());
            throw new AuraHandledException('Error deleting file.');
        }
    }
    
    @AuraEnabled
    public static void deleteFileByIdName(String EmployeeId, String FileName) {
        try {
            List<ContentDocumentLink> linksToDelete = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :EmployeeId AND ContentDocument.Title = :FileName];
            if (!linksToDelete.isEmpty()) {
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink link : linksToDelete) {
                    contentDocumentIds.add(link.ContentDocumentId);
                }
                
                delete linksToDelete;
                
                List<ContentDocument> docsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
                delete docsToDelete;
                
                System.debug('Files deleted successfully.');
            } else {
                throw new AuraHandledException('No files found to delete.');
            }
        } catch(Exception e) {
            System.debug('Error deleting files: ' + e.getMessage());
            throw new AuraHandledException('Error deleting files.');
        }
        
    }
    
}