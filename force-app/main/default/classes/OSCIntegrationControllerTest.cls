@isTest
public class OSCIntegrationControllerTest {
    private static testMethod void OSCIntegrationMethods_Test(){
        Test.setMock(HttpCalloutMock.class, new OSCIntegrationControllerMock()); 

        Account ac = TestUtil.createAccount('Person Account', true);
        ac.mdmrecid__c = '12243';
        update ac;
        
        Test.startTest();
        OSCIntegrationController.getDatePeriod();
        OSCIntegrationController.getOSCIntegrationData(ac.id);
        OSCIntegrationController.getAccountName(ac.id);
        Test.stopTest();
        //OSCIntegrationController.getOSCServiceData(ac.id);

    }
}