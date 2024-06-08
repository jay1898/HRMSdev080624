@isTest
private class NationalAccountToEBSTest {
 	private static testMethod void testMethod1() {		
        Test.startTest();
    	Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
     	acc.Branch_Number__c='P64';
     	update acc;        
        NationalAccountToEBS.Request sReq = new NationalAccountToEBS.Request();
        sReq.recordId = acc.Id;
        NationalAccountToEBS.Request[] sReq1= new NationalAccountToEBS.Request[]{};
        sReq1.add(sReq);
        NationalAccountToEBS.sendAccountDetailToEBS(sReq1);       
        Test.stopTest();
	}
}