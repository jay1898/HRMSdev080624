/*
Created By:
Created Date: 03/03/2021
Purpose: This is a trigger for Contact with all relevant events.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/

trigger ContactTrigger on Contact (before insert, after insert, after update,before update) {
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Contact_Disable_Trigger__c) ) return ; 
    

    if(Trigger.isBefore){
        if(Trigger.isInsert) ContactTriggerHandler.addQuiqContactsToBucketAccount(Trigger.new);
        if(Trigger.isInsert || Trigger.isUpdate){
            ContactTriggerHandler.resetContactOrgIdOnAccountChange(trigger.new, trigger.oldMap);
            ContactTriggerHandler.updateServiceContactPhones(Trigger.new, Trigger.oldMap);

        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            if(ContactTriggerHandler.RUN_EBS_CALLOUT) {
                ContactTriggerHandler.updateContactEBSCallout(trigger.new, trigger.oldMap);
                // Commeted out as this one is working from flow, we move code from flow to apex to resolve dupliacte error issue, we can remove comment one flow inactive
                // ContactTriggerHandler.updatePrimaryContact(trigger.new, trigger.oldMap);
            }
        }
    }
    
    
   
}