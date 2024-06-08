trigger ResourceAbsenceTrigger on ResourceAbsence (after insert,after update,before delete) 
{
     
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Resource_Absence_Disable_Trigger__c) ) return ;

    if(!ResourceAbsenceTriggerHandler.runTrigger)
        return;
    
    if(Trigger.isAfter && (Trigger.isInsert ) )
    {  
        if(ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT) ResourceAbsenceTriggerHandler.createOrUpdateEventforAbsence(Trigger.new,Trigger.oldMap);
        
    }
     if(Trigger.isAfter && (Trigger.isUpdate  ) )
    {
        if(ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT)ResourceAbsenceTriggerHandler.createOrUpdateEventforAbsence(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete)
    {
      // if(ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT) ResourceAbsenceTriggerHandler.deleteEventforAbsence(Trigger.old);
        
    }
}