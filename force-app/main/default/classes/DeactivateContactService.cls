/***************************************************************
 * Apex Class to support Inactivation of a Contact for Service
 * Created Date : 03/07/2024
 * Created By : WA
 ****************************************************************/
public without sharing class DeactivateContactService {
    @AuraEnabled
    public static Boolean toggleContactActiveStatus(Id contactId, Boolean currentState) {
        if (currentState) { 
            Integer openCases = [SELECT COUNT() FROM Case WHERE ContactId = :contactId AND Status NOT IN ('Closed', 'Completed')];
            if (openCases > 0) {
                throw new AuraHandledException('This Contact has one or more open Cases. Please review and resolve the related open Cases before inactivating the Contact.');
            }
        }
        
        Contact contact = [SELECT Id, Active_Service__c FROM Contact WHERE Id = :contactId LIMIT 1];
        contact.Active_Service__c = !currentState;
        update contact;
        return !currentState;
    }
    

    @AuraEnabled
    public static Boolean getContactActiveStatus(Id contactId) {
        Contact contact = [SELECT Id, Active_Service__c FROM Contact WHERE Id = :contactId LIMIT 1];
        return contact.Active_Service__c;
    }
}