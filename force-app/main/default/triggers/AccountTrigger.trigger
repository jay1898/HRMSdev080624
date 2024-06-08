/*
Created By: Mayank Srivastava
Created Date: 11/28/2019
Purpose: This is a trigger for Account with all relevant events.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/

trigger AccountTrigger on Account (before insert, after insert, after update, before update) {
    
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Account_Disable_Trigger__c) ) return ; 
    
    
    // TO Disable All Triggers 
    if(!AccountTriggerHandler.RUN_TRIGGER) return ;
    
   if(Trigger.isBefore && Trigger.isInsert ){
        if(!(cs != null && (cs.Disable_All__c || cs.Account_Disable_VR__c) )){
            // Check Account request is created from stanard UI
            AccountTriggerHandler.isCreatedFromStandardUI(trigger.new);
        }
    }
    
    // Temp.Code end here.
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        //Update branch number based on branch selection
        AccountTriggerHandler.updateBranchNumberOnBranchAccount(trigger.new,trigger.oldMap);
        AccountTriggerHandler.updateServiceAccountPhones(Trigger.new, Trigger.oldMap);
         // Method to update the EDW Last Modified
        //AccountTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.newMap);
    }
    
    //Added by Dhruv on 10/10/2020
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        AccountTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter) {
        
        if(Trigger.isUpdate) {
            
            //Trigger handler class to perform callouts
            if(AccountTriggerHandler.RUN_EBS_CALLOUT) AccountTriggerHandler.updateCustomerEBSCallout(trigger.new, trigger.oldMap);
            
            // Update Parent Account  
            //AccountTriggerHandler.updateBrancIdsOnParentAccount(trigger.new);
            
            // Update Address Assignment
            AccountTriggerHandler.updateAddressAssignment(trigger.newMap,trigger.oldMap);
            
        }//End of if(Trigger.isUpdate)
        
        if(Trigger.isInsert) {
            //system.debug('call insert after');
            //if(AccountTriggerHandler.RUN_EBS_CALLOUT) AccountTriggerHandler.CreateCustomerEBSCallout(trigger.new);
            // Update Parent Account  
            //AccountTriggerHandler.updateBrancIdsOnParentAccount(trigger.new);
            
        }//End of if(Trigger.isInsert)
       AccountTriggerHandler.replacementOppRecordShare(trigger.new,trigger.oldMap) ;
    }//End of if(Trigger.isAfter)
    
}//End of AccountTrigger