/*
Created By: 
Created Date: 
Purpose: This is a trigger for Pella Images with all relevant events.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/
trigger PellaImagesTrigger on Pella_Images__c (before insert, after insert, after update, before update) {

    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Pella_Images_Disable_Trigger__c) ) return ; 

    if(Trigger.isAfter) {
        PellaImagesTriggerHandler objPellaImagesTriggerHandler = new PellaImagesTriggerHandler();
        if(Trigger.isUpdate) {
           //Trigger handler class to attach files on opportunity
           objPellaImagesTriggerHandler.addFileOnOpportunity(trigger.oldMap, trigger.new);
            
        }//End of if(Trigger.isUpdate)
         
        if(Trigger.isInsert) {
            
            // Trigger handler class to attach files on opportunity  
            objPellaImagesTriggerHandler.addFileOnOpportunity(null, trigger.new);
            
        }//End of if(Trigger.isInsert)
        
    }//End of if(Trigger.isAfter)
}