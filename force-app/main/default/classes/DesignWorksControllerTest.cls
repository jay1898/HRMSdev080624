@isTest
public class DesignWorksControllerTest {
    @isTest
    public static void testAccessAndQueueId() {
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;

        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', true);
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Commercial_Lead_Receiver__c = usr.Id;
        branch.Trade_Lead_Receiver__c  = usr.Id;
        branch.T_C_Branch_Number__c = '100';
        insert branch;
        // Create Account BranchProfile
        Account_Branch_Profile__c ABP = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
        
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false); 
        opp.CloseDate = Date.valueOf('2020-01-29');
        opp.StageName = 'New';
        opp.Create_Quote_Shell__c = true;
        opp.Communication__c = 'Thank you';
        opp.Is_In_Communication__c = false;
        opp.Create_Quote_Shell__c = false;
        opp.Account_Branch_Profile__c = ABP.Id;
        opp.RecordTypeId = OppRecTyTCId ;
        insert opp;
        Test.startTest();
        DesignWorksController.processDWAccess(opp.Id);
        
        
        /*Group testGroup = new Group(Name='DW Team', Type='Queue');
        insert testGroup;
        QueuesObject testQueue = new QueueSObject();
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            testQueue.QueueID = testGroup.id;
            testQueue.SObjectType = 'Case';
            insert testQueue;
        }*/
        
        //String queueId = [Select Id, Name, DeveloperName from Group where type='Queue' and DeveloperName='DW_Team'].Id;
        String QId = DesignWorksController.fetchQueueId();
        //System.debug(QId+' = = = '+testGroup.Id+' - - - '+queueId);
        System.assertEquals(QId, 'TESTRUN');
        
        Test.stopTest();
    }
}