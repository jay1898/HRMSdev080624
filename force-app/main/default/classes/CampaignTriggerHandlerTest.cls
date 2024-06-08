/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          12/26/2019
*   @TaskSource:    Jira
*   @Purpose:       Test class behind CampaignMemberTriggerHandler
*   @Updates:       
*/
@isTest
private class CampaignTriggerHandlerTest 
{
    static testMethod void testMethod1() 
    {
        /*List<Campaign> campaigns = new List<Campaign>();
for(Integer i=0; i<=200 ; i++)
{
campaigns.add(new Campaign(Name='Test' + String.valueOf(i)));
}

insert campaigns ;
CampaignTriggerHandler.generateUniqueCode(campaigns);*/
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            //Cp.AOR__c=bf.Id;
           // Cp.Type='AOR';
            insert Cp;
            
        }
    }
    
    /*static testMethod void testMethod2() 
    {
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            insert Cp;
            Campaign Cp1 = TestUtil.createCampaign('Test Campaign1',branch.Id ,false);
            insert Cp1;
            Delete Cp1;
        }
    }*/
    @isTest
    public static void testMethod2(){
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
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            Cp.AOR__c=bf.Id;
            Cp.Type='AOR';
            insert Cp;
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;          
        }
    }
     @isTest
    public static void testMethod21(){
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, false); 
            t2.TCBranchNumber__c='199';
            insert t2;
            
            Id activetypeIdTC = TestUtil.getTerritoryTypeId('Trade');
            Territory2  TCt2= TestUtil.createTerritory2('1002',activetypeIdTC, false); 
            Tct2.DeveloperName='TCTred';
            TCt2.ParentTerritory2Id=t2.Id;
            TCt2.TCBranchNumber__c='199';
            insert TCt2;
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', false);
            bf.Branch_Family_Number__c = '100';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.T_C_Branch_Number__c='199';
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            Cp.Type='Branch';
            Cp.Business_Segment__c='Trade';
            insert Cp;
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;          
        }
    }
}