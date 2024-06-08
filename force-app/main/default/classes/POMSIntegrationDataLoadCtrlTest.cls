/**
* @description       : POMSIntegrationDataLoadCtrlTest for POMSIntegrationDataLoadCtrl
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date          Author        Modification
* 1.0   14-04-2022    Dhruv Javiya  Initial Version()
**/
@isTest
public class POMSIntegrationDataLoadCtrlTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://apidev.pella.com/order-enquiry/v1/oms-orders', req.getEndpoint());
            String Body = '[{"OrderNumber":"72120TELEA","OrderStatus":"6","BranchNumber":"079","LineNumber":"010","PoLineNumber":"0","Description":"ADDPRRMCOR020001 - Delivery & Disposal","InvoicedStatus":"X","ReceivedStatus":"N","DeliveredStatus":"","DeliveryDate":"11-NOV-20","LineCreationDate":"16-NOV-20","DeliveryCreationDate":"16-NOV-20","StopAddress1":"5807 Parkview Point Dr","StopAddress2":"","StopCity":"Orlando","StopState":"FL","StopPostalCode":"32821","ProjectAddress1":"5807 Parkview Point Dr","ProjectAddress2":"","ProjectCity":"Orlando","ProjectState":"FL","ProjectPostalCode":"32821","AppointmentStartDate":"","AppointmentEndDate":"","QuoteQuantity":1,"POQuantity":null,"BookedDate":"28-AUG-20","NeedDate":"05-OCT-20","PurchaseDate":"","ReceiptDate":"","ShipDate":"","LastRevisionDate":"","RollupUnitPrice":258.32,"DiscountPct":0,"ListPrice":null,"DACost":null,"RecdStatusLineCount":0}]';
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(Body);
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGeneratorError implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://apidev.pella.com/order-enquiry/v1/oms-orders', req.getEndpoint());
            String Body = '[{"OrderNumber":"72120TELEA","OrderStatus":"6","BranchNumber":"079","LineNumber":"010","PoLineNumber":"0","Description":"ADDPRRMCOR020001 - Delivery & Disposal","InvoicedStatus":"X","ReceivedStatus":"N","DeliveredStatus":"","DeliveryDate":"11-NOV-20","LineCreationDate":"16-NOV-20","DeliveryCreationDate":"16-NOV-20","StopAddress1":"5807 Parkview Point Dr","StopAddress2":"","StopCity":"Orlando","StopState":"FL","StopPostalCode":"32821","ProjectAddress1":"5807 Parkview Point Dr","ProjectAddress2":"","ProjectCity":"Orlando","ProjectState":"FL","ProjectPostalCode":"32821","AppointmentStartDate":"","AppointmentEndDate":"","QuoteQuantity":1,"POQuantity":null,"BookedDate":"28-AUG-20","NeedDate":"05-OCT-20","PurchaseDate":"","ReceiptDate":"","ShipDate":"","LastRevisionDate":"","RollupUnitPrice":258.32,"DiscountPct":0,"ListPrice":null,"DACost":null,"RecdStatusLineCount":0}]';
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(Body);
            res.setStatusCode(400);
            return res;
        }
    }
    static testMethod void testMethod1(){
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.PO_Number__c = '72120TELEA';
        q.Quote_Number_PQM__c = '123456';
        insert q;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        q.Work_Order__c = wo.Id;
        q.Status = 'Booked';
        q.PO_Number__c = '72120TELEA';
        update q;
        Test.startTest();
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new POMSIntegrationDataLoadCtrlTest.MockHttpResponseGenerator());
        
        POMSIntegrationDataLoadCtrl.getOrderDetails(wo.Id);
        POMSIntegrationDataLoadCtrl.formatDate('12-02-1999');
        Test.stopTest();
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
        q.PO_Number__c = '72120TELEA';
        q.Quote_Number_PQM__c = '123456';
        insert q;
        
        //create work type
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);
        
        //createbranch
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
        bf.Branch_Family_Number__c = '124';
        insert bf;
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        WorkOrder wo = TestUtil.createWorkOrder('Test subject', null, branch.Id, ac.Id, q.Id, true);
        q.Work_Order__c = wo.Id;
        q.Status = 'Booked';
        q.PO_Number__c = '72120TELEA';
        update q;
        Test.startTest();
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorError());
        
        POMSIntegrationDataLoadCtrl.getOrderDetails(wo.Id);
        POMSIntegrationDataLoadCtrl.formatDate('12-02-1999');
        Test.stopTest();
    }
}