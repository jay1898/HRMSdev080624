@isTest
public class RAUpdateForAlldayEventsBatchTest {
 public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
testMethod
    static void eventbatchLog(){
         
        User u = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()); 
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, true);
        
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=false;
        Event event = TestUtil.createEvent(u.Id, false); 
        event.WhatId = testOpportunity.Id;
        insert event;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+1);
        
        update event;
        
        event = TestUtil.createEvent(u.Id, false); 
        event.Event_Type__c= 'Follow Up';
        event.WhatId = testOpportunity.Id;
        insert event;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+1);
        
        update event;
        event.OwnerId = u1.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+1);
        event.IsAllDayEvent = TRUE;
        update event;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=true;
         Test.startTest();
        String jobId = System.schedule('RAUpdateForAlldayEventsBatch', CRON_EXP, new RAUpdateForAlldayEventsBatch());
        Test.stopTest();
    }
}