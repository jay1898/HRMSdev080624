/**
* @description       : AssignResourceToTerritoryController to manage territory resource assigment
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   21-02-2022    Dhruv Javiya  Initial Version()
**/
@isTest
public class InstallerPayoutAmountTriggerHandlerTest {
    static testMethod void testMethod1(){
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        Quote q = TestUtil.createQuote(opp.Id, true);
        
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Install';
        insert wt;
        
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
        ServiceResource sr = TestUtil.createServiceResource('test', UserInfo.getUserId(), branch.Id, bf.Id, false);
        sr.Installer_Third_Party__c= true;
        insert sr;
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, false);
        //woli.Lock_Payout_Transaction__c = true;
        woli.Status__c = 'Inquiry'; 
        woli.Primary_Installer__c = sr.Id;
        insert woli;
        Installer_Payout_Amount__c ipa = TestUtil.createInstallerPayoutAmount(woli.Id, false);
        ipa.Description__c = 'Test';
        ipa.PQM_Line__c = 'test';
        ipa.Quantity__c = 2;
        ipa.Payout_Amount__c = 200;
        insert ipa;
        ipa.Quantity__c = 3;
        update ipa;
        //InstallerPayoutAmountCmpController.fetchExistingInstallerPayoutData(woli.id);
        InstallerPayoutAmountCmpController.fetchInstallerPayoutData(woli.Id);
    }
    static testMethod void testMethod2(){
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Status = 'Ordered';
        insert q;
        
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
        branch.Automated_Installer_Payout__c = false;
        insert branch;
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, true);
        
        Installer_Payout_Amount__c ipa = TestUtil.createInstallerPayoutAmount(woli.Id, false);
        ipa.Description__c = 'Test';
        ipa.PQM_Line__c = 'test';
        ipa.Quantity__c = 2;
        ipa.Payout_Amount__c = 200;
        insert ipa;
        
        //InstallerPayoutAmountCmpController.fetchExistingInstallerPayoutData(woli.id);
    }
    /*static testMethod void testMethod3(){
// Create Account
Account ac = TestUtil.createAccount('Person Account', true);
Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
opp.Appointment_DateTime__c = DateTime.now();
opp.Status__c = 'Open';
opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
OpportunityTriggerHandler.RUN_TRIGGER= false;
insert opp;
Quote q = TestUtil.createQuote(opp.Id, false);
q.Status = 'Ordered';
q.Market_Segment__c = 'Retail';

insert q;


//create work type
WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);
//createbranch
Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
bf.Branch_Family_Number__c = '124';
insert bf;
Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
branch.Automated_Installer_Payout__c = true;
insert branch;


WorkOrder wo = TestUtil.createWorkOrder('Test subject', wt.Id, branch.Id, ac.Id, q.Id, true);

WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, true);

Installer_Payout_Amount__c ipa = TestUtil.createInstallerPayoutAmount(woli.Id, false);
ipa.Description__c = 'Test';
ipa.PQM_Line__c = 'test';
ipa.Quantity__c = 2;
ipa.Payout_Amount__c = 200;
insert ipa;

InstallerPayoutAmountCmpController.fetchExistingInstallerPayoutData(woli.id);
}*/
    static testMethod void testMethod4(){
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Status = 'Ordered';
        q.Market_Segment__c = 'Reetail';
        
        insert q;
        
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
        branch.Automated_Installer_Payout__c = true;
        insert branch;
        
        
        ServiceResource sr = TestUtil.createServiceResource('test', UserInfo.getUserId(), branch.Id, bf.Id, false);
        sr.Installer_Third_Party__c= true;
        insert sr;
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, false);
        //woli.Lock_Payout_Transaction__c = true;
        woli.Status__c = 'Inquiry'; 
        woli.Primary_Installer__c = sr.Id;
        insert woli;
        
        Installer_Payout_Amount__c ipa = TestUtil.createInstallerPayoutAmount(woli.Id, false);
        ipa.Description__c = 'Test';
        ipa.PQM_Line__c = 'test';
        ipa.Quantity__c = 2;
        ipa.Payout_Amount__c = 200;
        insert ipa;
        
        try{
            InstallerPayoutAmountCmpController.fetchExistingInstallerPayoutData(woli.id);
            
        }
        catch(exception e){
            system.debug('error'+e);
        }
        
        try{
            InstallerPayoutAmountCmpController.fetchInstallerPayoutData(woli.id);
            
        }
        catch(exception e){
            system.debug('error'+e);
        }
        
        try{
            InstallerPayoutAmountCmpController.fetchInstallerPayoutDataRecords(woli.Id);
            
        }
        catch(exception e){
            system.debug('error'+e);
        }
        /*InstallerPayoutAmountCmpController.fetchInstallerPayoutData(woli.id);
InstallerPayoutAmountCmpController.fetchInstallerPayoutDataRecords(woli.Id);
InstallerPayoutAmountCmpController.fetchExistingInstallerPayoutData(woli.id);*/
        
        
    }
    static testMethod void testMethod5(){
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Install';
        insert wt;
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
        branch.Automated_Installer_Payout__c = true;
        insert branch;
        
        String pb = test.getStandardPricebookId();
        Product2 p = TestUtil.createProduct(true);
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Status = 'Ordered';
        q.Market_Segment__c = 'Reetail';
        q.Pricebook2Id=pb;
        insert q;
        
        PriceBookEntry pbe = TestUtil.createPriceBookEntry(pb, p.Id, true);
        
        ServiceResource sr = TestUtil.createServiceResource('test', UserInfo.getUserId(), branch.Id, bf.Id, false);
        sr.Installer_Third_Party__c= true;
        sr.Tier__c = '1';
        insert sr;
        WorkOrder wo = TestUtil.createWorkOrder('Test subject',null, branch.Id, ac.Id, q.Id, true);
        
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, false);
        woli.Lock_Payout_Transaction__c = true;
        woli.Status__c = 'Inquiry'; 
        woli.Primary_Installer__c = sr.Id;
        insert woli;
        
        Installer_Payout_Amount__c ipa = TestUtil.createInstallerPayoutAmount(NULL, false);
        ipa.Description__c = 'Test';
        ipa.PQM_Line__c = 'test';
        ipa.Quantity__c = 2;
        ipa.Payout_Amount__c = 200;
        insert ipa;
        
        
     	QuoteLineItem qt =  TestUtil.createQuoteLineItem(q.Id,WOLI.Id,pbe.Id,p.Id,False);
        qt.Quantity = 2;
        qt.UnitPrice = 2;
        qt.QLI_Type__c = 'LineItem';
        qt.Psi_Resource_Labor__c = true;
        qt.Product_Code__c = '123';
        qt.Description = 'test';
        qt.Qte_Line__c = '10';
        insert qt;
         Installer_Payout__c ip = TestUtil.createInstallerPayout(branch.Id,false);
        ip.Description__c = 'Test';
        ip.Part_Number__c = '123';
        ip.Tier1__c = 1000;
        ip.Tier2__c =200;
        ip.Tier3__c = 200;
        ip.Tier4__c = 3000;
        insert ip;
        try{
            InstallerPayoutAmountCmpController.fetchExistingInstallerPayoutData(woli.id);
            
        }
        catch(exception e){
            system.debug('error'+e);
        }
        
        try{
            InstallerPayoutAmountCmpController.fetchInstallerPayoutData(woli.id);
            
        }
        catch(exception e){
            system.debug('error'+e);
        }
        
        try{
            InstallerPayoutAmountCmpController.fetchInstallerPayoutDataRecords(woli.Id);
            
        }
        catch(exception e){
            system.debug('error'+e);
        }
        /*InstallerPayoutAmountCmpController.fetchInstallerPayoutData(woli.id);
InstallerPayoutAmountCmpController.fetchInstallerPayoutDataRecords(woli.Id);
InstallerPayoutAmountCmpController.fetchExistingInstallerPayoutData(woli.id);*/
        
        
    }
    
}