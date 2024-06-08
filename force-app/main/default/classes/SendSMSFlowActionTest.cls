/**
* @description       : SendSMSFlowActionTest Test class for SendSMSFlowAction
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
@isTest
public class SendSMSFlowActionTest {
    static testMethod void testTwilioSmsFlowInput() 
    { 
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout ());
    	// Create Account
        Account ac = TestUtil.createAccount('Person Account', true);

        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('TEst', ac.Id, UserInfo.getUserId(), false);
        opp.Opportunity_No__c = '123';
        insert opp ;

        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 

        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf; 
        Branch__c branch = TestUtil.createBranch('Test', '{{Name}} 123', bf.Id, true);
        Question_Template__c questionTemp = TestUtil.createQuestion_Template(true);
        Branch_Question_Junction__c objBQJ7 = TestUtil.createBranch_Question_Junction(false, questionTemp.Id ,branch.Id,1);
        insert objBQJ7;
        branch.Enable_SMS_Feature__c = true;
        update branch;
         // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        insert sa;
        
        List<SendSMSFlowAction.TwilioSmsFlowInput> lst = new List<SendSMSFlowAction.TwilioSmsFlowInput>();
        SendSMSFlowAction.TwilioSmsFlowInput obj = new SendSMSFlowAction.TwilioSmsFlowInput();
        obj.branchId = branch.Id;
        obj.isFirstSMS = true;
        obj.recordId =opp.Id;
        obj.toNum = '7801845692';
        obj.topic = 'Survey';
        lst.add(obj);
        SendSMSFlowAction.sendNextSMS(lst);
        obj.isFirstSMS = false;
         SendSMSFlowAction.sendNextSMS(lst);
         obj.isFirstSMS = false;
         SendSMSFlowAction.sendNextSMS(lst);
    }
}