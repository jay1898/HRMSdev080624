@isTest
public class ApplicationFormController_Test {
	@isTest
     static void createRecord(){
        String fullName;
        String email;
        String role;
         
         Candidate__c candidate = new Candidate__c(
                Full_Name__c = 'abc',
                Email__C = 'test@gmail.com',
                Candidate_Role__c = 'abc',
                Status__c = 'New Application'
         );
         insert candidate;
     	
         Test.startTest();
        	ApplicationFormController.createRecord(fullName,email,role);
         Test.stopTest();
      
       // Test.startTest();
      //  String recordId = ApplicationFormController.createRecord(fullName, email, role);
       // Test.stopTest();
     }
    
    /*@isTest
    static void submitApplication() {
        Candidate__c candidate = new Candidate__c(
            Full_Name__c = 'abc',
            Email__C = 'test@gmail.com',
            Phone__c = '1234567890',
            Highest_Qualification_Held__c = 'BE / B.Tech',
            Years_of_Experience__c = '1',
            Salesforce_Certifications__c = 'abc',
            How_Did_You_Hear_About_Us__c = 'Internet Search',
            References__c = 'abc',
            Candidate_Role__c = 'abc',
            Status__c = 'New Application'
    	);
		insert candidate; 
        
         ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test content'),
            PathOnClient = 'TestDocument.txt'
        );
        insert contentVersion;
        
        Test.startTest();
            ApplicationFormController.submitApplication(candidate.Id, candidate.Full_Name__c, candidate.Email__C, candidate.Phone__c, null, null, null, candidate.Highest_Qualification_Held__c, candidate.Candidate_Role__c, null, candidate.Years_of_Experience__c, candidate.Salesforce_Certifications__c, candidate.How_Did_You_Hear_About_Us__c, candidate.References__c);
        Test.stopTest();
    }*/
    @isTest
    static void submitApplicationTest() {
        // Create a test Candidate record without an Id
        Candidate__c testCandidate = new Candidate__c(
            Full_Name__c = 'abc',
            Email__C = 'test@gmail.com',
            Phone__c = '1234567890',
            Highest_Qualification_Held__c = 'BE / B.Tech',
            Years_of_Experience__c = '1',
            Salesforce_Certifications__c = 'abc',
            How_Did_You_Hear_About_Us__c = 'Internet Search',
            References__c = 'abc',
            Candidate_Role__c = 'abc',
            Status__c = 'New Application'
        );
        insert testCandidate;

        // Create a test ContentVersion
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test content'),
            PathOnClient = 'TestDocument.txt'
        );
        insert testContentVersion;

