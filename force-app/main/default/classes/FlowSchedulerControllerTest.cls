@isTest
public class FlowSchedulerControllerTest {
    
    @isTest
    public static void runTest() {
         User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser){
        User usr = TestUtil.createPIESUser2(true);
         
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_Permissions'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr.Id;
        psa.PermissionSetId = ps1.Id;
        insert psa;
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_License'];  
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        psa1.AssigneeId = usr.Id;
        psa1.PermissionSetId = ps2.Id;
        insert psa1;
       
         // Create Account
        Account acc = TestUtil.createAccount('Person Account', true);
        Id RTId2 = Schema.SObjectType.FSL__Work_Rule__c.RecordTypeInfosByDeveloperName.get('Time_Rule_Service').RecordTypeId;
        Id RTId3 = Schema.SObjectType.FSL__Work_Rule__c.RecordTypeInfosByDeveloperName.get('Gap_Rule_Service').RecordTypeId;
        
        FSL__Work_Rule__c wr = new FSL__Work_Rule__c();
        wr.Name = 'Earliest Start Permitted 2';
        wr.RecordTypeId = RTId2;
        wr.FSL__Service_Schedule_Time_Property__c = 'SchedStartTime';
        wr.FSL__Service_Time_Operator__c = 'Later than or Equal to';
        wr.FSL__Service_Time_Property__c = 'EarliestStartTime';
        insert wr;
        
        FSL__Work_Rule__c wr2 = new FSL__Work_Rule__c();
        wr2.Name = 'Due Date 2';
        wr2.RecordTypeId =RTId2;
        wr2.FSL__Service_Schedule_Time_Property__c = 'SchedEndTime';
        wr2.FSL__Service_Time_Operator__c = 'Before or Equal To';
        wr2.FSL__Service_Time_Property__c = 'DueDate';
        insert wr2;
        
        FSL__Work_Rule__c wr3 = new FSL__Work_Rule__c();
        wr3.Name = 'Resource Availability 2';
        wr3.RecordTypeId = RTId3 ;
        wr3.FSL__Service_Property__c = 'ServiceTerritory';
        insert wr3;
        
        FSL__Scheduling_Policy__c pol = new FSL__Scheduling_Policy__c(Name='Test Policy, not default');
        insert pol;
        
        FSL__Scheduling_Policy_Work_Rule__c spw = new FSL__Scheduling_Policy_Work_Rule__c();
        spw.FSL__Scheduling_Policy__c = pol.Id;
        spw.FSL__Work_Rule__c = wr.Id; Insert spw ;
        
        FSL__Scheduling_Policy_Work_Rule__c spw2 = new FSL__Scheduling_Policy_Work_Rule__c();
        spw2.FSL__Scheduling_Policy__c = pol.Id;
        spw2.FSL__Work_Rule__c = wr2.Id; Insert spw2 ;
        
        FSL__Scheduling_Policy_Work_Rule__c spw3 = new FSL__Scheduling_Policy_Work_Rule__c();
        spw3.FSL__Scheduling_Policy__c = pol.Id;
        spw3.FSL__Work_Rule__c = wr3.Id; Insert spw3 ;
        
              
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone =  String.valueOf(UserInfo.getTimeZone()); Insert oh;
        
         // Create Time Slot
        TimeSlot ts = new TimeSlot();
        ts.EndTime = Time.newInstance(17, 00, 0, 0);
        ts.StartTime =  Time.newInstance(12, 00, 0, 0);
        ts.DayOfWeek = 'Monday';
        ts.OperatingHoursId = oh.Id; Insert ts; 
            
         // Create Time Slot
        TimeSlot ts1 = new TimeSlot();
        ts1.EndTime = Time.newInstance(17, 00, 0, 0);
        ts1.StartTime =  Time.newInstance(12, 00, 0, 0);
        ts1.DayOfWeek = 'Tuesday';
        ts1.OperatingHoursId = oh.Id; Insert ts1; 
            
            
         // Create Time Slot
        TimeSlot ts2 = new TimeSlot();
        ts2.EndTime = Time.newInstance(17, 00, 0, 0);
        ts2.StartTime =  Time.newInstance(12, 00, 0, 0);
        ts2.DayOfWeek = 'Wednesday';
        ts2.OperatingHoursId = oh.Id; Insert ts2; 
            
            
         // Create Time Slot
        TimeSlot ts3 = new TimeSlot();
        ts3.EndTime = Time.newInstance(17, 00, 0, 0);
        ts3.StartTime =  Time.newInstance(12, 00, 0, 0);
        ts3.DayOfWeek = 'Thursday';
        ts3.OperatingHoursId = oh.Id; Insert ts3; 
            
            
         // Create Time Slot
        TimeSlot ts4 = new TimeSlot();
        ts4.EndTime = Time.newInstance(17, 00, 0, 0);
        ts4.StartTime =  Time.newInstance(12, 00, 0, 0);
        ts4.DayOfWeek = 'Friday';
        ts4.OperatingHoursId = oh.Id; Insert ts4; 
            
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        //Create PIES Territory
        ServiceTerritory st = TestUtil.createPIESServiceTerritroy('PIES ST 1', branch.Id, oh.Id, 'Install', false );
        st.IsActive = true;
        st.put(FlowSchedulerController.defaultFieldName, true);
        Insert st ;
            
         //Create PIES Territory
        ServiceTerritory st2 = TestUtil.createPIESServiceTerritroy('PIES ST 2', branch.Id, oh.Id, 'OV', false );
        st2.IsActive = true;
        st2.put(FlowSchedulerController.defaultFieldName, true);
        Insert st2 ;    
        
        //create child territory
        ServiceTerritory chst = TestUtil.createPIESZCServiceTerritroy('32822','32822', st.Id, oh.Id, false);
        chst.IsActive = true ;
        insert chst;
            
        ServiceTerritory chst2 = TestUtil.createPIESZCServiceTerritroy('32116','32116', st2.Id, oh.Id, false);
        chst2.IsActive = true ;
        insert chst2;
        
          //Create territory zipcode
        Territory_Zipcode__c tz = TestUtil.createTZforPIES(st.Id, chst.Id, true);
        Territory_Zipcode__c tz1 = TestUtil.createTZforPIES(st2.Id, chst2.Id, true);
        
        Id RTId = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;   
         // Create 1st Service Resource
         ServiceResource sr1 = TestUtil.createPIESServiceResource('TestPIESOne', usr.Id, bf.Id, false);
         sr1.recordtypeId = RTId ;
         sr1.Resource_Group__c = 'Branch';
         sr1.ResourceType = 'T';
         sr1.Installer__c = TRUE; sr1.IsActive = true ;
            Insert sr1;   
        
        ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember1(sr1.Id, st2.Id, false);
        stm.TerritoryType = 'P';
        Insert stm ;
         //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Minutes', 45,false);
        wt.Schedule_Type__c = 'Project'; Insert wt;
        
        //create work type
        WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Test', 'Minutes', 45,false);
        wt2.Schedule_Type__c = 'OV';
        INSERT wt2;
        
      // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', acc.Id, UserInfo.getUserId(), false); 
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
        insert q ;

        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, acc.Id, q.Id, false);
        wo.PostalCode = '32822';
        wo.ServiceTerritoryId = st.Id;
        WorkOrderTriggerHandler.RUN_TRIGGER= FALSE;
        Insert wo;
        
        WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt2.Id, wo.Id, false) ;
        WOLI.PostalCode = '32116';
        WOLI.ServiceTerritoryId = st2.Id;
        WOLI.Scheduling_Policy__c =pol.Id;
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER= FALSE;
        Insert WOLI;
        
        ServiceAppointment sa = TestUtil.createPIESServiceAppointment('OV_Install', 'Test', acc.Id, WOLI.Id, false);
        sa.Status = 'New';
        sa.PostalCode = '32116';
        sa.ServiceTerritoryId = st2.Id;
        sa.Country='US';
        sa.Parent_WOLI__c = woli.id;
        sa.FSL__Scheduling_Policy_Used__c = pol.Id;
        sa.FSSK__FSK_Work_Order__c = wo.id ;
        //sa.SchedStartTime = system.now()+ 1 ;
        //sa.SchedEndTime = system.now() + 2 ;
        sa.EarliestStartTime =  Date.today() ;
        sa.DueDate = Date.today()+7 ;
        sa.Duration = 2;
        sa.DurationType = 'Hours';
		sa.ParentRecordId = WOLI.Id;            
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = TRUE;
        insert sa;
          
        FlowSchedulerGetSlots.Request getSlotsReq = newGetSlotsReq(sa.Id, pol.Id);
        List<FlowSchedulerGetSlots.Response> response = FlowSchedulerGetSlots.getSlots(new List<FlowSchedulerGetSlots.Request>{getSlotsReq});

        BookingSlot slot = new BookingSlot();
        slot.grade = 90;
        slot.start = Datetime.now();
        slot.finish = Datetime.now()+20;
		
        FlowSchedulerScheduleAppointment.Request scheduleApptReq = newScheduleAppointmentReq(sa.Id, slot.start.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''), slot.finish.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''), pol.Id);
        FlowSchedulerScheduleAppointment.scheduleAppointment(new List<FlowSchedulerScheduleAppointment.Request>{scheduleApptReq});

        FlowSchedulerController.changeTimeZone(Datetime.now(), UserInfo.getTimeZone());
        FlowSchedulerController.getArrivalWindowTime('2022-05-15T21:00:00.000Z');
        
        Test.stopTest();    
        }
        
     }

    public static FlowSchedulerGetSlots.Request newGetSlotsReq(Id saId, Id polId) {
        FlowSchedulerGetSlots.Request getSlotsReq = new FlowSchedulerGetSlots.Request();
        getSlotsReq.serviceAppointmentId = saId;
        getSlotsReq.schedulingPolicyId = polId;            
        return getSlotsReq;
    }

    public static FlowSchedulerScheduleAppointment.Request newScheduleAppointmentReq(Id saId, String startString, String endString, Id polId) {
        FlowSchedulerScheduleAppointment.Request scheduleApptReq = new FlowSchedulerScheduleAppointment.Request();
        scheduleApptReq.serviceAppointmentId = saId;
        scheduleApptReq.schedulingPolicyId = polId;   
        scheduleApptReq.startTimeString = startString;
        scheduleApptReq.endTimeString = endString;         
        return scheduleApptReq;
    }
}