trigger AssociateAccountTrigger on Associated_Account__c (before insert,before update,after insert, after update, after delete) {
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Associated_Account_Disable_Trigger__c) ) return;
     if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            AssociateAccountTriggerHandler.setNameField(Trigger.New, null) ; 
        }//End of if(Trigger.isInsert)
        
        if(Trigger.isUpdate) {
            AssociateAccountTriggerHandler.setNameField(Trigger.New, Trigger.oldMap) ; 
        }//End of if(Trigger.isUpdate)
        
        
    }//End of if(Trigger.isBefore) 
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            AssociateAccountTriggerHandler.updateYTDonAccount(Trigger.New, null) ; 
        }//End of if(Trigger.isInsert)
        
        if(Trigger.isUpdate) {
            AssociateAccountTriggerHandler.updateYTDonAccount(Trigger.New, Trigger.oldMap) ; 
        }//End of if(Trigger.isUpdate)
        
        if(Trigger.isDelete) {
            AssociateAccountTriggerHandler.updateYTDonAccount(Trigger.old, null); 
        }//End of if(Trigger.isDelete)
        
    }//End of if(Trigger.isAfter) 
}