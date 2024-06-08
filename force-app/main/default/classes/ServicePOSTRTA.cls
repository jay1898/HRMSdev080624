/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          11/27/2019
*   @TaskSource:    JIRA (SI-435, 125)
*   @Purpose:       Exposed a public webservice which will create Account, Address, Account Branch Info, Opportunity, Lead and Service Assignment records based on JSON attributes
*                   Before Account, Address, Account Branch Info and Opportunity code looking for existing record based on different criterias. 
*                   To Access this webservice for testing use these URLs, since it is public webservice therefore don't need any authentication
Sandbox : https://pelladev-pellacorp.cs28.force.com/services/apexrest/PostRTA
Production : /services/apexrest/PostRTA
*   @Updates:       Sachin Padhiyar (eVerge) 
*   @Date:          04/13/2020
*   @purpose:       For web RTA appointments, if there is no campaign information sent from pella.com, the opps and Leads should be associated with a catch campaign id 
*/
@RestResource(urlMapping='/PostRTA/*')
global without sharing class ServicePOSTRTA 
{
    public static Map<Id,String> addrAssignIdToTriggerMode = new Map<Id,String>();
    
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    
    
    global class Request
    {
        public String recid ; 
        public String firstname ; 
        public String lastname ; 
        public String address ; 
        public String address2 ; 
        public String country ; 
        public String city ; 
        public String state ; 
        public String zip ; 
        public String dayphone ; 
        public String phonetype ; 
        public String evephone ;
        public String evephonetype ;
        public String email ; 
        public String urlstring ; 
        public String apptsource ; 
        public String comments ; 
        public String destination ; 
        public String branchID ; 
        public String start ; 
        public String end_z ; 
        public String resource ; 
        public String notifyemail ; 
        public String consentcall ; 
        public String consentsms ;
        public String consenttophone ; 
        public String consenttomail ; 
        public String apptreqtype ; 
        public String appttype ; 
        public String storename ; 
        public Integer noOfDoors ;
        public Integer noOfWindows ;
        public String oppNo ;
        // added for timezone handle
        public String TimeZone_Code;
        public String callerId ;
        public String callcenteruid ;
        public String leadsource ;
        public String marketingsource ;
        public String showroomreqtype ; 
        public String cartadd ;
        public Boolean virtualapptmt ;
    }
    
    @HttpPost
    global static Response postData()
    {
        RestRequest reqst = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        String reqBody ;
        
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) return res ;
        
        try{
            Request req;
            
            reqBody = reqst.requestBody.toString() ;
            reqBody = reqBody.replaceAll('"end"', '"end_z"');
            
            // If request contains noOfWindows as empty string then change it to null to prevent JSON deserialization error
            if(reqBody.containsIgnoreCase('"noOfWindows":""')) reqBody = reqBody.replaceAll('"noOfWindows":""', '"noOfWindows" : null ');
            if(reqBody.containsIgnoreCase('"noOfWindows": ""')) reqBody = reqBody.replaceAll('"noOfWindows": ""', '"noOfWindows" : null ');
            if(reqBody.containsIgnoreCase('"noOfWindows" : ""')) reqBody = reqBody.replaceAll('"noOfWindows" : ""', '"noOfWindows" : null ');
            
            // If request contains noOfDoor as empty string then change it to null to prevent JSON deserialization error
            if(reqBody.containsIgnoreCase('"noOfDoors":""')) reqBody = reqBody.replaceAll('"noOfDoors":""', '"noOfDoors" : null ');
            if(reqBody.containsIgnoreCase('"noOfDoors": ""')) reqBody = reqBody.replaceAll('"noOfDoors": ""', '"noOfDoors" : null ');
            if(reqBody.containsIgnoreCase('"noOfDoors" : ""')) reqBody = reqBody.replaceAll('"noOfDoors" : ""', '"noOfDoors" : null ');
            
            
            System.debug('UAC: reqBody ' + reqBody );
            // Try to deserialize REQUEST
            try{
                req = (Request)JSON.deserialize(reqBody,Request.class);
                System.debug('UAC: req ' + req );
            }catch (Exception e){
                res.status = e.getMessage();
                res.errorMessage = 'INVALID_INPUT_FORMAT:';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostRTA','postData',reqBody,JSON.serialize(res),e.getStackTraceString(),'Integration'));
                return res;
            }
            
            // When ApptSource NOT in (Web, Call Center, Showroom)
            // 02-09-2020 added showroom in lowercase and also put return statement to resolve duplicate lead issue
            Set<String> validApptSources = new Set<String>{'Web', 'Call Center', 'Showroom','showroom'};
                if(!validApptSources.contains(req.apptsource)) 
            {
                res.errorMessage = 'ApptSource is not valid for this request' ;
                res.status = 'Fail';
                res.httpStatusCode = '400' ;
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostRTA','postData',reqBody,JSON.serialize(res),null,'Integration'));
                return res;
            }
            
            restRes.responseBody = Blob.valueOf( JSON.serialize(res));
            restRes.headers.put('Content-Type','application/json');
            restRes.headers.put('Access-Control-Allow-Origin','*');
            
            // Information Log Added on 26-02
            new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePostRTA','postData',JSON.serialize(res),reqBody,'Integration'));
            doEverything(reqBody, UserInfo.getSessionId() );
            
        }
        catch(Exception ex){
            System.debug('UAC: exception ' + ex.getMessage() );
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostRTA','postData',reqst.requestBody.toString(),ex,'Integration'));
        }
        
        return res;
    }
    
    @future(callout=true)
    public static void doEverything(String reqBody, String sessionId )
    {
        try{
            Request req;
            req = (Request)JSON.deserialize(reqBody,Request.class);
            
            req = makePrettyRequestForNullValues(req);
            
            // Trim zip code if needed 
            req.zip = ServiceUtil.trimZipCode(req.zip);
            
            String canadianZipcode= !req.zip.isNumeric() && req.zip.length() > 3 ? req.zip.substring(0,3) + '%' : '' ;
            
            //System.debug('UAC: req.zip ' + req.zip );
            req.TimeZone_Code='';
            List<ServiceTerritory> lstServiceTerritory ;
            
            lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                   ParentTerritory.ParentTerritory.Branch__c,ParentTerritory.ParentTerritory.Branch__r.branch_number__C, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c,ParentTerritory.Virtual_Appt_Duration_Min__c 
                                   FROM ServiceTerritory 
                                   WHERE PostalCode != NULL AND (PostalCode=:req.zip OR PostalCode LIKE :canadianZipcode ) AND RecordType.Name='Zipcode' ];
            
            if(String.isBlank(req.zip))
            {
                lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                       ParentTerritory.ParentTerritory.Branch__c, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c,ParentTerritory.Virtual_Appt_Duration_Min__c 
                                       FROM ServiceTerritory 
                                       WHERE ParentTerritory.Parent_Branch__c = '998' AND RecordType.Name='Zipcode' LIMIT 1 ];
            }
            
            ServiceTerritory zoneST ;
            if(lstServiceTerritory.size()>0)
            {
                // Parent Territory (Zone Territory) of Zipcode territory
                zoneST = lstServiceTerritory[0].ParentTerritory;
                req.TimeZone_Code= zoneST.OperatingHours.TimeZone;
                req.branchID = lstServiceTerritory[0].ParentTerritory.ParentTerritory.Branch__r.branch_number__C;
            }
            System.debug('UAC: zoneST ' + zoneST );
            //System.debug('TimeZone Code :: '+req.TimeZone_Code);
            
            Map<String,String> urlStringsMap = new Map<String,String>{  'utmcampaign' => 'utmcampaign__c', 'utmcontent' => 'utmcontent__c', 
                'utmmedium' => 'utmmedium__c', 'utmsource' => 'utmsource__c', 
                'pel_campaign_code' => 'pel_campaign_code__c', 'reqType' => 'reqType__c', 
                'parentSite' => 'parentSite__c', 'EloquaID' => 'EloquaID__c','host' => 'HostSite__c',
                'utmterm' => 'utmterm__c', 'utmdevice' => 'utmdevice__c','utmvariant' => 'utmvariant__c','gclid' => 'GCLID__c'};
                    
                    // Make start date and end date
                    DateTime startDate ;
            DateTime endDate ;
            if(String.isNotBlank(req.start)) startDate = DateTime.valueOf(req.start.replace('T', ' ').replace('Z', '')) ;
            if(String.isNotBlank(req.end_z)) endDate = DateTime.valueOf(req.end_z.replace('T', ' ').replace('Z', '')) ;
            System.debug('UAC: startDate ' + startDate );
            System.debug('UAC: endDate ' + endDate );
            
            // change timezone before save
            if(!String.isBlank(req.TimeZone_Code) && startDate != null )
            {
                TimeZone tz = TimeZone.getTimeZone(req.TimeZone_Code);
                startDate=startDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
                endDate=endDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
            }
            
            // Get homeOwner information before performing any DML 
            Map<String,Object> responseMap = getHomeOwnerInfo(req.address, req.address2, req.city, req.state, req.zip);
            
            // Get Branch information based on BranchID
            String branchId = getBranchInfo(req.branchID);
            
            // Added on 09-02 release Timeslot 
            List<RTA_Timeblock__c> timeBlocks  =[SELECT ID FROM RTA_Timeblock__c WHERE Opportunity_No__c = :req.oppNo ];
            if(timeBlocks.size() > 0) delete timeBlocks ;
            
            //System.debug('UAC: apptsource ' + req.apptsource + ' appttype ' + req.appttype );
            
            if(req.appttype.equalsIgnoreCase('NRT') || req.appttype.equalsIgnoreCase('Lead Only'))
            {
                Lead ld = createLead(req, urlStringsMap, null, startDate, endDate, zoneST);
                insert ld ;
                setBestMatch(null, null, ld.Id, null, req.address, req.address2, req.city, req.state, req.zip, req.country, req.start, reqBody, responseMap);
                
                return ; // GO BACK FROM HERE, DON'T NEED TO DO ANYTHING FURTHER
            }
            
            Set<String> apptTypesRT = new Set<String>{'RT', 'Preferred'};
                // Don't Process if Type is not RT or Preferred
                if( !apptTypesRT.contains(req.appttype) ) return  ;
            
            // Create or Update Customer Account 
            Account ac = createUpdateCustomerAccount(req, zoneST, reqBody);
            
            // Create or Update Address
            Address__c addr = createUpdateAddress(req, zoneST, reqBody);
            
            // Create or Update Account Branch Profile related to Account and Branch
            Account_Branch_Profile__c abf = createUpdateAccountBranchProfile(branchId, ac.Id);
            
            // Get Address Assingment for Account and AccountBranchProfile, if doesn't exists then create new one
            List<Address_Assignment__c> addressAssignments = createAddressAssignment(addr.Id, abf.Id, zoneST);
            
            // Get All open opportunities under Account and Account Branch Profile
            Date cutOffFiscalYear = Date.newInstance(2019, 12, 1);
            String searchStreet = '%' + addr.street__c + '%'+ addr.zipcode__c + '%';  
            
            // 25-05-2021 : W-000378 Allow another opp to be created if opp is in Contracted Stage (Added AND StageName !='Contracted' in codition )
            List<Opportunity> openOpps = [SELECT Id FROM Opportunity WHERE Account_Branch_Profile__c = :abf.Id 
                                          AND AccountId = :ac.Id AND IsClosed = FALSE AND CreatedDate > :cutOffFiscalYear
                                          AND StageName !='Contracted'
                                          AND  address__c  like :searchStreet ];
            System.debug('UAC: openOpps ' + openOpps );
            
            // When OPEN Opportunity Found for AccountBranchProfile and existing AddressAssignment
            if( openOpps.size() > 0 && addressAssignments.size() > 0 )
            { 
                // Create Lead and attach it to existing Open Opportunity
                Lead ld = createLead(req, urlStringsMap, openOpps[0].Id, startDate, endDate, zoneST);
                ld.Account_and_Opportunity_already_Exist__c = true ;
                insert ld ; 
            }
            
            // When no Opportunity for existing Address Assignment - OR - // For New Address Assignment 
            if( (openOpps.size() == 0 && addressAssignments.size() > 0) || addressAssignments.size() == 0 )  
                createOpportunityAndServiceAppointment(req, abf, ac, urlStringsMap, zoneST, reqBody, responseMap, addr );        
            
            // EBS Full Load Callout
            System.enqueueJob(new EBSFullLoad(ac.Id, sessionId ));
            
        }catch(Exception ex){   
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTRTA','doEverything',reqBody,ex,'Integration')); 
        }
        
    }
    
    public static Request makePrettyRequestForNullValues(Request req)
    {
        // Make efficient Request Attributes by checking null values 
        req.firstname = String.isBlank(req.firstname) ? '' : req.firstname ;
        req.lastname = String.isBlank(req.lastname) ? '' : req.lastname ;
        req.address = String.isBlank(req.address) ? '' : req.address ;
        req.country = String.isBlank(req.country) ? '' : req.country ;
        if(req.country.length() == 3) req.country = req.country.left(2);
        req.city = String.isBlank(req.city) ? '' : req.city ;
        req.state = String.isBlank(req.state) ? '' : req.state ;
        if(req.state.length() == 3) req.state = req.state.left(2);
        req.zip = String.isBlank(req.zip) ? '' : req.zip ;
        req.dayphone = String.isBlank(req.dayphone) ? '' : req.dayphone ;
        req.phonetype = String.isBlank(req.phonetype) ? '' : req.phonetype ;
        req.email = String.isBlank(req.email) ? '' : req.email ;
        req.urlstring = String.isBlank(req.urlstring) ? '' : req.urlstring ;
        req.apptsource = String.isBlank(req.apptsource) ? '' : req.apptsource ;
        req.comments = String.isBlank(req.comments) ? '' : req.comments ;
        req.destination = String.isBlank(req.destination) ? '' : req.destination ;
        req.start = String.isBlank(req.start) ? '' : req.start ;
        req.end_z = String.isBlank(req.end_z) ? '' : req.end_z ;
        req.resource = String.isBlank(req.resource) ? '' : req.resource ;
        req.notifyemail = String.isBlank(req.notifyemail) ? 'N' : req.notifyemail ;
        req.consentcall = String.isBlank(req.consentcall) ? 'N' : req.consentcall ;
        req.consentsms = String.isBlank(req.consentsms) ? 'N' : req.consentsms ;
        req.consenttophone = String.isBlank(req.consenttophone) ? 'N' : req.consenttophone ;
        req.consenttomail = String.isBlank(req.consenttomail) ? 'N' : req.consenttomail ;
        req.apptreqtype = String.isBlank(req.apptreqtype) ? '' : req.apptreqtype ;
        req.appttype = String.isBlank(req.appttype) ? '' : req.appttype ;
        req.storename = String.isBlank(req.storename) ? '' : req.storename ;
        req.callerId = String.isBlank(req.callerId) ? '' : req.callerId ;
        req.callcenteruid = String.isBlank(req.callcenteruid) ? '' : req.callcenteruid ;
        req.virtualapptmt = req.virtualapptmt == true ? true : false ;
        
        return req ;
    }
    
    public static String getBranchInfo(String branchId )
    {
        List<Branch__c> branches = [SELECT Id FROM Branch__c WHERE Branch_Number__c = :branchId];
        Branch__c branch = new Branch__c();
        if(branches.size() > 0) branch.Id = branches[0].Id ;
        
        return branch.Id ;
    }
    
    public static Account createUpdateCustomerAccount(Request req, ServiceTerritory zoneST, String reqBody)
    {
        // Get Person Account Record Type ID
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        // Create Account 
        Account ac = new Account(   RecordTypeId = personAccountRTId, FirstName = req.firstname, LastName = req.lastname, 
                                 PersonHasOptedOutOfEmail = req.notifyemail == 'Y' || req.apptsource.equalsIgnoreCase('Call Center')? false : true, Account_Status__c = 'Active',
                                 PersonAutoCall__c = req.consentcall == 'N' ? true : false, PersonDoNotCall = req.consenttophone == 'N' ? true : false, 
                                 Text_Opt_Out__c = req.consentsms == 'N' ? true : false, Mail_Opt_Out__c = req.consenttomail == 'Y' || req.apptsource.equalsIgnoreCase('Call Center')? false : true, 
                                 PersonMailingStreet = req.address, PersonMailingCity = req.city, PersonMailingCountry = req.country, 
                                 PersonMailingState = req.state, PersonMailingPostalCode = req.zip, Type = 'Homeowner',
                                 PersonAssistantPhone = req.evephone, Evening_Phone_Type__c = req.evephonetype, Branch_Number__c = req.branchId  );
        //Added on 19/10/2020 to resolve wizard validation issue
        ac.Is_From_Custom_UI__c = true;
        if(String.isNotBlank(req.email)) ac.PersonEmail = req.email ;
        
        // Fill Account Phone fields based on PhoneType 
        Map<String,String> phonetypeToAccountField = new Map<String,String>{'home' => 'PersonHomePhone', 'mobile' =>'PersonMobilePhone', 'work' => 'PersonOtherPhone'};
            
            if(phonetypeToAccountField.containsKey(req.phonetype.toLowerCase()) && String.isNotBlank(req.dayphone)) 
            ac.put(phonetypeToAccountField.get(req.phonetype.toLowerCase()), req.dayphone);
        
        Boolean isPhoneFound = false; 
        if(String.isNotBlank(ac.PersonHomePhone) && !isPhoneFound ) 
        { ac.Phone = ServiceUtil.formatPhone(ac.PersonHomePhone); isPhoneFound = true; 
        } 
        if(String.isNotBlank(ac.PersonMobilePhone) && !isPhoneFound ) 
        { ac.Phone = ServiceUtil.formatPhone(ac.PersonMobilePhone); isPhoneFound = true; } 
        if(String.isNotBlank(ac.PersonOtherPhone) && !isPhoneFound ) { ac.Phone = ServiceUtil.formatPhone(ac.PersonOtherPhone); isPhoneFound = true; }   
        if(String.isNotBlank(ac.PersonAssistantPhone) && !isPhoneFound ) { ac.Phone = ServiceUtil.formatPhone(ac.PersonAssistantPhone); isPhoneFound = true; }    
        
        // Assign Owner from Zone Territory 
        if(zoneST != null && String.isNotBlank(zoneST.Lead_Receiver__c)) ac.OwnerId = zoneST.Lead_Receiver__c ;
        
        // Insert Account and Check Duplicate for records
        System.debug('UAC: Inserting Account' + ac );
        
        AccountTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
        
        // Updates : 04/02/2020 - Mayank 
        // If Duplicate records found based on Fuzzy match then compare exact match of inserting account's Phone fields with duplicate Records Phones fields 
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = false;
        dml.DuplicateRuleHeader.runAsCurrentUser = false ; 
        Database.SaveResult saveResult = Database.insert(ac, dml);
        List<SObject> duplicateRecords = checkDuplicates(saveResult, reqBody);
        System.debug('UAC: duplicateRecords ' + duplicateRecords.size() );
        Boolean isExactPhoneMatchFound = false ;
        System.debug('ac ' + ac.Id); 
        if(duplicateRecords.size() > 0 ) 
        {
            Set<String> phoneFields = new Set<String>{'PersonHomePhone', 'PersonMobilePhone', 'PersonOtherPhone', 'PersonAssistantPhone'};
                Integer i = 1 ;
            // Iterate over duplicate accounts 
            for(Account dup : [SELECT PersonHomePhone, PersonMobilePhone, PersonOtherPhone, PersonAssistantPhone FROM Account WHERE ID IN :duplicateRecords] )
            {
                System.debug('UAC: duplicate Account ' + i );
                i++;
                // Iterate over inserting Account's Phone fields 
                for(String acFF : phoneFields)
                {
                    // Iterate over duplicate account's phone fields 
                    for(String dupFF : phoneFields)
                    {
                        System.debug('UAC: original Account ' + acFF + ' ' + ac.get(acFF) + ' Duplicate Account ' + dupFF + ' ' + dup.get(dupFF) );
                        
                        // if inserting Account phone exactly match with duplicate found account then use duplicate account Id
                        if(ac.get(acFF) != null && dup.get(dupFF) != null && ServiceUtil.formatPhone((String)ac.get(acFF)) == ServiceUtil.formatPhone((String)dup.get(dupFF)))
                        {
                            System.debug('Phone Match Found ');
                            ac.Id = dup.Id ;
                            isExactPhoneMatchFound = true ;
                            break ;
                        }
                    }
                    if(isExactPhoneMatchFound) break;
                }
                if(isExactPhoneMatchFound) break;
            }
            
            // If unable to find exact match based on phone number then pick any account Id 
            if(!isExactPhoneMatchFound) ac.Id = duplicateRecords[0].Id ;
        } else
        {
            // Check exact phone numbers logic 
            String searchPhone;
            if(String.isNotBlank(ac.phone))
                searchPhone += '(' + ServiceUtil.addSoslWildcards(ServiceUtil.formatPhone(ac.phone)) + ')';
            if(String.isNotBlank(ac.PersonAssistantPhone)){
                searchPhone += ' OR ';  
                searchPhone += '(' + ServiceUtil.addSoslWildcards(ServiceUtil.formatPhone(ac.PersonAssistantPhone)) + ')';
            }
            System.debug('searchPhone ' + searchPhone); 
            if(String.isNotBlank(searchPhone)){
            Account [] result = (List<Account>)[FIND :searchPhone IN Phone FIELDS RETURNING Account (Id, FirstName, LastName, PersonEmail, recordtype.name)][0];
            if(result.size() > 0){
                System.debug('Id ' + result[0].Id); 
                if(result[0].recordtype.name.equalsIgnoreCase('Person Account') && (result[0].FirstName.containsIgnoreCase(ac.FirstName) || result[0].LastName.containsIgnoreCase(ac.LastName) ||  (String.isNotBlank(result[0].PersonEmail) && result[0].PersonEmail.equalsIgnoreCase(ac.PersonEmail)))  )
                    ac.Id = result[0].Id ;
            }
           }
        } 
        
        // Update existing account with latest information of JSON 
        if(ac.Id != null) 
        {
            Database.DMLOptions dmll = new Database.DMLOptions();
            dmll.DuplicateRuleHeader.allowSave = true;
            dmll.DuplicateRuleHeader.runAsCurrentUser = true; 
            Database.update(ac, dmll) ;
        }
        return ac ;
    }
    
    public static Address__c createUpdateAddress(Request req, ServiceTerritory zoneST, String reqBody)
    {
        // Insert Address and check for duplicate records
        List<SObject> duplicateRecords = new List<SObject>();
        System.debug('UAC: Inserting Address ' );
        Address__c addr = new Address__c(Street__c = req.address, City__c = req.city, State__c = req.state, Zipcode__c = req.zip, Country__c = req.country );
        addr.Street__c = req.address ;
        
        if(req.appttype.equalsIgnoreCase('RT') && req.apptsource.equalsIgnoreCase('Call Center'))
        {
            addr.Street__c = req.address + ' ' + req.address2 ;
            // Added to resolve Duplicate Opportunity Issue
            if(addr.Street__c!=null)addr.Street__c=addr.Street__c.trim();
        }
        
        // Assign Owner from Zone Territory 
        if(zoneST != null && String.isNotBlank(zoneST.Lead_Receiver__c)) addr.OwnerId = zoneST.Lead_Receiver__c ;
        
        AddressTriggerHandler.RUN_EBS_CALLOUT = false ;
        Database.SaveResult addSaveResult = Database.insert(addr, false);
        duplicateRecords = checkDuplicates(addSaveResult, reqBody);
        if(duplicateRecords.size() > 0 ) 
        {
            addr.Id = duplicateRecords[0].Id ;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            Database.update(addr, dml) ;
        }
        // update addr ;
        return addr ;
    }
    
    public static Account_Branch_Profile__c createUpdateAccountBranchProfile(String branchId, String accountId )
    {
        // Get Account Branch Profile related to Account and Branch
        List<Account_Branch_Profile__c> accountBranchProfiles = [SELECT Id FROM Account_Branch_Profile__c WHERE Branch__c = :branchId AND Party_Account__c = :accountId FOR UPDATE ];
        Account_Branch_Profile__c abf = new Account_Branch_Profile__c(Party_Account__c = accountId, Branch__c = branchId);
        if(accountBranchProfiles.size() > 0 ) abf.Id = accountBranchProfiles[0].Id ;
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        
        if(abf.Id == null) Database.insert(abf, dml) ;
        if(abf.Id != null) Database.update(abf, dml) ; 
        
        return abf ;
    }
    
    public static List<Address_Assignment__c> createAddressAssignment(String addrId, String accountBranchProfileId, ServiceTerritory zoneST )
    {
        System.debug('UAC: addrId ' + addrId + ' accountBranchProfileId ' + accountBranchProfileId);
        List<Address_Assignment__c> addressAssignments = new List<Address_Assignment__c>();
        if(addrId != null)
        {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            // Get Address Assingment Type of (Bill To) for Account and AccountBranchProfile, if doesn't exists then create new one 
            List<Address_Assignment__c> existingBillToAssignments = [   SELECT Id FROM Address_Assignment__c 
                                                                     WHERE Address__c = :addrId AND Account_Branch_Profile__c = :accountBranchProfileId AND Address_Usage_Type__c = 'Bill To'];
            
            //System.debug('UAC: existingBillToAssignments ' + existingBillToAssignments );
            
            Address_Assignment__c addrAssignmentBillTo = new Address_Assignment__c( Account_Branch_Profile__c = accountBranchProfileId, Address__c = addrId, Status__c = 'Active',
                                                                                   Identifying_Address__c = TRUE, Address_Usage_Type__c = 'Bill To' , Primary_Flag__c = TRUE );
            if(existingBillToAssignments.size() > 0) 
            {
                addrAssignmentBillTo.Id = existingBillToAssignments[0].Id ;
                AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                Database.update(addrAssignmentBillTo, dml) ;
                addrAssignIdToTriggerMode.put(addrAssignmentBillTo.Id, 'Update');
            }
            
            if(addrAssignmentBillTo.Id == null) 
            {
                AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                Database.insert(addrAssignmentBillTo,dml) ;
                addrAssignIdToTriggerMode.put(addrAssignmentBillTo.Id, 'Insert');
            }
            addressAssignments.add(addrAssignmentBillTo);
            
            // Get Address Assingment Type of (Ship To) for Account and AccountBranchProfile, if doesn't exists then create new one 
            List<Address_Assignment__c> existingShipToAssignments = [    SELECT Id FROM Address_Assignment__c 
                                                                     WHERE Address__c = :addrId AND Account_Branch_Profile__c = :accountBranchProfileId AND Address_Usage_Type__c = 'Ship To'];
            
            //System.debug('UAC: existingShipToAssignments ' + existingShipToAssignments );
            Address_Assignment__c addrAssignmentShipTo = new Address_Assignment__c( Account_Branch_Profile__c = accountBranchProfileId, Address__c = addrId, 
                                                                                   Address_Usage_Type__c = 'Ship To' , Primary_Flag__c = TRUE, Status__c = 'Active');
            if(existingShipToAssignments.size() > 0) 
            {
                addrAssignmentShipTo.Id = existingShipToAssignments[0].Id ;
                AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                Database.update(addrAssignmentShipTo, dml) ;
                addrAssignIdToTriggerMode.put(addrAssignmentShipTo.Id, 'Update');
            }
            
            if(addrAssignmentShipTo.Id == null) 
            {
                AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                Database.insert(addrAssignmentShipTo, dml) ;
                addrAssignIdToTriggerMode.put(addrAssignmentShipTo.Id, 'Insert');
            }
            addressAssignments.add(addrAssignmentShipTo);
            
            
            // Get Address Assingment Type of (Install At) for Account and AccountBranchProfile, if doesn't exists then create new one 
            List<Address_Assignment__c> existingInstallAtAssignments = [SELECT Id FROM Address_Assignment__c 
                                                                        WHERE Address__c = :addrId AND Account_Branch_Profile__c = :accountBranchProfileId AND Address_Usage_Type__c = 'Install At'];
            
            //System.debug('UAC: existingInstallAtAssignments ' + existingInstallAtAssignments );
            Address_Assignment__c addrAssignmentInstallAt = new Address_Assignment__c(  Account_Branch_Profile__c = accountBranchProfileId, Address__c = addrId, 
                                                                                      Address_Usage_Type__c = 'Install At' , Primary_Flag__c = TRUE, Status__c = 'Active');
            
            if(existingInstallAtAssignments.size() > 0) 
            {
                addrAssignmentInstallAt.Id = existingInstallAtAssignments[0].Id ;
                AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                Database.update(addrAssignmentInstallAt, dml) ;
                addrAssignIdToTriggerMode.put(addrAssignmentInstallAt.Id, 'Update');
            }
            
            if(addrAssignmentInstallAt.Id == null) 
            {
                AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                Database.insert(addrAssignmentInstallAt,dml) ;
                addrAssignIdToTriggerMode.put(addrAssignmentInstallAt.Id, 'Insert');
            }
            addressAssignments.add(addrAssignmentInstallAt);
            
        }
        
        return addressAssignments ;
    }
    
    public static Lead createLead(Request req, Map<String,String> urlStringsMap, String opprtunityId, Datetime startDate, DateTime endDate, ServiceTerritory zoneST )
    {
        List<String> urlStrings = parseURLStrings(req.urlstring);
        
        Map<String,String> phonetypeToLeadField = new Map<String,String>{'home' => 'HomePhone__c', 'mobile' =>'MobilePhone', 'work' => 'Phone'};
            DateTime startLeadDateEmail ; 
        DateTime endLeadDateEmail ;
        
        // Create Lead and attach it to existing Open Opportunity
        Lead ld = new Lead( FirstName = req.firstname, LastName = req.lastname, Email = req.email, Phone = req.dayphone, Opportunity__c = opprtunityId,
                           Street = req.address, City = req.city, Country = req.country, State = req.state, PostalCode = req.zip,
                           Urlstring__c = req.urlstring, Description = req.comments, Scheduled_Start__c = startDate, Scheduled_End__c = endDate,
                           HasOptedOutOfEmail = req.notifyemail == 'N' ? true : false, PersonAutoCall__c = req.consentcall == 'N' ? true : false,
                           DoNotCall = req.consenttophone == 'N' ? true : false, PersonHasOptedOutofMail__c = req.consenttomail == 'N' ? true : false, 
                           Text_Opt_Out__c = req.consentsms == 'N' ? true : false, LeadSource = req.apptsource, Appointment_Type__c = req.appttype,
                           No_of_Windows__c = req.noOfWindows, No_of_Doors__c = req.noOfDoors, CallerId__c = req.callerId, Callcenteruid__c = req.callcenteruid,
                           AsstPhone__c = req.evephone, Evening_Phone_Type__c = req.evephonetype, Opportunity_No__c = req.oppNo,
                           Showroom_Request_Type__c = req.showroomreqtype, How_did_you_hear_about_Pella__c = req.leadsource, 
                           Company = req.firstname + ' ' + req.lastname, Status = 'Qualified', Virtual_Appointment__c = req.virtualapptmt );
        
        // For web RTA appointments, if there is no campaign information sent from pella.com, the lead should be associated with a catch campaign id 
        if(ld.Pel_campaign_code__c == NULL && ld.LeadSource == 'Web')
        {
            List<Campaign> lstcampaign = [SELECT Id FROM Campaign WHERE Source_Code__c = 'PEL617021947'];
            if (lstcampaign.size()>0) {
                ld.Campaign__c = lstCampaign[0].Id;
                ld.Pel_campaign_code__c = 'PEL617021947';
            }
        }
        
        if(zoneST != null ) 
        {
            ld.Zone__c = zoneST.Id ;
            ld.Branch__c = zoneST.ParentTerritory.Branch__c ;
        }
        
        if(String.isNotBlank(req.start)) startLeadDateEmail = DateTime.valueOf(req.start.replace('T', ' ').replace('Z', '')) ;
        if(String.isNotBlank(req.end_z)) endLeadDateEmail = DateTime.valueOf(req.end_z.replace('T', ' ').replace('Z', '')) ;
        ld.Appointment_DateTime_Email__c = startLeadDateEmail;
        if(phonetypeToLeadField.containsKey(req.phonetype.toLowerCase())) ld.put(phonetypeToLeadField.get(req.phonetype.toLowerCase()), req.dayphone);
        // Iterate over JSON fields and values, and update Opportunity fields if field name found in FieldsMap
        for(String str : urlStrings)
        {
            String fieldName = str.left(str.indexOf(':'));
            //System.debug('UAC: fieldName ' + fieldName );
            
            String fieldValue = str.substring(str.indexOf(':')+1); 
            //System.debug('UAC: fieldValue ' + fieldValue );
            
            if(urlStringsMap.containsKey(fieldName)) ld.put(urlStringsMap.get(fieldName), fieldValue);  
            
        }
        
        // Assign Owner from Zone Territory 
        if(zoneST != null && String.isNotBlank(zoneST.Lead_Receiver__c)) ld.OwnerId = zoneST.Lead_Receiver__c ;
        
        if(req.apptsource == 'Call Center')
        {
            ld.LeadSource_RTA__c = req.leadsource ;
        }
        
        if(String.isNotBlank(req.marketingsource))
        {
            List<Campaign> campaigns = [SELECT Id, Source_Code__c FROM Campaign WHERE Id = :req.marketingsource AND Status = 'Active' ];
            if(campaigns.size() > 0) {
                ld.Campaign__c = campaigns[0].Id;
                ld.Pel_campaign_code__c = campaigns[0].Source_Code__c;
            }
        }
        
        // Find matching Campaign based on Lead.Pel_campaign_code__c and populate on Lead 
        if( ld.LeadSource == 'Web' && String.isNotBlank(ld.Pel_campaign_code__c))
        {
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Source_Code__c = :ld.Pel_campaign_code__c AND Status = 'Active' ];
            if(campaigns.size() > 0) ld.Campaign__c = campaigns[0].Id ;
        }
        
        if( ld.LeadSource == 'Call Center' && String.isNotBlank(ld.LeadSource_RTA__c))
        {
            Decimal rtaLeadSource = Decimal.valueOf(ld.LeadSource_RTA__c);
            List<Campaign> campaigns = [SELECT Id,Source_Code__c FROM Campaign WHERE Toll_Free_Number__c = :rtaLeadSource AND Status = 'Active' ];
            if(campaigns.size() > 0) {
                ld.Campaign__c = campaigns[0].Id;
                ld.Pel_campaign_code__c = campaigns[0].Source_Code__c;
            }
        }
        
        return ld ;
    }
    
    public static List<String> parseURLStrings(String strr)
    {
        
        // Get long URLString attribute from JSON
        List<String> urlStrings = new List<String>();
        if(String.isBlank(strr)){
            return urlStrings;
        }
        // Iterate over JSON string and get JSON fields names and values from single string, and put into list 
        do{
            String fieldName = strr.left(strr.indexOf('^^'));
            //System.debug('UAC: fieldName ' + fieldName );
            strr = strr.subString(strr.indexOf('^^')+2);
            
            urlStrings.add(fieldName);
            
            //System.debug('UAC: strr' + strr);
            if(strr.indexOf('^^') <= 0) urlStrings.add(strr);
        }
        while(strr.indexOf('^^') > 0);
        
        //System.debug('UAC: urlStrings ' + urlStrings );
        return urlStrings ;
    }
    
    public static void createOpportunityAndServiceAppointment(Request req, Account_Branch_Profile__c abf, Account ac, Map<String,String> urlStringsMap, ServiceTerritory zoneST, String reqBody, Map<String,Object> responseMap, address__c addr )
    {
        
        // Get long URLString attribute from JSON
        List<String> urlStrings = parseURLStrings(req.urlstring);
        //System.debug('UAC: urlStrings ' + urlStrings );
        
        // Make start date and end date
        DateTime startDate ;
        DateTime startDateEmail ;
        DateTime endDate ;
        DateTime nextDay12AM ;
        if(String.isNotBlank(req.start)) startDate = DateTime.valueOf(req.start.replace('T', ' ').replace('Z', '')) ;
        if(String.isNotBlank(req.end_z)) endDate = DateTime.valueOf(req.end_z.replace('T', ' ').replace('Z', '')) ;
        startDateEmail = startDate;
        System.debug('UAC: startDate ' + startDate );
        System.debug('UAC: endDate ' + endDate );
        
        if(startDate != null ) nextDay12AM = Datetime.newInstance(startDate.addDays(1).date() , Time.newInstance(0, 0, 0, 0) );
        System.debug('UAC: nextDay12AM ' + nextDay12AM );
        
        // change timezone before save
        //System.debug('UAC: req.TimeZone_Code ' + req.TimeZone_Code );
        if(!String.isBlank(req.TimeZone_Code) && startDate != null ){
            TimeZone tz = TimeZone.getTimeZone(req.TimeZone_Code);
            System.debug('UAC: tz ' + tz );
            startDate=startDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
            endDate=endDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
            nextDay12AM=nextDay12AM.addSeconds((tz.getOffset(startDate)/1000)*-1);
        }
        System.debug('UAC: startDate aftertimezone ' + startDate );
        System.debug('UAC: endDate aftertimezone ' + endDate );
        
        // Prepare Opportunity Name 
        String oppName = req.firstname + ' ' + req.lastname + ' - ' + req.address + ', ' + req.city + ', ' + req.state + ', ' + + req.country + ' ' + req.zip ;
        String Description = req.comments;
        //Rekha(07/14): Add Site address to opportunity, to allow creation of multiple oppportunity for 1 customer
        
        //Added on 27/10/2020
        Id OppRecTyId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        
        // Create Opportunity 
        Opportunity opp = new Opportunity(  Name = oppName, LeadSource = req.apptsource, Account_Branch_Profile__c = abf.Id, AccountId = ac.Id, 
                                          Description = req.comments , StageName = 'New', Type = 'FSL Sales Appointment', Opportunity_No__c = req.oppNo,
                                          Number_of_Windows__c = req.noOfWindows, Number_of_Doors__c = req.noOfDoors, Status__c = 'New',
                                          Phone_Number_Type_Email_Template__c = req.dayphone + ' (' + req.phonetype + ')', 
                                          Phone__c = req.dayphone, Email_Email_Template__c = req.email, 
                                          Appointment_Type__c = req.appttype, Appointment_DateTime__c = startDate, Appointment_DateTime_Email__c = startDateEmail,
                                          CallerId__c = req.callerId, Callcenteruid__c = req.callcenteruid, LeadSource_RTA__c = req.leadsource,
                                          Showroom_Request_Type__c = req.showroomreqtype, How_did_you_hear_about_Pella__c = req.leadsource, 
                                          Virtual_Appointment__c = req.virtualapptmt, siteaddress__c = addr.id, recordTypeId =OppRecTyId,cartadd__c = req.cartadd) ;
        
        
        // For web RTA appointments, if there is no campaign information sent from pella.com, the opps should be associated with a catch campaign id 
        if(opp.Pel_campaign_code__c == NULL && opp.LeadSource == 'Web')
        {
            List<Campaign> lstcampaign = [SELECT Id FROM Campaign WHERE Source_Code__c = 'PEL617021947'];
            if(lstcampaign.size() > 0) { 
                opp.CampaignId = lstcampaign[0].Id;
                opp.Pel_campaign_code__c = 'PEL617021947';
            }
        }
        
        if(endDate == null ) endDate = System.now(); 
        opp.CloseDate = endDate.date().addDays(49) ;
        
        // Iterate over JSON fields and values, and update Opportunity fields if field name found in FieldsMap
        for(String str : urlStrings)
        {
            String fieldName = str.left(str.indexOf(':'));
            //System.debug('UAC: fieldName ' + fieldName );
            
            String fieldValue = str.substring(str.indexOf(':')+1); 
            //System.debug('UAC: fieldValue ' + fieldValue );
            
            if(urlStringsMap.containsKey(fieldName)) opp.put(urlStringsMap.get(fieldName), fieldValue);  
        }
        
        if(zoneST != null) 
        {
            opp.Zone__c = zoneST.Id ;
            
            // Assign Owner from Zone Territory for All types (Call Center[RT,Preferred], Web[RT,Preferred], ShowRoom[RT,Preferred])
            if(String.isNotBlank(zoneST.Lead_Receiver__c)) 
                opp.OwnerId = zoneST.Lead_Receiver__c ;
        }
        
        if(String.isNotBlank(req.marketingsource) )
        {
            List<Campaign> campaigns = [SELECT Id, Source_Code__c FROM Campaign WHERE Id = :req.marketingsource AND Status = 'Active' ];
            if(campaigns.size() > 0) { 
                opp.CampaignId = campaigns[0].Id;
                opp.Pel_campaign_code__c = campaigns[0].Source_Code__c;
            }
        }
        
        // Find matching Campaign based on Opporutnity.Pel_campaign_code__c and populate on Opportunity 
        if( opp.LeadSource == 'Web' && String.isNotBlank(opp.Pel_campaign_code__c))
        {
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Source_Code__c = :opp.Pel_campaign_code__c AND Status = 'Active' ];
            if(campaigns.size() > 0) opp.CampaignId = campaigns[0].Id ;
        }
        
        if( opp.LeadSource == 'Call Center' && String.isNotBlank(opp.LeadSource_RTA__c))
        {
            Decimal rtaLeadSource = Decimal.valueOf(opp.LeadSource_RTA__c);
            List<Campaign> campaigns = [SELECT Id, Source_Code__c FROM Campaign WHERE Toll_Free_Number__c = :rtaLeadSource AND Status = 'Active' ];
            if(campaigns.size() > 0) { 
                opp.CampaignId = campaigns[0].Id;
                opp.Pel_campaign_code__c = campaigns[0].Source_Code__c;
            }
        }
        
        if(req.appttype.equalsIgnoreCase('Preferred') && zoneST != null)
        {
            DateTime currentTime = Datetime.now();
            Date todayDate = Date.today() ; 
            if(currentTime.hour() >= 4 ) todayDate.addDays(1);
            Datetime nextDay = DateTime.newinstanceGMT(todayDate.addDays(1), Time.newInstance(12, 0, 0, 0));
            System.debug('UAC: nextDay ' + nextDay );
            
            startDateEmail = nextDay ;
            opp.Appointment_DateTime_Email__c = startDateEmail;
            
            if(!String.isBlank(req.TimeZone_Code) )
            {   
                TimeZone tz = TimeZone.getTimeZone(req.TimeZone_Code);
                nextDay=nextDay.addSeconds((tz.getOffset(nextDay)/1000)*-1);
                if(nextDay12AM != null) nextDay12AM=nextDay12AM.addSeconds((tz.getOffset(nextDay12AM)/1000)*-1);
            }
            
            opp.Appointment_DateTime__c = nextDay ;
            
            nextDay12AM = nextDay.addDays(1);
            System.debug('UAC: Preferred nextDay12AM ' + nextDay12AM );
        }
        
        opp.Appointment_Next_Day_12AM__c = nextDay12AM ;
        
        // Insert Opportunity
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.insert(opp, dml) ;
        
        Id softAssignId = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('Soft_Assign').RecordTypeId;
        // Insert Service appointment under Opporutnity
        ServiceAppointment sa = new ServiceAppointment( RecordTypeId = softAssignId, Subject = oppName, City = req.city, State = req.state, PostalCode = req.zip,
                                                       ContactId = [SELECT PersonContactId FROM Account WHERE ID = :ac.Id FOR UPDATE ].PersonContactId,
                                                       Description = Description, Opportunity__c = opp.Id, DueDate = endDate, EarliestStartTime = startDate, 
                                                       SchedStartTime =startDate, Start_Datetime__c = startDate, End_Datetime__c = endDate, SchedEndTime = endDate,
                                                       Virtual_Appointment__c = req.virtualapptmt );
        
        
        if(req.appttype.equalsIgnoreCase('RT')) sa.Status = 'Soft Assigned' ;
        if(req.appttype.equalsIgnoreCase('Preferred'))
        {
            sa.Status = 'Preference' ;
            system.debug('Status of Sa :' + sa.status);
            
        }
        
        // Assign Owner Of Service Appointment for NON RT types(Preferred, NRT)
        if(zoneST != null && String.isNotBlank(zoneST.Lead_Receiver__c) && !req.appttype.equalsIgnoreCase('RT') ) sa.OwnerId = zoneST.Lead_Receiver__c ;
        
        if(req.appttype.equalsIgnoreCase('Preferred') && zoneST != null)
        {
            system.debug('It is a preference Appointment');
            Integer durationInMinutes = Integer.valueOf(zoneST.ApptDurationMin__c);
            if(durationInMinutes == null) durationInMinutes = 0 ;
            
            // Added on 02-06 virtual appointment change
            if(opp.Virtual_Appointment__c){
                durationInMinutes=zoneST.Virtual_Appt_Duration_Min__c==null?durationInMinutes:Integer.valueOf(zoneST.Virtual_Appt_Duration_Min__c);
            }
            
            Datetime nextDay = DateTime.newinstanceGMT(Date.today().addDays(1), Time.newInstance(12, 0, 0, 0));
            System.debug('UAC: nextDay ' + nextDay );
            
            startDateEmail = nextDay ;
            //opp.Appointment_DateTime_Email__c = startDateEmail;
            
            nextDay12AM = Datetime.newInstance(nextDay.addDays(1).date() , Time.newInstance(0, 0, 0, 0) );
            
            if(!String.isBlank(req.TimeZone_Code) && nextDay12AM != null ){
                TimeZone tz = TimeZone.getTimeZone(req.TimeZone_Code);
                nextDay12AM=nextDay12AM.addSeconds((tz.getOffset(nextDay12AM)/1000)*-1);
            }
            
            if(!String.isBlank(req.TimeZone_Code) )
            {   
                TimeZone tz = TimeZone.getTimeZone(req.TimeZone_Code);
                nextDay=nextDay.addSeconds((tz.getOffset(nextDay)/1000)*-1);
            }
            System.debug('UAC: nextDay ' + nextDay );
            sa.SchedStartTime = nextDay ;
            sa.Start_Datetime__c = nextDay;
            sa.EarliestStartTime = sa.SchedStartTime ;
            //opp.Appointment_DateTime__c = nextDay ;
            
            sa.SchedEndTime = sa.SchedStartTime.addMinutes(durationInMinutes);
            sa.End_Datetime__c = sa.SchedStartTime.addMinutes(durationInMinutes);
            sa.DueDate = sa.SchedEndTime ;
        }
        
        //List<Lead> leads = [SELECT Id FROM Lead WHERE NAME = 'Soft Assign Placeholder' FOR UPDATE ];
        
        //changed on 15-05 to resolve the issue of Unable to lock the row issue
        List<String> listSAPlaceLead=System.Label.Soft_Assign_Placeholder_Lead_ID.split(',');
        String leadSAId;
        try{
            leadSAId= listSAPlaceLead[Integer.valueOf( Math.random() * (listSAPlaceLead.size() - 1))];
        }catch(Exception e){
            leadSAId=listSAPlaceLead[0];
        }
        sa.ParentRecordId =leadSAId ; //System.Label.Soft_Assign_Placeholder_Lead_ID ; 
        system.debug('Parent Record Id is :'+ sa.ParentRecordId);   
        
        System.debug('UAC: sa to insert ' + sa );
        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = TRUE ;
        
        // change on 24-03 instead of insert to database.insert
        
        try{
            if(!Test.isRunningTest()) insert sa ;
            system.debug('SA Id :' +sa.Id);
        }
        catch(DmlException de){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostRTA','createOpportunityAndServiceAppointment',reqBody,de.getMessage(),'Integration'));
        }
        
        
        setBestMatch(ac.Id, opp.Id, null, sa.Id, req.address, req.address2, req.city, req.state, req.zip, req.country, req.start, reqBody, responseMap);
    }
    
    public static Map<String,Object> getHomeOwnerInfo(String address1, String address2, String city, String state, String postalCode)
    {
        // Get custom settings for credentials 
        List<Endpoint_Configuration__mdt> settings = [SELECT Endpoint__c, Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Estated_HomeOwner_YearBuilt'];
        if(settings.size() == 0) return null ; 
        Endpoint_Configuration__mdt cs = settings[0];
        
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cm = Metadata_Control__c.getInstance();
        if(cm != null && (cm.Disable_All__c || cm.Disable_Estated_Integration__c ) || String.isBlank(address1) || String.isBlank(city) || String.isBlank(state) || String.isBlank(postalCode) ) return responseMap ;
        
        // SAMPLE - https://apis.estated.com/v4/property?token=CuMbDbD3RFxRft7vs3s1dcdSmmaMnn&street_address=151 Battle Green Dr&city=Rochester&state=NY&zip_code=14624
        // Get HomeOwner name and YearBuilt for passing address - YEAR BUILT and HOME OWNER 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndpoint(    cs.Endpoint__c + '?token=' + cs.Token__c + 
                            '&street_address=' + EncodingUtil.urlEncode(address1, 'UTF-8') + 
                            '&city=' + EncodingUtil.urlEncode(city, 'UTF-8') + 
                            '&state=' + EncodingUtil.urlEncode(state, 'UTF-8') + 
                            '&zip_code=' + EncodingUtil.urlEncode(postalCode, 'UTF-8'));
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        //request.setHeader('apikey', 'bddf6ac5c78a34ddf752c825b6919166');
        //System.debug('request:'+ request);
        request.setTimeout(120000);
        if(!Test.isRunningTest()) response = http.send(request);
        if(Test.isRunningTest()) response.setBody('{"year_built":1989,"effective_year_built":1989,"stories":"2B","rooms_count":null,"owner":{"name":"NICHOLAS M BELLUCCIO","second_name":null,"unit_type":null}');
        System.debug('UAC: res body:'+ response.getbody());
        System.debug('UAC: estated response:'+ response);
        
        // Extract OwnerName and yearBuilt attributes from weird JSON 
        String orgStr = response.getBody();
        
        // Check for yearBuilt and HomeOwner attributes in JSON 
        if(orgStr.indexOf('year_built') > 0 && orgStr.indexOf('effective_year_built') > 0 && orgStr.indexOf('owner') > 0 && orgStr.indexOf('second_name') > 0)
        {
            String str = orgStr.subString(orgStr.indexOf('year_built')-1, orgStr.indexOf('effective_year_built')-1);
            System.debug('UAC: str year built ' + str );
            str += orgStr.subString(orgStr.indexOf('stories')-1, orgStr.lastIndexOf('rooms_count')-1);
            System.debug('UAC: stories ' + str );
            str += orgStr.subString(orgStr.indexOf('owner')+8, orgStr.lastIndexOf('second_name')-2);
            str = '{' + str + '}'; 
            System.debug('UAC: st ' + str );
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(str);
            System.debug('UAC: responseMap ' + responseMap );
        }
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostRTA','getHomeOwnerInfo',('Parameters: ' + address1 + ', ' + city + ' , ' + state + ' , ' + postalCode),ex,'Integration'));
        }
        return responseMap;
    }
    
    // THIS METHOD IS CALLED FROM SERVICE APPOINTMENT TRIGGER HANDLER 
    @future(callout=true)
    public static void setBestMatchFuture(String accountId, String orgOppId, String orgLeadId, String saId, String address1, String address2, String city, String state, String postalCode, String country, String strDate, String reqBody)
    {
        system.debug('Debug + setBestMatchFuture');
        Map<String,Object> responseMap = getHomeOwnerInfo(address1, address2, city, state, postalCode);
        
        setBestMatch(accountId, orgOppId, orgLeadId, saId, address1, address2, city, state, postalCode, country, strDate, reqBody, responseMap);
    }
    
    
    public static void setBestMatch(String accountId, String orgOppId, String orgLeadId, String saId, String address1, String address2, String city, String state, String postalCode, String country, String strDate, String reqBody, Map<String,Object> responseMap)
    {
        try{
            
            Account ac = String.isBlank(accountId) ? new Account() : [  SELECT PersonMailingStreet, PersonMailingCity, PersonMailingCountry, 
                                                                      PersonMailingState, PersonMailingPostalCode
                                                                      FROM Account WHERE Id = :accountId ];
                                                                          if(String.isBlank(accountId))
                                                                      {
                                                                          //EncodingUtil.urlEncode(ac.PersonMailingStreet, 'UTF-8') + '&address2=' + EncodingUtil.urlEncode(ac.PersonMailingCity + ' ' + ac.PersonMailingState + ' ' + postalCode, 'UTF-8'));
                                                                          ac.PersonMailingStreet = address1 ; 
                                                                          ac.PersonMailingCity = city ; 
                                                                          ac.PersonMailingCountry = country;
                                                                          ac.PersonMailingState = state ;
                                                                          ac.PersonMailingPostalCode = postalCode;
                                                                      }
            
            Opportunity orgOpp = String.isBlank(orgOppId) ? new Opportunity() :  [  SELECT Id, name, Number_of_Windows__c, Number_of_Doors__c, Best_Match__c, AccountId,
                                                                                  //Phone_Number_Type_Email_Template__c,
                                                                                  Phone__c, 
                                                                                  Zone__c, Appointment_Type__c, Zone__r.Lead_Receiver__c,Virtual_Appointment__c,
                                                                                  Email_Email_Template__c, Appointment_DateTime__c, Sales_Rep_Email_Template__c, OwnerId,
                                                                                  Other_Available_Email_Template__c, Past_Customer_of_Email_Template__c, Actual_Homeowner__c,
                                                                                  StageName, Status__c
                                                                                  FROM Opportunity WHERE ID = :orgOppId];
                                                                                      
                                                                                      Lead orgLead = String.isBlank(orgLeadId) ? new Lead() : [ SELECT Id, Best_Match__c, No_of_Windows__c FROM Lead WHERE ID = :orgLeadId ];
                                                                                          
                                                                                          Map<Integer,String> algorithmRanking = new Map<Integer,String>();
            List<String> resourceIds = new List<String>();
            Map<Id,ServiceResource> serviceResourceMap = new Map<Id,ServiceResource>();
            Set<Id> resourceUserIds = new Set<Id>();
            List<String> resourceIdsRankSorted = new List<String>();
            List<String> pastOppsOrLeadsOwnerIds = new List<String>();
            Map<String,Integer> resourceIdToAppointments = new Map<String,Integer>();
            Map<String,String> userIdToResourceId = new Map<String,String>();
            Id zipCodeParentServiceTerritoryId ;
            Boolean isResourcesFoundInGetCalendarAPI = TRUE ;
            
            //String strDate = '2019-11-29T14:00:00.000Z';
            DateTime startDate ;
            if(String.isNotBlank(strDate)) startDate = DateTime.valueOf(strDate.replace('T', ' ').replace('Z', '')) ;
            System.debug('UAC: startDate ' + startDate );
            
            //Use only first 5 digits of zip code if zip code lenght is greater than 5 
            if(postalCode.indexOf('-') > 0 && postalCode.length() > 5) postalCode = postalCode.left(5);
            
            // Get All Available Resources 
            RTAIntegration.ReponseWrapper res = (RTAIntegration.ReponseWrapper)JSON.deserialize(RTAIntegration.getTimeSlotDetails(postalCode,orgOpp.Virtual_Appointment__c), RTAIntegration.ReponseWrapper.class );
            System.debug('UAC: res ' + res );
            
            // Get Execution order from custom settings
            for(Algorithm_Execution_Order__mdt ao : [SELECT DeveloperName, Sort_Order__c FROM Algorithm_Execution_Order__mdt ORDER BY Sort_Order__c ])
            {
                algorithmRanking.put(Integer.valueOf(ao.Sort_Order__c), ao.DeveloperName);
            }
            System.debug('UAC: algorithmRanking ' + algorithmRanking );
            
            // When Resources found then put them into a list 
            if(res != null && res.timeslots != null && res.timeslots.size() > 0)
            {
                for(RTAIntegration.TimeSlots ts : res.timeslots)
                {
                    
                    if(ts.START_DATE == startDate)
                    {
                        resourceIds.addAll(ts.RESOURCE_ID);
                    }
                }
            }
            System.debug('UAC: resourceIds ' + resourceIds );
            
            String canadianZipcode= !postalCode.isNumeric() && postalCode.length() > 3 ? postalCode.substring(0,3) + '%' : '' ;
            
            List<ServiceTerritory> STRec=[  SELECT Id, ParentTerritoryId,ParentTerritory.ParentTerritoryId FROM ServiceTerritory 
                                          WHERE PostalCode != NULL AND (PostalCode=:postalCode OR PostalCode LIKE :canadianZipcode ) 
                                          AND RecordType.Name='Zipcode' ];
            if(STRec.size()>0) zipCodeParentServiceTerritoryId = STRec[0].ParentTerritoryId ;
            
            // Move this line outside if
            // Update Service Appointment Owner with Opporunity Best Match
            ServiceAppointment sa = [SELECT Id, OwnerId,Rehash_Appointment__c, SchedStartTime, SchedEndTime, ServiceTerritoryId, Status,rescheduled__C FROM ServiceAppointment WHERE Id = :saId];
            
            
            
            // When no Resources found then Get Resources from Zone Territory (Parent of zipcode territory)
            if(resourceIds.size() == 0)
            {
                isResourcesFoundInGetCalendarAPI = false ;
                for(ServiceTerritoryMember srm : [  SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId,
                                                  ServiceResource.In_home_Eligible__c,ServiceResource.Virtual_Eligible__c,
                                                  ServiceResource.Rehash_Eligible__c
                                                  FROM ServiceTerritoryMember 
                                                  WHERE ServiceTerritoryId = :zipCodeParentServiceTerritoryId 
                                                  AND ServiceResource.Replacement_Sales_Rep__c=true       //Rekha, copied Dhruv's changes                                             
                                                  AND ServiceResource.IsActive = TRUE AND ServiceResource.RelatedRecordId != NULL ])
                {
                    if((orgOpp.Virtual_Appointment__c && srm.ServiceResource.Virtual_Eligible__c) || (!orgOpp.Virtual_Appointment__c && srm.ServiceResource.In_home_Eligible__c))
                    {
                        if(orgOpp != null && orgOpp.Zone__c != null && srm.ServiceResource.RelatedRecordId != orgOpp.Zone__r.Lead_Receiver__c){
                            // Added on 24-06 For Rehash Appointment
                            if(sa.Rehash_Appointment__c){
                                if(srm.ServiceResource.Rehash_Eligible__c){
                                    resourceIds.add(srm.ServiceResourceId); 
                                }
                            }else{
                                resourceIds.add(srm.ServiceResourceId); 
                            }
                            
                        }
                    }
                }    
                
                try{
                    String zipCodeMainParentTerritory='';
                    if(STRec.size()>0) zipCodeMainParentTerritory = STRec[0].ParentTerritory.ParentTerritoryId ;
                    // Added on 22-07 Timeslot debug 
                    new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch',JSON.serialize([SELECT Id,Name, EndDate__c, Opportunity_No__c, StartDate__c, Zipcode__c, Zone__c,lastmodifieddate FROM RTA_Timeblock__c Where Zone__c=:zipCodeMainParentTerritory ]) , 'Resource Not Found in Calendar API' ,'Integration'));
                }catch(Exception ex1){}
            }
            System.debug('UAC: after resourceIds ' + resourceIds );
            
            //if(Test.isRunningTest()) for(ServiceResource sr : [SELECT Id FROM ServiceResource]) resourceIds.add(sr.Id);
            
            // Get Service Resources Information 
            for(ServiceResource sr : [SELECT Id, RelatedRecordId, RelatedRecord.Name, Maximum_Windows__c, Ranker__c, Oldest_Year_Built__c,Rehash_Eligible__c  FROM ServiceResource WHERE ID IN :resourceIds AND ServiceResource.IsActive = TRUE AND ServiceResource.RelatedRecordId != NULL ORDER BY Ranker__c ASC ])
            {
                // Added on 24-06 For Rehash Appointment
                if(sa.Rehash_Appointment__c){
                    if(!sr.Rehash_Eligible__c) continue;
                }
                if(sr.Oldest_Year_Built__c == null) sr.Oldest_Year_Built__c = '0' ;
                serviceResourceMap.put(sr.Id, sr);
                resourceUserIds.add(sr.RelatedRecordId);
                userIdToResourceId.put(sr.RelatedRecordId, sr.Id);
                resourceIdsRankSorted.add(sr.Id);
                resourceIdToAppointments.put(sr.Id, 0); // Set default 0
            }
            //System.debug('UAC: serviceResourceMap ' + serviceResourceMap );
            System.debug('UAC: userIdToResourceId ' + userIdToResourceId );
            
            // Get existing booked appointments for ServiceResources for current Appointment Start Date 
            Date appDate = startDate == null ? Date.newInstance(2050,1,1) : startDate.date();
            for(AggregateResult ar : [  SELECT Count(Id)Total, ServiceResourceId 
                                      FROM AssignedResource 
                                      WHERE ServiceResourceId IN :resourceIds AND DAY_ONLY(ServiceAppointment.SchedStartTime) = :appDate 
                                      GROUP BY ServiceResourceId ])
            {
                String resourceId = (String)ar.get('ServiceResourceId') ;
                resourceIdToAppointments.put( resourceId , resourceIdToAppointments.get(resourceId) +(Integer)ar.get('Total') );
            }
            //System.debug('UAC: resourceIdToAppointments ' + resourceIdToAppointments );
            
            Set<String> tempSet = new Set<String>();
            // Get Past Opportunities for ServiceResource.RelatedRecordId user
            for(Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE OwnerId IN :userIdToResourceId.keySet() AND AccountId = :accountId AND ID != :orgOppId ])
            {
                system.debug('Opp Owner :' + opp.OwnerId + 'opp userIdToResourceId value :' + userIdToResourceId + 'Account Id :' + accountid + 'orgOppId :' + orgOppId);
                tempSet.add(opp.OwnerId);
            }
            System.debug('UAC: pastOppsOrLeadsOwnerIds ' + tempSet );
            
            pastOppsOrLeadsOwnerIds.addAll(tempSet);
            
            Boolean isBestMatchFound = false ;
            
            System.debug('UAC: resourceIds BEFORE starting steps ' + resourceIds );
            
            // Set default value 
            orgOpp.Other_Available_Email_Template__c = 'None';
            
            // STEP 1 - When only 1 Resource available then assign it as Best Match 
            if(resourceIds.size() == 1)
            {
                System.debug('UAC: Best Match On Availability');
                isBestMatchFound = true ;
                orgOpp.Best_Match__c = serviceResourceMap.get(resourceIds[0]).RelatedRecordId  ;
                orgOpp.Sales_Rep_Email_Template__c = serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name + ' (' + resourceIdToAppointments.get(resourceIds[0]) + ')' ;
                orgOpp.Other_Available_Email_Template__c = 'None';
                orgLead.Best_Match__c = orgOpp.Best_Match__c ;
                new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match: ' + serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name , 'Best Match On Availability for ' + orgOpp.Name,'Integration'));
            }
            
            // Iterate over custom settings algorithm 
            for(Integer key : algorithmRanking.keySet())
            {
                // Get Source 
                String sourceToCheck = algorithmRanking.get(key);
                System.debug('UAC: sourceToCheck ' + sourceToCheck + ' for order ' + key  );
                
                List<Id> validResourceIds = new List<Id>();
                List<Id> otherResourceIds = new List<Id>();
                
                System.debug('UAC: Availability Best Match Found ' + isBestMatchFound );
                
                // STEP 2 - Assign BestMatch based on Past Opportunity Ownership 
                if(sourceToCheck == 'PastOwnership' && !isBestMatchFound )
                { 
                    otherResourceIds.addAll(resourceIds);
                    
                    for(Integer i = 0 ; i<pastOppsOrLeadsOwnerIds.size(); i++ )
                    {
                        Id userId = pastOppsOrLeadsOwnerIds[i];
                        
                        // Get matching service resource Id 
                        Id resourceId = userIdToResourceId.get(userId);
                        
                        // Get Service Resource details
                        ServiceResource sr = serviceResourceMap.get(resourceId);
                        
                        // When only 1 ServiceResource found for Past Opportunities then assign as Best match
                        if(pastOppsOrLeadsOwnerIds.size() == 1 )
                        {
                            System.debug('UAC: Past Opportunity Best Matched ');
                            isBestMatchFound = true ;
                            orgOpp.Best_Match__c = sr.RelatedRecordId ;
                            orgOpp.Sales_Rep_Email_Template__c = sr.RelatedRecord.Name + ' (' + resourceIdToAppointments.get(sr.Id) + ')' ;
                            orgLead.Best_Match__c = orgOpp.Best_Match__c ;
                            if(isResourcesFoundInGetCalendarAPI) orgOpp.Other_Available_Email_Template__c = filterOtherAvailableResources(otherResourceIds, resourceId, serviceResourceMap, resourceIdToAppointments);
                            new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match: ' + sr.RelatedRecord.Name , 'Best Match On Past Ownership for ' + orgOpp.Name ,'Integration'));
                            break ; 
                        }
                        
                        // If multiple resources have Past Opportunities then go for NEXT STEP -3 
                        if(pastOppsOrLeadsOwnerIds.size() > 1) validResourceIds.add(sr.Id);
                    }
                }
                
                // If no Valid resource found then put all original resource Ids into valid resources to go for Next STEP 
                if(validResourceIds.size() == 0) validResourceIds.addAll(resourceIds);
                otherResourceIds.addAll(resourceIds);
                //System.debug('UAC: resourceIds Opportunity resourceIds ' + resourceIds + ' validResourceIds ' + validResourceIds );
                
                // Kick out irrelvent resource Ids by comparing them with validResourceIds 
                resourceIds = kickOutInvalidResourceIds(resourceIds, validResourceIds);
                
                // if only one Resource remaining then assign it as best match 
                if(resourceIds.size() == 1  && !isBestMatchFound)
                {
                    System.debug('UAC: After Past Ownership Best Matched ');
                    isBestMatchFound = true ;
                    orgOpp.Best_Match__c = serviceResourceMap.get(resourceIds[0]).RelatedRecordId  ;
                    orgOpp.Sales_Rep_Email_Template__c = serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name + ' (' + resourceIdToAppointments.get(resourceIds[0]) + ')' ;
                    if(isResourcesFoundInGetCalendarAPI) orgOpp.Other_Available_Email_Template__c = filterOtherAvailableResources(otherResourceIds, resourceIds[0], serviceResourceMap, resourceIdToAppointments);
                    orgLead.Best_Match__c = orgOpp.Best_Match__c ;
                    new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match: ' + serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name , 'Best Match On after PastOwnership Only 1 Resource remaining for ' + orgOpp.Name ,'Integration'));
                    break ; 
                }
                
                //System.debug('UAC: resourceIds Opportunity after kick out resourceIds ' + resourceIds + ' validResourceIds ' + validResourceIds );
                
                //Reset valid resource Ids 
                validResourceIds = new List<Id>();
                otherResourceIds = new List<Id>();
                
                // STEP 3 - Match Service Resource Based on NoOfWindows 
                if(sourceToCheck == 'NoOfWindows' && !isBestMatchFound && ( orgOpp.Number_of_Windows__c != null || orgLead.No_of_Windows__c != null ) )
                {
                    // Iterate over all resourceIDs 
                    for(Integer i = 0 ; i<resourceIds.size(); i++ )
                    {
                        // Get resource details
                        ServiceResource sr = serviceResourceMap.get(resourceIds[i]);
                        
                        // If multiple resources mathced with criteria then add them into valid resource Ids 
                        if( (orgOpp.Number_of_Windows__c <= sr.Maximum_Windows__c && resourceIds.size() > 1)
                           || (orgLead.No_of_Windows__c <= sr.Maximum_Windows__c && resourceIds.size() > 1) )  validResourceIds.add(sr.Id);
                        
                        // if Only resource remaining in list then assign it as best match 
                        if( (orgOpp.Number_of_Windows__c <= sr.Maximum_Windows__c && resourceIds.size() == 1) 
                           || (orgLead.No_of_Windows__c <= sr.Maximum_Windows__c && resourceIds.size() == 1)  ) 
                        {
                            System.debug('UAC: NoOfWindows Best Matched****');
                            isBestMatchFound = true ;
                            orgOpp.Best_Match__c = sr.RelatedRecordId ;
                            orgOpp.Sales_Rep_Email_Template__c = sr.RelatedRecord.Name + ' (' + resourceIdToAppointments.get(sr.Id) + ')' ;
                            if(isResourcesFoundInGetCalendarAPI) orgOpp.Other_Available_Email_Template__c = filterOtherAvailableResources(otherResourceIds, resourceIds[0], serviceResourceMap, resourceIdToAppointments);
                            orgLead.Best_Match__c = orgOpp.Best_Match__c ;
                            new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match: ' + sr.RelatedRecord.Name, 'Best Match On NoOfWindows for ' + orgOpp.Name ,'Integration'));
                            break ;
                        }
                    }
                }
                // If no Valid resource found then put all original resource Ids into valid resources 
                if(validResourceIds.size() == 0) validResourceIds.addAll(resourceIds);
                otherResourceIds.addAll(resourceIds);
                //System.debug('UAC: resourceIds NoOfWindows resourceIds ' + resourceIds + ' validResourceIds ' + validResourceIds );
                
                // Kick out irrelvent resource Ids by comparing them with validResourceIds 
                resourceIds = kickOutInvalidResourceIds(resourceIds, validResourceIds);
                
                // if only one Resource remaining then assign it as best match 
                if(resourceIds.size() == 1  && !isBestMatchFound)
                {
                    System.debug('UAC: NoOfWindows Best Matched on 1 ****');
                    isBestMatchFound = true ;
                    orgOpp.Best_Match__c = serviceResourceMap.get(resourceIds[0]).RelatedRecordId ;
                    orgOpp.Sales_Rep_Email_Template__c = serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name + ' (' + resourceIdToAppointments.get(resourceIds[0]) + ')' ;
                    if(isResourcesFoundInGetCalendarAPI) orgOpp.Other_Available_Email_Template__c = filterOtherAvailableResources(otherResourceIds, resourceIds[0], serviceResourceMap, resourceIdToAppointments);
                    orgLead.Best_Match__c = orgOpp.Best_Match__c ;
                    new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match Id: ' + serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name, 'Best Match On NoOfWindows for ' + orgOpp.Name ,'Integration'));
                    break ; 
                }
                //System.debug('UAC: resourceIds NoOfWindows after kick out resourceIds ' + resourceIds + ' validResourceIds ' + validResourceIds );
                
                //Reset valid resource Ids 
                validResourceIds = new List<Id>();
                otherResourceIds = new List<Id>();
                
                // STEP 4 - Best match based on YearBuilt RealEstateAPI 
                if(sourceToCheck == 'RealEstateAPI' && !isBestMatchFound)
                {
                    for(Integer i = 0 ; i<resourceIds.size(); i++ )
                    {
                        ServiceResource sr = serviceResourceMap.get(resourceIds[i]);
                        if(responseMap.containsKey('year_built') && Integer.valueOf(sr.Oldest_Year_Built__c) <= (Integer)responseMap.get('year_built')) validResourceIds.add(sr.Id);
                        
                        if(responseMap.containsKey('year_built') && Integer.valueOf(sr.Oldest_Year_Built__c) <= (Integer)responseMap.get('year_built') && resourceIds.size() == 1)
                        {
                            System.debug('UAC: RealEstateAPI Best Matched ****');
                            isBestMatchFound = true ;
                            orgOpp.Best_Match__c = sr.RelatedRecordId ;
                            orgOpp.Sales_Rep_Email_Template__c = serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name + ' (' + resourceIdToAppointments.get(sr.Id) + ')' ;
                            if(isResourcesFoundInGetCalendarAPI) orgOpp.Other_Available_Email_Template__c = filterOtherAvailableResources(otherResourceIds, resourceIds[0], serviceResourceMap, resourceIdToAppointments);
                            orgLead.Best_Match__c = orgOpp.Id ;
                            new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match Id : ' + serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name, 'Best Match On YearBuilt for ' + orgOpp.Name ,'Integration'));
                            break ;
                        }
                    }
                }
                if(validResourceIds.size() == 0) validResourceIds.addAll(resourceIds);
                otherResourceIds.addAll(resourceIds);
                //System.debug('UAC: resourceIds API resourceIds ' + resourceIds + ' validResourceIds ' + validResourceIds );
                
                resourceIds = kickOutInvalidResourceIds(resourceIds, validResourceIds);
                if(resourceIds.size() == 1  && !isBestMatchFound)
                {
                    System.debug('UAC: API Best Matched on 1 ****');
                    isBestMatchFound = true ;
                    orgOpp.Best_Match__c = serviceResourceMap.get(resourceIds[0]).RelatedRecordId ;
                    orgOpp.Sales_Rep_Email_Template__c = serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name + ' (' + resourceIdToAppointments.get(resourceIds[0]) + ')' ;
                    if(isResourcesFoundInGetCalendarAPI) orgOpp.Other_Available_Email_Template__c = filterOtherAvailableResources(otherResourceIds, resourceIds[0], serviceResourceMap, resourceIdToAppointments);
                    orgLead.Best_Match__c = orgOpp.Best_Match__c ;
                    new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match Id : ' + serviceResourceMap.get(resourceIds[0]).RelatedRecord.Name, 'Best Match On YearBuilt for ' + orgOpp.Name ,'Integration'));
                    break ; 
                }
                
                //System.debug('UAC: resourceIds API after kick out resourceIds ' + resourceIds + ' validResourceIds ' + validResourceIds );
            }
            System.debug('UAC: isBestMatchFound ' + isBestMatchFound + ' orgOpp.Best_Match__c ' + orgOpp.Best_Match__c );
            
            if(resourceIdsRankSorted.size() > 0)
            {
                resourceIdsRankSorted = kickOutInvalidResourceIds(resourceIdsRankSorted, resourceIds);
                List<String> tempListIds = new List<String>();
                tempListIds.addAll(resourceIdsRankSorted);
                resourceIdsRankSorted.clear();
                for(ServiceResource sr : [SELECT Id FROM ServiceResource WHERE ID IN :tempListIds AND Ranker__c > 0 ORDER BY Ranker__c ASC ])
                {
                    resourceIdsRankSorted.add(sr.Id);
                }
            } 
            
            System.debug('UAC: resourceIdsRankSorted ' + resourceIdsRankSorted );
            
            // STEP 5 - Best match based on Ranking...
            if(!isBestMatchFound && resourceIdsRankSorted.size() > 0) 
            {
                isBestMatchFound = true ;
                orgOpp.Best_Match__c = serviceResourceMap.get(resourceIdsRankSorted[0]).RelatedRecordId ;
                orgOpp.Sales_Rep_Email_Template__c = serviceResourceMap.get(resourceIdsRankSorted[0]).RelatedRecord.Name + ' (' + resourceIdToAppointments.get(resourceIdsRankSorted[0]) + ')' ;
                if(isResourcesFoundInGetCalendarAPI) orgOpp.Other_Available_Email_Template__c = filterOtherAvailableResources(resourceIdsRankSorted, resourceIdsRankSorted[0], serviceResourceMap, resourceIdToAppointments);
                orgLead.Best_Match__c = orgOpp.Best_Match__c ;
                new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRTA','BestMatch','Best Match Id : ' + serviceResourceMap.get(resourceIdsRankSorted[0]).RelatedRecord.Name , 'Best Match On Ranking for ' + orgOpp.Name ,'Integration'));
                if(String.isBlank(orgOpp.Other_Available_Email_Template__c)) orgOpp.Other_Available_Email_Template__c = 'None' ;
            }
            
            if(!isBestMatchFound) new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTRTA','BestMatch','Unable to find best match : ResourceIds ' + String.join(resourceIds, ', ')  + ' RankedBasedResources ' + String.join(resourceIdsRankSorted, ', '), 'No Best Match Found for Opportunity ' + orgOppId + ' ServiceAppointment ' + saId  ,'Integration'));
            // Set YearBuilt 
            if(responseMap.containsKey('year_built')) 
            {
                orgOpp.Year_Home_Built__c = String.valueOf((Integer)responseMap.get('year_built'));
                orgLead.Year_Home_Built__c = orgOpp.Year_Home_Built__c;
            }
            
            // Set HomeOwner Name 
            if(responseMap.containsKey('name')) 
            {
                orgOpp.Actual_HomeOwner__c = (String)responseMap.get('name');
                orgLead.Homeowner_Name__c = orgOpp.Actual_Homeowner__c;
            }
            
            if(responseMap.containsKey('stories')) 
            {
                orgOpp.stories__C = (String)responseMap.get('stories');
                orgLead.stories__C = orgOpp.stories__C;
            }
            
            //if(responseMap.containsKey('lastName')) orgOpp.Actual_HomeOwner__c = (String.isBlank(orgOpp.Actual_HomeOwner__c) ? '' : orgOpp.Actual_HomeOwner__c + ' ' ) + (String)responseMap.get('lastName');
            
            // Get past Owners of current account 
            Set<Id> pastOwnerIds = new Set<Id>();
            for(Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE AccountId = :ac.Id AND Owner.IsActive = TRUE AND ID != :orgOppId ])
            {
                pastOwnerIds.add(opp.OwnerId);
            }
            System.debug('UAC: pastOwnerIds ' + pastOwnerIds );
            
            // Get List Of Assigned Resource Added on 27-04-20
            
            Map<String,Integer> resourceIdToAppDay=new Map<String,Integer>();
            for(AggregateResult ar : [  SELECT Count(Id)Total, ServiceResourceId 
                                      FROM AssignedResource 
                                      WHERE ServiceResource.RelatedRecordId IN :pastOwnerIds AND DAY_ONLY(ServiceAppointment.SchedStartTime) = :appDate 
                                      GROUP BY ServiceResourceId ])
            {
                String resourceId = (String)ar.get('ServiceResourceId') ;
                resourceIdToAppDay.put( resourceId , (Integer)ar.get('Total') );
            }
            // Get existing booked appointments for past owners of current account 
            for(ServiceResource SR : [  SELECT Id,RelatedRecord.Name 
                                      FROM ServiceResource 
                                      WHERE RelatedRecordId IN :pastOwnerIds])
            {
                Integer total = resourceIdToAppDay.containsKey(SR.Id) ? resourceIdToAppDay.get(SR.Id) : 0 ;
                if(orgOpp.Past_Customer_of_Email_Template__c == null) orgOpp.Past_Customer_of_Email_Template__c = '' ;
                
                // Changed on 27-04
                orgOpp.Past_Customer_of_Email_Template__c += SR.RelatedRecord.Name + ' (' + total + '), ' ;
                //if(serviceResourceMap.containsKey(resourceId)) orgOpp.Past_Customer_of_Email_Template__c += serviceResourceMap.get(resourceId).RelatedRecord.Name + ' (' + total + '), ' ;
            }
            
            // Remove last comma and white space
            if(String.isNotBlank(orgOpp.Past_Customer_of_Email_Template__c)) orgOpp.Past_Customer_of_Email_Template__c=orgOpp.Past_Customer_of_Email_Template__c.left(orgOpp.Past_Customer_of_Email_Template__c.length()-2);
            
            // When no past information found, put None in field
            if(String.isBlank(orgOpp.Past_Customer_of_Email_Template__c)) orgOpp.Past_Customer_of_Email_Template__c = 'None' ;
            System.debug('UAC: orgOpp ' + orgOpp );
            
            // Only for Opportunity's Service Appointment
            if(String.isnotBlank(orgOppId)) 
            {
                if((orgOpp.Appointment_Type__c == 'RT' || (orgOpp.Appointment_Type__c == 'Preferred' && sa.Rescheduled__c)) && orgOpp.Zone__r.Lead_Receiver__c != null && orgOpp.OwnerId != orgOpp.Zone__r.Lead_Receiver__c )
                {
                    orgOpp.OwnerId = orgOpp.Zone__r.Lead_Receiver__c ;
                    OpportunityTriggerHandler.RUN_TRIGGER = false;
                }
                update orgOpp ;
                System.debug('UAC: orgOpp after update ' + [SELECT Id, StageName, Status__c FROM Opportunity WHERE Id = :orgOpp.Id ] );
                
                System.debug('UAC: saID ' + saId + ' BestMatch ' + orgOpp.Best_Match__c + ' zipCodeParentServiceTerritoryId ' + zipCodeParentServiceTerritoryId);
                
                Id bestMatchId = orgOpp.Appointment_Type__c == 'RT' ? orgOpp.Best_Match__c : orgOpp.Zone__r.Lead_Receiver__c ; 
                //  Id bestMatchId = (orgOpp.Appointment_Type__c == 'RT' || orgOpp.Appointment_Type__c == 'Preferred' ) ? orgOpp.Best_Match__c : orgOpp.Zone__r.Lead_Receiver__c ; 
                system.debug('bestMatchId :'+ bestMatchId);
                if( ( Test.isRunningTest() || String.isNotBlank(saId) ) && String.isNotBlank(bestMatchId) && String.isNotBlank(zipCodeParentServiceTerritoryId))
                {   
                    
                    // For RT Types only change Owner as Best Match of Opportunity
                    if(orgOpp.Appointment_Type__c == 'RT' || (orgOpp.Appointment_Type__c == 'Preferred' && sa.Rescheduled__c) ) sa.OwnerId = orgOpp.Best_Match__c ;
                    sa.ServiceTerritoryId = orgOpp.Zone__c ;
                    
                    System.debug('UAC: orgOpp.Appointment_Type__c ' + orgOpp.Appointment_Type__c );
                    
                    ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ;
                    ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = false ;
                    AssignedResourceTriggerHandler.CHANGE_SA_OPP_STATUS_OWNER = false ;
                    ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = false ;
                    ServiceAppointmentTriggerHandler.Check_Conflict_Overriden = false ;
                    if(orgOpp.Appointment_Type__c == 'RT' || (orgOpp.Appointment_Type__c == 'Preferred' && sa.Rescheduled__c)) 
                    {
                        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = true ;
                        ServiceAppointmentTriggerHandler.DO_NOT_CHANGE_FOR_RT = true ;
                    }
                    System.debug('UAC: sa bestmatch to update ' + sa );
                    update sa; 
                }
                
            }
            if(String.isnotBlank(orgLeadId)) update orgLead ;
            
            
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostRTA','setBestMatch',('Parameters: ' + orgOppId + ', ' + postalCode + ', ' + strDate),ex,'Integration'));
        }
    }
    
    public static List<Id> kickOutInvalidResourceIds(List<Id> resourceIds, List<Id> validResourceIds)
    {
        List<Id> matchedResourceIds = new List<Id>();
        if(validResourceIds.size() > 0)
        {
            for(Id validResourceId : validResourceIds )
            {
                for(Integer i=0 ; i<resourceIds.size(); i++)
                {
                    if(validResourceId == resourceIds[i]) matchedResourceIds.add(validResourceId);
                }
            }
        }
        return matchedResourceIds;
    }
    
    public static String filterOtherAvailableResources(List<Id> resourceIds, Id matchedResourceId, Map<Id,ServiceResource> serviceResourceMap, Map<String,Integer> resourceIdToAppointments )
    {
        String otherResources = '';
        
        if(resourceIds.size() > 0)
        {
            for(Id resourceId : resourceIds )
            {
                if(resourceId != matchedResourceId) otherResources += serviceResourceMap.get(resourceId).RelatedRecord.Name + ' (' + resourceIdToAppointments.get(resourceId) + '), ' ;
            }
        }
        return otherResources.length() > 0 ? otherResources.left(otherResources.length()-2) : otherResources ;
    }
    
    public static List<SObject> checkDuplicates(Database.SaveResult saveResult, String reqBody)
    {
        List<SObject> duplicateRecords = new List<SObject>();
        if(!saveResult.isSuccess())
        {
            for(Database.Error error : saveResult.getErrors()) 
            {
                System.debug('UAC: save result not SUCCESS ' + error.getMessage()  );
                
                // If there are duplicates, an error occurs Process only duplicates and not other errors (e.g., validation errors)
                if(error instanceof Database.DuplicateError) 
                {
                    // Handle the duplicate error by first casting it as a DuplicateError class This lets you use methods of that class (e.g., getDuplicateResult())
                    Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    
                    // Return only match results of matching rules that find duplicate records
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                    
                    // Just grab first match result (which contains the duplicate record found and other match info)
                    Datacloud.MatchResult matchResult = matchResults[0];
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    
                    // Add matched record to the duplicate records variable
                    for(Datacloud.MatchRecord matchRecord : matchRecords) 
                    {
                        //System.debug('MatchRecord: ' + matchRecord.getRecord());
                        duplicateRecords.add(matchRecord.getRecord());
                    }
                }
                else
                {
                    System.debug('UAC: error message ' + error.getMessage() );
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTRTA','checkDuplicates', reqBody, error.getMessage(),null,'Integration'));
                    // res.errorMessage = error.getMessage() ;
                    // res.status = 'FAILED' ;
                    // res.httpStatusCode = '400' ;
                    // return res ;
                }
            }
        }
        
        System.debug('UAC: duplicateRecords ' + duplicateRecords );
        return duplicateRecords ;
    }
    
}