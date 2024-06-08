@RestResource(urlMapping='/getCalendar/*')
global with sharing class getCalendarAPI {
   
    @HttpGet
    global static void getCal()
    {
		RestRequest req = RestContext.request;

        RestResponse res = RestContext.response;
		String zip = RestContext.request.params.get('Zip');
 
        // Trim zipcode if needed
        zip = ServiceUtil.trimZipCode(zip);

        String sourceType=RestContext.request.params.get('Type');
        String Inter=RestContext.request.params.get('Interface');
        // String zipCode = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
        String resBody=RTAIntegration.getTimeSlotDetails(Zip,Inter,sourceType);
        
        res.responseBody =Blob.valueOf(resBody);
        res.headers.put('Content-Type','application/json');
        res.headers.put('Access-Control-Allow-Origin','*');
    }
    
}