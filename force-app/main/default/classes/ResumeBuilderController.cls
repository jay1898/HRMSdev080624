public class ResumeBuilderController {
    @Auraenabled
    public static String getResumeTemplate(){
        Map<Id,Template__c> templateMap = new Map<Id,Template__c>([Select Id,Name,IsActive__c from Template__c Where IsActive__c = true order by Name desc]);
        List<ContentDocumentLink> contentDocumentList= [SELECT Id, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersionId,ContentDocument.LatestPublishedVersion.FileExtension,LinkedEntityId FROM ContentDocumentLink Where LinkedEntityId  IN :templateMap.keyset() ];

        Map<Id,TemplateWrapper> templateWrapperMap = new Map<Id,TemplateWrapper>();
        for(ContentDocumentLink cdl : contentDocumentList){
            if(cdl.ContentDocument.LatestPublishedVersion.FileExtension == 'docx'){
                if(!templateWrapperMap.containsKey(cdl.LinkedEntityId)){
                    templateWrapperMap.put(cdl.LinkedEntityId,new TemplateWrapper());
                    templateWrapperMap.get(cdl.LinkedEntityId).templateName=templateMap.get(cdl.LinkedEntityId).Name;
                }
                templateWrapperMap.get(cdl.LinkedEntityId).templateDocumentId=cdl.ContentDocument.LatestPublishedVersionId;
            }
            if(cdl.ContentDocument.LatestPublishedVersion.FileExtension == 'jpg' || cdl.ContentDocument.LatestPublishedVersion.FileExtension == 'png'){
                if(!templateWrapperMap.containsKey(cdl.LinkedEntityId)){
                    templateWrapperMap.put(cdl.LinkedEntityId,new TemplateWrapper());
                    templateWrapperMap.get(cdl.LinkedEntityId).templateName=templateMap.get(cdl.LinkedEntityId).Name;
                }
                templateWrapperMap.get(cdl.LinkedEntityId).templateThumbnailId=cdl.ContentDocument.LatestPublishedVersionId;
                templateWrapperMap.get(cdl.LinkedEntityId).templateThumbnailBase64= 'data:image/'+cdl.ContentDocument.LatestPublishedVersion.FileExtension+';base64, ' + EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
            }
        }

        return JSON.serialize(templateWrapperMap.values());
    }

    public class TemplateWrapper{
        public string templateName;
        public string templateDocumentId;
        public string templateThumbnailId;
        public string templateThumbnailBase64;
    }
}