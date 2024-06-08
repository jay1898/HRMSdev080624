public class EmailMessageTriggerHandler implements ITrigger{
     Public static Boolean RUN_TRIGGER = TRUE ;
    
    public EmailMessageTriggerHandler() {
    }
    
    public void bulkBefore() {
    }
    
    public void bulkAfter() {
    }
    
    public void beforeInsert(List<EmailMessage> emailMessageList) {
        try{
            EmailMessageTriggerHandlerService.checkIsBounced(emailMessageList);
            EmailMessageTriggerHandlerService.checkIsCommingBeforeUpdate(emailMessageList);
            //EmailMessageTriggerHandlerService.MailMergeCaseProcessor(emailMessageList);
            EmailMessageTriggerHandlerService.MailMergeCaseProcessorForClosedCase(emailMessageList);
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('EmailMessageTriggerHandlerService', 'checkIsCommingBeforeUpdate', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
    }
    public void beforeUpdate(Map<Id,SObject> newMap, Map<Id,SObject> oldMap) {   
    }
    
    public void beforeDelete(List<EmailMessage> oldRecords, Map<ID, SObject> oldRecordMap) {
    }
    
    public void afterInsert(List<EmailMessage> newList, Map<Id, SObject> newMap) {
        try {
            EmailMessageTriggerHandlerServiceForPIES.piesPopulateWOId(newList);
            
        } catch (Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('EmailMessageTriggerHandlerServiceForPIES', 'piesPopulateWOId', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        try {
            EmailMessageTriggerHandlerService.handleUndeliverableEmail(newList,newMap);
        } catch (Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('EmailMessageTriggerHandlerService', 'handleUndeliverableEmail', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
    }
    
    public void afterUpdate(Map<Id, SObject> newCaseMap, Map<Id, SObject> oldCaseMap) {
    }
    
    public void afterDelete(List<EmailMessage> oldRecords, Map<ID, SObject> oldRecordMap) {
    }
    
    public void andFinally(List<EmailMessage> newList, Map<ID, SObject> newMap) {
    }

}