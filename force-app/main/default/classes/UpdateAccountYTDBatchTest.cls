@isTest
public class UpdateAccountYTDBatchTest {
    public TestMethod static void ClassTestMethod(){
        User u = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now());
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.YTD_Phone_Calls__c = 5;
        acc.YTD_Meetings__c = 10;
        acc.YTD_CEUs__c = 1; 
        acc.YTD_Tasks__c = 50;
        acc.PY_Sales__c = 5;
        acc.PPY_Sales__c = 10;
        acc.YTD_Sales__c = 10; 
        acc.YTD_Associated_Sales__c = 50;
        acc.PY_Account_status__C='Customer';
        insert acc;
        
        acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.YTD_Phone_Calls__c = 5;
        acc.YTD_Meetings__c = 10;
        acc.YTD_CEUs__c = 1; 
        acc.YTD_Tasks__c = 50;
        acc.PY_Sales__c = 555;
        acc.PPY_Sales__c = 10;
        acc.YTD_Sales__c = 555; 
        acc.YTD_Associated_Sales__c = 50;
        acc.PY_Account_status__C='Customer';
        insert acc;
        
        Opportunity opp = TestUtil.createOpportunity('Test Opportunity', acc.Id, u.Id , false);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        opp.Status__c = 'Open';
        insert opp;
        
        Associated_Account__c assocAcc = new Associated_Account__c();
        assocAcc.Associated_Account_Name__c = acc.Id;
        assocAcc.Opportunity__c = opp.Id;
        insert assocAcc;
        
        Quote qt = TestUtil.createQuote(opp.Id, false);
        qt.BookDate__c = System.today();
        qt.status='Booked';
        qt.Customer_Extended_Price__c = 50;
        insert qt;
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
         Test.startTest();
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        
       
        UpdateAccountYTDBatch b = New UpdateAccountYTDBatch();
        Database.executeBatch(b);
        Test.stopTest();
    }
    public TestMethod static void updateAccountStatus(){
        User u = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now());
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.YTD_Phone_Calls__c = 5;
        acc.YTD_Meetings__c = 10;
        acc.YTD_CEUs__c = 1; 
        acc.YTD_Tasks__c = 50;
        acc.PY_Sales__c = 5;
        acc.PPY_Sales__c = 10;
        acc.YTD_Sales__c = 10; 
        acc.YTD_Associated_Sales__c = 50;
        acc.PY_Account_status__C='Customer';
        insert acc;
        
        acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.YTD_Phone_Calls__c = 5;
        acc.YTD_Meetings__c = 10;
        acc.YTD_CEUs__c = 1; 
        acc.YTD_Tasks__c = 50;
        acc.PY_Sales__c = 555;
        acc.PPY_Sales__c = 10;
        acc.YTD_Sales__c = 555; 
        acc.YTD_Associated_Sales__c = 50;
        acc.PY_Account_status__C='Customer';
        insert acc;
        
        Opportunity opp = TestUtil.createOpportunity('Test Opportunity', acc.Id, u.Id , false);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        opp.Status__c = 'Open';
        insert opp;
        
        Associated_Account__c assocAcc = new Associated_Account__c();
        assocAcc.Associated_Account_Name__c = acc.Id;
        assocAcc.Opportunity__c = opp.Id;
        insert assocAcc;
        
        Quote qt = TestUtil.createQuote(opp.Id, false);
        qt.BookDate__c = System.today();
        qt.status='Booked';
        qt.Customer_Extended_Price__c = 50;
        insert qt;
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
         Test.startTest();
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        
       
        UpdateAccountYTDStatusBatch b1 = New UpdateAccountYTDStatusBatch();
        Database.executeBatch(b1);
        Test.stopTest();
    }
}