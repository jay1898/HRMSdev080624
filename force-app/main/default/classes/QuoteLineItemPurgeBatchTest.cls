@isTest
private class QuoteLineItemPurgeBatchTest{
    static testMethod void testMethod1(){
        // Create Account
        Account ac = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        /*Opportunity oppt = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
oppt.Appointment_DateTime__c = DateTime.now();
oppt.Status__c = 'New';
oppt.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Replacement').getRecordTypeId();
OpportunityTriggerHandler.RUN_TRIGGER= false;
oppt.Is_Created_Using_PCC__c = true;
insert oppt;*/
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac.Id;
        aa.Opportunity__c = opp.Id;
        insert aa;
         Id pricebookId = Test.getStandardPricebookId();
      
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        q.Pricebook2Id=pricebookId;
        insert q ; 
        
        q.Forecasted__c = false ;
        q.Total_BAC_Price__c = 10 ;
        q.Signed_Contract_Date__c=Date.today(); 
        q.Status='Canceled';    
        update q ;
        Product2 p=new Product2(name='Quote#121Products',IsActive = true,Quote_Number_PQM__c='12');
        insert p;
         PricebookEntry PB=new PricebookEntry(Pricebook2Id = pricebookId,UnitPrice=1,IsActive=true,Product2Id = p.Id,Quote_Number_PQM__c='12');
        insert PB;
        QuoteLineItem QL = new QuoteLineItem();
        QL.Product_Type__c = 'test';
        QL.Quantity =1;
        QL.UnitPrice =100;
        QL.QuoteId=q.Id;
        QL.Product2Id=p.Id;
        QL.PricebookEntryId= PB.Id;
        QL.QLI_Type__c='Aggregated';
        insert QL;
        system.debug('@@@@'+[SELECT ID FROM Quotelineitem Where Quote.Status in ('Canceled','Cancelled','Active') and Quote.Forecasted__c =false]);
        system.assert([select id from quotelineitem].size()==1 );
        QuoteLineItemPurgeBatch b = new QuoteLineItemPurgeBatch(); 
        database.executebatch(b,1);
        
        Test.stopTest();  
          system.debug('@@@@'+[SELECT ID FROM Quotelineitem Where Quote.Status in ('Canceled','Cancelled','Active') and Quote.Forecasted__c =false]);
       
        system.debug('@@'+[select id from quotelineitem].size());
        system.assert([select id from quotelineitem].size()==0 );
    }
}