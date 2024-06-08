@isTest
public class SMSTriggerHandlerTest {
   /* static testMethod void TestOppCommAlertBatchMethodSMS(){
        
        // Create User
        User usr = TestUtil.createUser(true);
         Account acc = TestUtil.createBranchAccount('Pro_Lowes', true);
        Contact con=TestUtil.createContact(acc.id,'testes',false);
        con.Email='testMail@mail.com';
        insert con;
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.personEmail='testmail@mail.com';
        insert ac;
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
           // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        opp.Zone__c=ChildST.Id;
        opp.stagename='Follow-Up';
        update Opp;
        
        test.startTest();
        
        opp.RehashCommunication__c='RH 3 Day';
        update Opp; 
       
        Mogli_SMS__SMS_Template__c SMSTemp=TestUtil.createMogliTemplate('Opportunity Communication','Opportunity Communication',true);
        Mogli_SMS__SMS__c SMS=TestUtil.createMogliSMS('Incoming', null,'test', [SELECT Id,PersonContactID from account where id=:ac.Id].personContactId, 'Received Successfully', true);
        test.stopTest();
    }*/
}