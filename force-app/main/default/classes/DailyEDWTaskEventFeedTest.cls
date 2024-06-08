@isTest
public class DailyEDWTaskEventFeedTest {
    @testSetup
    static void dataSetup() {
        dateTime validToDate=DateTime.now();
        dateTime validFromDate=DateTime.now().AddDays(-10);
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp1', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c=DateTime.now();
        opp.EDW_Last_Modified__c=validToDate;
        insert opp;
        // Create Opportunity
        Opportunity opp1 = TestUtil.createOpportunity('New Opp test', ac.Id, UserInfo.getUserId(), false); 
        opp1.Appointment_DateTime__c=DateTime.now();
        opp1.EDW_Last_Modified__c=validFromDate;
        insert opp1;
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
    
    static testMethod void testGet1() {
        // Intialization of ADL object to create a ADL record
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex.Activity__c=true;
        objApex.Apex_Class__c='DailyEDWTaskFeed';
        objApex.Method__c='GET';
        insert objApex;
        
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Activity__c=true ORDER BY Name DESC limit 1];
        objApex.EDW_Transaction_ID__c=lstApexDebug[0].Id;
        objApex.id=lstApexDebug[0].id;
        update objApex;
        string TxnId = lstApexDebug[0].Id;
        dateTime validFrom=DateTime.now().AddDays(-10);
        dateTime validTo=DateTime.now();
        
        string csvname= 'Task-' + TxnId +'-'+String.valueOf(Date.today()).replace(' ' , '_')+'.csv';
        //Insert the csv file in File object
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = Blob.valueOf('Test');
        ContVerFile.Title = csvname; 
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient= csvname;
        insert ContVerFile;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MapLocationCalloutMock()); 
        DailyEDWTaskFeed objTask = new DailyEDWTaskFeed(validFrom,validTo,TxnId);
        objTask.newAdlId = TxnId;
        objTask.contentDocumentId = conDoc;
        Database.executeBatch( objTask , 1000);
        Test.stopTest();
    }
    
    static testMethod void testGet2() {
        // Intialization of ADL object to create a ADL record
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex.Activity__c=true;
        objApex.Apex_Class__c='DailyEDWEventFeed';
        objApex.Method__c='GET';
        insert objApex;
        
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Activity__c=true ORDER BY Name DESC limit 1];
        objApex.EDW_Transaction_ID__c=lstApexDebug[0].Id;
        objApex.id=lstApexDebug[0].id;
        update objApex;
        string TxnId = lstApexDebug[0].Id;
        dateTime validFrom=DateTime.now().AddDays(-10);
        dateTime validTo=DateTime.now();
        
        string csvname= 'Activity-' + TxnId +'-'+String.valueOf(Date.today()).replace(' ' , '_')+'.csv';
        //Insert the csv file in File object
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = Blob.valueOf('Test');
        ContVerFile.Title = csvname; 
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient= csvname;
        insert ContVerFile;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MapLocationCalloutMock()); 
        DailyEDWEventFeed objEvent = new DailyEDWEventFeed(validFrom,validTo,TxnId, '');
        objEvent.newAdlId = TxnId;
        objEvent.contentDocumentId = conDoc;
        Database.executeBatch( objEvent , 1000);
        Test.stopTest(); 
    }
}