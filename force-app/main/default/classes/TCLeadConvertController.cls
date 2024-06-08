public class TCLeadConvertController {
    
    @AuraEnabled
    public static Map<String,String> getLeadStatus(String leadId) {
        Map<String,String> resultMap = new Map<String,String>();
        List<Lead> leadList = [SELECT Id, Name,Lead_Type__c,Company,FirstName,LastName,Email,Phone,Street,City, PostalCode,State, Status,Appointment_Type__c,Virtual_Appointment__c  FROM Lead WHERE Id =: leadId];
        if(leadList.size() > 0){
            for(Lead ld : leadList){
                // Added Lead Type condition on 12/11 , as lead type is mandatory on TC Lead Convert
                if(ld.Lead_Type__c ==null || String.isBlank(ld.Lead_Type__c)){
                    resultMap.put('Error',String.valueOf(System.Label.Lead_Type_Must_Be_Required));
                }else if(ld.Status == 'Qualified' ){
                    resultMap.put('Success','');
                }else{
                    resultMap.put('Error',String.valueOf(System.Label.Lead_Status_Not_Qualified));
                }
            }            
        }
        return resultMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> getPickListValues(){
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, List<PicklistEntryWrapper>> objResults = new Map<String, List<PicklistEntryWrapper>>();
        
        String ObjName = 'Opportunity';
        String controllingField = 'Type';
        String dependentField = 'Market_Segment__c';
        
        Schema.sObjectType objType = Opportunity.getSObjectType();
        system.debug('objType : '+objType);
        if (objType == null){
            return resultMap;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        system.debug('objFieldMap : '+objFieldMap);
        if(objFieldMap.containsKey('TC_Stages__c')){
            Schema.SObjectField stageName = objFieldMap.get('TC_Stages__c');
            List<Schema.PicklistEntry> stages = stageName.getDescribe().getPicklistValues();
            List<PicklistEntryWrapper> stgNames = wrapPicklistEntries(stageName.getDescribe().getPicklistValues());
            
            resultMap.put('Stage', stgNames);
        }
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return resultMap;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        system.debug('ctrlField : '+ctrlField);
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        system.debug('contrEntries : '+contrEntries);
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<PicklistEntryWrapper>());
            controllingValues.add(label);
            
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(plew);
                }
            }
        }
        resultMap.put('Type', objResults);
        return resultMap;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits; 
    }
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    @AuraEnabled
    public static Map<String,Object> getLeadDetails(String leadId) {
        Map<String,Object> returnMap = new Map<String,Object>();
        List<CreateAccountController.RTARequest> rtaList = new list<CreateAccountController.RTARequest>();
        List<Lead> leadList = [SELECT Id, Name,Lead_Type__c,Company,FirstName,LastName,Email,Phone, MobilePhone__c , Street, City, PostalCode,State, Status,Appointment_Type__c,Virtual_Appointment__c  FROM Lead WHERE Id =: leadId];
        if(leadList.size() > 0){
            for(Lead ld : leadList){
                if(ld.Status == 'Qualified'){
                    CreateAccountController.RTARequest rta = new CreateAccountController.RTARequest();
                    rta.CustomerType = ld.Lead_Type__c;
                    rta.OrganizationName = ld.Company;
                    rta.FirstName = ld.FirstName;
                    rta.LastName = ld.LastName;
                    rta.Email = ld.Email;
                    if(String.isNotBlank(ld.Phone)){
                        rta.Phone = ld.Phone;
                    }else if(String.isNotBlank(ld.MobilePhone__c )){
                        rta.Phone = ld.MobilePhone__c ;
                    }
                    rta.Address = ld.Street;
                    rta.City = ld.City;
                    rta.State =ld.State;
                    rta.Zipcode = ld.PostalCode;
                    
                    returnMap.put('isPersonType', (ld.Lead_Type__c!=null && ( ld.Lead_Type__c=='Homeowner' ||  ld.Lead_Type__c=='Employee')));
                    
                    User currentUser=[SELECT ID,Country,Title FROM User Where Id =:Userinfo.getUserId()];
                    returnMap.put('UserCountry',currentUser);
                    returnMap.put('isUserRoleNotAllow',(currentUser.Title!=null && Label.T_C_NotAllowUser!=null && Label.T_C_NotAllowUser.containsIgnoreCase(';'+currentUser.Title+';')));
                    
                    // get states picklist values
                    Map<String,String> USStates = new Map<String,String>();
                    Map<String,String> CANStates = new Map<String,String>();
                    Map<String,String> AccRanks = new Map<String,String>();
                    Schema.DescribeFieldResult fieldResult =Address__c.US_States__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry f : ple)
                    {
                        USStates.put(f.getValue(),f.getLabel());
                    }   
                    
                    fieldResult = Address__c.US_States__c.getDescribe();
                    ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry f : ple)
                    {
                        CANStates.put(f.getValue(),f.getLabel());
                    }
                    
                    //For Account Rank
                    Schema.DescribeFieldResult fieldResultRank = Account.Account_Rank__c.getDescribe();
                    List<Schema.PicklistEntry> pleRank = fieldResultRank.getPicklistValues();
                    Map<String,String> accRank = new Map<String,String>();
                    for(Schema.PicklistEntry f : pleRank){
                        accRank.put(f.getValue(),f.getLabel());
                    }
                    
                    returnMap.put('AccRanks',accRank);
                    returnMap.put('USStates',USStates);
                    returnMap.put('CANStates',CANStates);
                    
                    // Add CutomerType
                    fieldResult =Account.Type.getDescribe();
                    ple = fieldResult.getPicklistValues();
                    Map<String,String> options = new Map<String,String>();
                    for( Schema.PicklistEntry f : ple)
                    {
                        options.put(f.getValue(),f.getLabel());
                    }       
                    returnMap.put('CustomerType',options);
                    
                    returnMap.put('AccountSelection',JSON.serialize(rta));
                    
                    returnMap.put('ExistingAccounts',CreateAccountController.searchExistingAccounts(JSON.serialize(rta)));
                    returnMap.put('ExistingContact',duplicateContactList(rta.FirstName,rta.LastName,rta.Email,rta.Phone,null));
                    
                    returnMap.putAll(CreateAccountController.getBranchName());
                    
                }else{
                    returnMap.put('Error',String.valueOf(System.Label.Lead_Status_Not_Qualified));
                }
            }            
        }
        return returnMap;
    }
    
    
    @AuraEnabled
    public static String convertLead(String leadId,String requestData,String AdditionalAddress,String contactRec,String OpportunityRec) {
        
        
        // Create Account
        String accountId=CreateAccountController.createNewAccount(requestData,AdditionalAddress);
        
        
        // create contact
        String contactId;
        Contact con=(contact)JSON.deserialize(contactRec, contact.class);
        if(con.Id==null){
            con.accountId=accountId;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            Database.SaveResult saveResult = Database.insert(con, dml);
            
        }else{
            List<String> fields = new List<String>();
            fields.addAll(Contact.getsObjectType().getDescribe().fields.getMap().keySet());
            String soql = 'SELECT ' + String.join(fields, ',') +
                ' FROM Contact WHERE Id =\''+con.Id+'\'';
            List<Contact> listContact=Database.query(soql);
            if(listContact.size()>0){
                if(listContact[0].AccountId!=accountId){
                    Contact objConCopy = listContact[0].clone(false,false,false,false);
                    objConCopy.AccountId=accountId;
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.allowSave = true;
                    dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
                    Database.SaveResult saveResult = Database.insert(objConCopy, dml);
                }
            }
            /*AccountContactRelation ACR=new AccountContactRelation();
            ACR.AccountId=accountId;
            ACR.contactId=con.Id;
            database.insert(ACR,false);*/
        }
        contactId=con.Id;
        
        // create Opportunity
        String OpportnityId;
        if(OpportunityRec != null){
            Opportunity opp=(opportunity)JSON.deserialize(OpportunityRec, Opportunity.class);
            System.debug('OpportnityId : '+opp);
            System.debug('stage:'+ opp.StageName);
            opp.accountId=accountId;
           // System.debug('Account.partyid : '+ opp.accountid.mdmrecid__c);
           // 
            // To Check if existing account is selected
           CreateAccountController.RTARequest request=(CreateAccountController.RTARequest) JSON.deserialize(requestData, CreateAccountController.RTARequest.class);  
          
            If (opp.StageName == 'Proposal' && (request.ChildRecordId==null || request.ChildRecordId==''))
            {                         
                opp.QuoteShellDelayFlag__c=true;
            }
            opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            Database.SaveResult saveResult = Database.insert(opp, dml);
            Map<String,Object> resultMap = CreateAccountController.checkDuplicates(saveResult);
            
            if(resultMap.containsKey('ErrorMessage')){
                System.debug('@@Error : '+String.valueOf(resultMap.get('ErrorMessage')));
                throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
            }
            
            /*if(opp.Id==null){
                
            }else{
                Opportunity updateOpp=new Opportunity();
                updateOpp.Id=opp.Id;
                updateOpp.accountId=accountId;
                update updateOpp;
            }*/
            System.debug('OpportnityId1 : '+opp.Id);
            OpportnityId=opp.Id;
        }
        
        Lead leadObj=new lead();
        leadObj.Id=leadId;
        if(OpportunityRec != null){
            leadObj.ConvertedOpportunityId__c=OpportnityId;
        }
        if(String.isNotBlank(ContactId)){
            leadObj.Converted_Contact__c=ContactId;
        }
        
        leadObj.Converted_Account__c=AccountId;
        leadObj.Status = 'Converted';
        
        update leadObj;
        
        return accountId;
    }
    
    /**
*   @Method:        getProjectAddress
*   @Purpose:       Auto populate the address on the account search UI 
*/
    @AuraEnabled
    public static String getProjectAddress(String queryValue,Boolean isCanada){
        List<Endpoint_Configuration__mdt> searchMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Search_Address' ]; 
        if(searchMetaData.size()>0){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(searchMetaData[0].Endpoint__c+EncodingUtil.urlEncode(queryValue, 'UTF-8')+'&country='+(isCanada?'CAN':'USA'));
            request.setHeader('Auth-Token', searchMetaData[0].Token__c);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            if ( response.getStatusCode() == 200) {
                return response.getBody();
            }
        }
        return '';
    } 
    
    /**
*   @Method:        getAddressDetails
*   @Purpose:       Get Full Address detail based on the user selection of address
*/
    @AuraEnabled
    public static String getAddressDetails(String addressURL){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(addressURL);
        request.setHeader('Auth-Token', 'bcb38f58-ceee-4b9f-b568-8ed0a21b1e9b');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if ( response.getStatusCode() == 200) {
            return response.getBody();
        }
        return '';
    }
    
    
    /**
*   @Method:        duplicateContactList
*   @Purpose:       find the matching account based on name,address and phone number
*/
    @AuraEnabled
    public static List<Contact> duplicateContactList(String  FirstName,String LastName,String Email,String Phone,String AccountId)
    {
        Map<string,string> AccountWiseRanking=new Map<String,String>();
        List<String> listContactIds=new List<String>();
        
        
        //Dulicate Account Check
        Contact con=new Contact();
        con.FirstName=FirstName;
        con.LastName=lastName;
        con.Phone=phone;
        con.Email=email;
        if(AccountId!=null){
            con.AccountId=AccountId;
        }
        List<Datacloud.FindDuplicatesResult> listDupContact=Datacloud.FindDuplicates.findDuplicates(new List<Contact>{con});
        Map<String,String> duplicateAccRecords=duplicateRecords(listDupContact);
        listContactIds.addAll(duplicateAccRecords.keySet());
        
        // Check exact phone numbers logic 
        String searchPhone = '';
        if(String.isNotBlank(Phone))
            searchPhone += '(' + ServiceUtil.addSoslWildcards(ServiceUtil.formatPhone(Phone)) + ')';
        
        System.debug('searchPhone ' + searchPhone); 
        if(searchPhone.length()>2){
            List<Contact> listDupConByPhone = (List<Contact>)[FIND :searchPhone IN Phone FIELDS RETURNING Contact (Id, FirstName, LastName, Email)][0];
            for(Contact rec:listDupConByPhone){
                listContactIds.add(rec.Id);
            }
        }
        
        
        return [SELECT Id,FirstName,LastName,Email,Phone FROM Contact Where Id in :listContactIds ];
    }
    
    /**
*   @Method:        duplicateRecords
*   @Purpose:       used to retrive the result of duplicate data from duplicate result set
*/
    public static Map<String,String> duplicateRecords(List<Datacloud.FindDuplicatesResult> results){
        Map<String,String> mapDupRecordWithRuleName=new Map<String,String>();
        //List<SObject> duplicateRecords = new List<SObject>();
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        System.debug('Duplicate Record: ' + matchRecord.getRecord()+'-'+dupeResult.getDuplicateRule());
                        //duplicateRecords.add(matchRecord.getRecord());
                        if(mapDupRecordWithRuleName.containsKey(String.valueOf(matchRecord.getRecord().get('Id')))){
                            mapDupRecordWithRuleName.put(String.valueOf(matchRecord.getRecord().get('Id')),
                                                         mapDupRecordWithRuleName.get(String.valueOf(matchRecord.getRecord().get('Id')))+','+dupeResult.getDuplicateRule());
                        }else{
                            mapDupRecordWithRuleName.put(String.valueOf(matchRecord.getRecord().get('Id')),dupeResult.getDuplicateRule());
                        }
                    }
                }
            }
        }
        //system.debug('@@mapDupRecordWithRuleName'+mapDupRecordWithRuleName);
        return mapDupRecordWithRuleName;
    }
    
    @AuraEnabled
    public static List<Opportunity> getOpportunity(String accountId) {
        return  [SELECT Id, Name,Type,StageName,Market_Segment__c,closeDate,accountId FROM Opportunity where accountId=:accountId];
    }
    
    public class PicklistEntryWrapper{
        @AuraEnabled public String active {get;set;}
        @AuraEnabled public String defaultValue {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String validFor {get;set;}
        public PicklistEntryWrapper(){  
            
        }
        
    }
}