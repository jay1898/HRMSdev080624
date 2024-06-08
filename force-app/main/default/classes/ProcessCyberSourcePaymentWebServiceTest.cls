@isTest
public class ProcessCyberSourcePaymentWebServiceTest {

    @TestSetup
    static void makeData(){
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        accountObj.BillingPostalCode    = '12345'; 
        insert accountObj;
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.MailingPostalCode    = '12345';
        insert contactObj;
        Case caseObj        			= new Case();
        caseObj.Status      			= 'Pending';
        caseObj.Origin      			= 'Email';
        caseObj.ContactId   			= contactObj.Id;
        CaseObj.Business_Segment__c 	= 'Trade';
        insert caseObj;
    }
    
    @isTest
    static void testPaymentCreation() {
        
        RestRequest req     = new RestRequest();
        RestResponse res = new RestResponse();      
        req.requestURI      = '/services/apexrest/postPaymentProcess';  //Request URL
        req.httpMethod      = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        String param        = '{"req_card_number":"xxxxxxxxxxxx1111","req_locale":"en-us","signature":"lYJ03wmetKl3hYeverdqyKU5kJMi7rWa8EkiUVKijo=","req_card_type_selection_indicator":"1","auth_trans_ref_no":"X20SIKHZMZPU","req_bill_to_surname":"BAHENA","req_bill_to_address_city":"Chicago","req_card_expiry_date":"04-2029","req_bill_to_address_postal_code":"60634-2545","card_type_name":"Visa","req_merchant_defined_data6":"7878028","reason_code":"100","auth_amount":"5.00","req_merchant_defined_data7":"4971212","auth_response":"00","bill_trans_ref_no":"78460385","req_bill_to_forename":"SAMUEL","req_merchant_defined_data9":"Test wfgpelchi","req_payment_method":"card","request_token":"AxjwSTdlfxTlDCcHjlABsQ3cNGzBm4aqI5kW6FTAVEcyLdCp6QJ+hkTDJpJl6MVvTR4YE5N2VFOUMJweOUAAAuw6N","auth_time":"2023-07-28T105841Z","req_amount":"5.00","req_bill_to_email":"sambahena@hotmail.com.invalid.invalid.invalid","auth_avs_code_raw":"Y","transaction_id":"6905419215826825804005","req_currency":"USD","req_card_type":"001","decision":"ACCEPT","req_allow_payment_token_update":"true","req_merchant_defined_data1":"1007052593","req_merchant_defined_data2":"PDSN SC","message":"Request was processed successfully.","signed_field_names":"transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_currency,req_locale,req_payment_method,req_payment_token,req_allow_payment_token_update,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_card_number,req_card_type,req_card_type_selection_indicator,req_card_expiry_date,card_type_name,req_merchant_defined_data1,req_merchant_defined_data2,req_merchant_defined_data5,req_merchant_defined_data6,req_merchant_defined_data7,req_merchant_defined_data9,message,reason_code,auth_avs_code,auth_avs_code_raw,auth_response,auth_amount,auth_code,auth_trans_ref_no,auth_time,request_token,bill_trans_ref_no,signed_field_names,signed_date_time","req_transaction_uuid":"5a22971a0bbbfe9db577113f11.64c39f5d06a303.87682375","req_merchant_defined_data5":"2690973","auth_avs_code":"Y","auth_code":"831000","req_bill_to_address_country":"US","req_transaction_type":"sale,update_payment_token","req_access_key":"4ffe806049273f8d8aaf8b7aaada9ffc","req_profile_id":"CB18A1B2-8DB8-4B50-AC07-E817FA9F7D0B","req_reference_number":"230725-000009-12","req_bill_to_address_state":"IL","signed_date_time":"2023-07-28T10:58:41Z","req_payment_token":"6905400559146735704004","req_bill_to_address_line1":"6134 W Byron St"}';
        req.addHeader('params', param); 
        req.requestBody     = Blob.valueof(param);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            ProcessCyberSourcePaymentWebService.postPayment();
        Test.stopTest();
    }
}