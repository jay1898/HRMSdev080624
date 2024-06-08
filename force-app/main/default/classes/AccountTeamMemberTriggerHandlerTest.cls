@isTest
private class AccountTeamMemberTriggerHandlerTest {
    @isTest
    static void testmethod1(){
        User usr = TestUtil.createUser(true);
        Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
        acc.mdmrecid__c = '4567890';
        update acc;
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.UserId = usr.Id;
        atm.AccountAccessLevel='Edit';
        atm.TeamMemberRole = 'Inside Sales Support';
        atm.OpportunityAccessLevel = 'Read';
        insert atm;
        
        // Perform test
        Test.startTest();
        atm.CaseAccessLevel = 'Read';
        update atm;
        system.assertEquals('Inside Sales Support', atm.TeamMemberRole);
        Delete atm;        
        Test.stopTest();
    }
}