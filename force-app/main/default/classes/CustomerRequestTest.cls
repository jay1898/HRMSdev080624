@isTest
global class CustomerRequestTest 
{
    static testMethod void testMethod1() 
    {   
        User u = TestUtil.createUser(true);
        Account acc = TestUtil.createAccount('Person Account', false);
        acc.PersonHomePhone='1236525632';
        acc.PersonOtherPhone='1236525632';
        acc.PersonAssistantPhone='1236525632';
        acc.Evening_Phone_Type__c='Home';
        acc.MDMphoneeveId__c = '4321908';
        acc.mdmrecid_email__c='23456';
        acc.Company_Email__c = 'abc@abc.com';
        acc.Fax='1234567890';
        acc.mdmfaxid__c='65432180';
        acc.Website='www.google.com';
        acc.mdmwebsiteId__c='34567890';
        acc.Account_Status__c='Active';
        insert acc;
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
     
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(acc.Id,branch.Id,true);
        
        Address__c ad = TestUtil.createAddress(false);
        ad.Address_Line_1__c='1-1000';
        insert ad;
        
        Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id,abp.Id,true);
        
        Lead ld = TestUtil.createLead('FirstName','LastName',true);
          //creating opp 
        Opportunity opp=testutil.createOpportunity('Test Opp', acc.id, userinfo.getUserId(),true);
        
        CustomerRequest.updateCustomerRequest(acc.Id, '');
        CustomerRequest.createCustomerRequest(acc.Id);
        CustomerRequest.createLeadRequest(ld.Id);
        CustomerRequest.createUpdateAARequest(aa);
        CustomerRequest.createUpdateAddressRequest(ad);
        //passing opp id in createOpportunityEBSCallout methsod
        CustomerRequest.createOpportunityRequest(opp.Id); 
        CustomerRequest.inActiveContactRequest('121','121','121');
        //added aditonalresponse for contact
        String response ='[{ "mdmrecid": 17698024, "spokerecid": "'+acc.Id+'", "message": "OK", "objectcode": "party", "statuscode": 200, "additionalresponsevalues": [{ "name": "email", "value": "test@test.com" }] }, { "mdmrecid": 20810796, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "contactmethods", "statuscode": 200, "additionalresponsevalues":[{"name":"partynumber","value":1003276518}]}, { "mdmrecid": 20810797, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-CALL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-SMS", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-MAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 24259326, "spokerecid": "a0l3K0000005PIxQAM", "message": "OK", "objectcode": "account", "statuscode": 200, "additionalresponsevalues": [{ "name": "accountnumber", "value": 1005498153 }] }, { "mdmrecid": 11460528, "spokerecid": "a0n3i0000062SNKAA2", "message": "OK", "objectcode": "address", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 11460528, "spokerecid": "a0m3i000001LdUsAAK", "message": "OK", "objectcode": "addressassignment", "statuscode": 200, "additionalresponsevalues": null }]';
            //CustomerRequest.handleCustomerResponse(''); 
        CustomerRequest.handleCustomerResponse(response);
    }
    static testMethod void testMethod2() 
    {   
        User u = TestUtil.createUser(true);
        Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
        acc.Store_Name__c='Test';
        acc.Branch_Number__c='p32';
        acc.branchaccmdmrecid__c='1236525632';
        acc.Fax='1234567890';
        acc.Website='www.google.com';
        update acc;

        Contact con = TestUtil.createContact(acc.Id, 'lastName', false);
        con.HomePhone='7890789009';
        con.Phone='1234567890';
        con.MobilePhone='1290876543';
        con.Email='abc@abc.com';
        con.Fax='2341567890';
        con.AssistantPhone='5678901234';
        insert con;
        
        CustomerRequest.updateCustomerRequest(acc.Id,'');
     //   CustomerRequest.createCustomerRequest(acc.Id);
       //Added by Satheesh
        CustomerRequest.createContactRequest(con.Id);
    }
     static testMethod void testMethod3() 
    {   
        User u = TestUtil.createUser(true);
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.mdmrecid_email__c='Test@abc.com';
        acc.Branch_Number__c='p32';
        acc.branchaccmdmrecid__c='1236525632';
        acc.mdmhomephonedayid__c = '32423423';
        acc.Fax='1234567890';
        acc.Website='www.google.com';
        acc.Company_Email__c='abc@abc.com';
        acc.mdmrecid_email__c='87087879';
        acc.Account_Status__c='Active';
        insert acc;       
        CustomerRequest.updateCustomerRequest(acc.Id,'');
    }
}