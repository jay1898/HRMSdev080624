@isTest
public class EmailMessageTriggerTest {
    

    @TestSetup
    static void makeData(){
        User usr=testutil.createUser(false);
        usr.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Pella System Administrator'].Id;
        insert usr;
        
        system.runAs(usr){
            
            Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
            accountObj.BillingPostalCode    = '12345'; 
            insert accountObj;
            Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
            contactObj.MailingPostalCode    = '12345';
            insert contactObj;
            
            Case parentCase = new Case();
            parentCase.ContactId = contactObj.Id;
            parentCase.Has_Awaiting_Parts_Alert__c = false;
            parentCase.Internal_Comments__c =  'Test Internal Comments';
            parentCase.Status = Constant.CASE_STATUS_COMPLETED;
            parentCase.Subject = 'Parent Test subject';
            insert parentCase;
            
            Case_Line__c caseLineRecord = new Case_Line__c();
            caseLineRecord.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Parts').getRecordTypeId();
            caseLineRecord.Case__c = parentCase.Id;
            caseLineRecord.Line_Price__c = 120;
            insert caseLineRecord;
            
            Case childCase = new Case();
            childCase.ContactId = contactObj.Id;
            childCase.Has_Awaiting_Parts_Alert__c = true;
            childCase.Internal_Comments__c =  'Test Internal Comments';
            childCase.Status = Constant.CASE_STATUS_MERGED;
            childCase.ParentId = parentCase.Id;
            childCase.Subject = 'Test subject';
            insert childCase;
            
            
        }
    } 
    
     @isTest
    static void testCreateEmailMessage() {

        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.RelatedToId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.ParentId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.FromAddress = 'testFrom@gmail.com';
        emailMessageRecord.ToAddress = 'testTo@gmail.com';
        emailMessageRecord.BccAddress = 'testTo@gmail.com';
        emailMessageRecord.CcAddress = 'testTo@gmail.com';
        emailMessageRecord.Subject = 'Subject';
        emailMessageRecord.TextBody = 'body';
        emailMessageRecord.Incoming = true;
        
        EmailMessage emailMessageRecordError = new EmailMessage();
        emailMessageRecordError.RelatedToId = [Select Id From Case Where ParentId = null Limit 1].Id;
        
        Test.startTest();
        // Call the method being tested
        insert emailMessageRecord;
        emailMessageRecord.TextBody = 'update body';
        update emailMessageRecord;
        
        insert emailMessageRecordError;
        
        delete emailMessageRecordError;
        Test.stopTest();

    }
    
    @isTest
    static void testCreateEmailMessageForCaseSendInvoice() {
        
        Case parentCase = new Case();
        parentCase.Id = [Select Id From Case Where ParentId = null Limit 1].Id;
        parentCase.Send_To_Invoicing__c = true;
        update parentCase;

        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.RelatedToId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.ParentId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.FromAddress = 'testFrom@gmail.com';
        emailMessageRecord.ToAddress = 'testTo@gmail.com';
        emailMessageRecord.Subject = 'Subject';
        emailMessageRecord.TextBody = 'body';
        emailMessageRecord.Incoming = true;
        
        Test.startTest();
        // Call the method being tested
        insert emailMessageRecord;
        Test.stopTest();

    }
      
