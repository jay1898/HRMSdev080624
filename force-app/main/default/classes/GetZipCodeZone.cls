@RestResource(urlMapping='/GetZipCodeZone')

global class GetZipCodeZone{
    
    @HttpGet
    
    global static void doGet() {
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        String zipcode= RestContext.request.params.get('zipcode');
        
        List<ServiceTerritory> lstServiceTerritory=[SELECT Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.ParentTerritoryId, ParentTerritory.ParentTerritory.Replacement_Branch_Number__c, ParentTerritory.OperatingHours.Local_Time__c,ParentTerritory.OperatingHours.TimeZone 
                                                    FROM ServiceTerritory WHERE PostalCode=:zipcode AND RecordType.Name='Zipcode' ];
        ServiceTerritory zoneST ;
        ServiceTerritory zoneParentST ;
        if(lstServiceTerritory.size()>0)
        {
            // Parent Territory (Zone Territory) of Zipcode territory
            zoneST = lstServiceTerritory[0].ParentTerritory;
            zoneParentST = zoneST.ParentTerritory;
            RestContext.response.responseBody = Blob.valueOf('{"TerritoryZone": "'+zoneST.RecordType.DeveloperName + '",' +
                                                             '"TimeZoneCode": "'+zoneST.OperatingHours.Local_Time__c + '",' +
                                                             '"TimeZone": "'+zoneST.OperatingHours.TimeZone + '",' +
                                                             '"RetailBranchNumber": "'+zoneParentST.Replacement_Branch_Number__c + '",' +
                                                             '"TradeBranchNumber": ""}');
        }else{
            RestContext.response.responseBody = Blob.valueOf( '{"TerritoryZone": "Zip Not Found"}');     
        }
        
        
    }
    
}