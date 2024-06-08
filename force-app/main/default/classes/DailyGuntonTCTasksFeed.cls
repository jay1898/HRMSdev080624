public class DailyGuntonTCTasksFeed  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    string tasksData;
    string squery;
    public Database.QueryLocator start(Database.BatchableContext BC){
        tasksData = '';
       if(Test.isRunningTest()){
            this.squery = 'SELECT Id, Owner.name,whatid, ActivityDate, Subject,Status, CreatedDate,Type, Manager_Coaching__c, Legacy_Event_Id__c FROM Task where account.recordtype.name = \'Branch Account\' and account.branch__r.name IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate LIMIT 1';
        }else{
            this.squery = 'SELECT Id, Owner.name,whatid, ActivityDate, Subject,Status, CreatedDate,Type, Manager_Coaching__c, Legacy_Event_Id__c FROM Task where account.recordtype.name = \'Branch Account\' and account.branch__r.name IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 and whatid in (select id from account) order by createddate';
        }
        return Database.getQueryLocator(squery);
    }
    
    public void execute(Database.BatchableContext BC, List<Task>scope){  
        string finalEventstr=' ID,Owner,Account ID, Due Date, Subject,Status, Created Date, Event Type, Manager Coaching,Legacy Event ID  \n';
        for(Task objEve : scope){
            finalEventstr = finalEventstr+'"'+(objEve.Id!=null?String.valueOf(objEve.Id).substring(0, 15):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Owner.name!=null?String.valueOf(objEve.Owner.name):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.whatid!=null?String.valueOf(objEve.whatId).substring(0, 15):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.ActivityDate!=null?String.valueOf(objEve.ActivityDate):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Subject!=null?String.valueOf(objEve.Subject):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Status !=null?String.valueOf(objEve.Status):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Createddate!=null?String.valueOf(objEve.Createddate):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Type!=null?String.valueOf(objEve.Type):'')+ '"';  
            finalEventstr = finalEventstr +',"'+(objEve.Manager_Coaching__c!=null?String.valueOf(objEve.Manager_Coaching__c):'')+ '"';
            finalEventstr = finalEventstr +',"'+(objEve.Legacy_Event_Id__c!=null?String.valueOf(objEve.Legacy_Event_Id__c):'')+ '"\n';
        }   
        tasksData+=finalEventstr;
    } 
    public void finish(Database.BatchableContext BC){
     String fileName = 'GuntonTCTasksData.csv'; 
        if(!test.isRunningTest())
            HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(tasksData,fileName,'guntonExtract');
        else
            system.debug('@@');    
    }
    public void execute(SchedulableContext sc) {
       // DailyGuntonTCQuotesFeed b = new DailyGuntonTCQuotesFeed(); 
     //  database.executebatch(b,500);
    }
}