@isTest
public class CallFlowHomeOwnerControllerTest {

    @TestSetup
    static void makeData(){
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        accountObj.BillingPostalCode    = '12345'; 
        insert accountObj;
        
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.MailingPostalCode    = '12345';
        insert contactObj;
        
        Case caseObj        = new Case();
        caseObj.Status      = 'Pending';
        caseObj.Origin      = 'Email';
        // caseObj.AssignedBranch__c = [Select Id from Branch__c LIMIT 1].Id;
        caseObj.ContactId   = [Select Id from Contact LIMIT 1].Id;
        CaseObj.Business_Segment__c = 'Trade';
        insert caseObj;
        
		Case_Assessment__c newCaseAssessmentObj = new Case_Assessment__c();
        newCaseAssessmentObj.Case__c = caseObj.Id;
		insert newCaseAssessmentObj;
        
        Question__c questionObj = new Question__c();
        questionObj.Active__c = true;
        questionObj.Question__c = 'test question';
        insert questionObj;
        
        Answer__c answerObj = new  Answer__c();
        answerObj.Answer__c = 'Test';
        answerObj.Answer_Type__c = 'RadioButton';
        answerObj.Case_Assessment__c = newCaseAssessmentObj.Id;
        answerObj.Question__c = questionObj.Id;
        insert answerObj;
    }
    // 
    @isTest
    static void testgetSectionQuestion(){
        system.assertequals(0,CallFlowHomeOwnerController.getSectionQuestion().size());  
    }
    
    // 
    @isTest
    static void testgetAllSubQuestions(){
        system.assertequals(0,CallFlowHomeOwnerController.getAllSubQuestions().size());  
    }
    
    @isTest
    static void testgetCaseAssessmentRecords(){
        system.assertequals(0,CallFlowHomeOwnerController.getCaseAssessmentRecords(null).size());  
    }
    
    @isTest
    static void testgetAnswerUsingCaseAssessment(){
        system.assertequals(1,CallFlowHomeOwnerController.getAnswerUsingCaseAssessment([SELECT Id From Case_Assessment__c Limit 1].Id).size());  
    }
    
     @isTest
    static void teststoreAnswers(){
        
        Question__c questionObj = new Question__c();
        questionObj.Active__c = true;
        questionObj.Question__c = 'test question 2';
        insert questionObj;
        
        Answer__c answerObj = new  Answer__c();
        answerObj.Answer__c = 'Test 2';
        answerObj.Answer_Type__c = 'RadioButton';
        answerObj.Question__c = questionObj.Id;
        answerObj.Case_Assessment__c = [SELECT Id From Case_Assessment__c Limit 1].Id;
        
        CallFlowHomeOwnerController.storeAnswers(new List<Answer__c>{answerObj});
    }
}