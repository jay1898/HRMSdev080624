trigger LeadTrigger on Lead(before insert, before update,after insert,after update) 
{
	// Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Lead_Disable_Trigger__c ) ) return ;

    if(Trigger.isBefore)
    {
        LeadTriggerHandler.populateZone(Trigger.new);
    }
    if(Trigger.isAfter)
    {
        LeadTriggerHandler.leadRecordShare(Trigger.new, Trigger.oldMap); 
    }
    //Pallavi, lead assignemnt for leads coming through Eloqua
    if(Trigger.isBefore && Trigger.isInsert){
      	LeadTriggerHandler.eloquaLeadAssignment(Trigger.new, Trigger.oldMap);  
        LeadTriggerHandler.pellaProMobileLeadAssignment(Trigger.new, Trigger.oldMap);
    }
}