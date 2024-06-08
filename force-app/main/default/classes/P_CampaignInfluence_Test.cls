@istest
public class P_CampaignInfluence_Test {

    @isTest
    public static void testGetCampInfluence(){
        
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        System.debug('OppRecTyTCId '+OppRecTyTCId);
        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', true);
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        // create Camp rec
        Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
        insert Cp;
        
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.RecordTypeId = OppRecTyTCId ;
        opp.CampaignId=Cp.Id;
        insert opp;
        
        System.debug('opp Id '+opp.Id); 
        oppList.add(opp);
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        CampaignInfluence ci = new CampaignInfluence();
        ci.CampaignId = Cp.Id;
        ci.OpportunityId = opp.Id;
        ci.ModelId = '03V3i000000Grf2EAC';
        insert ci;
        
        Campaign_Influence_For_Account__c cc = new Campaign_Influence_For_Account__c();
        cc.Account__c = ac.Id;
        cc.Campaign__c = Cp.Id;
        insert cc;
        
        P_CampaignInfluence.fetchCampInfluenceByAccId(ac.Id);
        
        Test.stopTest();
        
    }
}