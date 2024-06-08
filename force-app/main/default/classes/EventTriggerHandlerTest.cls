@isTest
public class EventTriggerHandlerTest {
    @isTest
    public static void EventTriggerHandlerMethod(){
        User u = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()); 
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        Account acc = TestUtil.createAccount('Person Account', true);
        Opportunity op = TestUtil.createOpportunity('Test Oppty',acc.Id, u1.Id, true);
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Id SRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        sr.ResourceType = 'T';
        sr.RecordTypeId = SRRT ;
        insert sr;
    //    sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
    //    sr.AccountId = acc.Id;
    //    insert sr;
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Replacement_Event').getRecordTypeId();
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, true);
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=false;
         Test.startTest();
        Event event = TestUtil.createEvent(u.Id, false); 
        event.ShowAs = 'Busy';
        event.WhatId = testOpportunity.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+1);
        event.RecordTypeId = evRTId ;
        insert event;
        
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+2);
        event.Event_Type__c= 'Time Block';
        event.ShowAs = 'Free';
        update event;
        
        event = TestUtil.createEvent(u.Id, false); 
        event.Event_Type__c= 'Follow Up';
        event.WhatId = testOpportunity.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+2);
        event.RecordTypeId = evRTId ;
        insert event;

    	event.OwnerId = u1.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+2);
        event.ShowAs = 'Free';
        event.WhatId = acc.Id;
        event.type = '';       
        event.WhatId = acc.Id;
        event.type = 'Meeting';
       // Test.setCreatedDate(event.Id, Date.today());
        update event;

		event.WhatId = acc.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+2);
        event.type = 'CEU';
        //Test.setCreatedDate(event.Id, Date.today());
        update event;
       
        event.Account__c = null;
        update event;
        
        event.Account__c = null;
        event.Opportunity_Full_Details__c = op.Id;
        update event;
        
        Task tsk = new Task();
        tsk.WhatId = acc.Id;
        tsk.Type = 'Call';
        tsk.RecordTypeId = tskRTId ;
        insert tsk;
        
        Task tsk2 = new Task();
        tsk2.WhatId = acc.Id;
        tsk2.Type = 'Meeting';
        tsk2.RecordTypeId = tskRTId ;
        insert tsk2;
        
        delete event;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=true;
       Test.stopTest();
    }
    @isTest
     public static void EventAttendee(){
        User u = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()); 
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        Account acc = TestUtil.createAccount('Person Account', true);
        Opportunity op = TestUtil.createOpportunity('Test Oppty',acc.Id, u1.Id, true);
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Id SRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        sr.ResourceType = 'T';
        sr.RecordTypeId = SRRT ;
        insert sr;
         
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank2', u1.Id, branch.Id, bf.Id, false);
        sr1.AccountId = acc.Id;
        sr1.ResourceType = 'T';
        sr1.RecordTypeId = SRRT ;
        insert sr1;
    //    sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
    //    sr.AccountId = acc.Id;
    //    insert sr;
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Replacement_Event').getRecordTypeId();
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, true);
       
         Test.startTest();
        Event event = TestUtil.createEvent(u.Id, false); 
        event.ShowAs = 'Busy';
         event.Event_Type__c= 'Time Block';
        event.WhatId = testOpportunity.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+1);
        event.RecordTypeId = evRTId ;
        insert event;
        
         EventRelation relation=new EventRelation();
         relation.eventId=event.Id;
         relation.RelationId=u1.Id;
         insert relation;
        
         
         
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+2);
        event.Event_Type__c= 'Time Block';
        event.ShowAs = 'Busy';
         
        update event;
        
      	
       Test.stopTest();
    }
     @isTest
     public static void EventAttendeeSR(){
        User u = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()); 
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        Account acc = TestUtil.createAccount('Person Account', true);
        Opportunity op = TestUtil.createOpportunity('Test Oppty',acc.Id, u1.Id, true);
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Id SRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
       
         
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank2', u1.Id, branch.Id, bf.Id, false);
        sr1.AccountId = acc.Id;
        sr1.ResourceType = 'T';
        sr1.RecordTypeId = SRRT ;
        insert sr1;
    //    sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
    //    sr.AccountId = acc.Id;
    //    insert sr;
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Replacement_Event').getRecordTypeId();
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, true);
       
         Test.startTest();
        Event event = TestUtil.createEvent(u.Id, false); 
        event.ShowAs = 'Busy';
         event.Event_Type__c= 'Time Block';
        //event.WhatId = testOpportunity.Id;
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+1);
        event.RecordTypeId = evRTId ;
        insert event;
        
         EventRelation relation=new EventRelation();
         relation.eventId=event.Id;
         relation.RelationId=u1.Id;
         insert relation;
        
         
         
        event.StartDateTime = DateTime.now();
        event.EndDateTime = DateTime.now().addDays(+2);
        event.Event_Type__c= 'Time Block';
        event.ShowAs = 'Busy';
         
        update event;
        
      	
       Test.stopTest();
    }
  }