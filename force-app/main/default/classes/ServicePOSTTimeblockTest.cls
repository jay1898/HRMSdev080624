@isTest
private class ServicePOSTTimeblockTest 
{
    static testMethod void testMethod1() 
    {
        User u = TestUtil.createUser(true);
        
        User u3 = TestUtil.createUser(false);
        u3.Email = 'test3_' + System.currentTimeMillis() + '@test232323.com';
        u3.Username = 'test3_3344@test3434.com' + System.currentTimeMillis();
        insert u3;
        
        User u2 = TestUtil.createUser(false);
        u2.Email = 'test2_' + System.currentTimeMillis() + '@test23232323.com';
        u2.Username = 'test2_2344@test3434.com' + System.currentTimeMillis();
        insert u2;
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep');
        
        Id rtZone = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('RT Zone').getRecordTypeId();
        Id nrtZone = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('NRT Zone').getRecordTypeId();
        Id Zipcode= Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();
        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Los_Angeles';
        insert oh;
        
        Time startTime = Time.newInstance(1, 1, 1, 1);
        Time endTime = Time.newInstance(23, 59, 59, 59);
        
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Monday';
        ts.Type = 'Normal';
        insert ts;
        
        TimeSlot ts1 = TestUtil.createTimeSlot(oh.Id, false);
        ts1.DayOfWeek = 'Tuesday';
        ts1.Type = 'Normal';
        insert ts1;
        
        TimeSlot ts2 = TestUtil.createTimeSlot(oh.Id, false);
        ts2.DayOfWeek = 'Wednesday';
        ts2.Type = 'Normal';
        insert ts2;
        
        TimeSlot ts3 = TestUtil.createTimeSlot(oh.Id, false);
        ts3.DayOfWeek = 'Thursday';
        ts3.Type = 'Normal';
        insert ts3;
        
        TimeSlot ts4 = TestUtil.createTimeSlot(oh.Id, false);
        ts4.DayOfWeek = 'Friday';
        ts4.Type = 'Normal';
        insert ts4;
        
        TimeSlot ts5 = TestUtil.createTimeSlot(oh.Id, false);
        ts5.DayOfWeek = 'Saturday';
        ts5.Type = 'Normal';
        insert ts5;
        
        TimeSlot ts6 = TestUtil.createTimeSlot(oh.Id, false);
        ts6.DayOfWeek = 'Sunday';
        ts6.Type = 'Normal';
        insert ts6;
        
        //Parent Level Territory
        ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, false);
        stParent.PostalCode = '11111';
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '22222';
        stZone.Lead_Receiver__c = u2.id;
        stZone.RecordTypeId = rtZone;
        insert stZone;
        
        //ZipCode Level Territory
        ServiceTerritory stZip = TestUtil.createSubChildServiceTerritory('Sub Child', stZone.Id, oh.Id, false);
        stZip.IsActive= true;
        stZip.PostalCode = '33333';
        stZip.RecordTypeId = Zipcode;
        insert stZip;
        
        //Zone Level Territory
        ServiceTerritory stZone2 = TestUtil.createChildServiceTerritory('Child1', stParent.Id, oh.Id, false);
        stZone2.IsActive= true;
        stZone2.PostalCode = '44444';
        stZone2.Lead_Receiver__c = u2.id;
        stZone2.RecordTypeId = rtZone;
        insert stZone2;
        
        //ZipCode1 Level Territory
        ServiceTerritory stZip1 = TestUtil.createSubChildServiceTerritory('Sub Child1', stZone2.Id, oh.Id, false);
        stZip1.IsActive= true;
        stZip1.PostalCode = '55555';
        stZip1.RecordTypeId = Zipcode;
        insert stZip1;
        
