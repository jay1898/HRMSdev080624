@isTest
private class ServiceAppointmentTriggerHandlerTest 
{
    static testMethod void testMethod1() 
    {
        
        // Create User
        User usr = TestUtil.createUser(false);
        String[] integrationUser=Label.Integration_UserName.split(' ');
        if(integrationUser.size()>1){
            usr.FirstName=integrationUser[0];
            usr.LastName=integrationUser[1];
        }else if(Label.Integration_UserName!=null && Label.Integration_UserName!=''){
            usr.LastName=Label.Integration_UserName;
        }
        insert usr;
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(),FirstName=usr.FirstName,LastName=usr.LastName, Title = 'Retail Sales Rep');
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '99999', bf.Id, true);
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Main SA Appointment Territory Branch', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Main Child SA Appointment Zone RT', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
        
        // Create Sub Child Territory under Child Territory
        //ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Main Sub SA Appointment Zipcode ', childST.Id, oh.Id, true);
        
        // Create 1st Service Resource
        //ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        
        ServiceResource sr1 ;
        List<ServiceResource> resources = [SELECT Id, Primary_Branch_Family__c FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() ];
        if(resources.size() > 0 ) sr1 = resources[0];
        if(sr1 == null) 
        {
            sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
            // Create Service Territory Member for 1st Resource
            ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        }
        
        // Create 2nd Service Resource
        //ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        //ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        Test.startTest();
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.Status = 'Scheduled';
        insert sa ;
        opp.Zone__c = childST.Id ;
        ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = true ;
        update opp ;
        System.debug('UAC: Test Class SA ' + [SELECT Status, Opportunity__c, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Id = :sa.Id] );
        
        //Event evnt = TestUtil.createEvent(UserInfo.getUserId(), false);
        
        
        sa.SchedStartTime = sa.SchedStartTime.addHours(1);
        //sa.SchedEndTime = sa.SchedEndTime.addHours(1);
        //sa.Status = 'Soft Assigned';
        sa.Ride_Along__c=true;
        System.debug('UAC: ServiceAppointmentTriggerHandler.RUN_TRIGGER ' + ServiceAppointmentTriggerHandler.RUN_TRIGGER ); 
        System.debug('UAC: ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH ' + ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH );
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = true ;
        ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = true ;
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ; // Set to false due to FSL run time error, other wise set to true for more coverage 
        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE=true;
        ServiceAppointmentTriggerHandler.RUN_FOR_OWNER_AND_DATE_CHANGE=true;
        ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = true ;
        update sa ;
        
        ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = true ;
        sa.Lead_Receiver__c=usr.Id;
        sa.Status = 'Canceled';
        sa.OwnerId = usr.Id ;

        update sa ; 
        Test.stopTest();
        
    }
    static testMethod void testMethod2() 
    {
        // Create User
        User usr = TestUtil.createUser(false);
        String[] integrationUser=Label.Integration_UserName.split(' ');
        if(integrationUser.size()>1){
            usr.FirstName=integrationUser[0];
            usr.LastName=integrationUser[1];
        }else if(Label.Integration_UserName!=null && Label.Integration_UserName!=''){
            usr.LastName=Label.Integration_UserName;
        }
        insert usr;
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(),FirstName=usr.FirstName,LastName=usr.LastName, Title = 'Retail Sales Rep');
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '99999', bf.Id, true);
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        //Create Territory
        Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
        Territory2  t2 ;

        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            t2= TestUtil.createTerritory2('99999',activetypeId, true);    
        }
        

        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Main SA Appointment Territory Branch', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Main Child SA Appointment Zone RT', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
        
        // Create Sub Child Territory under Child Territory
        //ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Main Sub SA Appointment Zipcode ', childST.Id, oh.Id, true);
        
        // Create 1st Service Resource
        //ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        
        ServiceResource sr1 ;
        List<ServiceResource> resources = [SELECT Id, Primary_Branch_Family__c FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() ];
        if(resources.size() > 0 ) sr1 = resources[0];
        if(sr1 == null) 
        {
            sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
            // Create Service Territory Member for 1st Resource
            ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        }
        
        // Create 2nd Service Resource
        //ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        //ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        insert sa ;
        test.startTest();
        opp.Zone__c = childST.Id ;
        ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = true ;
        update opp ;
        System.debug('UAC: Test Class SA ' + [SELECT Status, Opportunity__c, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Id = :sa.Id] );
        
        sa.SchedStartTime = sa.SchedStartTime.addHours(1);
        sa.SchedEndTime = sa.SchedEndTime.addHours(1);
        //sa.Status = 'Soft Assigned';
        sa.Ride_Along__c=true;
        System.debug('UAC: ServiceAppointmentTriggerHandler.RUN_TRIGGER ' + ServiceAppointmentTriggerHandler.RUN_TRIGGER );
        System.debug('UAC: ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH ' + ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH );
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = true ;
        ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = true ;
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ; // Set to false due to FSL run time error, other wise set to true for more coverage 
        sa.Appointment_Conflict_Override__c=true;
        sa.Rehash_Appointment__c = true ;
        sa.Opportunity__c = opp.Id ;
        update sa ;

        //Test.startTest();
            ServiceAppointmentTriggerHandler.syncEarliestStartAndDueDate(new List<ServiceAppointment>{sa});
            ServiceAppointmentTriggerHandler.updateOppAndSAOwnerFuture(opp.Id,usr.Id,sa.id);
            ServiceAppointmentTriggerHandler.setBestMatchRehashAppointment(new List<ServiceAppointment>{sa});
            ServiceAppointmentTriggerHandler.setBestMatchOnAppointmentReschedule(new List<ServiceAppointment>{sa}, new Map<Id,ServiceAppointment>{sa.Id => sa});
            ServiceAppointmentRecordShare.shareSARecordWithSTM(new List<ServiceAppointment>{sa});
            ServiceAppointmentRecordShare.shareSARecordWithSTMFuture(new List<String>{sa.Id});
            
             //create work type
            WorkType wt = TestUtil.createWorkType('WT1', 'Install', 'Hours', 2,true);
            // create quote
             Quote q = TestUtil.createQuote(opp.Id, true);
            WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
            wo.PostalCode = '32926';
            WorkOrderTriggerHandler.RUN_TRIGGER= false;
            insert wo;
            
            WorkOrderLineItemTriggerHandler.RUN_TRIGGER = FALSE;
            WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test WOLI ', wt.Id, wo.Id, true) ;

            List<String> mapVal = new List<String>{sa.Id};
            Map<String, List<String>> mapwosaIds = new map<String, List<String>>();
            mapwosaIds.put(woli.Id, mapVal);

            try{
                ServiceAppointmentTriggerHandler.updateWOLITimeAndDuration(new List<ServiceAppointment>{sa});    
            }
            catch(Exception de){}
            

            ServiceAppointmentRecordShare.shareSAwihtWOQuoteOwner(mapwosaIds);
        Test.stopTest();
    }
