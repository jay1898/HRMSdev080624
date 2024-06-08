/**
* @description       : BranchQuestionJunctionTriggerTest Test class for BranchQuestionJunctionTriggerHandler and BranchQuestionJunctionTrigger
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
@isTest
public class BranchQuestionJunctionTriggerTest {
    //validate Delete Branch Question Junction when SMS Feature of related branch is OFF
    static testMethod void testvalidateEnableSMSFeatureFalse() 
    {
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Question_Template__c questionTemp = TestUtil.createQuestion_Template(true);
        
        Branch_Question_Junction__c objBQJ = TestUtil.createBranch_Question_Junction(true, questionTemp.Id ,branch.Id,1);
        
        delete objBQJ;
    }
    
    //validate Delete Branch Question Junction when SMS Feature of related branch is ON
    static testMethod void testvalidateEnableSMSFeatureTrue() 
    {
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        //branch.Enable_SMS_Feature__c = true;
        //insert branch;
        
        Question_Template__c questionTemp = TestUtil.createQuestion_Template(true);
        
        List<Branch_Question_Junction__c> lstBQJ = new List<Branch_Question_Junction__c>();
        Branch_Question_Junction__c objBQJ1 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,1);
        lstBQJ.add(objBQJ1);
        Branch_Question_Junction__c objBQJ2 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,2);
        lstBQJ.add(objBQJ2);
        Branch_Question_Junction__c objBQJ3 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,3);
        lstBQJ.add(objBQJ3);
        Branch_Question_Junction__c objBQJ4 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,4);
        lstBQJ.add(objBQJ4);
        Branch_Question_Junction__c objBQJ5 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,5);
        lstBQJ.add(objBQJ5);
        Branch_Question_Junction__c objBQJ6 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,6);
        lstBQJ.add(objBQJ6);
        insert lstBQJ;
        
        branch.Enable_SMS_Feature__c = true;
        update branch;
        try {
            delete objBQJ1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains( Label.ValidateSMSOnDeleteBQJError) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    //validate Delete Branch Question Junction records are not more than six per branch
    static testMethod void testValidateQueCountAndOrderSixQuestions()
    {
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Question_Template__c questionTemp = TestUtil.createQuestion_Template(true);
        
        List<Branch_Question_Junction__c> lstBQJ = new List<Branch_Question_Junction__c>();
        Branch_Question_Junction__c objBQJ1 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,1);
        lstBQJ.add(objBQJ1);
        Branch_Question_Junction__c objBQJ2 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,2);
        lstBQJ.add(objBQJ2);
        Branch_Question_Junction__c objBQJ3 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,3);
        lstBQJ.add(objBQJ3);
        Branch_Question_Junction__c objBQJ4 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,4);
        lstBQJ.add(objBQJ4);
        Branch_Question_Junction__c objBQJ5 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,5);
        lstBQJ.add(objBQJ5);
        
        Branch_Question_Junction__c objBQJ6 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,6);
        lstBQJ.add(objBQJ6);
        insert lstBQJ;
        
        try {
            Branch_Question_Junction__c objBQJ7 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,7);
            insert objBQJ7;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains( Label.StopInsertmorethanSixQueError) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    } 
    
    //validate Delete Branch Question Junction records's order is in proper manner
    static testMethod void testValidateQueCountAndOrderSameOrder()
    {
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Question_Template__c questionTemp = TestUtil.createQuestion_Template(true);
        
        List<Branch_Question_Junction__c> lstBQJ = new List<Branch_Question_Junction__c>();
        Branch_Question_Junction__c objBQJ1 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,1);
        lstBQJ.add(objBQJ1);
        Branch_Question_Junction__c objBQJ2 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,2);
        lstBQJ.add(objBQJ2);
        Branch_Question_Junction__c objBQJ3 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,3);
        lstBQJ.add(objBQJ3);
        Branch_Question_Junction__c objBQJ4 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,4);
        lstBQJ.add(objBQJ4);
        Branch_Question_Junction__c objBQJ5 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,5);
        lstBQJ.add(objBQJ5);
        insert lstBQJ;
        
        try {
            Branch_Question_Junction__c objBQJ7 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,5);
            insert objBQJ7;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains( Label.ValidateOrderError) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    } 
}