        //ZipCode2 Level Territory
        ServiceTerritory stZip2 = TestUtil.createSubChildServiceTerritory('Sub Child2', stZone2.Id, oh.Id, false);
        stZip2.IsActive= true;
        stZip2.PostalCode = '66666';
        stZip2.RecordTypeId = Zipcode;
        insert stZip2;
        
        
        ServiceTerritory stZone1 = TestUtil.createChildServiceTerritory('Child2', stZip.Id, oh.Id, false);
        stZone1.IsActive= true;
        stZone1.Lead_Receiver__c = u2.id;
        stZone1.PostalCode = '77777';
        insert stZone1;
        
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        sr.In_home_Eligible__c = TRUE;
        sr.Virtual_Eligible__c = TRUE;
        sr.Primary_Replacement_Territory__c = stParent.id;
        sr.Override_Replacement_Rep__c = TRUE;
        insert sr;
        
        ServiceResource sr3 = TestUtil.createServiceResource('Kalyan', u3.Id, branch.Id, bf.Id, false);
        sr3.AccountId = acc.Id;
        sr3.In_home_Eligible__c = TRUE;
        sr3.Virtual_Eligible__c = TRUE;
        sr3.Primary_Replacement_Territory__c = stParent.id;
        sr3.Override_Replacement_Rep__c = TRUE;
        insert sr3;
        
        ServiceResource sr2 = TestUtil.createServiceResource('Mayank1', u2.Id, branch.Id, bf.Id, false);
        sr2.AccountId = acc.Id;
        sr.In_home_Eligible__c = TRUE;
        sr.Virtual_Eligible__c = TRUE;
        sr2.Primary_Replacement_Territory__c = stParent.id;
        sr2.Override_Replacement_Rep__c = TRUE;
        insert sr2;
        
