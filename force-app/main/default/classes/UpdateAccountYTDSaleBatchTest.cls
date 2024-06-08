@isTest
public class UpdateAccountYTDSaleBatchTest {
    public TestMethod static void ClassTestMethod(){
        User u = TestUtil.createUser(true);
        
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.PY_Sales__c = 5;
        acc.PPY_Sales__c = 10;
        acc.YTD_Sales__c = 1; 
        acc.YTD_Associated_Sales__c = 50;
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
        qt.Customer_Extended_Price__c = 50;
        insert qt;
        
        Test.startTest();
        UpdateAccountYTDSaleBatch updateAccYTDSaleRec = New UpdateAccountYTDSaleBatch();
        Database.executeBatch(updateAccYTDSaleRec);
        Test.stopTest();
    }
}