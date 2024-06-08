global class UpdateAccountPhoneBatchJob implements Database.Batchable<sObject>,Schedulable
{
    public String query;

    global UpdateAccountPhoneBatchJob() 
    {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator([SELECT Id, Phone, MdmRecId_Phone__c, Parent.Phone, Parent.MdmRecId_Phone__c FROM Account
                                        WHERE RecordType.DeveloperName = 'BranchAccount'
                                        AND (Phone = NULL OR MdmRecId_Phone__c = NULL)
                                        AND Parent.RecordType.DeveloperName = 'Organization' AND Parent.CreatedBy.Alias = 'dmigr'
                                        AND (Parent.Phone != null OR Parent.MDMrecId_Phone__c != NULL)]);
    }

    global void execute(System.SchedulableContext sc) 
    {
        Database.executeBatch(new UpdateAccountPhoneBatchJob(), 1 );
    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        List<Account> childAccountsToUpdate = new List<Account>();

        for(Account ac : (List<Account>)scope )
        {
            if(String.isBlank(ac.Phone) || String.isBlank(ac.MdmRecId_Phone__c))
            {
                if(String.isBlank(ac.Phone) && String.isNotBlank(ac.Parent.Phone) ) ac.Phone = ac.Parent.Phone ;
                if(String.isBlank(ac.MdmRecId_Phone__c) && String.isNotBlank(ac.Parent.MdmRecId_Phone__c) ) ac.MdmRecId_Phone__c = ac.Parent.MdmRecId_Phone__c ;
                childAccountsToUpdate.add(ac);
            }
        }
        AccountTriggerHandler.RUN_EBS_CALLOUT = false ;
        update childAccountsToUpdate ;
    }

    global void finish(Database.BatchableContext BC) {

    }
}