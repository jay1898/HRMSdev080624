/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          12/25/2019
*   @TaskSource:    Jira
*   @Purpose:       Exposed a public webservice which will return List of Opportunties based on parameters

Sandbox : https://pelladev-pellacorp.cs28.force.com/services/apexrest/searchOpportunities
Production : /services/apexrest/searchOpportunities
*   @Updates:       
*/
@RestResource(urlMapping='/searchOpportunities/*')
global without sharing class ServiceGETOpportunity 
{
    //Response class
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public List<SearchResult> results = new List<SearchResult>() ;
        
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    } 
    
    // Response Opportunity class to return SearchResult 
    global class SearchResult
    {
        public String CustomerNumber ;
        public String CustomerId ;
        public String CustomerName ;
        public String IdentifyingAddress ;
        public String SalesRepName ;
        public String EmailAddress ;
        public String PartyType ;
        public List<OpportunityRes> OpportunityInfo = new List<OpportunityRes>();
        public List<PhoneNumber> PhoneNumbers = new List<PhoneNumber>() ;
    }
    
    global class OpportunityRes
    {
        public String Description ; 
        public String Status ;
        public String Address1 ;
        public String City ;
        public String State ;
        public String PostalCode ;
        public String County ;
        public String Country ;
        public String LeadId ;
        public String PartyType ;
        //public String PartyNumber ;
        public String PartyName ;
        public String OpportunityId ;
        public List<AddressAssignment> AccountInfo = new List<AddressAssignment>();
    }
    
    global class AccountBranchProfile
    {
        public List<String> opportunityIds = new List<String>();
        public List<AddressAssignment> AccountInfo = new List<AddressAssignment>();
    }
    
    global class AddressAssignment
    {
        public String AddressType ; 
        public String Address1 ;
        public String City ;
        public String State ;
        public String PostalCode ;
        public String County ;
        public String Country ;
        //public String SalesRepName ;
        public String CustomerAccountNumber ;
        public String LastUpdateDate ;
        public String locationId ;
    }
    
    global class PhoneNumber
    {
        public String PhoneLineType ; 
        public String PhoneAreaCode ;
        public String PhoneNumber ;
        //public String PhoneCountryCode ;
        public String PhoneLinePurpose ;
    }
    
    global class Request
    {
        public String firstName ;
        public String lastName ;
        public String address ;
        public String city ; 
        public String postalcode ;
        public String phone ; 
        public String salesRepName ;
        public String organizationName ;
        public String customerID ;
        public String customerNumber ;
        public String businessSegment ;
        public String username ; 
        public String clientType ; 
        
    }
    
    
    @HttpPost
    global static Response getOpportunities()
    {
        
        RestRequest restReq = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;
        
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) return res ;
        
        Request req;
        
        String reqBody = restReq.requestBody.toString() ;
        System.debug('UAC: reqBody ' + reqBody );
        
        new ApexDebugLog().createLog(new ApexDebugLog.Information('ServiceGETOpportunity','getOpportunities',reqBody,JSON.serialize(res), ''));
        
        // Try to deserialize REQUEST
        try{
            req = (Request)JSON.deserialize(reqBody,Request.class);
            System.debug('UAC: req ' + req );
        }catch (Exception e){
            res.status = e.getMessage();
            res.errorMessage = 'INVALID_INPUT_FORMAT:';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServiceGETOpportunity','getOpportunities',reqBody,JSON.serialize(res),e.getStackTraceString()));
            return res;
        }
        
        String firstName = req.firstName;
        String lastName = req.lastName;
        String address = req.address;
        String city = req.city;
        String postalcode = req.postalcode;
        String phone = req.phone;
        String salesRepName = req.salesRepName;
        String organizationName = req.organizationName ; 
        String customerId = req.customerId ; 
        String customerNumber = req.customerNumber ; 
        String businessSegment = req.businessSegment ;
        String username = req.username ;
        String clientType = req.clientType; 
        
        System.debug('UAC: firstName ' + firstName + ' lastName ' + lastName + ' address ' + address + ' city ' + city + ' postalcode ' + postalcode + ' phone ' + phone + ' salesRepName ' + salesRepName );
        
        Boolean isTradeCommercial = String.isNotBlank(organizationName) ? true : false;
        if(String.isNotBlank(businessSegment) ){
            isTradeCommercial =businessSegment.equalsIgnoreCase('Retail')? false : true;
        }
        
        if(String.isBlank(firstName) && String.isBlank(lastName) && String.isBlank(address) && String.isBlank(city) 
           && String.isBlank(postalcode) && String.isBlank(phone) && String.isBlank(salesRepName) && String.isBlank(organizationName) && String.isBlank(customerId))
        {
            res.httpStatusCode = '400';
            res.status = 'INVALID_INPUT_REQUEST_TYPE';
            res.errorMessage = 'Please provide at least one valid Parameter';
            return res;
        }
        Set<String> branchNumbers = new Set<String>();
        Set<Id> territoryIds = new Set<Id>();
        
        List<UserTerritory2Association> listUTA = [SELECT  Territory2.Id,  Territory2.Territory_Type_Name__c, 
                                                   Territory2.Territory_Reference_Number__c,Territory2.TCBranchNumber__c, Territory2.ParentTerritory2.Territory_Reference_Number__c,Territory2.ParentTerritory2.TCBranchNumber__c
                                                   FROM UserTerritory2Association
                                                   WHERE User.EBS_UserName__c = :req.username AND User.EBS_UserName__c != NULL ];
        
        System.debug('User.EBS_UserName__c :: '+ User.EBS_UserName__c);
        System.debug('req.username :: '+ req.username);
        
        System.debug('listUTA :: '+ listUTA);
        for(UserTerritory2Association uta : listUTA){
            if(String.isNotBlank(uta.Territory2.Territory_Type_Name__c) && uta.Territory2.Territory_Type_Name__c == 'Branch_Family'){ 
                territoryIds.add(uta.Territory2.Id);      
            }else if(String.isNotBlank(uta.Territory2.Territory_Type_Name__c) && uta.Territory2.Territory_Type_Name__c == 'Branch'){   
                if(isTradeCommercial){
                    if(String.isNotBlank(uta.Territory2.TCBranchNumber__c)) branchNumbers.add(uta.Territory2.TCBranchNumber__c);
                }else{
                    if(String.isNotBlank(uta.Territory2.Territory_Reference_Number__c)) branchNumbers.add(uta.Territory2.Territory_Reference_Number__c);
                }
                
            }else {
                if(isTradeCommercial){
                    if(String.isNotBlank(uta.Territory2.ParentTerritory2.TCBranchNumber__c)) branchNumbers.add(uta.Territory2.ParentTerritory2.TCBranchNumber__c);    
                }else{
                    if(String.isNotBlank(uta.Territory2.ParentTerritory2.Territory_Reference_Number__c)) branchNumbers.add(uta.Territory2.ParentTerritory2.Territory_Reference_Number__c);    
                }
            }
        } 
        System.debug('UAC: territoryIds ' + territoryIds );
        if(territoryIds.size() > 0){
            for( Territory2 tr : [SELECT Territory_Reference_Number__c, TCBranchNumber__c 
                                  FROM Territory2
                                  WHERE ParentTerritory2Id IN :territoryIds])
            {
                
                if(isTradeCommercial){
                    if(String.isNotBlank(tr.TCBranchNumber__c)) branchNumbers.add(tr.TCBranchNumber__c);
                }else{
                    if(String.isNotBlank(tr.Territory_Reference_Number__c)) branchNumbers.add(tr.Territory_Reference_Number__c);
                }
            } 
        }  
        System.debug('UAC: branchNumbers ' + branchNumbers );
        Set<String> Stages = new Set<String>{'Closed', 'Closed Won'}; 
            Date cutOffDate = Date.newInstance(2020, 01, 01);   
        // Make query for Opportunities 
        String query =  ' SELECT    Id, AccountId, Account.Name,Account.branchaccmdmrecid__c, Account.AccountNumber, Account.mdmrecid__c,Account.Parent.Mdmrecid__c,Account.Parent.AccountNumber, Account.PersonEmail, Account.RecordType.Name, ' + 
            '           Account.PersonMailingStreet, Account.PersonMailingCity, Account.PersonMailingState, Account.PersonMailingPostalCode, Account.Company_Email__c,  ' + 
            '           Account.PersonMailingCountry, Account.PersonHomePhone, Account.PersonMobilePhone, Account.PersonOtherPhone, Account.PersonAssistantPhone, ' +
            '           Description, Owner.EBS_UserName__c, Owner.Name, Name, Status__c, Address__c,Account.IdentifyingAddress__c, Opportunity_No__c, StageName, ' + 
            '           Account_Branch_Profile__c, Account_Branch_Profile__r.MDMrecid__c,Account.BillingStreet, Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode '  +
            ' FROM Opportunity ' + 
            ' WHERE Id != NULL and stageName NOT IN :Stages and closedate >= :cutOffDate'  ;
        
        if(String.isNotBlank(firstName) && (!firstName.contains('*') && !firstName.contains('%') )) {
            query += ' AND Account.FirstName = :firstName ' ;
        }
        if(String.isNotBlank(firstName) && (firstName.contains('*') || firstName.contains('%') ))
        {
            firstName = firstName.replace('*', '%');
            query += ' AND Account.FirstName LIKE :firstName ' ;
        }
        
        if(String.isNotBlank(lastName) && (!lastName.contains('*')  && !lastName.contains('%') ) ) {
            query += ' AND Account.LastName = :lastName ' ;
        }
        if(String.isNotBlank(lastName) && ( lastName.contains('*') || lastName.contains('%')) )
        {
            lastName = lastName.replace('*', '%');
            query += ' AND Account.LastName LIKE :lastName ' ;
        }
        
        if(String.isNotBlank(salesRepName)) query += ' AND Owner.Name = :salesRepName ' ;
        
        if(String.isNotBlank(organizationName) && (!organizationName.contains('*') && !organizationName.contains('%') )) {
            query += ' AND Account.Name Like :organizationName ' ;
        }
        if(String.isNotBlank(organizationName) && (organizationName.contains('*') || organizationName.contains('%')) )
        {
            organizationName = organizationName.replace('*', '%');
            query += ' AND Account.Name LIKE :organizationName ' ;
        }
        //if(String.isNotBlank(organizationName)) query += ' AND Account.Name = :organizationName ' ;
        
        if(isTradeCommercial){
            if(String.isNotBlank(city)) {
                query += ' AND ( (Account.BillingCity = :city) ' + 
                    ' OR (Account.ShippingCity = :city)  ' + 
                    ' OR (Account.Parent.BillingCity = :city) ) ' ;
            }
            if(String.isNotBlank(postalcode)) {
                query += ' AND ( (Account.BillingPostalCode = :postalcode) ' + 
                    ' OR (Account.ShippingPostalCode  = :postalcode)  ' + 
                    ' OR (Account.Parent.BillingPostalCode = :postalcode) ) ' ;
            }
            
            // Updated by Mayank - 11/17/2020 - If Account recordType PersonAccount then campare with Account.MDMrecid__c otherwise campare with Acccount.Parent.MDMrecid__c
            if(String.isNotBlank(customerId)) { 
                query += ' AND ((Account.MDMrecid__c = :customerId AND Account.RecordType.DeveloperName = \'PersonAccount\') OR (Account.Parent.MDMrecid__c = :customerId AND Account.RecordType.DeveloperName != \'PersonAccount\') OR (Account.MDMrecid__c = :customerId AND Account.RecordType.DeveloperName = \'Pro_Lowes\') )' ;
            }
            if(String.isNotBlank(customerNumber)) {
                query += ' AND Account.branchaccmdmrecid__c = :customerNumber ' ;
            }
            if(String.isNotBlank(phone)) {
                query += ' AND Account.Phone = :phone ' ;
            }
            // Split address parameter for Fuzzy match
            if(String.isNotBlank(address)){
                // Remove all commas
                address = address.replaceAll(',', '');
                
                List<String> partialMatches = new List<String>();
                for(String fragment : address.split(' '))
                {
                    partialMatches.add('%' + fragment + '%');
                }
                query += ' AND (Account.BillingAddress__c LIKE :partialMatches OR Account.ShippingAddress__c LIKE :partialMatches OR Account.IdentifyingAddress__c LIKE :partialMatches) ' ;
            }
            
            if(branchNumbers.size() > 0 ) 
            {
                List<String> branchNumbersFilter = new List<String>();
                for(String branchNumber : branchNumbers)
                {
                    branchNumbersFilter.add('%;' + branchNumber + ';%');
                }
                
                query += ' AND Account.Branch_Number__c LIKE :branchNumbersFilter ' ;
            }
            // if(branchNumbers.size() > 0 ) {
            //     query += ' AND Account.Branch__r.T_C_Branch_Number__c IN :branchNumbers ' ;
            // }
            
            if(String.isNotBlank(businessSegment)){
                businessSegment=businessSegment.equalsIgnoreCase('Retail')?'Replacement':businessSegment;
            if(String.isNotBlank(clientType) && clientType == '4')
                businessSegment='Lowe\'s';
            else if(String.isNotBlank(clientType) && clientType == '2') 
                businessSegment='Prodealer';

                query += ' AND Type = :businessSegment ' ;
            }
        }
        else{
            if(String.isNotBlank(city)) query += ' AND Account.PersonMailingCity = :city ' ;
            if(String.isNotBlank(postalcode)) query += ' AND Account.PersonMailingPostalCode = :postalcode ' ;
            if(String.isNotBlank(customerId)) query += ' AND Account.mdmrecid__c = :customerId ' ;
            if(String.isNotBlank(customerNumber)) query += ' AND Account_Branch_Profile__r.MDMrecid__c = :customerNumber ' ;
            // Search phone number among All Account phone fields 
            if(String.isNotBlank(phone)) query += ' AND ( (Account.PersonHomePhone = :phone AND Account.PersonHomePhone != NULL) ' + 
                '       OR (Account.PersonMobilePhone = :phone AND Account.PersonMobilePhone != NULL)  ' + 
                '       OR (Account.PersonOtherPhone = :phone AND Account.PersonOtherPhone != NULL)  ' + 
                '       OR (Account.PersonAssistantPhone = :phone AND Account.PersonAssistantPhone != NULL) ) ' ;
            // Split address parameter for Fuzzy match
            if(String.isNotBlank(address)){
                // Remove all commas
                address = address.replaceAll(',', '');
                
                List<String> partialMatches = new List<String>();
                for(String fragment : address.split(' '))
                {
                    partialMatches.add('%' + fragment + '%');
                }
                query += ' AND Address__c LIKE :partialMatches ' ;
            }
            if(branchNumbers.size() > 0 ) query += ' AND Branch_Number__c IN :branchNumbers ' ;
            //if(String.isNotBlank(businessSegment)) query += ' AND Business_Segment__c = :businessSegment ' ;
            
            //Changed on 26-08 regarding bussiness Segment
             if(String.isNotBlank(businessSegment)){
                businessSegment=businessSegment.equalsIgnoreCase('Retail')?'Replacement':businessSegment;
                query += ' AND Business_Segment__c = :businessSegment ' ;
            }
        }
        
        System.debug('UAC: query ' + query);
       
        
        Set<Id> accountIds = new Set<Id>();
        Map<String,List<String>> abpIdToOppIds = new Map<String,List<String>>();
        Map<String,List<Opportunity>> accountIdToOpps = new Map<String,List<Opportunity>>();
        Map<String,Account> accountMap = new Map<String,Account>();
        List<SearchResult> sResults = new List<SearchResult>();
        
        // Get Opportunities 
        for(Opportunity opp : Database.query(query))
        {
            if(String.isNotBlank(opp.Account_Branch_Profile__c)) 
            {
                List<String> tempList = abpIdToOppIds.get(opp.Account_Branch_Profile__c);
                if(tempList == null)
                {
                    tempList = new List<String>();
                    abpIdToOppIds.put(opp.Account_Branch_Profile__c, tempList);
                }
                tempList.add(opp.Id);
            }
            accountIds.add(opp.AccountId);
            
            List<Opportunity> tempOpps = accountIdToOpps.get(opp.AccountId);
            if(tempOpps == null)
            {
                tempOpps = new List<Opportunity>();
                accountIdToOpps.put(opp.AccountId, tempOpps);
            }
            tempOpps.add(opp);
        }
        if(isTradeCommercial){
           /* Rekha Removing AccountInfo
            *  Map<String,List<Address_Assignment__c>> accountIdToAddressAssignments = new Map<String,List<Address_Assignment__c>>();
            for(Address_Assignment__c add : [   SELECT Id, Address_Usage_Type__c, Address__r.Street__c, Address__r.City__c, Address__r.Zipcode__c,  
                                             Address__r.State__c, Address__r.Country__c, Address__r.County__c, LastModifiedDate,
                                             Account__c, Account__r.MDMrecid__c,Account__r.branchaccmdmrecid__c,
                                             Address__r.Location_Id__c, Address__r.MDMrecid__c
                                             FROM Address_Assignment__c WHERE Account__c IN :accountIdToOpps.keySet()])
            {
                if(!accountIdToAddressAssignments.containsKey(add.Account__c)){
                    accountIdToAddressAssignments.put(add.Account__c, new List<Address_Assignment__c>());
                }
                accountIdToAddressAssignments.get(add.Account__c).add(add);
            }
*/
            for(Account ac : [  SELECT Name, Phone 
                              FROM Account WHERE ID IN :accountIds])
            {
                SearchResult sResult = new SearchResult();
                sResults.add(sResult);
                
                if(String.isNotBlank(ac.Phone)) 
                {
                    PhoneNumber ph = new PhoneNumber();
                    ph.phoneLinePurpose = 'PHONE' ;
                    ph.phoneLineType = 'PHONEDAY' ;
                    ph.phoneNumber = ServiceUtil.formatPhone(ac.Phone) ;
                    ph.phoneAreaCode = ph.phoneNumber.left(3);
                    sResult.phoneNumbers.add(ph);
                }
                for(Opportunity opp : accountIdToOpps.get(ac.Id))
                {
                    
                    if(String.isNotBlank(opp.Account.RecordType.Name) && (opp.Account.RecordType.Name == 'Person Account' || opp.Account.RecordType.Name == 'Pro_Lowes')){
                        sResult.customerId = ServiceUtil.checkNull(opp.Account.Mdmrecid__c) ;
                        sResult.customerNumber = ServiceUtil.checkNull(opp.Account.AccountNumber) ;
                        sResult.identifyingAddress = ServiceUtil.checkNull(opp.Address__c).replaceAll('<br>', ' ') ;
                    }else{
                        sResult.customerId = ServiceUtil.checkNull(opp.Account.Parent.Mdmrecid__c) ;
                        sResult.customerNumber = ServiceUtil.checkNull(opp.Account.Parent.AccountNumber) ;
                        sResult.identifyingAddress = ServiceUtil.checkNull(opp.Account.IdentifyingAddress__c).replaceAll('<br>', ' ') ;
                    }
                    sResult.customerName = ServiceUtil.checkNull(opp.Account.Name) ;
                    sResult.salesRepName = ServiceUtil.checkNull(opp.Owner.Name) ;
                    sResult.emailAddress = opp.Account.Company_Email__c  ;
                    sResult.partyType = opp.Account.RecordType.Name ;
                    
                    OpportunityRes oppRes = new OpportunityRes();
                    oppRes.description = opp.Name ; 
                    oppRes.status = opp.StageName ;
                    
                    //Added on 23-11 to resolve person account address issue
                    if(String.isNotBlank(opp.Account.RecordType.Name) && opp.Account.RecordType.Name == 'Person Account'){
                        oppRes.address1 = opp.Account.PersonMailingStreet ;
                        oppRes.city = opp.Account.PersonMailingCity ;
                        oppRes.state = opp.Account.PersonMailingState ;
                        oppRes.postalCode = opp.Account.PersonMailingPostalCode ;
                        //oppRes.county = opp.Name ;
                        oppRes.country = opp.Account.PersonMailingCountry ;
                    }else{
                        oppRes.address1 = opp.Account.BillingStreet ;
                        oppRes.city = opp.Account.BillingCity ;
                        oppRes.state = opp.Account.BillingState ;
                        oppRes.postalCode = opp.Account.BillingPostalCode ;
                        //oppRes.county = opp.Name ;
                        oppRes.country = opp.Account.BillingCountry ;
                    }
                    
                    oppRes.leadId = opp.Opportunity_No__c ;
                    oppRes.partyType = opp.Account.RecordType.Name ;
                    //oppRes.partyNumber = opp.Name ;
                    oppRes.partyName = opp.Account.Name ;
                    oppRes.opportunityId = opp.Id ;
                    
                   /* --Rekha Removing AccountInfo Section
                    * if(String.isNotBlank(opp.AccountId) && accountIdToAddressAssignments.containsKey(opp.AccountId))
                    {
                        AccountBranchProfile abp = new AccountBranchProfile();
                        //abp.opportunityIds = abpIdToOppIds.get(opp.Account_Branch_Profile__c);
                        
                        for(Address_Assignment__c add : accountIdToAddressAssignments.get(opp.AccountId))
                        {
                            AddressAssignment aAssign = new AddressAssignment();
                            aAssign.addressType = ServiceUtil.checkNull(add.Address_Usage_Type__c).replaceAll(' ', '_') ; 
                            aAssign.address1 = ServiceUtil.checkNull(add.Address__r.Street__c) ; 
                            aAssign.postalCode = ServiceUtil.checkNull(add.Address__r.Zipcode__c) ; 
                            aAssign.state = ServiceUtil.checkNull(add.Address__r.State__c) ; 
                            aAssign.city = ServiceUtil.checkNull(add.Address__r.City__c) ; 
                            aAssign.country = ServiceUtil.checkNull(add.Address__r.Country__c) ; 
                            aAssign.county = ServiceUtil.checkNull(add.Address__r.County__c) ; 
                            aAssign.customerAccountNumber = ServiceUtil.checkNull(add.Account__r.branchaccmdmrecid__c) ;
                            aAssign.locationId = ServiceUtil.checkNull(add.Address__r.MDMrecid__c) ;
                            aAssign.lastUpdateDate = String.valueOf(add.LastModifiedDate); 
                            oppRes.accountInfo.add(aAssign);        
                        }
                    }*/
                    sResult.opportunityInfo.add(oppRes);
                }
            }
            res.results = sResults ;
        }
        else{
            /* Rekha
            Map<String,List<Address_Assignment__c>> abpIdToAddressAssignments = new Map<String,List<Address_Assignment__c>>();
            for(Address_Assignment__c add : [   SELECT Id, Address_Usage_Type__c, Address__r.Street__c, Address__r.City__c, Address__r.Zipcode__c,  
                                             Address__r.State__c, Address__r.Country__c, Address__r.County__c, LastModifiedDate,
                                             Account_Branch_Profile__c, Account_Branch_Profile__r.MDMrecid__c, 
                                             Address__r.Location_Id__c, Address__r.MDMrecid__c
                                             FROM Address_Assignment__c WHERE Account_Branch_Profile__c IN :abpIdToOppIds.keySet()])
            {
                List<Address_Assignment__c> tempList = abpIdToAddressAssignments.get(add.Account_Branch_Profile__c);
                if(tempList == null)
                {
                    tempList = new List<Address_Assignment__c>();
                    abpIdToAddressAssignments.put(add.Account_Branch_Profile__c, tempList);
                }
                tempList.add(add);
            }
            */
            
            for(Account ac : [  SELECT Name, AccountNumber, PersonEmail, RecordType.Name, Evening_Phone_Type__c, 
                              PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, 
                              PersonMailingCountry, PersonHomePhone, PersonMobilePhone, PersonOtherPhone, PersonAssistantPhone
                              FROM Account WHERE ID IN :accountIds])
            {
                SearchResult sResult = new SearchResult();
                sResults.add(sResult);
                
                if(String.isNotBlank(ac.PersonHomePhone)) 
                {
                    PhoneNumber ph = new PhoneNumber();
                    ph.phoneLinePurpose = 'HOME' ;
                    ph.phoneLineType = 'PHONEDAY' ;
                    ph.phoneNumber = ServiceUtil.formatPhone(ac.PersonHomePhone) ;
                    ph.phoneAreaCode = ph.phoneNumber.left(3);
                    sResult.phoneNumbers.add(ph);
                }
                if(String.isNotBlank(ac.PersonMobilePhone)) 
                {
                    PhoneNumber ph = new PhoneNumber();
                    ph.phoneLinePurpose = 'MOBILE' ;
                    ph.phoneLineType = 'PHONEDAY' ;
                    ph.phoneNumber = ServiceUtil.formatPhone(ac.PersonMobilePhone) ;
                    ph.phoneAreaCode = ph.phoneNumber.left(3);
                    sResult.phoneNumbers.add(ph);
                }
                if(String.isNotBlank(ac.PersonOtherPhone)) 
                {
                    PhoneNumber ph = new PhoneNumber();
                    ph.phoneLinePurpose = 'WORK' ;
                    ph.phoneLineType = 'PHONEDAY' ;
                    ph.phoneNumber = ServiceUtil.formatPhone(ac.PersonOtherPhone) ;
                    ph.phoneAreaCode = ph.phoneNumber.left(3);
                    sResult.phoneNumbers.add(ph);
                }
                if(String.isNotBlank(ac.PersonAssistantPhone)) 
                {
                    PhoneNumber ph = new PhoneNumber();
                    ph.phoneLinePurpose = ac.Evening_Phone_Type__c ;
                    ph.phoneLineType = 'PHONEEVE' ;
                    ph.phoneNumber = ServiceUtil.formatPhone(ac.PersonAssistantPhone) ;
                    ph.phoneAreaCode = ph.phoneNumber.left(3);
                    sResult.phoneNumbers.add(ph);
                }
                
                for(Opportunity opp : accountIdToOpps.get(ac.Id))
                {
                    sResult.customerId = ServiceUtil.checkNull(opp.Account.Mdmrecid__c) ;
                    sResult.customerName = ServiceUtil.checkNull(opp.Account.Name) ;
                    sResult.customerNumber = ServiceUtil.checkNull(opp.Account_Branch_Profile__r.MDMrecid__c) ;
                    sResult.identifyingAddress = ServiceUtil.checkNull(opp.Address__c).replaceAll('<br>', ' ') ;
                    sResult.salesRepName = ServiceUtil.checkNull(opp.Owner.Name) ;
                    sResult.emailAddress = opp.Account.PersonEmail ;
                    sResult.partyType = opp.Account.RecordType.Name ;
                    
                    OpportunityRes oppRes = new OpportunityRes();
                    oppRes.description = opp.Name ; 
                    oppRes.status = opp.StageName ;
                    oppRes.address1 = opp.Account.PersonMailingStreet ;
                    oppRes.city = opp.Account.PersonMailingCity ;
                    oppRes.state = opp.Account.PersonMailingState ;
                    oppRes.postalCode = opp.Account.PersonMailingPostalCode ;
                    //oppRes.county = opp.Name ;
                    oppRes.country = opp.Account.PersonMailingCountry ;
                    oppRes.leadId = opp.Opportunity_No__c ;
                    oppRes.partyType = opp.Account.RecordType.Name ;
                    //oppRes.partyNumber = opp.Name ;
                    oppRes.partyName = opp.Account.Name ;
                    oppRes.opportunityId = opp.Id ;
                    
                    /* --Rekha Removing AccountInfo from API
                    if(String.isNotBlank(opp.Account_Branch_Profile__c) && abpIdToAddressAssignments.containsKey(opp.Account_Branch_Profile__c))
                    {
                        AccountBranchProfile abp = new AccountBranchProfile();
                        //abp.opportunityIds = abpIdToOppIds.get(opp.Account_Branch_Profile__c);
                        
                        for(Address_Assignment__c add : abpIdToAddressAssignments.get(opp.Account_Branch_Profile__c))
                        {
                            AddressAssignment aAssign = new AddressAssignment();
                            aAssign.addressType = ServiceUtil.checkNull(add.Address_Usage_Type__c).replaceAll(' ', '_') ; 
                            aAssign.address1 = ServiceUtil.checkNull(add.Address__r.Street__c) ; 
                            aAssign.postalCode = ServiceUtil.checkNull(add.Address__r.Zipcode__c) ; 
                            aAssign.state = ServiceUtil.checkNull(add.Address__r.State__c) ; 
                            aAssign.city = ServiceUtil.checkNull(add.Address__r.City__c) ; 
                            aAssign.country = ServiceUtil.checkNull(add.Address__r.Country__c) ; 
                            aAssign.county = ServiceUtil.checkNull(add.Address__r.County__c) ; 
                            aAssign.customerAccountNumber = ServiceUtil.checkNull(add.Account_Branch_Profile__r.MDMrecid__c) ;
                            aAssign.locationId = ServiceUtil.checkNull(add.Address__r.MDMrecid__c) ;
                            aAssign.lastUpdateDate = String.valueOf(add.LastModifiedDate); 
                            oppRes.accountInfo.add(aAssign);        
                        }
                    }*/
                    sResult.opportunityInfo.add(oppRes);
                }
            }
            
            res.results = sResults ;
        }
        
        System.debug('UAC: res ' + res );
        return res;
    }
}