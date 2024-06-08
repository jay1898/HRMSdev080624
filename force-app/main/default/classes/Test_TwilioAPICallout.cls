@isTest
global class Test_TwilioAPICallout implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {        
        System.assertEquals('POST', req.getMethod(), 'HTTP method was not POST');

        System.debug('body: ' + req.getBody());

        Map<String, String> body = new Map<String, String>();
        for (String param: req.getBody().replace('%2B', '+').split('&')){
            String[] splitNameValue = param.split('=');  
            if (splitNameValue.size() == 1){
                body.put(splitNameValue[0], '');
            }
            else if (splitNameValue.size() == 2){
                body.put(splitNameValue[0], splitNameValue[1]);
            } 
        }
        
        System.debug('body map: ' + body.toString());

        System.assert(body.containsKey('To'), 'Missing To parameter');
        System.assert(body.containsKey('From'), 'Missing From parameter');
        System.assert(body.containsKey('Body'), 'Missing message body (Body parameter)');

        String responseBody;
        Integer statusCode;

        String fromNumber = body.get('From');
        String toNumber = body.get('To');

        if (fromNumber.startsWith('MG') && toNumber.startsWith('+1')) {
            responseBody = '{\"from\": null, \"messaging_service_sid\": \"MGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\"}';
            statusCode = 201;
        }
        else if (fromNumber.startsWith('+1') && toNumber.startsWith('+1')){
            responseBody = '{\"from\": \"+15551234567\", \"messaging_service_sid\": null}';
            statusCode = 201;
        }
        else {
            responseBody = '{\"code\": 21408}';
            statusCode = 401;
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody);
        res.setStatusCode(statusCode);
        return res;
    }
}