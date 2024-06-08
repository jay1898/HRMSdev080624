trigger WorkOrderLineItemTrigger on WorkOrderLineItem (after insert, after update) {
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.WOLI_Disable_Trigger__c) ) return ;
    
    if(!WorkOrderLineItemTriggerHandler.RUN_TRIGGER)return ;
     if(Trigger.isAfter && Trigger.isInsert){
     	WorkOrderLineItemTriggerHandler.updateServiceTerritory(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
      	WorkOrderLineItemTriggerHandler.updateServiceTerritory(Trigger.new, Trigger.oldMap);
        WorkOrderLineItemTriggerHandler.pdfgenerator(Trigger.new, Trigger.oldMap);
    }

}