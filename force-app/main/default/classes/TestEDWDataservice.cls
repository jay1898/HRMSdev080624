/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: TestEDWDataservice to cover all the test cases for EDWDataservice and all Batch classes.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


@isTest
private class TestEDWDataservice {
    @testSetup
    static void dataSetup() {
        dateTime validToDate=DateTime.now();
        dateTime validFromDate=DateTime.now().AddDays(-10);
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        List<Opportunity> listOpps=new List<Opportunity>();
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp1', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c=DateTime.now();
        opp.EDW_Last_Modified__c=validToDate;
        listOpps.add(opp);
        //insert opp;
        // Create Opportunity
        Opportunity opp1 = TestUtil.createOpportunity('New Opp test', ac.Id, UserInfo.getUserId(), false); 
        opp1.Appointment_DateTime__c=DateTime.now();
        opp1.EDW_Last_Modified__c=validFromDate;
         listOpps.add(opp1);
        //insert opp1;
        insert listOpps;
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='12345' ;
        q.Status='Active';
        q.PO_Number__c='12345';
        insert q ;
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Gale';
        insert testUser;
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', false);
        bf.Branch_Family_Number__c = '123';
        insert bf;
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Branch__c branch1 = TestUtil.createBranch('Test1', '110', bf.Id, true); 
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        //string records=Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('zipcode').getRecordTypeId();
        recordtype obj= [select id,name from RecordType where sObjectType='ServiceTerritory' and Name='zipcode'];
        parentST.Branch__c = branch1.Id;
        parentST.RecordTypeId=obj.id;
        update parentST; 
        // Create Task
        Task tk = new task();
        tk.subject = 'Unresolved Email Unresolved Email Unresolved Email Unresolved Email';
        tk.Description = 'test task ref: ';
        tk.WhatId = opp.Id;
        insert tk; 
        User u = TestUtil.createUser(true);
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = ac.Id;
        insert sr;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=false;
        Event event = TestUtil.createEvent(u.Id, false); 
        event.ShowAs = 'Busy';
        event.WhatId = opp.Id;
        event.EDW_Last_Modified__c=validFromDate;
        insert event;
        //create Event
        Event objevent = TestUtil.createEvent(u.Id, false); 
        objevent.ShowAs = 'Busy';
        objevent.WhatId = opp.Id;
        objevent.EDW_Last_Modified__c=validToDate;
        insert objevent;
        
    }
    static testMethod void testGet() {
        string validTo= '2020-10-26 00:00:00.000z';
        string validFrom= '2020-09-16 00:00:00.000z';
        // create response 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EDWDataservice/?validFrom=2020-09-16 00:00:00.000z&validTo=2020-10-26 00:00:00.000z';
        req.httpMethod = 'GET';
        req.addHeader('httpMethod', 'GET');
        RestContext.request = req;
        RestContext.response= res;
        req.params.put('validFrom','2020-09-16 00:00:00.000z');
        req.params.put('validTo','2020-09-18 00:00:00.000z');
        res.statusCode=200;
        req.requestBody = Blob.valueof('Your request is being processed and results will be provided shortly\n TxnId-');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MapLocationCalloutMock()); 
        EDWDataservice acctResp = new EDWDataservice();
        EDWDataservice.getRequestParameter();
        Test.stopTest(); 
        List<Apex_Debug_Log__c> objADL=[select id, name from Apex_Debug_Log__c];
        System.assertEquals(true, objADL.size()>0);
    }
    static testMethod void testGetException() {
        // create response 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EDWDataservice/?validFrom=2020-09-16 00:00:00.000z&validTo=2020-10-26 00:00:00.000z';
        req.httpMethod = 'GET';
        req.addHeader('httpMethod', 'GET');
        RestContext.request = req;
        RestContext.response= res;
        res.statusCode=200;
        req.requestBody = Blob.valueof('Your request is being processed and results will be provided shortly\n TxnId-');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MapLocationCalloutMock()); 
        // Intialization of ADL object to create a ADL record
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex.Opportunity__c=true;
        objApex.Apex_Class__c='EDWDataservice';
        objApex.Method__c='GET';
        insert objApex;
        //Query to fetch the ADL record ID for Opportunity
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Opportunity__c=true ORDER BY Name DESC limit 1];
        objApex.EDW_Transaction_ID__c=lstApexDebug[0].Id;
        objApex.id=lstApexDebug[0].id;
        update objApex;
        string TxnId = lstApexDebug[0].Id;
        dateTime validFrom=DateTime.now().AddDays(-10);
        dateTime validTo=DateTime.now();
        OpportunityBatchprocess objOpp = new OpportunityBatchprocess(validFrom,validTo,TxnId,true);
        Database.executeBatch( objOpp , 1000);
        
        Test.stopTest(); 
        List<Apex_Debug_Log__c> objADL=[select id, name from Apex_Debug_Log__c];
        System.assertEquals(true, objADL.size()>1);
    }
     static testMethod void testGetException3() {
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MapLocationCalloutMock()); 
         Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
         Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
         
         Branch__c br = TestUtil.createBranch('Test Branch2', '1001', bf.Id, true);
         
         Account parentAcc = TestUtil.createBranchAccount('Pella Account', false);
         parentAcc.Temp_branch_Number__c = '5';
         parentAcc.Branch_Number__c = '10';
         insert parentAcc;
         
         Account childAcc = TestUtil.createBranchAccount('Branch Account', false);
         childAcc.ParentId = parentAcc.Id;
         childAcc.Branch__c = br.Id;
         childAcc.Temp_branch_Number__c = '5';
         childAcc.Branch_Number__c = '10';
         
         Database.DMLOptions dml = new Database.DMLOptions();
         dml.DuplicateRuleHeader.allowSave = true;
         dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
         Database.SaveResult saveResult = Database.insert(childAcc, dml);
         
         Opportunity opp = TestUtil.createOpportunity('Test1001', childAcc.Id, userinfo.getUserId(), false);
         opp.CloseDate = Date.valueOf('2020-12-29');
         opp.StageName = 'New';
         opp.Status__c = 'Open';
         opp.RecordTypeId = OppRecTyTCId;
         opp.Type = 'Trade';
         opp.Market_Segment__c = 'SP: Single Family Replacement';
         opp.Approved_Status__c = 'Approved';
         
         insert opp;
         
         
         Quote q = TestUtil.createQuote(opp.Id, false);
         q.Quote_Number_PQM__c='8989' ;
         q.Status='Active';
         insert q ;
         
        // create response 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EDWDataservice/?validFrom=2020-10-06 00:00:00.000z&validTo=2020-10-06 00:00:00.000z';
        req.httpMethod = 'GET';
        req.addHeader('httpMethod', 'GET');
        RestContext.request = req;
        RestContext.response= res;
        res.statusCode=200;
        req.requestBody = Blob.valueof('Your request is being processed and results will be provided shortly\n TxnId-');
        
        // Intialization of ADL object to create a ADL record
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex.Opportunity__c=true;
        objApex.Apex_Class__c='EDWDataservice';
        objApex.Method__c='GET';
        insert objApex;
        //Query to fetch the ADL record ID for Opportunity
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Opportunity__c=true ORDER BY Name DESC limit 1];
        objApex.EDW_Transaction_ID__c=lstApexDebug[0].Id;
        objApex.id=lstApexDebug[0].id;
        update objApex;
        string TxnId = lstApexDebug[0].Id;
        dateTime validFrom=DateTime.now().AddDays(-10);
        dateTime validTo=DateTime.now();
        OpportunityBatchprocess objOpp = new OpportunityBatchprocess(validFrom,validTo,TxnId,true);
        Database.executeBatch( objOpp , 1000);
        
        
        Test.stopTest(); 
        List<Apex_Debug_Log__c> objADL=[select id, name from Apex_Debug_Log__c];
        System.assertEquals(true, objADL.size()>1);
    }
     static testMethod void testGetException2() {
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MapLocationCalloutMock()); 
         Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
         Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
         
         Branch__c br = TestUtil.createBranch('Test Branch2', '1001', bf.Id, true);
         
         Account parentAcc = TestUtil.createBranchAccount('Pella Account', false);
         parentAcc.Temp_branch_Number__c = '5';
         parentAcc.Branch_Number__c = '10';
         insert parentAcc;
         
         Account childAcc = TestUtil.createBranchAccount('Branch Account', false);
         childAcc.ParentId = parentAcc.Id;
         childAcc.Branch__c = br.Id;
         childAcc.Temp_branch_Number__c = '5';
         childAcc.Branch_Number__c = '10';
         
         Database.DMLOptions dml = new Database.DMLOptions();
         dml.DuplicateRuleHeader.allowSave = true;
         dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
         Database.SaveResult saveResult = Database.insert(childAcc, dml);
         
         Opportunity opp = TestUtil.createOpportunity('Test1001', childAcc.Id, userinfo.getUserId(), false);
         opp.CloseDate = Date.valueOf('2020-12-29');
         opp.StageName = 'New';
         opp.Status__c = 'Open';
         opp.RecordTypeId = OppRecTyTCId;
         opp.Type = 'Trade';
         opp.Market_Segment__c = 'SP: Single Family Replacement';
         opp.Approved_Status__c = 'Approved';
         
         insert opp;
         
         
         Quote q = TestUtil.createQuote(opp.Id, false);
         q.Quote_Number_PQM__c='8989' ;
         q.Status='Active';
         insert q ;
         
        // create response 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EDWDataservice/?validFrom=2020-09-16 00:00:00.000z&validTo=2020-10-26 00:00:00.000z';
        req.httpMethod = 'GET';
        req.addHeader('httpMethod', 'GET');
        RestContext.request = req;
        RestContext.response= res;
        res.statusCode=200;
        req.requestBody = Blob.valueof('Your request is being processed and results will be provided shortly\n TxnId-');
        
        // Intialization of ADL object to create a ADL record
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex.Opportunity__c=true;
        objApex.Apex_Class__c='EDWDataservice';
        objApex.Method__c='GET';
        insert objApex;
        //Query to fetch the ADL record ID for Opportunity
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Opportunity__c=true ORDER BY Name DESC limit 1];
        objApex.EDW_Transaction_ID__c=lstApexDebug[0].Id;
        objApex.id=lstApexDebug[0].id;
        update objApex;
        string TxnId = lstApexDebug[0].Id;
        dateTime validFrom=DateTime.now().AddDays(-10);
        dateTime validTo=DateTime.now();
        DailyEDWOpportunityFeed objOpp = new DailyEDWOpportunityFeed(validFrom,validTo,TxnId,true);
        Database.executeBatch( objOpp , 1000);
         
         HistoricalEDWOpportunityFeed objOpp2 = new HistoricalEDWOpportunityFeed(validFrom,validTo,TxnId,true);
         Database.executeBatch( objOpp2 , 1000);
        
        Test.stopTest(); 
        List<Apex_Debug_Log__c> objADL=[select id, name from Apex_Debug_Log__c];
        System.assertEquals(true, objADL.size()>1);
    }
    static testMethod void testGetException4() {
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MapLocationCalloutMock()); 
         Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
         Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
         
         Branch__c br = TestUtil.createBranch('Test Branch2', '1001', bf.Id, true);
         
         Account parentAcc = TestUtil.createBranchAccount('Pella Account', false);
         parentAcc.Temp_branch_Number__c = '5';
         parentAcc.Branch_Number__c = '10';
         insert parentAcc;
         
         Account childAcc = TestUtil.createBranchAccount('Branch Account', false);
         childAcc.ParentId = parentAcc.Id;
         childAcc.Branch__c = br.Id;
         childAcc.Temp_branch_Number__c = '5';
         childAcc.Branch_Number__c = '10';
         
         Database.DMLOptions dml = new Database.DMLOptions();
         dml.DuplicateRuleHeader.allowSave = true;
         dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
         Database.SaveResult saveResult = Database.insert(childAcc, dml);
         
         Opportunity opp = TestUtil.createOpportunity('Test1001', childAcc.Id, userinfo.getUserId(), false);
         opp.CloseDate = Date.valueOf('2020-12-17');
         opp.StageName = 'New';
         opp.Status__c = 'Open';
         opp.RecordTypeId = OppRecTyTCId;
         opp.Type = 'Trade';
         opp.Market_Segment__c = 'SP: Single Family Replacement';
         opp.Approved_Status__c = 'Approved';
         
         insert opp;
         
         
         Quote q = TestUtil.createQuote(opp.Id, false);
         q.Quote_Number_PQM__c='8989' ;
         q.BookDate__c=Date.valueOf('2020-12-17');
         q.Status='Active';
         insert q ;
         
        // create response 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EDWDataservice/?validFrom=2020-09-16 00:00:00.000z&validTo=2020-09-18 00:00:00.000z';
        req.httpMethod = 'GET';
        req.addHeader('httpMethod', 'GET');
        RestContext.request = req;
        req.params.put('validFrom','2020-09-18 00:00:00.000z');
        req.params.put('validTo','2020-09-16 00:00:00.000z');
        RestContext.response= res;
        res.statusCode=200;
        req.requestBody = Blob.valueof('Your request is being processed and results will be provided shortly\n TxnId-');
        
        EDWDataservice acctResp = new EDWDataservice();
        EDWDataservice.getRequestParameter();
        req.params.put('validFrom','2020-09-1600:00:00.000z');
        req.params.put('validTo','2020-09-2500:00:00.000z');
        EDWDataservice.getRequestParameter();
        req.params.put('validFrom','2020-09-16 00:00:00.000z');
        req.params.put('validTo','2020-09-25 00:00:00.000z');
        EDWDataservice.getRequestParameter();
        
        
        // Intialization of ADL object to create a ADL record
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex.Opportunity__c=true;
        objApex.Apex_Class__c='EDWDataservice';
        objApex.Method__c='GET';
        insert objApex;
        //Query to fetch the ADL record ID for Opportunity
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Opportunity__c=true ORDER BY Name DESC limit 1];
        objApex.EDW_Transaction_ID__c=lstApexDebug[0].Id;
        objApex.id=lstApexDebug[0].id;
        update objApex;
        string TxnId = lstApexDebug[0].Id;
        dateTime validFrom=DateTime.now().AddDays(-10);
        dateTime validTo=DateTime.now();
        DailyEDWOpportunityFeed objOpp = new DailyEDWOpportunityFeed(validFrom,validTo,TxnId,true);
        Database.executeBatch( objOpp , 1000);
         
         HistoricalEDWOpportunityFeed objOpp2 = new HistoricalEDWOpportunityFeed(validFrom,validTo,TxnId,true);
         Database.executeBatch( objOpp2 , 1000);
        
        Test.stopTest(); 
        List<Apex_Debug_Log__c> objADL=[select id, name from Apex_Debug_Log__c];
        System.assertEquals(true, objADL.size()>1);
    }
    
}