@isTest
public class ServiceTerritoryMemberTriggerHandlerTest {
    @isTest
    public static void ServiceResourceTriggerTest1(){
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true);   
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', false);
            bf.Branch_Family_Number__c = '100';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            // Create Parent Territory
            ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
            update parentST;
            
            // Create Child Territory under Parent Territory
            ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, false);
            childST.Lead_Receiver__c = UserInfo.getUserId() ;
            insert childST ;
            
            // Create Sub Child Territory under Child Territory
            ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, false);
            subChildST.postalcode='12122';
            insert subChildST;
            
            
            // Create 1st Service Resource
            ServiceResource sr = TestUtil.createServiceResource('Mayank', testUser.Id, branch.Id, bf.Id, false);
            sr.Ranker__c = 10.0;
            insert sr;
            try{
			ServiceTerritoryMember STM=new ServiceTerritoryMember();
			STM.ServiceResourceId=sr.Id;
			STM.ServiceTerritoryId=childST.Id;
            STM.TerritoryType='S';
            STM.EffectiveStartDate=Date.today();
			insert STM;          
            }catch(exception e){}
            try{
			ServiceTerritoryMember STM=new ServiceTerritoryMember();
			STM.ServiceResourceId=sr.Id;
			STM.ServiceTerritoryId=childST.Id;
            STM.TerritoryType='P';
            STM.EffectiveStartDate=Date.today();
			insert STM;          
            }catch(exception e){}
        }
    }  
    
}