@IsTest
public class P_UpdateCampaigns_Test {
    
    @IsTest
    private static void testUpdateCampaignsOpps() {
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        User usr = TestUtil.createUser(true);
        
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        // create Camp rec
        Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
        insert Cp;
        
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
        
        opp.StageName = 'Closed Won';
        update opp;

        Test.startTest();
        P_UpdateCampaignsCountBatchOpps pcb = new P_UpdateCampaignsCountBatchOpps();
        Database.executeBatch(pcb);
        
        DateTime toDate = System.now().addMinutes(1);//next 10 min;
        Integer nextDay = toDate.day();
        Integer nextMonth = toDate.month();
        Integer nextYear = toDate.year();
        Integer hrNow = toDate.hour();
        Integer minNow = toDate.minute();
        
        String schTime = '0 '+minNow+' '+hrNow+' '+nextDay+' '+nextMonth+' ? '+nextYear+'';
        DateTime dt = DateTime.now();
        String nowTime = dt.format('yyyy/MM/dd HH:mm:ss');
        
        System.schedule('P_UpdateCampaignsCountSchedulable : '+nowTime+': For :'+minNow, schTime , new P_UpdateCampaignsCountSchedulable());
        
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testUpdateCampaignLeads() {
        User usr = TestUtil.createUser(true);
        
        List<Lead> leads = new List<Lead>();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Trade_Lead_Receiver__c = usr.Id;
        insert branch;
        
        Campaign camp = TestUtil.createCampaign('Pella.com – Get A Quote', branch.Id ,  True);
        
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        for(Integer i=0; i<10; i++)
        {
            Lead ld = TestUtil.createLead( 'TestLead' +String.valueOf(i), 'LastnameTestLead' + String.valueOf(i), false ) ;
            ld.Originating_System__c = 'Eloqua';
            ld.Campaign__c = camp.Id;
            ld.RecordTypeId = leadRecordTypeId ;
            ld.Business_Segment__c = 'Commercial';
            ld.Lead_Type__c = 'Commercial Building Owner';
            ld.PostalCode = '13116';
            leads.add(ld);
        }
        insert leads ;
        Test.startTest();
        P_UpdateCampaignsCountBatchLeads pcb = new P_UpdateCampaignsCountBatchLeads();
        Database.executeBatch(pcb);
        Test.stopTest();
    }
}