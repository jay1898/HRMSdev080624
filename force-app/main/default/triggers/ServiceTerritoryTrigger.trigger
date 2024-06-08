trigger ServiceTerritoryTrigger on ServiceTerritory (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Service_Territory_Disable_Trigger__c) ) return ;
    
    ServiceTerritoryTriggerHandler handler=new ServiceTerritoryTriggerHandler();
    
    // Before trigger logic
    if (Trigger.IsBefore )
    {
        if (Trigger.IsInsert)
            handler.BeforeInsert(trigger.new);
            
        if (Trigger.IsUpdate)
            handler.BeforeUpdate(trigger.new,trigger.newMap, trigger.oldMap);
            
        if (Trigger.IsDelete)
            handler.BeforeDelete(trigger.oldMap);
    }
    
    // After trigger logic
    if (Trigger.IsAfter)
    {
        if (Trigger.IsInsert) 
            handler.AfterInsert(Trigger.new);
        
        if (Trigger.IsUpdate)
            handler.AfterUpdate(trigger.new,trigger.newMap, trigger.oldMap);
        
        if (trigger.IsDelete)
            handler.AfterDelete(trigger.oldMap);
        
        if (trigger.isUndelete)
            handler.AfterUndelete(trigger.oldMap);
    }
}