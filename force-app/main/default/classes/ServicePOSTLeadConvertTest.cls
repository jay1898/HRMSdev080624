@isTest
private class ServicePOSTLeadConvertTest 
{
    static testMethod void TestServicePOSTLeadConvertMethod(){
        
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

        Campaign cam = TestUtil.createCampaign('TestCampaign', branch.Id, false);
        cam.Type = 'Branch';
        insert cam;
        
        Lead ld = TestUtil.createLead('Test','Test', false);
        ld.Campaign__c = cam.Id;
        ld.Zone__c = childST.Id ;
        insert ld;   
        
        String myJSON='{"comments":"TEst","leadid":"'+ld.Id+'","oppno":"989899121","start":"2020-01-05T13:30:00.000Z","end":"2020-01-05T15:30:00.000Z"}';
        System.debug('@myJSON@'+ myJSON);
        
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/ConvertLead'; 
        
        request.requestBody = Blob.valueof(myJSON); 
        
        RestResponse response = new RestResponse();
        
        RestContext.request = request;
        RestContext.response = response;     
         
        ServicePOSTLeadConvert.makeRequestForRTA(ld);
        ServicePOSTLeadConvert.postData(); 
    } 
}