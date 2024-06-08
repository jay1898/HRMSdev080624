/*
Created By      : Rahul Sangwan
Created Date    : 18 July 2023
Purpose         : This is controller to get Authentication of Order API.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class GraphServiceAuthenticateController {
    public static String scope = null;
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 18 July 2023
    *   Purpose         : Method to get Authentication token.
    *   Input Param     : 
    *   Output Param    : String ( Authorization token)
    */
    public static String getAuthenticationToken() { 
        try{
            if(scope == null) scope = Label.GraphQLScope;  //purchased_products_read
            String payload = 'grant_type=client_credentials&scope='+scope;
            system.debug('payload: ' + payload);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Okta_Auth');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody(payload);
            Http http = new Http();
            system.debug('request: ' + request);
            HTTPResponse response = http.send(request);
            OktaAuthResponse respBodyObj = OktaAuthResponse.parse(response.getBody());
            system.debug('respBodyObj: ' + respBodyObj);
            return respBodyObj.access_token;
        }catch(Exception e){
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('GraphServiceAuthenticateController', 'getAuthenticationToken', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        return null;
    }
}