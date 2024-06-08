public class EmailMessageTriggerHandlerModel {

    //Commented
    /*public static List<EmailMessage> getRecord (Set<Id> ParentIdlist) {
        return new List<EmailMessage>([select Id, Incoming from EmailMessage where Id IN: ParentIdlist and Incoming = true order by createdDate DESC limit 1]);
    }*/
    
    public static List<Case> getCaseRecord (Set<Id> caseToProceed) {
        return new List<Case>([select Id, ParentId, Send_To_Invoicing__c, Has_Awaiting_Parts_Alert__c, ContactId, Internal_Comments__c, OwnerId, Status, Subject,CaseNumber from Case where Id IN: caseToProceed]) ;
    }
    
    public static List<Case> getParentCaseRecords (List<String> caseToProceed) {
        return new List<Case>([select Id, Assigned_Queue__c ,ParentId, Send_To_Invoicing__c,  Has_Awaiting_Parts_Alert__c, ContactId, Internal_Comments__c, OwnerId, Status, Subject,CaseNumber from Case where Id IN: caseToProceed]) ;
    }
    
    public static List<Case> getMergedCaseRecords (Set<String> caseToProceed) {
        return new List<Case>([select Id, Assigned_Queue__c ,ParentId, Send_To_Invoicing__c,  Has_Awaiting_Parts_Alert__c, ContactId, Internal_Comments__c, OwnerId, Status, Subject,CaseNumber from Case where Id IN: caseToProceed and Status =: Constant.CASE_STATUS_MERGED]) ;
    }
    
    public static List<Case_Line__c> getCaseLineRecord (Set<Id> CaseLineIdList) {
        return new List<Case_Line__c>([select Id, Labor_Cost__c,Case__c,Line_Price__c from Case_Line__c where Case__c IN: CaseLineIdList And (RecordType.DeveloperName =: Constant.CASE_LINE_RECROD_TYPE_SHIPPING OR RecordType.DeveloperName =: Constant.CASE_LINE_RECROD_TYPE_LABOR OR RecordType.DeveloperName =: Constant.CASE_LINE_RECROD_TYPE_PARTS) ]) ;
    }
    
     public static List<Case_Line__c> getParentCaseLineRecord (List<String> CaseLineIdList) {
        return new List<Case_Line__c>([select Id, Labor_Cost__c,Case__c,Line_Price__c from Case_Line__c where Case__c IN: CaseLineIdList AND Case__r.Status =: Constant.CASE_STATUS_COMPLETED ]) ;
    }
    
    public static List<Corporate_Queue_List__mdt > getCorporateQueueListMetaData () {
        return new List<Corporate_Queue_List__mdt >([select Id, Label, Queue_Name__c from Corporate_Queue_List__mdt]) ;
    }
    
    public static List<Contact> getBouncedContactList(List<String> emailList){
        return new List<Contact>([Select Id,Email,IsEmailBounced from Contact Where Email IN : emailList and IsEmailBounced = true]);
    }
    
    public static List<ContentVersion> getContentVersion(Set<Id> emailMessageIds){
        return new List<ContentVersion>([Select VersionData from ContentVersion where FirstPublishLocationId IN :emailMessageIds and FileExtension = 'txt']);
    } 
}