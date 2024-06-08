trigger EventTrigger on Event (before insert,after insert,before update, after update, after delete) 
{
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Event_Disable_Trigger__c ) ) return ;
    
    // Exclude execution for Profiles (Trade_Comm Sales and Trade_Comm Sales Management)
    //if(EventTriggerHandler.profileIdsToExclude.contains(UserInfo.getProfileId())) return ;
    
    //Perform apex validation for checking salesResource status
    /* if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
{  
EventTriggerHandler.validate(Trigger.new);
}*/
    
    if(EventTriggerHandler.runTrigger)
    {
        if(EventTriggerHandler.profileIdsToExclude.contains(UserInfo.getProfileId())){
            if(Trigger.isAfter && Trigger.isUpdate){ 
                EventTriggerHandler.updateOnAccount(Trigger.New, Trigger.oldMap) ; 
               
                
            }  
            if(Trigger.isAfter && Trigger.isDelete){
                EventTriggerHandler.updateOnAccount(Trigger.old, null); 
                
            }
            if(Trigger.isAfter && Trigger.isInsert){
                EventTriggerHandler.updateOnAccount(Trigger.New, null); 
            }   
        } else{
            if(Trigger.isBefore && Trigger.isInsert)
            {
                EventTriggerHandler.createServiceAppointement(Trigger.new, Trigger.oldMap); 
                EventTriggerHandler.createAbsenceResource(Trigger.new); 
                // Method to update the EDW Last Modified
                EventTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.oldMap);
                
            }  
            if(Trigger.isBefore && Trigger.isUpdate)
            {
                EventTriggerHandler.RTAAppointmentDateChangeValidation(Trigger.new, Trigger.oldMap);
                EventTriggerHandler.updateAbsenceResource(Trigger.new, Trigger.oldMap); 
                // Method to update the EDW Last Modified
                EventTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.oldMap);
            }
            
            if(Trigger.isAfter && Trigger.isUpdate){
                EventTriggerHandler.deleteOldAbsenceResourceOnChange(Trigger.new, Trigger.oldMap);    
                EventTriggerHandler.updateServiceAppointement(Trigger.new, Trigger.oldMap);  
                EventTriggerHandler.updateOnAccount(Trigger.New, Trigger.oldMap) ; 
                
            }  
            if(Trigger.isAfter && Trigger.isDelete){
                system.debug('After Delete');
                EventTriggerHandler.deleteAbsenceResource(Trigger.old);
                EventTriggerHandler.updateOnAccount(Trigger.old, null); 
                
            }
            if(Trigger.isAfter && Trigger.isInsert){
                EventTriggerHandler.updateOnAccount(Trigger.New, null);
               
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isDelete){
                EventTriggerHandler.ManageChildAbsenceResource(Trigger.old, Trigger.oldMap);
            }else{
                EventTriggerHandler.ManageChildAbsenceResource(Trigger.New, Trigger.oldMap);
            }
            
        }
    }
}