        DateTime startDateTime = DateTime.now();
        DateTime endDateTime = startDateTime.adddays(1);
        
        ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember(sr.Id, stZone.Id, true);
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, stZone.Id, true);
        ServiceTerritoryMember stm3 = TestUtil.createServiceTerritoryMember(sr3.Id, stZone.Id, true);
        
       //ServiceTerritoryMember stm4 = TestUtil.createServiceTerritoryMember1(sr.Id, stZone1.Id, true);
        //ServiceTerritoryMember stm6 = TestUtil.createServiceTerritoryMember1(sr3.Id, stZone1.Id, true);

        ServiceTerritoryMember stm7 = TestUtil.createServiceTerritoryMember2(sr.Id, stZone2.Id, true);
        ServiceTerritoryMember stm9 = TestUtil.createServiceTerritoryMember2(sr3.Id, stZone2.Id, true);
        
        
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp', acc.Id, u.Id, false);
        testOpportunity.zone__C = stZone.id;
        insert testOpportunity;
        
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', acc.Id, testOpportunity.Id, testOpportunity.Id, false);
        sa.ServiceTerritoryId = stZone.Id;
        sa.Country='US';
        //sa.ownerid= u.Id;
        ServiceAppointmentTriggerHandler.run_Trigger = false ;
        insert sa;
        
        AssignedResource ar = new AssignedResource();
        ar.ServiceResourceId = sr.Id;
        ar.ServiceAppointmentId = sa.Id;
        insert ar;
        
        ResourceAbsence ra = new ResourceAbsence();
        ra.ResourceId = sr.Id;
        ra.Start = startDateTime;
        ra.End = endDateTime;
        ra.Type = 'Training';
       
        ResourceAbsenceTriggerHandler.runTrigger = false;
        insert ra;
        
        
        // Make JSON 
        String jsonStr = '{ "oppNo":"123452119394", "start":"'+DateTime.now()+'", "end":"'+DateTime.now().adddays(1)+'","type":"Block", "zipcode":"33333", "appType":"home"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ServicePOSTTimeblock.postData();
        
        jsonStr = '{ "oppNo":"123452119395", "start":"'+DateTime.now()+'", "end":"'+DateTime.now().adddays(1)+'","type":"Block", "zipcode":"55555", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        
        jsonStr = '{ "oppNo":"123452119396", "start":"'+DateTime.now()+'", "end":"'+DateTime.now().adddays(1)+'","type":"Block", "zipcode":"66666", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        jsonStr = '{ "oppNo":"123452119394", "start":"'+DateTime.now()+'", "end":"'+DateTime.now().addhours(10)+'","type":"Both", "zipcode":"33333", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        
        jsonStr = '{ "oppNo":"123452119396", "start":"'+DateTime.now()+'", "end":"'+DateTime.now().addhours(15)+'","type":"Both", "zipcode":"33333", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        jsonStr = '{ "oppNo":"123452119396", "start":"'+DateTime.now()+'", "end":"'+DateTime.now().adddays(1)+'","type":"Unblock", "zipcode":"33333", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        jsonStr = '{ "oppNo":"123452119396", "start":"'+DateTime.now()+'", "end":"","type":"Unblock", "zipcode":"33333", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        jsonStr = '{ "oppNo":"123452119396", "start":"'+DateTime.now()+'", "end":"+DateTime.now().adddays(1)+","type":"Unblock", "zipcode":"33333", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        Test.stopTest();
        
    }
    static testMethod void noResourceAvailable() 
    {
         User u = TestUtil.createUser(true);
        
        User u3 = TestUtil.createUser(false);
        u3.Email = 'test3_' + System.currentTimeMillis() + '@test232323.com';
        u3.Username = 'test3_3344@test3434.com' + System.currentTimeMillis();
        insert u3;
        
        User u2 = TestUtil.createUser(false);
        u2.Email = 'test2_' + System.currentTimeMillis() + '@test23232323.com';
        u2.Username = 'test2_2344@test3434.com' + System.currentTimeMillis();
        insert u2;
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep');
        
        Id rtZone = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('RT Zone').getRecordTypeId();
        Id nrtZone = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('NRT Zone').getRecordTypeId();
        Id Zipcode= Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();
        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Los_Angeles';
        insert oh;
        
        Time startTime = Time.newInstance(1, 1, 1, 1);
        Time endTime = Time.newInstance(23, 59, 59, 59);
        
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Monday';
        ts.Type = 'Normal';
        insert ts;
        
        TimeSlot ts1 = TestUtil.createTimeSlot(oh.Id, false);
        ts1.DayOfWeek = 'Tuesday';
        ts1.Type = 'Normal';
        insert ts1;
        
        TimeSlot ts2 = TestUtil.createTimeSlot(oh.Id, false);
        ts2.DayOfWeek = 'Wednesday';
        ts2.Type = 'Normal';
        insert ts2;
        
        TimeSlot ts3 = TestUtil.createTimeSlot(oh.Id, false);
        ts3.DayOfWeek = 'Thursday';
        ts3.Type = 'Normal';
        insert ts3;
        
        TimeSlot ts4 = TestUtil.createTimeSlot(oh.Id, false);
        ts4.DayOfWeek = 'Friday';
        ts4.Type = 'Normal';
        insert ts4;
        
        TimeSlot ts5 = TestUtil.createTimeSlot(oh.Id, false);
        ts5.DayOfWeek = 'Saturday';
        ts5.Type = 'Normal';
        insert ts5;
        
        TimeSlot ts6 = TestUtil.createTimeSlot(oh.Id, false);
        ts6.DayOfWeek = 'Sunday';
        ts6.Type = 'Normal';
        insert ts6;
        
        //Parent Level Territory
        ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, false);
        stParent.PostalCode = '11111';
        stParent.IsActive = true;
        insert stParent;
        
        //Zone Level Territory
        ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child', stParent.Id, oh.Id, false);
        stZone.IsActive= true;
        stZone.PostalCode = '22222';
        stZone.Lead_Receiver__c = u2.id;
        stZone.RecordTypeId = rtZone;
        insert stZone;
        
        //ZipCode Level Territory
        ServiceTerritory stZip = TestUtil.createSubChildServiceTerritory('Sub Child', stZone.Id, oh.Id, false);
        stZip.IsActive= true;
        stZip.PostalCode = '33333';
        stZip.RecordTypeId = Zipcode;
        insert stZip;
        
        //Zone Level Territory
        ServiceTerritory stZone2 = TestUtil.createChildServiceTerritory('Child1', stParent.Id, oh.Id, false);
        stZone2.IsActive= true;
        stZone2.PostalCode = '44444';
        stZone2.Lead_Receiver__c = u2.id;
        stZone2.RecordTypeId = rtZone;
        insert stZone2;
        
        //ZipCode1 Level Territory
        ServiceTerritory stZip1 = TestUtil.createSubChildServiceTerritory('Sub Child1', stZone2.Id, oh.Id, false);
        stZip1.IsActive= true;
        stZip1.PostalCode = '55555';
        stZip1.RecordTypeId = Zipcode;
        insert stZip1;
        
        //ZipCode2 Level Territory
        ServiceTerritory stZip2 = TestUtil.createSubChildServiceTerritory('Sub Child2', stZone2.Id, oh.Id, false);
        stZip2.IsActive= true;
        stZip2.PostalCode = '66666';
        stZip2.RecordTypeId = Zipcode;
        insert stZip2;
        
        
        ServiceTerritory stZone1 = TestUtil.createChildServiceTerritory('Child2', stZip.Id, oh.Id, false);
        stZone1.IsActive= true;
        stZone1.Lead_Receiver__c = u2.id;
        stZone1.PostalCode = '77777';
        insert stZone1;
        
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        sr.In_home_Eligible__c = TRUE;
        sr.Virtual_Eligible__c = TRUE;
        sr.Primary_Replacement_Territory__c = stParent.id;
        sr.Override_Replacement_Rep__c = TRUE;
        insert sr;
        
        ServiceResource sr3 = TestUtil.createServiceResource('Kalyan', u3.Id, branch.Id, bf.Id, false);
        sr3.AccountId = acc.Id;
        sr3.In_home_Eligible__c = TRUE;
        sr3.Virtual_Eligible__c = TRUE;
        sr3.Primary_Replacement_Territory__c = stParent.id;
        sr3.Override_Replacement_Rep__c = TRUE;
        insert sr3;
        
        ServiceResource sr2 = TestUtil.createServiceResource('Mayank1', u2.Id, branch.Id, bf.Id, false);
        sr2.AccountId = acc.Id;
        sr.In_home_Eligible__c = TRUE;
        sr.Virtual_Eligible__c = TRUE;
        sr2.Primary_Replacement_Territory__c = stParent.id;
        sr2.Override_Replacement_Rep__c = TRUE;
        insert sr2;
        
        DateTime startDateTime = DateTime.now();
        DateTime endDateTime = startDateTime.adddays(1);
        
        ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember(sr.Id, stZone.Id, true);
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, stZone.Id, true);
        ServiceTerritoryMember stm3 = TestUtil.createServiceTerritoryMember(sr3.Id, stZone.Id, true);
        
       //ServiceTerritoryMember stm4 = TestUtil.createServiceTerritoryMember1(sr.Id, stZone1.Id, true);
        //ServiceTerritoryMember stm6 = TestUtil.createServiceTerritoryMember1(sr3.Id, stZone1.Id, true);

        ServiceTerritoryMember stm7 = TestUtil.createServiceTerritoryMember2(sr.Id, stZone2.Id, true);
        ServiceTerritoryMember stm9 = TestUtil.createServiceTerritoryMember2(sr3.Id, stZone2.Id, true);
        
        
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, true);
        
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', acc.Id, testOpportunity.Id, testOpportunity.Id, false);
        sa.ServiceTerritoryId = stZone.Id;
        sa.Country='US';
       // insert sa;
        
      //  AssignedResource ar = TestUtil.createAssignedResource(sr.Id,sa.Id, true);
        
        ResourceAbsence ra = TestUtil.createResourceAbsence(sr.Id, true);
        
        // Make JSON 
        String jsonStr = '{ "oppNo":"123452119394", "start":"'+DateTime.now().addHours(10)+'", "end":"'+DateTime.now().addHours(11)+'","type":"Block", "zipcode":"33333", "appType":"home"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ServicePOSTTimeblock.postData();
        
        jsonStr = '{ "oppNo":"", "end":"'+DateTime.now().addHours(11)+'","type":"unBlock", "zipcode":"30000", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        jsonStr = '{ "oppNo":"", "end":"'+DateTime.now().addHours(11)+'","type":"unBlock" "zipcode":"12345", "appType":"home"}';
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTTimeblock.postData();
        
        
        
        Test.stopTest();
        
    }
}