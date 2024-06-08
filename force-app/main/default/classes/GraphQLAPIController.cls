/*
Created By      : Rahul Sangwan
Created Date    : 18 July 2023
Purpose         : Utility class to execute callouts to Supergraph services
*/
public class GraphQLAPIController {
    
    public static String authToken = null;
    
    public static String getResponseFromGraphQL(String labelName, String requestBodyVariables) {
        try {
            Graphql_Configuration_Customer_Service__mdt mdtObj = [SELECT Id, Endpoint_URL__c, GraphQL_Query__c
                                                                  FROM Graphql_Configuration_Customer_Service__mdt 
                                                                  WHERE Label =: labelName];
            checkAndRetrieveOAuthToken(false);
            String payload = mdtObj.GraphQL_Query__c + requestBodyVariables;
         //   String authenticationToken = GraphServiceAuthenticateController.getAuthenticationToken();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(mdtObj.Endpoint_URL__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer '+ authToken);
            request.setBody(payload);
            request.setTimeOut(120000);            
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getBody().contains('AUTH_ERROR')) {
                checkAndRetrieveOAuthToken(true);
                request.setHeader('Authorization', 'Bearer ' + authToken);
                response = http.send(request);
            }
            return response.getBody();
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('OrderAPiAuthenticateCtrl', 'getAuthenticationToken', e.getMessage(), e.getStackTraceString(), 'Internal'));
            return null;
        }   
    }
    
    
    public static void checkAndRetrieveOAuthToken(Boolean resetToken) {
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.GraphQLToken');
        if (orgPart.contains('key') && resetToken != true) {
            authToken = (String)orgPart.get('key');
        } else{
            authToken  = GraphServiceAuthenticateController.getAuthenticationToken();
            orgPart.put('key',authToken);
        }
    } 
}