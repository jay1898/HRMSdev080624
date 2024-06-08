public with sharing class SalesQuotaTriggerHandler {
    public static Boolean RUN_TRIGGER = true ;
    
    public static void populateAssociatedQuotesForQuota (List<Sales_Quota__c> quotas, Map<Id, Sales_Quota__c> oldMap) {
        for (Sales_Quota__c quota : quotas) {
            Sales_Plan__c salesPlan = [SELECT Id, Owner.Id FROM Sales_Plan__c WHERE Id =: quota.Sales_Plan__c];
            List<Quote> quotesInQuotaPeriod = [
                SELECT  id, Name, TotalPrice, BookDate__c, Opportunity.Name, Opportunity.CloseDate, Quote_Number_PQM__c 
                FROM    Quote
                WHERE   Opportunity.OwnerId =: salesPlan.OwnerId
                AND     (((Status = 'Ordered' OR Status = 'Booked')
                AND     BookDate__c >: quota.Quota_Period_Start_Date__c
                AND     BookDate__c <: quota.Quota_Period_End_Date__c)
                OR      (Status != 'Ordered' AND Status != 'Booked'
                AND     Opportunity.CloseDate > :quota.Quota_Period_Start_Date__c
                AND     Opportunity.CloseDate < :quota.Quota_Period_End_Date__c))
            ];
            List<Sales_Quota_Associated_Quote__c> associatedQuotes = new List<Sales_Quota_Associated_Quote__c> ();

            for (Quote quote : quotesInQuotaPeriod) {
                Sales_Quota_Associated_Quote__c newAssociatedQuote = new Sales_Quota_Associated_Quote__c(
                    Name = 'Associated Quote #' + quote.Quote_Number_PQM__c,
                    Sales_Quota__c = quota.Id,
                    Quote__c = quote.Id
                );

                associatedQuotes.add(newAssociatedQuote);
            }
            
            if (associatedQuotes.size() > 0) {
            	insert associatedQuotes;    
            }
        }
    }
}