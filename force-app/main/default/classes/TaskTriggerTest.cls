@isTest
private class TaskTriggerTest 
{
    static testMethod void TestTaskTriggerMethod(){
        
        // Create User
        User usr = TestUtil.createUser(true);
        User u1 = TestUtil.createUser(false);
        u1.FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()); 
        u1.UserName ='test@test2783232323.com';
        insert u1;
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Opportunity
        Communication__c comm = TestUtil.createCommunication(true);
        
        // Create OpportunityCommunication
        OpportunityCommunication__c OC = new OpportunityCommunication__c();
        //OC.Contact__c = con.Id;
        OC.Opportunity__c = opp.Id;
        Oc.Communication__c = comm.Id;
        insert OC;
        
        Task tk = new task();
        tk.subject = 'Unresolved Email ref: '+OC.Id;
        tk.Description = 'test task ';
        tk.WhatId = OC.Id;
        insert tk;
        
        Test.startTest();
        
        Task tsk = new Task();
        tsk.WhatId = ac.Id;
        tsk.Type = 'Call';
        insert tsk;
        
        tsk.Type = 'Meeting';
        update tsk;
        
        tsk.Type = 'To Do';
        update tsk;
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        ServiceResource sr = TestUtil.createServiceResource('Mayank', usr.Id, branch.Id, bf.Id, false);
        sr.AccountId = ac.Id;
        sr.ResourceType='T' ;
        sr.RecordTypeId=srRTId;
        insert sr;
        
        sr = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
        sr.AccountId = ac.Id;
        sr.ResourceType='T' ;
        
        sr.RecordTypeId=srRTId;
        insert sr;
        
        
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=false;
        Event event = TestUtil.createEvent(usr.Id, false); 
        event.ShowAs = 'Free';
        event.Event_Type__c=null;
        event.type = 'Meeting';
        event.WhatId = ac.Id;
        event.OwnerId = usr.Id;
        event.StartDateTime=DateTime.now();
        event.EndDateTime=DateTime.now().addHours(3);
        insert event;
        
