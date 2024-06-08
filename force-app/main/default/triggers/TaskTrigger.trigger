trigger TaskTrigger on Task (before insert, before update, after insert, after update, after delete) 
{
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Task_Disable_Trigger__c) ) return ;

    if(Trigger.isBefore){
        TaskTriggerHandler.resolveEmailMapping(Trigger.new);
        if(Trigger.isInsert || Trigger.isUpdate)
            
            // Method to update the EDW Last Modified
            TaskTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.oldMap);
        
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert) {
            TaskTriggerHandler.updateOnAccount(Trigger.New, null) ; 
        }
        
        if(Trigger.isUpdate) {
            TaskTriggerHandler.updateOnAccount(Trigger.New, Trigger.oldMap) ; 
            TaskTriggerHandler.createAutoTaskforPIES(Trigger.New, Trigger.oldMap);
        }
        
        if(Trigger.isDelete) {
            TaskTriggerHandler.updateOnAccount(Trigger.old, null); 
        }
    }
}