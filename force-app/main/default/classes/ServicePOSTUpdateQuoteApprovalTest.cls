@isTest
public class ServicePOSTUpdateQuoteApprovalTest {
    static testMethod void UpdateQuoteApprovalSuccessfulResultTest() {
        User user = TestUtil.createTradeCommSalesRep();
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opportunityOne = TestUtil.createOpportunity('New Test Opp One', ac.Id, user.Id, true); 
       
        Quote quote = TestUtil.createQuote(opportunityOne.Id, false);
        quote.Approval_Status__c = 'Approval Requested';
        quote.Quote_Number_PQM__c = '123456';
        insert quote;
        
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        
     	restRequest.requestURI = '/UpdateQuoteApprovalStatus';
        restRequest.httpMethod = 'POST';
        RestContext.request = restRequest;
        
        ServicePOSTUpdateQuoteApproval.Request approvalRequest = new ServicePOSTUpdateQuoteApproval.Request();
        approvalRequest.quoteId = quote.Id;
        approvalRequest.approvalStatus = 'Approved';
        approvalRequest.approvalMessage = 'This is a test approval';
        restRequest.requestBody = Blob.valueOf(JSON.serialize(approvalRequest));
        
        ServicePOSTUpdateQuoteApproval.Response response = ServicePOSTUpdateQuoteApproval.updateQuoteApproval(); 
        
        System.assertEquals('200', response.httpStatusCode);
        
        Quote result = [SELECT Id, Approval_Status__c, Approval_Message__c FROM Quote WHERE Id =: quote.Id]; 
        
        System.assertEquals('Approved', result.Approval_Status__c);
        System.assertEquals('This is a test approval', result.Approval_Message__c);
    }
    
    static testMethod void UpdateQuoteApprovalInvalidRequestTest() {
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        
     	restRequest.requestURI = '/UpdateQuoteApprovalStatus';
        restRequest.httpMethod = 'POST';
        RestContext.request = restRequest;
        
        restRequest.requestBody = Blob.valueOf('');
        
        ServicePOSTUpdateQuoteApproval.Response response = ServicePOSTUpdateQuoteApproval.updateQuoteApproval(); 
        
        System.assertEquals('400', response.httpStatusCode);
        System.assertEquals('BAD_REQUEST', response.status);
        
        List<Apex_Debug_Log__c> logs = [
            SELECT Id, Name, Apex_Class__c, Method__c 
            FROM Apex_Debug_Log__c ORDER BY CreatedDate DESC 
            LIMIT 5 
        ];
       	Apex_Debug_Log__c topLog = logs[0];
        
        System.assertEquals('ServicePOSTUpdateQuoteApproval', topLog.Apex_Class__c);
        System.assertEquals('updateQuoteApproval', topLog.Method__c);
    }

    static testMethod void UpdateQuoteApprovalInvalidApprovalStatusTest() {
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        
     	restRequest.requestURI = '/UpdateQuoteApprovalStatus';
        restRequest.httpMethod = 'POST';
        RestContext.request = restRequest;
        
        ServicePOSTUpdateQuoteApproval.Request approvalRequest = new ServicePOSTUpdateQuoteApproval.Request();
        approvalRequest.quoteId = '99999999';
        approvalRequest.approvalStatus = 'INVALID_VALUE';
        restRequest.requestBody = Blob.valueOf(JSON.serialize(approvalRequest));
        
        ServicePOSTUpdateQuoteApproval.Response response = ServicePOSTUpdateQuoteApproval.updateQuoteApproval(); 
        
        System.assertEquals('400', response.httpStatusCode);
        System.assertEquals('Please provide a valid Approval Status (Approved, Denied)', response.errorMessage);
    }
    
    static testMethod void UpdateQuoteApprovalQuoteNotFoundTest() {
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        
     	restRequest.requestURI = '/UpdateQuoteApprovalStatus';
        restRequest.httpMethod = 'POST';
        RestContext.request = restRequest;
        
        ServicePOSTUpdateQuoteApproval.Request approvalRequest = new ServicePOSTUpdateQuoteApproval.Request();
        approvalRequest.quoteId = '999999999';
        approvalRequest.approvalStatus = 'Approved';
        restRequest.requestBody = Blob.valueOf(JSON.serialize(approvalRequest));
        
        ServicePOSTUpdateQuoteApproval.Response response = ServicePOSTUpdateQuoteApproval.updateQuoteApproval(); 
        
        System.assertEquals('404', response.httpStatusCode);
        System.assertEquals('Quote not found', response.errorMessage);
    }
}