@isTest
public class CreateSWOForQuoteBatchTest {
    static testMethod void newInstallWO(){
        
         // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
        branch.Is_Available_for_Work_Order__c=true;
        insert branch;
        
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
        // create Work Order
        WorkOrder wo1 = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, null, false);
        wo1.OwnerId = u.Id;
        insert wo1;
        
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);    
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Project'; Insert wt;
        //create work type
        WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Install', 'Hours', 2,false);
        wt2.Schedule_Type__c = 'OV';   Insert wt2;
        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Project_Coordinator__c = true;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.Account_Branch_Profile__c=abp.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        //Create quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c= '14168876' ;
        q.Status='Active';
        insert q ;
        
        //create group
        Group gp = new Group();
        gp.name = 'PIES ST 1';
        Insert gp; 
        system.assertEquals(q.Work_Order__c,null);
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo.PostalCode = '32926';
        wo.ServiceTerritoryId = st.Id; 
        WO.Quote__c=q.Id;
        //WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        test.startTest();
        CreateSWOForQuoteBatch b = new CreateSWOForQuoteBatch(); 
        database.executebatch(b,100);
        test.stopTest();
        q=[Select id,work_order__c from quote where id=:q.Id];
        system.assertNotEquals(q.Work_Order__c,null);
    }
    
}