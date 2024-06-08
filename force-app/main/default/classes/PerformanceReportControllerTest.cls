@isTest
public class PerformanceReportControllerTest {
    static testMethod void PRTest() 
    {
        // Create User
        
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        TestUtil.createWK52Report('YTD','123','123',true);
        TestUtil.createWK52Report('MTD','123','1234',true);
        TestUtil.createWK52Report('CR',u.Id,'1235',true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Epsilon', false);
        bf.Branch_Family_Number__c = '123';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Ranker__c = 10.0;
        insert sr;
        Test.startTest();
        PerformanceReportController.getServiceResourceRecords();
        PerformanceReportController.getBranchRecords();
        
        PerformanceReportController.getPublisReportResult();
        PerformanceReportController.getYTDReportResult();
        PerformanceReportController.getMTDReportResult();
        PerformanceReportController.getCRReportResult();
        PerformanceReportController.getCurrentAndPreviousFiscalYear();
        PerformanceReportController.getCRReportResultForRank();
		PerformanceReportController.getAllBranchRecords();
		new PerformanceReportController.report();      
        Test.stopTest();
    }
    static testMethod void PerformanceReportWithDate() 
    {
        
        Date PrevYearStarDate,PrevYearEndDate;
        Date CurrentYearStarDate,CurrentYearEndDate;
        CurrentYearStarDate = Date.today().toStartOfMonth();
        CurrentYearEndDate = Date.today();
        PrevYearStarDate = CurrentYearStarDate.addYears(-1);
        PrevYearEndDate = CurrentYearEndDate.addYears(-1);
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.Prospect_Type__c='New Prospect';
        insert ac;
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        // Create Branch
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        
        List<Id> OppIds = new List<Id>();
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Phoenix';
        insert oh;
        
        //Parent Level Territory
        ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
        stParent.PostalCode = '10000';
        stParent.Branch__c=branch.Id;
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '20000';
        stZone.Lead_Receiver__c = usr.id;
        insert stZone;   
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.Account_Branch_Profile__c = abp.Id;
        opp.Status__c = 'Canceled';
        opp.StageName = 'Closed';
        opp.Book_Date_PQM__c = system.today().addDays(-5);
        opp.Appointment_DateTime__c = system.today().addDays(-5);
        opp.Createddate = PrevYearStarDate;
        opp.Zone__c = stZone.Id;
        opp.Signed_Contract_Date__c = system.today().addDays(-5);
        insert opp;
        
        List<Opportunity> listOpps=new List<Opportunity>();
        // Create 5st Opportunity 
        Opportunity opp5 = TestUtil.createOpportunity('New Opp1', ac.Id, usr.Id, false); 
        opp5.Account_Branch_Profile__c = abp.Id;
        opp5.Status__c = 'First Call Close';
        opp5.StageName = 'Closed Won';
        opp5.LeadSource='Showroom';
        opp5.Showroom_Request_Type__c='Branch-Gen';
        opp5.Appointment_Type__c='RT';
        opp5.Book_Date_PQM__c = system.today().addDays(-5);
        opp5.Appointment_DateTime__c = system.today().addDays(-5);
        opp5.Createddate = PrevYearStarDate;
        opp5.Zone__c = stZone.Id;
        opp5.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp5;
        listOpps.add(opp5);
        OppIds.add(opp5.Id);
        
         // Create 5st Opportunity 
        Opportunity opp6 = TestUtil.createOpportunity('New Opp1', ac.Id, usr.Id, false); 
        opp6.Account_Branch_Profile__c = abp.Id;
        opp6.Status__c = 'First Call Close';
        opp6.StageName = 'Closed Won';
        opp6.LeadSource='Showroom';
        opp6.Showroom_Request_Type__c='Self-Gen';
        opp6.Appointment_Type__c='RT';
        opp6.Book_Date_PQM__c = system.today().addDays(-5);
        opp6.Appointment_DateTime__c = system.today().addDays(-5);
        opp6.Createddate = PrevYearStarDate;
        opp6.Zone__c = stZone.Id;
        opp6.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp6;
        listOpps.add(opp6);
        OppIds.add(opp6.Id);
        
        
         // Create 5st Opportunity 
        Opportunity opp7 = TestUtil.createOpportunity('New Opp1', ac.Id, usr.Id, false); 
        opp7.Account_Branch_Profile__c = abp.Id;
        opp7.Status__c = 'Canceled';
        opp7.StageName = 'Closed';
        opp7.LeadSource='Showroom';
        opp7.Showroom_Request_Type__c='Self-Gen';
        opp7.Appointment_Type__c='RT';
        opp7.Book_Date_PQM__c = system.today().addDays(-5);
        opp7.Appointment_DateTime__c = system.today().addDays(-5);
        opp7.Createddate = PrevYearStarDate;
        opp7.Zone__c = stZone.Id;
        opp7.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp7;
        listOpps.add(opp7);
        OppIds.add(opp7.Id);
        
        
        
         // Create 5st Opportunity 
        Opportunity opp8 = TestUtil.createOpportunity('New Opp1', ac.Id, usr.Id, false); 
        opp8.Account_Branch_Profile__c = abp.Id;
        opp8.Status__c = 'Transferred to Commercial';
        opp8.StageName = 'Closed';
        opp8.LeadSource='Showroom';
        opp8.Showroom_Request_Type__c='Self-Gen';
        opp8.Appointment_Type__c='RT';
        opp8.Book_Date_PQM__c = system.today().addDays(-5);
        opp8.Appointment_DateTime__c = system.today().addDays(-5);
        opp8.Createddate = PrevYearStarDate;
        opp8.Zone__c = stZone.Id;
        opp8.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp8;
        listOpps.add(opp8);
        OppIds.add(opp8.Id);
        
        insert listOpps;
        Test.startTest();
        
        //create Quote
        Quote qt = TestUtil.createQuote(opp5.Id, false);
        qt.Signed_Contract_Date__c = PrevYearStarDate; //system.today().addDays(-5);
        qt.BookDate__c =  PrevYearStarDate; 
        insert qt;
        
        //create Quote
        Quote qt1 = TestUtil.createQuote(opp5.Id, false);
        qt1.Signed_Contract_Date__c = PrevYearStarDate;
        qt1.BookDate__c = PrevYearStarDate; 
        insert qt1;
        
        
        List<Id> UserIds = new List<Id>();
        UserIds.add(usr.Id);
        UserIds.add(UserInfo.getUserId());
        
        PerformanceReportController.getResultDataWithDate(branch.Id, CurrentYearStarDate, CurrentYearEndDate, PrevYearStarDate, PrevYearEndDate, false, 'All');
        
        Test.stopTest(); 
    }
    static testMethod void PerformanceReportWithDate2() 
    {
        
        Date PrevYearStarDate,PrevYearEndDate;
        Date CurrentYearStarDate,CurrentYearEndDate;
        CurrentYearStarDate = Date.today().toStartOfMonth();
        CurrentYearEndDate = Date.today();
        PrevYearStarDate = CurrentYearStarDate.addYears(-1);
        PrevYearEndDate = CurrentYearEndDate.addYears(-1);
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.Prospect_Type__c='New Prospect';
        insert ac;
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        // Create Branch
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        
        List<Id> OppIds = new List<Id>();
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Phoenix';
        insert oh;
        
        //Parent Level Territory
        ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
        stParent.PostalCode = '10000';
        stParent.Branch__c=branch.Id;
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '20000';
        stZone.Lead_Receiver__c = usr.id;
        insert stZone;   
        
       
        List<Opportunity> listOpps=new List<Opportunity>();
        // Create 5st Opportunity 
        Opportunity opp5 = TestUtil.createOpportunity('New Opp1', ac.Id, usr.Id, false); 
        opp5.Account_Branch_Profile__c = abp.Id;
        opp5.Status__c = 'First Call Close';
        opp5.StageName = 'Closed Won';
        opp5.LeadSource='Showroom';
        opp5.Showroom_Request_Type__c='Branch-Gen';
        opp5.Appointment_Type__c='RT';
        opp5.Book_Date_PQM__c = system.today().addDays(-5);
        opp5.Appointment_DateTime__c = system.today().addDays(-5);
        opp5.Createddate = PrevYearStarDate;
        opp5.Zone__c = stZone.Id;
        opp5.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp5;
        listOpps.add(opp5);
        OppIds.add(opp5.Id);
        
        
        
         // Create 5st Opportunity 
        Opportunity opp8 = TestUtil.createOpportunity('New Opp1', ac.Id, usr.Id, false); 
        opp8.Account_Branch_Profile__c = abp.Id;
        opp8.Status__c = 'Transferred to Commercial';
        opp8.StageName = 'Closed';
        opp8.LeadSource='Showroom';
        opp8.Showroom_Request_Type__c='Self-Gen';
        opp8.Appointment_Type__c='RT';
        opp8.Book_Date_PQM__c = system.today().addDays(-5);
        opp8.Appointment_DateTime__c = system.today().addDays(-5);
        opp8.Createddate = PrevYearStarDate;
        opp8.Zone__c = stZone.Id;
        opp8.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp8;
        listOpps.add(opp8);
        OppIds.add(opp8.Id);
        
        insert listOpps;
        Test.startTest();
        
        //create Quote
        Quote qt = TestUtil.createQuote(opp5.Id, false);
        qt.Signed_Contract_Date__c = PrevYearStarDate; //system.today().addDays(-5);
        qt.BookDate__c =  PrevYearStarDate; 
        insert qt;
        
        //create Quote
        Quote qt1 = TestUtil.createQuote(opp5.Id, false);
        qt1.Signed_Contract_Date__c = PrevYearStarDate;
        qt1.BookDate__c = PrevYearStarDate; 
        insert qt1;
          
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
       
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp5.Id, lead.Id, false);
        sa.Status = 'Scheduled';
        sa.Rehash_Appointment__c=true;
        insert sa ;
        
        List<Id> UserIds = new List<Id>();
        UserIds.add(usr.Id);
        UserIds.add(UserInfo.getUserId());
        
        PerformanceReportController.getResultDataWithDate(usr.Id, CurrentYearStarDate, CurrentYearEndDate, PrevYearStarDate, PrevYearEndDate, true, 'All');
        
        Test.stopTest(); 
    }
}