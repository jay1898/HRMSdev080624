public class DailyGuntonTCAccountsFeed  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
   
    string accountData;
    string squery;
    public Database.QueryLocator start(Database.BatchableContext BC){
        accountData = '';
        if(Test.isRunningTest()){
            this.squery = 'SELECT ID, name, owner.name,owner.EBS_UserName__c ,owner.Trade_Branch_Number__c,Oracle_Account_Number__c,Account_Rank__c,Account_State__c,Branch__r.name,createddate,Type,Phone,Potential_Sales__c,PPY_Account_Rank__c,PPY_Account_Status__c,PPY_Sales__c,Prior_Year__c,PY_Account_Rank__c,PY_Account_Status__c,PY_Associated_Sales__c,PY_Sales__c,YTD_Sales__c,YTD_Associated_Sales__c,YTD_CEUs__c,YTD_Meetings__c,YTD_Phone_Calls__c,YTD_Tasks__c,PCC_ID__c,Contractor_Program_Level__c FROM Account where recordtype.name = \'Branch Account\' and branch__r.name IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate LIMIT 1';
        }else{
            this.squery = 'SELECT ID, name, owner.name,owner.EBS_UserName__c ,owner.Trade_Branch_Number__c,Oracle_Account_Number__c,Account_Rank__c,Account_State__c,Branch__r.name,createddate,Type,Phone,Potential_Sales__c,PPY_Account_Rank__c,PPY_Account_Status__c,PPY_Sales__c,Prior_Year__c,PY_Account_Rank__c,PY_Account_Status__c,PY_Associated_Sales__c,PY_Sales__c,YTD_Sales__c,YTD_Associated_Sales__c,YTD_CEUs__c,YTD_Meetings__c,YTD_Phone_Calls__c,YTD_Tasks__c,PCC_ID__c,Contractor_Program_Level__c FROM Account where recordtype.name = \'Branch Account\' and branch__r.name IN ( \'Cleveland\' , \'Columbus\', \'Harrisburg\', \'Philadelphia\', \'Pittsburgh\' ) and LastModifiedDate = LAST_N_DAYS:7 order by createddate';
        }
        return Database.getQueryLocator(squery);
    }
    
    public void execute(Database.BatchableContext BC, List<Account>scope){
        string finalAccountstr='Account ID,Account Name,Account Owner, EBS User Name, Primary Branch Number,Account Number, Account Rank,Account Status,Branch, Created Date,Type,Phone,Potential Sales,PPY Account Rank, PPY Account Status, PPY Sales, Prior Year,  PY Account Rank, PY Account Status, PY Associated Sales, PY Sales, YTD Sales, YTD Associated Sales, YTD CEUs, YTD Meetings, YTD Phone Calls, YTD Tasks, PCC ID, Contractor Program Level \n';
        for(Account account : scope){
                                   finalAccountstr = finalAccountstr+'"'+(account.Id!=null?String.valueOf(account.Id).substring(0, 15):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Name!=null?String.valueOf(account.Name):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Owner.name!=null?String.valueOf(account.Owner.name):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.owner.EBS_UserName__c!=null?String.valueOf(account.owner.EBS_UserName__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.owner.Trade_Branch_Number__c !=null?String.valueOf(account.owner.Trade_Branch_Number__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Oracle_Account_Number__c!=null?String.valueOf(account.Oracle_Account_Number__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Account_Rank__c!=null?String.valueOf(account.Account_Rank__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Account_State__c!=null?String.valueOf(account.Account_State__c):'')+ '"'; 
                                   finalAccountstr = finalAccountstr +',"'+(account.Branch__r.name!=null?String.valueOf(account.Branch__r.name):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Createddate!=null?String.valueOf(account.Createddate):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Type!=null?String.valueOf(account.Type):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Phone!=null?String.valueOf(account.Phone):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Potential_Sales__c!=null?String.valueOf(account.Potential_Sales__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PPY_Account_Rank__c!=null?String.valueOf(account.PPY_Account_Rank__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PPY_Account_Status__c!=null?String.valueOf(account.PPY_Account_Status__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PPY_Sales__c!=null?String.valueOf(account.PPY_Sales__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.Prior_Year__c!=null?String.valueOf(account.Prior_Year__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PY_Account_Rank__c!=null?String.valueOf(account.PY_Account_Rank__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PY_Account_Status__c!=null?String.valueOf(account.PY_Account_Status__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PY_Associated_Sales__c!=null?String.valueOf(account.PY_Associated_Sales__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PY_Sales__c!=null?String.valueOf(account.PY_Sales__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.YTD_Sales__c!=null?String.valueOf(account.YTD_Sales__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.YTD_Associated_Sales__c!=null?String.valueOf(account.YTD_Associated_Sales__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.YTD_CEUs__c!=null?String.valueOf(account.YTD_CEUs__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.YTD_Meetings__c!=null?String.valueOf(account.YTD_Meetings__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.YTD_Phone_Calls__c!=null?String.valueOf(account.YTD_Phone_Calls__c):'')+ '"';  
                                   finalAccountstr = finalAccountstr +',"'+(account.YTD_Tasks__c!=null?String.valueOf(account.YTD_Tasks__c):'')+ '"';
                                   finalAccountstr = finalAccountstr +',"'+(account.PCC_ID__c!=null?String.valueOf(account.PCC_ID__c):'')+ '"';  
                                   finalAccountstr = finalAccountstr +',"'+(account.Contractor_Program_Level__c!=null?String.valueOf(account.Contractor_Program_Level__c):'')+ '"\n';
                                   
                               }   
        accountData+=finalAccountstr;
        
        
    } 
    public void finish(Database.BatchableContext BC){
     String fileName = 'GuntonTCAccountsData.csv'; 
        if(!test.isRunningTest())
            HTTPResponse response=ServiceTerritoryExportBatchHandler.uploadFile(accountData,fileName,'guntonExtract');
        else
            system.debug('@@');  
    }
    public void execute(SchedulableContext sc) {
       // DailyGuntonTCOppsFeed b = new DailyGuntonTCOppsFeed(); 
        //database.executebatch(b,500);
    }
}