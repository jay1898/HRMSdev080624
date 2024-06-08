global class RTANoOppLeadAlert implements Schedulable {
    global void execute(SchedulableContext ctx) {
        List<RTAIntegrationConfig__c> lastExTime = new List<RTAIntegrationConfig__c>();
        try{
            lastExTime = [Select Id, Last_Execution_Time__c from RTAIntegrationConfig__c limit 1];
            if(lastExTime.size() > 0 || Test.isRunningTest())
            {
                List<Lead> createdLeads = [Select Id, Name from Lead where  CreatedDate > :lastExTime[0].Last_Execution_Time__c limit 1];
                List<Opportunity> createdOpportunities = [Select Id, Name from Opportunity where  CreatedDate > :lastExTime[0].Last_Execution_Time__c limit 1];
                if(createdLeads.size() == 0 && createdOpportunities.size() == 0)
                {
                    new ApexDebugLog().createLog(
                        new ApexDebugLog.Error(
                            'RTANoOppLeadAlert',
                            'execute',
                            'Last Execution Time: '+lastExTime[0].Last_Execution_Time__c + ' and Current Time: ' + DateTime.now(),
                            System.Label.No_Opportunity_and_Lead_Alert,
                            null,
                            'Internal'
                        )
                    );
                }
                lastExTime[0].Last_Execution_Time__c = DateTime.now();
                update lastExTime[0];
            }
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(
                new ApexDebugLog.Error(
                    'RTANoOppLeadAlert',
                    'execute',
                    'Last Execution Time: '+((lastExTime.size()>0)?lastExTime[0].Last_Execution_Time__c:null),
                    ex,
                    'Internal'
                )
            );
        }
    }
}