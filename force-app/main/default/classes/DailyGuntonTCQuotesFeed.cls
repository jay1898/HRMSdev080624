public class DailyGuntonTCQuotesFeed  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    string quoteData;
    string squery; 
    public Database.QueryLocator start(Database.BatchableContext BC){
        quoteData = '';
        if(Test.isRunningTest()){
            this.squery = 'SELECT ID, name, Owner.name,opportunity.owner.EBS_UserName__c ,opportunity.owner.Trade_Branch_Number__c,Status,CreatedDate, Opportunityid, Opportunity.name, Opportunity_Stage__c,BookDate__c,Customer_Extended_Price__c,Earliest_LRD_Date__c,Forecasted__c, Opp_Total_Price__c,PO_Number__c,PQM_Link_Date__c,PQM_List_Price__c,PQM_Quote_Date__c,Quantity__c,QuoteNumber,Quote_Number_PQM__c,Signed_Contract_Date__c,TotalPrice,Total_BAC_Price__c,Total_Invoice_Price__c FROM Quote where opportunity.type in (\'Trade\', \'Commercial\') and opportunity.branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate LIMIT 1';
        }else{
            this.squery = 'SELECT ID, name, Owner.name,opportunity.owner.EBS_UserName__c ,opportunity.owner.Trade_Branch_Number__c,Status,CreatedDate, Opportunityid, Opportunity.name, Opportunity_Stage__c,BookDate__c,Customer_Extended_Price__c,Earliest_LRD_Date__c,Forecasted__c, Opp_Total_Price__c,PO_Number__c,PQM_Link_Date__c,PQM_List_Price__c,PQM_Quote_Date__c,Quantity__c,QuoteNumber,Quote_Number_PQM__c,Signed_Contract_Date__c,TotalPrice,Total_BAC_Price__c,Total_Invoice_Price__c FROM Quote where opportunity.type in (\'Trade\', \'Commercial\') and opportunity.branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate';
        }
        return Database.getQueryLocator(squery);
    }
    
    public void execute(Database.BatchableContext BC, List<Quote>scope){
        string finalQuotestr='Quote ID, Name, Owner, EBS User Name, Primary Branch Number,Quote Status, Created Date, Opportunity ID, Opportunity Name, Opportunity Stage, Book Date,  Customer Extended Price, Earliest LRD Date, Forecasted, Opportunity Total Proce, PO Number, PQM Link Date, PQM List Price, PQM Quote Date, Quantity, Quote Number, Quote Number PQM, Signed Contract Date, Total Price, Total BAC Price, Total Invoice Price \n';
        for(Quote quote : scope){
            finalQuotestr = finalQuotestr+'"'+(quote.Id!=null?String.valueOf(quote.Id).substring(0, 15):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Name!=null?String.valueOf(quote.Name):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Owner.name!=null?String.valueOf(quote.Owner.name):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.opportunity.owner.EBS_UserName__c!=null?String.valueOf(quote.opportunity.owner.EBS_UserName__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.opportunity.owner.Trade_Branch_Number__c !=null?String.valueOf(quote.opportunity.owner.Trade_Branch_Number__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.status!=null?String.valueOf(quote.status):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Createddate!=null?String.valueOf(quote.Createddate):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Opportunityid!=null?String.valueOf(quote.Opportunityid).substring(0, 15):'')+ '"'; 
            finalQuotestr = finalQuotestr +',"'+(quote.Opportunity.name!=null?String.valueOf(quote.Opportunity.name):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Opportunity_Stage__c!=null?String.valueOf(quote.Opportunity_Stage__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.BookDate__c!=null?String.valueOf(quote.BookDate__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Customer_Extended_Price__c!=null?String.valueOf(quote.Customer_Extended_Price__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Earliest_LRD_Date__c!=null?String.valueOf(quote.Earliest_LRD_Date__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Forecasted__c!=null?String.valueOf(quote.Forecasted__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Opp_Total_Price__c!=null?String.valueOf(quote.Opp_Total_Price__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.PO_Number__c!=null?String.valueOf(quote.PO_Number__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.PQM_Link_Date__c!=null?String.valueOf(quote.PQM_Link_Date__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.PQM_List_Price__c!=null?String.valueOf(quote.PQM_List_Price__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.PQM_Quote_Date__c!=null?String.valueOf(quote.PQM_Quote_Date__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Quantity__c!=null?String.valueOf(quote.Quantity__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.QuoteNumber!=null?String.valueOf(quote.QuoteNumber):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Quote_Number_PQM__c!=null?String.valueOf(quote.Quote_Number_PQM__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Signed_Contract_Date__c!=null?String.valueOf(quote.Signed_Contract_Date__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.TotalPrice!=null?String.valueOf(quote.TotalPrice):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Total_BAC_Price__c!=null?String.valueOf(quote.Total_BAC_Price__c):'')+ '"';
            finalQuotestr = finalQuotestr +',"'+(quote.Total_Invoice_Price__c!=null?String.valueOf(quote.Total_Invoice_Price__c):'')+ '"\n';
            
        }   
        quoteData+=finalQuotestr;    
    } 
    public void finish(Database.BatchableContext BC){
        String fileName = 'GuntonTCQuotesData.csv'; 
        if(!test.isRunningTest())
            HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(quoteData,fileName,'guntonExtract');
        else
            system.debug('@@');     
    }
    public void execute(SchedulableContext sc) {
        
    }
}