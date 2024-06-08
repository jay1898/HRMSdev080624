/*
Created By: Sachin Padhiyar
Created Date: 04/01/2020
Purpose: Calling the EBSRESTCallout class to get the account information 
----------------------------------------------------------------------------------------------
Modified By: 
Modified Date: 
Purpose: 
------------------------------------------------------------------------------------------------
*/

public with sharing class Calloutwebservice {
    
    @AuraEnabled
    public static string docallout(String accId) {
        string statuscode = EBSRESTCallout.createCustomerEBSData(accId);
        return statuscode;
    }
   /* @AuraEnabled
    public static Account fetchAcoountrecord(String accId) {
        Account acc = [Select id,mdmrecid__c from Account Where id =: accid];
        return acc;
    }*/
}