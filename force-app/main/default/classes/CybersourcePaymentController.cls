public class CybersourcePaymentController {
    
    
    /*
    *   Created By      : Lucas Soderstrom
    *   Added on        : 17 Aug 2023
    *   Purpose         : Method to find existing payments tied to Case Contact. 
    *   User Story      : SCS-159
    *   Input Param     : 1) caseId       - Id of case record, passed from LWC
    *   Output Param    : List of Payment records 
    */
    @AuraEnabled(cacheable=true)
    public static list <Payment__c> checkForExistingPayment(String caseId){
        list <Payment__c> contactPayments = new list <Payment__c>(); 
        list <Case> currentCase = [Select ContactId FROM Case WHERE Id = :caseId];
        
        contactPayments = [Select Cybersource_Token__c FROM Payment__c WHERE Contact__c = :currentCase[0].ContactId
                                        ORDER BY CreatedDate desc Limit 1];
        return contactPayments;
        
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 25 Oct 2023
    *   Purpose         : Method return the Cybersource JSON payload. 
    *   User Story      : SCS-162 (Bug 1169)
    *   Input Param     : 1) conId       - Contact Id of case record, passed from LWC
                          2) caseId       - Id of case record, passed from LWC
                          3) brchId       - Branch Id of case record, passed from LWC
    *   Output Param    : Map<String, String> 
    */
    // @AuraEnabled
    // public static CyberSourceJSONWrapper buildCyberSourceJSONPayload(String conId, String caseId, String brchId, String amt, String tranType){
        
    //     CyberSourceJSONWrapper cyberWrapper = new CyberSourceJSONWrapper();
    //     Map<String, String> payload = new Map<String, String>();

    //     Contact conRecord = [Select Id, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone from Contact Where Id =: conId];
    //     Branch__c branchRecord = [Select Id, Merchant_Id__c from Branch__c Where Id =: brchId LIMIT 1];
    //     Merchant__c merRecord = [SELECT Id, Access_Key__c, Merchant_Id__c, Profile_Id__c, Secret_Key__c FROM Merchant__c Where Merchant_Id__c =: branchRecord.Merchant_Id__c LIMIT 1];

    //     //String transType = ApexPages.CurrentPage().getParameters().get('type');
    //     //String amount = ApexPages.CurrentPage().getParameters().get('amt');
    //     String signedDate = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

    //     String trans_Guid = getCreateGuid();
    //     String ref_No = getReferenceNo();

    //     payload.put('access_key', merRecord.Access_Key__c);
    //     payload.put('profile_id', merRecord.Profile_Id__c);
    //     payload.put('transaction_uuid', trans_Guid);
    //     payload.put('bill_to_forename', conRecord.FirstName);
    //     payload.put('bill_to_surname', conRecord.LastName);
    //     payload.put('bill_to_address_line1', conRecord.MailingStreet);
    //     payload.put('bill_to_address_city', conRecord.MailingCity);
    //     payload.put('bill_to_address_state', conRecord.MailingState);
    //     payload.put('bill_to_address_postal_code', conRecord.MailingPostalCode);
    //     payload.put('bill_to_address_country', conRecord.MailingCountry);
    //     payload.put('bill_to_email', conRecord.Email);
    //     payload.put('bill_to_phone', conRecord.Phone);
    //     payload.put('signed_field_names', 'access_key,profile_id,transaction_uuid,bill_to_forename,bill_to_surname,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_postal_code,bill_to_address_country,bill_to_email,bill_to_phone,signed_field_names,unsigned_field_names,signed_date_time,locale,merchant_defined_data1,transaction_type,reference_number,amount,currency');
    //     payload.put('unsigned_field_names', '');
    //     payload.put('signed_date_time', signedDate);
    //     payload.put('locale', 'en');
    //     //payload.put('payment_token', 'Axj//wSTe2blB1IESzb+ABsQ3YMmjdkwYp77xXnXoAp77xXnXppAqvDPWGTSTL0YremjwwJyb2zcoOpAiWbfwAAAxhSn');
    //     payload.put('merchant_defined_data1', caseId);
    //     payload.put('transaction_type', tranType);
    //     payload.put('reference_number', ref_No);
    //     payload.put('amount', amt);
    //     payload.put('currency', 'USD');
        
    //     cyberWrapper.trans_Guid = trans_Guid;
    //     cyberWrapper.merchantRecord = merRecord;
    //     cyberWrapper.signedDate = signedDate;
    //     cyberWrapper.ref_No = ref_No;
    //     cyberWrapper.eSignature = getCreateSignature(payload, merRecord.Secret_Key__c);
    //     return cyberWrapper;
    // }

    // public static String getCreateGuid() {

    //     Blob b = Crypto.GenerateAESKey(128);
    //     String h = EncodingUtil.ConvertTohex(b);
    //     String guid = h.SubString(0,13);
    //     system.debug(guid);
    //     return guid;
    // }

    // public static String getReferenceNo() {

    //     String b = String.valueOf(Math.abs(Crypto.getRandomLong()));
    //     String h = String.valueOf(Math.abs(Crypto.getRandomInteger()));
    //     String refrenceNo = b.SubString(0,6)+'-'+h.SubString(0,6)+'-'+b.SubString(7, 9);
    //     return refrenceNo;
    // }

    // public static string getCreateSignature(Map<String, String> payloadMap, String secretkey) {

    //     List<String> payLoadList = new List<String>();
    //     for(String key : payloadMap.keySet()) {
    //         payLoadList.add(key+'='+payloadMap.get(key));
    //     }
    //     System.debug(string.join(payLoadList,','));

    //     String salt = string.join(payLoadList,',');
    //     String key = secretkey;
    //     Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(key));
    //     System.debug('data:::'+EncodingUtil.Base64Encode(data));
    //     return EncodingUtil.Base64Encode(data);
    // }
    
    
    /*
    *   Created By      : Lucas Soderstrom
    *   Added on        : 21 Aug 2023
    *   Purpose         : Method to generate information to send to cybersource
    *   User Story      : SCS-159
    *   Input Param     : 1) caseId       - Id of case record, passed from LWC
    */
    // @AuraEnabled(cacheable=true)
    // public static void generateCybersourceInfo(String caseId){
    //     list <Payment__c> contactPayments = new list <Payment__c>(); 
    //     list <Case> currentCase = [Select ContactId FROM Case WHERE Id = :caseId];
        
    //     contactPayments = [Select Cybersource_Token__c FROM Payment__c WHERE Contact__c = :currentCase[0].ContactId
    //                        ORDER BY CreatedDate desc];
        
    //     for (Case cs : [Select Id, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, Contact.MailingCity, 
    //                                    Contact.MailingState, Contact.MailingPostalCode, ContactId, CaseNumber,
    //                                    Contact.MailingCountry, Contact.MailingStreet FROM Case WHERE Id = :caseId]){ 
                                           
    //                                        JSONGenerator jsonGen = JSON.createGenerator(true);
    //                                        jsonGen.writeStartObject();
    //                                        jsonGen.writeStringField('merchant_defined_data1','create_payment_token'); // Billing contact's org's c$party_number
    //                                        jsonGen.writeStringField('merchant_defined_data2', UserInfo.getName()); // Agent's full name
    //                                        jsonGen.writeStringField('merchant_defined_data5', cs.ContactId); // Billing Contact ID
    //                                        jsonGen.writeStringField('merchant_defined_data6', cs.Id); // Incident/Event ID
    //                                        jsonGen.writeStringField('merchant_defined_data7','create_payment_token'); // Agent Account ID
    //                                        jsonGen.writeStringField('merchant_defined_data8','create_payment_token'); // Submitter Contact ID
    //                                        jsonGen.writeStringField('merchant_defined_data9','wfgpelchi'); // Merchant ID (from Finance.Merchant.MerchantID)
    //                                        // profile ID: 2D3E9FCA-0C36-4471-AC28-F31DC510CC74
    //                                        // access key: 4c559cd2eefd32e3a82ce5cfb614e05d
    //                                        // secret key: eb8e2370b7ef4579b6813172d8472ed061ffa32c90854d1cb1324c64bd0a4457e1f808a1b6854010b2ea3b1ac8aecd09552bee0d62cf445cb198b22a83e534a2845a9958d8114d5cb8a38fb322da0b6a693e70cbcb3246a2869b7b367597cb29d0c5976c2b014a72aa08f210fbdca7cfaf7c66fa14da42eab3d1428fac4a057a
    //                                        jsonGen.writeStringField('access_key','4c559cd2eefd32e3a82ce5cfb614e05d');
    //                                        jsonGen.writeStringField('profile_id', '2D3E9FCA-0C36-4471-AC28-F31DC510CC74');
    //                                        jsonGen.writeStringField('transaction_type','create_payment_token');
    //                                        jsonGen.writeStringField('bill_to_forename', cs.Contact.FirstName);
    //                                        jsonGen.writeStringField('bill_to_surname', cs.Contact.LastName);
    //                                        jsonGen.writeStringField('bill_to_address_line1',cs.Contact.MailingStreet);
    //                                        jsonGen.writeStringField('bill_to_address_city',cs.Contact.MailingCity);
    //                                        jsonGen.writeStringField('bill_to_address_state',cs.Contact.MailingState);
    //                                        jsonGen.writeStringField('bill_to_address_postal_code',cs.Contact.MailingPostalCode);
    //                                        jsonGen.writeStringField('bill_to_address_country',cs.Contact.MailingCountry);
    //                                        jsonGen.writeStringField('bill_to_email',cs.Contact.Email);
    //                                        jsonGen.writeStringField('bill_to_phone',cs.Contact.Phone);
    //                                        jsonGen.writeStringField('locale','en-us');
    //                                        jsonGen.writeStringField('currency','USD');
    //                                        jsonGen.writeStringField('signed_date_time',JSON.serialize(system.now()));
    //                                        jsonGen.writeStringField('reference_number',cs.CaseNumber);
    //                                       // jsonGen.writeStringField('transaction_uuid',cs.ContactId + cs.Id);
                                           
                                           
    //                                        jsonGen.writeEndObject();
    //                                        String jsonData = jsonGen.getAsString();
    //                                        System.debug('Json Data - ' + jsonData);
    //                                    }
    // }   


    // public class CyberSourceJSONWrapper {

    //     @AuraEnabled public Merchant__c merchantRecord;
    //     @AuraEnabled public String trans_Guid;
    //     @AuraEnabled public String signedDate;
    //     @AuraEnabled public String ref_No;
    //     @AuraEnabled public String eSignature;
    // }
}