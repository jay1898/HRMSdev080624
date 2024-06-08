@isTest
private class QuoteTriggerHandlerTest{
    static testMethod void testMethod1(){
        // Create Account
        Account ac = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        /*Opportunity oppt = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
oppt.Appointment_DateTime__c = DateTime.now();
oppt.Status__c = 'New';
oppt.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Replacement').getRecordTypeId();
OpportunityTriggerHandler.RUN_TRIGGER= false;
oppt.Is_Created_Using_PCC__c = true;
insert oppt;*/
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac.Id;
        aa.Opportunity__c = opp.Id;
        insert aa;
        
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ; 
        
        q.Forecasted__c = true ;
        q.Customer_Extended_Price__c = 10 ;
        q.Status='Contracted';
        update q ; 
        
        q.Forecasted__c = true ;
        q.Customer_Extended_Price__c = 10 ;
        q.Status='Active';
        update q ;
        
        q.Forecasted__c = true ;
        q.Total_BAC_Price__c = 10 ;
        q.Status='Booked';
        update q ;  
        
        q.Forecasted__c = true ;
        q.Total_BAC_Price__c = 10 ;
        q.Signed_Contract_Date__c=Date.today(); 
        q.Status='Canceled';    
        update q ;
        
        delete q;
        Test.stopTest();  
    }
    static testMethod void testMethod2(){
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        //opp.Appointment_DateTime__c = DateTime.now();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Replacement').getRecordTypeId();
        insert opp;
        
        Test.startTest();
        
        Quote q1 = TestUtil.createQuote(opp.Id, false);
        q1.Quote_Number_PQM__c='89891' ;
        q1.Forecasted__c = true ;
        insert q1 ;
        
        q1.Forecasted__c = true ;
        q1.Customer_Extended_Price__c = 10 ;
        q1.Status='Active';
        update q1 ;
        
        q1.Forecasted__c = true ;
        q1.Total_BAC_Price__c = 10 ;
        q1.Signed_Contract_Date__c=Date.today();
        q1.Status='Ordered';
        update q1 ;
        q1.Forecasted__c = true ;
        q1.Total_BAC_Price__c = 10 ;
        q1.Signed_Contract_Date__c=Date.today();
        q1.Status='Canceled';
        update q1 ;
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
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Active';
        insert q ;
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Primary__c=true;
        q.Market_Segment__c = 'S0';
        q.Business_Segment__c = 'Trade';
        update q ;
        q.Status='Canceled';
        update q ;
        
       
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
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
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
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, null, false);
        sr.Project_Coordinator__c = true;
        sr.Branch__c = branch.Id;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('Trade R/R', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Active';
        insert q ;
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Primary__c=true;
        q.Market_Segment__c = 'SM';
        q.Business_Segment__c = 'Trade';
        update q ;
        
        Test.stopTest();
    }
    static testMethod void testMethod5(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
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
        WorkType wt = TestUtil.createWorkType('Retail', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Active';
        insert q ;
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Primary__c=true;
        q.Market_Segment__c = 'SM';
        q.Business_Segment__c = 'Retail';
        update q ;
        
        Test.stopTest();
    }
    static testMethod void testMethod6(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
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
        WorkType wt = TestUtil.createWorkType('Retail', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Active';
        insert q ;
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Primary__c=true;
        q.Market_Segment__c = 'SM';
        q.Business_Segment__c = 'Replacement';
        update q ;
        
        Test.stopTest();
    }
    static testMethod void testMethod7(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
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
        WorkType wt = TestUtil.createWorkType('Commercial', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = opp2.Id;
        insert aa;
        
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Active';
        insert q ;
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Primary__c=true;
        q.Market_Segment__c = 'MF';
        q.Business_Segment__c = 'Commercial';
        update q ;
        
        Test.stopTest();
    }

    static testMethod void testMethod8(){
        // Create User
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        insert u;
        
        // create Branch family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        // create branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
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
        Opportunity oppt = TestUtil.createOpportunity('New Opp', ac2.Id, UserInfo.getUserId(), false); 
        oppt.Appointment_DateTime__c = DateTime.now();
        oppt.Status__c = 'New';
        oppt.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Replacement').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        oppt.Is_Created_Using_PCC__c = true;
        insert oppt;
        
        // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.Project_Coordinator__c = true;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('New Construction', 'OV', 'Hours', 2,true);
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac2.Id;
        aa.Opportunity__c = oppt.Id;
        insert aa;
        // create Work Order
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac2.Id, null, false);
        wo.OwnerId = u.Id;
        insert wo;
        
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp2.Id, false);
        q.Quote_Number_PQM__c='898' ;
        q.BookDate__c = Date.today();
        q.Status='Contracted';
        q.Order_Type__c='INSTALLED_SALES';
        q.Primary__c=true;
        q.Market_Segment__c = 'S0';
        q.Business_Segment__c = 'Trade';
        insert q ;
        
       
        Test.stopTest();
    }
    
    static testMethod void createSalesQuotaAssociationForQuoteTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);

        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, false); 
        opportunity.CloseDate = date.newInstance(System.today().year(), 5, 15);
        insert opportunity;
         
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuota = new Sales_Quota__c(
            Month__c = 'May',
            Quota_Amount__c = 50000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 5, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 5, 31)
        );
		insert salesQuota;

        Test.startTest();
        Quote quote =  new Quote(OpportunityId = Opportunity.Id, Name = 'Test Quote', OwnerId = salesPlan.OwnerId);
        insert quote;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];

        System.assertEquals(1, results.size());
        System.assertEquals(salesQuota.Id, results[0].Sales_Quota__r.Id);
    }    
    
    static testMethod void createSalesQuotaAssociationForQuoteBookedStatusTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);

        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, false); 
        opportunity.CloseDate = date.newInstance(System.today().year(), 10, 19);
        insert opportunity;
         
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuota = new Sales_Quota__c(
            Month__c = 'August',
            Quota_Amount__c = 50000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 8, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 8, 31)
        );
		insert salesQuota;

        Test.startTest();
        Quote quote =  new Quote(
            OpportunityId = Opportunity.Id,
            Name = 'Test Quote',
            OwnerId = salesPlan.OwnerId,
            BookDate__c = date.newInstance(System.today().year(), 8, 14),
            Status = 'Booked'
        );
        insert quote;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];

        System.assertEquals(1, results.size());
        System.assertEquals(salesQuota.Id, results[0].Sales_Quota__r.Id);
    }  
    
    static testMethod void updateSalesQuotaAssociationForQuoteTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);

        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, false);
        opportunity.CloseDate = date.newInstance(System.today().year(), 5, 21);
        insert opportunity;
        
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuotaOne = new Sales_Quota__c(
            Month__c = 'May',
            Quota_Amount__c = 50000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 5, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 5, 31)
        );
		insert salesQuotaOne;
        
        Sales_Quota__c salesQuotaTwo = new Sales_Quota__c(
            Month__c = 'April',
            Quota_Amount__c = 40000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 4, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 4, 30)
        );
        insert salesQuotaTwo;
        
        Quote quote = TestUtil.createQuote(opportunity.Id, true);
        
        Test.startTest();
        quote.Status = 'Booked';
        quote.BookDate__c = date.newInstance(System.today().year(), 4, 16);
        
        update quote;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];

        System.assertEquals(1, results.size());
        System.assertEquals(salesQuotaTwo.Id, results[0].Sales_Quota__r.Id);
    }   
    
     static testMethod void updateSalesQuotaAssociationForQuoteStatusChangedNotBookedTest() {
     	User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);

        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, true);

        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuotaOne = new Sales_Quota__c(
            Month__c = 'August',
            Quota_Amount__c = 90000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 8, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 8, 31)
        );
		insert salesQuotaOne;
        
        Sales_Quota__c salesQuotaTwo = new Sales_Quota__c(
            Month__c = 'September',
            Quota_Amount__c = 100000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 9, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 9, 30)
        );
        insert salesQuotaTwo;
        
        Quote quote = TestUtil.createQuote(opportunity.Id, false);
        quote.Status = 'Booked';
        quote.BookDate__c = date.newInstance(System.today().year(), 8, 10); 
        insert quote; 
        
        opportunity.CloseDate = date.newInstance(System.today().year(), 9, 21);
        update opportunity;

        Test.startTest();
        quote.Status = 'Active';
        quote.BookDate__c = null;
       
        update quote;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];

        System.assertEquals(1, results.size());
        System.assertEquals(salesQuotaTwo.Id, results[0].Sales_Quota__r.Id);
    }
    
    static testMethod void updateSalesQuotaAssociationForQuoteBookDateChangeTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);

        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, true);
        
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuotaOne = new Sales_Quota__c(
            Month__c = 'August',
            Quota_Amount__c = 90000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 8, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 8, 31)
        );
		insert salesQuotaOne;
        
        Sales_Quota__c salesQuotaTwo = new Sales_Quota__c(
            Month__c = 'October',
            Quota_Amount__c = 100000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 10, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 10, 30)
        );
        insert salesQuotaTwo;
        
        Quote quote = TestUtil.createQuote(opportunity.Id, false);
        quote.Status = 'Booked';
        quote.BookDate__c = date.newInstance(System.today().year(), 8, 10); 
        insert quote; 

        Test.startTest();
        quote.BookDate__c = date.newInstance(System.today().year(), 10, 12);
        
        update quote;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];

        System.assertEquals(1, results.size());
        System.assertEquals(salesQuotaTwo.Id, results[0].Sales_Quota__r.Id);
    }   
    
     static testMethod void updateSalesQuotaAssociationForQuoteWithoutPreviousAssociationTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);

        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, false);
        opportunity.closeDate = date.newInstance(System.today().year(), 08, 30);
        insert opportunity;
        
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuota = new Sales_Quota__c(
            Month__c = 'December',
            Quota_Amount__c = 100000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 12, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 12, 31)
        );
		insert salesQuota;
        
        Quote quote = TestUtil.createQuote(opportunity.Id, false);
        quote.Status = 'Active';
        quote.BookDate__c = null; 
        insert quote; 

        List<Sales_Quota_Associated_Quote__c> existingQuoteAssociation = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];
         
        System.assertEquals(0, existingQuoteAssociation.size());
                 
        Test.startTest();
        quote.Status = 'Booked';
        quote.BookDate__c = date.newInstance(System.today().year(), 12, 15);
        
        update quote;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];

        System.assertEquals(1, results.size());
        System.assertEquals(salesQuota.Id, results[0].Sales_Quota__r.Id);
    } 
    
    static testMethod void updateSalesQuotaAssociationForQuoteEstimatedBookDateChangeTest() { 
    	User user = TestUtil.createTradeCommSalesRep();
    	Account ac = TestUtil.createBranchAccount('Branch Account', true);
        Branch_Grouping__c branchGrouping = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', branchGrouping.Id, false);
        branch.T_C_Branch_Number__c = '100';
		Account_Branch_Profile__c branchProfile = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, false);
        opportunity.CloseDate = date.newInstance(System.today().year(), 10, 14);
        opportunity.Status__c = 'Open';
        opportunity.RecordTypeId = oppRecordTypeId;
        opportunity.Account_Branch_Profile__c = branchProfile.Id;
        insert opportunity;
                 
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuotaOne = new Sales_Quota__c(
            Month__c = 'October',
            Quota_Amount__c = 90000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 10, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 10, 31)
        );
		insert salesQuotaOne;
        
        Sales_Quota__c salesQuotaTwo = new Sales_Quota__c(
            Month__c = 'November',
            Quota_Amount__c = 100000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 11, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 11, 30)
        );
        insert salesQuotaTwo;
        
        Quote quote = TestUtil.createQuote(opportunity.Id, true);

        Test.startTest();
        Opportunity.CloseDate = date.newInstance(System.today().year(), 11, 26);
        update opportunity;
            
        quote.Estimated_Book_Date__c = date.newInstance(System.today().year(), 11, 26);        
        update quote;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Sales_Quota__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id
        ];

        System.assertEquals(1, results.size());
        System.assertEquals(salesQuotaTwo.Id, results[0].Sales_Quota__r.Id);
    }  
    
    static testMethod void updatePYTDonAccountWhenPQMTotalPriceChangesTest(){
         Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date previousYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        
        User user = TestUtil.createReplacementSalesRep();
        
        Branch_Grouping__c branchFamily = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', branchFamily.Id, true);
        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Branch__c = branch.Id;
        insert account;
        Account_Branch_Profile__c accountBranchProfile = TestUtil.createAccountBranchProfile(account.Id, branch.Id, true);
        
        OpportunityTriggerHandler.RUN_TRIGGER = false;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        Opportunity opportunity = TestUtil.createOpportunity('New Opp 1', account.Id, UserInfo.getUserId(), false);
        opportunity.Status__c = 'Open';
        opportunity.RecordTypeId = oppRecordTypeId;
        opportunity.Account_Branch_Profile__c = accountBranchProfile.Id;
        insert opportunity;

        Quote quoteOne = TestUtil.createQuote(opportunity.Id, false);
        quoteOne.Quote_Number_PQM__c = '12345678' ;
        quoteOne.Customer_Extended_Price__c = 5000;
        quoteOne.BookDate__c = previousYearStartDate.addDays(15);
        quoteOne.Status = 'Booked';
        insert quoteOne;
        
        Date todayLastYear = System.today().addYears(-1);
        Quote quoteTwo = TestUtil.createQuote(opportunity.Id, false);
        quoteTwo.Quote_Number_PQM__c = '87654321' ;
		quoteTwo.Customer_Extended_Price__c = 5000;
        quoteTwo.BookDate__c = todayLastYear.addDays(-1);
        quoteTwo.Status = 'Ordered';
        insert quoteTwo;
        
        Test.startTest();       
		quoteOne.Customer_Extended_Price__c = 7000;
	
        update quoteOne;
        Test.stopTest();
        
        Account accountAfterUpdate = [SELECT Id, PYTD_Sales__c FROM Account WHERE Id =: account.Id LIMIT 1];
        
        System.assertEquals(12000, accountAfterUpdate.PYTD_Sales__c);       
    }
    
    static testMethod void updatePYTDonAccountWhenBookDateChangesTest(){
         Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date previousYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        
        User user = TestUtil.createReplacementSalesRep();
        
        Branch_Grouping__c branchFamily = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', branchFamily.Id, true);
        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Branch__c = branch.Id;
        insert account;
        Account_Branch_Profile__c accountBranchProfile = TestUtil.createAccountBranchProfile(account.Id, branch.Id, true);
        
        OpportunityTriggerHandler.RUN_TRIGGER = false;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        Opportunity opportunity = TestUtil.createOpportunity('New Opp 1', account.Id, UserInfo.getUserId(), false);
        opportunity.Status__c = 'Open';
        opportunity.RecordTypeId = oppRecordTypeId;
        opportunity.Account_Branch_Profile__c = accountBranchProfile.Id;
        insert opportunity;

        Quote quoteOne = TestUtil.createQuote(opportunity.Id, false);
        quoteOne.Quote_Number_PQM__c = '12345678' ;
        quoteOne.Customer_Extended_Price__c = 7500;
        quoteOne.BookDate__c = previousYearStartDate.addDays(15);
        quoteOne.Status = 'Booked';
        insert quoteOne;
        
        Date todayLastYear = System.today().addYears(-1);
        Quote quoteTwo = TestUtil.createQuote(opportunity.Id, false);
        quoteTwo.Quote_Number_PQM__c = '87654321' ;
		quoteTwo.Customer_Extended_Price__c = 12500;
        quoteTwo.BookDate__c = todayLastYear.addDays(-15);
        quoteTwo.Status = 'Ordered';
        insert quoteTwo;
        
        Test.startTest();       
		quoteTwo.BookDate__c = todayLastYear.addDays(-3);

        update quoteTwo;
        Test.stopTest();
        
        Account accountAfterUpdate = [SELECT Id, PYTD_Sales__c FROM Account WHERE Id =: account.Id LIMIT 1];
        
        System.assertEquals(20000, accountAfterUpdate.PYTD_Sales__c);       
    }
    
    static testMethod void updatePYTDonAccountWhenStatusChangesTest(){
        Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date previousYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        
        User user = TestUtil.createReplacementSalesRep();
        
        Branch_Grouping__c branchFamily = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', branchFamily.Id, true);
        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Branch__c = branch.Id;
        insert account;
        Account_Branch_Profile__c accountBranchProfile = TestUtil.createAccountBranchProfile(account.Id, branch.Id, true);
        
        OpportunityTriggerHandler.RUN_TRIGGER = false;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        Opportunity opportunity = TestUtil.createOpportunity('New Opp 1', account.Id, UserInfo.getUserId(), false);
        opportunity.Status__c = 'Open';
        opportunity.RecordTypeId = oppRecordTypeId;
        opportunity.Account_Branch_Profile__c = accountBranchProfile.Id;
        insert opportunity;

        Quote quoteOne = TestUtil.createQuote(opportunity.Id, false);
        quoteOne.Quote_Number_PQM__c = '12345678' ;
        quoteOne.Customer_Extended_Price__c = 22500;
        quoteOne.Status = 'Active';
        insert quoteOne;
        
        Date todayLastYear = System.today().addYears(-1);
        Quote quoteTwo = TestUtil.createQuote(opportunity.Id, false);
        quoteTwo.Quote_Number_PQM__c = '87654321' ;
		quoteTwo.Customer_Extended_Price__c = 17500;
        quoteTwo.BookDate__c = todayLastYear.addDays(-15);
        quoteTwo.Status = 'Ordered';
        insert quoteTwo;
        
        Test.startTest();       
        quoteOne.BookDate__c = previousYearStartDate.addDays(15);
		quoteOne.Status = 'Booked';

        update quoteOne;
        Test.stopTest();

        Account accountAfterUpdate = [SELECT Id, PYTD_Sales__c FROM Account WHERE Id =: account.Id LIMIT 1];
        
        System.assertEquals(40000, accountAfterUpdate.PYTD_Sales__c);       
    }
    
     public static testMethod void removeSalesQuotaAssociationsWhenQuoteIsDeletedTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);
       
        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, true); 
       
        Quote quoteOne = TestUtil.createQuote(opportunity.Id, false);
        quoteOne.Status = 'Booked';
        quoteOne.BookDate__c = date.newInstance(System.today().year(), 5, 14);
        quoteOne.Quote_Number_PQM__c = '123456';
        insert quoteOne;
         
        Quote quoteTwo = TestUtil.createQuote(opportunity.Id, false);
        quoteTwo.Status = 'Booked';
        quoteTwo.BookDate__c = date.newInstance(System.today().year(), 5, 24);
        quoteTwo.Quote_Number_PQM__c = '654321';
        insert quoteTwo;
        
        Sales_Plan__c salesPlan = new Sales_Plan__c(
            Name = 'Test Sales Plan',
            OwnerId = user.id
        );
        insert salesPlan;

        Sales_Quota__c salesQuota = new Sales_Quota__c(
            Month__c = 'May',
            Quota_Amount__c = 50000,
            Sales_Plan__c = salesPlan.Id,
            Quota_Period_Start_Date__c = date.newInstance(System.today().year(), 5, 1),
            Quota_Period_End_Date__c = date.newInstance(System.today().year(), 5, 31)
        );
        SalesQuotaTriggerHandler.RUN_TRIGGER = false;
        insert salesQuota;

         List<Sales_Quota_Associated_Quote__c> resultBeforeDeletion = [
            SELECT Id, Name, Quote__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quoteOne.Id OR Quote__r.Id =: quoteTwo.Id
        ];

        System.assertEquals(2, resultBeforeDeletion.size());
         
        Test.startTest();
        delete quoteTwo;
        Test.stopTest();

        List<Sales_Quota_Associated_Quote__c> results = [
            SELECT Id, Name, Quote__r.Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quoteOne.Id OR Quote__r.Id =: quoteTwo.Id
        ];

        System.assertEquals(1, results.size());
    }
}