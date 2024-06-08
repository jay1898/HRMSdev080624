/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          12/26/2019
*   @TaskSource:    Jira
*   @Purpose:       Trigger to generate a Unique code for Pel_Campaign_Code__c field Whenever a campaing is created in salesforce
*   @Updates:       
*/
trigger CampaignTrigger on Campaign(before insert,after insert) 
{
	// Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Campaign_Disable_Trigger__c ) ) return ;
    if(Trigger.isBefore && Trigger.isInsert){
        CampaignTriggerHandler.generateUniqueCode(Trigger.new);
        CampaignTriggerHandler.populateAORonCampaign(Trigger.new);
    }
     if(Trigger.isAfter && Trigger.isInsert){
        CampaignTriggerHandler.shareCampaignWithETM(Trigger.new);
    }
}