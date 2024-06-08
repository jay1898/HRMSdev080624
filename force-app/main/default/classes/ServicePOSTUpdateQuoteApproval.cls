@RestResource(urlMapping='/UpdateQuoteApprovalStatus/*')
global without sharing class ServicePOSTUpdateQuoteApproval {
	global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    
    
    global class Request {
        public String quoteId;
        public String approvalStatus;
        public String approvalMessage;
    }
    
    @HttpPost
    global static Response updateQuoteApproval() {
        RestRequest restRequest = Restcontext.request;
        Response response = new Response();
        RestResponse restResponse = RestContext.response;

         Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) {
            response.status = 'Not Found';
            response.httpStatusCode = '404';
            
            return response; 
		}
        
        restResponse.headers.put('Content-Type','application/json');
        restResponse.headers.put('Access-Control-Allow-Origin','*');
        
        Request request;
        
        String requestBody = restRequest.requestBody.toString() ;

        try{
            request = (Request)JSON.deserialize(requestBody, Request.class);
        }catch (Exception e){
            response.status = 'BAD_REQUEST';
            response.httpStatusCode = '400';
            response.errorMessage = e.getMessage();
            
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTUpdateQuoteApproval', 'updateQuoteApproval', requestBody, JSON.serialize(response), e.getStackTraceString()));
            
        	return response;
        }
        
        Set<String> statuses = new Set<String>{'Approved', 'Denied'};
        if(String.isBlank(request.approvalStatus) || !statuses.contains(request.approvalStatus) )
        {
             response.httpStatusCode = '400';
             response.status = 'BAD_REQUEST';
             response.errorMessage = 'Please provide a valid Approval Status (Approved, Denied)';

             return response;
        }
        System.debug('Request: ' + request);
        List<Quote> quotes = [
            SELECT Id, Approval_Status__c, Approval_Message__c, OpportunityId 
            FROM Quote 
            WHERE Id =: request.quoteId
        ];
        
        if (quotes.size() <= 0) {
            response.httpStatusCode = '404';
            response.status = 'NOT_FOUND';
             response.errorMessage = 'Quote not found';

             return response;
        }

        Quote quoteForUpdate = quotes[0];
        
        quoteForUpdate.Approval_Status__c = request.approvalStatus;
        quoteForUpdate.Approval_Message__c = request.approvalMessage;
            
        update quoteForUpdate;
        
        return response;
    }
}