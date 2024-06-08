/*
 * Added by Satheesh Bojanapu on 04/21/2021
 *  */
@isTest
global class LwcCalloutMock implements HttpCalloutMock{
	global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('PELLA SEGMENT-III');
    return res;
  }
}