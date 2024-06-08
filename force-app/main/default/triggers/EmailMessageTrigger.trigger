trigger EmailMessageTrigger on EmailMessage (before insert,after insert,before update,after update, after delete, before delete) {
    EmailMessageTriggerHandler handler = new EmailMessageTriggerHandler();
    TriggerManager.handle(handler, 'Email_Message_Disable_Trigger__c');
}