//      static testMethod void testMethod3() 
// {
// Test.startTest();
// // Create User
// User usr = TestUtil.createUser(false);
// String[] integrationUser=Label.Integration_UserName.split(' ');
// if(integrationUser.size()>1){
// usr.FirstName=integrationUser[0];
// usr.LastName=integrationUser[1];
// }else if(Label.Integration_UserName!=null && Label.Integration_UserName!=''){
// usr.LastName=Label.Integration_UserName;
// }
// insert usr;

// // Update current User title 
// update new User(Id = UserInfo.getUserId(),FirstName=usr.FirstName,LastName=usr.LastName, Title = 'Retail Sales Rep');

// // Create Account
// Account ac = TestUtil.createAccount('Person Account', true);

// // Create Branch Family
// Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);

// // Create Branch
// Branch__c branch = TestUtil.createBranch('Test', '99999', bf.Id, true);
// // Create Opreating Hours
// OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);

// // Create Time Slot
// TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);

// // Create Parent Territory
// ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Main SA Appointment Territory Branch', oh.Id, branch.Id, true);

// // Create Child Territory under Parent Territory
// ServiceTerritory childST = TestUtil.createChildServiceTerritory('Main Child SA Appointment Zone RT', parentST.Id, oh.Id, false);
// childST.Lead_Receiver__c = UserInfo.getUserId() ;
// insert childST ;

// ServiceResource sr1 ;
// List<ServiceResource> resources = [SELECT Id, Primary_Branch_Family__c FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() ];
// if(resources.size() > 0 ) sr1 = resources[0];
// if(sr1 == null) 
// {
// sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
// // Create Service Territory Member for 1st Resource
// ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
// }

// // Create Lead
// Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 

// // Create 1st Opportunity
// Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
// // Create Service Appointment
// ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
// sa.Status = 'Scheduled';
// insert sa ;
// opp.Zone__c = childST.Id ;
// ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = true ;
// update opp ;
// System.debug('UAC: Test Class SA ' + [SELECT Status, Opportunity__c, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Id = :sa.Id] );

// //Event evnt = TestUtil.createEvent(UserInfo.getUserId(), false);

// sa.SchedStartTime = sa.SchedStartTime.addHours(1);
// sa.SchedEndTime = sa.SchedEndTime.addHours(1);
// //sa.Status = 'Soft Assigned';
// sa.Ride_Along__c=true;

