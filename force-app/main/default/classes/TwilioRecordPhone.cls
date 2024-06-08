public with sharing class TwilioRecordPhone {

    public class NotSupportedException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static String getPhoneFromRecord(String strId) {
        Id recordId = Id.valueOf(strId);
        String recordType = recordId.getSobjectType().getDescribe().getName();

        TwilioPhoneObject returnValue = null;
        switch on recordType {
            when 'User' {
                returnValue = getPhoneFromUser(strId);
            }
            when 'Account' {
                returnValue = getPhoneFromAccount(strId);
            }
            when 'Opportunity' {
                returnValue = getPhoneFromOpportunity(strId);
            }
            when 'ServiceAppointment' {
                returnValue = getPhoneFromAppointment(strId);
            }
        }

        if (returnValue != null) {
            return JSON.serialize(returnValue);
        } else {
            NotSupportedException e = new NotSupportedException();
            e.setMessage(recordType + ' not supported');
            throw e;
        }
    }

    private static TwilioPhoneObject getPhoneFromAppointment(String strId) {
        Schema.DescribeFieldResult phoneC = ServiceAppointment.Phone__c.getDescribe();

        // Fields do not exist in Prod
        //Schema.DescribeFieldResult mobilePhoneC = ServiceAppointment.Mobile_Phone__c.getDescribe();
        //Schema.DescribeFieldResult alternatePhoneC = ServiceAppointment.Alternate_Phone__c.getDescribe();

        List<Schema.DescribeFieldResult> fieldObjects = new List<Schema.DescribeFieldResult> { phoneC };
        ServiceAppointment result = [SELECT Phone__c, Contact.Id from ServiceAppointment where Id = :strId LIMIT 1];
        
        try {
            return phoneValue(result, fieldObjects);
        } catch(NoDataFoundException e) {
            if (result.Contact.Id != null) {
                System.debug('No Phone found on ServiceAppointment Object. Checking Associated Contact (Id: ' + result.Contact.Id + ')');
                Id contactId = result.Contact.Id;
                return getPhoneFromContact((String) contactId);
            } else {
                NoDataFoundException e2 = new NoDataFoundException();
                e2.setMessage('No Phone found on ServiceAppointment Object and Contact Object is Blank');
                throw e2;
            }
        }
    }

    private static TwilioPhoneObject getPhoneFromContact(String strId) {
        Schema.DescribeFieldResult phone = Contact.Phone.getDescribe();
        Schema.DescribeFieldResult mobilePhone = Contact.MobilePhone.getDescribe();
        Schema.DescribeFieldResult homePhone = Contact.HomePhone.getDescribe();
        Schema.DescribeFieldResult otherPhone = Contact.OtherPhone.getDescribe();
        List <Schema.DescribeFieldResult> fieldObjects = new List<Schema.DescribeFieldResult> { phone, mobilePhone, homePhone, otherPhone};
        Contact result = [Select Phone, MobilePhone, HomePhone, OtherPhone from Contact where Id = :strId];

        return phoneValue(result, fieldObjects);
    }

    private static TwilioPhoneObject getPhoneFromOpportunity(String strId) {
        Schema.DescribeFieldResult phoneC = Opportunity.Phone__c.getDescribe();
        Schema.DescribeFieldResult leadReceiverPhoneC = Opportunity.Lead_Receiver_Phone__c.getDescribe();
        List<Schema.DescribeFieldResult> fieldObjects = new List<Schema.DescribeFieldResult> { phoneC, leadReceiverPhoneC };

        Opportunity result = [SELECT Phone__c, Lead_Receiver_Phone__c FROM Opportunity where Id = :strId LIMIT 1];

        return phoneValue(result, fieldObjects);
    }

    private static TwilioPhoneObject getPhoneFromAccount(String strId) {
        Schema.DescribeFieldResult phone = Account.Phone.getDescribe();
        Schema.DescribeFieldResult personMobilePhone = Account.PersonMobilePhone.getDescribe();
        Schema.DescribeFieldResult personHomePhone = Account.PersonHomePhone.getDescribe();
        Schema.DescribeFieldResult mobileCustom = Account.Mobile__c.getDescribe();
        List<Schema.DescribeFieldResult> fieldObjects = new List<Schema.DescribeFieldResult> { phone, personMobilePhone, personHomePhone, mobileCustom };

        Account result = [SELECT Phone, PersonMobilePhone, PersonHomePhone, Mobile__c FROM Account where Id = :strId LIMIT 1];
        
        return phoneValue(result, fieldObjects);
    }

    public static TwilioPhoneObject getPhoneFromUser(String strId) {
        Schema.DescribeFieldResult phone = User.Phone.getDescribe();
        Schema.DescribeFieldResult personMobilePhone = User.MobilePhone.getDescribe();
        List<Schema.DescribeFieldResult> fieldObjects = new List<Schema.DescribeFieldResult> { phone, personMobilePhone };
        User result = [SELECT Phone, MobilePhone FROM User WHERE Id = :strId LIMIT 1];

        return phoneValue(result, fieldObjects);
    }

    private static TwilioPhoneObject phoneValue(SObject result, List<Schema.DescribeFieldResult> fields) {
        if (result == null) {
            NoDataFoundException e = new NoDataFoundException();
            e.setMessage('Object not found');
            throw e;
        } else {
            for (Schema.DescribeFieldResult field : fields) {
                String fieldValue = (String) result.get(field.getName());
                if (fieldValue != null && !fieldValue.isWhitespace()) {
                    TwilioPhoneObject foundPhone = new TwilioPhoneObject();
                    foundPhone.phoneNumber = fieldValue;
                    foundPhone.source = field.getLabel();
                    return foundPhone;
                }
            }
            NoDataFoundException e = new NoDataFoundException();
            e.setMessage('No Phone found on ' + result.getSObjectType().getDescribe().getName());
            throw e;    
        }
    }
}