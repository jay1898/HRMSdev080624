/*public class SendOfferLetterWithAttachment {
    public Candidate__c candidate { get; set; }

    public SendOfferLetterWithAttachment(ApexPages.StandardController stdController) {
        this.candidate = (Candidate__c)stdController.getRecord();
        // Assuming you have the record ID, fetch additional fields as needed
        this.candidate = [SELECT id,Name,Full_Name__c,Email__c   FROM Candidate__c WHERE Id = :stdController.getId()];
    }
}*/
public class SendOfferLetterWithAttachment {
    public Candidate__c candidate { get; set; }
    public String MstrID { get; set; }
    public String message { get; set; }
    public String formattedTodayDate { get; set; }
    public Boolean dataNotNull {get;set;}
    public SendOfferLetterWithAttachment(ApexPages.StandardController stdController) {
       
        this.candidate = (Candidate__c)stdController.getRecord();
        this.candidate = [SELECT id, Name, Full_Name__c, Email__c,Status__c ,Candidate_Role__c,Joining_Date__c,Salary__c,Offer_Letter_Description__c,Description__c,provident_fund__c, profession_tax__c, TDS__c FROM Candidate__c  WHERE Id = :stdController.getId()];
        this.MstrID = stdController.getId();
        Integer intAsString = Integer.valueOf(this.candidate.Salary__c);
    
        this.candidate.provident_fund__c = this.candidate.provident_fund__c == null ? this.candidate.provident_fund__c = 0 : this.candidate.provident_fund__c;
        this.candidate.profession_tax__c = this.candidate.profession_tax__c == null ? this.candidate.profession_tax__c = 0 : this.candidate.profession_tax__c;
        this.candidate.TDS__c  = this.candidate.TDS__c  == null ? this.candidate.TDS__c  = 0 : this.candidate.TDS__c ;

        //  this.candidate.provident_fund__c == null ? this.candidate.provident_fund__c = 0 : this.candidate.provident_fund__c ;
        dataNotNull = (this.candidate.Salary__c == null || intAsString == 0) || (this.candidate.Joining_Date__c == null) || (this.candidate.Description__c == null) ? true : false;
        Date today = Date.today();
        formattedTodayDate = formatDate(today);
    }

    public PageReference sendEmail() {
        // Create the email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate et = [SELECT Id,HtmlValue FROM EmailTemplate WHERE DeveloperName =:'Send_Candidate_Offer_Later'];
        mail.setToAddresses(new String[] { candidate.Email__c });
        mail.setSubject('Offer Letter');
        String emailBody = et.HtmlValue.replace('{!Candidate__c.Full_Name__c}', candidate.Full_Name__c != null ? candidate.Full_Name__c : '')
            .replace('{!Candidate__c.Candidate_Role__c}', candidate.Candidate_Role__c != null ? candidate.Candidate_Role__c : '')
           .replace('{!Candidate__c.Id}', candidate.Id != null ? candidate.Id : '').replace('{!$Label.Email_Header_Image_Link}', System.Label.Email_Header_Image_Link);
             /*.replace('{!Candidate__c.Full_Name__c}', candidate.Full_Name__c != null ? candidate.Full_Name__c : '')*/
		//mail.setPlainTextBody('Please find attached your offer letter.');
        mail.setTemplateId(et.Id);
        mail.setHtmlBody(emailBody);
        mail.setWhatId(candidate.Id);
        mail.setSaveAsActivity(true);
        
        PageReference pdfPage = Page.OfferLetterPDFViewer;
        pdfPage.getParameters().put('id', candidate.Id);
        pdfPage.getParameters().put('name', candidate.Full_Name__c);
        pdfPage.getParameters().put('email', candidate.Email__c);
        pdfPage.getParameters().put('CandidateRole', candidate.Candidate_Role__c);
        pdfPage.getParameters().put('salary', String.valueOf(candidate.Salary__c));
        pdfPage.getParameters().put('d', formatDate(candidate.Joining_Date__c));
        pdfPage.getParameters().put('description', candidate.Offer_Letter_Description__c);
        pdfPage.getParameters().put('des', candidate.Description__c);
        Blob pdfBlob; 
        if(!test.isRunningTest()){
            pdfBlob = pdfPage.getContentAsPDF();
        }else{
            pdfBlob = blob.valueof('TEST');
        }
        // Create email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('OfferLetter.pdf');
        efa.setBody(pdfBlob);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
			
        ContentVersion conVer = NEW ContentVersion();
        conVer.ContentLocation = 'S'; // TO USE S specify this document IS IN Salesforce, TO USE E FOR external files
        conVer.PathOnClient = candidate.Full_Name__c +' Offer Letter'+'.pdf'; 
        conVer.Title = candidate.Full_Name__c +' Offer Letter'+'.pdf'; 
        conVer.VersionData = pdfBlob;
        system.debug('conVer@@ ' + conVer);
        INSERT conVer;  

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

        ContentDocumentLink conDocLink = NEW ContentDocumentLink();
        conDocLink.LinkedEntityId = candidate.Id;
        conDocLink.ContentDocumentId = conDoc; 
        conDocLink.shareType = 'V';
        INSERT conDocLink;

        // Send the email
        try {
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            message = 'Mail sent successfully to ' + candidate.Email__c; // Success message
            this.candidate.Status__c = 'Offer Extended';
            update this.candidate;
        } catch (Exception e) {
            message = 'Error sending email: ' + e.getMessage(); // Error message
        }
        
        return null; // Or return a PageReference
    }
    public String getFormattedJoiningDate() {
        return formatDate(candidate.Joining_Date__c);
    } 

    public static String formatDate(Date d) {
        if(d == null) {
            return '';
        }
    
        String daySuffix;
        Integer day = d.day();
        if(day == 1 || day == 21 || day == 31) {
            daySuffix = 'st';
        } else if(day == 2 || day == 22) {
            daySuffix = 'nd';
        } else if(day == 3 || day == 23) {
            daySuffix = 'rd';
        } else {
            daySuffix = 'th';
        }
    
        String[] months = new String[]{ 'January', 'February', 'March', 'April', 'May', 'June', 
                                        'July', 'August', 'September', 'October', 'November', 'December' };
        String monthName = months[d.month()-1];
    
        String formattedDate = day + daySuffix + ' ' + monthName + ', ' + d.year();
        return formattedDate;
    }
    
}