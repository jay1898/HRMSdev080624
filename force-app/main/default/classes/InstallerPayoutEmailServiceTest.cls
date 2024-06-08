@isTest
public class InstallerPayoutEmailServiceTest{
    public static testMethod void EmailAttachmentTester(){
        
        InstallerPayoutEmailService objconfirm = new InstallerPayoutEmailService();
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        branch.AOR__c=bf.Id;
        update branch;
        
        //createquote
        // Account for quote
        Account ac = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        //Quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        WorkType wt = TestUtil.createWorkType('tests', ' ', 'Hours', 2,true);
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, false);
  		woli.status__c='Pending Approval';
        insert woli;
        Test.startTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = 'ref: '+woli.Id+' Test subject' ;
        email.plainTextBody = 'yes';
        envelope.fromAddress = 'maf@cloudsocius.com';
       
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        Test.stopTest();
        
    }
    public static testMethod void EmailAttachment(){
        
        InstallerPayoutEmailService objconfirm = new InstallerPayoutEmailService();
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        branch.AOR__c=bf.Id;
        update branch;
        
        //createquote
        // Account for quote
        Account ac = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        //Quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        WorkType wt = TestUtil.createWorkType('tests', ' ', 'Hours', 2,true);
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, false);
  		woli.status__c='Pending Approval';
        insert woli;
        Test.startTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = 'Test subject' ;
         email.plainTextBody = '\n'+'no'+'ref: '+woli.Id + '\n test';
        envelope.fromAddress = 'maf@cloudsocius.com';
       
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        
         
        
    }
    
    public static testMethod void EmailAttachment1(){
        
        InstallerPayoutEmailService objconfirm = new InstallerPayoutEmailService();
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        branch.AOR__c=bf.Id;
        update branch;
        
        //createquote
        // Account for quote
        Account ac = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        //Quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        WorkType wt = TestUtil.createWorkType('tests', ' ', 'Hours', 2,true);
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, false);
  		woli.status__c='Pending Approval';
        insert woli;
        Test.startTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = 'Test subject' ;
         email.plainTextBody = '\n'+'xyz'+'ref: '+woli.Id + '\n test';
        envelope.fromAddress = 'maf@cloudsocius.com';
       
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        
         
        
    }
}