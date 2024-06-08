@isTest
public class RTAIntegrationTest 
{
    
    @isTest
    public static void RTAIntegrationTest1(){
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
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Monday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Tuesday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Wednesday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Thursday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Friday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Saturday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Sunday';
        insert ts;
            
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, false);
        subChildST.postalcode='12122';
        insert subChildST;
        
        Id chidlRTId = Schema.SObjectType.ServiceTerritory.recordTypeInfosByDeveloperName.get('NRT_Zone').RecordTypeId;
      
         // Create Child Territory under Parent Territory
        ServiceTerritory childST1 = TestUtil.createChildServiceTerritory('Child NRT', parentST.Id, oh.Id, false);
        childST1.Lead_Receiver__c = UserInfo.getUserId() ;
        childST1.RecordTypeId=chidlRTId;
        insert childST1 ;
        
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST1 = TestUtil.createSubChildServiceTerritory('Sub Child NRT', childST1.Id, oh.Id, false);
        subChildST1.postalcode='85858';
         insert subChildST1;
        
        
        
         // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, false);
        sr1.Primary_Replacement_Territory__c = parentST.id;
        sr1.Override_Replacement_Rep__c = TRUE;
        insert sr1;
        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 

        // Create 2nd Service Resource
        ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, false);
        sr2.Primary_Replacement_Territory__c = parentST.id;
        sr2.Override_Replacement_Rep__c = TRUE;
        insert sr2;

        // Create 2nd Service Territory Member for 2nd Resource
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 

        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 

        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false);
        opp.Best_Match__c = usr.Id ;
        opp.Appointment_Type__c = 'RT' ;
        insert opp ;
        
        Campaign cmp= TestUtil.createCampaign('Camp1',branch.Id,false);
        //cmp.Business_Segment__c = 'Trade';
        insert cmp;
        
        RTA_Timeblock__c TimeBlock=TestUtil.createRTATimeBlock(subChildST.postalCode,true);
        
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, true);
        
        AssignedResource ar = TestUtil.createAssignedResource(sr2.Id, sa.Id,true);
        
        ResourceAbsence ra = TestUtil.createResourceAbsence(sr2.Id,true);
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getCalendar/'; 
        req.params.put('Zip', subChildST.postalCode);
        req.params.put('Type', 'Showroom');
        req.params.put('Interface', 'test');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        req.addHeader('Access-Control-Allow-Origin', '*'); 
        RestContext.request = req;
        RestContext.response = res;
        getCalendarAPI.getCal();
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestURI = '/services/apexrest/getCalendar/'; 
        req.params.put('Zip', '12345');
        req.params.put('Type', 'Normal');
        req.params.put('Interface', 'test');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        req.addHeader('Access-Control-Allow-Origin', '*'); 
        RestContext.request = req;
        RestContext.response = res;
        getCalendarAPI.getCal();
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestURI = '/services/apexrest/getCalendar/'; 
        req.params.put('Zip', subChildST1.PostalCode);
        req.params.put('Type', 'Showroom');
        req.params.put('Interface', 'test');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        req.addHeader('Access-Control-Allow-Origin', '*'); 
        RestContext.request = req;
        RestContext.response = res;
        getCalendarAPI.getCal();
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestURI = '/services/apexrest/getCalendar/'; 
        req.params.put('Zip', subChildST.postalCode);
        req.params.put('Type', 'Lead Only');
        req.params.put('Interface', 'test');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        req.addHeader('Access-Control-Allow-Origin', '*'); 
        RestContext.request = req;
        RestContext.response = res;
        getCalendarAPI.getCal();
        Test.stopTest(); 
        
    }
    
    @isTest
    public static void RTAIntegrationTest2(){
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
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Monday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Tuesday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Wednesday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Thursday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Friday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Saturday';
        insert ts;
        ts = TestUtil.createTimeSlot(oh.Id, false);
        ts.DayOfWeek = 'Sunday';
        insert ts;
            
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, false);
        subChildST.postalcode='12122';
        insert subChildST;
        
        Id chidlRTId = Schema.SObjectType.ServiceTerritory.recordTypeInfosByDeveloperName.get('NRT_Zone').RecordTypeId;
      
         // Create Child Territory under Parent Territory
        ServiceTerritory childST1 = TestUtil.createChildServiceTerritory('Child NRT', parentST.Id, oh.Id, false);
        childST1.Lead_Receiver__c = UserInfo.getUserId() ;
        childST1.RecordTypeId=chidlRTId;
        insert childST1 ;
        
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST1 = TestUtil.createSubChildServiceTerritory('Sub Child NRT', childST1.Id, oh.Id, false);
        subChildST1.postalcode='85858';
         insert subChildST1;
        
        
        
         // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, false);
        sr1.Primary_Replacement_Territory__c = parentST.id;
        sr1.Override_Replacement_Rep__c = TRUE;
        insert sr1;

        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 

        // Create 2nd Service Resource
        ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, false);
        sr2.Primary_Replacement_Territory__c = parentST.id;
        sr2.Override_Replacement_Rep__c = TRUE;
        insert sr2;

        // Create 2nd Service Territory Member for 2nd Resource
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 

        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 

        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, false);
        opp.Best_Match__c = usr.Id ;
        opp.Appointment_Type__c = 'RT' ;
        insert opp ;
        
        Campaign cmp= TestUtil.createCampaign('Camp1',branch.Id,true);
        
        RTA_Timeblock__c TimeBlock=TestUtil.createRTATimeBlock(subChildST.postalCode,true);
        
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, true);
        
        AssignedResource ar = TestUtil.createAssignedResource(sr2.Id, sa.Id,true);
        
        ResourceAbsence ra = TestUtil.createResourceAbsence(sr2.Id,true);
        
        Test.startTest();
        
        RTAIntegration.getTimeSlotDetails(subChildST.postalCode,false);
        RTAIntegration.getTimeSlotDetails(subChildST.postalCode,'LeadOnly','home');
        
        Test.stopTest(); 
        
    }
   
}