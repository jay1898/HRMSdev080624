public class UpdateAccountPhoneBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Phone, PersonOtherPhone, PersonMobilePhone, PersonHomePhone, PersonAssistantPhone, Phone_Text__c, Home_Phone_Text__c, Mobile_Text__c, Asst_Phone_Text__c, Other_Phone_Text__c, All_Account_Phones__c, 
            Phone_Idx__c, Home_Phone_Idx__c,  Mobile_Idx__c, Asst_Phone_Idx__c, All_Account_Phones_Idx__c, Other_Phone_Idx__c
            FROM Account
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> records) {
        
        for (Account acc : records) {
            String allPhonesConcatenated = ServiceUtil.concatenatePhoneNumbers(new List<String>{
                acc.Phone, acc.PersonOtherPhone, acc.PersonMobilePhone, acc.PersonHomePhone, acc.PersonAssistantPhone
            });
            acc.Phone_Idx__c = acc.Phone != null ? ServiceUtil.formatPhone(acc.Phone) : '';
            acc.Other_Phone_Idx__c = acc.PersonOtherPhone != null ? ServiceUtil.formatPhone(acc.PersonOtherPhone) : '';
            acc.Mobile_Idx__c = acc.PersonMobilePhone != null ? ServiceUtil.formatPhone(acc.PersonMobilePhone) : '';
            acc.Home_Phone_Idx__c = acc.PersonHomePhone != null ? ServiceUtil.formatPhone(acc.PersonHomePhone) : '';
            acc.Asst_Phone_Idx__c = acc.PersonAssistantPhone != null ? ServiceUtil.formatPhone(acc.PersonAssistantPhone) : '';
            acc.All_Account_Phones_Idx__c = allPhonesConcatenated;

        }
        update records;
    }
    
    public void finish(Database.BatchableContext BC) {}
}