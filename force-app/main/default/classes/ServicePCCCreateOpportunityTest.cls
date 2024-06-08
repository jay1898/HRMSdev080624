@isTest
public class ServicePCCCreateOpportunityTest {
    public static testMethod void testMethod1(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Create Parent Account
        Account ac = TestUtil.createBranchAccount('Pella Account', false);
        ac.BillingStreet = '2 Test St';
        ac.BillingCity = 'Belmont';
        ac.BillingState = 'NH';
        ac.BillingPostalCode = '03220-4052';
        ac.BillingCountry = 'US';
        ac.mdmrecId__c = '180948121';
        insert ac ;
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c br = TestUtil.createBranch('Test', '100', bf.Id, false);
        br.T_C_Branch_Number__c = '230';
        insert br;
        
        // Create Child Account
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.ParentId = ac.Id;
        acc.Branch__c = br.Id;
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
        Database.SaveResult saveResult = Database.insert(acc, dml);
        
        // Create Contact
        Contact cont = TestUtil.createContact(acc.Id, 'Test Contact' , false);
        cont.PCC_UserName__c = 'Test PCC UserName';
        insert cont;
        
        req.requestBody = Blob.valueOf( 'Test' );
        ServicePCCCreateOpportunity.postData();
        
        ServicePCCCreateOpportunity.OpportunityRequest conReq = new ServicePCCCreateOpportunity.OpportunityRequest();
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        conReq.name = 'JBContractor 09-10-2020 21:20';
        conReq.userLogin = 'Test PCC UserName' ;
        conReq.businessSegment = 'Retail';
        conReq.customerPartyId = '180948121';
        conReq.branchNumber = '230';
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        conReq.name = 'JBContractor 09-10-2020 21:20';
        conReq.userLogin = 'Test PCC UserName 1' ;
        conReq.businessSegment = 'Retail';
        conReq.customerPartyId = '180948121';
        conReq.branchNumber = '230';
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
    }
    public static testMethod void testMethod2(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Create Parent Account
        Account ac = TestUtil.createBranchAccount('Pella Account', false);
        ac.BillingStreet = '2 Test St';
        ac.BillingCity = 'Belmont';
        ac.BillingState = 'NH';
        ac.BillingPostalCode = '03220-4052';
        ac.BillingCountry = 'US';
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        ac.RecordTypeId=recordTypeId;
        
        insert ac ;
        
        // Create Child Account
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.ParentId = ac.Id;
        acc.RecordTypeId=recordTypeId;
        acc.Branch_number__c='P79';
        acc.mdmrecId__c = '180948121';
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
        Database.SaveResult saveResult = Database.insert(acc, dml);
        
        
        req.requestBody = Blob.valueOf( 'Test' );
        ServicePCCCreateOpportunity.postData();
        
        ServicePCCCreateOpportunity.OpportunityRequest conReq = new ServicePCCCreateOpportunity.OpportunityRequest();
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        conReq.name = 'JBContractor 09-10-2020 21:20';
        conReq.userLogin = 'Test PCC UserName' ;
        conReq.businessSegment = 'Retail';
        conReq.customerPartyId = '180948121';
        conReq.branchNumber = 'P79';
        conReq.clientType='4';
        conReq.OrderType='NON_INSTALLED_SALES';
        
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        
    }
    public static testMethod void testMethod3(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Create Parent Account
        Account ac = TestUtil.createBranchAccount('Pella Account', false);
        ac.BillingStreet = '2 Test St';
        ac.BillingCity = 'Belmont';
        ac.BillingState = 'NH';
        ac.BillingPostalCode = '03220-4052';
        ac.BillingCountry = 'US';
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        ac.RecordTypeId=recordTypeId;
        
        insert ac ;
        
        // Create Child Account
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.ParentId = ac.Id;
        acc.RecordTypeId=recordTypeId;
        acc.Branch_number__c='P79';
        acc.mdmrecId__c = '180948121';
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
        Database.SaveResult saveResult = Database.insert(acc, dml);
        
        
        req.requestBody = Blob.valueOf( 'Test' );
        ServicePCCCreateOpportunity.postData();
        
        ServicePCCCreateOpportunity.OpportunityRequest conReq = new ServicePCCCreateOpportunity.OpportunityRequest();
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        conReq.name = 'JBContractor 09-10-2020 21:20';
        conReq.userLogin = 'Test PCC UserName' ;
        conReq.businessSegment = 'Retail';
        conReq.customerPartyId = '180948121';
        conReq.branchNumber = 'P79';
        conReq.clientType='4';
        conReq.OrderType='NADISPLAY';
        
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        
    }
    public static testMethod void testMethod4(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Create Parent Account
        Account ac = TestUtil.createBranchAccount('Pella Account', false);
        ac.BillingStreet = '2 Test St';
        ac.BillingCity = 'Belmont';
        ac.BillingState = 'NH';
        ac.BillingPostalCode = '03220-4052';
        ac.BillingCountry = 'US';
        //ac.mdmrecId__c = '180948121';
        insert ac ;
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c br = TestUtil.createBranch('Test', '100', bf.Id, false);
        br.T_C_Branch_Number__c = '230';
        insert br;
        
        // Create Child Account
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.ParentId = ac.Id;
        acc.Branch__c = br.Id;
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
        Database.SaveResult saveResult = Database.insert(acc, dml);
        
        // Create Contact
        Contact cont = TestUtil.createContact(acc.Id, 'Test Contact' , false);
        cont.PCC_UserName__c = 'Test PCC UserName';
        insert cont;
        
        req.requestBody = Blob.valueOf( 'Test' );
        ServicePCCCreateOpportunity.postData();
        
        ServicePCCCreateOpportunity.OpportunityRequest conReq = new ServicePCCCreateOpportunity.OpportunityRequest();
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        conReq.name = 'JBContractor 09-10-2020 21:20';
        conReq.userLogin = 'Test PCC UserName' ;
        conReq.businessSegment = 'Retail';
        conReq.customerPartyId = '180948121';
        conReq.branchNumber = '230';
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
        
        conReq.name = 'JBContractor 09-10-2020 21:20';
        conReq.userLogin = 'Test PCC UserName 1' ;
        conReq.businessSegment = 'Retail';
        conReq.customerPartyId = '180948121';
        conReq.branchNumber = '230';
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePCCCreateOpportunity.postData();
    }
}