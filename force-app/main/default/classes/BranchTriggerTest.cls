/**
* @description       : BranchTriggerTest Test class for BranchTriggerHandler and BranchTrigger
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
@isTest
public class BranchTriggerTest {
    static testMethod void testMethod1() 
    { 
        User u = TestUtil.createUser(false);
        u.AOR__C= 'Gale';
        insert u;
        system.runAs(u) 
        {
            Account acc = TestUtil.createAccount('Person Account', true);
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
            bf.Branch_Family_Number__c = '124';
            insert bf;
            Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
            branch.AOR__c=bf.Id;
            update branch;
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch_Family');
            Territory2  territory= TestUtil.createTerritory2('124',activetypeId, true);     
            
            Id activetypeId1 = TestUtil.getTerritoryTypeId('Branch');
            Territory2  territory1= TestUtil.createTerritory2('123',activetypeId1, false);     
            territory1.DeveloperName = 'testt';
            insert territory1;
        }
    }
    
    //validate branch Enable SMS Featur  when Branch_Question_Junction record per branch is atleast one. 
    static testMethod void testValidateEnableSMSFeature() 
    {
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        try {
            branch.Enable_SMS_Feature__c = true;
            update branch;
        }
        catch(Exception ex){
            system.debug('ex: '+ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains( Label.EnableSMSError) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
      
	}
}