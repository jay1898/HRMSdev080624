trigger ContentVersionTrigger on ContentVersion (after insert) {
    String sfdcUserId;
    String entityValue;
    String body;
    List<ContentDistribution> cdList    = new List<ContentDistribution>();
    for(ContentVersion versionObj : Trigger.new) {
        if (versionObj.Type__c == 'ANSWER') {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = versionObj.title;
            cd.ContentVersionId = versionObj.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            cdList.add(cd);
        }
    }
    insert cdList;
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 3 November 2023
*   Purpose         : to set the bounced email image on case and the email notification to the case owner about bounded email.
*   Input Param     : 
*   Output Param    : void
*   User Story      : SCS-1177
*/
    
    try {
        // Check if the trigger is for insert and after insert
        if (Trigger.isInsert && Trigger.isAfter) {
            // Get the SObjectType for EmailMessage
            Schema.SObjectType EmailMessageRecordName = Schema.EmailMessage.getSObjectType();
            
            // Create a list to store EmailMessage Ids
            List<String> emailMessageIds = new List<String>();
            
            // Iterate through the ContentVersion records in the trigger
            for (ContentVersion attachment : Trigger.new) {
                // Get the Id of the parent record
                Id recordId = attachment.FirstPublishLocationId;
                // Get the name of the parent record's SObject
                String record = recordId.getSObjectType().getDescribe().getName();
                
                // Check if the parent record is an EmailMessage
                if (record == String.valueOf(EmailMessageRecordName)) {
                    emailMessageIds.add(attachment.FirstPublishLocationId);
                }
            }
            
            // Query EmailMessage records based on the collected Ids
            List<EmailMessage> emailMessageList = [SELECT Id, ParentId, Parent.CaseNumber, Parent.Owner.Email FROM EmailMessage WHERE Id IN :emailMessageIds];
            
            // Create a map to store EmailMessage records by Id
            Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>(emailMessageList);
            
            // Create lists to store bounced EmailMessages and email notifications
            List<EmailMessage> bouncedEmailMessage = new List<EmailMessage>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            // Get Orgwide Email Address
            OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM 
                                        OrgWideEmailAddress WHERE DisplayName='Pella Support'];
            
            Map<String, String> attachmentandCaseMap = new Map<String, String>();
            //List<String> caseExtractedIds = new List<String>();
            for (ContentVersion attachment : Trigger.new) {
                Id recordId = attachment.FirstPublishLocationId;
                String record = recordId.getSObjectType().getDescribe().getName();
                
                // Check if the attachment is of type 'TEXT' and associated with an EmailMessage
                if (attachment.FileType == 'TEXT' && record == String.valueOf(EmailMessageRecordName)){
                    // Extract the content of the attachment
                    Blob versionDataBlob = attachment.VersionData;
                    String versionDataString = versionDataBlob.toString();
                    
                    // Define a regular expression pattern to extract X-SFDC-EntityId
                    Pattern entityPattern = Pattern.compile('X-SFDC-EntityId: (\\w+)');
                    Matcher entityMatcher = entityPattern.matcher(versionDataString);
                    
                    while (entityMatcher.find()) {
                        entityValue = entityMatcher.group(1);
                        //caseExtractedIds.add(entityValue);
                        attachmentandCaseMap.put(attachment.Id, entityValue);
                        System.debug('attachment id@@@@@'+attachment.Owner.Name);
                        System.debug('entity value@@@@'+attachmentandCaseMap.values());
                    }
                }
            }            
            
            Map<Id,Case> caseExtractedMap = new Map<Id, Case>([Select Id,CaseNumber From Case Where Id In :attachmentandCaseMap.values() ]);
            System.debug('caseExtractedMap value@@@@@@'+caseExtractedMap);
            
            // Iterate through ContentVersion records again
            for (ContentVersion attachment : Trigger.new) {
                Id recordId = attachment.FirstPublishLocationId;
                String record = recordId.getSObjectType().getDescribe().getName();
                String email;
                String sfdcUserId;
                String entityValue;
                
                System.debug('BEFORE IF --> ' + attachment.FileType);
                
                // Check if the attachment is of type 'TEXT' and associated with an EmailMessage
                if (attachment.FileType == 'TEXT' && record == String.valueOf(EmailMessageRecordName)) {
                    System.debug('AFTER IF --> ' + attachment.FileType);
                    
                    // Extract the content of the attachment
                    Blob versionDataBlob = attachment.VersionData;
                    String versionDataString = versionDataBlob.toString();
                    
                    // Define a regular expression pattern to extract email addresses
                    Pattern emailPattern = Pattern.compile('([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4})(?= \\(Undelivered\\))');
                    Matcher emailMatcher = emailPattern.matcher(versionDataString);
                    
                    /*// Define a regular expression pattern to extract X-SFDC-EntityId
Pattern entityPattern = Pattern.compile('X-SFDC-EntityId: (\\w+)');
Matcher entityMatcher = entityPattern.matcher(versionDataString);*/
                    
                    // Define a regular expression pattern to extract X-SFDC-User's Id
                    Pattern xSfdcUserPattern = Pattern.compile('X-SFDC-User: (\\w+)');
                    Matcher xSfdcUserMatcher = xSfdcUserPattern.matcher(versionDataString);
                    
                    while (xSfdcUserMatcher.find()) {
                        sfdcUserId = xSfdcUserMatcher.group(1);
                    }
                    
                    /*while (entityMatcher.find()) {
entityValue = entityMatcher.group(1);                       
}*/
                    
                    while (emailMatcher.find()) {
                        // Extract and process the bounced email addresses
                        email = emailMatcher.group();
                        System.debug('Extracted email address: ' + email);
                    }
                    
                    if (emailMessageMap.containsKey(attachment.FirstPublishLocationId) && email != null && sfdcUserId != null && attachmentandCaseMap.containskey(attachment.Id)) {
                        // Add the EmailMessage to the bouncedEmailMessage list
                        bouncedEmailMessage.add(emailMessageMap.get(attachment.FirstPublishLocationId));
                        
                        // Get relevant data for creating email notifications
                        EmailMessage emailMessageObj = emailMessageMap.get(attachment.FirstPublishLocationId);
                        System.debug('Masp value@@@@@'+attachmentandCaseMap);
                        System.debug('Masp value@@@@@'+caseExtractedMap);
                        
                        if(caseExtractedMap.containsKey(attachmentandCaseMap.get(attachment.Id))){
                            
                            Case ExtractedCase = caseExtractedMap.get(attachmentandCaseMap.get(attachment.Id));
                            String caseId = ExtractedCase.Id;
                            String caseNumber = ExtractedCase.CaseNumber;
                            String endPoint = Constant.ORG_ENDPOINT;
                            
                            // Create email body
                            String body = '';
                            body += '';
                            body += 'The email sent to: <br>';
                            body += 'Email Address : <a href=mailto:' + email + '>' + email + '</a> has bounced. The email address specified is invalid.<br>';
                            body += 'Case : <a href=' + endPoint + caseId + '>' + caseNumber + '</a><br><br>';
                            body += 'Please verify and update the email address as needed, then resend the email.';
                            body += '<br>';
                            
                            // Query the X-SFDC-User's email address based on the SFDC User ID
                            User xSfdcUser = [SELECT Id, Email FROM User WHERE Id = :sfdcUserId];
                            
                            if (xSfdcUser != null && xSfdcUser.Email != null) {
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setToAddresses(new String[]{xSfdcUser.Email});
                                mail.setSubject('Salesforce Bounced Email Notification for Case ' + caseNumber);
                                mail.setOrgWideEmailAddressId(owea.Id);
                                mail.setHtmlBody(body);
                                mailList.add(mail);
                            }
                        }
                    }
                }
            }
            
            
            
            // Send email notifications if there are any
            if (mailList.size() > 0) {
                Messaging.sendEmail(mailList);
            }
            
            // Update the Case records to mark Contact_Email_Bounced__c as true
            List<Case> updateCaseList = new List<Case>();
            System.debug('bouncedEmailMessage: ' + bouncedEmailMessage);
            for (EmailMessage em : bouncedEmailMessage) {
                Case newCase = new Case();
                newCase.Id = em.ParentId;
                newCase.Contact_Email_Bounced__c = true;
                updateCaseList.add(newCase);
            }
            
            if (!updateCaseList.isEmpty()) {
                update updateCaseList;
            }
        }
    } catch (Exception e) {
        
        System.debug('The following exception has occurred: ' + e.getMessage());
    }
    
}