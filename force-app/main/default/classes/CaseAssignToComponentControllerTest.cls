@isTest
public class CaseAssignToComponentControllerTest {
    
    @TestSetup
    static void makeData(){

        Account acc = TestUtil.createAccount('Person Account', false);
        acc.BillingCity = 'Test City';
        acc.BillingStreet = '123 Test Street';
        acc.BillingState = 'Test State';
        acc.BillingPostalCode = '654321';
        insert acc;

        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping Test', true);
        
        Branch__c branch = TestUtil.createBranch('Test Br', '10', bf.Id, true);

        Case caseObj  = new Case();
        caseObj.Status = 'Pending';
        caseObj.Origin = 'Email';
        caseObj.AccountId  = acc.Id;
        caseObj.Business_Segment__c = 'Trade';
        caseObj.Sales_Channel__c = 'Ecommerce';
        caseObj.Subject = 'Test Subject Case';
        caseObj.AssignedBranch__c = branch.Id;
        caseObj.Cc_Other_Email_Addresses__c = 'test001@gmail.com';
        insert caseObj;
    }

    // confirm that method returns a record if a Contact with a payment exists on the Case
    @isTest
    static void searchQueueandQueueMembersTest(){ 

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       
        System.runAs (thisUser) {

            Group testGroup = new Group();
            testGroup.Name='Test Group';
            testGroup.Type='Queue';
            insert testGroup;

            GroupMember gropMember = new GroupMember();
            gropMember.GroupId = testGroup.Id;
            gropMember.UserOrGroupId = UserInfo.getUserId();
            insert gropMember;

            Case caseObj = [Select Id, CaseNumber from Case Limit 1];

            Test.startTest();
                List<CaseAssignToComponentController.GroupWrapper> wrapList = CaseAssignToComponentController.searchQueueandQueueMembers('', caseObj.Id);
                system.assertEquals(1, wrapList.size(), 'It should return Group record atleast');

                List<CaseAssignToComponentController.GroupWrapper> testGroupList = CaseAssignToComponentController.searchQueueandQueueMembers('Test', caseObj.Id);
                system.assertEquals('Test Group', testGroupList[0].Name, 'It should return Test Group record');

                List<CaseAssignToComponentController.GroupWrapper> currentUserList = CaseAssignToComponentController.searchQueueandQueueMembers('Bal', caseObj.Id);
                system.assertEquals(1, currentUserList[0].GroupMembers.size(), 'It should return current User record Group Member');
            Test.stopTest();
        }
    }
}