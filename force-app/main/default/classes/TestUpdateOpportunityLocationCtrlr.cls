/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: TestUpdateOpportunityLocationCtrlr to test all the logic of UpdateOpportunityLocationCtrlr.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


@isTest
public class TestUpdateOpportunityLocationCtrlr {
    static testMethod void testData() {
        //Fetch RecordType Id
        string records=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Account').getRecordTypeId();
        //Insert Account
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        testAccount.Is_From_Custom_UI__c=true;
        testAccount.RecordTypeId  = records;
        insert testAccount;
        //Insert opportuntiy
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name='Test';
        objOpportunity.Geo_Location__Latitude__s=33.920860;
        objOpportunity.Geo_Location__Longitude__s=-118.415947;
        objOpportunity.StageName = 'New';
        objOpportunity.CloseDate = Date.today();
        objOpportunity.AccountId=testAccount.id;
        insert objOpportunity;
        objOpportunity.Geo_Location__Latitude__s=33.920860;
        objOpportunity.Geo_Location__Longitude__s=-118.415947;
        objOpportunity.Street__c='E Holly Ave';
        objOpportunity.City__c='El Segundo';
        objOpportunity.State__c='CA';
        objOpportunity.Country__c='United States';
        objOpportunity.Zipcode__c='90245';
        update objOpportunity;
        string location='{"street_number":"72","route":"Sanctuary","locality":"Irvine","administrative_area_level_1":"California","country":"United States","postal_code":"92620","location":"(33.69615503468632, -117.75421142578125)"}';
        UpdateOpportunityLocationCtrlr.LocationAddressWrapper objLocationAddressWrapper = new UpdateOpportunityLocationCtrlr.LocationAddressWrapper();
        objLocationAddressWrapper.street_number='E Holly Ave';
        objLocationAddressWrapper.locality='El Segundo';
        objLocationAddressWrapper.administrative_area_level_1='CA';
        objLocationAddressWrapper.country='United States';
        objLocationAddressWrapper.postal_code='90245';
        UpdateOpportunityLocationCtrlr.getOpportunityLocation(objOpportunity.id);
        UpdateOpportunityLocationCtrlr.saveAccountLocation(objOpportunity.id,location);
    }
}