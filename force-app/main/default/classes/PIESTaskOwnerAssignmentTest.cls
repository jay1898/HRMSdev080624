@isTest
public class PIESTaskOwnerAssignmentTest {
	
    static testMethod void taskOwnerAssignWOOwner(){
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
        //Create quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        //create group
        Group gp = new Group();
        gp.name = 'PIES ST 1';
        Insert gp; 
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo.PostalCode = '32926';
        wo.ServiceTerritoryId = st.Id;
        WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        
        WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt2.Id, wo.Id, false) ;
        WOLI.PostalCode = '32926';
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER= false;
        Insert WOLI;
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('OV_Install', 'Test', ac.Id, opp.Id, WOLI.Id, false);
        sa.Status = 'New';
        sa.ServiceTerritoryId = ST.Id;
        sa.Country='US';
        sa.Parent_WOLI__c = woli.id;
        sa.FSSK__FSK_Work_Order__c = wo.id ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = TRUE;
        insert sa;
        Test.startTest();
        PIESTaskOwnerAssignment.FlowInputs firstInput = new PIESTaskOwnerAssignment.FlowInputs();
        firstInput.tasktype = 'OV';
        firstInput.woId = wo.Id ;
       
        List<PIESTaskOwnerAssignment.FlowInputs> request = new List<PIESTaskOwnerAssignment.FlowInputs>();
        request.add(firstInput);
        PIESTaskOwnerAssignment.taskOwnerAssignment(request);
        
       
        Test.stopTest();
    }
    static testMethod void taskOwnerAssignOVPC(){
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
        WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install').getRecordTypeId();
        Task t = new Task();
        t.ownerId = us2.Id ;
        t.ActivityDate = System.today() + 2 ;
        t.Status = 'In Progress';
        t.RecordTypeId = tskRTId;
        insert t ;
        
        WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt2.Id, wo.Id, false) ;
        WOLI.PostalCode = '32926';
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER= false;
        Insert WOLI;
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('OV_Install', 'Test', ac.Id, opp.Id, WOLI.Id, false);
        sa.Status = 'New';
        sa.ServiceTerritoryId = ST.Id;
        sa.Country='US';
        sa.Parent_WOLI__c = woli.id;
        sa.FSSK__FSK_Work_Order__c = wo.id ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = TRUE;
        insert sa;
        Test.startTest();
        PIESTaskOwnerAssignment.FlowInputs firstInput = new PIESTaskOwnerAssignment.FlowInputs();
        firstInput.tasktype = 'OV';
        firstInput.woId = wo.Id ;
       
        List<PIESTaskOwnerAssignment.FlowInputs> request = new List<PIESTaskOwnerAssignment.FlowInputs>();
        request.add(firstInput);
        PIESTaskOwnerAssignment.taskOwnerAssignment(request);
        
       
        Test.stopTest();
    }
    static testMethod void taskOwnerAssignSchedPC(){
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
        WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install').getRecordTypeId();
        Task t = new Task();
        t.ownerId = us2.Id ;
        t.ActivityDate = System.today() + 2 ;
        t.Status = 'In Progress';
        t.RecordTypeId = tskRTId;
        insert t ;
        
        WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt2.Id, wo.Id, false) ;
        WOLI.PostalCode = '32926';
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER= false;
        Insert WOLI;
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('OV_Install', 'Test', ac.Id, opp.Id, WOLI.Id, false);
        sa.Status = 'New';
        sa.ServiceTerritoryId = ST.Id;
        sa.Country='US';
        sa.Parent_WOLI__c = woli.id;
        sa.FSSK__FSK_Work_Order__c = wo.id ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = TRUE;
        insert sa;
        Test.startTest();
        PIESTaskOwnerAssignment.FlowInputs firstInput = new PIESTaskOwnerAssignment.FlowInputs();
        firstInput.tasktype = 'Scheduling';
        firstInput.woId = wo.Id ;
       
        List<PIESTaskOwnerAssignment.FlowInputs> request = new List<PIESTaskOwnerAssignment.FlowInputs>();
        request.add(firstInput);
        PIESTaskOwnerAssignment.taskOwnerAssignment(request);
        
       
        Test.stopTest();
    }
     static testMethod void taskOwnerAssignRecoveryPC(){
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
        sr1.Assign_Tasks_Recovery__c = TRUE ;
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
        WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        
        Id tskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install').getRecordTypeId();
        Task t = new Task();
        t.ownerId = us2.Id ;
        t.ActivityDate = System.today() + 2 ;
        t.Status = 'In Progress';
        t.RecordTypeId = tskRTId;
        insert t ;
        
        WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt2.Id, wo.Id, false) ;
        WOLI.PostalCode = '32926';
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER= false;
        Insert WOLI;
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('OV_Install', 'Test', ac.Id, opp.Id, WOLI.Id, false);
        sa.Status = 'New';
        sa.ServiceTerritoryId = ST.Id;
        sa.Country='US';
        sa.Parent_WOLI__c = woli.id;
        sa.FSSK__FSK_Work_Order__c = wo.id ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = TRUE;
        insert sa;
        Test.startTest();
        PIESTaskOwnerAssignment.FlowInputs firstInput = new PIESTaskOwnerAssignment.FlowInputs();
        firstInput.tasktype = 'Recovery';
        firstInput.woId = wo.Id ;
       
        List<PIESTaskOwnerAssignment.FlowInputs> request = new List<PIESTaskOwnerAssignment.FlowInputs>();
        request.add(firstInput);
        PIESTaskOwnerAssignment.taskOwnerAssignment(request);
        
       
        Test.stopTest();
    }
}