@isTest
public class TestSyncEBSContactBatch {
    static testMethod void testData() {
        // Create Account
        Account ac = TestUtil.createBranchAccount('Pro_Lowes', true);
        Contact ct = TestUtil.createContact(ac.id,'TestLast', true);
          SyncEBSContactsBatch b = new SyncEBSContactsBatch(); 
        database.executebatch(b,10);       
    }

}