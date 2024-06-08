@RestResource(urlMapping='/postPaymentProcess')
global class ProcessCyberSourcePaymentWebService {
    
    @HttpPost 
    global static String postPayment() {
        RestRequest reqst           	= Restcontext.request;
        system.debug('reqst '+reqst);
        Map<String, String> paramMap 	= reqst.params;
        system.debug('paramMap '+paramMap);
        String reqBody              	= JSON.serialize(paramMap);//  reqst.requestBody.toString();
        try{
            PaymentReqWrapper reqObj    = PaymentReqWrapper.parse(reqBody);
            if(reqObj.message.contains('Request was processed successfully')) {
                
                Payment__c paymentObj       = createPaymentRecord(reqObj);
                ApexDebugLog adLog 			= new ApexDebugLog();
                adLog.createLog(new ApexDebugLog.Error('ProcessCyberSourcePaymentWebService', 'postPayment', 'Request Body : '+ reqBody, 'test', 'Internal'));
                return paymentObj.Id;
            } else {
                
                ApexDebugLog adLog 			= new ApexDebugLog();
                adLog.createLog(new ApexDebugLog.Error('ProcessCyberSourcePaymentWebService', 'postPayment', 'Request Body : '+ reqBody, 'test', 'Internal'));
                return null;
            }

        } catch (Exception e) {
            ApexDebugLog adLog 			= new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProcessCyberSourcePaymentWebService', 'postPayment', e.getMessage() + '   Request Body : '+ reqBody, e.getStackTraceString(), 'Internal'));
            return e.getMessage();
        }
    }


    private static Payment__c createPaymentRecord(PaymentReqWrapper reqObj) {
        if(String.isNotBlank(reqObj.signed_date_time)) reqObj.signed_date_time = reqObj.signed_date_time.replace('T', ' ');
        Payment__c paymentObj   					= new Payment__c();
        paymentObj.Amount__c   						= reqObj.auth_amount == null ? null : Decimal.valueOf(reqObj.auth_amount);
        paymentObj.Case__c      					= reqObj.req_merchant_defined_data1;
        //paymentObj.Cybersource_Token__c				= reqObj.request_token;
        if(reqObj.req_merchant_defined_data2 == 'true') paymentObj.Cybersource_Token__c = reqObj.req_transaction_type.contains('create_payment_token') ? reqObj.payment_token : reqObj.req_payment_token;
        paymentObj.Contact__c						= reqObj.req_merchant_defined_data1 == null ? null : [Select Id, ContactId from Case where Id =: reqObj.req_merchant_defined_data1].ContactId;
        paymentObj.CyberSource_Transaction_UUID__c	= reqObj.req_transaction_uuid;
        paymentObj.Payment_Date__c					= reqObj.signed_date_time != null ? Datetime.valueOf(reqObj.signed_date_time) : null;	
        paymentObj.Payment_Type__c 					= 'Credit Card';
        paymentObj.Transaction_Type__c 				= reqObj.req_transaction_type;
        paymentObj.Status__c                        = 'Anticipated';
        insert paymentObj;
        return paymentObj;
        //        .EBS_Transaction_ID__c = reqObj.
//        .GP_Transaction_ID__c
//        .Legacy_Id__c
//        .Merchant_ID__c

    }
}