trigger UserTerritory2AssociationTrigger on UserTerritory2Association (before insert,before update,after insert,before delete) {
    
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.UserTerritoryAssociat_Disable_Trigger__c) ) return ;
    
    if(!UserTerritory2AssociationTriggerHandler.runTrigger) return;
    
    if(trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate)){ 
        UserTerritory2AssociationTriggerHandler.validateUserTerritoryRole(Trigger.New,Trigger.oldMap);
    } 
    if(Trigger.isAfter && Trigger.isInsert){
        UserTerritory2AssociationTriggerHandler.shareRecordsWithUTA(Trigger.New);
    }
    if(trigger.isBefore && Trigger.isDelete){ 
        UserTerritory2AssociationTriggerHandler.removeShareRecordsWithUTA(Trigger.old);
    }
}