public class CybersourcePaymentPageController {

    public Id recordId { get; set; }
    public Id caseId { get; set; }
    public Id branchId { get; set; }
    public String trans_Guid { get; set; }
    public String ref_No { get; set; }
    public String transType { get; set; }
    public String amount { get; set; }
    public String signedDate { get; set; }
    public Contact conRecord { get; set; }
    public String paymentToken { get; set; }
    public String saveToken { get; set; }
    public Branch__c branchRecord { get; set; }
    public Merchant__c merRecord { get; set; }
    public String accessFields { get; set; }

    public Map<String, String> payload = new Map<String, String>();

    public CybersourcePaymentPageController(){

        merRecord = new Merchant__c();
        recordId = ApexPages.CurrentPage().getParameters().get('conId');
        caseId = ApexPages.CurrentPage().getParameters().get('id');
        branchId = ApexPages.CurrentPage().getParameters().get('brchId');
        paymentToken = ApexPages.CurrentPage().getParameters().get('token');
        saveToken = ApexPages.CurrentPage().getParameters().get('saveToken');
        conRecord = [Select Id, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone from Contact Where Id =: recordId];
        branchRecord = [Select Id, Merchant_Id__c from Branch__c Where Id =: branchId LIMIT 1];
        merRecord = [SELECT Id, Access_Key__c, Merchant_Id__c, Profile_Id__c, Secret_Key__c FROM Merchant__c Where Merchant_Id__c =: branchRecord.Merchant_Id__c LIMIT 1];

        transType = ApexPages.CurrentPage().getParameters().get('type');
        amount = ApexPages.CurrentPage().getParameters().get('amt');
        signedDate = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        if(transType.contains('create_payment_token')) {
            accessFields = 'access_key,profile_id,transaction_uuid,bill_to_forename,bill_to_surname,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_postal_code,bill_to_address_country,bill_to_email,bill_to_phone,signed_field_names,unsigned_field_names,signed_date_time,locale,merchant_defined_data1,merchant_defined_data2,transaction_type,reference_number,amount,currency';
        } else {
            accessFields = 'access_key,profile_id,transaction_uuid,bill_to_forename,bill_to_surname,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_postal_code,bill_to_address_country,bill_to_email,bill_to_phone,signed_field_names,unsigned_field_names,signed_date_time,locale,merchant_defined_data1,merchant_defined_data2,transaction_type,reference_number,amount,currency,payment_token';
        }    
        trans_Guid = getCreateGuid();
        ref_No = getReferenceNo();

        payload.put('access_key', merRecord.Access_Key__c);
        payload.put('profile_id', merRecord.Profile_Id__c);
        payload.put('transaction_uuid', trans_Guid);
        payload.put('bill_to_forename', conRecord.FirstName);
        payload.put('bill_to_surname', conRecord.LastName);
        payload.put('bill_to_address_line1', conRecord.MailingStreet);
        payload.put('bill_to_address_city', conRecord.MailingCity);
        payload.put('bill_to_address_state', conRecord.MailingState);
        payload.put('bill_to_address_postal_code', conRecord.MailingPostalCode);
        payload.put('bill_to_address_country', conRecord.MailingCountry);
        payload.put('bill_to_email', conRecord.Email);
        payload.put('bill_to_phone', conRecord.Phone);
        payload.put('signed_field_names', accessFields);
        payload.put('unsigned_field_names', '');
        payload.put('signed_date_time', signedDate);
        payload.put('locale', 'en');
        payload.put('merchant_defined_data1', caseId);
        payload.put('merchant_defined_data2', saveToken);
        payload.put('transaction_type', transType);
        payload.put('reference_number', ref_No);
        payload.put('amount', amount);
        payload.put('currency', 'USD');
        if(String.isNotBlank(paymentToken)) payload.put('payment_token', paymentToken);
    }
    
    public String getCreateGuid() {

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,13);
        system.debug(guid);
        return guid;
    }

    public String getReferenceNo() {

        String b = String.valueOf(Math.abs(Crypto.getRandomLong()));
        String h = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        String refrenceNo = b.SubString(0,6)+'-'+h.SubString(0,6)+'-'+b.SubString(7, 9);
        return refrenceNo;
    }

    public String getCreateSignature() {

        List<String> payLoadList = new List<String>();
        for(String key : payload.keySet()) {
            payLoadList.add(key+'='+payload.get(key));
        }
        System.debug(string.join(payLoadList,','));

        String salt = string.join(payLoadList,',');
        String key = merRecord.Secret_Key__c;
        Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(key));
        System.debug('data:::'+EncodingUtil.Base64Encode(data));
        return EncodingUtil.Base64Encode(data);
    }
}