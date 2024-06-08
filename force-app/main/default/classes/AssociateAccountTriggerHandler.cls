public class AssociateAccountTriggerHandler {
    //UpdateAccountYTDSaleBatchTest test class
    public static void setNameField(List<Associated_Account__c> listAssociateAcc, Map<Id, Associated_Account__c> oldMap){
        Integer lastAutoNumber=0;
        List<Associated_Account__c> lastAssociateAccount=[SELECT ID,Auto_Number__c  from Associated_Account__c order by createddate desc Limit 1];
        if(lastAssociateAccount.size()>0){
            lastAutoNumber=Integer.valueOf(lastAssociateAccount[0].Auto_Number__c )+1;
        }
        List<Id> listEndCustomerIds=new List<Id>();
        for(Associated_Account__c AA : listAssociateAcc){
            if(oldMap==null){
                AA.Name='A-'+String.valueOf(lastAutoNumber).leftPad(4, '0');
                lastAutoNumber++;
            }
            if(AA.Associated_Account_Name__c != null && AA.End_Customer_Account__c !=null && (oldMap==null || oldMap.get(AA.Id).End_Customer_Account__c != AA.End_Customer_Account__c)){
                listEndCustomerIds.add(AA.End_Customer_Account__c);
            }
        }
        if(listEndCustomerIds.size()>0){
            Map<Id,Account> mapIdWiseAccount=new Map<Id,Account>([SELECT Id,NAME FROM Account Where Id = :listEndCustomerIds]);
            for(Associated_Account__c AA : listAssociateAcc){
                if(AA.Associated_Account_Name__c != null && AA.End_Customer_Account__c !=null && (oldMap==null || oldMap.get(AA.Id).End_Customer_Account__c != AA.End_Customer_Account__c) && mapIdWiseAccount.containsKey(AA.End_Customer_Account__c)){
                    AA.Name=mapIdWiseAccount.get(AA.End_Customer_Account__c).Name;
                }
            }
        }
        
    }
    
    public static void updateYTDonAccount(List<Associated_Account__c> listAssociateAcc, Map<Id, Associated_Account__c> oldMap){
        //get the current fiscal year details
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        
        Set<String> associateAccId = new Set<String>();
        Set<String> associateOppId = new Set<String>();
        for(Associated_Account__c AA : listAssociateAcc){
            if(AA.Associated_Account_Name__c != null && (oldMap == null || oldMap.get(AA.Id).Associated_Account_Name__c != AA.Associated_Account_Name__c || oldMap.get(AA.Id).Opportunity__c != AA.Opportunity__c)){
                associateAccId.add(AA.Associated_Account_Name__c);
                if(oldMap != null && oldMap.get(AA.Id).Associated_Account_Name__c != null && (oldMap.get(AA.Id).Associated_Account_Name__c != AA.Associated_Account_Name__c 
                                                                                              || oldMap.get(AA.Id).Opportunity__c != AA.Opportunity__c))
                {
                    associateAccId.add(oldMap.get(AA.Id).Associated_Account_Name__c);
                }
            }
        }
        
        //get all opportunity related to Associate account
        List<Associated_Account__c> associateAccList = [SELECT Id, Associated_Account_Name__c, Opportunity__c FROM Associated_Account__c
                                                        WHERE Associated_Account_Name__c =:associateAccId AND Associated_Account_Name__r.RecordType.Name != 'Pella Account'];
        Map<String, Set<String>> mapAccOpp = new Map<String, Set<String>>();
        for(Associated_Account__c AA : associateAccList){
            if(AA.Opportunity__c != null){
                associateOppId.add(AA.Opportunity__c);
            }
            if(AA.Associated_Account_Name__c != null){
                if(!mapAccOpp.containsKey(AA.Associated_Account_Name__c)){
                    mapAccOpp.put(AA.Associated_Account_Name__c, new Set<String>());
                }
                mapAccOpp.get(AA.Associated_Account_Name__c).add(AA.Opportunity__c);
            }
            
        }
        
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE OpportunityId =:associateOppId
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name = 'Branch Account'
                                 AND BookDate__c >=: stdt AND BookDate__c <=: eddt];
        
        Decimal totalAcc = 0;
        Decimal totalOpp = 0;
        Map<String, Decimal> mapAcct = new Map<String, Decimal>();
        Map<String, Decimal> mapOpp = new Map<String, Decimal>();
        
        for(Quote qt : quoteList){
            if(!mapOpp.containsKey(qt.OpportunityId)){
                mapOpp.put(qt.OpportunityId, 0);
            }
            totalOpp = mapOpp.get(qt.OpportunityId) + (qt.Customer_Extended_Price__c == null ? 0 : qt.Customer_Extended_Price__c);
            mapOpp.put(qt.OpportunityId, totalOpp);
        }
        
        List<Account> accList = new List<Account>();
        
        for(String accId : associateAccId){
            Account acc = new Account();
            acc.Id = accId;
            if(mapAccOpp.containsKey(accId)){
                Decimal totalYTDAssociate = 0;
                for(String oppId : mapAccOpp.get(accId)){
                    if(mapOpp.containsKey(oppId)){
                        totalYTDAssociate += mapOpp.get(oppId);
                    }
                }
                acc.YTD_Associated_Sales__c = totalYTDAssociate;
                
            }else{
                acc.YTD_Associated_Sales__c = 0;
            }
            accList.add(acc);
        }
        if(accList.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update accList; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
        
    }
}