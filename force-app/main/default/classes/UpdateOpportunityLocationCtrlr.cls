/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: This class is fetching the existing opportunity location and updating the user current location
         or selected location on the opportunity
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/


public with sharing class UpdateOpportunityLocationCtrlr {
    
    //This method is fetching the existing oppotunity location
    @AuraEnabled
    public static LocationWrapper getOpportunityLocation(String OppId){
        //Validatinh if the opportunity id is not blank
        if(String.isNotBlank(OppId)){
            //fetching the opportunity
            Opportunity objOpportunity = [SELECT Id,Name,Geo_Location__Latitude__s, Geo_Location__Longitude__s FROM Opportunity WHERE Id =: oppId];
            //validation for checking the geolocation fields
            if(objOpportunity.Geo_Location__Latitude__s != Null && objOpportunity.Geo_Location__Longitude__s != Null){
                //assigning the opportunity location to the wrapper
                LocationWrapper objWrapper = new LocationWrapper(objOpportunity.Geo_Location__Latitude__s,objOpportunity.Geo_Location__Longitude__s,objOpportunity.Name);
                return objWrapper;
            }
        }
        return null;
    }

    //This method is saving the selected location on the current opportunity
    @AuraEnabled
    public static Boolean saveAccountLocation(String oppId,String OpportunityLocation){
        //validating if the opportunity id and selected location is not blank
        if(String.isNotBlank(oppId) && String.isNotBlank(OpportunityLocation)){
            //fetching the existing location
            Opportunity objOpportunity = [SELECT Id, Geo_Location__Latitude__s, Geo_Location__Longitude__s FROM Opportunity WHERE Id =: oppId];
            //replacing brackets from the selected location
            LocationAddressWrapper objLocationAddressWrapper = (LocationAddressWrapper) JSON.deserialize(OpportunityLocation, LocationAddressWrapper.class);
            objLocationAddressWrapper.location = objLocationAddressWrapper.location.replace('(', '');
            objLocationAddressWrapper.location = objLocationAddressWrapper.location.replace(')', '');
            //removing whitespace from the selected location
            objLocationAddressWrapper.location = objLocationAddressWrapper.location.deleteWhitespace();
            //Splitting the string values into list
            List<String> lstCoordinates = objLocationAddressWrapper.location.split(',');
            //assigning the location values in the opportunity fields
            objOpportunity.Geo_Location__Latitude__s = Decimal.valueOf(lstCoordinates[0].left(9));
            objOpportunity.Geo_Location__Longitude__s = Decimal.valueOf(lstCoordinates[1].left(9));
            objOpportunity.Street__c = (String.isNotBlank(objLocationAddressWrapper.street_number) ? (objLocationAddressWrapper.street_number + ' ') : '') + ' ' + objLocationAddressWrapper.route;
            objOpportunity.City__c = objLocationAddressWrapper.locality;
            objOpportunity.State__c = objLocationAddressWrapper.administrative_area_level_1;
            objOpportunity.Country__c = objLocationAddressWrapper.country;
            objOpportunity.Zipcode__c = objLocationAddressWrapper.postal_code;
            //updating the opportunity
            update objOpportunity;
            return true;
        }
        return false;
    }
    
    //Wrapper class for location of current opportunity
    public class LocationWrapper{
        @AuraEnabled public Decimal latitude;
        @AuraEnabled public Decimal longitude;
        @AuraEnabled public String title;
        public LocationWrapper(Decimal lat,Decimal lng, String oppName){
            latitude = lat;
            longitude = lng;
            title = oppName;
        }
    }
    //Wrapper class for location physical address
    public class LocationAddressWrapper{
        @AuraEnabled public string street_number;
        @AuraEnabled public string route;
        @AuraEnabled public string locality;
        @AuraEnabled public string administrative_area_level_1;
        @AuraEnabled public string country;
        @AuraEnabled public string postal_code;
        @AuraEnabled public string location;
    }
   }