        Test.startTest();
        ApplicationFormController.submitApplication(
            testCandidate.Id,
            testCandidate.Full_Name__c,
            testCandidate.Email__C,
            testCandidate.Phone__c,
            null, 
            null, 
            null, 
            testCandidate.Highest_Qualification_Held__c,
            testCandidate.Candidate_Role__c,
            testContentVersion.Id,
            testCandidate.Years_of_Experience__c,
            testCandidate.Salesforce_Certifications__c,
            testCandidate.How_Did_You_Hear_About_Us__c,
            testCandidate.References__c
        );
        Test.stopTest();
        Candidate__c updatedCandidate = [SELECT Id, Status__c FROM Candidate__c WHERE Id = :testCandidate.Id];
    }


    @isTest
	static void GetFileSizes() {
    
    ContentVersion testContentVersion1 = new ContentVersion(
        VersionData = Blob.valueOf('Test Data 1'),
        Title = 'Test Content 1'
    );
    //insert testContentVersion1;

    ContentVersion testContentVersion2 = new ContentVersion(
        VersionData = Blob.valueOf('Test Data 2'),
        Title = 'Test Content 2'
    );
   // insert testContentVersion2;

    // Prepare a list of ContentVersion Ids
    List<String> contentVersionIds = new List<String>{
        testContentVersion1.Id,
        testContentVersion2.Id
    };


    Test.startTest();
    List<ContentVersion> result = ApplicationFormController.getFileSizes(contentVersionIds);
    Test.stopTest();
}

    @isTest
    static void deleteRedundantFiles(){
        ContentVersion conversion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test content'),
            PathOnClient = 'TestDocument.txt'
        );
        insert conversion;

        Test.startTest();
        	ApplicationFormController.deleteRedundantFiles(conversion.Id);
        Test.stopTest();
    }

    
    @isTest
    static void getInterviewConfirmedCandidateDetails() {
        Candidate__c testCandidate = new Candidate__c(
            Full_Name__c = 'abc',
            Email__C = 'test@gmail.com',
            Phone__c = '1234567890',
            Highest_Qualification_Held__c = 'BE / B.Tech',
            Years_of_Experience__c = '1',
            Salesforce_Certifications__c = 'abc',
            How_Did_You_Hear_About_Us__c = 'Internet Search',
            References__c = 'abc',
            Candidate_Role__c = 'abc',
            Status__c = 'New Application'
        );
        insert testCandidate;


        Test.startTest();
       		ApplicationFormController.getInterviewConfirmedCandidateDetails(testCandidate.Id);
        Test.stopTest();
    }
    
    
  

    @isTest
    static void emailOtpVerification() {
        // Test data
        String testEmail = 'test@example.com';
        String testName = 'Test User';

        // Mocking the OrgWideEmailAddress query result
        OrgWideEmailAddress mockOrgWideEmail = new OrgWideEmailAddress();
        mockOrgWideEmail.Address = 'harshvi.mavaniitechcloud@gmail.com';
       
        Test.startTest();       
        Integer generatedOTP = ApplicationFormController.emailOtpVerification(testEmail, testName);
        Test.stopTest();

    }

    
    @isTest
    static void LogOTPSent() {
        // Test case for existing log with OTP_Regeneration_Count__c less than 2
        String testEmailExisting = 'existing@example.com';
        Email_OTP_Log__c existingLog = new Email_OTP_Log__c(Email__c = testEmailExisting, OTP_Regeneration_Count__c = 1);
        insert existingLog;

        existingLog = [SELECT Last_OTP_Generation__c, OTP_Regeneration_Count__c FROM Email_OTP_Log__c WHERE Id = :existingLog.Id LIMIT 1];
        
        // Test case for existing log with OTP_Regeneration_Count__c equal to 2
        String testEmailExistingCount2 = 'existing2@example.com';
        Email_OTP_Log__c existingLogCount2 = new Email_OTP_Log__c(Email__c = testEmailExistingCount2, OTP_Regeneration_Count__c = 2);
        insert existingLogCount2;

        existingLogCount2 = [SELECT Last_OTP_Generation__c, OTP_Regeneration_Count__c FROM Email_OTP_Log__c WHERE Id = :existingLogCount2.Id LIMIT 1];
        
        // Test case for new log
        String testEmailNew = 'new@example.com';

        Test.startTest();
        System.debug('Before calling logOTPSent');
        ApplicationFormController.logOTPSent(testEmailNew);
        System.debug('After calling logOTPSent');
        Test.stopTest();

        Email_OTP_Log__c newLog = [SELECT Id, Last_OTP_Generation__c, OTP_Regeneration_Count__c FROM Email_OTP_Log__c WHERE Email__c = :testEmailNew LIMIT 1];
        
    }
    
    @isTest
    public static void GetLastOTPGeneration() {
        // Create an Email_OTP_Log__c record
        Email_OTP_Log__c otpLog = new Email_OTP_Log__c(
            Email__c = 'test@example.com',
            Last_OTP_Generation__c = System.now().addMinutes(-5), // Last generation 5 minutes ago
            OTP_Regeneration_Count__c = 1
        );
        insert otpLog;

        // Test getting the last OTP generation time
        Map<String, Object> response = ApplicationFormController.getLastOTPGenerationTime('test@example.com');
     
        // Simulate generating an OTP after 2 minutes (should reset the count)
        otpLog.Last_OTP_Generation__c = System.now().addMinutes(-2);
        update otpLog;

        // Test getting the last OTP generation time again
        response = ApplicationFormController.getLastOTPGenerationTime('test@example.com');
       

        // Test getting OTP generation time for an email that doesn't exist
        response = ApplicationFormController.getLastOTPGenerationTime('nonexistent@example.com');
       
    }


    
    @isTest
    public static void GetInterviewConfirmedCandidates() {
        // Create a Candidate__c record
         Candidate__c testCandidate = new Candidate__c(
            Full_Name__c = 'abc',
            Email__C = 'test@gmail.com',
            Phone__c = '1234567890',
            Highest_Qualification_Held__c = 'BE / B.Tech',
            Years_of_Experience__c = '1',
            Salesforce_Certifications__c = 'abc',
            How_Did_You_Hear_About_Us__c = 'Internet Search',
            References__c = 'abc',
            Candidate_Role__c = 'abc',
            Status__c = 'New Application'
        );
        insert testCandidate;

        // Test getting candidate details when the link is not expired
        List<Candidate__c> candidate = ApplicationFormController.getInterviewConfirmedCandidateDetails(testCandidate.Id);
        Candidate__c retrievedCandidate = candidate[0];
      

        // Verify that the link has been marked as expired
        testCandidate = [SELECT Expired_Confirmation_Link__c FROM Candidate__c WHERE Id = :testCandidate.Id LIMIT 1];
        // Test exception handling
        Test.startTest();
        try {
            ApplicationFormController.getInterviewConfirmedCandidateDetails(testCandidate.Id);
        } catch (AuraHandledException ex) {
        }
        Test.stopTest();
    }


    
    

    @isTest
    public static void setInterviewConfirmed() {
        // Create a Candidate__c record
       Candidate__c testCandidate = new Candidate__c(
            Full_Name__c = 'abc',
            Email__C = 'test@gmail.com',
            Phone__c = '1234567890',
            Highest_Qualification_Held__c = 'BE / B.Tech',
            Years_of_Experience__c = '1',
            Salesforce_Certifications__c = 'abc',
            How_Did_You_Hear_About_Us__c = 'Internet Search',
            References__c = 'abc',
            Candidate_Role__c = 'abc',
            Status__c = 'New Application'
        );
        insert testCandidate;

        // Test confirming the interview
        Boolean isConfirmed = ApplicationFormController.setInterviewConfirmed(testCandidate.Id, true);
               // Verify that the Candidate__c record has been updated with Interview_Confirmed__c and Status__c
        testCandidate = [SELECT Interview_Confirmed__c, Status__c, Expired_Confirmation_Link__c FROM Candidate__c WHERE Id = :testCandidate.Id LIMIT 1];
        Boolean isDeclined = ApplicationFormController.setInterviewConfirmed(testCandidate.Id, false);
      
        testCandidate = [SELECT Interview_Confirmed__c, Expired_Confirmation_Link__c FROM Candidate__c WHERE Id = :testCandidate.Id LIMIT 1];
     
        // Test exception handling
        Test.startTest();
        try {
            ApplicationFormController.setInterviewConfirmed(testCandidate.Id, true);
        } catch (Exception ex) {
          //  System.assertEquals(null, ex.getMessage());
        }
        Test.stopTest();
    }


    
   
    @isTest
    public static void acceptOfferLetter() {
        // Create a Candidate__c record
        Candidate__c testCandidate = new Candidate__c(
            Full_Name__c = 'abc',
            Email__C = 'test@gmail.com',
            Phone__c = '1234567890',
            Highest_Qualification_Held__c = 'BE / B.Tech',
            Years_of_Experience__c = '1',
            Salesforce_Certifications__c = 'abc',
            How_Did_You_Hear_About_Us__c = 'Internet Search',
            References__c = 'abc',
            Candidate_Role__c = 'abc',
            Status__c = 'New Application'
        );
        insert testCandidate;

        // Test accepting an offer
        Boolean isAccepted = ApplicationFormController.acceptOfferLetter(testCandidate.Id, 'accept');
       

        // Verify that the Candidate__c record has been updated to 'Offer Accepted'
        testCandidate = [SELECT Status__c FROM Candidate__c WHERE Id = :testCandidate.Id LIMIT 1];
       

        // Try accepting the offer again (should throw an exception)
        Boolean isAcceptedAgain = ApplicationFormController.acceptOfferLetter(testCandidate.Id, 'accept');
       

        // Test declining an offer
        Boolean isDeclined = ApplicationFormController.acceptOfferLetter(testCandidate.Id, 'decline');
       

        testCandidate = [SELECT Status__c FROM Candidate__c WHERE Id = :testCandidate.Id LIMIT 1];
        
        
        Boolean isDeclinedAgain = ApplicationFormController.acceptOfferLetter(testCandidate.Id, 'decline');
        

        // Test exception handling
        Test.startTest();
        try {
            ApplicationFormController.acceptOfferLetter(testCandidate.Id, 'accept');
        } catch (AuraHandledException ex) { 
        }
        Test.stopTest();
    }


}