public without sharing class QuoteLineItemPurgeBatch  implements Database.Batchable<sObject> ,Database.Stateful,Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ID FROM Quotelineitem Where Quote.Status in ('Canceled','Cancelled','Active') and Quote.Forecasted__c =false]);
    }
    
    public void execute(Database.BatchableContext BC, List<Quotelineitem> listPQMQuote){
        database.delete(listPQMQuote);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}