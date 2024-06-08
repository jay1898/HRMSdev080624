global class CreateAccountBranchProfileBatch implements Database.Batchable<sObject>, Database.Stateful
{
    public String query;

    global CreateAccountBranchProfileBatch() 
    {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator([   SELECT AccountId, Zone__r.ParentTerritory.Branch__c 
                                            FROM Opportunity 
                                            WHERE (Account.Branch_Number__c = NULL OR Account.Branch_Number__c = '')
                                                    AND Zone__r.ParentTerritory.Branch__r.Branch_Number__c != NULL ]);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        List<Opportunity> opps = (List<Opportunity>)scope ;
        Map<Id,Account_Branch_Profile__c> accountIdToABP = new Map<Id,Account_Branch_Profile__c>();
        for(Opportunity opp : opps)
        {
            if(!accountIdToABP.containsKey(opp.AccountId)) accountIdToABP.put(opp.AccountId, new Account_Branch_Profile__c(Party_Account__c=opp.AccountId, Branch__c = opp.Zone__r.ParentTerritory.Branch__c ));
        }
        if(accountIdToABP.size() > 0 ) insert accountIdToABP.values() ;
    }

    global void finish(Database.BatchableContext BC) {
    }
}