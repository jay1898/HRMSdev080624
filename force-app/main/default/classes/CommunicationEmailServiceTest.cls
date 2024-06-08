@isTest
public class CommunicationEmailServiceTest{
    public static testMethod void EmailAttachmentTester(){
        
        CommunicationEmailService objconfirm = new CommunicationEmailService();
        
        User usr = TestUtil.createUser(true);
         Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
       
        Contact con=TestUtil.createContact(acc.Id,'testes',true);
        
        Account ac = TestUtil.createAccount('Person Account', true);
        
        Opportunity Opp = TestUtil.createOpportunity('TestOpp', ac.Id, usr.Id, true);
        
        Communication__c comm = TestUtil.createCommunication(true);
        
        Communication_Component__c cc = TestUtil.createCommunicationComponent(comm.Id,true);
        
        OpportunityCommunication__c oc = TestUtil.createOpportunityCommunication(con.Id,Opp.Id,comm.Id,cc.Id,true);
        Test.startTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = 'ref: '+oc.Id+' Test subject' ;
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        envelope.fromAddress = 'maf@cloudsocius.com';
        Task tsk = new Task();
        tsk.WhatId = oc.Id;
        tsk.Subject = email.subject;
        tsk.Description = email.plainTextBody;
        insert tsk;
        
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            
            Messaging.Inboundemail.TextAttachment textAttachment = new Messaging.Inboundemail.TextAttachment();
        textAttachment.Filename = 'test.pdf';
        textAttachment.body = 'my attachment text';
        email.textAttachments = new  Messaging.Inboundemail.TextAttachment[]{textAttachment};
            objconfirm.handleInboundEmail(email, envelope);
        
        Attachment attachment = new Attachment();
        attachment.Name = textAttachment.fileName;
        attachment.Body = Blob.valueOf(textAttachment.body);
        attachment.ParentId = tsk.Id;
        insert attachment;
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        List<Attachment> att = [Select id, name from Attachment where parentid = :tsk.id and name = :'test.pdf'];
        System.assertEquals(att[0].name, 'test.pdf');
        Test.stopTest();
        
    }
    public static testMethod void EmailAttachmentTester2(){
        
        CommunicationEmailService objconfirm = new CommunicationEmailService();
        
        User usr = TestUtil.createUser(true);
        Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
       
        Contact con=TestUtil.createContact(acc.Id,'testes',true);
        
        Account ac = TestUtil.createAccount('Person Account', true);
        
        Opportunity Opp = TestUtil.createOpportunity('TestOpp', ac.Id, usr.Id, true);
        
        Communication__c comm = TestUtil.createCommunication(true);
        
        Communication_Component__c cc = TestUtil.createCommunicationComponent(comm.Id,true);
        
        OpportunityCommunication__c oc = TestUtil.createOpportunityCommunication(con.Id,Opp.Id,comm.Id,cc.Id,true);
        
        Test.startTest();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = ' Test subject' ;
        email.plainTextBody = 'ref: '+oc.Id+'Hello, this a test email body. for testing purposes only. Bye';
        envelope.fromAddress = 'maf@cloudsocius.com';
        Task tsk = new Task();
        tsk.WhatId = oc.Id;
        tsk.Subject = email.subject;
        tsk.Description = email.plainTextBody;
        insert tsk;
        
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            
            Messaging.Inboundemail.TextAttachment textAttachment = new Messaging.Inboundemail.TextAttachment();
        textAttachment.Filename = 'test.pdf';
        textAttachment.body = 'my attachment text';
        email.textAttachments = new  Messaging.Inboundemail.TextAttachment[]{textAttachment};
            objconfirm.handleInboundEmail(email, envelope);
        
        Attachment attachment = new Attachment();
        attachment.Name = textAttachment.fileName;
        attachment.Body = Blob.valueOf(textAttachment.body);
        attachment.ParentId = tsk.Id;
        insert attachment;
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        List<Attachment> att = [Select id, name from Attachment where parentid = :tsk.id and name = :'test.pdf'];
        System.assertEquals(att[0].name, 'test.pdf');
        Test.stopTest();
    }
    public static testMethod void EmailAttachmentTester3(){
        
        CommunicationEmailService objconfirm = new CommunicationEmailService();
        
        User usr = TestUtil.createUser(true);
        Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
       
        Contact con=TestUtil.createContact(acc.Id,'testes',true);
        
        Account ac = TestUtil.createAccount('Person Account', true);
        
        Opportunity Opp = TestUtil.createOpportunity('TestOpp', ac.Id, usr.Id, true);
        
        Communication__c comm = TestUtil.createCommunication(true);
        
        Communication_Component__c cc = TestUtil.createCommunicationComponent(comm.Id,true);
        
        OpportunityCommunication__c oc = TestUtil.createOpportunityCommunication(con.Id,Opp.Id,comm.Id,cc.Id,true);
        Test.startTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = ' Test subject' ;
        email.plainTextBody = 'ref: '+Opp.Id+'Hello, this a test email body. for testing purposes only. Bye';
        envelope.fromAddress = 'maf@cloudsocius.com';
        Task tsk = new Task();
        tsk.WhatId = oc.Id;
        tsk.Subject = email.subject;
        tsk.Description = email.plainTextBody;
        insert tsk;
        
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            
            Messaging.Inboundemail.TextAttachment textAttachment = new Messaging.Inboundemail.TextAttachment();
        textAttachment.Filename = 'test.pdf';
        textAttachment.body = 'my attachment text';
        email.textAttachments = new  Messaging.Inboundemail.TextAttachment[]{textAttachment};
            objconfirm.handleInboundEmail(email, envelope);
        
        Attachment attachment = new Attachment();
        attachment.Name = textAttachment.fileName;
        attachment.Body = Blob.valueOf(textAttachment.body);
        attachment.ParentId = tsk.Id;
        insert attachment;
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        List<Attachment> att = [Select id, name from Attachment where parentid = :tsk.id and name = :'test.pdf'];
        System.assertEquals(att[0].name, 'test.pdf');
        Test.stopTest();
    }
    static testMethod void testMethod1() 
    {
         // Create User
        User usr = TestUtil.createUser(false);
        String[] integrationUser=Label.Integration_UserName.split(' ');
        if(integrationUser.size()>1){
            usr.FirstName=integrationUser[0];
            usr.LastName=integrationUser[1];
        }else if(Label.Integration_UserName!=null && Label.Integration_UserName!=''){
            usr.LastName=Label.Integration_UserName;
        }
        insert usr;
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(),FirstName=usr.FirstName,LastName=usr.LastName, Title = 'Retail Sales Rep');
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '99999', bf.Id, true);
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Main SA Appointment Territory Branch', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Main Child SA Appointment Zone RT', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
        
        // Create Sub Child Territory under Child Territory
        //ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Main Sub SA Appointment Zipcode ', childST.Id, oh.Id, true);
        
        // Create 1st Service Resource
        //ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        
        ServiceResource sr1 ;
        List<ServiceResource> resources = [SELECT Id, Primary_Branch_Family__c FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() ];
        if(resources.size() > 0 ) sr1 = resources[0];
        if(sr1 == null) 
        {
            sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
            // Create Service Territory Member for 1st Resource
            ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        }
        
        // Create 2nd Service Resource
        //ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        //ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.Status = 'Scheduled';
        insert sa ;
        
        
        // Make JSON 
        String jsonStr = '{"opportunity_id": "'+opp.Id+'","appointment_id": "'+sa.Id+'","sales_rep_id": "'+usr.Id+'","email": "dhruv.javiyasfdc@gmail.com","message": "body of message","links": {"customer": "https://someurl.xn--com-9o0a","sales_rep": "https://someurl.xn--com-9o0a"}}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        ServicePOSTVantageEmail.postData();
        Vantage_Email__c VE=[SELECT Id from Vantage_Email__c limit 1];
        Test.startTest();
        CommunicationEmailService objconfirm = new CommunicationEmailService();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = ' Test subject' ;
        email.plainTextBody = 'ref: '+VE.Id+'Hello, this a test email body. for testing purposes only. Bye';
        envelope.fromAddress = 'maf@cloudsocius.com';
        Task tsk = new Task();
        tsk.WhatId = VE.Id;
        tsk.Subject = email.subject;
        tsk.Description = email.plainTextBody;
        insert tsk;
        
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            
            Messaging.Inboundemail.TextAttachment textAttachment = new Messaging.Inboundemail.TextAttachment();
        textAttachment.Filename = 'test.pdf';
        textAttachment.body = 'my attachment text';
        email.textAttachments = new  Messaging.Inboundemail.TextAttachment[]{textAttachment};
            objconfirm.handleInboundEmail(email, envelope);
        
        Attachment attachment = new Attachment();
        attachment.Name = textAttachment.fileName;
        attachment.Body = Blob.valueOf(textAttachment.body);
        attachment.ParentId = tsk.Id;
        insert attachment;
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        List<Attachment> att = [Select id, name from Attachment where parentid = :tsk.id and name = :'test.pdf'];
        System.assertEquals(att[0].name, 'test.pdf');
        Test.stopTest();
    }
}