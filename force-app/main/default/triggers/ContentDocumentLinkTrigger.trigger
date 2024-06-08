trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Content_Document_Link_Disable_Trigger__c) ) return ;
    
    if(!ContentDocumentLinkTriggerHandler.RUN_TRIGGER)return; 
    
    if(Trigger.isAfter && Trigger.isInsert){
        ContentDocumentLinkTriggerHandler.shareWorkOrderfile(Trigger.New);
    }
    
}