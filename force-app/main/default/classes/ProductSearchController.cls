/*
Created By      : Rahul Sangwan
Created Date    : 9 May 2023
Purpose         : This is a Apex Controller from . 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ProductSearchController {

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 28 June 2023
    *   Purpose         : To get the Product Search User Settings from User_Component_Setting__c.
    *   Input Param     : String jsonString.
    *   Output Param    : return the User_Component_Setting__c value.
    */
    @AuraEnabled
    public static User_Component_Setting__c getUserSettings(String jsonString){
        List<User_Component_Setting__c> userSettingsList = [SELECT Id, User__c, Component__c, Setting_JSON__c, Name 
                                                            FROM User_Component_Setting__c 
                                                            WHERE User__c =: UserInfo.getUserId() 
                                                            AND Component__c = 'Product Search Table' Limit 1];

        if(userSettingsList.size() == 0) {
            User_Component_Setting__c userSettings = new User_Component_Setting__c();
            userSettings.User__c = UserInfo.getUserId();
            userSettings.Component__c = 'Product Search Table';
            userSettings.Setting_JSON__c = jsonString;
            insert userSettings;
            return userSettings;
        }
        
        return userSettingsList[0];
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 27 October 2023
    *   Purpose         : To get the Last 10 Searched item keywords Search from User_Component_Setting__c.
    *   Input Param     : String poSearchTerm for filter by the User Component Setting records.
    *   Output Param    : return the List<User_Component_Setting__c>.
    */
    @AuraEnabled
    public static User_Component_Setting__c getLastSearchedItems(String poSearchTerm){

        List<User_Component_Setting__c> userSettingsList = [SELECT Id, User__c, Component__c, Setting_JSON__c, Name 
                                                            FROM User_Component_Setting__c 
                                                            WHERE User__c =: UserInfo.getUserId() 
                                                            AND PO_Search_Terms__c =: poSearchTerm 
                                                            AND Component__c = 'Product Search Term' Limit 1];
        
        if(userSettingsList.size() == 0) {
            User_Component_Setting__c userSettings = new User_Component_Setting__c();
            userSettings.User__c = UserInfo.getUserId();
            userSettings.Component__c = 'Product Search Term';
            userSettings.PO_Search_Terms__c = poSearchTerm;
            userSettings.Setting_JSON__c = '';
            insert userSettings;
            return userSettings;
        }
        
        return userSettingsList[0];
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 28 June 2023
    *   Purpose         : To store the Product Search User Settings into User_Component_Setting__c.
    *   Input Param     : String jsonString.
    *   Output Param    : return the User_Component_Setting__c value.
    */
    @AuraEnabled
    public static User_Component_Setting__c updateUserSettings(String jsonString){

        User_Component_Setting__c userSettings = [SELECT Id, User__c, Component__c, Setting_JSON__c, Name 
                                                  FROM User_Component_Setting__c 
                                                  WHERE User__c =: UserInfo.getUserId() 
                                                  AND Component__c = 'Product Search Table' Limit 1];
        userSettings.Setting_JSON__c = jsonString;
        update userSettings;

        return userSettings;
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 27 October 2023
    *   Purpose         : To store the Product Search recent searched items into User_Component_Setting__c.
    *   Input Param     : String poSearchTerm for selected search by option value passed from LWC.
                          String searchedItems for typed product search item passed from LWC.
    *   Output Param    : return the User_Component_Setting__c value.
    */
    @AuraEnabled
    public static User_Component_Setting__c updateSearchTermUserSettings(String poSearchTerm, String searchedItems){

        User_Component_Setting__c userSettings = [SELECT Id, User__c, Component__c, Setting_JSON__c, Name 
                                                  FROM User_Component_Setting__c 
                                                  WHERE User__c =: UserInfo.getUserId() 
                                                  AND PO_Search_Terms__c =: poSearchTerm AND Component__c = 'Product Search Term' Limit 1];
        
        List<String> recentItemList = new List<String>();
        Set<String> recentItemSet = new Set<String>{searchedItems};
        List<String> existingItemList = String.isNotBlank(userSettings.Setting_JSON__c) ? userSettings.Setting_JSON__c.split(',') : new List<String>();
        recentItemSet.addAll(existingItemList);
        recentItemList.addAll(recentItemSet);
        if(recentItemList.size() > 10) {
            recentItemList.remove(10);
        }

        userSettings.Setting_JSON__c = string.join(recentItemList,',');
        update userSettings;

        return userSettings;
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 9 June 2023
    *   Purpose         : To get Address data from Address_Assignment__c.
    *   Input Param     : String caseId.
    *   Output Param    : return the wrapper of Address_Assignment__c and Address__c parent values.
    */
    @AuraEnabled(cacheable=true)
    public static List<ProductAddress> getAllAdressesByCaseId(String caseId){

        Case cse = [SELECT Id, AccountId FROM Case WHERE Id =: caseId];
        Map<Id, ProductAddress> addWrapperMap = new Map<Id, ProductAddress>();

        if(String.isNotBlank(cse.AccountId)) {
            for(Address_Assignment__c address : [SELECT Id, Account__c, Address_Usage_Type__c, Address__r.Address_Line_1__c, Address__r.Address_Line_3__c, Address__r.City__c, Address__r.Country__c, Address__r.Street__c, Address__r.State__c, Address__r.ZipCode__c, Address__r.Location_Id__c 
                                             FROM Address_Assignment__c 
                                             WHERE Account__c =: cse.AccountId]) {

                if(!addWrapperMap.containsKey(address.Address__r.Id)){
                    ProductAddress addWrapper  = new ProductAddress();
                    addWrapper.Id = address.Id;
                    addWrapper.AccountId = address.Account__c;
                    addWrapper.AddressId = address.Address__r.Id;
                    addWrapper.type = address.Address_Usage_Type__c;
                    addWrapper.AddressLine1 = address.Address__r.Address_Line_1__c;
                    addWrapper.AddressLine2 = address.Address__r.Address_Line_3__c;
                    addWrapper.Street = address.Address__r.Street__c;
                    addWrapper.City = address.Address__r.City__c;
                    addWrapper.Country = address.Address__r.Country__c;
                    addWrapper.Zipcode = address.Address__r.ZipCode__c;
                    addWrapper.State = address.Address__r.State__c;
                    addWrapper.LocationId = address.Address__r.Location_Id__c;
                    addWrapper.IsChecked = false;
                    addWrapperMap.put(address.Address__r.Id, addWrapper);
                }
            }
        }
        return addWrapperMap.values();
    }

    public class ProductAddress {

        @auraEnabled public String id{get;set;}
        @auraEnabled public String accountId{get;set;}
        @auraEnabled public String addressId{get;set;}
        @auraEnabled public String type{get;set;}
        @auraEnabled public String addressLine1{get;set;}
        @auraEnabled public String addressLine2{get;set;}
        @auraEnabled public String street{get;set;}
        @auraEnabled public String city{get;set;}
        @auraEnabled public String country{get;set;}
        @auraEnabled public String zipcode{get;set;}
        @auraEnabled public String state{get;set;}
        @auraEnabled public String locationId{get;set;}
        @auraEnabled public boolean isChecked{get;set;}
    }
}