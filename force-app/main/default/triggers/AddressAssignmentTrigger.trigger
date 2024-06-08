trigger AddressAssignmentTrigger on Address_Assignment__c (before insert, before update, after insert,after update) 
{
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Address_Assignment_Disable_Trigger__c) ) return ;

    if(AddressAssignmentTriggerHandler.runTrigger)
    {
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        { 
            System.debug('@@isAfter');
            if(AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT) AddressAssignmentTriggerHandler.createOrUpdateEBSData(Trigger.new, Trigger.oldMap); 
       		AddressAssignmentTriggerHandler.StampIdentifyingAddressonAccount(Trigger.New,Trigger.OldMap);
            AddressAssignmentTriggerHandler.updateAccountAddress(Trigger.new, Trigger.oldMap);
        }  
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        { 
            System.debug('@@isBefore');
            AddressAssignmentTriggerHandler.identifyingValidation(Trigger.new, Trigger.oldMap); 
            AddressAssignmentTriggerHandler.primaryValidation(Trigger.new, Trigger.oldMap);
        }
        
    }
}