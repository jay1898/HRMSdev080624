/************************************************** 
 * Apex class to generate the SearchPersonsResponse 
 * Createddate : 04/18/2024
 * Created by : Wajid Abdhulla
******************************************************/



public class SearchPersonsService {

    public static Graphql_Configuration_Customer_Service__mdt graphConfigMetadata = [
        SELECT GraphQL_Query__c, Endpoint_URL__c
        FROM Graphql_Configuration_Customer_Service__mdt
        WHERE DeveloperName = 'Search_Persons'
        LIMIT 1
    ];


    /*
    *   Created By      : Wajid Abdhulla
    *   Purpose         : Method to generate the request body for searchpersons
    *   Input Param     : Map<String, Object> filters, Integer limitValue, Integer offsetValue
    *   Output Param    : String requestbody
    */
    public static String generateSearchPersonsRequestBody(Map<String, Object> filters, Integer limitValue, Integer offsetValue) {
       
        Map<String, Object> variables = new Map<String, Object>{
            'filter' => filters,
            'offset' => offsetValue,
            'limit' => limitValue
        };

        String query = graphConfigMetadata.GraphQL_Query__c;
        return GraphqlRequest.generateGraphqlRequestBody(query, 'SearchPersons', variables);
    }

    /*
    *   Created By      : Wajid Abdhulla
    *   Purpose         : Method to make the callout and receive the response from GraphQL for search persons
    *   Input Param     : Map<String, Object> filters, Integer limitValue, Integer offsetValue
    *   Output Param    : String response JSON
    */

    public static String generateSearchPersonsResponse(Map<String, Object> filters, Integer limitValue, Integer offsetValue){

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        String authenticationToken;
        authenticationToken = GraphServiceAuthenticateController.getAuthenticationToken(); 
        request.setEndpoint(graphConfigMetadata.Endpoint_URL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ authenticationToken);

        String requestBody = generateSearchPersonsRequestBody(filters, limitValue, offsetValue);
        request.setBody(requestBody);

        try {
            response = http.send(request);
            return response.getBody();
        } catch (Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('SearchPersonsService', 'generateSearchPersonsResponse', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        return null;

    }
    /*
    *   Created By      : Wajid Abdhulla
    *   Purpose         : Method to make the returned response available to VoiceAnswerScreenController
    *   Input Param     : Map<String, Object> filters, Integer limitValue, Integer offsetValue
    *   Output Param    : VoiceAnswerScreenResponse.CustDetails
    */

    public static List<VoiceAnswerScreenResponse.CustDetails> getCustomerDetails(Map<String, Object> filter, Integer theLimit, Integer theOffset) {
       
        String res = SearchPersonsService.generateSearchPersonsResponse(filter, theLimit, theOffset);
        System.debug('res:::::::'+res);
        SearchPersonsResponse response = SearchPersonsResponse.parse(res);
        List<VoiceAnswerScreenResponse.CustDetails> custDetailsList = new List<VoiceAnswerScreenResponse.CustDetails>();

        for (SearchPersonsResponse.Results result : response.data.searchPersons.results) {
            VoiceAnswerScreenResponse.CustDetails details = new VoiceAnswerScreenResponse.CustDetails(
                result.id, 
                result.displayName, 
                result.phoneNumber, 
                result.email, 
                result.street, 
                result.city, 
                result.state, 
                result.postalCode, 
                null,
                result.displayName 
            ); 
            details.fromGraph = true;
            
            custDetailsList.add(details);
        }

        return custDetailsList;
    }

      /*
    *   Created By      : Wajid Abdhulla
    *   Purpose         : Method to return addresses by passing customer Id to GraphQL
    *   Input Param     : String Customer Id
    *   Output Param    : List of GraphQLAddressResponse
    */
    public static List<GraphQLAddressResponse.getStreetAddressesForPersonById> generateCustomerAddressResponse(String customerId){
        Graphql_Configuration_Customer_Service__mdt config = [
            SELECT GraphQL_Query__c, Endpoint_URL__c
            FROM Graphql_Configuration_Customer_Service__mdt
            WHERE DeveloperName = 'Get_Customer_Address'
            LIMIT 1
        ];
        String addressQuery = config.GraphQL_Query__c;
        String authenticationToken;
        Map<String, Object> variables = new Map<String, Object>{
            'personId' => customerId  
        };
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        authenticationToken = GraphServiceAuthenticateController.getAuthenticationToken();
        request.setEndpoint(config.Endpoint_URL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ authenticationToken);

        String requestBody = GraphqlRequest.generateGraphqlRequestBody(addressQuery, 'GetStreetAddressesForPersonById', variables);
        request.setBody(requestBody);

        try {
            response = http.send(request);
            GraphQLAddressResponse parsedResponse = GraphQLAddressResponse.parse(response.getBody());
            return parsedResponse.data.getStreetAddressesForPersonById;


        } catch (Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('SearchPersonsService', 'generateCustomerAddressResponse', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        return null;
    }   
}