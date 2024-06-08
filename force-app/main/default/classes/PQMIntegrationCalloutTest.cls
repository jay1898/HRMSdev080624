@isTest
private class PQMIntegrationCalloutTest 
{
    public class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(-200);
            return response; 
        }
    }
    
    public class Mock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{ "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "party", "statuscode": 200, "additionalresponsevalues": [{ "name": "partynumber", "value": 1009382533 }] }, { "mdmrecid": 20810796, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "PHONE", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 20810797, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-CALL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-SMS", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-MAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 24259326, "spokerecid": "a0o23000000FGlHAAW", "message": "OK", "objectcode": "account", "statuscode": 200, "additionalresponsevalues": [{ "name": "accountnumber", "value": 1005498153 }] }, { "mdmrecid": 11460528, "spokerecid": "a0m23000000CqHPAA0", "message": "OK", "objectcode": "address", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 11460528, "spokerecid": "a0n23000000EMF5AAO", "message": "OK", "objectcode": "addressassignment", "statuscode": 200, "additionalresponsevalues": null }]');
            response.setStatusCode(200);
            return response; 
        }
    }
    
    static testMethod void testMethod1() 
    {
        
         // Create Account
        Account ac = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac.Id;
        aa.Opportunity__c = opp.Id;
        insert aa;
        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new Mock());
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ; 
        
        q.Forecasted__c = false ;
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
        q.Business_Segment__c = 'Commercial';
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
        
        branch.Advance_PC_WO_Assignment__c=true;
        branch.Default_Retail_PC_receiver__c=sr.id;
        branch.Default_Trade_PC_Receiver__c=sr.id;
        update branch;
        
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
        q.Business_Segment__c = 'Commercial';
        update q ;
        q.Status='Canceled';
        update q ;
        
       
        Test.stopTest();
    }
}