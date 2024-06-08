global class PQMNoQuoteShellAlert implements Schedulable {
   global void execute(SchedulableContext ctx) {
        List<PQMIntegrationConfig__c> lastExTime = new List<PQMIntegrationConfig__c>();
        try{
            lastExTime = [Select Id, Last_Execution_Time__c from PQMIntegrationConfig__c limit 1];
            if(lastExTime.size() > 0 || Test.isRunningTest())
            {
                List<Apex_Debug_Log__c> createdQuoteShell = [Select Id, Name from Apex_Debug_Log__c where Method__c='postToPQMFuture' and Type__c='Information' and  CreatedDate > :lastExTime[0].Last_Execution_Time__c limit 1];
                if(createdQuoteShell.size() == 0)
               	{
                    new ApexDebugLog().createLog(
                        new ApexDebugLog.Error(
                            'PQMNoQuoteShellAlert',
                            'execute',
                            'Last Execution Time: '+lastExTime[0].Last_Execution_Time__c + ' and Current Time: ' + DateTime.now(),
                            System.Label.No_Quote_Shell_Alert,
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
                    'PQMNoQuoteShellAlert',
                    'execute',
                    'Last Execution Time: '+((lastExTime.size()>0)?lastExTime[0].Last_Execution_Time__c:null),
                    ex,
                    'Internal'
                )
            );
        }
    }
}