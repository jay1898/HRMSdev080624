/*
Created By: 
Created Date: 
Purpose: This class is fetching geo codes from address entered by user.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/
public with sharing Class GetMapLocation {
    //this method is a future method to get geo codes based on opportunity address
    @future(callout=true)
    public static void getLongitde_Latitude(String oppId){
        //fetching opportunity using the opportunity id passed
        Opportunity objOpp = [SELECT Id, Street__c,City__c,State__c,Country__c,Zipcode__c FROM Opportunity WHERE Id =: oppId];
        //adding all the address details as per google input parameter
        String address = objOpp.Street__c + ' ' + objOpp.City__c + ' ' + objOpp.State__c + ' ' +objOpp.Country__c;
        //encoding the address in utf format
        address = EncodingUtil.urlEncode(address, 'UTF-8');
        
        // start building callout
        Http h = new Http();        
        HttpRequest req = new HttpRequest();
        
        // Enter your Api key which you have created in google api console
        String key = '&key=' + Label.Google_Api_Key;
        //Enter the Google Api for custom label
        String endPoint = Label.Google_Map_Geocode_Api + address;
        //Setting end point in the request
        req.setEndpoint(endPoint + key);
        req.setMethod('GET');
        req.setTimeout(5000);
        try{
            // making callout
            //HttpResponse res = h.send(req);
            //system.debug('===>'+res.getBody());
            HttpResponse res;
                if(!test.isRunningTest()){
                    res = h.send(req);
                }
                else{
                    res = GetMapLocationCalloutMock.respond(req);
                }
            system.debug('===>'+res.getBody());
            // parse coordinates from response
            JSONParser parser = JSON.createParser(res.getBody());
            //Defining variable to store latitude and longitude
            double lat = null;
            double lon = null;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'location')){
                       // system.debug('a');
                        parser.nextToken(); // object start                     
                        while (parser.nextToken() != JSONToken.END_OBJECT){
                            String txt = parser.getText();
                            parser.nextToken();
                            if (txt == 'lat')
                                lat = parser.getDoubleValue();
                            else if (txt == 'lng')
                                lon = parser.getDoubleValue();
                        }
                    }
            }
            // update coordinates on opportunity if we get back
            if (lat != null && lon != null){
                objOpp.Geo_Location__Latitude__s = lat;
                objOpp.Geo_Location__Longitude__s = lon;
                //updation of opportunity
                update(objOpp);
            }
        }
        //Handle if callout throws an exception
        catch (Exception e) {
            system.debug(e);
        }
    }
}