@isTest
private class SendOfferLetterWithAttachment_Test {

    static testMethod void test(){
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
        
        Test.startTest();
        
        ApexPages.StandardController sc  = new ApexPages.standardController(candidate);
        System.assertNotEquals(sc,null);
        
        PageReference pageRef = Page.OfferLetterPDFViewer;
        system.debug('pageRef::::'+pageRef);
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('id', candidate.Id);
        pageRef.getParameters().put('name', candidate.Full_Name__c);
        
        SendOfferLetterWithAttachment sl = new SendOfferLetterWithAttachment(sc);  
        sl.sendEmail();
        
        Test.stopTest();
        
        System.assertNotEquals('null',null);
    }
}