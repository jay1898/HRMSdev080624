/**
* @description       : TerritoryGoogleMapViewCtrl to manage territory google map view
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   08-03-2022    Dhruv Javiya  Initial Version()
**/
public class TerritoryGoogleMapViewCtrl {
    Transient public String  TerritoryWiseZipCodes{get;set;}
    Transient public String ZipCodeWiseCoOrdinate{get;set;}
    Transient public String  TerritoryWiseResources{get;set;}
    Transient public String  TerritoryWiseDetails{get;set;}
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    private final Branch__c branch;
    public TerritoryGoogleMapViewCtrl(ApexPages.StandardController stdController) {
        this.branch = (Branch__c)stdController.getRecord();
        
        Map<String,List<String>> TerritoryWiseZipCodeList=new Map<String,List<String>>();
        Map<String,String> ZipCodeWiseCoOrdinates=new Map<String,String>();
        Map<String,String> TerritoryWiseDetail=new Map<String,String>();
        // retrive  territory Zipcode based on related branch and record type OV_Install_Territory
        for(Territory_Zipcode__c TZ :[SELECT Id,Name,Territory__c,Territory__r.Name ,ZipCode__r.Name,ZipCode__r.ZipCode_Co_Ordinates__c,ZipCode__c FROM Territory_Zipcode__c   
                                      Where Territory__r.Branch__c= :this.branch.Id 
                                      and Territory__r.RecordType.DeveloperName='OV_Install_Territory'
                                      and ZipCode__r.Name!=null and Territory__c!=null
                                      order by Name asc]){
                                          if(!TerritoryWiseZipCodeList.containsKey(TZ.Territory__c))  {
                                              TerritoryWiseZipCodeList.put(TZ.Territory__c,new List<String>());
                                          }       
                                          TerritoryWiseZipCodeList.get(TZ.Territory__c).add(TZ.ZipCode__r.Name);
                                          ZipCodeWiseCoOrdinates.put(TZ.ZipCode__r.Name,TZ.ZipCode__r.ZipCode_Co_Ordinates__c);
                                          TerritoryWiseDetail.put(TZ.Territory__c,TZ.Territory__r.Name);
                                      }
        Map<String,List<ServiceTerritoryMember>> TerritoryWiseResource=new Map<String,List<ServiceTerritoryMember>>();
        // retrive  Service Territory Member based on related Service Territory branch and record type OV_Install_Territory
        for(ServiceTerritoryMember STM :[SELECT Id,ServiceTerritory.Name,ServiceResource.Name,ServiceResource.Resource_Group__c, ServiceResource.Resource_Type__c  FROM ServiceTerritoryMember   
                                         Where ServiceTerritory.Branch__c= :this.branch.Id 
                                         and ServiceTerritory.RecordType.DeveloperName='OV_Install_Territory']){
                                             if(!TerritoryWiseResource.containsKey(STM.ServiceTerritoryId))  {
                                                 TerritoryWiseResource.put(STM.ServiceTerritoryId,new List<ServiceTerritoryMember>());
                                             }       
                                             TerritoryWiseResource.get(STM.ServiceTerritoryId).add(STM);                       
                                         }
        ZipCodeWiseCoOrdinate=JSON.serialize(ZipCodeWiseCoOrdinates);
        TerritoryWiseZipCodes=JSON.serialize(TerritoryWiseZipCodeList);
        TerritoryWiseResources=JSON.serialize(TerritoryWiseResource);
        TerritoryWiseDetails=JSON.serialize(TerritoryWiseDetail);
    }
}