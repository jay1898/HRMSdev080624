trigger WorkOrderTrigger on WorkOrder (after insert, after update) {

 	// Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.WO_Disable_Trigger__c) ) return ;
    
    
    if(!WorkOrderTriggerHandler.RUN_TRIGGER)return;
    if(Trigger.isAfter && Trigger.isInsert){
        WorkOrderTriggerHandler.updateServiceTerritory(Trigger.new, Trigger.oldMap);
        WorkOrderTriggerHandler.wordorderRecordShare(Trigger.new, Trigger.oldMap);
       
    }
    system.debug('WorkOrderTrigger line 9');
    if(Trigger.isAfter && Trigger.isUpdate){
        //WorkOrderTriggerHandler.pdfgenerator(Trigger.new, Trigger.oldMap);
      WorkOrderTriggerHandler.wordorderRecordShare(Trigger.new, Trigger.oldMap);
        WorkOrderTriggerHandler.updateServiceTerritory(Trigger.new, Trigger.oldMap);
    }
}