    @isTest
    static void testCreateEmailMessageParentCompletedWithCaseLine() {
        
        Case parentCase = new Case();
        parentCase.ContactId = [Select id from Contact Limit 1].Id;
            parentCase.Has_Awaiting_Parts_Alert__c = false;
            parentCase.Internal_Comments__c =  'Test Internal Comments';
            parentCase.Status = Constant.CASE_STATUS_COMPLETED;
            parentCase.Subject = 'Parent Test subject';
            insert parentCase;

        ID orgId = UserInfo.getOrganizationId();
        String sOrgId = (string)orgId;
        ID caseId = [Select Id From Case Where ParentId != null Limit 1].Id; // replace this with your case id
        String sCaseId = (string)caseId;
        String threadIdPart1 = 'ref:_' + sOrgId.left(5) + sOrgId.right(10).replace('0','');
        threadIdPart1 = threadIdPart1.substring(0,threadIdPart1.length()-3);
        String threadIdPart2 = '._' + sCaseId.Left(5) + sCaseId.right(10).left(5).replace('0','') + sCaseId.right(5);
        threadIdPart2 = threadIdPart2.substring(0,threadIdPart2.length()-3)+':ref';
        String SubjectthreadId = threadIdPart1 + threadIdPart2;  
        System.debug('Thread Id^^'+SubjectthreadId); 
        
        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.RelatedToId = parentCase.Id;
        emailMessageRecord.ParentId = parentCase.Id;
        emailMessageRecord.FromAddress = 'testFrom@gmail.com';
        emailMessageRecord.ToAddress = 'testTo@gmail.com';
        emailMessageRecord.Subject = 'SUBJECT ' + SubjectthreadId;
        emailMessageRecord.TextBody = 'body';
        emailMessageRecord.Incoming = true;
        
        EmailMessage emailMessageRecordError = new EmailMessage();
        emailMessageRecordError.RelatedToId = [Select Id From Case Limit 1].Id;
        
        Test.startTest();
        insert emailMessageRecord;
        Test.stopTest();

    }
    
    @isTest
    static void testCreateEmailMessageParentCancelled() {
        
        Case parent = [Select Id,Status From Case Where ParentId = null Limit 1];
        parent.Status = Constant.CASE_STATUS_CANCELLED;
        update Parent;
        
        ID orgId = UserInfo.getOrganizationId();
        String sOrgId = (string)orgId;
        ID caseId = [Select Id From Case Where ParentId != null Limit 1].Id; // replace this with your case id
        String sCaseId = (string)caseId;
        String threadIdPart1 = 'ref:_' + sOrgId.left(5) + sOrgId.right(10).replace('0','');
        threadIdPart1 = threadIdPart1.substring(0,threadIdPart1.length()-3);
        String threadIdPart2 = '._' + sCaseId.Left(5) + sCaseId.right(10).left(5).replace('0','') + sCaseId.right(5);
        threadIdPart2 = threadIdPart2.substring(0,threadIdPart2.length()-3)+':ref';
        String SubjectthreadId = threadIdPart1 + threadIdPart2;  
        System.debug('Thread Id^^'+SubjectthreadId); 

        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.RelatedToId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.ParentId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.FromAddress = 'testFrom@gmail.com';
        emailMessageRecord.ToAddress = 'testTo@gmail.com';
        emailMessageRecord.Subject = 'SUBJECT ' + SubjectthreadId;
        emailMessageRecord.TextBody = 'body';
        emailMessageRecord.Incoming = true;
        
        EmailMessage emailMessageRecordError = new EmailMessage();
        emailMessageRecordError.RelatedToId = [Select Id From Case Limit 1].Id;
        
        Test.startTest();
        // Call the method being tested
        insert emailMessageRecord;
        Test.stopTest();

    }
    
    @isTest
    static void testCreateEmailMessageParentClosed() {
        
        Case parent = [Select Id,Status From Case Where ParentId = null Limit 1];
        parent.Status = Constant.CASE_STATUS_CLOSED;
        update Parent;
        
        ID orgId = UserInfo.getOrganizationId();
        String sOrgId = (string)orgId;
        ID caseId = [Select Id From Case Where ParentId != null Limit 1].Id; // replace this with your case id
        String sCaseId = (string)caseId;
        String threadIdPart1 = 'ref:_' + sOrgId.left(5) + sOrgId.right(10).replace('0','');
        threadIdPart1 = threadIdPart1.substring(0,threadIdPart1.length()-3);
        String threadIdPart2 = '._' + sCaseId.Left(5) + sCaseId.right(10).left(5).replace('0','') + sCaseId.right(5);
        threadIdPart2 = threadIdPart2.substring(0,threadIdPart2.length()-3)+':ref';
        String SubjectthreadId = threadIdPart1 + threadIdPart2;  
        System.debug('Thread Id^^'+SubjectthreadId);

        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.RelatedToId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.ParentId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.FromAddress = 'testFrom@gmail.com';
        emailMessageRecord.ToAddress = 'testTo@gmail.com';
        emailMessageRecord.Subject = 'SUBJECT ' + SubjectthreadId;
        emailMessageRecord.TextBody = 'body';
        emailMessageRecord.Incoming = true;
        
        EmailMessage emailMessageRecordError = new EmailMessage();
        emailMessageRecordError.RelatedToId = [Select Id From Case Limit 1].Id;
        
        Test.startTest();
        // Call the method being tested
        insert emailMessageRecord;
        Test.stopTest();

    }
    
