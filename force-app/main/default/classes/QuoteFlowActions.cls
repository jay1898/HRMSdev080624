public with sharing class QuoteFlowActions {
    public class OppException extends Exception {} 
    public class QuoteApprovalInput {
        @InvocableVariable public Id quoteId;
        @InvocableVariable public Id opportunityId;
        @InvocableVariable public String leadId;
        @InvocableVariable public String quoteNumber;
        @InvocableVariable public String opportunityOwnerFullName;
        @InvocableVariable public String opportunityOwnerTitle;
        @InvocableVariable public String opportunityOwnerEmail;
        @InvocableVariable public String accountCompanyEmail;
        @InvocableVariable public String branchNumber;
    }
    
    public class SendForReviewVariables {
        public String quoteNumber;
        public Id quoteId;
        public Id opportunityId;
        public String leadId;
        public String opportunityOwnerFullName;
        public String opportunityOwnerTitle;
        public String opportunityOwnerEmail;
        public String accountCompanyEmail;
        public String branchNumber;
    }
    
    public class SendForReviewInput {
        SendForReviewVariables input;
    }
 
    public class Result {
        @InvocableVariable(label='QuoteId for Output' description='A list of successfully updated QuoteIds' required=true)
  		public String quoteId;
    }

    @InvocableMethod(label='Send Quote for Approval' description='Send quote to user for approval' category='Quote')
    public static List<Result> SendQuoteForApproval (List<QuoteApprovalInput> quotesForApprovalList) {
        List<Result> resultsList = new List<Result>();

        for (QuoteApprovalInput quoteApprovalInput : quotesForApprovalList) {
            List<Graphql_Configuration__mdt> graphqlConfig = [
                SELECT Endpoint__c 
                FROM Graphql_Configuration__mdt 
                WHERE DeveloperName = 'Pella_Graphql_Configuration' 
            ]; 
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();   
            
            request.setEndpoint(graphqlConfig[0].Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(60000);
				
            SendForReviewVariables variables = new SendForReviewVariables();
            variables.quoteNumber = quoteApprovalInput.quoteNumber;
            variables.quoteId = quoteApprovalInput.quoteId;
            variables.opportunityId = quoteApprovalInput.opportunityId;
            variables.opportunityOwnerFullName = quoteApprovalInput.opportunityOwnerFullName;
            variables.opportunityOwnerTitle = quoteApprovalInput.opportunityOwnerTitle;
			variables.opportunityOwnerEmail = quoteApprovalInput.opportunityOwnerEmail;
            variables.accountCompanyEmail = quoteApprovalInput.accountCompanyEmail;
            variables.branchNumber = quoteApprovalInput.branchNumber;
            variables.leadId = quoteApprovalInput.leadId != null && string.isNotBlank(quoteApprovalInput.leadId) 
                ? quoteApprovalInput.leadId
                : null;
            
            SendForReviewInput sendForReviewInput = new SendForReviewInput();
            sendForReviewInput.input = variables;
            
            String mutationJson = GraphqlRequest.generateGraphqlRequestBody(
                'mutation SendQuoteForReview($input: SendQuoteForReviewInput!) { sendQuoteForReview (input: $input) { quoteNumber quoteStatus }}',
                'SendQuoteForReview',
                sendForReviewInput
            );
            
    		request.setBody(mutationJson);
            HttpResponse response = http.send(request);
			GraphqlResponse.GraphqlResponseBody gqlResponseBody = (GraphqlResponse.GraphqlResponseBody) JSON.deserialize(response.getBody(), GraphqlResponse.GraphqlResponseBody.class);

            if (gqlResponseBody.errors != null && gqlResponseBody.errors.size() > 0) {
                string errorMessage = gqlResponseBody.errors[0].message;
                new ApexDebugLog().createLog(new ApexDebugLog.Error('QuoteFlowActions', 'SendQuoteForApproval Graphql Error', mutationJson, errorMessage, 'External'));

                throw new OppException('SendQuoteForApproval Graphql Error');
            }
            
            Result successResult = new Result();
            successResult.quoteId = quoteApprovalInput.quoteId;
            
            resultsList.add(successResult);              
        }
        
        return resultsList;
    }
}