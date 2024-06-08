@isTest
public class FlowSchedulerUpdateArrivalTest {
    
     @isTest
    public static void updateArrivaldates(){
          // Create Account
        Account acc = TestUtil.createAccount('Person Account', true);
       
        FSL__Scheduling_Policy__c pol = new FSL__Scheduling_Policy__c(Name='Test Policy, not default');
        insert pol;
        
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
        
          //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Project';
        insert wt;
        
          //create work type
        WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Retail', 'Hours', 2,false);
        wt2.Schedule_Type__c = 'OV';
        insert wt2;
        
      // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', acc.Id, UserInfo.getUserId(), false); 
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

        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, acc.Id, q.Id, false);
        wo.PostalCode = '32926';
        wo.ServiceTerritoryId = st.Id;
        WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        
        WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt2.Id, wo.Id, false) ;
        WOLI.PostalCode = '32926';
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER= false;
        Insert WOLI;
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('OV_Install', 'Test', acc.Id, opp.Id, WOLI.Id, false);
        sa.Status = 'Scheduled';
        sa.ServiceTerritoryId = ST.Id;
        sa.Country='US';
        sa.Parent_WOLI__c = woli.id;
        sa.FSSK__FSK_Work_Order__c = wo.id ;
        sa.SchedStartTime = system.now() ;
        sa.SchedEndTime = system.now() + 15 ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = TRUE;
        insert sa;
        
        FlowSchedulerUpdateArrival.Request req = new FlowSchedulerUpdateArrival.Request();
        req.serviceAppointmentId = sa.Id;
        req.startTimeString = '2022-05-03T21:00:00.000Z';   //String.valueOf('"'+ system.now() +'"'); //string.valueof(system.now()) ;
        req.endTimeString = '2022-05-04T21:00:00.000Z' ;  //String.valueOf('"'+ system.now() +'"');
        
        List< FlowSchedulerUpdateArrival.Request> re = new List< FlowSchedulerUpdateArrival.Request>();
        re.add(req);
        FlowSchedulerUpdateArrival.updateArrivalDateonAppointment(re);

    }

}