trigger AssignedResourceTrigger on AssignedResource(after insert, after update, before delete, after delete) 
{
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Assigned_Resource_Disable_Trigger__c ) ) return ;
    
    if(Trigger.isAfter && Trigger.isInsert){
        system.debug('After insert AssignedResourceTriggerHandler');
        AssignedResourceTriggerHandler.piesSAWORecordShare(Trigger.new, Trigger.oldMap);
    }
   if(Trigger.isAfter &&  Trigger.isUpdate ){
        system.debug('After update AssignedResourceTriggerHandler');
        AssignedResourceTriggerHandler.piesSAWORecordShareDelete(Trigger.new,Trigger.oldMap);
        AssignedResourceTriggerHandler.piesSAWORecordShare(Trigger.new, Trigger.oldMap);
    }
    
  
   if(Trigger.isAfter && Trigger.isDelete){
        system.debug('AssignedResourceTrigger : ' + 'After delete');
        AssignedResourceTriggerHandler.piesSAWORecordShareDelete2(Trigger.old);
    }
    
    if(!AssignedResourceTriggerHandler.RUN_TRIGGER) return ;
    
   if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) )
    {
        if(AssignedResourceTriggerHandler.CHANGE_OWNER_ON_SA_FOR_SERVICE_RESOURCE) AssignedResourceTriggerHandler.syncOwnerOnAppointmentForAssignedResource(Trigger.new, Trigger.oldMap, Trigger.isInsert );    
        if(AssignedResourceTriggerHandler.CHANGE_SA_OPP_STATUS_OWNER) AssignedResourceTriggerHandler.changeSAOpportunityStatusAndOwner(Trigger.new, Trigger.oldMap, Trigger.isInsert);
        AssignedResourceTriggerHandler.updateWOLPayoutInstaller(Trigger.new, Trigger.oldMap, Trigger.isInsert);
        
    }
   
}