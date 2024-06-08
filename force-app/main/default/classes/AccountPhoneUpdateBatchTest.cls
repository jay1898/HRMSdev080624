@isTest
global class AccountPhoneUpdateBatchTest 
{
    static testMethod void testMethod1() 
    {
        
        User u = TestUtil.createUser(true);
        
        Account acc = TestUtil.createAccount('Person Account', true);
        acc.PersonHomePhone='1236525632';
        acc.PersonOtherPhone='1236525632';
        acc.PersonAssistantPhone='1236525632';
        acc.Evening_Phone_Type__c='Home';
        update acc;
        
         AccountPhoneUpdateBatch b = new AccountPhoneUpdateBatch(); 
        database.executebatch(b,10);
        
    }
}