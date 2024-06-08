global class OpportunityRecordShareTCBatch implements Database.Batchable<sObject>, Schedulable
{
    public String query;

    global OpportunityRecordShareTCBatch() {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(Label.AOR_Opportunity_Share);
        //return Database.getQueryLocator([SELECT Id FROM Opportunity WHERE LastModifiedDate >= YESTERDAY AND LastModifiedBy.Profile.Name = 'Data Migration']);
    }

    public void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new OpportunityRecordShareTCBatch() ,200);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        List<Id> oppIds = new List<Id>();

        for(Sobject so : scope)
        {
            oppIds.add((Id)so.get('Id'));
        }
        OpportunityRecordShare.shareOppRecordWithETMGroup(oppIds);
    }

    global void finish(Database.BatchableContext BC) {

    }
}