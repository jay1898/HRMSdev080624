/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: QuoteBatchprocess to fetch all the data of Quote POST all the records to external URL.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


public class UploadImage{
    @AuraEnabled
    public static void createAttachment(String strAttachJSON, String imagename){
        AttachClass objAttach = (AttachClass) JSON.deserialize(strAttachJSON, AttachClass.Class);
        if(String.isBlank(imagename)){
            imagename = objAttach.fileName;
        }
        Pella_Images__c pellaimage = new Pella_Images__c();
        pellaimage.name = imagename;
        insert pellaimage;
        Attachment a = new Attachment(parentid=pellaimage.id, Name = imagename,
                                      Body = EncodingUtil.base64Decode(objAttach.Body),
                                      contentType= objAttach.contentType);
        insert a;
    }
    public class AttachClass{
        @AuraEnabled public String fileName;
        @AuraEnabled public String contentType;
        @AuraEnabled public String Body;
    }
}