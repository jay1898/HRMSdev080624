@isTest
public class ShareSAWOPIESContForCommUserBatch_T {
    /*static testMethod void testMethod1() 
    {
        
        Account acc = TestUtil.createBranchAccount('Branch Account', true);
        
        
        Contact con = TestUtil.createContact(acc.Id,'TestFirst Name1',false);
        con.LastName = 'Test LN';
        con.FirstName = 'Test FN';
        insert con;
        
        Contact con2 = TestUtil.createContact(acc.Id,'TestFirst Name2',false);
        con2.LastName = 'Test LN1';
        con2.FirstName = 'Test FN1';
        insert con2;
        TestUtil.insertUser(con.Id,con2.Id);
        List<User> allUser = [Select Id From User];
        User u1 = new User();
        User u2 = new User();
        if(!allUser.isEmpty()){
            u1 = allUser[0];
            u2 = allUser[1];
        }
        system.debug('u1: '+system.JSON.serialize(u1));
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
        stZone.Lead_Receiver__c = u1.id;
        insert stZone;
        
        //ZipCode Level Territory
        ServiceTerritory stZip = TestUtil.createSubChildServiceTerritory('Sub Child3', stZone.Id, oh.Id, false);
        stZip.IsActive= true;
        stZip.PostalCode = '30000';
        insert stZip;
        ServiceTerritory stZone1 = TestUtil.createChildServiceTerritory('Child5', stZip.Id, oh.Id, false);
        stZone1.IsActive= true;
        stZone1.PostalCode = '70000';
        stZone1.Lead_Receiver__c = u1.id;
        insert stZone1;
        String replacementRecID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Replacement').getRecordTypeId();
        Opportunity testOpportunity = new Opportunity(Name='test op',StageName='New',Amount=10,CloseDate=system.today() + 30,AccountId=acc.Id, Status__c='New' );
        testOpportunity.RecordTypeId = replacementRecID; 
        insert testOpportunity ;
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', acc.Id, testOpportunity.Id, testOpportunity.Id, false);
        sa.ServiceTerritoryId = stZone.Id;
        sa.Country='US';
        insert sa;
        
        ServiceResource sr = TestUtil.createServiceResource('Test', u1.Id, branch.Id, bf.Id, false);
        sr.Ranker__c = 10.0;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        sr.Manager__c = true;
        insert sr;
        
        ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember(sr.Id, stZone.Id, true);
        
         // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        update parentST;
        ServiceTerritory childst = TestUtil.createChildServiceTerritory('Child Territory',parentST.Id, oh.Id, true);
        AssignedResource ar = TestUtil.createAssignedResource(sr.Id,sa.Id, true);
        
        ShareSAWOPIESContForCommUserBatch b = new ShareSAWOPIESContForCommUserBatch(u1.Id); 
        database.executebatch(b,1);
        
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
            
            List<String> lstUserIds = new List<String>();
            lstUserIds.add(usr2.Id);
            ShareSAWOPIESContForCommUserBatch b = new ShareSAWOPIESContForCommUserBatch(lstUserIds); 
            database.executebatch(b,1);
            test.stopTest();
        }
    }
    
}