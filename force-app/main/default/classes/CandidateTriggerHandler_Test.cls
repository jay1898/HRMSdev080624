@isTest
public class CandidateTriggerHandler_Test {
    
    static testMethod void countValidationHitTest(){
         Candidate__c candidate = new Candidate__c(
                Full_Name__c = 'abc',
                Email__C = 'test@gmail.com',
                Candidate_Role__c = 'abc',
                Status__c = 'At iTechCloud',
            	Salary__c = 100,
            	Joining_Date__c = Date.Today(),
            	Offer_Letter_Description__c = 'Test'
         );
         insert candidate;
        
        List<Candidate__c> canList = new List<Candidate__c>();
        canList.add(candidate);
        
        Map<Id, Candidate__c> oldMap = new Map<Id, Candidate__c>();
        oldMap.put(candidate.Id,candidate);
        
        CandidateTriggerHandler.countValidationHit(canList, oldMap);
        
    }
    
    static testMethod void countValidationHitTest1(){
         Candidate__c candidate = new Candidate__c(
                Full_Name__c = 'abc',
                Email__C = 'test@gmail.com',
                Candidate_Role__c = 'abc',
                Status__c = 'Selected',
            	Salary__c = 100,
            	Joining_Date__c = Date.Today(),
            	Offer_Letter_Description__c = 'Test',
               IncludeInAfterUpdateTrigger__c = true
         );
         insert candidate;
        
        List<Candidate__c> canList = new List<Candidate__c>();
        canList.add(candidate);
        
        Map<Id, Candidate__c> oldMap = new Map<Id, Candidate__c>();
        oldMap.put(candidate.Id,candidate);
        
        CandidateTriggerHandler.countValidationHit(canList, oldMap);
    }
    
    /*static testMethod void countValidationHitTest2(){
         Candidate__c candidate = new Candidate__c(
                Full_Name__c = 'abc',
                Email__C = 'test@gmail.com',
                Candidate_Role__c = 'abc',
                Status__c = 'New Application',
            	Salary__c = 100,
            	Joining_Date__c = Date.Today(),
            	Offer_Letter_Description__c = 'Test'
         );
         insert candidate;
        
        List<Candidate__c> canList = new List<Candidate__c>();
        canList.add(candidate);
        
        Map<Id, Candidate__c> oldMap = new Map<Id, Candidate__c>();
        oldMap.put(candidate.Id,candidate);
        
        CandidateTriggerHandler.countValidationHit(canList, oldMap);
    }*/
}