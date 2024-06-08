@isTest(seeAllData=true)
public with sharing class LwcDataStoreIntegrationTest {
    @isTest
    public static void testMethod1(){
        Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
        acc.mdmrecid__c = '4081706234';
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new LwcCalloutMock());
        LwcDataStoreIntegration.getFedexRate(acc.Id);
        Test.stopTest();
	}
}