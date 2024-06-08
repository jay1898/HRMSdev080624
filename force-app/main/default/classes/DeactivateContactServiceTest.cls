@isTest
public class DeactivateContactServiceTest {
    
    @TestSetup
    static void testSetup(){
            Account accountObj = TestUtil.createBranchAccount('Pella Account', false);
            insert accountObj;
            Contact contactObj = TestUtil.createContact(accountObj.Id, 'test', false);
            contactObj.MailingPostalCode = '12345';    
        	insert contactObj;
    }
        
    @isTest
    /* To confirm that method activates an inactive Contact */
    public static void activateAnInactiveContact(){
        list <Contact> contactRecord = [SELECT Id FROM Contact WHERE MailingPostalCode = '12345'];
        DeactivateContactService.toggleContactActiveStatus(contactRecord[0].Id, false);
        list <Contact> updatedContactRecord = [SELECT Active_Service__c FROM Contact WHERE MailingPostalCode = '12345'];
        System.assertEquals(updatedContactRecord[0].Active_Service__c,True);
    } 
    
    @isTest
    /* To confirm that method deactivates an active Contact */
    public static void deactivateAnActiveContact(){
        list <Contact> contactRecord = [SELECT Id FROM Contact WHERE MailingPostalCode = '12345'];
        contactRecord[0].Active_Service__c = true;
        update contactRecord[0];
        test.startTest();
        DeactivateContactService.toggleContactActiveStatus(contactRecord[0].Id, true);
        test.stopTest();
        list <Contact> updatedContactRecord = [SELECT Active_Service__c FROM Contact WHERE MailingPostalCode = '12345'];
        System.assertEquals(updatedContactRecord[0].Active_Service__c,False); 
    }   
    
    @isTest
    /* To confirm that method returns true for an active Contact */
    public static void getStatusOnActiveContact(){
        list <Contact> contactRecord = [SELECT Id FROM Contact WHERE MailingPostalCode = '12345'];
        contactRecord[0].Active_Service__c = true;
        update contactRecord[0];
        Boolean contactStatus = DeactivateContactService.getContactActiveStatus(contactRecord[0].Id);
        System.assertEquals(contactStatus,True); 
    }
}