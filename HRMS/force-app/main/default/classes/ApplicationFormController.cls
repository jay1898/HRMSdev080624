public without sharing class ApplicationFormController {
    @AuraEnabled
    public static string createRecord(String fullName, String email,String role){
        DateTime currentDateTime = DateTime.now();
        try {
            
            Candidate__c newRecord = new Candidate__c(
                Full_Name__c = fullName,
                Email__C = email,
                Candidate_Role__c = role,
                Status__c = 'New Application',
                BlockedUntil__c = currentDateTime
            );
                
                insert newRecord;
                return newRecord.Id;

        } catch (Exception e) {
           
            return 'Error';
        }
        
    }
    // String country, String state, String address ,   Removing from parameter
    @AuraEnabled
    public static String submitApplication(String RecordId, String fullName, String email, String phone,String city, String street, String zipcode,String qualification,String role, String contentVersionId, String experience, String certification, String hearAboutUs, String reference) {

            // Create a new Candidate__c record
            Candidate__c newCandidate = new Candidate__c(
                Id=RecordId,
                Full_Name__c = fullName,
                Email__C = email,
                Phone__c = phone,
                // Address__c = address,
                // Country__c = country,
                // State__c = state,
                // Candidate_Address__CountryCode__s = country,
                // Candidate_Address__StateCode__s = state,
                // Candidate_Address__City__s = city,
                // Candidate_Address__Street__s = street,
                // Candidate_Address__PostalCode__s = zipcode,
                Highest_Qualification_Held__c= qualification,
                Candidate_Role__c = role,
                Years_of_Experience__c = experience,
                Salesforce_Certifications__c = certification,
                How_Did_You_Hear_About_Us__c = hearAboutUs,
                References__c = reference,
                Status__c = 'Under HR Review'
            );
            upsert newCandidate;
            System.debug('Log of Updated candidate'+newCandidate.Id);
            List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
            List<ContentVersion> cvList = new List<ContentVersion>();

            for(ContentVersion cv : [SELECT contentDocumentId FROM  ContentVersion WHERE Id =: contentVersionId]) {
                ContentDocumentLink conDocLink = New ContentDocumentLink();

                ContentVersion mCV = new ContentVersion(Id = cv.Id, IsLinkedWithCandidate__c = true);

                conDocLink.LinkedEntityId = newCandidate.Id;
                conDocLink.ContentDocumentId = cv.contentDocumentId;
                System.debug('Record Id  :::::::::' +newCandidate.Id);
                System.debug('Record Id cv.Id  :::::::::' +cv.contentDocumentId);

                conDocLink.Visibility = 'AllUsers';
                conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                cdList.add(conDocLink);
                cvList.add(mCV);
            }
            update cvList;
            insert cdList;

            return 'Success';
    }

    @AuraEnabled
    public static string deleteRedundantFiles(String cvId){

        Id cdId = [select Id, ContentDocumentId from ContentVersion where Id = :cvId].ContentDocumentId;
        ContentDocument cd = [select Id, Title, FileExtension, FileType, LatestPublishedVersionId from ContentDocument where Id =: cdId limit 1];
        delete cd;
        System.debug('cd deleted');
        return 'success';
    }

    @AuraEnabled
    public static List<ContentVersion> getFileSizes(List<String> contentVersionIds) {
        if(contentVersionIds == null || contentVersionIds.isEmpty()) {
            return new List<ContentVersion>();
        }
        return [SELECT Id, Title, ContentSize, FileExtension, ContentDocumentId 
                FROM ContentVersion 
                WHERE Id IN :contentVersionIds];
    }
    // @AuraEnabled
    // public static void deleteLargeFiles(List<String> contentDocumentIds) {
    //     Id cdId = [select Id, ContentDocumentId from ContentVersion where Id = :cvId].ContentDocumentId;
    //     ContentDocument cd = [select Id, Title, FileExtension, FileType, LatestPublishedVersionId from ContentDocument where Id =: cdId limit 1];
        
    //     List<ContentDocument> largeFileLimitList = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
    //     if(largeFileLimitList.size() > 0){
    //     delete largeFileLimitList;
    //     }
        
    // }

    @AuraEnabled
    public static Integer emailOtpVerification(String email, String name ){
    
   // Date currentDate = Date.today();
    // DateTime currentDateTime = DateTime.now();
    // System.debug('current Date and time'+ currentDateTime);
    // // Check for existing email
    // List<Candidate__c> existingCandidates = [SELECT Id, BlockedUntil__c FROM Candidate__c WHERE Email__c = :email LIMIT 1];
    // System.debug('existing candidate list'+ existingCandidates);
    // if (!existingCandidates.isEmpty()) {
    //     Candidate__c candidate = existingCandidates[0];
    //     System.debug('If existing user exist   ');
    //     // If the blocked until date-time is set and still in the future, throw an exception.
    //     if(candidate.BlockedUntil__c != null && candidate.BlockedUntil__c >= currentDateTime) {
    //         System.debug('in if 1st');
    //         DateTime blockedUntilDateTime = currentDateTime.addMinutes(2);
    //         candidate.BlockedUntil__c = blockedUntilDateTime;
    //         update candidate;
    //         throw new AuraHandledException('Email is blocked. Please try again after ' + candidate.BlockedUntil__c.format());
    //     }
    //     else if(candidate.BlockedUntil__c == null || candidate.BlockedUntil__c < currentDateTime) {
    //         System.debug('Blocking the user again for trying to verify within the time frame.');
    //         DateTime blockedUntilDateTime = currentDateTime.addMinutes(2); // Change to .addMonths(6) for 6 months block.
    //         candidate.BlockedUntil__c = blockedUntilDateTime;
    //         update candidate;
    //         throw new AuraHandledException('Duplicate Email. Your email is blocked for the next 2 minutes.');
    //     }
    //     // If email exists and the block duration has passed, continue and reset block.
    //     // else if(candidate.BlockedUntil__c != null && candidate.BlockedUntil__c < currentDateTime) {
    //     //     System.debug('candidate block duration passed');
    //     //     candidate.BlockedUntil__c = null; // reset block
    //     //     update candidate; // save changes
    //     // }
    //     // If email exists and no block date-time is set (i.e., it's a duplicate), block for 2 minutes.
    //     // else {
    //     //     System.debug('in else blocked user');
    //     //     DateTime blockedUntilDateTime = currentDateTime.addMinutes(2);
    //     //     candidate.BlockedUntil__c = blockedUntilDateTime;
    //     //     update candidate;
    //     //     throw new AuraHandledException('Duplicate Email. Your email is blocked for the next 2 minutes.');
    //     // }
    // }


    
    // Map<String, Object> responseMap = new Map<String, Object>();
    //Return if email already exists
    // List<Candidate__c> existingCandidates = [SELECT Id FROM Candidate__c WHERE Email__c = :email LIMIT 1];
    // if (!existingCandidates.isEmpty()) {
    //     throw new AuraHandledException('Duplicate Email');
// }

        try {
            Integer mOTP = (Integer)Math.floor(Math.random() * 9000) + 1000;
            // system.debug('mOTP: ' + mOTP);

            Id orgWideEmailAddressId = [select id, Address, DisplayName from OrgWideEmailAddress where Address = 'harshvi.mavaniitechcloud@gmail.com'].Id;

            String htmlBody = '<html><head><style>body {text-align: justify;}.container {max-width: 600px;margin: 0 auto;}@media screen and (max-width: 768px) {.body {display: none;}}</style></head><body class="container" style="text-align: justify;"><div style="margin-bottom: 20px"> <img src="https://itechcloudsolution--itechdev.sandbox.my.salesforce.com/sfc/dist/version/download/?oid=00D1s0000000TLW&ids=0681s000002M9pDAAS&d=/a/1s000000ESa0/XqB_jby8.Uwuwl2FV.kfzKhzlT5jIeRC.8vM1Vk3QtY&operationContext=DELIVERY&viewId=05H1s000000D1YAEA0&dpt=" alt="iTechCloud Solution" width="100%"></div> <p>Dear '+name+',</p><p></p><p>Thank you for choosing iTechCloud Solution.</p><p></p><p>To complete the application process, please use the following OTP: <b>'+mOTP+'</b></p><p>Sincerely,<br>iTechCloud Solution</p><p></p><table width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-top: 20px;"><tr><td align="center" valign="top" width="100%"><table class="container" cellpadding="0" cellspacing="0" width="600"><tr><td align="center" style="font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 11px; color: #959595; padding:0px 0px 25px 0px;"><!-- Add social media links here --><div class="social-links mt-3"> <a href="https://twitter.com/itechcloud_"><img height="30px" width="30px" src="https://itechcloudsolution--itechdev.sandbox.file.force.com/servlet/servlet.ImageServer?id=0151s0000000vEf&oid=00D1s0000000TLW&lastMod=1697461691000"/></a><a href="https://www.facebook.com/itechcloudsolution/" ><img height="30px" width="30px" src="https://itechcloudsolution--itechdev.sandbox.file.force.com/servlet/servlet.ImageServer?id=0151s0000000vEL&oid=00D1s0000000TLW&lastMod=1697460067000"/></a><a href="https://www.instagram.com/itechcloudsolution"><img height="30px" width="30px" src="https://itechcloudsolution--itechdev.sandbox.file.force.com/servlet/servlet.ImageServer?id=0151s0000000vEV&oid=00D1s0000000TLW&lastMod=1697461983000"/></a><a href="skype:subhash.panchani?chat"><img height="30px" width="30px" src="https://itechcloudsolution--itechdev.sandbox.file.force.com/servlet/servlet.ImageServer?id=0151s0000000vEQ&oid=00D1s0000000TLW&lastMod=1697460995000"/></a><a href="https://in.linkedin.com/company/itechcloud-solution-pvt-ltd"><img height="30px" width="30px" src="https://itechcloudsolution--itechdev.sandbox.file.force.com/servlet/servlet.ImageServer?id=0151s0000000vEa&oid=00D1s0000000TLW&lastMod=1697461606000"/></a></div><br>This email was sent by: <span>iTechCloud Solutoin<br>210, Western Plaza,Simada Gam, Nana Varachha, Surat, Gujarat 395006, India</span><br<br><br> <br> </td></tr></table></td></tr></table></body></html>';
            List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
            //email message
            List<String> toAddress = new List<String>();
            toaddress.add(email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(orgWideEmailAddressId != null)
                mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
            mail.setToAddresses(toAddress);
            mail.setSubject('iTechCloud Email Verification Code');
            mail.setHtmlBody(htmlBody);
            mailList.add(mail);

            if(toAddress.size() > 0 && toAddress != null){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                if (results[0].success){
                    System.debug('Email sent successfully.');
                    //return 'Email sent successfully.';
                }
                else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                    //return 'The email failed to send: ' + results[0].errors[0].message;
                }
            }
            return mOTP;
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static void logOTPSent(String email) {
        List<Email_OTP_Log__c> existingLogs = [SELECT Id, Last_OTP_Generation__c, OTP_Regeneration_Count__c FROM Email_OTP_Log__c WHERE Email__c = :email LIMIT 1];
        
        if (existingLogs.size() > 0) {
            Email_OTP_Log__c existingLog = existingLogs[0];
            existingLog.Last_OTP_Generation__c = Datetime.now();
            if (existingLog.OTP_Regeneration_Count__c == null) {
                existingLog.OTP_Regeneration_Count__c = 1; // Initialize if null
            } else if(existingLog.OTP_Regeneration_Count__c < 2){
                existingLog.OTP_Regeneration_Count__c += 1;  // Increment the counter
            }
            // existingLog.OTP_Regeneration_Count__c += 1;  // Increment the counter
            update existingLog;
        } else {
            Email_OTP_Log__c newLog = new Email_OTP_Log__c();
            newLog.Email__c = email;
            newLog.Last_OTP_Generation__c = Datetime.now();
            newLog.OTP_Regeneration_Count__c = 1;  // Initialize the counter to 1 for new entries
            insert newLog;
        }
    }
    

    @AuraEnabled
    public static Map<String, Object> getLastOTPGenerationTime(String email) {
        List<Email_OTP_Log__c> logs = [SELECT Last_OTP_Generation__c, OTP_Regeneration_Count__c FROM Email_OTP_Log__c WHERE Email__c = :email LIMIT 1];
        Map<String, Object> response = new Map<String, Object>();
        DateTime currentTime = System.now();
        Integer twoMinutes = 2 * 60 * 1000;

        if(logs.size() > 0) {
            Email_OTP_Log__c log = logs[0];
            Long timeDifference = currentTime.getTime() - log.Last_OTP_Generation__c.getTime();

            if(timeDifference >= twoMinutes) {
                // If more than two minutes have passed, reset the counter
                log.OTP_Regeneration_Count__c = 0;
                update log;
            }

            response.put('lastGeneratedTime', log.Last_OTP_Generation__c);
            response.put('regenerationCount', log.OTP_Regeneration_Count__c);
            response.put('canRegenerateOTP', log.OTP_Regeneration_Count__c < 2); // Can regenerate if count is less than 2
        } else {
            response.put('lastGeneratedTime', null);
            response.put('regenerationCount', 0);
            response.put('canRegenerateOTP', true);
        }
        System.debug('Response time and count'+response);
        return response;
    }



    @AuraEnabled
    public static List<Candidate__c> getInterviewConfirmedCandidateDetails(String CandidateId){
        Candidate__c candidate = [select id, Full_Name__c, Email__c, Candidate_Role__c, Interview_Date__c, Expired_Confirmation_Link__c from Candidate__c where id=:CandidateId limit 1];
        System.debug('candidate:::::'+candidate);
        if(candidate.Expired_Confirmation_Link__c) {
            throw new AuraHandledException('Your link has already expired.');
        }
        // Mark the link as expired.
        
        // candidate.Expired_Confirmation_Link__c = true;
        update candidate;

        return new List<Candidate__c>{ candidate };

        // return [select id, Full_Name__c,Email__c, Candidate_Role__c,Interview_Date__c  from Candidate__c where id=:CandidateId];
    }
    @AuraEnabled
    public static Boolean setInterviewConfirmed(String candidateId,Boolean isConfirmed){
       try{ 
        Candidate__c candidate = [SELECT Id, Interview_Confirmed__c,Status__c,Expired_Confirmation_Link__c FROM Candidate__c WHERE Id = :candidateId LIMIT 1];
    
        // update when Yes option is selected
        if (isConfirmed) {
            candidate.Interview_Confirmed__c = isConfirmed;
            candidate.Status__c = 'Interview';
        }
        candidate.Expired_Confirmation_Link__c = true;
        update candidate;

        return true;
    } catch(Exception e) {
        System.debug('Error in setInterviewConfirmed: ' + e.getMessage());
        return false;
    }
    }
    @AuraEnabled
    public static Boolean getExpiredOfferLetterConfirmation(String candidateId) {
        Candidate__c candidate = [SELECT Id, Expired_Offer_Letter_Confirmation__c FROM Candidate__c WHERE Id = :candidateId LIMIT 1];
        
        if (candidate.Expired_Offer_Letter_Confirmation__c) {
            return true;
        }
        return false ;
    }

    @AuraEnabled
    public static Boolean acceptOfferLetter(String candidateId, String action){
       try{ 
        Candidate__c candidate = [SELECT Id, Status__c,Offer_accepted_date__c,Expired_Offer_Letter_Confirmation__c FROM Candidate__c WHERE Id = :candidateId LIMIT 1];
        
        if (candidate.Expired_Offer_Letter_Confirmation__c) {
            throw new AuraHandledException('You already submitted your response.'); 
        } 
        // if (candidate.Status__c == 'Offer Accepted' || candidate.Status__c == 'Offer Declined') {
        //     throw new AuraHandledException('You already submitted your response.'); 
        // } 
        if (action == 'accept') {
            Date todayDate =  Date.today();
            candidate.Offer_accepted_date__c = todayDate;
            candidate.Status__c = 'Offer Accepted';
        } else {
            candidate.Status__c = 'Offer Declined';
        }
        candidate.Expired_Offer_Letter_Confirmation__c = true;
        update candidate;

        return true;
    } catch(Exception e) {
        System.debug('Error in accept Offer Letter: ' + e.getMessage());
        return false;
    }
    }
}