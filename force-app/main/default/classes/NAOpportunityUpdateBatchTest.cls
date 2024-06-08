@isTest
public class NAOpportunityUpdateBatchTest {
    static testMethod void testMethod3(){
        // Create Account
        Account ac2 = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        insert opp2;
        
        
       
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Contracted';
        insert q ;
        
       
        Test.startTest();
        NAOpportunityUpdateBatch b = new NAOpportunityUpdateBatch(); 
        database.executebatch(b,10);
        Test.stopTest();
    }
    static testMethod void testMethod2(){
        // Create Account
        Account ac2 = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        insert opp2;
        
        
       
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Ordered';
        insert q ;
        
       
        Test.startTest();
        NAOpportunityUpdateBatch b = new NAOpportunityUpdateBatch(); 
        database.executebatch(b,10);
        Test.stopTest();
    }
    static testMethod void testMethod1(){
        // Create Account
        Account ac2 = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        insert opp2;
        
        
       
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Ordered'; 
        q.Ship_Complete_Date__c=Date.today();
        q.Signed_Contract_Date__c=Date.today();
        q.BookDate__c=Date.today();
        q.Total_Invoice_Price__c=100;
        q.Total_BAC_Price__c=100;
        q.Customer_Extended_Price__c=100;
        insert q ;
        
       
        Test.startTest();
        NAOpportunityUpdateBatch b = new NAOpportunityUpdateBatch(); 
        database.executebatch(b,10);
        Test.stopTest();
    }
}