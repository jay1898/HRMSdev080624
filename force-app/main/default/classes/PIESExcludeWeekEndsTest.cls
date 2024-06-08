@isTest
public class PIESExcludeWeekEndsTest {
    
    static testMethod void excludeweekendsplus1(){
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
        PIESExcludeWeekEnds.FlowInputs firstInput = new PIESExcludeWeekEnds.FlowInputs();
        firstInput.saSchedStartTime = sa.SchedStartTime;
        firstInput.taskoffset1 = 3 ;
        firstInput.taskoffset2 = 2 ;
        firstInput.taskoffset3 = 8 ;
        List<PIESExcludeWeekEnds.FlowInputs> request = new List<PIESExcludeWeekEnds.FlowInputs>();
        request.add(firstInput);
        PIESExcludeWeekEnds.excludeweekends(request);
        
        /*PIESExcludeWeekEndsOffset2.FlowInputs firstInput2 = new PIESExcludeWeekEndsOffset2.FlowInputs();
        firstInput2.saSchedStartTime = sa.SchedStartTime;
        firstInput2.taskoffset2 = 8 ;
        List<PIESExcludeWeekEndsOffset2.FlowInputs> request2 = new List<PIESExcludeWeekEndsOffset2.FlowInputs>();
        request2.add(firstInput2);
        PIESExcludeWeekEndsOffset2.excludeweekends(request2); 
         
        PIESExcludeWeekEndsOffset3.FlowInputs firstInput3 = new PIESExcludeWeekEndsOffset3.FlowInputs();
        firstInput3.saSchedStartTime = sa.SchedStartTime;
        firstInput3.taskoffset3 = 7 ; 
        List<PIESExcludeWeekEndsOffset3.FlowInputs> request3 = new List<PIESExcludeWeekEndsOffset3.FlowInputs>();
        request3.add(firstInput3);
        PIESExcludeWeekEndsOffset3.excludeweekends(request3);*/
        Test.stopTest();
    }
     static testMethod void excludeweekendnegativeoffset(){
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
        PIESExcludeWeekEnds.FlowInputs firstInput = new PIESExcludeWeekEnds.FlowInputs();
        firstInput.saSchedStartTime = sa.SchedStartTime;
        firstInput.taskoffset1 = -11 ;
      	firstInput.taskoffset2 = -2 ;
        firstInput.taskoffset3 = -8 ;
        List<PIESExcludeWeekEnds.FlowInputs> request = new List<PIESExcludeWeekEnds.FlowInputs>();
        request.add(firstInput);
        PIESExcludeWeekEnds.excludeweekends(request);
        
        /*PIESExcludeWeekEndsOffset2.FlowInputs firstInput2 = new PIESExcludeWeekEndsOffset2.FlowInputs();
        firstInput2.saSchedStartTime = sa.SchedStartTime;
        firstInput2.taskoffset2 = -8 ;
        List<PIESExcludeWeekEndsOffset2.FlowInputs> request2 = new List<PIESExcludeWeekEndsOffset2.FlowInputs>();
        request2.add(firstInput2);
        PIESExcludeWeekEndsOffset2.excludeweekends(request2); 
         
        PIESExcludeWeekEndsOffset3.FlowInputs firstInput3 = new PIESExcludeWeekEndsOffset3.FlowInputs();
        firstInput3.saSchedStartTime = sa.SchedStartTime;
        firstInput3.taskoffset3 = -7 ; 
        List<PIESExcludeWeekEndsOffset3.FlowInputs> request3 = new List<PIESExcludeWeekEndsOffset3.FlowInputs>();
        request3.add(firstInput3);
        PIESExcludeWeekEndsOffset3.excludeweekends(request3);*/
        Test.stopTest();
    }

}