        event = TestUtil.createEvent(usr.Id, false); 
        event.ShowAs = 'Free';
        event.type = 'Call';
        event.Event_Type__c=null;
        event.WhatId = ac.Id;
        event.OwnerId = usr.Id;
        event.StartDateTime=DateTime.now();
        event.EndDateTime=DateTime.now().addHours(3);
        insert event;
        
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=true;
        Test.stopTest();
    }
    
    static testMethod void TestTaskTriggerMethod2(){
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Opportunity
        Communication__c comm = TestUtil.createCommunication(true);
        
        // Create OpportunityCommunication
        OpportunityCommunication__c OC = new OpportunityCommunication__c();
        OC.Opportunity__c = opp.Id;
        OC.Communication__c = comm.Id;
        insert OC;
        
        // Create OpportunityCommunication
        OpportunityCommunication__c OC1 = new OpportunityCommunication__c();
        OC1.Opportunity__c = opp.Id;
        OC1.Communication__c = comm.Id;
        insert OC1;
        
        // Create Lead
        Lead ld = TestUtil.createLead('test','Lead', true);
        
        // Create Task
        Task tk = new task();
        tk.subject = 'Unresolved Email Unresolved Email Unresolved Email Unresolved Email';
        tk.Description = 'test task ref: '+OC.Id;
        tk.WhatId = OC.Id;
        insert tk; 
    } 
    static testMethod void TestTaskTriggerMethod3(){
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Opportunity
        Communication__c comm = TestUtil.createCommunication(true);
        
        // Create OpportunityCommunication
        OpportunityCommunication__c OC = new OpportunityCommunication__c();
        OC.Opportunity__c = opp.Id;
        OC.Communication__c = comm.Id;
        insert OC;
        
        // Create OpportunityCommunication
        OpportunityCommunication__c OC1 = new OpportunityCommunication__c();
        OC1.Opportunity__c = opp.Id;
        OC1.Communication__c = comm.Id;
        insert OC1;
        
        // Create Lead
        Lead ld = TestUtil.createLead('test','Lead', true);
        
        // Create Task
        Task tk = new task(); 
        tk.subject = ' Email';
        tk.Description = 'test task '+OC.Id;
        tk.WhatId = OC.Id;
        insert tk;  
    } 
    
   static testMethod void createAutoTaskforPIES(){
        User us = TestUtil.createUser(true);
        User us2 = TestUtil.createUser(true);
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        //Create PIES Territory
        ServiceTerritory st = TestUtil.createPIESServiceTerritroy('PIES ST 1', branch.Id, oh.Id, 'Install', false );
        st.IsActive = true;
        Insert st ;
        
        //create child territory
        ServiceTerritory chst = TestUtil.createPIESZCServiceTerritroy('32926','32926', st.Id, oh.Id, false);
        chst.IsActive = true ;
        insert chst;
        ServiceTerritory chst2 = TestUtil.createPIESZCServiceTerritroy('32116','32116', st.Id, oh.Id, false);
        chst2.IsActive = true ;
        insert chst2;
        
        //Create territory zipcode
        Territory_Zipcode__c tz = TestUtil.createTZforPIES(st.Id, chst.Id, true);
        Territory_Zipcode__c tz1 = TestUtil.createTZforPIES(st.Id, chst2.Id, true);
        
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        ServiceResource sr1 = TestUtil.createServiceResource('Pallavi PIES', us2.Id, branch.Id, bf.Id, false);
        sr1.Project_Coordinator__c = TRUE;
        sr1.Assign_Tasks_OV__c = TRUE ;
        sr1.Business_Segment__c = 'Replacement' ;
        sr1.RecordTypeId = srRTId ;
        insert sr1;  
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Project'; Insert wt;
         //create work type
        WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Install', 'Hours', 2,false);
        wt2.Schedule_Type__c = 'OV'; Insert wt2;
        
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
		Test.startTest();
        //Create quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        q.Business_Segment__c = 'Replacement';
        insert q ;
        
        //create group
        Group gp = new Group();
        gp.name = 'PIES ST 1';
        Insert gp; 
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo.PostalCode = '32926';
        wo.ServiceTerritoryId = st.Id;
        WorkOrderTriggerHandler.RUN_TRIGGER= FALSE;
        Insert wo;
        
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install').getRecordTypeId();
        Task t = new Task();
        t.ownerId = us2.Id ;
        t.ActivityDate = System.today() + 2 ;
        t.Status = 'In Progress';
        t.RecordTypeId = tskRTId;
        t.Subject = 'Review New Job';
        t.Auto_Task__c = TRUE;
        t.WhatId = wo.Id;
        t.type = 'Order Verification';
        insert t ;
        
        t.Status = 'Completed';
        update t;
		Test.stopTest();
    }
    static testMethod void createAutoTaskforPIES2(){
        User us = TestUtil.createUser(true);
        User us2 = TestUtil.createUser(true);
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        //Create PIES Territory
        ServiceTerritory st = TestUtil.createPIESServiceTerritroy('PIES ST 1', branch.Id, oh.Id, 'Install', false );
        st.IsActive = true;
        Insert st ;
        
        //create child territory
        ServiceTerritory chst = TestUtil.createPIESZCServiceTerritroy('32926','32926', st.Id, oh.Id, false);
        chst.IsActive = true ;
        insert chst;
        ServiceTerritory chst2 = TestUtil.createPIESZCServiceTerritroy('32116','32116', st.Id, oh.Id, false);
        chst2.IsActive = true ;
        insert chst2;
        
        //Create territory zipcode
        Territory_Zipcode__c tz = TestUtil.createTZforPIES(st.Id, chst.Id, true);
        Territory_Zipcode__c tz1 = TestUtil.createTZforPIES(st.Id, chst2.Id, true);
        
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        ServiceResource sr1 = TestUtil.createServiceResource('Pallavi PIES', us2.Id, branch.Id, bf.Id, false);
        sr1.Project_Coordinator__c = TRUE;
        sr1.Assign_Tasks_Scheduling__c = TRUE ;
        sr1.Assign_Tasks_Recovery__c = TRUE;
        sr1.Business_Segment__c = 'Replacement' ;
        sr1.RecordTypeId = srRTId ;
        insert sr1;  
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Project'; Insert wt;
         //create work type
        WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Install', 'Hours', 2,false);
        wt2.Schedule_Type__c = 'OV'; Insert wt2;
        
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        Test.startTest();
        //Create quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        q.Business_Segment__c = 'Replacement';
        insert q ;
        
        //create group
        Group gp = new Group();
        gp.name = 'PIES ST 1';
        Insert gp; 
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo.PostalCode = '32926';
        wo.ServiceTerritoryId = st.Id;
        wo.status = 'New';
        WorkOrderTriggerHandler.RUN_TRIGGER= FALSE;
        Insert wo;
        
        WorkOrder wo2 = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo2.PostalCode = '32926';
        wo2.ServiceTerritoryId = st.Id;
        wo2.status = 'New';
        WorkOrderTriggerHandler.RUN_TRIGGER= FALSE;
        Insert wo2;
        
        List<Task> lstTask  = new List<Task>();
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install').getRecordTypeId();
        Task t = new Task();
        t.ownerId = us2.Id ;
        t.ActivityDate = System.today() + 2 ;
        t.Status = 'In Progress';
        t.RecordTypeId = tskRTId;
        t.Subject = 'Book Order';
        t.Auto_Task__c = TRUE;
        t.WhatId = wo.Id;
        t.type = 'Scheduling';
        //insert t ;
        lstTask.add(t);
        Task t2 = new Task();
        t2.ownerId = us2.Id ;
        t2.ActivityDate = System.today() + 2 ;
        t2.Status = 'In Progress';
        t2.RecordTypeId = tskRTId;
        t2.Subject = 'Purchase Product';
        t2.Auto_Task__c = TRUE;
        t2.WhatId = wo2.Id;
        t2.type = 'Recovery';
        //insert t2 ;
        lstTask.add(t2);
        Insert lstTask ;
        
        List<Task> listupd = new List<Task>();
        for(Task tsk : lstTask){
			tsk.Status = 'Completed';
            listupd.add(tsk); 
        }
        UPDATE listupd ;
        Test.stopTest();
    }
}