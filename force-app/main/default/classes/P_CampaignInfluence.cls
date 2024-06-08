public class P_CampaignInfluence {
    
    @AuraEnabled(cacheable=true)
    public static List<CampaignInfluenceWrapper> fetchCampInfluenceByAccId(String accId) {
        
        List<CampaignInfluenceWrapper> influenceList = new List<CampaignInfluenceWrapper>();
        
        
        for(Campaign_Influence_For_Account__c campAcc : [SELECT Id, CreatedDate, Account__c, Campaign__c, Campaign__r.Name, Account__r.Name, 
                                                         LastModifiedDate 
                                                         FROM Campaign_Influence_For_Account__c 
                                                         WHERE Account__c= :accId order by CreatedDate DESC])
        {
            CampaignInfluenceWrapper cIW = new CampaignInfluenceWrapper();
            cIW.CampaignId = campAcc.Campaign__c;
            cIW.CampaignName = campAcc.Campaign__r.Name;
            cIW.AccountId = campAcc.Account__c;
            cIW.AccountName = campAcc.Account__r.Name;
            cIW.OpportunityName = null;
            cIW.OpportunityId = null;
            cIW.CreatedDate = campAcc.CreatedDate;
            cIW.LastModifiedDate = campAcc.LastModifiedDate;
            influenceList.add(cIW);            
        }

        for(CampaignInfluence camp : [SELECT Id, CampaignId, Campaign.Name, CreatedDate, LastModifiedDate, ModelId, 
                                      Opportunity.AccountId, Opportunity.Account.Name, OpportunityId, Opportunity.Name
                                      FROM CampaignInfluence 
                                      WHERE Opportunity.AccountId= :accId order by CreatedDate DESC])
        {
            CampaignInfluenceWrapper cIW = new CampaignInfluenceWrapper();
            cIW.CampaignId = camp.CampaignId;
            cIW.CampaignName = camp.Campaign.Name;
            cIW.OpportunityName = camp.Opportunity.Name;
            cIW.OpportunityId = camp.OpportunityId;
            cIW.AccountId = camp.Opportunity.AccountId;
            cIW.AccountName = camp.Opportunity.Account.Name;
            cIW.CreatedDate = camp.CreatedDate;
            cIW.LastModifiedDate = camp.LastModifiedDate;
            influenceList.add(cIW);
        }
        
        
        
        return influenceList;
    }
    
    
    
    public class CampaignInfluenceWrapper{
        @AuraEnabled public Id CampaignId {get;set;}
        @AuraEnabled public String CampaignName {get;set;}
        @AuraEnabled public String OpportunityName {get;set;}
        @AuraEnabled public Id OpportunityId {get;set;}
        @AuraEnabled public DateTime CreatedDate {get;set;}
        @AuraEnabled public DateTime LastModifiedDate {get;set;}
        @AuraEnabled public Id AccountId {get;set;}
        @AuraEnabled public String AccountName {get;set;}
    }
}