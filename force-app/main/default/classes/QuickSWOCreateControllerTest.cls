@isTest
private class QuickSWOCreateControllerTest{
    static testMethod void testMethod1(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Is_Available_for_Work_Order__c=true;
        insert branch;
        
        // Create Account
        Account ac2 = TestUtil.createBranchAccount('Branch Account', false);
        ac2.Branch__c = branch.Id;
        insert ac2;
        // create account branch profile  
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac2.Id, branch.Id, true);
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        insert opp2;
        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Project_Coordinator__c = true;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('New Construction', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        // create Work Order
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac2.Id, null, false);
        wo.OwnerId = u.Id;
        insert wo;
        
        Test.startTest();
        Metadata_Control__c mc = new Metadata_Control__c();
        mc.Disable_All__c = true;
        insert mc;
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Market_Segment__c = 'S0';
        q.Business_Segment__c = 'Trade';
        q.ProjectOwner_City__c = 'Merritt Island';
        q.ProjectOwner_Country__c = 'US';
        q.ProjectOwner_State__c = 'FL';
        q.ProjectOwner_Street__c = '1360 Trout St';
        q.ProjectOwner_Zip__c = '32952-5749';
        insert q;
        system.debug('@@Test Quote Id::'+q.Id);
        
        QuickSWOCreateController.createSWORecord(q,true,wt.Id,false);
        
        Test.stopTest();
        
    }
    static testMethod void testMethod2(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Is_Available_for_Work_Order__c=true;
        insert branch;
        
        // Create Account
        Account ac2 = TestUtil.createBranchAccount('Branch Account', false);
        ac2.Branch__c = branch.Id;
        insert ac2;
        // create account branch profile  
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac2.Id, branch.Id, true);
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        insert opp2;
        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Project_Coordinator__c = true;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('New Construction', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        // create Work Order
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac2.Id, null, false);
        wo.OwnerId = u.Id;
        insert wo;
        
        Test.startTest();
        Metadata_Control__c mc = new Metadata_Control__c();
        mc.Disable_All__c = true;
        insert mc;
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Market_Segment__c = 'SM';
        q.Business_Segment__c = 'Trade';
        q.ProjectOwner_City__c = 'Merritt Island';
        q.ProjectOwner_Country__c = 'US';
        q.ProjectOwner_State__c = 'FL';
        q.ProjectOwner_Street__c = '1360 Trout St';
        q.ProjectOwner_Zip__c = '32952-5749';
        insert q;
        system.debug('@@Test Quote Id::'+q.Id);
        QuickSWOCreateController.createSWORecord(q,true,wt.Id,false);
        
        Test.stopTest();
        
    }
    static testMethod void testMethod3(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Is_Available_for_Work_Order__c=true;
        insert branch;
        
        // Create Account
        Account ac2 = TestUtil.createBranchAccount('Branch Account', false);
        ac2.Branch__c = branch.Id;
        insert ac2;
        // create account branch profile  
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac2.Id, branch.Id, true);
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        insert opp2;
        
        opportunity opp = [select id, Work_Order__c from opportunity where id =:opp2.Id ];
        system.debug('opppo@@@@@@@::::::::'+ opp.Work_Order__c);        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Project_Coordinator__c = true;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('New Construction', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        // create Work Order
        /*WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac2.Id, null, false);
wo.OwnerId = u.Id;
insert wo;*/
        
        Test.startTest();
        Metadata_Control__c mc = new Metadata_Control__c();
        mc.Disable_All__c = true;
        insert mc;
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Active';
        q.Order_Type__c='INSTALLED_SALES';
        //q.Market_Segment__c = 'SM';
        q.Business_Segment__c = 'Retail';
        q.ProjectOwner_City__c = 'Merritt Island';
        q.ProjectOwner_Country__c = 'US';
        //q.ProjectOwner_State__c = 'FL';
        q.ProjectOwner_Street__c = '1360 Trout St';
        q.ProjectOwner_Zip__c = '32952-5749';
        insert q;
        quote qq = [select id, Branch_Family__c  from quote where id =: q.Id];
        
        system.debug('@@Test Quote Id::'+qq.Branch_Family__c);
        try{
            QuickSWOCreateController.QuoteWrapper qwrap=QuickSWOCreateController.checkQuoteRecordDetails(q.Id,false);
        }catch(Exception e){
            system.debug('Error:'+e);
        }
        
        q.Status='Contracted';
        update q;
        QuickSWOCreateController.QuoteWrapper qwrap=QuickSWOCreateController.checkQuoteRecordDetails(q.Id,false);
        QuickSWOCreateController.createSWORecord(qwrap.quote,false,wt.Id,false);
        try{
            QuickSWOCreateController.createSWORecord(q,false,wt.Id,false);
            QuickSWOCreateController.checkQuoteRecordDetails(q.Id,false);
        }catch(Exception e){
            system.debug('Error:'+e);
        }
        
        Test.stopTest();
        
    }
    static testMethod void testMethod4(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Is_Available_for_Work_Order__c=true;
        insert branch;
        
        // Create Account
        Account ac2 = TestUtil.createBranchAccount('Branch Account', false);
        ac2.Branch__c = branch.Id;
        insert ac2;
        // create account branch profile  
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac2.Id, branch.Id, true);
        
        // Create Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        opp2.Appointment_DateTime__c = DateTime.now();
        opp2.Status__c = 'Open';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        insert opp2;
        
        opportunity opp = [select id, Work_Order__c from opportunity where id =:opp2.Id ];
        system.debug('opppo@@@@@@@::::::::'+ opp.Work_Order__c);        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Project_Coordinator__c = true;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('New Construction', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        // create Work Order
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac2.Id, null, false);
        wo.OwnerId = u.Id;
        insert wo;
        
        Test.startTest();
        Metadata_Control__c mc = new Metadata_Control__c();
        mc.Disable_All__c = true;
        insert mc;
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Active';
        q.Order_Type__c='INSTALLED_SALES';
        //q.Market_Segment__c = 'SM';
        q.Business_Segment__c = 'Retail';
        q.ProjectOwner_City__c = 'Merritt Island';
        q.ProjectOwner_Country__c = 'US';
        //q.ProjectOwner_State__c = 'FL';
        q.ProjectOwner_Street__c = '1360 Trout St';
        q.ProjectOwner_Zip__c = '32952-5749';
        insert q;
        quote qq = [select id, Branch_Family__c  from quote where id =: q.Id];
        
        system.debug('@@Test Quote Id::'+qq.Branch_Family__c);
        try{
            QuickSWOCreateController.QuoteWrapper qwrap=QuickSWOCreateController.checkQuoteRecordDetails(opp2.Id,true);
        }catch(Exception e){
            system.debug('Error:'+e);
        }
        
        q.Status='Contracted';
        update q;
        QuickSWOCreateController.QuoteWrapper qwrap=QuickSWOCreateController.checkQuoteRecordDetails(q.Id,false);
        QuickSWOCreateController.checkTerritoryDetails(qwrap.quote,false,wt.Id);
        try{
            QuickSWOCreateController.checkTerritoryDetails(q,false,wt.Id);
            q.id=null;
            QuickSWOCreateController.createSWORecord(q,false,wt.Id,true);
        }catch(Exception e){
            system.debug('Error:'+e);
        }
        
        Test.stopTest();
        
    }
    
    
}