/*
Created By: Sachin Padhiyar
Created Date: 04/02/2020
Purpose: Testing the Calloutwebservice class.
----------------------------------------------------------------------------------------------
Modified By: 
Modified Date: 
Purpose: 
------------------------------------------------------------------------------------------------
*/

@isTest
public with sharing class CalloutwebserviceTest {
    
    @isTest
    public static void testDocallout() {
        Account ac = TestUtil.createAccount('Person Account', true);
        ac.Mail_Opt_Out__c=true;
        Calloutwebservice.docallout(ac.Id);
    }
}