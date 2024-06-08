@isTest
public class PerformanceReportBatchHandlerTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2050';
    
    static testMethod void PerformanceReportTest1() 
    {
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
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '20000';
        stZone.Lead_Receiver__c = usr.id;
        insert stZone;   
        
        List<Opportunity> listOpps=new List<Opportunity>();
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.Account_Branch_Profile__c = abp.Id;
        opp.Status__c = 'Canceled';
        opp.StageName = 'Closed';
        opp.Book_Date_PQM__c = system.today().addDays(-5);
        opp.Appointment_DateTime__c = system.today().addDays(-5);
        opp.Createddate = system.today().addDays(-5);
        opp.Zone__c = stZone.Id;
        opp.Signed_Contract_Date__c = system.today().addDays(-5);
        //insert opp;
        listOpps.add(opp);
        // Create 2st Opportunity
        Opportunity opp1 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp1.Account_Branch_Profile__c = abp.Id;
        opp1.Status__c = 'First Call Close';
        opp1.StageName = 'Closed Won';
        opp1.Book_Date_PQM__c = system.today().addDays(-5);
        opp1.Appointment_DateTime__c = system.today().addDays(-5);
        opp1.Createddate = Date.today().toStartOfMonth().addDays(-120);
        opp1.Zone__c = stZone.Id;
        opp1.Signed_Contract_Date__c = system.today().addDays(-5);
        //insert opp1;
        listOpps.add(opp1);
        OppIds.add(opp1.Id);
        
        // Create 3st Opportunity(90 days) 
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp2.Account_Branch_Profile__c = abp.Id;
        opp2.Status__c = 'First Call Close';
        opp2.StageName = 'Closed Won';
        opp2.Book_Date_PQM__c = system.today().addDays(-5);
        opp2.Appointment_DateTime__c = system.today().addDays(-5);
        opp2.Createddate = Date.today().addDays(-459);
        opp2.Zone__c = stZone.Id;
        opp2.Signed_Contract_Date__c = system.today().addDays(-5);
        //insert opp2;
        listOpps.add(opp2);
        OppIds.add(opp2.Id);
        
        // Create 4st Opportunity(90 days)  
        Opportunity opp3 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp3.Account_Branch_Profile__c = abp.Id; 
        opp3.Status__c = 'First Call Close';
        opp3.StageName = 'Closed Won';
        opp3.Book_Date_PQM__c = system.today().addDays(-374);
        opp3.Appointment_DateTime__c = system.today().addDays(-5);
        opp3.Createddate = Date.today().addDays(-364);
        opp3.Zone__c = stZone.Id;
        opp3.Total_Price_Quote__c = 100;
        opp3.Total_BAC_Price_Quote__c = 50;
        opp3.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp3;
        listOpps.add(opp3);
        OppIds.add(opp3.Id);
        
        // Create 5st Opportunity 
        Opportunity opp4 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp4.Account_Branch_Profile__c = abp.Id;
        opp4.Status__c = 'First Call Close';
        opp4.StageName = 'Closed Won';
        opp4.Book_Date_PQM__c = system.today().addDays(-5);
        opp4.Appointment_DateTime__c = system.today().addDays(-5);
        opp4.Createddate = Date.today().addDays(-60);
        opp4.Zone__c = stZone.Id;
        opp4.Signed_Contract_Date__c = system.today().addDays(-305);
        //insert opp4;
        listOpps.add(opp4);
        OppIds.add(opp4.Id);
        insert listOpps;
        
        Test.startTest();
        List<Id> UserIds = new List<Id>();
        UserIds.add(usr.Id);
        UserIds.add(UserInfo.getUserId());
        
        PerformanceReportBatchHandler.getResultData(OppIds);
        PerformanceReportBatchHandler.getMTDResultData(OppIds);
        PerformanceReportBatchHandler.getCoachingReportResultData(UserIds);
        
        Set<decimal> listResult = new Set<decimal>();
        listResult.add(4);
        PerformanceReportBatchHandler.sorting(true, listResult);
        Test.stopTest(); 
    }
    static testMethod void PerformanceReportTest2() 
    {
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
        opp5.Createddate = Date.today().addDays(-60);
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
        opp6.Createddate = Date.today().addDays(-60);
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
        opp7.Createddate = Date.today().addDays(-60);
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
        opp8.Createddate = Date.today().addDays(-60);
        opp8.Zone__c = stZone.Id;
        opp8.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp8;
        listOpps.add(opp8);
        OppIds.add(opp8.Id);
        
        insert listOpps;
        
        //create Quote
        Quote qt = TestUtil.createQuote(opp5.Id, false);
        qt.Signed_Contract_Date__c = Date.today().toStartOfMonth().addDays(-20); //system.today().addDays(-5);
        qt.BookDate__c =  Date.today().toStartOfMonth().addDays(-20); 
        insert qt;
        
        Test.startTest();
        
        //create Quote
        Quote qt1 = TestUtil.createQuote(opp5.Id, false);
        qt1.Signed_Contract_Date__c = Date.today().toStartOfMonth().addDays(20);
        qt1.BookDate__c = Date.today().toStartOfMonth().addDays(20); 
        insert qt1;
        
        List<Id> UserIds = new List<Id>();
        UserIds.add(usr.Id);
        UserIds.add(UserInfo.getUserId());
        
        PerformanceReportBatchHandler.getResultData(OppIds);
        PerformanceReportBatchHandler.getMTDResultData(OppIds);
        PerformanceReportBatchHandler.getCoachingReportResultData(UserIds);
        
        Set<decimal> listResult = new Set<decimal>();
        listResult.add(4);
        PerformanceReportBatchHandler.sorting(true, listResult);
        Test.stopTest(); 
    }
    static testMethod void PerformanceReportTest3() 
    {
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
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '20000';
        stZone.Lead_Receiver__c = usr.id;
        insert stZone;   
        
        
        List<Opportunity> listOppsToInsert=new List<Opportunity>();
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
        opp5.Createddate = Date.today().addDays(-453);
        opp5.Zone__c = stZone.Id;
        opp5.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp5;
        listOppsToInsert.add(opp5);
        
        
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
        opp6.Createddate = Date.today().addDays(-453);
        opp6.Zone__c = stZone.Id;
        opp6.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp6;
        listOppsToInsert.add(opp6);
        
        
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
        opp7.Createddate = Date.today().addDays(-453);
        opp7.Zone__c = stZone.Id;
        opp7.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp7;
       listOppsToInsert.add(opp7);
        
        
        
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
        opp8.Createddate = Date.today().addDays(-453);
        opp8.Zone__c = stZone.Id;
        opp8.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp8;
        listOppsToInsert.add(opp8);
        
        insert listOppsToInsert;
        
        OppIds.add(opp5.Id);
        OppIds.add(opp6.Id);
        OppIds.add(opp7.Id);
        OppIds.add(opp8.Id);
        Test.startTest();
        
        //create Quote
        Quote qt = TestUtil.createQuote(opp5.Id, false);
        qt.Signed_Contract_Date__c = Date.today().toStartOfMonth().addDays(-20); //system.today().addDays(-5);
        qt.BookDate__c =  Date.today().toStartOfMonth().addDays(-20); 
        insert qt;
        
        //create Quote
        Quote qt1 = TestUtil.createQuote(opp5.Id, false);
        qt1.Signed_Contract_Date__c = Date.today().toStartOfMonth().addDays(20);
        qt1.BookDate__c = Date.today().toStartOfMonth().addDays(20); 
        insert qt1;
        
        List<Id> UserIds = new List<Id>();
        UserIds.add(usr.Id);
        UserIds.add(UserInfo.getUserId());
        
        PerformanceReportBatchHandler.getResultData(OppIds);
        PerformanceReportBatchHandler.getMTDResultData(OppIds);
        PerformanceReportBatchHandler.getCoachingReportResultData(UserIds);
        
        Set<decimal> listResult = new Set<decimal>();
        listResult.add(4);
        PerformanceReportBatchHandler.sorting(true, listResult);
        Test.stopTest(); 
    }
    static testMethod void PerformanceReportTest4() 
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
        
        List<Opportunity> listOppRec=new List<Opportunity>();
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
        listOppRec.add(opp5);
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
        listOppRec.add(opp6);
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
        listOppRec.add(opp7);
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
        listOppRec.add(opp8);
        OppIds.add(opp8.Id);

		insert listOppRec;
		OppIds=new List<Id>();
        for(Opportunity opprec :listOppRec)  {
            OppIds.add(opprec.Id);
        }     
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
        
        PerformanceReportBatchHandler.getResultData(OppIds);
        PerformanceReportBatchHandler.getMTDResultData(OppIds);
        PerformanceReportBatchHandler.getCoachingReportResultData(UserIds);
        
        Set<decimal> listResult = new Set<decimal>();
        listResult.add(4);
        PerformanceReportBatchHandler.sorting(true, listResult);
        Test.stopTest(); 
    }
    static testMethod void PerformanceReportTest5() 
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
        opp.Createddate = CurrentYearStarDate;
        opp.Zone__c = stZone.Id;
        opp.Signed_Contract_Date__c = system.today().addDays(-5);
        insert opp;
        
        List<Opportunity> listOppRec=new List<Opportunity>();

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
        opp5.Createddate = CurrentYearStarDate;
        opp5.Zone__c = stZone.Id;
        opp5.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp5;
        listOppRec.add(opp5);
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
        opp6.Createddate = CurrentYearStarDate;
        opp6.Zone__c = stZone.Id;
        opp6.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp6;
        listOppRec.add(opp6);
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
        opp7.Createddate = CurrentYearStarDate;
        opp7.Zone__c = stZone.Id;
        opp7.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp7;
        listOppRec.add(opp7);
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
        opp8.Createddate = CurrentYearStarDate;
        opp8.Zone__c = stZone.Id;
        opp8.Signed_Contract_Date__c = system.today().addDays(-365);
        //insert opp8;
        listOppRec.add(opp8);
        OppIds.add(opp8.Id);
        
        insert listOppRec;
		OppIds=new List<Id>();
        for(Opportunity opprec :listOppRec)  {
            OppIds.add(opprec.Id);
        }     
        Test.startTest();
        
        //create Quote
        Quote qt = TestUtil.createQuote(opp5.Id, false);
        qt.Signed_Contract_Date__c = CurrentYearStarDate; //system.today().addDays(-5);
        qt.BookDate__c = CurrentYearStarDate; 
        insert qt;
        
        //create Quote
        Quote qt1 = TestUtil.createQuote(opp5.Id, false);
        qt1.Signed_Contract_Date__c = CurrentYearStarDate;
        qt1.BookDate__c = CurrentYearStarDate; 
        insert qt1;
        
        List<Id> UserIds = new List<Id>();
        UserIds.add(usr.Id);
        UserIds.add(UserInfo.getUserId());
        
        PerformanceReportBatchHandler.getResultData(OppIds);
        PerformanceReportBatchHandler.getMTDResultData(OppIds);
        PerformanceReportBatchHandler.getCoachingReportResultData(UserIds);
        
        Set<decimal> listResult = new Set<decimal>();
        listResult.add(4);
        PerformanceReportBatchHandler.sorting(true, listResult);
        Test.stopTest(); 
    }
    static testMethod void PerformanceReportTest6() 
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
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '20000';
        stZone.Lead_Receiver__c = usr.id;
        insert stZone;   
        
        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', usr.Id, branch.Id, bf.Id, false);
        sr.Ranker__c = 10.0;
        insert sr;
        
        // Create 1st Service Resource
        sr = TestUtil.createServiceResource('Mayank1', UserInfo.getUserId(), branch.Id, bf.Id, false);
        sr.Ranker__c = 11.0;
        insert sr;
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.Account_Branch_Profile__c = abp.Id;
        opp.Status__c = 'Canceled';
        opp.StageName = 'Closed';
        opp.Book_Date_PQM__c = system.today().addDays(-5);
        opp.Appointment_DateTime__c = system.today().addDays(-5);
        opp.Createddate = CurrentYearStarDate;
        opp.Zone__c = stZone.Id;
        opp.Signed_Contract_Date__c = system.today().addDays(-5);
        insert opp;
          
       
        Test.startTest();
        List<Id> UserIds = new List<Id>();
        UserIds.add(usr.Id);
        UserIds.add(UserInfo.getUserId());
        OppIds.add(opp.Id);
        PerformanceYTDReportBatch BatchApex = new PerformanceYTDReportBatch(); 
        PerformanceMTDReportBatch BatchApex1 = new PerformanceMTDReportBatch();  
        
        Map<String,PerformanceReportBatchHandler.ReportResult> mapRR=PerformanceReportBatchHandler.getResultData(OppIds);
        for(String branchName : mapRR.keySet()){
            if(!BatchApex.mapReportResult.containsKey(branchName)){
                BatchApex.mapReportResult.put(branchName,mapRR.get(branchName));
            }
            if(!BatchApex1.mapReportResult.containsKey(branchName)){
                BatchApex1.mapReportResult.put(branchName,mapRR.get(branchName));
            }
        }
        DataBase.executeBatch(BatchApex);
        String jobId = System.schedule('PerformanceYTDReportBatchTest', CRON_EXP, new PerformanceYTDReportBatch());
        
        //DataBase.executeBatch(BatchApex1);
        //System.schedule('PerformanceMTDReportBatchTest', CRON_EXP, new PerformanceMTDReportBatch());
        
        PerformanceCRReportBatch BatchApex2 = new PerformanceCRReportBatch();  
        
        DataBase.executeBatch(BatchApex2);
        String jobId2 = System.schedule('PerformanceCRReportBatchTest', CRON_EXP, new PerformanceCRReportBatch());
        
        Test.stopTest(); 
    } 
    /*     static testMethod void PerformanceReportgetMTDResultDataTest() 
{
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
opp.Createddate = system.today().addDays(-5);
opp.Zone__c = stZone.Id;
opp.Signed_Contract_Date__c = system.today().addDays(-5);
insert opp;

// Create 2st Opportunity
Opportunity opp1 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
opp1.Account_Branch_Profile__c = abp.Id;
opp1.Status__c = 'First Call Close';
opp1.StageName = 'Closed Won';
opp1.Book_Date_PQM__c = system.today().addDays(-5);
opp1.Appointment_DateTime__c = system.today().addDays(-5);
opp1.Createddate = Date.today().toStartOfMonth().addDays(-120);
opp1.Zone__c = stZone.Id;
opp1.Signed_Contract_Date__c = system.today().addDays(-5);
insert opp1;
OppIds.add(opp1.Id);

// Create 3st Opportunity(90 days) 
Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
opp2.Account_Branch_Profile__c = abp.Id;
opp2.Status__c = 'First Call Close';
opp2.StageName = 'Closed Won';
opp2.Book_Date_PQM__c = system.today().addDays(-5);
opp2.Appointment_DateTime__c = system.today().addDays(-5);
opp2.Createddate = Date.today().addDays(-459);
opp2.Zone__c = stZone.Id;
opp2.Signed_Contract_Date__c = system.today().addDays(-5);
insert opp2;
OppIds.add(opp2.Id);

// Create 4st Opportunity(90 days)  
Opportunity opp3 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
opp3.Account_Branch_Profile__c = abp.Id; 
opp3.Status__c = 'First Call Close';
opp3.StageName = 'Closed Won';
opp3.Book_Date_PQM__c = system.today().addDays(-374);
opp3.Appointment_DateTime__c = system.today().addDays(-5);
opp3.Createddate = Date.today().addDays(-364);
opp3.Zone__c = stZone.Id;
opp3.Total_Price_Quote__c = 100;
opp3.Total_BAC_Price_Quote__c = 50;
opp3.Signed_Contract_Date__c = system.today().addDays(-365);
insert opp3;
OppIds.add(opp3.Id);

// Create 5st Opportunity 
Opportunity opp4 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
opp4.Account_Branch_Profile__c = abp.Id;
opp4.Status__c = 'First Call Close';
opp4.StageName = 'Closed Won';
opp4.Book_Date_PQM__c = system.today().addDays(-5);
opp4.Appointment_DateTime__c = system.today().addDays(-5);
opp4.Createddate = Date.today().addDays(-366);
opp4.Zone__c = stZone.Id;
opp4.Signed_Contract_Date__c = system.today().addDays(-305);
insert opp4;
OppIds.add(opp4.Id);

//create Quote
Quote qt = TestUtil.createQuote(opp.Id, false);
qt.Signed_Contract_Date__c = Date.today().toStartOfMonth().addDays(-20); //system.today().addDays(-5);
qt.BookDate__c =  Date.today().toStartOfMonth().addDays(-20); 
insert qt;

//create Quote
Quote qt1 = TestUtil.createQuote(opp.Id, false);
qt1.Signed_Contract_Date__c = Date.today().toStartOfMonth().addDays(20);
qt1.BookDate__c = Date.today().toStartOfMonth().addDays(20); 
insert qt1;

List<Id> UserIds = new List<Id>();
UserIds.add(usr.Id);

PerformanceReportBatchHandler.getResultData(OppIds);
PerformanceReportBatchHandler.getMTDResultData(OppIds);
PerformanceReportBatchHandler.getCoachingReportResultData(OppIds);

Set<decimal> listResult = new Set<decimal>();
listResult.add(4);
PerformanceReportBatchHandler.sorting(true, listResult);
}*/
}