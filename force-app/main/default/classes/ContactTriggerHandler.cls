/*
Created By: 
Created Date: 03/03/2021
Purpose: This is a trigger handler for sObject Contact to perform required operations.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/
public class ContactTriggerHandler {
    
    public static Boolean RUN_EBS_CALLOUT = true ; 
    public static Boolean RUN_TRIGGER=true;  
    
    /*
    Added By : Rahul Sangwan
    Date     : 6 Sept 2023
    Story    : SCS-672
    Purpose  : this method will check if a Contact was created by the Quiq us
    
    
    
    er, and if so add to the Pella Corporate Bucket Account
    */
    public static void addQuiqContactsToBucketAccount(List<Contact> newList) {
        Id userId       = null;
        Id accountId    = null;
        try{
            userId = [Select Id from User where Name =: System.Label.Quiq_User LIMIT 1].Id;
        }catch(Exception e) {}

        try{
            accountId = [Select Id from Account where Name =: System.Label.Corporate_Bucket_Account LIMIT 1].Id;
        }catch(Exception e) {}
        
        for(Contact contactObj : newList) {
            if(userId != null && accountId != null && contactObj.OwnerId == userId && contactObj.AccountId == null) contactObj.AccountId = accountId;
        }
    }


    public static void resetContactOrgIdOnAccountChange(List<Contact> newContacts, Map<Id, Contact> oldConMap){
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        Id proLowerRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Pro_Lowes_Record_Type').getRecordTypeId();
        
        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newContacts){
            if(con.Account_Recordtype__c==recordTypeId){
                if(oldConMap!=null && con.AccountId!=null && oldConMap.get(con.Id).AccountId!=con.AccountId)
                {
                    
                    // Make EBS callout to inactive contact
                    EBSRESTCallout.inActiveContactToEBSCallout(con.Id,oldConMap.get(con.Id).AccountId,oldConMap.get(con.Id).Org_Contact_ID__c,oldConMap.get(con.Id).Account_mdmbranchrecId__c);
                    
                    con.Org_Contact_ID__c=null;
                    con.mdmhomephoneId__c=null;
                    con.mdmphoneid__c=null;
                    con.mdmmobilephoneid__c=null;
                    con.mdmotherphoneid__C=null;
                    con.mdmAssistantPhoneId__c=null;
                    con.mdmEmailId__c=null;
                    con.mdmfaxid__c=null;
                }
            }
            if(con.RecordTypeId == proLowerRecordTypeId){
                accountIds.add(con.AccountId);
            }
        }
        // Commeted out as this one is working from flow, we move code from flow to apex to resolve dupliacte error issue, we can remove comment one flow inactive
        /*Map<Id,Account> accountMap = new Map<Id,Account>([Select Id, OwnerId FROM Account WHERE Id IN : accountIds]);
        for(Contact con : newContacts){ 
			con.OwnerId = accountMap.get(con.AccountId).OwnerId;
        }  */   
    }
    
    public static void updateContactEBSCallout(List<Contact> newContacts, Map<Id, Contact> oldConMap) {
        ContactTriggerHandler.RUN_EBS_CALLOUT=false;
        String byUser='';
        User u=[SELECT id,name,EBS_UserName__c FROM User WHERE id = :Userinfo.getUserId()];
        if(String.isNotBlank(u.EBS_UserName__c)){
            byUser=u.EBS_UserName__c.toUpperCase();
        }
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        for(Contact con : newContacts){
            system.debug('con.Account_Recordtype__c: '+con.Account_Recordtype__c);
            if(con.Account_Recordtype__c==recordTypeId){
                if(oldConMap==null || (con.AccountId!=null 
                                       && (oldConMap.get(con.Id).AccountId!=con.AccountId|| oldConMap.get(con.Id).Active__c!=con.Active__c || oldConMap.get(con.Id).Contact_Status__c!=con.Contact_Status__c || oldConMap.get(con.Id).LastName!=con.LastName || oldConMap.get(con.Id).FirstName !=con.FirstName ||
                                           oldConMap.get(con.Id).HomePhone!=con.HomePhone ||oldConMap.get(con.Id).MobilePhone!=con.MobilePhone || oldConMap.get(con.Id).Fax!=con.Fax || oldConMap.get(con.Id).Phone!=con.Phone || oldConMap.get(con.Id).OtherPhone!=con.OtherPhone || oldConMap.get(con.Id).AssistantPhone!=con.AssistantPhone 
                                           || oldConMap.get(con.Id).Email!=con.Email || oldConMap.get(con.Id).Title!=con.Title ||  oldConMap.get(con.Id).Contact_Type__c!=con.Contact_Type__c  )))
                {
                    
                    // Added on 03-03 to Ignore send update back in case of api call made by EBS
                    // It should check if last update was made by PELSFINTEGRATION, dont send that update back.
                    //if(byUser!='PELSFINTEGRATION')
                    if(u.Name!=Label.Integration_UserName)
                    {
                        EBSRESTCallout.createUpdateContactToEBSCallout(con.Id); 
                    }
                }
            }
            
        }
        
    }
    
    
    public static void updatePrimaryContact(List<Contact> newContacts, Map<Id, Contact> oldConMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact con: newContacts){
            if(con.AccountId != null && String.isNotBlank(con.AccountId) && con.Primary__c){
                accountIds.add(con.AccountId);
            	contactIds.add(con.Id);
            }
        }
        
        List<Contact> contactList = [Select Id, AccountId, Primary__c FROM Contact WHERE AccountId IN : accountIds AND Id NOT IN : contactIds];
        for(Contact con : contactList){ 
            if(!contactIds.contains(con.Id) && accountIds.contains(con.AccountId)){
                con.Primary__c = false;
            }
        }
        update contactList;
    }
    //Method to copy over phone fields to indexed fields after clean up
    public static void updateServiceContactPhones(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        for (Contact c : newContacts) {
            Contact oldContact = oldMap != null ? oldMap.get(c.Id) : null;

            Boolean phoneFieldsChangedOrNew = oldContact == null || 
                    (c.Phone != oldContact.Phone) ||
                    (c.OtherPhone != oldContact.OtherPhone) ||
                    (c.MobilePhone != oldContact.MobilePhone) ||
                    (c.HomePhone != oldContact.HomePhone) ||
                    (c.AssistantPhone != oldContact.AssistantPhone);

            // Concatenate and format all phone numbers, separated by hyphens
            String allPhonesConcatenated = ServiceUtil.concatenatePhoneNumbers(new List<String>{
                c.Phone, c.OtherPhone, c.MobilePhone, c.HomePhone, c.AssistantPhone
            });

            if (phoneFieldsChangedOrNew) {
                c.Phone_Idx__c = c.Phone != null ? ServiceUtil.formatPhone(c.Phone) : '';
                c.Other_Phone_Idx__c = c.OtherPhone != null ? ServiceUtil.formatPhone(c.OtherPhone) : '';
                c.Mobile_Idx__c = c.MobilePhone != null ? ServiceUtil.formatPhone(c.MobilePhone) : '';
                c.Home_Phone_Idx__c = c.HomePhone != null ? ServiceUtil.formatPhone(c.HomePhone) : '';
                c.Asst_Phone_Idx__c = c.AssistantPhone != null ? ServiceUtil.formatPhone(c.AssistantPhone) : '';
                c.All_Contact_Phones_Idx__c = allPhonesConcatenated;
            }

        }
    }
}