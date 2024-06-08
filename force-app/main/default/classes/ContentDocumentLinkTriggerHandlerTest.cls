@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    static testMethod void shareFile(){
         Test.startTest();
         // Create Opreating Hours
         OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
         // Create Time Slot
         TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
         
         //createbranch
         Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
         bf.Branch_Family_Number__c = '124';
         insert bf;
         Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
         //Create PIES Territory
         ServiceTerritory st = TestUtil.createPIESServiceTerritroy('PIES ST 1', branch.Id, oh.Id, 'Install', false );
         st.IsActive = true;
         Insert st ;
        
         //create child territory
          ServiceTerritory chst = TestUtil.createPIESZCServiceTerritroy('32926','32926', st.Id, oh.Id, false);
          chst.IsActive = true ;
          insert chst;
          ServiceTerritory chst2 = TestUtil.createPIESZCServiceTerritroy('32116','32116', st.Id, oh.Id, false);
          chst2.IsActive = true ;
          insert chst2;
         
         //Create territory zipcode
         Territory_Zipcode__c tz = TestUtil.createTZforPIES(st.Id, chst.Id, true);
         Territory_Zipcode__c tz1 = TestUtil.createTZforPIES(st.Id, chst2.Id, true);
        
         // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Project'; Insert wt;
        //create work type
        WorkType wt2 = TestUtil.createWorkType('WT1', 'OV - Install', 'Hours', 2,false);
		wt2.Schedule_Type__c = 'OV';   Insert wt2;
        
        // Create Opportunity for quote
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        //Create quote
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
       
        //create group
        Group gp = new Group();
        gp.name = 'PIES ST 1';
        Insert gp; 
        
        //create WO
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, false);
        wo.PostalCode = '32926';
        wo.ServiceTerritoryId = st.Id;
        //WorkOrderTriggerHandler.RUN_TRIGGER= false;
        Insert wo;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='PIES Test'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=wo.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        insert contentlink;
        Test.stopTest();
        
    }
}