    @isTest
    static void testCreateEmailMessageParentAwaiting() {
        
        Case parent = [Select Id,Status From Case Where ParentId = null Limit 1];
        parent.Status = Constant.CASE_STATUS_AWAITING_PART_ORDER;
        update Parent;
        
        ID orgId = UserInfo.getOrganizationId();
        String sOrgId = (string)orgId;
        ID caseId = [Select Id From Case Where ParentId != null Limit 1].Id; // replace this with your case id
        String sCaseId = (string)caseId;
        String threadIdPart1 = 'ref:_' + sOrgId.left(5) + sOrgId.right(10).replace('0','');
        threadIdPart1 = threadIdPart1.substring(0,threadIdPart1.length()-3);
        String threadIdPart2 = '._' + sCaseId.Left(5) + sCaseId.right(10).left(5).replace('0','') + sCaseId.right(5);
        threadIdPart2 = threadIdPart2.substring(0,threadIdPart2.length()-3)+':ref';
        String SubjectthreadId = threadIdPart1 + threadIdPart2;  
        System.debug('Thread Id^^'+SubjectthreadId);

        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.RelatedToId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.ParentId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.FromAddress = 'testFrom@gmail.com';
        emailMessageRecord.ToAddress = 'testTo@gmail.com';
        emailMessageRecord.Subject = 'SUBJECT ' + SubjectthreadId;
        emailMessageRecord.TextBody = 'body';
        emailMessageRecord.Incoming = true;
        
        EmailMessage emailMessageRecordError = new EmailMessage();
        emailMessageRecordError.RelatedToId = [Select Id From Case Limit 1].Id;
        
        Test.startTest();
        // Call the method being tested
        insert emailMessageRecord;
        Test.stopTest();

    }
    
    @isTest
    static void testCreateEmailMessageParentPending() {
        
        Case parent = [Select Id,Status,Has_Awaiting_Parts_Alert__c,Internal_Comments__c From Case Where ParentId = null Limit 1];
        parent.Status = Constant.CASE_STATUS_PENDING;
        update Parent;
        
        ID orgId = UserInfo.getOrganizationId();
        String sOrgId = (string)orgId;
        ID caseId = [Select Id From Case Where ParentId != null Limit 1].Id; // replace this with your case id
        String sCaseId = (string)caseId;
        String threadIdPart1 = 'ref:_' + sOrgId.left(5) + sOrgId.right(10).replace('0','');
        threadIdPart1 = threadIdPart1.substring(0,threadIdPart1.length()-3);
        String threadIdPart2 = '._' + sCaseId.Left(5) + sCaseId.right(10).left(5).replace('0','') + sCaseId.right(5);
        threadIdPart2 = threadIdPart2.substring(0,threadIdPart2.length()-3)+':ref';
        String SubjectthreadId = threadIdPart1 + threadIdPart2;  
        System.debug('Thread Id^^'+SubjectthreadId);

        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.RelatedToId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.ParentId = [Select Id From Case Where ParentId = null Limit 1].Id;
        emailMessageRecord.FromAddress = 'testFrom@gmail.com';
        emailMessageRecord.ToAddress = 'testTo@gmail.com';
        emailMessageRecord.Subject = 'SUBJECT ' + SubjectthreadId;
        emailMessageRecord.TextBody = 'body';
        emailMessageRecord.Incoming = true;
        
        EmailMessage emailMessageRecordError = new EmailMessage();
        emailMessageRecordError.RelatedToId = [Select Id From Case Limit 1].Id;
        
        Test.startTest();
        // Call the method being tested
        insert emailMessageRecord;
        EmailMessageTriggerHandlerService.caseAwaitingPartsOrderProcessor(parent);
        Test.stopTest();

    }
}