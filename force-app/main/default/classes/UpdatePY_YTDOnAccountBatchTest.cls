@isTest
public class UpdatePY_YTDOnAccountBatchTest {
    public static testMethod void testMethod1(){
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.PY_Sales__c = 5;
        acc.PPY_Sales__c = 10;
        acc.YTD_Sales__c = 1; 
        insert acc;
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', acc.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        insert opp2;
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = acc.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        
         
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.valueOf(Label.UpdateYTDFiscalYearDate);
        q.Status='Active';
        insert q ;
        
        Test.startTest();       
        UpdatePY_YTDOnAccountBatch updateAccYTDField = new UpdatePY_YTDOnAccountBatch();
        Database.executeBatch(updateAccYTDField);
        
        Test.stopTest();
    }
}