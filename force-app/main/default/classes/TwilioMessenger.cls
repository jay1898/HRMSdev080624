/**
 * Twilio Messaging API interface class
 * 
 * Example usage for sending an SMS message:
 * ```
 * String customerNumber = '+15551234568';
 * String body = 'Hello from Pella!';
 * String topic = 'Survey';
 * Id parentId = ParentObject.Id;
 * 
 * try {
 *      // Note: the second parameter of sendSms() can take a Twilio phone number instead
 *      TwilioMessenger.sendSms(customerNumber, body, topic, parentId);
 * catch (CalloutException apiError) {
 *      System.debug("Message send failed due to API error");
 * }
 * ```
 */

public with sharing class TwilioMessenger {

    static final Integer PHONE_LENGTH_NO_COUNTRY_CODE = 10;
    static final Integer PHONE_LENGTH_COUNTRY_CODE = 11;
    static final Integer SUCCESS_STATUS_MIN = 200;
    static final Integer SUCCESS_STATUS_MAX = 299;

    /**
     * Parameters for sendLightningMessage
     * @param toNum the customer's phone number (not necessarily E.164 formatted)
     * @param message the message body
     * @param topic the message topic - determines what Twilio number will be used
     * @param strId the parent record's ID (as a string)
     */
    public class SendLightningMessageParams {
        public String toNum;
        public String message;
        public String topic;
        public String strId;
    }

    /**
     * Parameters for sendSms
     * @param toNum the customer's phone number
     * @param message the message body
     * @param topic the message topic - determines what Twilio number will be used
     * @param recordId the parent record's ID (as an Id Object)
     */
    public class SendSmsParams {
        public String toNum;
        public String message;
        public String topic;
        public Id recordId;
        public Id branchId;
    }

    /**
     * Parameters for sendFormattedSms
     * @param formattedNum the E.164 formatted number
     * @param fromId the sender phone number or Twilio Messaging service ID
     * @param topic the message topic
     * @param recordId the parent ID
     * @param message the message body
     * @param branchId the branch Id
     */
    public class SendFormattedSmsParams {
        public String formattedNum;
        public String fromId;
        public String topic;
        public Id recordId;
        public String message;
        public Id branchId;
    }
    
    /**
     * Parameters for createMessage()
     * @param direction the direction the message is traveling (Inbound or Outbound)
     * @param topic the message topic, used to tag messages based on the channel (e.g. "Survey")
     * @param msgBody the message body
     * @param phone the recipient's phone number
     * @param recordId the parent record's ID (as an Id object)
     * @param status The status of the message (whether or not it was successful)
     * @param branchId The branch Id tied to this message (for security)
     */
    public class CreateMessageParams {
        public String direction;
        public String topic;
        public String msgBody;
        public String phone;
        public Id recordId;
        public String status;
        public Id branchId;
        public String msgStatusMessage;
        public String messageSid;
    }

    /**
     * Send a message from the Lightning Web Component shown on user contact pages
     * @param params SendLightningMessageParams
     * Notes: removed cacheable=true from @AuraEnabled decorator due to issue with insert operation
     * https://developer.salesforce.com/forums/?id=9062I000000IE4kQAG
     */
    @AuraEnabled
    public static void sendLightningMessage(String toNum, String message, String topic, String strId) {
        System.debug(LoggingLevel.DEBUG, 'String Id: ' + strId);
        Id recordId = Id.valueOf(strId);
        Id branchId = getBranchIdFromRecord(recordId);

        SendSmsParams smsParams = new SendSmsParams();
        smsParams.branchId = branchId;
        smsParams.message = message;
        smsParams.recordId = recordId;
        smsParams.toNum = toNum;
        smsParams.topic = topic;
    	TwilioMessenger.sendSms(smsParams);
    }
    
    /**
     * Send an SMS message from a number or Twilio Message Service SID to a customer
     * @param params SendSmsParams
     */
    public static void sendSms(SendSmsParams params) {
        SendFormattedSmsParams formattedParams = new SendFormattedSmsParams();
        List<String> numbersToFormat = new List<String>();
        numbersToFormat.add(params.toNum);
        formattedParams.formattedNum = formatPhoneE164(numbersToFormat).get(0);
        formattedParams.fromId = getSenderFromTopic(params.topic);
        formattedParams.message = params.message;
        formattedParams.recordId = params.recordId;
        formattedParams.topic = params.topic;
        formattedParams.branchId = params.branchId;
        String serializedParams = JSON.serialize(formattedParams);
        sendFormattedSms(serializedParams);
    }

    public static void sendNonFutureSms(SendSmsParams params) {
        SendFormattedSmsParams formattedParams = new SendFormattedSmsParams();
        List<String> numbersToFormat = new List<String>();
        numbersToFormat.add(params.toNum);
        formattedParams.formattedNum = formatPhoneE164(numbersToFormat).get(0);
        formattedParams.fromId = getSenderFromTopic(params.topic);
        formattedParams.message = params.message;
        formattedParams.recordId = params.recordId;
        formattedParams.topic = params.topic;
        formattedParams.branchId = params.branchId;
        String serializedParams = JSON.serialize(formattedParams);
        sendNonFutureFormattedSms(serializedParams);
    }

    /**
     * Send a formatted Message from a number to a customer, recording meta-data in the process
     * @param formattedNum the customer's phone number, assumed to be in the correct format
     * @param fromId the Id of the Twilio Message Service (or phone number) to use to send this SMS
     * @param topic the message topic - to be recorded when message is created
     * @param recordId the parent record's ID (as an Id Object)
     * @param message the message body
     * @param branchId The branch identifier that this message belongs to (for security purposes)
     */
    @future(callout=true)
    public static void sendFormattedSms(String serializedParams) {
        SendFormattedSmsParams params = (SendFormattedSmsParams) JSON.deserialize(serializedParams, SendFormattedSmsParams.class);
        
        CreateMessageParams createParams = new CreateMessageParams();
        createParams.topic = params.topic;
        createParams.phone = params.formattedNum;
        createParams.recordId = params.recordId;
        createParams.msgBody = params.message;
        createParams.direction = 'Outbound';
        createParams.branchId = params.branchId;

        try {
            HttpResponse response = sendHttpRequest(params.formattedNum, params.fromId, params.message);
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            createParams.messageSid = (String) responseBody.get('sid');
            createParams.status = 'Success';
        } catch(CalloutException e) {
            createParams.msgStatusMessage = e.getMessage();
            createParams.status = 'Failure';
        }

        createMessage(createParams);
    }

    public static void sendNonFutureFormattedSms(String serializedParams) {
        SendFormattedSmsParams params = (SendFormattedSmsParams) JSON.deserialize(serializedParams, SendFormattedSmsParams.class);
        CreateMessageParams createParams = new CreateMessageParams();
        createParams.topic = params.topic;
        createParams.phone = params.formattedNum;
        createParams.recordId = params.recordId;
        createParams.msgBody = params.message;
        createParams.direction = 'Outbound';
        createParams.branchId = params.branchId;

        try {
            HttpResponse response = sendHttpRequest(params.formattedNum, params.fromId, params.message);
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            createParams.messageSid = (String) responseBody.get('sid');
            createParams.status = 'Success';
        } catch(CalloutException e) {
            createParams.msgStatusMessage = e.getMessage();
            createParams.status = 'Failure';
        }

        createMessage(createParams);
    }
    /**
     * This function inserts a Twiliomessage__c object based on a sent or received message
     * @param params CreateMessageParams
     */
    public static void createMessage(CreateMessageParams params) {
        System.debug('msgBody: ' + params.msgBody);
        if (TwilioMessage__c.SobjectType.getDescribe().isAccessible() &&
                TwilioMessage__c.SobjectType.getDescribe().isCreateable()) {
            TwilioMessage__c msg = new TwilioMessage__c();
            String formattedName = '{0} ({1}): {2}';
            List<String> formattedNameParams = new List<String>();
            formattedNameParams.add(params.direction);
            formattedNameParams.add(params.phone);
            formattedNameParams.add(params.topic);
            
            msg.Name = String.format(formattedName, formattedNameParams);
            msg.Topic__c = params.topic;	
            msg.MessageBody__c = params.msgBody;
            msg.Phone__c = params.phone;
            msg.Direction__c = params.direction;
            msg.Status__c = params.status;
            msg.Branch__c = params.branchId;
            msg.Status_Message__c = params.msgStatusMessage;
            msg.messageSid__c = params.messageSid;

            String branchStrId = (String) params.branchId;
            msg.Branch_Name__c = [SELECT Name from Branch__c where Id = :branchStrId LIMIT 1].Name;

            if (params.recordId != null) {
                String objectType = params.recordId.getSobjectType().getDescribe().getName();
                msg.ParentID__c = String.valueOf(params.recordId);

                // For Related Objects
                switch on objectType {
                    when 'ServiceAppointment' {
                        msg.Appointment__c = params.recordId;
                    }
                    when 'Opportunity' {
                        msg.Opportunity__c = params.recordId;
                    }
                    when else {
                        System.debug('Object Type ' + objectType + ' not related.');
                    }
                }
            }
            insert msg;
        } else {
            System.debug(LoggingLevel.ERROR, 'Error: Unable to create new Twilio Message - User is not authorized');            
        }
    }

    /**
     * Get the last sent message to a user by phone number and message topic
     * @param phoneNumber the recipient's phone number
     * @param topic the message topic
     */
    public static TwilioMessage__c getLastOutboundMessage(String phoneNumber, String topic) {
        List<String> numbersToFormat = new List<String>();
        numbersToFormat.add(phoneNumber);
        String formattedPhoneNumber = TwilioMessenger.formatPhoneE164(numbersToFormat).get(0);
        return [SELECT ParentID__c, Branch__c FROM TwilioMessage__c WHERE Phone__c = :formattedPhoneNumber AND Topic__c = :topic AND Direction__c = 'Outbound' ORDER BY CreatedDate DESC LIMIT 1];
    }

    /**
     * Query TwilioMessage__c records by phone number, topic, and parent ID
     * @param phoneNumber the recipient's phone number
     * @param topic the message topic
     * @param parentId the parent record's ID
     */
    public static List<TwilioMessage__c> queryMessages(String phoneNumber, String topic, String parentId) {
        List<String> numbersToFormat = new List<String>();
        numbersToFormat.add(phoneNumber);
        String formattedPhoneNumber = TwilioMessenger.formatPhoneE164(numbersToFormat).get(0);
        return [SELECT Name, MessageBody__c  FROM TwilioMessage__c WHERE Topic__c = :topic AND ParentID__c = :parentId AND Phone__c = :formattedPhoneNumber ORDER BY CreatedDate DESC];
    }
    
    /**
     * Get the phone number or Twilio Message Service SID from a topic
     * The topics are configured in the TwilioConfigurations metadata type
     * @param topic the topic
     */
    public static String getSenderFromTopic(String topic) {
        try {
            return [SELECT Phone__c FROM TwilioSetup__mdt WHERE QualifiedAPIName = :topic LIMIT 1].Phone__c;
        }
        catch (Exception error) {
            System.debug(LoggingLevel.ERROR, 'No sender found for topic: ' + topic);
            throw error;
        }
    }

    /**
     * Get the topic from a phone number Twilio Message Service SID
     * The phone numbers are configured in the TwilioConfigurations metadata type
     * @param sender the phone number or Message Service SID
     */
    public static String getTopicFromSender(String sender) {
        try {
            return [SELECT QualifiedAPIName FROM TwilioSetup__mdt WHERE Phone__c = :sender LIMIT 1].QualifiedAPIName;
        }
        catch (Exception error) {
            System.debug(LoggingLevel.ERROR, 'No topic found for sender: ' + sender);
            throw error;
        }
    }

    /**
     * Format a US phone number as E.164 format for Twilio API
     * For example: (555) 123-4567 becomes +15551234567
     * Phone number must be 10/11 digits
     * @param phoneNumber the phone number to reformat
     */
    @InvocableMethod(label='Twilio Format Phone' description='Format Phone to E.164 Format' category='Twilio')
    public static List<String> formatPhoneE164(List<String> phoneNumbers) {      
        List<String> formattedPhoneNumbers = new List<String>();  
        for(String phoneNumber : phoneNumbers) {
            // remove all non numeric
            String formattedPhoneNumber = phoneNumber.replaceAll('[^0-9]', '');

            // 10 digit: reformat +1 appended
            if (formattedPhoneNumber.length() == TwilioMessenger.PHONE_LENGTH_NO_COUNTRY_CODE) {
                formattedPhoneNumbers.add('+1' + formattedPhoneNumber);
                continue;
            }
            else if (formattedPhoneNumber.length() == TwilioMessenger.PHONE_LENGTH_COUNTRY_CODE) {
                formattedPhoneNumbers.add('+' + formattedPhoneNumber);
                continue;
            }
            else {
                throw new IllegalArgumentException('Phone number had invalid length - only 10/11-digit numbers are accepted, got: ' + phoneNumber);
            }
        }
        return formattedPhoneNumbers;
    }
    
    private static Id getBranchIdFromRecord(Id recordId) {
        String recordType = recordId.getSobjectType().getDescribe().getName();
        String strId = (String) recordId;
        String branchNumber = null;
        switch on recordType {
            when 'User' {
                if (User.SObjectType.getDescribe().isAccessible()) {
                    User userObject = [SELECT Trade_Branch_Number__c from User where Id = :strId LIMIT 1];
                    branchNumber = userObject.Trade_Branch_Number__c;    
                    System.debug('USER BRANCH NUMBER: ' + branchNumber);
                }
                else {
                    NoAccessException e = new NoAccessException();
                    e.setMessage('User Object is not accessible for this context');
                    throw e;
                }
            }
            when 'ServiceAppointment' {
                if (ServiceAppointment.SObjectType.getDescribe().isAccessible()) {
                    ServiceAppointment svcApptObj = [SELECT Branch_Number__c from ServiceAppointment where Id = :strId LIMIT 1];
                    branchNumber = svcApptObj.Branch_Number__c;
                }
                else {
                    NoAccessException e = new NoAccessException();
                    e.setMessage('ServiceAppointment Object is not accessible for this context');
                    throw e;    
                }        
            }
            when 'Opportunity' {
                if (Opportunity.SObjectType.getDescribe().isAccessible()) {
                    Opportunity opportunityObj = [SELECT Branch_Number__c from Opportunity where Id = :strId LIMIT 1];
                    branchNumber = opportunityObj.Branch_Number__c;
                }   
                else {
                    NoAccessException e = new NoAccessException();
                    e.setMessage('Opportunity Object is not accessible for this context');
                    throw e;  
                }
            }
            when 'Contact' {
                if (Contact.SObjectType.getDescribe().isAccessible()) {
                    Contact contactObj = [SELECT Account.Branch_Number__c from Contact where Id = :strId LIMIT 1];
                    branchNumber = contactObj.Account.Branch_Number__c;
                }
                else {
                    NoAccessException e = new NoAccessException();
                    e.setMessage('Contact Object is not accessible for this context');
                    throw e;  
                }
            }
            when 'Account' {
                if (Account.SOBjectType.getDescribe().isAccessible()) {
                    Account accountObj = [SELECT Branch_Number__c from Account where Id = :strId LIMIT 1];
                    branchNumber = accountObj.Branch_Number__c;
                } else {
                    NoAccessException e = new NoAccessException();
                    e.setMessage('Account Object is not accessible for this context');
                    throw e;
                }
            }
            when else {
                System.debug('Record type ' + recordType + ' not supported for branch identification');
                return null;
            }
        }
        return [SELECT Id, Name from Branch__c where Branch_Number__c = :branchNumber LIMIT 1].Id;
    }
    /**
     * Internal method to call the Twilio Messages API
     */
    private static HttpResponse sendHttpRequest(String toNum, String fromId, String message) {
        
        List<Endpoint_Configuration__mdt> twillioCallbackMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Twilio_Message_Status_Callback' ]; 
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:TwilioAccount/Messages.json');
        request.setMethod('POST');
       	request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String payloadFormat = 'From={0}&Body={1}&To={2}';
        List<String> params = new List<String>();

        params.add(EncodingUtil.urlEncode(fromId,'UTF-8'));
        params.add(EncodingUtil.urlEncode(message,'UTF-8'));
        params.add(EncodingUtil.urlEncode(toNum,'UTF-8'));
        if(twillioCallbackMetaData.size()>0){
            payloadFormat += '&StatusCallback={3}';
            params.add(EncodingUtil.urlEncode(twillioCallbackMetaData[0].Endpoint__c,'UTF-8'));
        }

        request.setBody(String.format(payloadFormat, params));

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        Integer responseCode = response.getStatusCode();
        System.debug('Response: ' + responseCode);
        if (TwilioHttpStatus.SUCCESS_RANGE_MIN <= responseCode && responseCode <= TwilioHttpStatus.SUCCESS_RANGE_MAX) {
            System.debug('Sent Message: ' + response.getBody());
        } else {
            String formatString = 'Error sending request. (Status Code: {0} Message: {1})';
            List<String> errorParams = new List<String>();
            errorParams.add(String.valueOf(responseCode));
            errorParams.add(response.getStatus());
            throw new CalloutException(String.format(formatString, errorParams));
        }
        return response;
    }
}