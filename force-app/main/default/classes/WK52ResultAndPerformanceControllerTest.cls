@isTest
private class WK52ResultAndPerformanceControllerTest 
{
   /* static testMethod void WK52TestMethod() 
    {
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        // Create Branch
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.Account_Branch_Profile__c = abp.Id;
        opp.Status__c = 'Canceled';
        opp.StageName = 'Closed';
        opp.Book_Date_PQM__c = system.today().addDays(-5);
        opp.Appointment_DateTime__c = system.today().addDays(-5);
        opp.Createddate = system.today().addDays(-5);
        insert opp;
        
        // Create 2st Opportunity
        Opportunity opp1 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp1.Account_Branch_Profile__c = abp.Id;
        opp1.Status__c = 'First Call Close';
        opp1.StageName = 'Closed Won';
        opp1.Book_Date_PQM__c = system.today().addDays(-5);
        opp1.Appointment_DateTime__c = system.today().addDays(-5);
        opp1.Createddate = Date.today().toStartOfMonth().addDays(-120);
        insert opp1;
        
        // Create 3st Opportunity(90 days) 
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp2.Account_Branch_Profile__c = abp.Id;
        opp2.Status__c = 'First Call Close';
        opp2.StageName = 'Closed Won';
        opp2.Book_Date_PQM__c = system.today().addDays(-5);
        opp2.Appointment_DateTime__c = system.today().addDays(-5);
        opp2.Createddate = Date.today().addDays(-459);
        insert opp2;
        
        // Create 4st Opportunity(90 days) 
        Opportunity opp3 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp3.Account_Branch_Profile__c = abp.Id;
        opp3.Status__c = 'First Call Close';
        opp3.StageName = 'Closed Won';
        opp3.Book_Date_PQM__c = system.today().addDays(-5);
        opp3.Appointment_DateTime__c = system.today().addDays(-5);
        opp3.Createddate = Date.today().addDays(-364);
        insert opp3;
        
        // Create 5st Opportunity 
        Opportunity opp4 = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp4.Account_Branch_Profile__c = abp.Id;
        opp4.Status__c = 'First Call Close';
        opp4.StageName = 'Closed Won';
        opp4.Book_Date_PQM__c = system.today().addDays(-5);
        opp4.Appointment_DateTime__c = system.today().addDays(-5);
        opp4.Createddate = Date.today().addDays(-60);
        insert opp4;
        
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
        
        WK52ResultAndPerformanceController.getResult();
        WK52ResultAndPerformanceController.getMTDResult();
        WK52ResultAndPerformanceController.getCoachingReportResult();
        
        WK52ResultAndPerformanceControllerVF.getResultData();
        Set<decimal> listResult = new Set<decimal>();
        listResult.add(4);
        WK52ResultAndPerformanceControllerVF.sorting(true, listResult);
        
        WK52ResultAndPerformanceMTDVFController.getResultData();
        WK52ResultAndPerformanceMTDVFController.sorting(true, listResult);      
        List<opportunity> listOpp=new List<Opportunity>();
        listOpp.add(opp);
        listOpp.add(opp1);
        listOpp.add(opp2);
        listOpp.add(opp3);
        listOpp.add(opp4);
       
    } */
}