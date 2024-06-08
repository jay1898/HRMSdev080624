/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          02/18/2019
*   @TaskSource:    Jira
*   @Purpose:       Purpose to generate a Unique code for Source_Code__c field Whenever a campaign is created in salesforce
*   @Updates:       
*/
public with sharing class CampaignTriggerHandler 
{
    public static void generateUniqueCode(List<Campaign> campaigns) 
    {
        for(Campaign c : campaigns)
        {
            // Update a unique code in SourceCode field 
            c.Source_Code__c = 'PEL' + String.valueof(Math.abs(Crypto.getRandomLong())).substring(0, 9) ; 
        }
    }
    public static void populateAORonCampaign(List<Campaign> campaigns) 
    {
        for(Campaign c : campaigns)
        {
            if(c.AOR__c!=null){
                c.Type='AOR';
            }
        }
        List<User> listUser=[select id,AOR__C from user where Id =:userinfo.getUserId()];
        if(listUser.size()>0 && listUser[0].AOR__C!=null){
            List<Branch_Grouping__c> listBranch=[SELECT ID FROM Branch_Grouping__c where Name = :listUser[0].AOR__c];
            if(listBranch.size()>0){
                for(Campaign c : campaigns)
                {
                    if(c.Type=='AOR' && c.AOR__c==null){
                        c.AOR__c=listBranch[0].Id;
                    }
                }
            }
        }
    }
    public static void shareCampaignWithETM(List<Campaign> campaigns){
        CampaignRecordShare.shareCampaignRecordWithSTM(campaigns);
    }
    
}