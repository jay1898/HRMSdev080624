@isTest
public class PIESUpdateInstallEmailonWOLITest {
    static testMethod void testMethod2(){
        User u = TestUtil.createUser(true);
         system.runAs(u){
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
        
              Id srRTId = Schema.SObjectType.ServiceResource.recordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
            // Create 1st Service Resource
            ServiceResource sr1 = TestUtil.createServiceResource('TestPIESOne', u.Id, branch.Id, bf.Id, false);
            sr1.RecordTypeId = srRTId ; 
            sr1.Installer_Third_Party__c = TRUE; 
            Insert sr1;
             
              ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember1(sr1.Id, st.Id, false);
        	stm.TerritoryType = 'P';
        	Insert stm ;
             
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Install', 'Hours', 2,true);
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
        insert q ;
        
        //create group
        Group gp = new Group();
        gp.name = 'PIES ST 1';
        Insert gp; 
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo.PostalCode = '32926';
        wo.ServiceTerritoryId = st.Id;
        wo.Legacy_Incident_Number__c = '4546';
        
        WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
             
         WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI', wt.Id, wo.Id, false) ;
      WOLI.PostalCode = '32926';
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER= false;
        Insert WOLI;
        
       ServiceAppointment sa = TestUtil.createServiceAppointment('OV_Install', 'Test', ac.Id, opp.Id, WOLI.Id, false);
       sa.Status = 'Scheduled';
       sa.ServiceTerritoryId = ST.Id;
       sa.Country='US';
       sa.Parent_WOLI__c = woli.id;
       sa.FSSK__FSK_Work_Order__c = wo.id ;
       sa.FSSK__FSK_Assigned_Service_Resource__c  = sr1.Id;
       ServiceAppointmentTriggerHandler.RUN_TRIGGER = FALSE;
       insert sa;
           
       AssignedResourceTriggerHandler.RUN_TRIGGER = FALSE;      
       AssignedResource ar = TestUtil.createAssignedResource(sr1.Id,sa.Id, true); 
       AssignedResourceTriggerHandler.RUN_TRIGGER = FALSE; 
     
            Database.executeBatch(new PIESUpdateInstallEmailonWOLI(),2000);
        Test.stopTest();     

         }
        
    }

}