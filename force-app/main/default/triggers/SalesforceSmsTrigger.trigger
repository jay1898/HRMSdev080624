trigger SalesforceSmsTrigger on TwilioMessage__c (after insert, after update) {
    
    if(Trigger.isAfter)
    {
        if(trigger.isInsert){
            SalesforceSmsTriggerHandler.triggerSMSCreateEvent(Trigger.new);
        }
        SalesforceSmsTriggerHandler.SMSRecordShare(Trigger.new, Trigger.oldMap); 
    }
}