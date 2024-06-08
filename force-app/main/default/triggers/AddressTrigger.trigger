trigger AddressTrigger on Address__c (after update) 
{
	// Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Address_Disable_Trigger__c ) ) return ;

	if(Trigger.isUpdate && Trigger.isAfter)
	{
		// RUN_EBS_CALLOUT Flag is controlled from ServicePostRTA class - 02/22/2020 
		if(AddressTriggerHandler.RUN_EBS_CALLOUT) AddressTriggerHandler.updateAddressEBSCallout(Trigger.New,Trigger.OldMap);
        
        //Update Account Address
        if(AddressTriggerHandler.update_Account_Address) AddressTriggerHandler.updateAccountAddress(trigger.newMap);
	}
}