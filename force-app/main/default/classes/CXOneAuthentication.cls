/********************************************************************
 Apex class to generate the access token for CX One
 **********************************************************************/

public without sharing class CXOneAuthentication {

    // Method to obtain the access token
    public static String getAccessToken() {
        // Fetch CXONE credentials from custom metadata
        CXONE_Cred__mdt creds = [SELECT Client_ID__c, Client_Secret__c, Username__c, Password__c, Endpoint__c FROM CXONE_Cred__mdt LIMIT 1];

        if (creds != null) {
            // Create the concatenated string of client ID and client secret
            String credentials = creds.Client_Id__c + ':' + creds.Client_Secret__c;

            // Encode the credentials in base64
            Blob credentialsBlob = Blob.valueOf(credentials);
            String encodedCredentials = EncodingUtil.base64Encode(credentialsBlob);

            String requestBody = 'grant_type=password' +
                                '&username=' + creds.Username__c +
                                '&password=' + creds.Password__c;

            HttpRequest request = new HttpRequest();
            request.setEndpoint(creds.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', 'Basic ' + encodedCredentials);
            request.setBody(requestBody);

            
            Http http = new Http();
            HttpResponse response = http.send(request);

            String accessToken;
           
            if (response.getStatusCode() == 200) {
               
                String responseBody = response.getBody();
                system.debug('The response is '+responseBody);
                Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                // Access the access token from the response
                accessToken = String.valueOf(tokenResponse.get('access_token'));
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
                accessToken = null; // Set accessToken to null in case of an error
            }

            return accessToken;
        } else {
            System.debug('CXONE credentials not found in custom metadata.');
            return null;
        }
    }

    public static string getSessionId(String accessToken){
        String endpoint = 'https://cxone.niceincontact.com/inContactAPI/services/v29.0/agent-sessions/join?asAgentId=39544050';

		String requestBody = '{"asAgentId": 39544050}';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
		request.setBody(requestBody);
       
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('accept', 'application/json');
		
        request.setHeader('Authorization', 'Bearer ' + accessToken);

		system.debug(request);       
        Http http = new Http();
        HttpResponse response;

        try {
            response = http.send(request);
            System.debug('Status: ' + response.getStatusCode());
            System.debug('Body: ' + response.getBody());
            Map<String, Object> sessionResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String theSessionId = String.valueOf(sessionResponse.get('sessionId'));
            return theSessionId;
        } catch(System.CalloutException e) {
            
            System.debug('Callout error: ' + e.getMessage());
            return null;
        }
        
    }
}