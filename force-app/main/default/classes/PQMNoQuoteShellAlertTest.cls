@isTest
public class PQMNoQuoteShellAlertTest {
    
    @isTest
    public static void PQMNoQuoteShellAlertTestMethodForException()
    {
        Test.startTest();
        PQMNoQuoteShellAlert classToTest = new PQMNoQuoteShellAlert();
        classToTest.execute(null);
        Test.stopTest();
    }
    @isTest
    public static void PQMNoQuoteShellAlertTestMethod()
    {
        PQMIntegrationConfig__c lastExTime = TestUtil.createPQMIntegrationConfig(System.now(),true);
        Test.startTest();
        PQMNoQuoteShellAlert classToTest = new PQMNoQuoteShellAlert();
        classToTest.execute(null);
        Test.stopTest();
    }
}