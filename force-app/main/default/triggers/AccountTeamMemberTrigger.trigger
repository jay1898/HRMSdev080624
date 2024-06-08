trigger AccountTeamMemberTrigger on AccountTeamMember (after insert,after update, after delete) {
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.ATM_Disable_Trigger__c) ) return;
    AccountTeamMemberTriggerHandler.EBSCalloutOnSalesRepChange(Trigger.New,Trigger.oldMap);
}