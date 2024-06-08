trigger SalesQuotaTrigger on Sales_Quota__c (after insert) {
	// Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c) ) return ;
    
    if(Trigger.isAfter && Trigger.isInsert){
       SalesQuotaTriggerHandler.populateAssociatedQuotesForQuota(Trigger.new, Trigger.newMap);
    }
}