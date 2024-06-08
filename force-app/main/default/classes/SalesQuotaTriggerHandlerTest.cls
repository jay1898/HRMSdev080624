@isTest
public with sharing class SalesQuotaTriggerHandlerTest {
    public static testMethod void populateAssociatedQuotesForQuotaTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);
       
        Opportunity opportunityOne = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, true); 
       
        Quote quoteOne = TestUtil.createQuote(opportunityOne.Id, false);
        quoteOne.Status = 'Booked';
        quoteOne.BookDate__c = date.newInstance(System.today().year(), 5, 14);
        quoteOne.Quote_Number_PQM__c = '123456';
        insert quoteOne;

        Opportunity opportunityTwo = TestUtil.createOpportunity('New Test Opp Two', ac.Id, user.Id, false);
        opportunityTwo.CloseDate = date.newInstance(System.today().year(), 5, 25);
        insert opportunityTwo;
        
        Quote quoteTwo = TestUtil.createQuote(opportunityTwo.Id, false);
        quoteTwo.Quote_Number_PQM__c = '654321';
        insert quoteTwo;
        
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuota = new Sales_Quota__c(
            Month__c = 'May',
            Quota_Amount__c = 50000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 5, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 5, 31)
        );
        SalesQuotaTriggerHandler.RUN_TRIGGER = false;
        insert salesQuota;
        
        Map<Id, Sales_Quota__c> oldMap = new Map<Id, Sales_Quota__c>();
        oldMap.put(salesQuota.Id, salesQuota);
        
        List<Sales_Quota__c> quotaList = new List<Sales_Quota__c>(); 
        quotaList.add(salesQuota);

        Test.startTest();
        SalesQuotaTriggerHandler.populateAssociatedQuotesForQuota(quotaList, oldMap);
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Quote__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quoteOne.Id OR Quote__r.Id =: QuoteTwo.Id
        ];

        System.assertEquals(2, results.size());
    }
    
     public static testMethod void populateAssociatedQuotesForQuotaNoAvailableQuotesTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);
       
        Opportunity opportunityOne = TestUtil.createOpportunity('New Test 2 Opp One', ac.Id, user.Id, true); 
       
        Quote quoteOne = TestUtil.createQuote(opportunityOne.Id, false);
        quoteOne.Status = 'Booked';
        quoteOne.BookDate__c = date.newInstance(System.today().year(), 8, 14);
        insert quoteOne;

        Opportunity opportunityTwo = TestUtil.createOpportunity('New Test 2 Opp Two', ac.Id, user.Id, false);
        opportunityTwo.CloseDate = date.newInstance(System.today().year(), 8, 25);
        insert opportunityTwo;
        
        Quote quoteTwo = TestUtil.createQuote(opportunityTwo.Id, false);
        insert quoteTwo;
        
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuota = new Sales_Quota__c(
            Month__c = 'May',
            Quota_Amount__c = 50000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 5, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 5, 31)
        );
        SalesQuotaTriggerHandler.RUN_TRIGGER = false;
        insert salesQuota;
        
        Map<Id, Sales_Quota__c> oldMap = new Map<Id, Sales_Quota__c>();
        oldMap.put(salesQuota.Id, salesQuota);
        
        List<Sales_Quota__c> quotaList = new List<Sales_Quota__c>(); 
        quotaList.add(salesQuota);

        Test.startTest();
        SalesQuotaTriggerHandler.populateAssociatedQuotesForQuota(quotaList, oldMap);
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Quote__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quoteOne.Id OR Quote__r.Id =: QuoteTwo.Id
        ];

        System.assertEquals(0, results.size());
    }    
}