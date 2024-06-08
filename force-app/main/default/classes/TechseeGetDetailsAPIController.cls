public class TechseeGetDetailsAPIController {

    @AuraEnabled(cacheable=true)
    public static String getDataFromTechsee(Id caseId) {
        Case caseObj                        = new Case();
        caseObj                             = TechseeGetDetailsAPICtrlModel.getCaseDetails(caseId);
        if(caseObj.TechSee_Request_Id__c == null || caseObj.Origin != Constant.TECHSEE_CASE_ORIGIN) return Constant.TECHSEE_CASE_INVALID_MSG;

        Techsee_API_Details__c techSeeCS    = Techsee_API_Details__c.getInstance();
        String authToken                    = getTechseeAuthToken(techSeeCS);
        String dataResp                     = getTechseeData(authToken, techSeeCS);
        return dataResp;
    }


    static String getTechseeAuthToken(Techsee_API_Details__c techSeeCS) {
        Map<String, String> requestMap  = new Map<String, String>();
        requestMap.put('api_key', techSeeCS.API_Key__c);
        requestMap.put('api_secret', techSeeCS.API_Secret__c);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(techSeeCS.Endpoint_URL_Auth__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestMap));

        Http http                   = new Http();
        HTTPResponse res            = http.send(req);
        AuthRespWrapper respBodyObj = AuthRespWrapper.parse(res.getBody());
        return respBodyObj.token;
    }


    static String getTechseeData(String authToken, Techsee_API_Details__c techSeeCS) {
        Map<String, String> requestMap  = new Map<String, String>();
        requestMap.put('token', authToken);
        requestMap.put('byRequestId','true');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(techSeeCS.Endpoint_URL_Case_Data__c + '/63f3632741fd496d6176d8e0');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestMap));

        Http http                   = new Http();
        HTTPResponse res            = http.send(req);
        return res.getBody();
    }
}