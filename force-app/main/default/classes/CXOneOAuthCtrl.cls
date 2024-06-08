/*
Created By      : Rahul Sangwan
Created Date    : 23 January 2024
Purpose         : This is for basic authentication and API Callout for CXOne Events
----------------------------------------------------------------------------------------------*/


public class CXOneOAuthCtrl {

    public static CXONE_Cred__mdt creds = [SELECT Client_ID__c, Max_Search_Records__c, Session_URL__c, Call_Details_URL__c,Skill_URL__c, Client_Secret__c, Username__c, Password__c, Endpoint__c FROM CXONE_Cred__mdt LIMIT 1];
    public static String authToken = null;

    /*
    *   Created By      : Rahul Sangwan
    *   Purpose         : Method to get the auth code
    *   Input Param     : None
    *   Output Param    : CXOneOAuthWrapperCtrl
    */

    public static CXOneOAuthWrapperCtrl getCXOneAuthCode() {
        HttpRequest httpRequest                     = new HttpRequest();
        httpRequest.setEndpoint('callout:CXONE');
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpRequest.setBody('grant_type=password&username='+EncodingUtil.urlEncode(creds.Username__c,'UTF-8') +'&password='+EncodingUtil.urlEncode(creds.Password__c,'UTF-8'));
        Http http                   = new Http();
        HTTPResponse httpResponse            = http.send(httpRequest);
        return CXOneOAuthWrapperCtrl.parse(httpResponse.getBody());
    }


     /*
    *   Created By      : Rahul Sangwan
    *   Purpose         : Method to get the sessionId for the Agent
    *   Input Param     : None
    *   Output Param    : String SessionId
    */

    @AuraEnabled
    public static string getSessionId(){
        String agentId = [SELECT id,CXNICE_Agent_Id__c FROM user WHERE Id =:UserInfo.getUserId() LIMIT 1].CXNICE_Agent_Id__c;
        String endpoint     =  creds.Session_URL__c ;
        checkAndRetrieveOAuthToken(false);
        String requestBody  = '{"asAgentId": ' + agentId + '}';
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod('POST');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('accept', 'application/json');        
        httpRequest.setHeader('Authorization', 'Bearer ' + authToken);
        Http http = new Http();
        HttpResponse response;

        try {
            response = http.send(httpRequest);
            if(response.getStatusCode() == 401) {
                checkAndRetrieveOAuthToken(true);
                httpRequest.setHeader('Authorization', 'Bearer ' + authToken);
                response = http.send(httpRequest);
            }
            System.debug(response.getBody());
            Map<String, Object> sessionResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String theSessionId = String.valueOf(sessionResponse.get('sessionId'));
            return theSessionId;
        } catch(System.CalloutException e) {            
            System.debug('Callout error: ' + e.getMessage());
            return null;
        }
        
    }

      /*
    *   Created By      : Wajid Abdhulla
    *   Purpose         : Method to get the Incoming call details like calling number, called number and queue name
    *   Input Param     : None
    *   Output Param    : CallDetailsWrapper
    */

    @AuraEnabled
    public static CallDetailsWrapper getCallDetails() {
        String endpoint     = creds.Call_Details_URL__c +'?timeout=30';
        endpoint            = endpoint.replace('{!sessionId}', getSessionId());
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + authToken);
        Http http = new Http();
        HTTPResponse res = http.send(request);
        CallDetailsWrapper callWrapper = new CallDetailsWrapper(); 
        CallEventResponseWrapper eventResponse = CallEventResponseWrapper.parse(res.getBody());
        List<CallEventResponseWrapper.Events> events = eventResponse.events;
        for(CallEventResponseWrapper.Events event: events){
            if(event.type == 'CallContactEvent'){
                callWrapper.DNIS = event.DNIS;
                callWrapper.ANI = event.ANI;
                callWrapper.skill = event.skill;
                
            }
        }
        callWrapper.skillName = getSkillNameById(callWrapper.skill);
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c(); 
        objApex.Apex_Class__c ='Test CXOne';
        objApex.Method__c ='GET';
        objApex.Type__c ='Information';
        objApex.Message__c = res.getBody();
        insert objApex;
        return callWrapper;
    }

      /*
    *   Created By      : Wajid Abdhulla
    *   Purpose         : Method to get the skill name to be populated on the Voice Call screen
    *   Input Param     : None
    *   Output Param    : String skillname
    */

    public static String getSkillNameById(string skillId){
        if(skillId == null){
            return null;
        }
        system.debug('inside skill callout');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(creds.Skill_URL__c + skillId);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + authToken);

        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('the response is '+res.getBody());
        if (res.getStatusCode() == 200) {
            
            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String skillName = (String)resBody.get('skillName');
            return skillName;
        } else {
            return null;
        }
    }  
    
    
       /*
    *   Created By      : Rahul Sangwan
    *   Purpose         : Method to store and retrieve the auth token until expiry in platform cache
    *   Input Param     : Boolean resetToken
    *   Output Param    : None
    */

    public static void checkAndRetrieveOAuthToken(Boolean resetToken) {
        system.debug('test');
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.CXOneAuthToken');
        if (orgPart.contains('key') && resetToken != true) {
            authToken = (String)orgPart.get('key');

        } else{
            authToken  = getCXOneAuthCode().access_token;
            orgPart.put('key',authToken);
        }
    } 
}