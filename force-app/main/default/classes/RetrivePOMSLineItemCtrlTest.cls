/**
* @description       : RetrivePOMSLineItemCtrlTest
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   14-04-2022    Dhruv Javiya  Quote
**/

@isTest
public class RetrivePOMSLineItemCtrlTest {
    
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
        q.PO_Number__c = '123';
        update q;
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, false);
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        WorkOrderLineItem woli = TestUtil.createWorkOrderLineItem('Test subject', wt.Id, wo.Id, true);

        RetrivePOMSLineItemCtrl.getQuoteDetails(woli.id);
        test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RetrivePOMSLineItemCtrl.getPOMSLineItemDetails(q.id);
        test.stopTest();
        
    }
}