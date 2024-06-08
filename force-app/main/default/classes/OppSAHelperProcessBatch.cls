global without sharing class OppSAHelperProcessBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable
{   
    global String query ; 
    global Datetime currentTime ; 
    global Datetime next24Hours ; 

    global OppSAHelperProcessBatch() 
    {
        currentTime = Datetime.now() ;
        next24Hours = currentTime.addHours(24);
        currentTime = currentTime.addHours(-2);
        System.debug('UAC: currentTime ' + currentTime +  ' next24Hours ' + next24Hours );

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([   SELECT Id, Appointment_DateTime__c, StageName, Status__c, Update_SA_Helper__c, Create_Quote_Shell__c, Quote_Number_Shell__c
                                            FROM Opportunity
                                            WHERE   StageName IN ('New', 'Active') AND Status__c IN ('New', 'Active') AND Status__c != 'Canceled'
                                                    AND Set_by_Active_Quote_Note_in_PB__c = FALSE  
                                                    AND Appointment_DateTime__c != NULL AND Appointment_DateTime__c >= :currentTime AND Appointment_DateTime__c <= :next24Hours 
                                                    AND Appointment_Type__c != 'Preferred'
                                                    AND Quote_Number_Shell__c = NULL AND PQM_Quote_Shell_Error_Message__c = NULL 
                                        ]);
    }

    global void execute(System.SchedulableContext sc){
        Database.executeBatch(new OppSAHelperProcessBatch(), 10 );
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        
        List<Opportunity> opps = (List<Opportunity>)scope;

        for(Opportunity opp : opps )
        {
            opp.Update_SA_Helper__c = TRUE ;
            opp.StageName = 'Active' ;
            opp.Status__c = 'Active';
        }
        
        try
        {   
            System.debug('UAC: opps ' + opps )   ;
            OpportunityTriggerHandler.RUN_POST_SHELL_QUOTE_PQM_FUTURE = false ; 
            OpportunityTriggerHandler.Check_Conflict_Overriden = false ;
            update opps ; 
        }
        catch(Exception ex){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OppSAHelperProcessBatch', 'execute', opps[0].Id, ex, 'Integration' ));}
        
    }

    global void finish(Database.BatchableContext BC) {
        
        Database.executeBatch(new CreateQuoteShellPQMBatch(), 1);

        /*
System.schedule('OppSAHelperProcessBatch Job 2', '0 2 * * * ?', new OppSAHelperProcessBatch());
System.schedule('OppSAHelperProcessBatch Job 17', '0 17 * * * ?', new OppSAHelperProcessBatch());
System.schedule('OppSAHelperProcessBatch Job 32', '0 32 * * * ?', new OppSAHelperProcessBatch());
System.schedule('OppSAHelperProcessBatch Job 47', '0 47 * * * ?', new OppSAHelperProcessBatch());

        */
    }   
}