@isTest
private class ResourceAbsenceTriggerHandlerTest 
{
    static testMethod void TestServicePOSTLeadConvertMethod(){
        DateTime startDateTime = DateTime.now().addDays(-10);
        DateTime endDateTime = startDateTime.addHours(24);
        
        User u = TestUtil.createUser(true);
        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        ServiceResource sr = TestUtil.createServiceResource('Mayank', u.Id, branch.Id, bf.Id, false);
        sr.AccountId = acc.Id;
        sr.recordtypeId = srRTId ;
        insert sr;
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        //Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
         
        ResourceAbsence ra = TestUtil.createResourceAbsence(sr.Id,true);
      	ra.Start = DateTime.now().addMinutes(-2);
        update ra;
    	delete ra;    
    }
}