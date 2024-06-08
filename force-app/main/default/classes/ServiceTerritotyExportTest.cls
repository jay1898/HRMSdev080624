@isTest
public class ServiceTerritotyExportTest 
{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    @isTest
    public static void RTAIntegrationTest1(){
      
        
		Test.setMock(HttpCalloutMock.class, new ServiceTerritoryExportMock());
        Test.startTest();
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
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
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
        ServiceTerritoryExportController.runServiceTerritoryExportBatch();
        ServiceTerritoryExportBatch BatchApex = new ServiceTerritoryExportBatch();  
        DataBase.executeBatch(BatchApex);
        
        ServiceTerritoryExportBatchHandler.getBoundary();
        ServiceTerritoryExportBatchHandler.GetContentType();
        
        Test.stopTest();
    }
}