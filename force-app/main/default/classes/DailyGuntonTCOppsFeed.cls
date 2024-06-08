public class DailyGuntonTCOppsFeed  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    string oppData;
    string squery;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        oppData = '';
        if(Test.isRunningTest()){
            this.squery = 'SELECT  Id,Owner.name,owner.EBS_UserName__c ,owner.Trade_Branch_Number__c, Name,Account.ID, Account.name,BusinessSegment__c, Status__c,Market_Segment__c,Createddate,CloseDate,Close_Comments__c,StageName, Type,Branch__c ,Total_Price_Quote__C, Quote_Date__c, Book_Date_PQM__c,Quote_Number_Shell__c, Probability,Legacy_Opportunity_CRM_Id__c FROM Opportunity where type in (\'Trade\', \'Commercial\') and branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate LIMIT 1';
        }else{
            this.squery = 'SELECT  Id,Owner.name,owner.EBS_UserName__c ,owner.Trade_Branch_Number__c, Name,Account.ID, Account.name,BusinessSegment__c, Status__c,Market_Segment__c,Createddate,CloseDate,Close_Comments__c,StageName, Type,Branch__c ,Total_Price_Quote__C, Quote_Date__c, Book_Date_PQM__c,Quote_Number_Shell__c, Probability,Legacy_Opportunity_CRM_Id__c FROM Opportunity where type in (\'Trade\', \'Commercial\') and branch__C IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate';   
        }
        return Database.getQueryLocator(squery);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity>scope){
        string finalOppstr='Opportunity ID,Opportunity Owner,EBS User Name, Primary Branch Number,Opportunity Name,Account ID, Account Name,Business Segment,Status, Market Segment, Created Date,Closed Date,Close Comments,Opportunity Stage,Type,Branch,Total Price Quote,Quote Date,Book Date(PQM),Quote Shell Number, Probability, Legacy Opportunity CRM ID  \n';
        for(Opportunity objOpp : scope){
            finalOppstr = finalOppstr+'"'+(objOpp.Id!=null?String.valueOf(objOpp.Id).substring(0, 15):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Owner.name!=null?String.valueOf(objOpp.Owner.name):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.owner.EBS_UserName__c!=null?String.valueOf(objOpp.owner.EBS_UserName__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.owner.Trade_Branch_Number__c !=null?String.valueOf(objOpp.owner.Trade_Branch_Number__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Name!=null?String.valueOf(objOpp.Name):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Account.ID!=null?String.valueOf(objOpp.Account.Id).substring(0, 15):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Account.name!=null?String.valueOf(objOpp.Account.name):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.BusinessSegment__c!=null?String.valueOf(objOpp.BusinessSegment__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Status__c!=null?String.valueOf(objOpp.Status__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Market_Segment__c!=null?String.valueOf(objOpp.Market_Segment__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Createddate!=null?String.valueOf(objOpp.Createddate):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.CloseDate!=null?String.valueOf(objOpp.CloseDate):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Close_Comments__c!=null?String.valueOf(objOpp.Close_Comments__c):'')+ '"';  
            finalOppstr = finalOppstr +',"'+(objOpp.StageName!=null?String.valueOf(objOpp.StageName):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Type!=null?String.valueOf(objOpp.Type):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Branch__c!=null?String.valueOf(objOpp.Branch__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Total_Price_Quote__C!=null?String.valueOf(objOpp.Total_Price_Quote__C):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Quote_Date__c!=null?String.valueOf(objOpp.Quote_Date__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Book_Date_PQM__c!=null?String.valueOf(objOpp.Book_Date_PQM__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Quote_Number_Shell__c!=null?String.valueOf(objOpp.Quote_Number_Shell__c):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Probability!=null?String.valueOf(objOpp.Probability):'')+ '"';
            finalOppstr = finalOppstr +',"'+(objOpp.Legacy_Opportunity_CRM_Id__c!=null?String.valueOf(objOpp.Legacy_Opportunity_CRM_Id__c):'')+ '"\n';
        }   
        oppData+=finalOppstr;
    } 
    public void finish(Database.BatchableContext BC){
        String fileName = 'GuntonTCOppData.csv'; 
        if(!test.isRunningTest())
            HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(oppData,fileName,'guntonExtract');
        else
            system.debug('@@');  
      
        /*Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName(fileName);
attachment.setBody(Blob.valueOf(oppData));
Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
message.setSubject('Gunton Trade & Commercial Files');
message.setPlainTextBody('The report is attached.');
message.setToAddresses( new String[] { 'adhamk@pella.com' } );
Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
*/
    }
    public void execute(SchedulableContext sc) {
        // DailyGuntonTCActivitesFeed b = new DailyGuntonTCActivitesFeed(); 
        // database.executebatch(b,200);
    }
}