@isTest
private class EBSRESTCalloutTest 
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
    	
        Account ac = TestUtil.createBranchAccount('Branch Account', true);
        ac.branchaccmdmrecid__c = '34567823';
        update ac;
        
        Contact con=TestUtil.createContact(ac.Id, 'lastName', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        
        Address__c ad = TestUtil.createAddress(true);
        //Address__c ad = new Address__c(Street__c = 'Panvel',City__c = 'Surat',Country__c = 'US',State__c = 'GJ', Zipcode__c = '39410-1531',County__c = 'Varachha',Location_Id__c = '12345678');
        //insert ad;
        
        Address_Assignment__c aa = new Address_Assignment__c(Address__c = ad.Id, Account_Branch_Profile__c = abp.Id, Primary_Flag__c = true, Identifying_Address__c = false, Status__c = 'Active');
        insert aa;
        
        Lead ld = new Lead(LastName = 'Demo' , FirstName = 'Test' , LeadSource = 'LeadSource' , HomePhone__c = '(317) 555-1212');
        insert ld;

    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new Mock1()); 
        EBSRESTCallout.updateCustomerEBSCallout(ac.id, 'SendNULLBody');
        EBSRESTCallout.createCustomerEBSCallout(ac.id);
    	EBSRESTCallout.updateCustomerEBSData(ac.Id,'SendNULLBody');
        EBSRESTCallout.createLeadEBSCallout(ld.Id);
        EBSRESTCallout.updateCustomerEBSCallout(ac.Id,true);
        EBSRESTCallout.createUpdateContactToEBSData(con.Id);
        EBSRESTCallout.inActiveContactToEBSCallout(con.Id,ac.Id,'121','34567823');
    	Test.stopTest();
    }
    
    static testMethod void testBehavior1() {
        
        Account ac = TestUtil.createAccount('Person Account', true);

        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c br = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, br.Id,false);
        abp.MDMrecid__c='12120';
        insert abp;
        
        Address__c ad = TestUtil.createAddress(false);
        ad.MDMrecid__c='111';
        insert ad;
        Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id, abp.Id, true);
        
        Lead ld = TestUtil.createLead('John', 'Soft Assign Placeholder', true);
        //creating opp 
        Opportunity opp=testutil.createOpportunity('Test Opp', ac.id, userinfo.getUserId(),true);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        EBSRESTCallout.updateCustomerEBSCallout(ac.id, 'SendNULLBody');
        EBSRESTCallout.createCustomerEBSCallout(ac.id);
        EBSRESTCallout.createCustomerEBSCallout('');
    	EBSRESTCallout.updateCustomerEBSData('','');
        EBSRESTCallout.createLeadEBSCallout(ld.Id);
        EBSRESTCallout.createLeadEBSCallout('');
        EBSRESTCallout.updateAddressEBSCallout('');
        EBSRESTCallout.updateAddressEBSCallout(ad.Id);
        //passing opp id in createOpportunityEBSCallout method
        EBSRESTCallout.createOpportunityEBSCallout(opp.id);
        Test.stopTest();
    }
}