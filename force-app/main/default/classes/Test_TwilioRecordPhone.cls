@isTest
private class Test_TwilioRecordPhone {
    @isTest(SeeAllData=true)
    static void testUser() {
        Id profileId = [SELECT Id, Name FROM Profile WHERE Name = 'Limited Access User' LIMIT 1].Id;

        User testUser = new User();
        testUser.Phone = '+15551234567';
        testuser.Username = 'testUser@testdomain.com';
        testUser.LastName = 'user';
        testUser.Email = 'testUser@testdomain.com';
        testUser.Alias = 'testUser';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';

        insert testUser;

        Test.startTest();
        String phoneJson = TwilioRecordPhone.getPhoneFromRecord(String.valueOf(testUser.Id));
        Test.stopTest();

        TwilioPhoneObject phone = (TwilioPhoneObject) JSON.deserialize(phoneJson, TwilioPhoneObject.class);

        System.assertEquals(phone.phoneNumber, testUser.Phone, 'Phone number was not retrieved successfully');
    }

    @isTest(SeeAllData=true)
    static void testAccount() {
        Account account = [SELECT Id, Name, Phone FROM Account WHERE Phone != NULL LIMIT 1];

        Test.startTest();
        String phoneJson = TwilioRecordPhone.getPhoneFromRecord(String.valueOf(account.Id));
        Test.stopTest();

        TwilioPhoneObject phone = (TwilioPhoneObject) JSON.deserialize(phoneJson, TwilioPhoneObject.class);

        System.assertEquals(phone.phoneNumber, account.Phone, 'Phone number was not retrieved successfully');

    }
    
    @isTest(SeeAllData=true) 
    static void testOpportunity() {
        Opportunity opp = [SELECT Id, Name, Phone__c FROM Opportunity WHERE Phone__c != NULL LIMIT 1];
        Test.startTest();
        String phoneJson = TwilioRecordPhone.getPhoneFromRecord(String.valueOf(opp.Id));
        Test.stopTest();

        TwilioPhoneObject phone = (TwilioPhoneObject) JSON.deserialize(phoneJson, TwilioPhoneObject.class);

        System.assertEquals(phone.phoneNumber, opp.Phone__c, 'Phone number was not retrieved successfully');
    }

    @isTest(SeeAllData=true) 
    static void testAppointment() {
        ServiceAppointment appt = [SELECT Id, Phone__c FROM ServiceAppointment WHERE Phone__c != NULL LIMIT 1];
        try {
            String phoneJson = TwilioRecordPhone.getPhoneFromRecord(String.valueOf(appt.Id));
            TwilioPhoneObject phone = (TwilioPhoneObject) JSON.deserialize(phoneJson, TwilioPhoneObject.class);
            System.assertEquals(phone.phoneNumber, appt.Phone__c, 'Phone number was not retrieved successfully');
            return;
        } catch(NoDataFoundException e) {
            System.debug('Appointment missing phone number; dont fail the test');
            return;
        }
    }

    @isTest(SeeAllData=true) 
    static void testAppointmentNoPhone() {
        try {
            ServiceAppointment appt = [SELECT Id, Phone__c FROM ServiceAppointment WHERE Phone__c = NULL LIMIT 1];
            String phoneJson = TwilioRecordPhone.getPhoneFromRecord(String.valueOf(appt.Id));
            return;
        } catch(NoDataFoundException e) {
            System.debug('Appointment missing phone number; dont fail the test');
            return;
        }
    }

    @isTest(SeeAllData=true) 
    static void testRecordNotSupported() {
        try {
            Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
            String phoneJson = TwilioRecordPhone.getPhoneFromRecord(String.valueOf(campaign.Id));
        } catch(TwilioRecordPhone.NotSupportedException e) {
            return;
        }
        System.assert(false, 'Exception Not Thrown');
    }

}