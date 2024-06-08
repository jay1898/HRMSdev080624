public class DailyGuntonRetailOppsFeed  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    string oppData;
    string squery;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        oppData = '';
        if(Test.isRunningTest()){
            this.squery = 'SELECT  Id, Name,Owner.name, Account.name ,  Account.Type, Status__c,StageName,Createddate,CloseDate,Close_Comments__c,Branch__c ,zone__r.name, Appointment_DateTime__c,Appointment_Type__c,LeadSource,Virtual_Appointment__c,Response_Channel__c ,Campaign.name,  Total_Price_Quote__C, Quote_Date__c, Book_Date_PQM__c,Quote_Number_Shell__c, Probability,Legacy_Opportunity_Id__c FROM Opportunity where recordtype.name = \'Replacement\' and branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate LIMIT 1';
        }else{
            this.squery = 'SELECT  Id, Name,Owner.name, Account.name ,  Account.Type, Status__c,StageName,Createddate,CloseDate,Close_Comments__c,Branch__c ,zone__r.name, Appointment_DateTime__c,Appointment_Type__c,LeadSource,Virtual_Appointment__c,Response_Channel__c ,Campaign.name,  Total_Price_Quote__C, Quote_Date__c, Book_Date_PQM__c,Quote_Number_Shell__c, Probability,Legacy_Opportunity_Id__c FROM Opportunity where recordtype.name = \'Replacement\' and branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate';
        }
        return Database.getQueryLocator(squery);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity>scope){
        string finalOppstr='Opportunity ID,Opportunity Name, Opportunity Owner,Account Name, Account Type ,Status, Stage, Created Date,Closed Date,Close Comments,Branch,Zone, Appointment DateTime,Appointment Type,Appointment Source,Virtual Appointment,Response Channel, Campaign, Total Price Quote,Quote Date,Book Date(PQM),Quote Shell Number, Probability, Legacy Opportunity ID  \n';
        for(Opportunity objOpp : scope){
                                      finalOppstr = finalOppstr+'"'+(objOpp.Id!=null?String.valueOf(objOpp.Id).substring(0, 15):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Name!=null?String.valueOf(objOpp.Name):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Owner.name!=null?String.valueOf(objOpp.Owner.name):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Account.name!=null?String.valueOf(objOpp.Account.name):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Account.Type!=null?String.valueOf(objOpp.Account.Type):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Status__c!=null?String.valueOf(objOpp.Status__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.StageName!=null?String.valueOf(objOpp.StageName):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Createddate!=null?String.valueOf(objOpp.Createddate):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.CloseDate!=null?String.valueOf(objOpp.CloseDate):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Close_Comments__c!=null?String.valueOf(objOpp.Close_Comments__c):'')+ '"';  
                                      finalOppstr = finalOppstr +',"'+(objOpp.Branch__c!=null?String.valueOf(objOpp.Branch__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.zone__r.name!=null?String.valueOf(objOpp.zone__r.name):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Appointment_DateTime__c!=null?String.valueOf(objOpp.Appointment_DateTime__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Appointment_Type__c!=null?String.valueOf(objOpp.Appointment_Type__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.LeadSource!=null?String.valueOf(objOpp.LeadSource):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Virtual_Appointment__c!=null?String.valueOf(objOpp.Virtual_Appointment__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Response_Channel__c!=null?String.valueOf(objOpp.Response_Channel__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Campaign.name!=null?String.valueOf(objOpp.Campaign.name):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Total_Price_Quote__C!=null?String.valueOf(objOpp.Total_Price_Quote__C):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Quote_Date__c!=null?String.valueOf(objOpp.Quote_Date__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Book_Date_PQM__c!=null?String.valueOf(objOpp.Book_Date_PQM__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Quote_Number_Shell__c!=null?String.valueOf(objOpp.Quote_Number_Shell__c):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Probability!=null?String.valueOf(objOpp.Probability):'')+ '"';
                                      finalOppstr = finalOppstr +',"'+(objOpp.Legacy_Opportunity_Id__c!=null?String.valueOf(objOpp.Legacy_Opportunity_Id__c):'')+ '"\n';
                                  }   
        oppData+=finalOppstr;
    } 
    public void finish(Database.BatchableContext BC){
     String fileName = 'GuntonRetailOppData.csv'; 
        if(!test.isRunningTest())
            HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(oppData,fileName,'guntonExtract');
        else
            system.debug('@@');  
    }
    public void execute(SchedulableContext sc) {
       // DailyGuntonTCActivitesFeed b = new DailyGuntonTCActivitesFeed(); 
       // database.executebatch(b,200);
    }
}