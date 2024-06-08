@isTest
public class ProductIssueHierarchyCtrlTest {
    
    @TestSetup
    static void makeData(){
        Account acc = TestUtil.createBranchAccount('Pro_Lowes', false);
        acc.BillingCity = 'City';
        acc.BillingStreet = 'Test Street';
        acc.BillingState = 'State';
        acc.BillingPostalCode = '123456';
        insert acc;

        Contact con = TestUtil.createContact(acc.Id, 'TestContact', true);

        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);

        Case caseObj       = new Case();
        caseObj.Status     = 'New';
        caseObj.Origin     = 'Email';
        caseObj.ContactId  = con.Id;
        caseObj.AccountId  = acc.Id;
        caseObj.AssignedBranch__c = branch.Id;
      //  caseObj.Assigned_Branch__c = 'Chicago';
        caseObj.Business_Segment__c = 'Trade';
        caseObj.Sales_Channel__c = 'Ecommerce';
        caseObj.Subject = 'Test Subject';
        caseObj.Cc_Other_Email_Addresses__c = 'test001@gmail.com';
        insert caseObj;

        Case_Line__c csLine = TestUtil.createCaseLine(caseObj.Id, 'Pella', 'Test Desc 3','Test Comp 2', 'Awning','Test Issue 2', false);
        insert csLine;

        List<Product_Issue_Hierarchy__c> issueList  = new List<Product_Issue_Hierarchy__c>();
        issueList.add(new Product_Issue_Hierarchy__c(Service_Category__c = 'Test Cat', What_is_the_issue_with__c = 'Test Issue',
                                                     Component_noun__c = 'Test Comp', Description_Adj__c = 'Test Desc',
                                                     Brand__c = 'Test Brand', Product__c = 'Test Product'));
        issueList.add(new Product_Issue_Hierarchy__c(Service_Category__c = 'Test Cat', What_is_the_issue_with__c = 'Test Issue',
                                                     Component_noun__c = 'Test Comp', Description_Adj__c = 'Test Desc 2',
                                                     Brand__c = 'Test Brand', Product__c = 'Test Product'));
        issueList.add(new Product_Issue_Hierarchy__c(Service_Category__c = 'Test Cat 2', What_is_the_issue_with__c = 'Test Issue 2',
                                                     Component_noun__c = 'Test Comp 2', Description_Adj__c = 'Test Desc 2',
                                                     Brand__c = 'Test Brand 2', Product__c = 'Test Product 2'));                                     
        issueList.add(new Product_Issue_Hierarchy__c(Service_Category__c = 'Test Cat 2', What_is_the_issue_with__c = 'Test Issue 2',
                                                     Component_noun__c = 'Test Comp 2', Description_Adj__c = 'Test Desc 3',
                                                     Brand__c = 'Test Brand 2', Product__c = 'Test Product 2'));
        insert issueList;
    }


    @isTest
    private static void testProductIssueWOCreation() {
        ProductIssueHierarchyController.getProductAndIssueData('Test Brand', 'Test Product');
        ProductIssueHierarchyController.createWorkOrderForIssue([Select Id from Case_Line__c LIMIT 1].Id, 'Pella', 'Awning', 'Test Comp 2', 'Test Issue 2', 'Test Desc 3');
        ProductIssueHierarchyController.getProductTreeData(null, null, null);
    }
}