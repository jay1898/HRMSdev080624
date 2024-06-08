@isTest
public class ServiceResourceTriggerHandlerTest {
	@isTest
    public static void ServiceResourceTriggerTest1(){
         // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        User u1 = TestUtil.createUser(false);
        u1.username=u1.username+'_u2';
        u1.Email='u2_'+u1.Email;
        insert u1;
        User u2 = TestUtil.createUser(false);
        u2.username=u2.username+'_u3';
        u2.Email='u3_'+u2.Email;
        insert u2;

        // Create Account
    	Account ac = TestUtil.createAccount('Person Account', true);

        // Create Branch Family
    	Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch_Grouping__c bf1 = TestUtil.createBranchGrouping('BranchGrouping_2', true);
        Branch_Grouping__c bf2 = TestUtil.createBranchGrouping('BranchGrouping_3', true);

         // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        Branch__c branch1 = TestUtil.createBranch('Test1', '101', bf1.Id, true);
        Branch__c branch2 = TestUtil.createBranch('Test2', '102', bf2.Id, true);
        
         // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Ranker__c = 10.0;
        insert sr;
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', u1.Id, branch.Id, bf.Id, false);
        sr1.Ranker__c = 11.0;
        sr1.IsActive=false;
        insert sr1;
        ServiceResource sr2 = TestUtil.createServiceResource('Mayank', u2.Id, branch.Id, bf.Id, false);
        sr2.Ranker__c = 10.0;
        insert sr2;

     
        
        sr.Name = 'test1';
        sr.Primary_Branch_Family__c = bf.Id;
        update sr;
        test.startTest();
        try{
            sr.Ranker__c = null;
            sr.Override_Replacement_Rep__c=true;
            update sr;
        }catch(EXCEPTION ex){
            system.assert(ex.getMessage().contains(System.Label.Ranking_Mandatory));
        }
        
        try{
            sr.Primary_Branch_Family__c = bf1.Id;
            sr.Ranker__c = 11.0;
            update sr;
        }catch(EXCEPTION ex){

            system.assert(ex.getMessage().contains(System.Label.Duplicate_Ranking.replace(':Param1',sr1.Name)));
        }
        
        
        sr1.Name = 'test';
        sr1.IsActive = true;
        update sr1;
        system.assert([select id,Ranker__c from ServiceResource where id=:sr1.Id limit 1].Ranker__c!=null);
        
        sr.Name = 'test12';
        sr.IsActive = false;
        update sr;
        //system.assert([select id,Ranker__c from ServiceResource where id=:sr.Id limit 1].Ranker__c==null);
        
        
        sr1.Primary_Branch_Family__c = bf2.Id;
        sr1.Ranker__c = 5;
        sr1.Override_Replacement_Rep__c=true;
        update sr1;
         test.stoptest();
		
    }
     static testMethod void Resourcesharing() 
    {        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Id activetypeId = TestUtil.getTerritoryTypeId('Replacement');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, true);           
            
            UserTerritory2Association UTA= TestUtil.createUserTerritory2Association(testUser.Id, t2.id, true);
            
            ServiceResource sr = TestUtil.createServiceResource('Mayank', testUser.Id, branch.Id, bf.Id, false);
            sr.AccountId = acc.Id;
            insert sr;
        } 
    }
    
    @isTest
    public static void PIESServiceResourceSquareTriggerTest(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ){
            Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
             User us = TestUtil.createUser(true);
              // Create Account
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.OwnerId = us.id;
        insert ac ;
        Account brac = TestUtil.createBranchAccount('Branch Account', false);
        brac.OwnerId =  us.id;
        insert brac ;
		
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

        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Pallavi PIES', us.Id, branch.Id, bf.Id, false);
        sr1.Resource_Group__c = 'Squareset';
        sr1.Installer__c = TRUE; 
        sr1.RecordTypeId = srRTId ;
         
        insert sr1;    
		
        }
        
    }
    
    @isTest
    public static void PIESServiceResourceSquaresetupdateTriggerTest(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ){
            Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
             User us = TestUtil.createUser(true);
              // Create Account
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.OwnerId = us.id;
        insert ac ;
        Account brac = TestUtil.createBranchAccount('Branch Account', false);
        brac.OwnerId =  us.id;
        insert brac ;
		
            //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Install', 'Hours', 2,true);
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
         // Create Branch Family
        Branch_Grouping__c bf2 = TestUtil.createBranchGrouping('BranchGrouping2', true);    

        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            
         // Create Branch
        Branch__c branch2 = TestUtil.createBranch('Test2', '101', bf2.Id, true);    
        
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

        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Pallavi PIES', us.Id, branch.Id, bf.Id, false);
        sr1.Resource_Group__c = 'Squareset';
        sr1.Installer__c = TRUE; 
        sr1.RecordTypeId = srRTId ;
         
        insert sr1; 
        sr1.Primary_Branch_Family__c = bf2.Id;
        update sr1;    
		
        }
        
    }
      @isTest
    public static void PIESServiceResourceTriggerTest(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ){
            Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
             User us = TestUtil.createUser(true);
              // Create Account
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.OwnerId = us.id;
        insert ac ;
        Account brac = TestUtil.createBranchAccount('Branch Account', false);
        brac.OwnerId =  us.id;
        insert brac ;
		
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Install', 'Hours', 2,true);
            
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
         // Create Branch Family
        Branch_Grouping__c bf2 = TestUtil.createBranchGrouping('BranchGrouping2', true);    

        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
         // Create Branch
        Branch__c branch2 = TestUtil.createBranch('Test2', '101', bf2.Id, true);    
        
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

        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Pallavi PIES', us.Id, branch.Id, bf.Id, false);
        sr1.Project_Coordinator__c = TRUE;
        sr1.Installer__c = TRUE; 
        sr1.RecordTypeId = srRTId ;
        insert sr1;  
        
        sr1.Primary_Branch_Family__c = bf2.Id ;
        update sr1 ;    
            
		
        }

        
    }
    
}