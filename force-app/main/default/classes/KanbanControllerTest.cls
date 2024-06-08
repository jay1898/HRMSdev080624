@isTest
public class KanbanControllerTest {
    static testMethod void testMethod1(){
        User testUser = TestUtil.createUser(false);
        testUser.EBS_UserName__c = 'SADHWANIR';
        insert testUser;
        system.runAs(testUser) 
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            RestContext.request = req;
            RestContext.response = res;
            
            // Create Account
            Account ac = TestUtil.createAccount('Person Account', false);
            ac.PersonHomePhone = ac.PersonMobilePhone ;
            ac.PersonOtherPhone = ac.PersonMobilePhone ;
            ac.PersonAssistantPhone = ac.PersonMobilePhone ;
            ac.PersonMailingStreet = '2 Test St';
            ac.PersonMailingCity = 'Belmont';
            ac.PersonMailingState = 'NH';
            ac.PersonMailingPostalCode = '03220-4052';
            ac.PersonMailingCountry = 'US';
            insert ac ;
            
            
            // Create Opportunity
            Opportunity opp = TestUtil.createOpportunity('TEst-1', ac.Id, UserInfo.getUserId(), false);
            opp.Opportunity_No__c = '123';
            insert opp ;
            
            FollowUpCommunicationController.getOpportunityDetail(opp.Id);
            FollowUpCommunicationController.saveOpportunity(opp.Id,String.valueOf(DateTime.now()),'3 Day'); 
            
            KanbanController k=new KanbanController();
            k.StageName='5 Days';
            k.oppId=opp.Id;
            k.updateOpportunityStage();
            
        }
    }
}