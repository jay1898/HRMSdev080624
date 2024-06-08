@isTest
global class ServicePOSTRTAMock implements HttpCalloutMock 
{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) 
    {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{ "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "party", "statuscode": 200, "additionalresponsevalues": [{ "name": "partynumber", "value": 1009382533 }] }, { "mdmrecid": 20810796, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "PHONE", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 20810797, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-CALL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-EMAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-SMS", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 17698024, "spokerecid": "0012300000STbzBAAT", "message": "OK", "objectcode": "profiles-contactmethods-MAIL", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 24259326, "spokerecid": "a0o23000000FGlHAAW", "message": "OK", "objectcode": "account", "statuscode": 200, "additionalresponsevalues": [{ "name": "accountnumber", "value": 1005498153 }] }, { "mdmrecid": 11460528, "spokerecid": "a0m23000000CqHPAA0", "message": "OK", "objectcode": "address", "statuscode": 200, "additionalresponsevalues": null }, { "mdmrecid": 11460528, "spokerecid": "a0n23000000EMF5AAO", "message": "OK", "objectcode": "addressassignment", "statuscode": 200, "additionalresponsevalues": null }]');
        response.setStatusCode(200);
        return response; 
    } 
}