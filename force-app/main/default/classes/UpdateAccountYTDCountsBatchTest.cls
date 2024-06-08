@isTest
public class UpdateAccountYTDCountsBatchTest {
    public TestMethod static void ClassTestMethod(){
        User u = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now());
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.YTD_Phone_Calls__c = 5;
        acc.YTD_Meetings__c = 10;
        acc.YTD_CEUs__c = 1; 
        acc.YTD_Tasks__c = 50;
        insert acc;
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=false;
        Event event = TestUtil.createEvent(u.Id, false);
        event.ShowAs = 'Free';
        event.OwnerId = u1.Id;
        event.WhatId = acc.Id;
        event.type = 'Meeting';
        insert event;

        event = TestUtil.createEvent(u.Id, false);
        event.ShowAs = 'Free';
        event.OwnerId = u1.Id;
        event.WhatId = acc.Id;
        event.type = 'Call';
        insert event;
        
        event = TestUtil.createEvent(u.Id, false);
        event.ShowAs = 'Free';
        event.OwnerId = u1.Id;
        event.WhatId = acc.Id;
        event.type = 'CEU';
        insert event;
        
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=true;
        
        Task tsk = new Task();
        tsk.WhatId = acc.Id;
        tsk.Type = 'Call';
        insert tsk;
        
        tsk = new Task();
        tsk.WhatId = acc.Id;
        tsk.Type = 'Meeting';
        insert tsk;
        
        tsk = new Task();
        tsk.WhatId = acc.Id;
        tsk.Type = 'To Do';
        insert tsk;
        
        Test.startTest();
        UpdateAccountYTDCountsBatch updateAccRec = New UpdateAccountYTDCountsBatch();
        Database.executeBatch(updateAccRec);
        Test.stopTest();
    }
}