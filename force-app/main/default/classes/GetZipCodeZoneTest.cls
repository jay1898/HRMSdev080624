@isTest
public class GetZipCodeZoneTest 
{
    
    @isTest
    public static void GetZipCodeZoneTest1(){
       // Create User
        User usr = TestUtil.createUser(true);
        
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
        
         
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getCalendar/'; 
        req.params.put('zipcode', subChildST.postalCode);
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        req.addHeader('Access-Control-Allow-Origin', '*'); 
        RestContext.request = req;
        RestContext.response = res;
        GetZipCodeZone.doGet();
        
        req = new RestRequest(); 
        res = new RestResponse();
        req.requestURI = '/services/apexrest/getCalendar/'; 
        req.params.put('zipcode','221111');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        req.addHeader('Access-Control-Allow-Origin', '*'); 
        RestContext.request = req;
        RestContext.response = res;
        GetZipCodeZone.doGet();
        
        
        Test.stopTest(); 
        
    }
      
}