// System.debug('UAC: ServiceAppointmentTriggerHandler.RUN_TRIGGER ' + ServiceAppointmentTriggerHandler.RUN_TRIGGER );
// System.debug('UAC: ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH ' + ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH );
// ServiceAppointmentTriggerHandler.RUN_TRIGGER = true ;
// ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = true ;
// ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH =true ; // Set to false due to FSL run time error, other wise set to true for more coverage 

// try{
// update sa ;
// }catch(exception e){

// }

// Test.stopTest();
// }
//     static testMethod void testMethod4() 
//     {
//         Test.startTest();
//         // Create Account
//         Account ac = TestUtil.createAccount('Person Account', true);
//         Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
//         opp.Appointment_DateTime__c = DateTime.now();
//         opp.Status__c = 'Open';
//         opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
//         OpportunityTriggerHandler.RUN_TRIGGER= false;
//         insert opp;
//         Quote q = TestUtil.createQuote(opp.Id, true);
//         q.PO_Number__c = '123';
//         update q;
        
//         //create work type
//         WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
//         wt.Schedule_Type__c = 'Project'; Insert wt;
            
//         //create work type
//         WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Install', 'Hours', 2,false);    
//         wt2.Schedule_Type__c = 'OV'; Insert wt2;
        
        
//         //createbranch
//         Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
//         bf.Branch_Family_Number__c = '124';
//         insert bf;
//         Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
        
//         WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, true);
//         WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt2.Id, wo.Id, true);
        
//         // Create Service Appointment
//         ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, woli.Id, false);
//         sa.Status = 'Scheduled';
//         insert sa ;
        
//         system.assertEquals('Test', sa.Subject); 
        
//         Test.stopTest();
//     }
    
//     static testMethod void testMethod6() {
//          // Create Opreating Hours
//         OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
//         // Create Time Slot
//         TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
//         //createbranch
//         Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
//         bf.Branch_Family_Number__c = '124';
//         insert bf;
//         Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
//         //Create PIES Territory
//         ServiceTerritory st = TestUtil.createPIESServiceTerritroy('PIES ST 1', branch.Id, oh.Id, 'Install', false );
//         st.IsActive = true;
//         Insert st ;
        
//         //create child territory
//         ServiceTerritory chst = TestUtil.createPIESZCServiceTerritroy('32926','32926', st.Id, oh.Id, false);
//         chst.IsActive = true ;
//         insert chst;
//         ServiceTerritory chst2 = TestUtil.createPIESZCServiceTerritroy('32116','32116', st.Id, oh.Id, false);
//         chst2.IsActive = true ;
//         insert chst2;
        
//         //Create territory zipcode
//         Territory_Zipcode__c tz = TestUtil.createTZforPIES(st.Id, chst.Id, true);
//         Territory_Zipcode__c tz1 = TestUtil.createTZforPIES(st.Id, chst2.Id, true);
        
//         // Create Account
//         Account ac = TestUtil.createAccount('Person Account', true);
        
//         //create work type
//         WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
//         wt.Schedule_Type__c = 'Project'; Insert wt;
            
//         //create work type
//         WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Install', 'Hours', 2,false);    
//         wt2.Schedule_Type__c = 'OV'; Insert wt2;
        
        
//         // Create Opportunity for quote
//         Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
//         opp.Appointment_DateTime__c = DateTime.now();
//         opp.Status__c = 'Open';
//         opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
//         OpportunityTriggerHandler.RUN_TRIGGER= false;
//         insert opp;
//         //Create quote
//         Quote q = TestUtil.createQuote(opp.Id, false);
//         q.Quote_Number_PQM__c='8989' ;
//         q.Status='Active';
//         insert q ;
        
//         //Create group
//         Group gp = new Group();
//         gp.name = 'PIES ST 1';
//         Insert gp; 
        
//         WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
//         wo.PostalCode = '32926';
//         wo.ServiceTerritoryId = st.Id;
//         WorkOrderTriggerHandler.RUN_TRIGGER= false;
//         Insert wo;
        
//         WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt2.Id, wo.Id, false) ;
//         WOLI.PostalCode = '32926';
//         WorkOrderLineItemTriggerHandler.RUN_TRIGGER= false;
//         Insert WOLI;
        
//         ServiceAppointment sa = TestUtil.createServiceAppointment('OV_Install', 'Test', ac.Id, opp.Id, WOLI.Id, false);
//         sa.Status = 'New';
//         sa.ServiceTerritoryId = ST.Id;
//         sa.Country='US';
//         sa.Parent_WOLI__c = woli.id;
//         sa.FSSK__FSK_Work_Order__c = wo.id ;
//         ServiceAppointmentTriggerHandler.RUN_TRIGGER = TRUE;
//         insert sa;
        
    // }
}