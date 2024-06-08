@isTest
public class AssignedResourceTriggerHandlerTest {
  
    /*@isTest
    public static void AssignedResourceTriggerHandlerMethod(){
        User u = TestUtil.createUser(true);
        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Phoenix';
        insert oh;
        
        //Parent Level Territory
        ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
        stParent.PostalCode = '10000';
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '20000';
        stZone.Lead_Receiver__c = u.id;
        insert stZone;
        
        //ZipCode Level Territory
        ServiceTerritory stZip = TestUtil.createSubChildServiceTerritory('Sub Child3', stZone.Id, oh.Id, false);
        stZip.IsActive= true;
        stZip.PostalCode = '30000';
        insert stZip;
        
        ServiceTerritory stZone1 = TestUtil.createChildServiceTerritory('Child5', stZip.Id, oh.Id, false);
        stZone1.IsActive= true;
        stZone1.PostalCode = '70000';
        stZone1.Lead_Receiver__c = u.id;
        insert stZone1;
        
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        insert sr;
        
        DateTime startDateTime = DateTime.now();
        DateTime endDateTime = startDateTime.addHours(24);
        
        ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember(sr.Id, stZone.Id, true);
        
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, true);
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', acc.Id, testOpportunity.Id, testOpportunity.Id, false);
        sa.ServiceTerritoryId = stZone.Id;
        sa.Country='US';
        insert sa;
        
        AssignedResource ar = TestUtil.createAssignedResource(sr.Id,sa.Id, true);
        
        Long dt1Long = sa.SchedStartTime.getTime();
        Long dt2Long = sa.SchedEndTime.getTime();
        Integer durationMin = Integer.valueOf((dt2Long - dt1Long)/(1000*60));
        DateTime startDate=sa.SchedStartTime.addMinutes(-(durationMin-30));
        startDate=startDate.addSeconds(UserInfo.getTimeZone().getOffset(startDate)/1000);
        startDate=startDate.addSeconds(-(startDate.second()));
        
        List<AssignedResource> assList = new List<AssignedResource>();
        assList.add(ar);
        update assList;
        
    }*/

    
    
    public static testmethod void PIEStestmethod1() {
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser){
            Profile PIESPrId = [SELECT Id FROM Profile where Name = 'PIES Installer Contractor'];
            Profile PIESPrId2 = [SELECT Id FROM Profile where Name = 'PIES Manager Contractor'];
            Id ConRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();
            
            UserRole ur = new UserRole(Name = 'CEO');
            insert ur;
            // Create User
            User us = TestUtil.createUser(false);
            us.UserRoleId =  ur.id; //'00E3i000000cZOPEA2'; //00E3i000000cZOPEA2
            insert us;
            
            // Create Account
            Account ac = TestUtil.createAccount('Person Account', false);
            ac.OwnerId = us.id;
            insert ac ;
            
            Account brac = TestUtil.createBranchAccount('Branch Account', false);
            brac.OwnerId =  us.id;
            insert brac ;
            
            //Create Contact
            Contact c = new Contact();
            c.LastName = 'Test LN';
            c.FirstName = 'Test FN';
            c.RecordTypeId = ConRTId ;
            c.AccountId = brac.Id;
            c.Email = 'TestLN@gm.com';
            insert c;
            
            User usr = TestUtil.createPIESUser(PIESPrId.Id, c.id, true);
            c.email = usr.email;
            update c ;
            
            //Create Contact
            Contact c2 = new Contact();
            c2.LastName = 'Test LN2';
            c2.FirstName = 'Test FN2';
            c2.RecordTypeId = ConRTId ;
            c2.AccountId = brac.Id;  
            c2.Email = 'TestLN2@gm.com';
            insert c2;
            
            User usr2 = TestUtil.createPIESUser(PIESPrId2.Id,c2.Id, true);
            c2.email = usr2.email;
            update c2 ;
            
            //create work type
            WorkType wt = TestUtil.createWorkType('WT1', 'Install', 'Hours', 2,true);
            // Create Branch Family
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
    
            // Create Branch
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            
            // Create Opreating Hours
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
    
            // Create Time Slot
            TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
    
           
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
            ServiceResource sr1 = TestUtil.createServiceResource('TestPIESOne', usr.Id, branch.Id, bf.Id, false);
            sr1.RecordTypeId = srRTId ; 
            Insert sr1;
            
            ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember1(sr1.Id, st.Id, false);
          stm.TerritoryType = 'P';
          Insert stm ;
            
            // Create Opportunity for quote
            Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
            opp.Appointment_DateTime__c = DateTime.now();
            opp.Status__c = 'Open';
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
            OpportunityTriggerHandler.RUN_TRIGGER= false;
            insert opp;
            
      Test.startTest() ;  
              Quote q = TestUtil.createQuote(opp.Id, true);
             
            WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.id, false); //0Q03i0000002vXuCAI
            wo.PostalCode = '32926';
            wo.ServiceTerritoryId = st.Id;
            WorkOrderTriggerHandler.RUN_TRIGGER= false;
            Insert wo;
            
