trigger QuoteTrigger on Quote (after insert,after update,after delete, before delete, before insert,before update) {
    
    if(!QuoteTriggerHandler.isRecursive)
    {
        // Get custom settings, Check object trigger settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Quote_Disable_Trigger__c) ) return ; 
        
        if(Trigger.isBefore) {
            if(Trigger.isInsert || Trigger.isUpdate) {
                QuoteTriggerHandler.resetFieldOnQuoteCancel(Trigger.New);
                QuoteTriggerHandler.tradeCommercialDataUpdate(Trigger.New,Trigger.oldMap);
                // added 10-03-2022
                QuoteTriggerHandler.createSWORecord(Trigger.New,Trigger.oldMap);
            }
            if(Trigger.isInsert) {
                QuoteTriggerHandler.updatePCCOpportunityName(Trigger.New);
            }
            if(Trigger.isDelete) {
                QuoteTriggerHandler.removeSalesQuotaAssociations(Trigger.old, null);
            }
        }
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                QuoteTriggerHandler.updateOpportunityTotalPriceQuote(Trigger.New,null);    
                QuoteTriggerHandler.updateYTDonAccount(Trigger.New, null); 
                QuoteTriggerHandler.updatePYTDonAccount(Trigger.New, null);
                QuoteTriggerHandler.updateSWOPrimaryQuote(Trigger.New, null);
                QuoteTriggerHandler.createSalesQuotaAssociationForQuote(Trigger.New, null);
            }//End of if(Trigger.isInsert)
            
            if(Trigger.isUpdate) {
                QuoteTriggerHandler.updateOpportunityTotalPriceQuote(Trigger.New,Trigger.oldMap);
                //QuoteTriggerHandler.createInstallerPayoutRecord(Trigger.New,Trigger.oldMap);
                //pallavi
                QuoteTriggerHandler.updateYTDonAccount(Trigger.New, Trigger.oldMap);
                QuoteTriggerHandler.updatePYTDonAccount(Trigger.New, null);
                QuoteTriggerHandler.updateSalesQuotaAssociationForQuote(Trigger.New, Trigger.oldMap);
            }//End of if(Trigger.isUpdate)
            
            
            if(Trigger.isDelete) {
                QuoteTriggerHandler.updateOpportunityTotalPriceQuote(Trigger.old,null);  
                QuoteTriggerHandler.updateYTDonAccount(Trigger.old,null); 
            }//End of if(Trigger.isDelete)
            
        }//End of if(Trigger.isAfter) 
    } 
}//End of AccountTrigger