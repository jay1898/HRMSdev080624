trigger Territory2Trigger on Territory2 (after insert,after update) {

// Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Territory_Disable_Trigger__c) ) return ;

    if(Trigger.isInsert && Trigger.isAfter){
        Territory2TriggerHandler.shareSTWithETM(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        Territory2TriggerHandler.updateShareSTWithETM(Trigger.New,Trigger.oldMap);
        Territory2TriggerHandler.updateShareSRWithETM(Trigger.New,Trigger.oldMap);
    }
    
}