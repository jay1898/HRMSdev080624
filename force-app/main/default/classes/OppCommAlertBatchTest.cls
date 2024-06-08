@isTest
private class OppCommAlertBatchTest 
{
    public static String CRON_EXP = '0 0 0 3 9 ? 2023';
    static testMethod void TestOppCommAlertBatchMethod(){
        
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
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Opportunity
        
        Communication__c comm = TestUtil.createCommunication(true);
        
        Communication_Component__c comcop = TestUtil.createCommunicationComponent(comm.Id, false);
        comcop.Email_Template__c='COM1 CC1';
        comcop.Channel__c = 'Email';
        insert comcop;
        
        
      /*  Mogli_SMS__SMS_Template__c SMSTemp=TestUtil.createMogliTemplate('OppComm','OppComm',true);
        
        Communication_Component__c comcopsms = TestUtil.createCommunicationComponent(comm.Id, false);
        comcopsms.Email_Template__c='OppComm';
        comcopsms.Channel__c = 'SMS';
        insert comcopsms;*/
        
        // Create OpportunityCommunication
        OpportunityCommunication__c OC = TestUtil.createOpportunityCommunication(con.Id,opp.Id,comm.Id,comcop.Id,true);
        
        Test.startTest();
        OppCommAlertBatch BatchApex = new OppCommAlertBatch();  
        DataBase.executeBatch(BatchApex);
        
        String jobId = System.schedule('OppCommAlertBatchTest', CRON_EXP, new OppCommAlertBatch());
        
        Test.stopTest();
    }
     static testMethod void TestOppCommAlertBatchMethodSMS(){
        
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
       
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Opportunity
        
        Communication__c comm = TestUtil.createCommunication(true);
        
        Communication_Component__c comcop = TestUtil.createCommunicationComponent(comm.Id, false);
        comcop.Email_Template__c='COM1 CC1';
        comcop.Channel__c = 'Email';
        insert comcop;
       OpportunityCommunication__c oc = TestUtil.createOpportunityCommunication(con.Id,Opp.Id,comm.Id,comcop.Id,true);

        
       /* Mogli_SMS__SMS_Template__c SMSTemp=TestUtil.createMogliTemplate('Opportunity Communication','Opportunity Communication',true);
        
        Communication_Component__c comcopsms = TestUtil.createCommunicationComponent(comm.Id, false);
        comcopsms.Email_Template__c='Opportunity Communication';
        comcopsms.Channel__c = 'SMS';
        insert comcopsms;*/
        
        // Create OpportunityCommunication
        //OpportunityCommunication__c OC = TestUtil.createOpportunityCommunication(con.Id,opp.Id,comm.Id,comcopsms.Id,true);
        
        Test.startTest();
        OppCommAlertBatch BatchApex = new OppCommAlertBatch();  
        DataBase.executeBatch(BatchApex);
        
        String jobId = System.schedule('OppCommAlertBatchTest', CRON_EXP, new OppCommAlertBatch());
        
        Test.stopTest();
    }
}