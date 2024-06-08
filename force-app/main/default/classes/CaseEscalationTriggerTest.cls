@isTest
public class CaseEscalationTriggerTest {
    @TestSetup
    static void testSetup(){
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        insert accountObj;
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        insert contactObj;
        
        Case parentCase = new Case();
        parentCase.ContactId = contactObj.Id;
        parentCase.Has_Awaiting_Parts_Alert__c = false;
        parentCase.Internal_Comments__c =  'Test Internal Comments';
        parentCase.Status = 'Pending';
        parentCase.Subject = 'Parent Test subject';
        insert parentCase;
        
        Case_Escalation__c ce=new Case_Escalation__c();
        ce.Case__c=parentCase.Id;
        ce.Escalation_Level__c='Escalation';
        ce.Escalation_Status__c='In Progress';
        ce.Escalate_to_Group__c='Corp Managers';
        insert ce;
    }
        
    @isTest
    /* To confirm that Case_Escalation_Count__c increments on parent Case when a Case Escalation record is created */
    public static void updateCaseEscalationCountOnCreate(){
        list <Case> caseWithEscalation = [SELECT Case_Escalation_Count__c FROM Case WHERE Subject = 'Parent Test subject'];
        System.assertEquals(caseWithEscalation[0].Case_Escalation_Count__c,1);
        
    } 
    
    @isTest
    /* To confirm that Case_Escalation_Count__c decrements on parent Case when a Case Escalation record is canceled */
    public static void decrementCaseEscalationCountOnEscalationCancel(){
        list <Case_Escalation__c> caseEscalation = [SELECT Escalation_Status__c FROM Case_Escalation__c WHERE Escalation_Level__c = 'Escalation'];
        caseEscalation[0].Escalation_Status__c = 'Canceled';
        update caseEscalation[0];
        list <Case> caseWithEscalation = [SELECT Case_Escalation_Count__c FROM Case WHERE Subject = 'Parent Test subject'];
        System.assertEquals(caseWithEscalation[0].Case_Escalation_Count__c,0);   
    }   
    
    @isTest
    /* To confirm that Case_Escalation_Count__c decrements on parent Case when a Case Escalation record is deleted */
    public static void decrementCaseEscalationCountOnEscalationDelete(){
        list <Case_Escalation__c> caseEscalation = [SELECT Escalation_Status__c FROM Case_Escalation__c WHERE Escalation_Level__c = 'Escalation'];
        delete caseEscalation[0];
        list <Case> caseWithEscalation = [SELECT Case_Escalation_Count__c FROM Case WHERE Subject = 'Parent Test subject'];
        System.assertEquals(caseWithEscalation[0].Case_Escalation_Count__c,0);   
    }  
}