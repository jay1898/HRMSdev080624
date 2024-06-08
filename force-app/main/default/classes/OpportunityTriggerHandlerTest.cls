@isTest
public class OpportunityTriggerHandlerTest {
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
            response.setBody('{"QuoteNumber":"123"}');
            response.setStatusCode(200);
            return response; 
        }
    }
    
    public class Mock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{ "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "party", "statuscode": 200, "additionalresponsevalues": [{ "name": "partynumber", "value": 1009382533 }] }, { "mdmrecid": 20810796, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "PHONE", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 20810797, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-CALL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-SMS", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-MAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 24259326, "spokerecid": "a0o23000000FGlHAAW", "message": "OK", "objectcode": "account", "statuscode": 200, "additionalresponsevalues": [{ "name": "accountnumber", "value": 1005498153 }] }, { "mdmrecid": 11460528, "spokerecid": "a0m23000000CqHPAA0", "message": "OK", "objectcode": "address", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 11460528, "spokerecid": "a0n23000000EMF5AAO", "message": "OK", "objectcode": "addressassignment", "statuscode": 200, "additionalresponsevalues": null }]');
            response.setStatusCode(200);
            return response; 
        }
    }
    
    @isTest
    public static void OpportunityTriggerHandlerMethod(){
        Communication__c com = TestUtil.createCommunication(true);
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        Communication_Component__c comcop = TestUtil.createCommunicationComponent(com.Id, false); 
        comcop.Channel__c = 'Email';
        comcop.Order__c = '1';
        comcop.Frequency__c = 'Immediate';
        comcop.Deployment_Run_After__c = '1';
        insert comCop;
        
        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false); 
        opp.CloseDate = Date.valueOf('2020-01-29');
        opp.StageName = 'New';
        opp.Create_Quote_Shell__c = true;
        opp.Communication__c = 'Thank you';
        opp.Is_In_Communication__c = false;
        opp.Create_Quote_Shell__c = false;
        opp.RecordTypeId = OppRecTyTCId ;
        insert opp;
        
        opp.Communication_1on1_Flag__c = true;
        opp.Communication__c = '1on1';
        opp.Already_Executed_Communication__c = 'test';
        opp.Create_Quote_Shell__c = true;
        opp.StageName = 'Follow-Up';
        
        List<Opportunity> oppList = new List<Opportunity>();        
        oppList.add(opp);
        update oppList;
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock1());
        OpportunityTriggerHandler.updateCommunicationStage(oppList,oldMap);
        Test.stopTest();
    }
    
    @isTest
    public static void OpportunityTriggerHandlerMethodRehash(){
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        Communication__c com = TestUtil.createCommunication(true);
        Communication__c com1 = TestUtil.createCommunication(false);
        com1.Type__c='Follow-Up';
        insert com1;
        Communication_Component__c comcop = TestUtil.createCommunicationComponent(com.Id, false); 
        comcop.Channel__c = 'Email';
        comcop.Order__c = '1';
        comcop.Frequency__c = 'Immediate';
        comcop.Deployment_Run_After__c = '1';
        insert comCop;
        Communication_Component__c comcop1 = TestUtil.createCommunicationComponent(com1.Id, false); 
        comcop1.Channel__c = 'Email';
        comcop1.Order__c = '1';
        comcop1.Frequency__c = 'Immediate';
        comcop1.Deployment_Run_After__c = '1';
        insert comCop1;
        comcop1 = TestUtil.createCommunicationComponent(com1.Id, false); 
        comcop1.Channel__c = 'Email';
        comcop1.Order__c = '1';
        comcop1.Frequency__c = 'Scheduled';
        comcop1.Deployment_Run_After__c = '1';
        insert comCop1;
        
        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false); 
        opp.CloseDate = Date.valueOf('2020-01-29');
        opp.StageName = 'New';
        opp.Create_Quote_Shell__c = true;
        opp.Communication__c = 'Thank you';
        opp.RehashCommunication__c = 'Thank you';
        opp.Is_In_Communication__c = false;
        opp.Create_Quote_Shell__c = false;
        opp.StageName = 'Follow-Up';
        opp.status__c='Follow Up';
        opp.RecordTypeId = OppRecTyTCId ;
        insert opp;
        
        opp.Communication_1on1_Flag__c = true;
        opp.RehashCommunication__c = '1on1';
        opp.Already_Executed_Communication__c = 'test';
        opp.Create_Quote_Shell__c = true;
        
        List<Opportunity> oppList = new List<Opportunity>();        
        oppList.add(opp);
        update oppList;
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock1());
        OpportunityTriggerHandler.updateCommunicationStage(oppList,oldMap);
        
        opp.RehashCommunication__c = 'RH 5 Day';
        Map<Id,Opportunity> oldMapNew = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        OpportunityTriggerHandler.OpportunityCommunication(oppList,oldMapNew);
        Test.stopTest();
    }
    @isTest
    public static void OpportunityTriggerHandlerMethod2(){
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        Communication__c com = TestUtil.createCommunication(true);
        
        Communication_Component__c comcop = TestUtil.createCommunicationComponent(com.Id, true);        
        
        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false); 
        opp.CloseDate = Date.valueOf('2020-01-29');
        opp.StageName = 'New';
        opp.Create_Quote_Shell__c = true;
        opp.Communication__c = 'Thank you';
        opp.Is_In_Communication__c = false;
        opp.Create_Quote_Shell__c = false;
        opp.RecordTypeId = OppRecTyTCId ;
        insert opp;
        
        //opp.Communication__c = 'COM1';
        opp.Create_Quote_Shell__c = true;
        opp.StageName = 'Closed';
        
        List<Opportunity> oppList = new List<Opportunity>();        
        oppList.add(opp);
        update oppList;
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock1());
        OpportunityTriggerHandler.updateCommunicationStage(oppList,oldMap);
        Test.stopTest();
    }
    
    @isTest
    public static void OpportunityTriggerHandlerMethod3(){
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        Communication__c com = TestUtil.createCommunication(true);
        
        Communication_Component__c comcop = TestUtil.createCommunicationComponent(com.Id, true);        
        
        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false);
        opp.CloseDate = Date.valueOf('2020-01-29');
        opp.StageName = 'New';
        opp.Create_Quote_Shell__c = true;
        opp.Communication__c = 'Thank you';
        opp.Is_In_Communication__c = false;
        opp.Create_Quote_Shell__c = false;
        opp.RecordTypeId = OppRecTyTCId;
        insert opp;
        
        opp.Communication_1on1_Flag__c = true;
        opp.Communication__c = '1on1';
        opp.Already_Executed_Communication__c = 'test';
        opp.Create_Quote_Shell__c = true;
        opp.StageName = 'Follow-Up';
        
        List<Opportunity> oppList = new List<Opportunity>();        
        oppList.add(opp);
        update oppList;
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock1());
        OpportunityTriggerHandler.updateCommunicationStage(oppList,oldMap);
        Test.stopTest();
    }
    
    public static testMethod void triggerTest()
    {
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep');
        
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
        
        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        
        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        
        // Create 2nd Service Resource
        ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.RecordTypeId = OppRecTyTCId ;
        opp.Create_Quote_Shell__c = false;
        insert opp ;
        
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.Lead_Receiver__c = usr.Id;
        sa.OwnerId = usr.Id ;
        sa.Rehash_Appointment__c = false;
        insert sa;
        //sa.Status = 'Scheduled';
        //update sa;
        
        Test.startTest();
        OpportunityTriggerHandler.RUN_TRIGGER = true ;
        OpportunityTriggerHandler.CHANGE_OWNER_FOR_CANCEL_STATUS = true ;
        OpportunityTriggerHandler.CHANGE_OWNER_FOR_CANCEL_STATUS = true ;
        opp.OwnerId = UserInfo.getUserId() ;
        opp.Zone__c = childST.Id ;
        opp.Status__c = 'New';
        opp.Create_Quote_Shell__c = true;
        update opp ;
        
        
        OpportunityTriggerHandler.RUN_TRIGGER = true ;
        OpportunityTriggerHandler.CHANGE_OWNER_FOR_CANCEL_STATUS = true ;
        opp.Status__c = 'Canceled';
        update opp ;
        Test.stopTest();
        
    }
    public static testMethod void triggerTestNew()
    {
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep',Trade_Branch_Number__c='100');
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c='100';
        insert branch;
        
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
        
        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        
        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        
        // Create 2nd Service Resource
        ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.Status__c='open';
        opp.RecordTypeId = OppRecTyTCId ;
        insert opp ;
        
        
        
        Test.startTest();
        Opp=[SELECT  Id,Account.RecordType.DeveloperName,Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c, Account.Legacy_Party_Id__c, Account.PersonMailingStreet, Account.PersonMailingCity, Account.PersonMailingState, Account.Mdmrecid__c, 
             Account.PersonMailingPostalCode, Account.PersonMailingCountry, Account.Account_Status__c, Owner.LastName, Owner.FirstName, 
             Description, CreatedDate, LastModifiedDate, Name, Owner.EBS_UserName__c, Account_Branch_Profile__r.Branch__r.Branch_Number__c, 
             Create_Quote_Shell__c,RecordTypeId,RecordType.DeveloperName,Account.Parent.Mdmrecid__c, Market_Segment__c, 
             Account.parent.BillingStreet,Account.parent.BillingCity,Account.parent.BillingState,Business_Segment__c,BusinessSegment__c,
             Account.parent.BillingPostalCode,Account.parent.BillingCountry,Account.Branch__r.Branch_Number__c,Account.Branch__r.T_C_Branch_Number__c,
             street__c, city__c, state__c, country__c, zipcode__c, Account.Name
             FROM Opportunity WHERE ID = :opp.Id];
        OpportunityTriggerHandler.createJSONForPQM(opp);
        
        Test.stopTest();
        
        
    }
    
    public static testMethod void testActualAccCreateJSONForPQM() {
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        User usr = TestUtil.createUser(true);
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep',Trade_Branch_Number__c='100');
        // Create Account
        Account acPro_Lowes = TestUtil.createBranchAccount('Pro_Lowes', true);
        
        // Create 2nd Opportunity
        Opportunity oppPro_Lowes = TestUtil.createOpportunity('New Pro Lowes Opp', acPro_Lowes.Id, usr.Id, false); 
        oppPro_Lowes.Status__c='open';
        oppPro_Lowes.RecordTypeId = OppRecTyTCId ;
        insert oppPro_Lowes ;
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('Hard_Assign', 'subject', acPro_Lowes.Id, oppPro_Lowes.Id,  oppPro_Lowes.Id, true);
        Test.startTest();
        Opportunity Opp = [SELECT  Id,Account.RecordType.DeveloperName,Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c, Account.Legacy_Party_Id__c, Account.PersonMailingStreet, Account.PersonMailingCity, Account.PersonMailingState, Account.Mdmrecid__c, 
             Account.PersonMailingPostalCode, Account.PersonMailingCountry, Account.Account_Status__c, Owner.LastName, Owner.FirstName, 
             Description, CreatedDate, LastModifiedDate, Name, Owner.EBS_UserName__c, Account_Branch_Profile__r.Branch__r.Branch_Number__c, 
             Create_Quote_Shell__c,RecordTypeId,RecordType.DeveloperName,Account.Parent.Mdmrecid__c, Market_Segment__c, 
             Account.parent.BillingStreet,Account.parent.BillingCity,Account.parent.BillingState,Business_Segment__c,BusinessSegment__c,
             Account.parent.BillingPostalCode,Account.parent.BillingCountry,Account.Branch__r.Branch_Number__c,Account.Branch__r.T_C_Branch_Number__c,
             street__c, city__c, state__c, country__c, zipcode__c, Account.Name
             FROM Opportunity WHERE ID = :oppPro_Lowes.Id];
        OpportunityTriggerHandler.createJSONForPQM(Opp);
        Test.stopTest();
    }
    public static testMethod void triggerTest9()
    {
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep');
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        // create Camp rec
        Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
        //Cp.AOR__c=bf.Id;
        // Cp.Type='AOR';
        insert Cp;
        
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
        
        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        
        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        
        // Create 2nd Service Resource
        ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false); 
        opp.RecordTypeId = OppRecTyTCId ;
        insert opp ;
        
        
        Test.startTest();
        opp.CampaignId=Cp.Id;
        update opp ;
        
        Test.stopTest();
        
    }
    @isTest
    public static void OpportunityTriggerHandlerCommOwner(){
        Id OppRecTyRepId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
        
        User usr = TestUtil.createUser(false);
        usr.Trade_Branch_Number__c = '100' ;
        insert usr;
        Account ac = TestUtil.createAccount('Person Account', true);
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Commercial_Lead_Receiver__c = usr.Id;
        branch.Trade_Lead_Receiver__c  = usr.Id;
        branch.T_C_Branch_Number__c = '100';
        insert branch;
        // Create Account BranchProfile
        Account_Branch_Profile__c ABP = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        System.runAs(usr){
            Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false);
            opp.CloseDate = Date.valueOf('2020-12-29');
            opp.StageName = 'New';
            opp.Status__c = 'New';
            opp.RecordTypeId = OppRecTyRepId;
            opp.Account_Branch_Profile__c = ABP.Id;
            opp.Street__c = '123 Test St';
            insert opp;
            
            Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
            oldMap.put(opp.Id,opp);
            
            List<Opportunity> oppList = new List<Opportunity>(); 
            opp.StageName = 'Closed';
            opp.status__c = 'Transferred to Commercial';
            oppList.add(opp);
            update oppList;
            Test.startTest();
            OpportunityTriggerHandler.updateOppOwnerforTC(oppList,oldMap);
            Test.stopTest();
        }
    }
    @isTest
    public static void OpportunityTriggerHandlerTradeOwner(){
        Id OppRecTyRepId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
        
        User usr = TestUtil.createUser(false);
        usr.Trade_Branch_Number__c = '100' ;
        insert usr;
        Account ac = TestUtil.createAccount('Person Account', true);
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Commercial_Lead_Receiver__c = usr.Id;
        branch.Trade_Lead_Receiver__c  = usr.Id;
        branch.T_C_Branch_Number__c = '100';
        insert branch;
        // Create Account BranchProfile
        Account_Branch_Profile__c ABP = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        System.runAs(usr){
            Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false);
            opp.CloseDate = Date.valueOf('2020-12-29');
            opp.StageName = 'New';
            opp.Status__c = 'New';
            opp.RecordTypeId = OppRecTyRepId;
            opp.Account_Branch_Profile__c = ABP.Id;
            opp.Street__c = '123 Test St';
            insert opp;
            
            Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
            oldMap.put(opp.Id,opp);
            
            List<Opportunity> oppList = new List<Opportunity>(); 
            opp.StageName = 'Closed';
            opp.status__c = 'Transferred to New Construction';
            
            oppList.add(opp);
            update oppList;
            
            
            Test.startTest();
            OpportunityTriggerHandler.updateOppOwnerforTC(oppList,oldMap);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void OpportunityTriggerHandlerOppTeamMember(){
        
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
        Id AccRecTyPellaId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Organization').RecordTypeId;   
        
        User usr = TestUtil.createUser(true);
        //usr.Trade_Branch_Number__c = '100' ;
        //insert usr;
        Account pellaAcc = new Account(Name = 'Test BA 123', Type = 'Architectural / Design Firm',Phone ='(999) 666-6666',
                                       RecordTypeId=AccRecTyPellaId, Is_From_Custom_UI__c=true) ;
        insert pellaAcc ;
        
        Account ac = TestUtil.createBranchAccount('Branch Account' , false);
        ac.ParentId = pellaAcc.Id;
        insert ac;
        
        Opportunity opp = TestUtil.createOpportunity('Test1001', ac.Id, usr.Id, false);
        opp.CloseDate = Date.valueOf('2020-12-29');
        opp.StageName = 'New';
        opp.Status__c = 'Open';
        opp.RecordTypeId = OppRecTyTCId;
        opp.Type = 'Trade';
        opp.Market_Segment__c = 'SP: Single Family Replacement';
        opp.Approved_Status__c = 'Approved';
        
        insert opp;
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        List<Opportunity> oppList = new List<Opportunity>(); 
        oppList.add(opp);
        update oppList;
        
        Approval.ProcessSubmitRequest req =  new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval');
        req.setObjectId(opp.Id);
        
        req.setSubmitterId(UserInfo.getUserId());
        
        req.setProcessDefinitionNameOrId('Opportunity_Team_Addition');
        req.setSkipEntryCriteria(true);
        
        Approval.ProcessResult result = Approval.process(req);
        
        Approval.ProcessWorkitemRequest reqe =
            new Approval.ProcessWorkitemRequest();
        reqe.setComments('Approving request.');
        reqe.setAction('Approve');
        
        ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: opp.id];
        reqe.setWorkitemId(pItem.Id);
        Approval.ProcessResult resulta = Approval.process(reqe);
        Test.startTest();
        OpportunityTriggerHandler.createOppTeamMember(oppList,oldMap);
        Test.stopTest();
    }
    public static testMethod void testMethod1(){
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        // Create Account
        Account ac2 = TestUtil.createAccount('Person Account', false);
        ac2.FirstName='testrewc';
        ac2.LastName='tes2t2rewc';
        insert ac2;
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        insert opp;
        
        Test.startTest();
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        opp.AccountId=ac2.Id;
        update opp;
        Test.stopTest();
    }
    @isTest
    public static void OpportunityTriggerHandlerOppSplit(){
        // commented out as not able to enable opportunity split on prod
        
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
        Id AccRecTyPellaId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Organization').RecordTypeId;   
        
        User usr = TestUtil.createUser(true);
        //usr.Trade_Branch_Number__c = '100' ;
        //insert usr;
        
        User usrpal = TestUtil.createUser(false);
        usrpal.FirstName = 'Pallavi Test';
        usrpal.LastName = 'LN';
        insert usrpal;
        
        Account pellaAcc = new Account(Name = 'Test BA 123', Type = 'Architectural / Design Firm',Phone ='(999) 666-6666',
                                       RecordTypeId=AccRecTyPellaId, Is_From_Custom_UI__c=true) ;
        insert pellaAcc ;
        
        Account ac = TestUtil.createBranchAccount('Branch Account' , false);
        ac.ParentId = pellaAcc.Id;
        insert ac;
        
        Opportunity opp = TestUtil.createOpportunity('Test1001', ac.Id, usr.Id, false);
        opp.CloseDate = Date.valueOf('2020-12-29');
        opp.StageName = 'New';
        opp.Status__c = 'Open';
        opp.RecordTypeId = OppRecTyTCId;
        opp.Type = 'Trade';
        opp.Market_Segment__c = 'SP: Single Family Replacement';
        opp.OwnerId = usr.Id;
        
        insert opp;
        
        //create Opp Split type
        OpportunitySplitType oppSpTy = [SELECT Id, MasterLabel, DeveloperName, SplitEntity, SplitField FROM 
                                        OpportunitySplitType WHERE MasterLabel = 'Total Price Overlay Credit'];
        
        
        OpportunitySplit oppSplit = new OpportunitySplit(SplitTypeId = oppSpTy.Id, OpportunityId = opp.Id , 
                                                         SplitOwnerId = usr.id, SplitPercentage = 100,
                                                         SplitNote = 'Test' );
        insert oppSplit ;
        
        List<Opportunity> oppList = new List<Opportunity>();
        opp.OwnerId = usrpal.Id;
        oppList.add(opp);
        update oppList;
        
        
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp.Id,opp);
        
        Test.startTest();
        OpportunityTriggerHandler.createOppTeamMember(oppList,oldMap);
        
        OpportunityTriggerHandler.updateOpportunityConflictFlag(oppList[0].Id,false);
        Test.stopTest();
        
    }
    
    static testMethod void updatePYTDonAccountWhenStageNameChangesTest(){
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
        OpportunityTriggerHandler.RUN_TRIGGER = true;

        Quote quoteOne = TestUtil.createQuote(opportunity.Id, false);
        quoteOne.Quote_Number_PQM__c = '12345678' ;
        quoteOne.Customer_Extended_Price__c = 125000;
        quoteOne.BookDate__c = previousYearStartDate.addDays(15);
        quoteOne.Status = 'Booked';
        insert quoteOne;
        
        Date todayLastYear = System.today().addYears(-1);
        Quote quoteTwo = TestUtil.createQuote(opportunity.Id, false);
        quoteTwo.Quote_Number_PQM__c = '87654321' ;
		quoteTwo.Customer_Extended_Price__c = 175000;
        quoteTwo.BookDate__c = todayLastYear.addDays(-1);
        quoteTwo.Status = 'Ordered';
        insert quoteTwo;
        
        Test.startTest();     
        opportunity.Status__c = 'Closed';
		opportunity.StageName = 'Closed Won';
	
        update opportunity;
        Test.stopTest();
        
        Account accountAfterUpdate = [SELECT Id, PYTD_Sales__c FROM Account WHERE Id =: account.Id LIMIT 1];
        
        System.assertEquals(300000, accountAfterUpdate.PYTD_Sales__c);       
    }
    
    static testMethod void updatePYTDonAccountWhenStageNameAndAccountChangesTest(){
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
        
        Branch_Grouping__c branchFamilyOne = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branchOne = TestUtil.createBranch('Test', '100', branchFamilyOne.Id, true);
        Account accountOne = TestUtil.createBranchAccount('Branch Account', false);
        accountOne.Branch__c = branchOne.Id;
        insert accountOne;
        Account_Branch_Profile__c accountBranchProfileOne = TestUtil.createAccountBranchProfile(accountOne.Id, branchOne.Id, true);
         
        Branch_Grouping__c branchFamilyTwo = TestUtil.createBranchGrouping('BranchGrouping_2', true);
        Branch__c branchTwo = TestUtil.createBranch('Test', '102', branchFamilyTwo.Id, true);
        Account accountTwo = TestUtil.createBranchAccount('Branch Account', false);
        accountTwo.Branch__c = branchTwo.Id;
        insert accountTwo;
        Account_Branch_Profile__c accountBranchProfileTwo = TestUtil.createAccountBranchProfile(accountTwo.Id, branchTwo.Id, true);
        
        OpportunityTriggerHandler.RUN_TRIGGER = false;
        List<Opportunity> newOpportunities = new List<Opportunity> ();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        
		Opportunity opportunityOne = TestUtil.createOpportunity('New Opp 1', accountOne.Id, UserInfo.getUserId(), false);
        opportunityOne.Status__c = 'Open';
        opportunityOne.RecordTypeId = oppRecordTypeId;
        opportunityOne.Account_Branch_Profile__c = accountBranchProfileOne.Id;
        newOpportunities.add(opportunityOne);

        Opportunity opportunityTwo = TestUtil.createOpportunity('New Opp 2', accountTwo.Id, UserInfo.getUserId(), false);
        opportunityTwo.Status__c = 'Open';
        opportunityTwo.RecordTypeId = oppRecordTypeId;
        opportunityTwo.Account_Branch_Profile__c = accountBranchProfileTwo.Id;
        newOpportunities.add(opportunityTwo);
                             
		insert newOpportunities;
        OpportunityTriggerHandler.RUN_TRIGGER = true;

        Quote quoteOne = TestUtil.createQuote(opportunityOne.Id, false);
        quoteOne.Quote_Number_PQM__c = '56781234' ;
        quoteOne.Customer_Extended_Price__c = 25000;
        quoteOne.BookDate__c = previousYearStartDate.addDays(15);
        quoteOne.Status = 'Booked';
        insert quoteOne;
         
		Date todayLastYear = System.today().addYears(-1);
        Quote quoteTwo = TestUtil.createQuote(opportunityTwo.Id, false);
        quoteTwo.Quote_Number_PQM__c = '12345678' ;
        quoteTwo.Customer_Extended_Price__c = 75000;
        quoteTwo.BookDate__c = todayLastYear.addDays(-1);
        quoteTwo.Status = 'Ordered';
        insert quoteTwo;
         
        Test.startTest();     
        opportunityOne.Status__c = 'Closed';
		opportunityOne.StageName = 'Closed Won';
		opportunityOne.AccountId = accountTwo.Id;
        opportunityOne.Account_Branch_Profile__c = accountBranchProfileTwo.Id;

        update opportunityOne;
        Test.stopTest();
        
        List<Account> accountsAfterUpdate = [SELECT Id, PYTD_Sales__c FROM Account WHERE Id =: accountOne.Id OR Id =: accountTwo.Id LIMIT 2];
 
        System.assertEquals(0, accountsAfterUpdate[0].PYTD_Sales__c);       
        System.assertEquals(100000, accountsAfterUpdate[1].PYTD_Sales__c);       
    }
    
      static testMethod void updatePYTDonAccountUnrelatedFieldChangeNoCalculationsdTest(){
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
        opportunity.Status__c = 'Closed';
        opportunity.StageName = 'Closed Won';
        opportunity.RecordTypeId = oppRecordTypeId;
		insert opportunity;
        OpportunityTriggerHandler.RUN_TRIGGER = true;

        Quote quoteOne = TestUtil.createQuote(opportunity.Id, false);
        quoteOne.Quote_Number_PQM__c = '56781234' ;
        quoteOne.Customer_Extended_Price__c = 25000;
        quoteOne.BookDate__c = previousYearStartDate.addDays(15);
        quoteOne.Status = 'Booked';
        insert quoteOne;
         
		Date todayLastYear = System.today().addYears(-1);
        Quote quoteTwo = TestUtil.createQuote(opportunity.Id, false);
        quoteTwo.Quote_Number_PQM__c = '12345678' ;
        quoteTwo.Customer_Extended_Price__c = 25000;
        quoteTwo.BookDate__c = todayLastYear.addDays(-1);
        quoteTwo.Status = 'Ordered';
        insert quoteTwo;
         
        Test.startTest();     
        opportunity.Building_Type__c = 'Single Family';
		
        update opportunity;
        Test.stopTest();

      	Account accountAfterUpdate = [SELECT Id, PYTD_Sales__c FROM Account WHERE Id =: account.Id LIMIT 1];
 
        System.assertEquals(null, accountAfterUpdate.PYTD_Sales__c);       
    }
}