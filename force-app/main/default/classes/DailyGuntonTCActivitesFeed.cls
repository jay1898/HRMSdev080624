public class DailyGuntonTCActivitesFeed  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    string eventsData;
    string squery;
    public Database.QueryLocator start(Database.BatchableContext BC){
        eventsData = '';
        if(Test.isRunningTest()){
            this.squery = 'SELECT Id, Owner.name,account__C,Opportunity_Full_Details__c, StartDateTime, EndDateTime, Subject,Location, CreatedDate,Type, Manager_Coaching__c, Legacy_Event_Id__c FROM Event where recordtype.name = \'Trade_Comm Event\' and (( account.branch__r.name IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' )) OR ( Opportunity_Full_Details__r.branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ))) and LastModifiedDate = LAST_N_DAYS:7 order by createddate LIMIT 1';
        }else{
            this.squery = 'SELECT Id, Owner.name,account__C,Opportunity_Full_Details__c, StartDateTime, EndDateTime, Subject,Location, CreatedDate,Type, Manager_Coaching__c, Legacy_Event_Id__c FROM Event where recordtype.name = \'Trade_Comm Event\' and (( account.branch__r.name IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' )) OR ( Opportunity_Full_Details__r.branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ))) and LastModifiedDate = LAST_N_DAYS:7 order by createddate ';
        }
        return Database.getQueryLocator(squery);
    }
    
    public void execute(Database.BatchableContext BC, List<Event>scope){  
        string finalEventstr=' ID,Owner,Account ID, Opportunity ID, Start Date Time, End Date Time, Subject, Location, Created Date, Event Type, Showas, Manager Coaching,Legacy Event ID  \n';
        for(Event objEve : scope){
            finalEventstr = finalEventstr+'"'+(objEve.Id!=null?String.valueOf(objEve.Id).substring(0, 15):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Owner.name!=null?String.valueOf(objEve.Owner.name):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.account__C!=null?String.valueOf(objEve.account__C).substring(0, 15):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Opportunity_Full_Details__c!=null?String.valueOf(objEve.Opportunity_Full_Details__c).substring(0, 15):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.StartDateTime!=null?String.valueOf(objEve.StartDateTime):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.EndDateTime!=null?String.valueOf(objEve.EndDateTime):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Subject!=null?String.valueOf(objEve.Subject):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Location!=null?String.valueOf(objEve.Location):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Createddate!=null?String.valueOf(objEve.Createddate):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Type!=null?String.valueOf(objEve.Type):'')+ '"';  
            finalEventstr = finalEventstr +',"'+(objEve.Manager_Coaching__c!=null?String.valueOf(objEve.Manager_Coaching__c):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Legacy_Event_Id__c!=null?String.valueOf(objEve.Legacy_Event_Id__c):'')+ '"\n';
        }   
        eventsData+=finalEventstr;
    } 
    public void finish(Database.BatchableContext BC){
        String fileName = 'GuntonTCEventsData.csv'; 
        if(!test.isRunningTest())
            HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(eventsData,fileName,'guntonExtract');
        else
            system.debug('@@');  
    }
    public void execute(SchedulableContext sc) {
        // DailyGuntonTCQuotesFeed b = new DailyGuntonTCQuotesFeed(); 
        //  database.executebatch(b,500);
    }
}