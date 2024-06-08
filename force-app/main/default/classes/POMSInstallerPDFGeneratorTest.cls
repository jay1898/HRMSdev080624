/**
* @description       : POMSInstallerPDFGeneratorTest cover POMSInstallerPDFGenerator
* @author            : Dhruv Javiya | javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   14-04-2022    Dhruv Javiya  Initial Version()
**/
@isTest
public class POMSInstallerPDFGeneratorTest {
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
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        WorkOrderLineItem WOLI = TestUtil.createWorkOrderLineItem('Test', wt.Id, wo.Id, true);
        List<String> WOLIlst = new List<String>();
        WOLIlst.add(WOLI.Id);
         String nwid = Network.getNetworkId();
        POMSInstallerPDFGenerator.PDFGenerator(WOLIlst,nwid);
        
    }
}