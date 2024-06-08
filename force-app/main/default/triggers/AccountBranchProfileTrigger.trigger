trigger AccountBranchProfileTrigger on Account_Branch_Profile__c( after insert, after update, after delete ) 
{
	List<Account_Branch_Profile__c> abps = Trigger.isDelete ? Trigger.old : Trigger.new ;

	// Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.ABP_Disable_Trigger__c) ) return ;

    AccountBranchProfileTriggerHandler.updateBrancIdsOnAccount(abps);
}