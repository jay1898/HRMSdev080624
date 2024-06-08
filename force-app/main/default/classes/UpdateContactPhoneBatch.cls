public class UpdateContactPhoneBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Phone, OtherPhone, MobilePhone, HomePhone, AssistantPhone,  Phone_Text__c, Home_Phone_Text__c, Mobile_Text__c, Asst_Phone_Text__c, Other_Phone_Text__c,  All_Contact_Phones__c, Phone_Idx__c, Home_Phone_Idx__c, 
            Mobile_Idx__c, Asst_Phone_Idx__c, All_Contact_Phones_Idx__c, Other_Phone_Idx__c FROM Contact
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> records) {
        for (Contact c : records) {
            String allPhonesConcatenated = ServiceUtil.concatenatePhoneNumbers(new List<String>{
                c.Phone, c.OtherPhone, c.MobilePhone, c.HomePhone, c.AssistantPhone
            });
            c.Phone_Idx__c = c.Phone != null ? ServiceUtil.formatPhone(c.Phone) : '';
            c.Other_Phone_Idx__c = c.OtherPhone != null ? ServiceUtil.formatPhone(c.OtherPhone) : '';
            c.Mobile_Idx__c = c.MobilePhone != null ? ServiceUtil.formatPhone(c.MobilePhone) : '';
            c.Home_Phone_Idx__c = c.HomePhone != null ? ServiceUtil.formatPhone(c.HomePhone) : '';
            c.Asst_Phone_Idx__c = c.AssistantPhone != null ? ServiceUtil.formatPhone(c.AssistantPhone) : '';
            c.All_Contact_Phones_Idx__c = allPhonesConcatenated;
        }
        update records;
    }
    
    public void finish(Database.BatchableContext BC) {}
}