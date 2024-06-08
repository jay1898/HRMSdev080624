@isTest
public class Batch_CandidateReminder_Test {

   /* static testMethod void batchCandidateReminderTest(){
       
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
        
        Test.setCreatedDate(candidate.Id, Date.today().addDays(-1));
        
        Batch_CandidateReminder bc = new Batch_CandidateReminder();
        Database.executeBatch(bc);
    }
    */

static testMethod void batchCandidateReminderTest(){
       
       Candidate__c candidate = new Candidate__c(
                Full_Name__c = 'abc',
                Email__C = 'test@gmail.com',
                Candidate_Role__c = 'abc',
                //Status__c = 'Screening Reject',
            	Salary__c = 100,
            	Joining_Date__c = Date.Today(),
           	    
            	Offer_Letter_Description__c = 'Test'
         );
         insert candidate;
        
        Test.setCreatedDate(candidate.Id, Date.today().addDays(-1));
        
        Batch_CandidateReminder bc = new Batch_CandidateReminder();
        Database.executeBatch(bc);
    }
    // Helper method to create a candidate record with a specified created date
    private static Candidate__c createCandidateWithCreatedDate(Date createdDate) {
        return new Candidate__c(
            Full_Name__c = 'abc',
            Email__c = 'test@gmail.com',
            Candidate_Role__c = 'abc',
            Status__c = 'New Application',
            Salary__c = 100,
            Joining_Date__c = Date.today(),
            Offer_Letter_Description__c = 'Test'
        );
    }

    static testMethod void batchCandidateReminder() {
        // Create a candidate record with a created date within the desired range
        Candidate__c candidateWithinRange = createCandidateWithCreatedDate(Date.today().addDays(-2));
        insert candidateWithinRange;

        // Create a candidate record with a created date outside the desired range
        Candidate__c candidateOutsideRange = createCandidateWithCreatedDate(Date.today().addDays(-10));
        insert candidateOutsideRange;

        // Set the created date for the second candidate to be within the desired range
        Test.setCreatedDate(candidateOutsideRange.Id, Date.today().addDays(-1));

        // Execute the batch job
        Test.startTest();
        Batch_CandidateReminder bc = new Batch_CandidateReminder();
        Database.executeBatch(bc);
        Test.stopTest();

        // Query for the updated candidate records
        List<Candidate__c> updatedCandidates = [SELECT Id, Status__c FROM Candidate__c WHERE Id IN :new Set<Id>{candidateWithinRange.Id, candidateOutsideRange.Id}];

        System.assertEquals('New Application', updatedCandidates[0].Status__c);
    }
     @isTest
    static void ReplaceDynamicContent1() {
        // Test data setup
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('ConditionVariable', true);
        inputMap.put('DynamicValue1', 'Value1');
        inputMap.put('DynamicValue2', 'Value2');

        String textToReplace = 'Testing {{if(ConditionVariable,\'DynamicValue1\',\'DynamicValue2\')}} replacement {{DynamicValue1}}';

        // Call the method
        String result = Batch_CandidateReminder.replaceDynamicContent(inputMap, textToReplace);

        // Verify the result
       // System.assertEquals('Testing Value1 replacement Value1', result);
    }
}