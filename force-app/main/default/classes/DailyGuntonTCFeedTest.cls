@isTest
private class DailyGuntonTCFeedTest {
    
    static testMethod void testMethod1() 
    {
        User usr = TestUtil.createUser(true);
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;  
        Account acc = TestUtil.createAccount('Person Account', true);
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', false);
        bf.Branch_Family_Number__c = '123';
        insert bf;
        
        Branch__c br = TestUtil.createBranch('Cleveland', '1001', bf.Id, true);
        ServiceResource sr = TestUtil.createServiceResource('Mayank', usr.Id, br.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        if(br.name == 'Cleveland') {
        Account parentAcc = TestUtil.createBranchAccount('Pella Account', false);
        parentAcc.Temp_branch_Number__c = '5';
        parentAcc.Branch_Number__c = '1001';
        insert parentAcc;
        
        Account childAcc = TestUtil.createBranchAccount('Branch Account', false);
        childAcc.ParentId = parentAcc.Id;
        childAcc.Branch__c = br.Id;
        childAcc.Temp_branch_Number__c = '5';
        childAcc.Branch_Number__c = '1001';
        childAcc.EDW_Last_Modified__c = DateTime.now().AddDays(-5);
        //childAcc.
        insert childAcc;
        
        Opportunity opp = TestUtil.createOpportunity('Test1001', childAcc.Id, userinfo.getUserId(), false);
        opp.CloseDate = Date.valueOf('2020-12-29');
        opp.StageName = 'New';
        opp.Status__c = 'Open';
        opp.RecordTypeId = OppRecTyTCId;
        opp.Type = 'Trade';
        opp.Market_Segment__c = 'SP: Single Family Replacement';
        opp.Approved_Status__c = 'Approved';
        insert opp;
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        Task tk = new task();
        tk.subject = 'Unresolved Email ref: '+childAcc.Id;
        tk.Description = 'test task ';
        tk.WhatId = childAcc.Id;
        insert tk;
        
        Event event = TestUtil.createEvent(usr.Id, false); 
        event.Type= 'Phone Call';
        event.ShowAs = 'Busy';
        event.Account__c = childAcc.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+1);
        EventTriggerHandler.runTrigger = false;
        insert event;
        
        Test.startTest();
        DailyGuntonTCAccountsFeed b = new DailyGuntonTCAccountsFeed(); 
        database.executebatch(b,10);
        DailyGuntonTCOppsFeed c = new DailyGuntonTCOppsFeed(); 
        database.executebatch(c,10);
        DailyGuntonTCQuotesFeed d = new DailyGuntonTCQuotesFeed(); 
        database.executebatch(d,10);
        DailyGuntonTCTasksFeed e = new DailyGuntonTCTasksFeed(); 
        database.executebatch(e,10);
        DailyGuntonTCActivitesFeed f = new DailyGuntonTCActivitesFeed(); 
        database.executebatch(f,10);
        Test.stopTest() ;
        }
    }
    static testMethod void testMethod2() 
    {
        Id OppRecTyId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        User usr = TestUtil.createUser(true);
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep');
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', false);
        bf.Branch_Family_Number__c = '123';
        insert bf;
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Cleveland', '100', bf.Id, true);
        
        if(branch.name == 'Cleveland') {
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);   
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, true);
        
        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        
        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true);       
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false);
        opp.Account_Branch_Profile__c=abp.id;
         opp.RecordTypeId = OppRecTyId ;
        opp.OwnerId = UserInfo.getUserId() ;
        opp.Zone__c = childST.Id ;
        opp.Status__c = 'New';
         opp.Create_Quote_Shell__c = true;
        insert opp;
        //ServiceAppointmentTriggerHandler.RUN_TRIGGER=false;
        
        
        Test.startTest();
        DailyGuntonRetailOppsFeed dailyGuntonRetailOppsFeed = new DailyGuntonRetailOppsFeed(); 
        database.executebatch(dailyGuntonRetailOppsFeed,10);
        Test.stopTest() ;
    } 
    }
}