            WorkOrderLineItemTriggerHandler.RUN_TRIGGER = FALSE;
            WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt.Id, wo.Id, true) ;
            
            ServiceAppointment sa = TestUtil.createPIESServiceAppointment('OV_Install', 'TestPIES', ac.Id, woli.Id, false);
            sa.Status = 'Scheduled';
            sa.ServiceTerritoryId = ST.Id;
            sa.Country='US';
            sa.Parent_WOLI__c = woli.id;
            sa.FSSK__FSK_Work_Order__c = wo.id ;
            sa.SchedStartTime = System.now();
            sa.SchedEndTime = system.now() + 1;
            ServiceAppointmentTriggerHandler.RUN_TRIGGER = FALSE;
            insert sa;
            
            ServiceAppointmentShare saShare = new ServiceAppointmentShare();
            saShare.ParentId = sa.Id;
            saShare.UserOrGroupId = us.Id; 
            saShare.AccessLevel = 'Edit';
            saShare.RowCause = 'Manual';
            insert saShare;
                
            AssignedResource ar = TestUtil.createAssignedResource(sr1.Id,sa.Id, true);
            delete ar;
          test.stopTest();
        }
    }
   /* public static testmethod void PIEStestmethodDelete() {
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser){
            Profile PIESPrId = [SELECT Id FROM Profile where Name = 'PIES Installer Contractor'];
            Profile PIESPrId2 = [SELECT Id FROM Profile where Name = 'PIES Manager Contractor'];
            Id ConRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();
            
            UserRole ur = new UserRole(Name = 'Manager');
            insert ur;
            // Create User
            User us = TestUtil.createUser(false);
            us.UserRoleId =   ur.Id; //'00E3i000000cZOPEA2'; // // //00E3i000000caqv
            insert us;
            
            // Create Account
            Account ac = TestUtil.createAccount('Person Account', false);
            ac.OwnerId = us.id;
            insert ac ;
            
            Account brac = TestUtil.createBranchAccount('Branch Account', false);
            brac.OwnerId =  us.id;
            insert brac ;
            
            //Create Contact
            Contact c = new Contact();
            c.LastName = 'Test LN';
            c.FirstName = 'Test FN';
            c.RecordTypeId = ConRTId ;
            c.AccountId = brac.Id;
            c.Email = 'TestLN@gm.com';
            insert c;
            
            User usr = TestUtil.createPIESUser(PIESPrId.Id, c.id, true);
            c.email = usr.email;
            update c ;
            
            //Create Contact
            Contact c2 = new Contact();
            c2.LastName = 'Test LN2';
            c2.FirstName = 'Test FN2';
            c2.RecordTypeId = ConRTId ;
            c2.AccountId = brac.Id;  
            c2.Email = 'TestLN2@gm.com';
            insert c2;
            
            User usr2 = TestUtil.createPIESUser(PIESPrId2.Id,c2.Id, true);
            c2.email = usr2.email;
            update c2 ;
            
       
            
             //create work type
            WorkType wt = TestUtil.createWorkType('WT1', 'Install', 'Hours', 2,true);
            // Create Branch Family
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
    
            // Create Branch
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            
            // Create Opreating Hours
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
    
            // Create Time Slot
            TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
    
           
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
            ServiceResource sr1 = TestUtil.createServiceResource('TestPIESOne', usr.Id, branch.Id, bf.Id, false);
            sr1.RecordTypeId = srRTId ; 
            Insert sr1;
            
            ServiceResource sr2 = TestUtil.createServiceResource('TestPIES', usr2.Id, branch.Id, bf.Id, false);
            sr2.RecordTypeId = srRTId ; 
            Insert sr2;
            
            ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember1(sr1.Id, st.Id, false);
          stm.TerritoryType = 'P';
          Insert stm ;
            
            ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember1(sr2.Id, st.Id, false);
          stm2.TerritoryType = 'P';
          Insert stm2 ;
            
            // Create Opportunity for quote
            Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
            opp.Appointment_DateTime__c = DateTime.now();
            opp.Status__c = 'New';
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Replacement').getRecordTypeId();
            OpportunityTriggerHandler.RUN_TRIGGER= false;
            insert opp;
            
       Test.startTest(); 
            Quote q = TestUtil.createQuote(opp.Id, true);
            
            WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id , false); //0Q03i0000002vXuCAI
            wo.PostalCode = '32926';
            wo.ServiceTerritoryId = st.Id;
            WorkOrderTriggerHandler.RUN_TRIGGER= false;
            Insert wo;
            
            WorkOrderLineItemTriggerHandler.RUN_TRIGGER = FALSE;
            WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt.Id, wo.Id, true) ;
            
            ServiceAppointment sa = TestUtil.createPIESServiceAppointment('OV_Install', 'TestPIES', ac.Id, woli.Id, false);
            sa.Status = 'Scheduled';
            sa.ServiceTerritoryId = ST.Id;
            sa.Country='US';
            sa.Parent_WOLI__c = woli.id;
            sa.FSSK__FSK_Work_Order__c = wo.id ;
            sa.SchedStartTime = System.now();
            sa.SchedEndTime = system.now() + 1;
            ServiceAppointmentTriggerHandler.RUN_TRIGGER = FALSE;
            insert sa;
            
            ServiceAppointmentShare saShare = new ServiceAppointmentShare();
            saShare.ParentId = sa.Id;
            saShare.UserOrGroupId = us.Id; 
            saShare.AccessLevel = 'Edit';
            saShare.RowCause = 'Manual';
            insert saShare;
                
            AssignedResource ar = TestUtil.createAssignedResource(sr1.Id,sa.Id, true);
            ar.ServiceResourceId = sr2.Id ; 
            //WorkOrderLineItemTriggerHandler.RUN_TRIGGER = FALSE;
            AssignedResourceTriggerHandler.RUN_TRIGGER = FALSE;
            update ar;
          test.stopTest();
        }
    } 
    */
     public static testmethod void PIEStestmethod12() {
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser){
            Profile PIESPrId = [SELECT Id FROM Profile where Name = 'PIES Manager Contractor'];
            Profile PIESPrId2 = [SELECT Id FROM Profile where Name = 'PIES Manager Contractor'];
            Id ConRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();
            
            UserRole ur = new UserRole(Name = 'CEO');
            insert ur;
            // Create User
            User us = TestUtil.createUser(false);
            us.UserRoleId =  ur.id; //'00E3i000000cZOPEA2'; //00E3i000000cZOPEA2
            insert us;
            
            // Create Account
            Account ac = TestUtil.createAccount('Person Account', false);
            ac.OwnerId = us.id;
            insert ac ;
            
            Account brac = TestUtil.createBranchAccount('Branch Account', false);
            brac.OwnerId =  us.id;
            insert brac ;
            
            //Create Contact
            Contact c = new Contact();
            c.LastName = 'Test LN';
            c.FirstName = 'Test FN';
            c.RecordTypeId = ConRTId ;
            c.AccountId = brac.Id;
            c.Email = 'TestLN@gm.com';
            insert c;
            
            User usr = TestUtil.createPIESUser(PIESPrId.Id, c.id, true);
            c.email = usr.email;
            update c ;
            
            //Create Contact
            Contact c2 = new Contact();
            c2.LastName = 'Test LN2';
            c2.FirstName = 'Test FN2';
            c2.RecordTypeId = ConRTId ;
            c2.AccountId = brac.Id;  
            c2.Email = 'TestLN2@gm.com';
            insert c2;
            
            User usr2 = TestUtil.createPIESUser(PIESPrId2.Id,c2.Id, true);
            c2.email = usr2.email;
            update c2 ;
            
            //create work type
            WorkType wt = TestUtil.createWorkType('WT1', 'Install', 'Hours', 2,true);
            // Create Branch Family
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
    
            // Create Branch
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            
            // Create Opreating Hours
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
    
            // Create Time Slot
            TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
    
           
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
            ServiceResource sr1 = TestUtil.createServiceResource('TestPIESOne', usr.Id, branch.Id, bf.Id, false);
            sr1.RecordTypeId = srRTId ; 
            Insert sr1;
            
            ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember1(sr1.Id, st.Id, false);
          stm.TerritoryType = 'P';
          Insert stm ;
            
            // Create Opportunity for quote
            Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
            opp.Appointment_DateTime__c = DateTime.now();
            opp.Status__c = 'Open';
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
            OpportunityTriggerHandler.RUN_TRIGGER= false;
            insert opp;
            
      Test.startTest() ;  
              Quote q = TestUtil.createQuote(opp.Id, true);
             
            WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.id, false); //0Q03i0000002vXuCAI
            wo.PostalCode = '32926';
            wo.ServiceTerritoryId = st.Id;
            WorkOrderTriggerHandler.RUN_TRIGGER= false;
            Insert wo;
            
            WorkOrderLineItemTriggerHandler.RUN_TRIGGER = FALSE;
            WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt.Id, wo.Id, true) ;
            
            ServiceAppointment sa = TestUtil.createPIESServiceAppointment('OV_Install', 'TestPIES', ac.Id, woli.Id, false);
            sa.Status = 'Scheduled';
            sa.ServiceTerritoryId = ST.Id;
            sa.Country='US';
            sa.Parent_WOLI__c = woli.id;
            sa.FSSK__FSK_Work_Order__c = wo.id ;
            sa.SchedStartTime = System.now();
            sa.SchedEndTime = system.now() + 1;
            ServiceAppointmentTriggerHandler.RUN_TRIGGER = FALSE;
            insert sa;
            
            ServiceAppointmentShare saShare = new ServiceAppointmentShare();
            saShare.ParentId = sa.Id;
            saShare.UserOrGroupId = us.Id; 
            saShare.AccessLevel = 'Edit';
            saShare.RowCause = 'Manual';
            insert saShare;
                
            AssignedResource ar = TestUtil.createAssignedResource(sr1.Id,sa.Id, true);
            delete ar;
          test.stopTest();
        }
    }
   public static testmethod void testmethod1()
    {
        // Create User
        User usr = TestUtil.createUser(true);

        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);

        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);

        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);

        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);

        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);

        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);

        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, true);

        Id srRTId = Schema.SObjectType.ServiceResource.recordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', usr.Id, branch.Id, bf.Id, false);
        sr1.RecordTypeId = srRTId ;Insert Sr1;

        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 

        // Create 2nd Service Resource
        //ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);

        // Create 2nd Service Territory Member for 2nd Resource
        //ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 

        Opportunity opp = TestUtil.createOpportunity('New Opp1', ac.Id, usr.Id, true);
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, opp.Id, false);
        sa.Status = 'Soft Assign';
        sa.ServiceTerritoryId = childST.Id;
        sa.Country='US';
        sa.Status='Scheduled';
        insert sa;

        AssignedResource ar = TestUtil.createAssignedResource(sr1.Id,sa.Id, true);
    }  
}