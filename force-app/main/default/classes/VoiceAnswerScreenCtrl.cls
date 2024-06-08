/*
Created By      : Rahul Sangwan
Created Date    : 10 January 2024
Purpose         : This is Controller for Voice Screen page.
----------------------------------------------------------------------------------------------
Modified By     : Rahul Sangwan
Modified Date.  : 12 April 2024
Purpose         : Updated Order no search functionality.
----------------------------------------------------------------------------------------------
*/
public without sharing class VoiceAnswerScreenCtrl {

    static List<Id> contactAccountIdList;

    /*
    *   Created By      : Rahul Sangwan
    *   Purpose         : Method to be called on onload of Voice Answer screen to get Customer based on Mobile number called from.
    *   Input Param     : Phone No.
    *   Output Param    : VoiceAnswerScreenWrapper
    */
    @AuraEnabled
    public static VoiceAnswerScreenWrapper getCustomerDetailsBasedOnPhone(String phoneNo) {
        VoiceAnswerScreenWrapper respObj                            = new VoiceAnswerScreenWrapper();
        List<VoiceAnswerScreenWrapper.CustDetails> custDetailList   = new List<VoiceAnswerScreenWrapper.CustDetails>();
        for(Account accObj : [SELECT Id, Name, Phone, PersonEmail, PersonMailingStreet, PersonMailingCity, PersonMailingState , PersonMailingPostalCode 
                              FROM Account 
                              WHERE IsPersonAccount = true 
                              AND (Phone_Idx__c =: phoneNo OR Home_Phone_Idx__c =: phoneNo OR Mobile_Idx__c =: phoneNo OR Asst_Phone_Idx__c =: phoneNo OR Other_Phone_Idx__c =: phoneNo)]) {
            custDetailList.add(new VoiceAnswerScreenWrapper.CustDetails(accObj.Id, accObj.Name, accObj.Phone, accObj.PersonEmail, accObj.PersonMailingStreet, accObj.PersonMailingCity, accObj.PersonMailingState, accObj.PersonMailingPostalCode, accObj.Id, accObj.Name));
        }

        for(Contact contactObj : [SELECT Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, AccountId, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode FROM Contact WHERE Account.IsPersonAccount = false AND Active_SERVICE__c = true AND (Phone_Idx__c =: phoneNo OR Home_Phone_Idx__c =: phoneNo OR Mobile_Idx__c =: phoneNo OR Asst_Phone_Idx__c =: phoneNo OR Other_Phone_Idx__c =: phoneNo OR Account.Phone_Idx__c =: phoneNo)]) {
            Boolean shippingAddress = String.isNotBlank(contactObj.Account.ShippingStreet) || String.isNotBlank(contactObj.Account.ShippingCity) || String.isNotBlank(contactObj.Account.ShippingState) || String.isNotBlank(contactObj.Account.ShippingPostalCode);
            String streetVal = shippingAddress == false ? contactObj.Account.BillingStreet : contactObj.Account.ShippingStreet;
            String cityVal = shippingAddress == false ? contactObj.Account.BillingCity : contactObj.Account.ShippingCity;
            String stateVal = shippingAddress == false ? contactObj.Account.BillingState : contactObj.Account.ShippingState;
            String postalCodeVal = shippingAddress == false ? contactObj.Account.BillingPostalCode : contactObj.Account.ShippingPostalCode;
            custDetailList.add(new VoiceAnswerScreenWrapper.CustDetails(contactObj.Id, contactObj.Name, contactObj.Phone, contactObj.Email, streetVal, cityVal, stateVal, postalCodeVal, contactObj.Account.Id, contactObj.Account.Name));
        } 
        
        if(custDetailList.size() > CXOneOAuthCtrl.creds.Max_Search_Records__c) throw new TooManyRecordsException(System.Label.CXOne_Max_Rec_Error_Msg);
        custDetailList.sort();
        respObj.custDetailsList         = custDetailList;
        respObj.isCaseNoSearch          = false;
        respObj.caseNo                  = null;
        respObj.maxCaseRecordsCrossed   = false;
        return respObj;
    }


    /*
    *   Created By      : Rahul Sangwan
    *   Purpose         : Method to be called when user is going to select any Customer from search results.
    *   Input Param     : String customerId, String caseNo, String poNo, String qoNo, String orderNo
    *   Output Param    : VoiceAnswerScreenWrapper
    */
    @AuraEnabled
    public static VoiceAnswerScreenWrapper getDetailsRelatedToCustomer(String customerId, String caseNo, String poNo, String qoNo, String orderNo) {
        String parentAccountId              = null;
        Integer maxRecLimit                 = 100;
        Integer queryRecords                = maxRecLimit + 1;
        try{
            Contact contactObj              = [Select Id, AccountId, IsPersonAccount from Contact where Id =: customerId LIMIT 1];
            if(contactObj.IsPersonAccount != true && contactObj.AccountId != null){
                customerId     = contactObj.AccountId;
            }
            parentAccountId                 = contactObj.AccountId;
        } catch(Exception e) {}
        VoiceAnswerScreenWrapper respObj    = new VoiceAnswerScreenWrapper();
        List<Case> caseList                 = new List<Case>();  
        if(String.isNotBlank(caseNo) || String.isNotBlank(poNo) || String.isNotBlank(qoNo) || String.isNotBlank(orderNo)) {
            String poNoOperator =  String.isNotBlank(poNo) && poNo.contains('%') ? 'LIKE' : '=:';
            String quoteNoOperator = String.isNotBlank(qoNo) && qoNo.contains('%') ? 'LIKE' : '=:';
            String orderNoOperator  = String.isNotBlank(orderNo) && orderNo.contains('%') ? 'LIKE' : '=:';
            String caseQuery        = 'SELECT Id, CaseNumber, Status, Subject, CreatedDate, Owner.Name, LastModifiedDate, IsClosed, IsEscalated, Escalation_Image__c, Assigned_Queue__c FROM Case WHERE AccountId != null AND (AccountId =: customerId OR ContactId =: customerId OR AccountId =: parentAccountId OR Contact.AccountId =: parentAccountId)';
            if(String.isNotBlank(caseNo)) {
                caseQuery          += ' AND CaseNumber =: caseNo';
            }
            if(String.isNotBlank(poNo)) {
                caseQuery          += ' AND Purchase_Order__c ' + poNoOperator + ' poNo';
            }
            if(String.isNotBlank(qoNo)) {
                caseQuery          += ' AND Quote_Number__c ' + quoteNoOperator + ' qoNo';
            }
            if(String.isNotBlank(orderNo)) {
                caseQuery          += ' AND Order_Number__c ' + orderNoOperator + ' orderNo';
            }
            caseQuery              += ' ORDER BY IsClosed ASC, Is_Escalated__c DESC, LastModifiedDate DESC LIMIT: queryRecords';
            caseList                = Database.query(caseQuery);
        } else {
            caseList                        = [SELECT Id, CaseNumber, Status, Subject, CreatedDate, Owner.Name, LastModifiedDate, IsClosed, IsEscalated, Escalation_Image__c, Assigned_Queue__c FROM Case 
                                               wHERE AccountId != null AND (AccountId =: customerId OR ContactId =: customerId OR AccountId =: parentAccountId) ORDER BY IsClosed ASC, Is_Escalated__c DESC, LastModifiedDate DESC LIMIT: queryRecords];
        }
        if(caseList.size() > maxRecLimit) {
            caseList.remove(maxRecLimit);
            respObj.maxCaseRecordsCrossed   = true;
        } else {
            respObj.maxCaseRecordsCrossed   = false;
        }                                     
        respObj.caseList                    = caseList;      
        respObj.addressList                 = getRelatedAddresses(customerId, parentAccountId);       
        return respObj;      
    }


    /*
    *   Created By      : Rahul Sangwan
    *   Purpose         : Method to get Related Address to the customer.
    *   Input Param     : String customerId, String parentAccountId.
    *   Output Param    : List of Address Assignment.
    */
    private static List<Address_Assignment__c> getRelatedAddresses(String customerId, String parentAccountId) {
        Boolean isPersonAccount                     = true;
        if(parentAccountId != null) isPersonAccount = [SELECT Id, IsPersonAccount FROM Account WHERE Id =: parentAccountId OR Id =: customerId LIMIT 1].IsPersonAccount;
        List<Address_Assignment__c> addressList     = new List<Address_Assignment__c>();
        if(isPersonAccount) {
        //Address_Street__c, Address_City__c, Address_State__c, Address_Zip__c,
            for(Account_Branch_Profile__c branchProObj : [SELECT Id, (SELECT Id, Address_Usage_Type__c,  Account_Branch_Profile__r.Branch__r.Name, Primary_Flag__c, Identifying_Address__c FROM Address_Assignments__r) FROM Account_Branch_Profile__c WHERE (Party_Account__c =: customerId OR Party_Account__c=: parentAccountId) AND Party_Account__c != null]) {
                for(Address_Assignment__c addressObj : branchProObj.Address_Assignments__r) {
                    addressList.add(addressObj);
                }
            }
        } else {
        //Address_Street__c, Address_City__c, Address_State__c, Address_Zip__c,
            for(Address_Assignment__c addressObj : [SELECT Id, Address_Usage_Type__c,  Account__r.isPersonAccount, Account__r.Name, Account_Branch_Profile__r.Branch__r.Name, Primary_Flag__c, Identifying_Address__c FROM Address_Assignment__c WHERE Account__c != null AND (Account__c =: customerId OR Account__c =: parentAccountId)]) {
                addressList.add(addressObj);
            }
        }
        return addressList;
    }


    /*
    *   Created By      : Rahul Sangwan
    *   Purpose         : Method to be called on click of Search button.
    *   Input Param     : String firstName, String lastName, String accountName, String phoneNo, String emailId, String street, String city, String state, String zipCode, String caseNo, String poNo, String quoteNo, String orderNo.
    *   Output Param    : VoiceAnswerScreenWrapper
    */
    @AuraEnabled
    public static VoiceAnswerScreenWrapper getContactFromSearch(String firstName, String lastName, String accountName, String phoneNo, String emailId, String street, String city, String state, String zipCode, String caseNo, String poNo, String quoteNo, String orderNo) {
        List<Id> accountIdList = new List<Id>();
        List<Id> conAccIdList = new List<Id>();
        List<Id> b2cAccountIdList = new List<Id>();
        List<Id> b2bAccountIdList = new List<Id>();
        contactAccountIdList = new List<Id>();
        VoiceAnswerScreenWrapper voiceAnswerScreenResponse = new VoiceAnswerScreenWrapper();
        List<VoiceAnswerScreenWrapper.CustDetails> custDetailList = new List<VoiceAnswerScreenWrapper.CustDetails>();
        Boolean searchContacts, showOnlySearchContacts = false;
        if(String.isNotBlank(caseNo) && caseNo.length() != 8) {
            for(Integer i = caseNo.length(); i < 8; i++) {
                caseNo = '0' + caseNo;
            }
        }        
        String conQuery     = 'SELECT Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, OtherStreet, OtherCity, OtherState, OtherPostalCode, AccountId, Account.Name, Account.ShippingAddress, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode FROM Contact WHERE AccountId != null AND Account.IsPersonAccount = false AND Active_SERVICE__c = true';
        String conAggrQuery = 'SELECT Count(Id) totalRec FROM Contact WHERE Account.IsPersonAccount = false AND Active_SERVICE__c = true';
        String query        = 'SELECT Id, Name, Phone, PersonEmail, PersonMailingStreet, PersonMailingCity, PersonMailingState , PersonMailingPostalCode FROM Account WHERE IsPersonAccount = true';
        if(String.isNotBlank(firstName)) {
            query                  += firstName.contains('%') ? ' AND FirstName LIKE: firstName' : ' AND FirstName =: firstName';
            conQuery               += firstName.contains('%') ? ' AND FirstName LIKE: firstName' : ' AND FirstName =: firstName';
            conAggrQuery           += firstName.contains('%') ? ' AND FirstName LIKE: firstName' : ' AND FirstName =: firstName';
            searchContacts          = true;
            showOnlySearchContacts  = true;
        }
        
        if(String.isNotBlank(lastName)) {
            query                  += lastName.contains('%') ? ' AND LastName LIKE: lastName' : ' AND LastName =: lastName';
            conQuery               += lastName.contains('%') ? ' AND LastName LIKE: lastName' : ' AND LastName =: lastName';
            conAggrQuery           += lastName.contains('%') ? ' AND LastName LIKE: lastName' : ' AND LastName =: lastName';
            searchContacts          = true;
            showOnlySearchContacts  = true;
        }
        
        if(String.isNotBlank(accountName)) {
            query           += accountName.contains('%') ? ' AND Name LIKE: accountName' : ' AND Name =: accountName';
            conQuery        += accountName.contains('%') ? ' AND Account.Name LIKE: accountName' : ' AND Account.Name =: accountName';
            conAggrQuery    += accountName.contains('%') ? ' AND Account.Name LIKE: accountName' : ' AND Account.Name =: accountName';
            searchContacts   = true;
        }
        
        if(String.isNotBlank(phoneNo)) {
            String searchPattern = phoneNo;
            if(!phoneNo.contains('%')) {
                query +=  ' AND (Phone_Idx__c =: phoneNo OR Home_Phone_Idx__c =: phoneNo OR Mobile_Idx__c =: phoneNo OR Asst_Phone_Idx__c =: phoneNo OR Other_Phone_Idx__c =: phoneNo)';
               conQuery += ' AND (Phone_Idx__c =: phoneNo OR Home_Phone_Idx__c =: phoneNo OR Mobile_Idx__c =: phoneNo OR Asst_Phone_Idx__c =: phoneNo OR Other_Phone_Idx__c =: phoneNo OR Account.Phone_Idx__c =: phoneNo)';
               conAggrQuery += '  AND (Phone_Idx__c =: phoneNo OR Home_Phone_Idx__c =: phoneNo OR Mobile_Idx__c =: phoneNo OR Asst_Phone_Idx__c =: phoneNo OR Other_Phone_Idx__c =: phoneNo OR Account.Phone_Idx__c =: phoneNo)';

            }
            else{
                searchPattern = phoneNo.startsWith('%') ? phoneNo : '%-' + phoneNo; 
                searchPattern = phoneNo.endsWith('%') ? searchPattern : searchPattern + '-%';
                query += ' AND All_Account_Phones_Idx__c LIKE : searchPattern';
                conQuery += ' AND (All_Contact_Phones_Idx__c LIKE : searchPattern OR Account.Phone_Idx__c LIKE: phoneNo)';
                conAggrQuery += ' AND (All_Contact_Phones_Idx__c LIKE : searchPattern OR Account.Phone_Idx__c LIKE: phoneNo)'; 
            }
            
            searchContacts = true;
            showOnlySearchContacts = true;
        }
        
        if(String.isNotBlank(emailId)) {
            query += emailId.contains('%') ? ' AND PersonEmail like: emailId' : ' AND PersonEmail =: emailId';
            conQuery += emailId.contains('%') ? ' AND (Email like: emailId OR Account.Company_Email__c like: emailId)' : ' AND (Email =: emailId  OR Account.Company_Email__c =: emailId)';
            conAggrQuery += emailId.contains('%') ? ' AND (Email like: emailId OR Account.Company_Email__c like: emailId)' : ' AND (Email =: emailId  OR Account.Company_Email__c =: emailId)';
            searchContacts = true;
            showOnlySearchContacts = true;

        }
        
        if(String.isNotBlank(caseNo) || String.isNotBlank(poNo) || String.isNotBlank(quoteNo) || String.isNotBlank(orderNo)) {
            try {
                Boolean addAndOperator = false;
                List<Id> accountIdSet = new List<Id>();
                List<Id> contactIdSet = new List<Id>();
                String poNoOperator = '=:';
                String quoteNoOperator = '=:';
                String orderNoOperator = '=:';
                if(String.isNotBlank(poNo) && poNo.contains('%')) poNoOperator = 'like:';
                if(String.isNotBlank(quoteNo) && quoteNo.contains('%')) quoteNoOperator = 'like:';
                if(String.isNotBlank(orderNo) && orderNo.contains('%')) orderNoOperator = 'like:';

                String caseQuery        = 'SELECT Id, CaseNumber, AccountId, Account.IsPersonAccount, ContactId, Contact.AccountId, Contact.Account.IsPersonAccount FROM Case';
                if(String.isNotBlank(caseNo)) {
                    caseQuery          += ' WHERE CaseNumber =: caseNo';
                    addAndOperator      = true;
                }
                if(String.isNotBlank(poNo)) {
                    caseQuery          += addAndOperator == true ? ' AND Purchase_Order__c ' + poNoOperator + ' poNo' : ' where Purchase_Order__c ' + poNoOperator + ' poNo';
                    addAndOperator      = true;
                }
                if(String.isNotBlank(quoteNo)) {
                    caseQuery          += addAndOperator == true ? ' AND Quote_Number__c ' + quoteNoOperator + ' quoteNo' : ' where Quote_Number__c ' + quoteNoOperator + ' quoteNo';
                    addAndOperator      = true;
                }
                if(String.isNotBlank(orderNo)) {
                    caseQuery          += addAndOperator == true ? ' AND Order_Number__c ' + orderNoOperator + ' orderNo' : ' where Order_Number__c ' + orderNoOperator + ' orderNo';
                    addAndOperator      = true;
                }
                for(Case caseObj : Database.query(caseQuery)) {
                    if(caseObj.AccountId != null && caseObj.Account.IsPersonAccount == true) accountIdSet.add(caseObj.AccountId);
                    if(caseObj.ContactId != null && caseObj.Contact.Account.IsPersonAccount != true) contactIdSet.add(caseObj.ContactId);
                }
                for(Account accObj : [Select Id, Name, Phone, PersonEmail, PersonMailingStreet, PersonMailingCity, PersonMailingState , PersonMailingPostalCode from Account where Id IN: accountIdSet]) {
                    custDetailList.add(new VoiceAnswerScreenWrapper.CustDetails(accObj.Id, accObj.Name, accObj.Phone, accObj.PersonEmail, accObj.PersonMailingStreet, accObj.PersonMailingCity, accObj.PersonMailingState, accObj.PersonMailingPostalCode, accObj.Id, accObj.Name));        
                }      
                for(Contact contactObj : [Select Id, Name, Phone, Email, Account.Name, Account.ShippingStreet, Account.BillingStreet, Account.BillingCity, Account.ShippingCity, Account.BillingState, Account.ShippingState, Account.BillingPostalCode, Account.ShippingPostalCode from Contact where Id IN: contactIdSet]) {
                        Boolean shippingAddress = String.isNotBlank(contactObj.Account.ShippingStreet) || String.isNotBlank(contactObj.Account.ShippingCity) || String.isNotBlank(contactObj.Account.ShippingState) || String.isNotBlank(contactObj.Account.ShippingPostalCode);
                        String streetVal = shippingAddress == false ? contactObj.Account.BillingStreet : contactObj.Account.ShippingStreet;
                        String cityVal = shippingAddress == false ? contactObj.Account.BillingCity : contactObj.Account.ShippingCity;
                        String stateVal = shippingAddress == false ? contactObj.Account.BillingState : contactObj.Account.ShippingState;
                        String postalCodeVal = shippingAddress == false ? contactObj.Account.BillingPostalCode : contactObj.Account.ShippingPostalCode;
                        custDetailList.add(new VoiceAnswerScreenWrapper.CustDetails(contactObj.Id, contactObj.Name, contactObj.Phone, contactObj.Email, streetVal, cityVal, stateVal, postalCodeVal, contactObj.Account.Id, contactObj.Account.Name));
                }           
            } catch(Exception e) {
                System.debug('e:::'+e.getmessage());
            }
            custDetailList.sort();
            voiceAnswerScreenResponse.custDetailsList         = custDetailList;
            voiceAnswerScreenResponse.isCaseNoSearch          = true;
            if(String.isNotBlank(caseNo))
            voiceAnswerScreenResponse.caseNo                  = caseNo;
            if(String.isNotBlank(poNo))
            voiceAnswerScreenResponse.poNo                    = poNo;
            if(String.isNotBlank(quoteNo))
            voiceAnswerScreenResponse.quoteNo                 = quoteNo;
            if(String.isNotBlank(orderNo))
            voiceAnswerScreenResponse.orderNo                 = orderNo;
            voiceAnswerScreenResponse.maxCaseRecordsCrossed   = false;
            return voiceAnswerScreenResponse;
        }
        if(String.isNotBlank(street) || String.isNotBlank(city) || String.isNotBlank(state) || String.isNotBlank(zipCode)) {
            if(String.isNotBlank(firstName) || String.isNotBlank(lastName) || String.isNotBlank(accountName) || String.isNotBlank(phoneNo) || String.isNotBlank(emailId)) { 
                String lStreet = String.isBlank(street) ? street : street.remove('%');
                String lCity  = String.isBlank(city) ? city : city.remove('%');
                String lState = String.isBlank(state) ? state : state.remove('%');
                String lZipCode = String.isBlank(zipCode) ? zipCode : zipCode.remove('%');           
                for(Account accObj : Database.query(query)) {
                    accountIdList.add(accObj.Id);
                }
                for(Contact contactObj : Database.query(conQuery)) {
                    if(((String.isBlank(street) || (String.isNotBlank(street) && ((!(street.contains('%')) && (street).equalsIgnoreCase(contactObj.MailingStreet)) || (street.contains('%') && (contactObj.MailingStreet).contains(lStreet))))) &&
                        (String.isBlank(city) || (String.isNotBlank(city) && ((!(city.contains('%')) && (city).equalsIgnoreCase(contactObj.MailingCity)) || (city.contains('%') && (contactObj.MailingCity).contains(lCity))))) &&
                        (String.isBlank(state) || (String.isNotBlank(state) && ((!(state.contains('%')) && (state).equalsIgnoreCase(contactObj.MailingState)) || (state.contains('%') && (contactObj.MailingState).contains(lState))))) &&
                        (String.isBlank(zipCode) || (String.isNotBlank(zipCode) && ((!(zipCode.contains('%')) && (zipCode).equalsIgnoreCase(contactObj.MailingPostalCode)) || (zipCode.contains('%') && (contactObj.MailingPostalCode).contains(lZipCode)))))
                       )
                       ||
                       (
                        (String.isBlank(street) || (String.isNotBlank(street) && ((!(street.contains('%')) && (street).equalsIgnoreCase(contactObj.OtherStreet)) || (street.contains('%') && (contactObj.OtherStreet).contains(lStreet))))) &&
                        (String.isBlank(city) || (String.isNotBlank(city) && ((!(city.contains('%')) && (city).equalsIgnoreCase(contactObj.OtherCity)) || (city.contains('%') && (contactObj.OtherCity).contains(lCity))))) &&
                        (String.isBlank(state) || (String.isNotBlank(state) && ((!(state.contains('%')) && (state).equalsIgnoreCase(contactObj.OtherState)) || (state.contains('%') && (contactObj.OtherState).contains(lState))))) &&
                        (String.isBlank(zipCode) || (String.isNotBlank(zipCode) && ((!(zipCode.contains('%')) && (zipCode).equalsIgnoreCase(contactObj.OtherPostalCode)) || (zipCode.contains('%') && (contactObj.OtherPostalCode).contains(lZipCode)))))
                       )
                       ) {
                        contactAccountIdList.add(contactObj.AccountId);
                    } else {
                        conAccIdList.add(contactObj.AccountId);
                    }
                }
                accountIdList = getAccountsRelatedToAccounts(street, city, state, zipCode, accountIdList, conAccIdList);
            }else{
                String contactAddQuery  = 'SELECT Id, AccountId FROM Contact WHERE AccountId != null AND Account.IsPersonAccount = false AND Active_SERVICE__c = true';
                if(String.isNotBlank(street) && !(street.contains('%'))) contactAddQuery            += ' AND (MailingStreet =: street OR OtherStreet =: street)';
                if(String.isNotBlank(street) && street.contains('%')) contactAddQuery               += ' AND (MailingStreet like: street OR OtherStreet like: street)'; 
                if(String.isNotBlank(city) && !(city.contains('%'))) contactAddQuery                += ' AND (MailingCity =: city OR OtherCity =: city)';
                if(String.isNotBlank(city) && city.contains('%')) contactAddQuery                   += ' AND (MailingCity like: city OR OtherCity like: city)'; 
                if(String.isNotBlank(state) && !(state.contains('%'))) contactAddQuery              += ' AND (MailingState =: state OR OtherState =: state)';
                if(String.isNotBlank(state) && state.contains('%')) contactAddQuery                 += ' AND (MailingState like: state OR OtherState like: state)'; 
                if(String.isNotBlank(zipCode) && !(zipCode.contains('%'))) contactAddQuery          += ' AND (MailingPostalCode =: zipCode OR OtherPostalCode =: zipCode)';
                if(String.isNotBlank(zipCode) && zipCode.contains('%')) contactAddQuery             += ' AND (MailingPostalCode like: zipCode OR OtherPostalCode like: zipCode)'; 
                
                for(Contact contactObj : Database.query(contactAddQuery)) {
                    contactAccountIdList.add(contactObj.AccountId);
                }
                accountIdList           = getAccountsRelatedToAccounts(street, city, state, zipCode, null, null);
            }
            if(contactAccountIdList != null && !contactAccountIdList.isEmpty()) {
                conQuery       += ' AND AccountId IN: contactAccountIdList';
                conAggrQuery   += ' AND AccountId IN: contactAccountIdList';                
                searchContacts  = true;
            }            
            query          += ' AND Id IN: accountIdList';
        }
        for(Account accObj : Database.query(query)) {
            custDetailList.add(new VoiceAnswerScreenWrapper.CustDetails(accObj.Id, accObj.Name, accObj.Phone, accObj.PersonEmail, accObj.PersonMailingStreet, accObj.PersonMailingCity, accObj.PersonMailingState, accObj.PersonMailingPostalCode, accObj.Id, accObj.Name));
        }

        if(searchContacts == true) {
            AggregateResult[] res = Database.query(conAggrQuery);    
            if(Integer.valueOf(res[0].get('totalRec')) > 10000) throw new TooManyRecordsException(System.Label.CXOne_Max_Rec_Error_Msg);
            for(Contact contactObj : Database.query(conQuery)) {
                if(showOnlySearchContacts) {
                    Boolean shippingAddress = String.isNotBlank(contactObj.Account.ShippingStreet) || String.isNotBlank(contactObj.Account.ShippingCity) || String.isNotBlank(contactObj.Account.ShippingState) || String.isNotBlank(contactObj.Account.ShippingPostalCode);
                    String streetVal = shippingAddress == false ? contactObj.Account.BillingStreet : contactObj.Account.ShippingStreet;
                    String cityVal = shippingAddress == false ? contactObj.Account.BillingCity : contactObj.Account.ShippingCity;
                    String stateVal = shippingAddress == false ? contactObj.Account.BillingState : contactObj.Account.ShippingState;
                    String postalCodeVal = shippingAddress == false ? contactObj.Account.BillingPostalCode : contactObj.Account.ShippingPostalCode;
                    custDetailList.add(new VoiceAnswerScreenWrapper.CustDetails(contactObj.Id, contactObj.Name, contactObj.Phone, contactObj.Email, streetVal, cityVal, stateVal, postalCodeVal, contactObj.Account.Id, contactObj.Account.Name));
                } else{
                    b2cAccountIdList.add(contactObj.AccountId);
                }                
            }
        }        

        for(Contact contactObj : [Select Id, Name, Phone, Email, AccountId, Account.Name, Account.ShippingAddress, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode from Contact where AccountId IN: b2cAccountIdList AND AccountId != null AND Active_SERVICE__c = true]) {
            Boolean shippingAddress = String.isNotBlank(contactObj.Account.ShippingStreet) || String.isNotBlank(contactObj.Account.ShippingCity) || String.isNotBlank(contactObj.Account.ShippingState) || String.isNotBlank(contactObj.Account.ShippingPostalCode);
            String streetVal = shippingAddress == false ? contactObj.Account.BillingStreet : contactObj.Account.ShippingStreet;
            String cityVal = shippingAddress == false ? contactObj.Account.BillingCity : contactObj.Account.ShippingCity;
            String stateVal = shippingAddress == false ? contactObj.Account.BillingState : contactObj.Account.ShippingState;
            String postalCodeVal = shippingAddress == false ? contactObj.Account.BillingPostalCode : contactObj.Account.ShippingPostalCode;
            custDetailList.add(new VoiceAnswerScreenWrapper.CustDetails(contactObj.Id, contactObj.Name, contactObj.Phone, contactObj.Email, streetVal, cityVal, stateVal, postalCodeVal, contactObj.Account.Id, contactObj.Account.Name));
        }

        if(custDetailList.size() > CXOneOAuthCtrl.creds.Max_Search_Records__c) throw new TooManyRecordsException(System.Label.CXOne_Max_Rec_Error_Msg);
        custDetailList.sort();
        voiceAnswerScreenResponse.custDetailsList = custDetailList;
        voiceAnswerScreenResponse.isCaseNoSearch = false;
        voiceAnswerScreenResponse.caseNo = null;
        voiceAnswerScreenResponse.poNo = null;
        voiceAnswerScreenResponse.quoteNo = null;
        voiceAnswerScreenResponse.orderNo = null;
        voiceAnswerScreenResponse.maxCaseRecordsCrossed = false;
        return voiceAnswerScreenResponse;
    }


    private static List<Id> getAccountsRelatedToAccounts(String street, String city, String state, String zipCode, List<Id> accountIdList, List<Id> conAccIdList) {
        if(accountIdList == null) accountIdList   = new List<Id>();
        if(conAccIdList == null) conAccIdList     = new List<Id>();
        List<Id> accIdList      = new List<Id>();  
        String aggrQuery        = 'SELECT count(Id) totalRec FROM Address_Assignment__c WHERE (Account_Branch_Profile__c != null OR Account__c != null)';
        String query            = 'SELECT Id, Account__r.IsPersonAccount, Account_Branch_Profile__r.Party_Account__r.IsPersonAccount, Account__c, Account_Branch_Profile__r.Party_Account__c FROM Address_Assignment__c WHERE (Account_Branch_Profile__c != null OR Account__c != null)';
        if(accountIdList.isEmpty() && !conAccIdList.isEmpty()) {
            query       += ' AND Account__r.IsPersonAccount = false AND Account__c IN: conAccIdList';
            aggrQuery   += ' AND Account__r.IsPersonAccount = true AND Account__c IN: conAccIdList';            
        }
        if(!accountIdList.isEmpty() && !conAccIdList.isEmpty()) {
            query       += ' AND ((Account_Branch_Profile__r.Party_Account__r.IsPersonAccount = true AND Account_Branch_Profile__r.Party_Account__c IN: accountIdList) OR (Account__r.IsPersonAccount = false AND Account__c IN: conAccIdList))';
            aggrQuery   += ' AND ((Account_Branch_Profile__r.Party_Account__r.IsPersonAccount = true AND Account_Branch_Profile__r.Party_Account__c IN: accountIdList) OR (Account__r.IsPersonAccount = false AND Account__c IN: conAccIdList))';
        }
        
        /*if(String.isNotBlank(street)) {
            query       += street.contains('%') ? ' AND Address_Street__c like: street' : ' AND Address_Street__c =: street';
            aggrQuery   += street.contains('%') ? ' AND Address_Street__c like: street' : ' AND Address_Street__c =: street';
        }
        
        if(String.isNotBlank(city)) {
            query       += city.contains('%') ? ' AND Address_City__c like: city' : ' AND Address_City__c =: city';
            aggrQuery   += city.contains('%') ? ' AND Address_City__c like: city' : ' AND Address_City__c =: city';
        }
        
        if(String.isNotBlank(state)) {
            query       += state.contains('%') ? ' AND Address_State__c like: state' : ' AND Address_State__c =: state';
            aggrQuery   += state.contains('%') ? ' AND Address_State__c like: state' : ' AND Address_State__c =: state';
        }

        if(String.isNotBlank(zipCode)) {
            query       += zipCode.contains('%') ? ' AND Address_Zip__c like: zipCode' : ' AND Address_Zip__c =: zipCode';
            aggrQuery   += zipCode.contains('%') ? ' AND Address_Zip__c like: zipCode' : ' AND Address_Zip__c =: zipCode';
        }*/

        AggregateResult[] res = Database.query(aggrQuery);
        if(Integer.valueOf(res[0].get('totalRec')) > 15000) throw new TooManyRecordsException(System.Label.CXOne_Max_Rec_Error_Msg);        
                        
        for(Address_Assignment__c addAssignObj : Database.query(query)) {
            if((!accountIdList.isEmpty() && accountIdList.contains(addAssignObj.Account_Branch_Profile__r.Party_Account__c)) ||
               (accountIdList.isEmpty() && addAssignObj.Account_Branch_Profile__r.Party_Account__r.IsPersonAccount == true)) {
                if(addAssignObj.Account_Branch_Profile__c != null && addAssignObj.Account_Branch_Profile__r.Party_Account__c != null)
                accIdList.add(addAssignObj.Account_Branch_Profile__r.Party_Account__c);
               }
            if((!conAccIdList.isEmpty() && conAccIdList.contains(addAssignObj.Account__c)) || (conAccIdList.isEmpty() && addAssignObj.Account__r.IsPersonAccount == false)) {
                if(addAssignObj.Account__c != null)
                contactAccountIdList.add(addAssignObj.Account__c);
            }                
        }
        return accIdList;
    }
}