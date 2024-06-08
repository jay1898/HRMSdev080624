@isTest
public class FileControllerTest {
    static testMethod void TestFileAttachment() {
        
        // create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Project'; 
        Insert wt;
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        // Create quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        
        // create branch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        branch.Branch_Email__c = 'pallavi.patil@evergegroup.com';
        update branch;
        
        // create work order
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo.PostalCode = '32926';
        WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        
        // create work order line item
        WorkOrderLineItem WOLI  = TestUtil.createWorkOrderLineItem('Test WOLI ', wt.Id, wo.Id, false) ;
        WOLI.PostalCode = '32926';
        WOLI.Status__c = 'Pending Approval';
        WorkOrderLineItemTriggerHandler.RUN_TRIGGER = FALSE ;
        Insert WOLI; 
        
        // create content version
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        ContentDocumentLinkTriggerHandler.RUN_TRIGGER = FALSE;
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title = 'picture'];
        
        // create ContentDocumentLink  record for WO
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = wo.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        // create ContentDocumentLink  record for WOLI
        ContentDocumentLink woliCdl = new ContentDocumentLink();
        woliCdl.LinkedEntityId = WOLI.Id;
        woliCdl.ContentDocumentId = documents[0].Id;
        woliCdl.ShareType = 'I';
        woliCdl.Visibility = 'AllUsers';
      
        insert woliCdl;
        
        Test.startTest();
        FileController.getVersionFilesForWO(wo.Id);
        FileController.getVersionFilesForChildWolis(wo.Id);
        Test.stopTest();
    }
}