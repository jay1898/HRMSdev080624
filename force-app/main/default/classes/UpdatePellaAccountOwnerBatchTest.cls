@isTest
public class UpdatePellaAccountOwnerBatchTest {
    public TestMethod static void ClassTestMethod(){
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c br = TestUtil.createBranch('Test Branch', '100', bf.Id, true);
        
        Account parentAcc = TestUtil.createBranchAccount('Pella Account', false);
        parentAcc.Temp_branch_Number__c = '5';
        parentAcc.Branch_Number__c = '10';
        insert parentAcc;
        
        Account childAcc = TestUtil.createBranchAccount('Branch Account', false);
        childAcc.ParentId = parentAcc.Id;
        childAcc.Branch__c = br.Id;
        childAcc.Temp_branch_Number__c = '5';
        childAcc.Branch_Number__c = '10';
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
        Database.SaveResult saveResult = Database.insert(childAcc, dml);
        
        Test.startTest();
        UpdatePellaAccountOwnerBatch updatePellaAccRec = New UpdatePellaAccountOwnerBatch();
        Database.executeBatch(updatePellaAccRec);
        system.schedule('Update Pella Account Test', '0 0 1 * * ?', updatePellaAccRec );
        Test.stopTest();
    }
}