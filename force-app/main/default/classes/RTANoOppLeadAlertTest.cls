@isTest
public class RTANoOppLeadAlertTest {
    
    @isTest
    public static void RTANoOppLeadAlertTestMethodForException()
    {
        Test.startTest();
        RTANoOppLeadAlert classToTest = new RTANoOppLeadAlert();
        classToTest.execute(null);
        Test.stopTest();
    }
    @isTest
    public static void RTANoOppLeadAlertTestMethod()
    {
        RTAIntegrationConfig__c lastExTime = TestUtil.createRTAIntegrationConfig(System.now(),true);
        Test.startTest();
        RTANoOppLeadAlert classToTest = new RTANoOppLeadAlert();
        classToTest.execute(null);
        Test.stopTest();
    }
}