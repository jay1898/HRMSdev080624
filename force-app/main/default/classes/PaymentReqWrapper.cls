public class PaymentReqWrapper {

    public String req_card_number;	//xxxxxxxxxxxx1111
    public String req_locale;	//en-us
    public String signature;	//lYJ03/wmetKl3hYeverdqyKU5kJMi7rWa8EkiUVKijo=
    public String req_card_type_selection_indicator;	//1
    public String auth_trans_ref_no;	//X20SIKHZMZPU
    public String req_bill_to_surname;	//BAHENA
    public String payment_token;	//BAHENA
    public String req_bill_to_address_city;	//Chicago
    public String req_card_expiry_date;	//04-2029
    public String req_bill_to_address_postal_code;	//60634-2545
    public String card_type_name;	//Visa
    public String req_merchant_defined_data6;	//7878028
    public String reason_code;	//100
    public String auth_amount;	//5.00
    public String req_merchant_defined_data7;	//4971212
    public String auth_response;	//00
    public String bill_trans_ref_no;	//78460385
    public String req_bill_to_forename;	//SAMUEL
    public String req_merchant_defined_data9;	//Test wfgpelchi
    public String req_payment_method;	//card
    public String request_token;	//Axj//wSTdlfxTlDCcHjlABsQ3cNGzBm4aqI5kW6FTAVEcyLdCp6QJ+hkTDJpJl6MVvTR4YE5N2V/FOUMJweOUAAAuw6N
    public String auth_time;	//2023-07-28T105841Z
    public String req_amount;	//5.00
    public String req_bill_to_email;	//sambahena@hotmail.com.invalid.invalid.invalid
    public String auth_avs_code_raw;	//Y
    public String transaction_id;	//6905419215826825804005
    public String req_currency;	//USD
    public String req_card_type;	//001
    public String decision;	//ACCEPT
    public String req_allow_payment_token_update;	//true
    public String req_merchant_defined_data1;	//1007052593
    public String req_merchant_defined_data2;	//PDSN SC
    public String message;	//Request was processed successfully.
    public String signed_field_names;	//transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_currency,req_locale,req_payment_method,req_payment_token,req_allow_payment_token_update,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_card_number,req_card_type,req_card_type_selection_indicator,req_card_expiry_date,card_type_name,req_merchant_defined_data1,req_merchant_defined_data2,req_merchant_defined_data5,req_merchant_defined_data6,req_merchant_defined_data7,req_merchant_defined_data9,message,reason_code,auth_avs_code,auth_avs_code_raw,auth_response,auth_amount,auth_code,auth_trans_ref_no,auth_time,request_token,bill_trans_ref_no,signed_field_names,signed_date_time
    public String req_transaction_uuid;	//5a22971a0bbbfe9db577113f11.64c39f5d06a303.87682375
    public String req_merchant_defined_data5;	//2690973
    public String auth_avs_code;	//Y
    public String auth_code;	//831000
    public String req_bill_to_address_country;	//US
    public String req_transaction_type;	//sale,update_payment_token
    public String req_access_key;	//4ffe806049273f8d8aaf8b7aaada9ffc
    public String req_profile_id;	//CB18A1B2-8DB8-4B50-AC07-E817FA9F7D0B
    public String req_reference_number;	//230725-000009-12
    public String req_bill_to_address_state;	//IL
    public String signed_date_time;	//2023-07-28T10:58:41Z
    public String req_payment_token;	//6905400559146735704004
    public String req_bill_to_address_line1;	//6134 W Byron St

    public static PaymentReqWrapper parse(String json){
        return (PaymentReqWrapper) System.JSON.deserialize(json, PaymentReqWrapper.class);
    }
}