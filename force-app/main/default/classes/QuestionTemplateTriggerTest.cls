/**
* @description       : QuestionTemplateTriggerTest Test class for QuestionTemplateTriggerHandler and QuestionTemplateTrigger
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
@isTest
//First Question Validation
public class QuestionTemplateTriggerTest {
    static testMethod void testQuestionIsFirstValidationFirst() {
                        
        Question_Template__c questionTemp = TestUtil.createQuestion_Template(false);
		questionTemp.isFirstQuestion__c = true;       
        insert questionTemp;
        
        try{
            Question_Template__c questionTemp1 = TestUtil.createQuestion_Template(false);
            questionTemp1.isFirstQuestion__c = true;
            questionTemp1.isLastQuestion__c = false;
            insert questionTemp1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains( Label.ValidateQuoteTemplateFirstQueError) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
                      
    }
    
    //Last Question Validation
     static testMethod void testQuestionIsFirstValidationLast() {
          Question_Template__c questionTemp = TestUtil.createQuestion_Template(false);
		questionTemp.isLastQuestion__c = true;       
        insert questionTemp;
        
        try{
            Question_Template__c questionTemp1 = TestUtil.createQuestion_Template(false);
            questionTemp1.isLastQuestion__c = true;       
            insert questionTemp1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains( Label.ValidateQuoteTemplateLastQueError) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
	//Delete Question Template Validation
    static testMethod void testDeleteQuestionTemplate() {
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Question_Template__c questionTemp = TestUtil.createQuestion_Template(true);
        
        Branch_Question_Junction__c objBQJ = TestUtil.createBranch_Question_Junction(true, questionTemp.Id ,branch.Id,1);
        
        try {
            delete questionTemp;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains( Label.ValidateBQJOnQueTempDeleteError) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
}