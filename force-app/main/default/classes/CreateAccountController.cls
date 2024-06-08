public without sharing class CreateAccountController {
    
    public static List<String> personAccCustomerType= new list<String>{'Homeowner','Employee'};
    public class RTARequest{
        public String CustomerType;
        public String PhoneType;
        public String OrganizationName;
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        public String Address;
        public String Address2;
        public String City;
        public String State;
        public String Zipcode;
        public String RecordId;
        public Boolean Business;
        public Boolean ShipTo;
        public Boolean InstallAt;
        public Boolean BillTo;
        public Boolean BusinessPrimary;
        public Boolean ShipToPrimary;
        public Boolean InstallAtPrimary;
        public Boolean BillToPrimary;
        public Boolean BusinessIdentify;
        public Boolean ShipToIdentify;
        public Boolean InstallAtIdentify;
        public Boolean BillToIdentify;
        public String branchId;
        public String AccRank;
        public String AccStatus;
        public String county;
        public String ChildRecordId;
        public String Usercountry;
        public String serviceContactId;
        
        //Added for National Account Changes
        public String currentRecId;
    }
    
    public class ExistingAccountWrapper{
        @AuraEnabled public String Name;
        @AuraEnabled public String RecordId;
        @AuraEnabled public String Phone;
        @AuraEnabled public Boolean IsABPExist;
        @AuraEnabled public String ABPOwner;
        @AuraEnabled public String ABPOwnerId;
        @AuraEnabled public String ABPId;
        @AuraEnabled public String Address;
        @AuraEnabled public Decimal rank;
        @AuraEnabled public String MatchBasedOn;
        @AuraEnabled public List<String> existingBranch;
        
    }
    
    

     
   @AuraEnabled //Save Account Data
    Public static void createAccount(Account objacc){
        try{
            //Insert Account Record
            insert objacc; 
             
        }catch(Exception e){
            //throw exception message
            throw new AuraHandledException(e.getMessage());
        }
        finally {
        }
    }
     
    @AuraEnabled//get Account Phone Type Picklist Values
    public static Map<String,Object> getPhone(String queryValue){
        Map<String,Object> returnMap=new Map<String,Object>();
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult =Account.Evening_Phone_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        
        for( Schema.PicklistEntry f : ple)
        {
            options.put(f.getValue(),f.getLabel());
        }       
        returnMap.put('PhoneType',options);
        system.debug('This is get Phone'+returnMap);
        
        return returnMap;
    }
	/**
    *   @Method:        getProjectAddress
    *   @Purpose:       Auto populate the address on the account search UI 
    * 
    */
    @AuraEnabled
    public static String getProjectAddress(String queryValue,Boolean isCanada){
        system.debug('getProjectAddress'); 
        List<Endpoint_Configuration__mdt> searchMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Search_Address' ]; 
        if(searchMetaData.size()>0){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(searchMetaData[0].Endpoint__c+EncodingUtil.urlEncode(queryValue, 'UTF-8')+'&country='+(isCanada?'CAN':'USA'));
            request.setTimeout(120000);
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
        List<Endpoint_Configuration__mdt> searchMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Search_Address' ]; 
        if(searchMetaData.size()>0){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(addressURL);
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
    *   @Method:        getPhoneType
    *   @Purpose:       get Phone Type to display on the UI for selection 
    */
     @AuraEnabled 
    public static Map<String, String> getPhoneType(){
     
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Account.Evening_Phone_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    
    }
    
    /**
    *   @Method:        getCustomerType
    *   @Purpose:       get Customer Type to display on the UI for selection 
    */
    @AuraEnabled
    public static Map<String,Object> getCustomerType(String queryValue){
        Map<String,Object> returnMap=new Map<String,Object>();
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult =Account.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        system.debug('This is get customer tyoe');
        
        for( Schema.PicklistEntry f : ple)
        {
            options.put(f.getValue(),f.getLabel());
        }       
        returnMap.put('CustomerType',options);
        User currentUser=[SELECT ID,Country,Title,Profile.Name FROM User Where Id =:Userinfo.getUserId()];
        returnMap.put('UserCountry',currentUser);
        returnMap.put('isUserRoleNotAllow',(currentUser.Title!=null && Label.T_C_NotAllowUser!=null && Label.T_C_NotAllowUser.containsIgnoreCase(';'+currentUser.Title+';')));
        
        // get states picklist values
        Map<String,String> USStates = new Map<String,String>();
        Map<String,String> CANStates = new Map<String,String>();
        Map<String,String> COSTARICAStates = new Map<String,String>();
        Map<String,String> MEXICOStates = new Map<String,String>();
        fieldResult = Address__c.US_States__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            USStates.put(f.getValue(),f.getLabel());
        }   
        
        fieldResult = Address__c.CAN_States__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            CANStates.put(f.getValue(),f.getLabel());
        }
    fieldResult = Address__c.COSTA_RICA_States__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            COSTARICAStates.put(f.getValue(),f.getLabel());
        } 
            fieldResult = Address__c.MEXICO_States__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            MEXICOStates.put(f.getValue(),f.getLabel());
        }     
        
        Map<String,String> accStatus = new Map<String,String>();
        fieldResult = Account.Account_Status__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            accStatus.put(f.getValue(),f.getLabel());
        } 
        
        Map<String,String> accRank = new Map<String,String>();
        fieldResult = Account.Account_Rank__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            accRank.put(f.getValue(),f.getLabel());
        }
        
        returnMap.put('USStates', USStates);
        returnMap.put('CANStates', CANStates);
        returnMap.put('COSTARICAStates', COSTARICAStates);
        returnMap.put('MEXICOStates', MEXICOStates);
        returnMap.put('accStatus', accStatus);
        returnMap.put('accRank', accRank);
        return returnMap;
    }
    
    /**
    *   @Method:        searchExistingAccounts
    *   @Purpose:       Get List of existing matching account based on the user input 
    */
    @AuraEnabled
    public static List<ExistingAccountWrapper> searchExistingAccounts(String requestData) {
        
        //User currentUser=[SELECT ID,Country,Title FROM User Where Id =:Userinfo.getUserId()];
        
        
        
        /* Account Weightage config from custom metadata */
        List<Account_Weightage__mdt> listAccountWeightage=[SELECT DeveloperName,Order__C,Display_Text__c from Account_Weightage__mdt];
        Map<String,Account_Weightage__mdt> NameWiseWeightage=new Map<String,Account_Weightage__mdt>();
        for(Account_Weightage__mdt AW: listAccountWeightage){
            NameWiseWeightage.put(AW.DeveloperName,AW);
        }
        
        RTARequest request=(RTARequest) JSON.deserialize(requestData, RTARequest.class);
        String userCountry=request.Usercountry!=null && request.Usercountry.toLowerCase()=='canada'?'CA':'US';
        List<ExistingAccountWrapper> listAccWrapper=new List<ExistingAccountWrapper>();
        //request.OrganizationName='%'+request.OrganizationName+'%';
        
        // check search is for Personaccount or branch account
        String searchAccType='Org';
        if(request.CustomerType!=null && (personAccCustomerType.contains(request.CustomerType))){
            searchAccType='Person';
        }
        
        // Get List Of Relevent Duplicate account
        Map<String,String> AccountIdWiseRanking=duplicateAccountList(request,searchAccType,userCountry);
        String ProLowBusinessSegment='';
        List<String> recordTypeSearch=new List<String>();
        
        // Added for National Account
        if(request.currentRecId!=null && !String.isBlank(request.currentRecId) && !request.currentRecId.startsWithIgnoreCase('003')){
            recordTypeSearch.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BranchAccount').getRecordTypeId());
            List<Account> listAcc=[SELECT ID,type,Branch_Number__c,BusinessSegment__c FROM Account where Id=:request.currentRecId];
            if(listAcc.size()>0){
                ProLowBusinessSegment=listAcc[0].BusinessSegment__c ;
            }
            
        }
        else if( searchAccType=='Person'){
            recordTypeSearch.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        }else{
            recordTypeSearch.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId());
            recordTypeSearch.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BranchAccount').getRecordTypeId());
        }
        
        List<Account> listAcc=[SELECT ID,Branch__C,Branch_Number__c,BusinessSegment__c,ParentId,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,OwnerId,Owner.Name,Phone 
                               FROM Account 
                               Where Id in :AccountIdWiseRanking.keySet() and recordTypeId in :recordTypeSearch];//Name Like :request.OrganizationName];
        set<Id> listParentAccId=new set<Id>();
        
        
        for(Account acc:listAcc){
            // Pro Lowes Account
            if(request.currentRecId!=null && !request.currentRecId.startsWithIgnoreCase('003')){
                if(acc.BusinessSegment__c!=null && acc.BusinessSegment__c == ProLowBusinessSegment){
                    if(acc.ParentId!=null){
                        listParentAccId.add(acc.ParentId);
                        AccountIdWiseRanking.put(acc.ParentId,AccountIdWiseRanking.get(acc.Id));
                    }else{
                        listParentAccId.add(acc.Id);
                    }
                }
             }else{
                 if(acc.BusinessSegment__c==null){
                     if(acc.ParentId!=null){
                         listParentAccId.add(acc.ParentId);
                         AccountIdWiseRanking.put(acc.ParentId,AccountIdWiseRanking.get(acc.Id));
                     }else{
                         listParentAccId.add(acc.Id);
                     }
                 }
            }
            
        }
       
        // Get list of braches associate with logged in user
        Map<String,Object> branchResult=getBranchName(request.serviceContactId);
        List<Branch__c> listBranch=(List<Branch__c>)branchResult.get('BranchList');
        List<Id> listBranchFamily=new List<Id>();
        List<Id> listBranchIdAssociateWithUser=new List<Id>();
        Map<Id,List<Id>> branchFamilyWisebranch=new Map<Id,List<Id>>();
        for(Branch__C branch : listBranch){
            listBranchFamily.add(branch.Branch_Family__c);
            if(!branchFamilyWisebranch.containsKey(branch.Branch_Family__c)){
                branchFamilyWisebranch.put(branch.Branch_Family__c,new List<Id>());
            }
            branchFamilyWisebranch.get(branch.Branch_Family__c).add(branch.Id);
            listBranchIdAssociateWithUser.add(branch.Id);
        }
        
        if(searchAccType=='Org'){
            List<Account> listAllAccounts=[SELECT ID,Branch__C,BusinessSegment__c,Branch__r.Branch_Family__c,ParentId,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,OwnerId,Owner.Name,Phone,(SELECT ID,Associated_Account_Name__c FROM Associated_CustomerAccounts__r)  FROM Account Where Id in :listParentAccId or parentId in :listParentAccId  ];
            
            // Check Branch Family wise account exist
            Map<Id,Account> AccountIdWiseABP=new Map<Id,Account>();
            Map<Id,set<String>> accountWiseABPNumber=new Map<Id,set<String>>();
            List<String> listExistingAcc=new List<String>();
            for(Account acc : listAllAccounts){
                if(listBranchFamily.contains(acc.Branch__r.Branch_Family__c)){
                    String accId=acc.parentId==null?acc.Id:acc.ParentId;
                    AccountIdWiseABP.put(accId,acc);
                    if(branchFamilyWisebranch.containsKey(acc.Branch__r.Branch_Family__c)){
                        for(Id branchId : branchFamilyWisebranch.get(acc.Branch__r.Branch_Family__c)){
                            if(!accountWiseABPNumber.containsKey(accId)){
                                accountWiseABPNumber.put(accId,new set<String>());
                            }
                            accountWiseABPNumber.get(accId).add(branchId);
                        }
                    }
                }
                
            }
            // Prepare data to display on the UI
            for(Account acc: listAllAccounts){
                if((acc.ParentId==null  && request.currentRecId==null) || (acc.ParentId==null  && request.currentRecId.startsWithIgnoreCase('003')) ){
                    String Address=acc.BillingStreet==null?'':acc.BillingStreet+',';
                    Address+=acc.BillingCity==null?'':acc.BillingCity+',';
                    Address+=acc.BillingState==null?'':acc.BillingState+',';
                    Address+=acc.BillingPostalCode==null?'':acc.BillingPostalCode+',';
                    if(Address.length()>0){
                        Address=Address.substring(0,Address.length()-1);
                    }
                    ExistingAccountWrapper EAW=new ExistingAccountWrapper();
                    EAW.Name=acc.Name;
                    EAW.RecordId=acc.Id;
                    EAW.Address=Address;
                    EAW.IsABPExist=AccountIdWiseABP.containsKey(acc.Id);
                    EAW.ABPOwner=AccountIdWiseABP.containsKey(acc.Id)?String.valueOf(AccountIdWiseABP.get(acc.Id).Owner.Name):''; 
                    EAW.ABPOwnerId=AccountIdWiseABP.containsKey(acc.Id)?String.valueOf(AccountIdWiseABP.get(acc.Id).OwnerId):'';
                    EAW.ABPId=AccountIdWiseABP.containsKey(acc.Id)?String.valueOf(AccountIdWiseABP.get(acc.Id).Id):'';
                    EAW.Phone=acc.Phone;
                    if(NameWiseWeightage.containsKey(AccountIdWiseRanking.get(acc.Id))){
                        EAW.rank=NameWiseWeightage.get(AccountIdWiseRanking.get(acc.Id)).Order__C;
                        EAW.MatchBasedOn=NameWiseWeightage.get(AccountIdWiseRanking.get(acc.Id)).Display_Text__c;
                    }
                    EAW.existingBranch=new List<String>();
                    if(accountWiseABPNumber.containsKey(acc.Id)){
                        EAW.existingBranch.addAll(accountWiseABPNumber.get(acc.Id));
                    }
                    EAW.IsABPExist=EAW.existingBranch.size()==listBranchIdAssociateWithUser.size();
                    IF(EAW.IsABPExist)EAW.rank=0;
                    
                    
                    listAccWrapper.add(EAW); 
                }
                if(acc.ParentId!=null && request.currentRecId!=null){
                    if(acc.BusinessSegment__c!=null && acc.BusinessSegment__c == ProLowBusinessSegment){
                        
                        String Address=acc.BillingStreet==null?'':acc.BillingStreet+',';
                        Address+=acc.BillingCity==null?'':acc.BillingCity+',';
                        Address+=acc.BillingState==null?'':acc.BillingState+',';
                        Address+=acc.BillingPostalCode==null?'':acc.BillingPostalCode+',';
                        if(Address.length()>0){
                            Address=Address.substring(0,Address.length()-1);
                        }
                        ExistingAccountWrapper EAW=new ExistingAccountWrapper();
                        EAW.Name=acc.Name;
                        EAW.RecordId=acc.Id;
                        EAW.Address=Address;
                        EAW.IsABPExist=false;
                        for(Associated_Account__c AssociateAcc: acc.Associated_CustomerAccounts__r){
                            if(AssociateAcc.Associated_Account_Name__c==request.currentRecId){
                                EAW.IsABPExist=true;
                            }
                        }
                        EAW.ABPOwner=acc.Owner.Name; 
                        EAW.ABPOwnerId=acc.OwnerId;
                        EAW.ABPId=acc.Id;
                        EAW.Phone=acc.Phone;
                        if(NameWiseWeightage.containsKey(AccountIdWiseRanking.get(acc.Id))){
                            EAW.rank=NameWiseWeightage.get(AccountIdWiseRanking.get(acc.Id)).Order__C;
                            EAW.MatchBasedOn=NameWiseWeightage.get(AccountIdWiseRanking.get(acc.Id)).Display_Text__c;
                        }
                        EAW.existingBranch=new List<String>();
                        if(accountWiseABPNumber.containsKey(acc.Id)){
                            EAW.existingBranch.addAll(accountWiseABPNumber.get(acc.Id));
                        }
                        
                        IF(EAW.IsABPExist)EAW.rank=0;
                        
                        listAccWrapper.add(EAW); 
                    }
                }
            }
        }else if(searchAccType=='Person'){
            
            // get all related account branch profiles
            List<Account_Branch_Profile__c> listAccBanchProfile=[SELECT ID,Party_Account__c,OwnerId,Owner.Name,Branch__c,Branch__r.Branch_Family__c FROM Account_Branch_Profile__c Where Party_Account__c in :listAcc and Branch__r.Branch_Family__c in :listBranchFamily and Branch__r.Branch_Family__c !=null];
            Map<Id,Account_Branch_Profile__c> AccountIdWiseABP=new Map<Id,Account_Branch_Profile__c>();
            Map<Id,set<String>> accountWiseABPNumber=new Map<Id,set<String>>();
            for(Account_Branch_Profile__c ABP : listAccBanchProfile){
                AccountIdWiseABP.put(ABP.Party_Account__c,ABP);
                /*if(listBranchIdAssociateWithUser.contains(ABP.Branch__c)){
                    if(!accountWiseABPNumber.containsKey(ABP.Party_Account__c)){
                        accountWiseABPNumber.put(ABP.Party_Account__c,new set<String>());
                    }
                    accountWiseABPNumber.get(ABP.Party_Account__c).add(ABP.Branch__c);
                }*/
                if(branchFamilyWisebranch.containsKey(ABP.Branch__r.Branch_Family__c)){
                    for(Id branchId : branchFamilyWisebranch.get(ABP.Branch__r.Branch_Family__c)){
                        if(!accountWiseABPNumber.containsKey(ABP.Party_Account__c)){
                            accountWiseABPNumber.put(ABP.Party_Account__c,new set<String>());
                        }
                        accountWiseABPNumber.get(ABP.Party_Account__c).add(branchId);
                    }
                }
            }
            
            for(Account acc: listAcc){
                String Address=acc.BillingStreet==null?'':acc.BillingStreet+',';
                Address+=acc.BillingCity==null?'':acc.BillingCity+',';
                Address+=acc.BillingState==null?'':acc.BillingState+',';
                Address+=acc.BillingPostalCode==null?'':acc.BillingPostalCode+',';
                if(Address.length()>0){
                    Address=Address.substring(0,Address.length()-1);
                }
                ExistingAccountWrapper EAW=new ExistingAccountWrapper();
                EAW.Name=acc.Name;
                EAW.RecordId=acc.Id;
                EAW.Address=Address;
                EAW.IsABPExist=AccountIdWiseABP.containsKey(acc.Id);
                EAW.ABPOwner=AccountIdWiseABP.containsKey(acc.Id)?String.valueOf(AccountIdWiseABP.get(acc.Id).Owner.Name):''; 
                EAW.ABPOwnerId=AccountIdWiseABP.containsKey(acc.Id)?String.valueOf(AccountIdWiseABP.get(acc.Id).OwnerId):'';
                EAW.ABPId=AccountIdWiseABP.containsKey(acc.Id)?String.valueOf(acc.Id):'';
                EAW.Phone=acc.Phone;
                if(NameWiseWeightage.containsKey(AccountIdWiseRanking.get(acc.Id))){
                    EAW.rank=NameWiseWeightage.get(AccountIdWiseRanking.get(acc.Id)).Order__C;
                    EAW.MatchBasedOn=NameWiseWeightage.get(AccountIdWiseRanking.get(acc.Id)).Display_Text__c;
                }
                EAW.existingBranch=new List<String>();
                if(accountWiseABPNumber.containsKey(acc.Id)){
                    EAW.existingBranch.addAll(accountWiseABPNumber.get(acc.Id));
                }
                EAW.IsABPExist=EAW.existingBranch.size()==listBranchIdAssociateWithUser.size();
                IF(EAW.IsABPExist)EAW.rank=0;
                listAccWrapper.add(EAW); 
            }
            
        }
        system.debug('@@'+listAccWrapper);
        return listAccWrapper;
    }
    
    /**
    *   @Method:        duplicateAccountList
    *   @Purpose:       find the matching account based on name,address and phone number
    */
    public static Map<string,string> duplicateAccountList(RTARequest req ,String AccountType,String userCountry)
    {
        Map<string,string> AccountWiseRanking=new Map<String,String>();
        List<String> listAccIds=new List<String>();
        
        List<String> NameMatch=new List<String>();
        List<String> AddressMatch=new List<String>();
        List<String> PhoneMatch=new List<String>();
        List<String> EmailMatch=new List<String>();
        
        //Dulicate Account Check
        Account acc=new Account();
        if(AccountType=='Org'){
            acc.Name=req.OrganizationName;
            acc.Phone=req.Phone;
            acc.BillingStreet=req.Address+' '+req.Address2;
            acc.BillingState=req.state;
            acc.BillingCity=req.city;
            acc.BillingPostalCode=req.zipcode;
            acc.BillingCountry=userCountry;
            acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        }
        if(AccountType=='Person'){
            acc.FirstName=req.FirstName;
            acc.LastName=req.LastName;
            acc.Evening_Phone_Type__c= req.PhoneType;
            acc.PersonEmail=req.Email;
            acc.Phone=req.Phone;
            acc.PersonMailingStreet=req.Address+' '+req.Address2;
            acc.PersonMailingState=req.state;
            acc.PersonMailingCity=req.city;
            acc.PersonMailingPostalCode=req.zipcode;
            acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        }
           
        List<Datacloud.FindDuplicatesResult> listDupAccount=Datacloud.FindDuplicates.findDuplicates(new List<Account>{acc});
        Map<String,String> duplicateAccRecords=duplicateRecords(listDupAccount);
        for(String accID:duplicateAccRecords.keySet()){
            // If Branch Account below condition match
            if(duplicateAccRecords.get(accId).contains('Account_Name')){
                NameMatch.add(accId);
            }
            if(duplicateAccRecords.get(accId).contains('Account_Address')){
                AddressMatch.add(accId);
            }
            
            //if person account below condition match
            if(duplicateAccRecords.get(accId).contains('FN_LN_Phone')){
                NameMatch.add(accId);
                PhoneMatch.add(accId);
            }
            if(duplicateAccRecords.get(accId).contains('FN_LN_and_Email')){
                NameMatch.add(accId);
                EmailMatch.add(accId);
            }
            if(duplicateAccRecords.get(accId).contains('FN_Address_Phone_and_Email')){
                NameMatch.add(accId);
                EmailMatch.add(accId);
                AddressMatch.add(accId);
                PhoneMatch.add(accId);
            }
            if(duplicateAccRecords.get(accId).contains('FN_LN_Address')){
                NameMatch.add(accId);
                AddressMatch.add(accId);
            }
        }
        listAccIds.addAll(duplicateAccRecords.keySet());
        system.debug('@@Address');
        
        // Duplicate Address
        Address__c addr = new Address__c(Street__c = req.Address+' '+req.Address2, City__c = req.City, State__c = req.State, Zipcode__c = req.Zipcode,County__c = req.county, Country__c =userCountry );
        List<Datacloud.FindDuplicatesResult> listDupAddress=Datacloud.FindDuplicates.findDuplicates(new List<Address__c>{addr});
        Map<String,String> duplicateAddRecords=duplicateRecords(listDupAddress);
        
        List<Address_Assignment__c> listAA=[SELECT ID,Account_Branch_Profile__r.Party_Account__c,Account__c FROM Address_Assignment__c Where Address__c in :duplicateAddRecords.KeySet() ];
        for(Address_Assignment__c AA : listAA){
            if(AccountType=='Org'){
                if(AA.Account__c!=null){
                    listAccIds.add(AA.Account__c);
                    AddressMatch.add(AA.Account__c);
                }
            }else if(AccountType=='Person'){
                if(AA.Account_Branch_Profile__r.Party_Account__c!=null){
                    listAccIds.add(AA.Account_Branch_Profile__r.Party_Account__c);
                    AddressMatch.add(AA.Account_Branch_Profile__r.Party_Account__c);
                }
            }
        }
        
        // Check exact phone numbers logic 
        String searchPhone = '';
        if(String.isNotBlank(req.Phone))
            searchPhone += '(' + ServiceUtil.addSoslWildcards(ServiceUtil.formatPhone(req.Phone)) + ')';
        
        System.debug('searchPhone ' + searchPhone); 
        if(searchPhone.length()>2){
            List<Account> listDupAccByPhone = (List<Account>)[FIND :searchPhone IN Phone FIELDS RETURNING Account (Id, FirstName, LastName, PersonEmail)][0];
            for(Account rec:listDupAccByPhone){
                listAccIds.add(rec.Id);
                PhoneMatch.add(rec.Id);
            }
        }
        
        
        // Check exact name  logic for prolow
        String searchName =req.OrganizationName;
        
        System.debug('searchName ' + searchName); 
        if(searchName.length()>2){
            List<Account> listDupAccByName = (List<Account>)[SELECT ID,NAME FROM Account Where Name =:searchName ];
            for(Account rec:listDupAccByName){
                listAccIds.add(rec.Id);
                NameMatch.add(rec.Id);
            }
        }
        
        
        // Order Matching Rule
        for(String accId : listAccIds){
            if((NameMatch.contains(accId) && PhoneMatch.contains(accId) && AddressMatch.contains(accId) && EmailMatch.contains(accId) )){
                AccountWiseRanking.put(accId,'NAME_PHONE_ADDRESS_EMAIL');
            }
            else if((NameMatch.contains(accId) && PhoneMatch.contains(accId) && EmailMatch.contains(accId))){
                AccountWiseRanking.put(accId,'NAME_PHONE_EMAIL');
            }
            else if((NameMatch.contains(accId) && PhoneMatch.contains(accId) && AddressMatch.contains(accId))){
                AccountWiseRanking.put(accId,'NAME_PHONE_ADDRESS');
            }else if((NameMatch.contains(accId) && EmailMatch.contains(accId) && AddressMatch.contains(accId))){
                AccountWiseRanking.put(accId,'NAME_EMAIL_ADDRESS');
            }else if(NameMatch.contains(accId) && PhoneMatch.contains(accId)){
                AccountWiseRanking.put(accId,'NAME_PHONE');
            }else if(NameMatch.contains(accId) && EmailMatch.contains(accId)){
                AccountWiseRanking.put(accId,'NAME_EMAIL');
            }else if(NameMatch.contains(accId) && AddressMatch.contains(accId)){
                AccountWiseRanking.put(accId,'NAME_ADDRESS');
            }else if(PhoneMatch.contains(accId) && EmailMatch.contains(accId)){
                AccountWiseRanking.put(accId,'PHONE_EMAIL');
            }else if(PhoneMatch.contains(accId) && AddressMatch.contains(accId)){
                AccountWiseRanking.put(accId,'PHONE_ADDRESS');
            }else if(PhoneMatch.contains(accId) ){
                AccountWiseRanking.put(accId,'PHONE');
            }else if(EmailMatch.contains(accId)){
                AccountWiseRanking.put(accId,'EMAIL');
            }else if(AddressMatch.contains(accId)){
                AccountWiseRanking.put(accId,'ADDRESS');
            }else if(NameMatch.contains(accId)){
                AccountWiseRanking.put(accId,'NAME');
            }
        }
        
        return AccountWiseRanking;
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
    
    /**
    *   @Method:        createNewAccount
    *   @Purpose:       Create New Account and Branch Account based on the user input data 
    */
    @AuraEnabled
    public static String createNewAccount(String requestData,String AdditionalAddress) {
        String returnRecId;
        RTARequest request=(RTARequest) JSON.deserialize(requestData, RTARequest.class);
        
        // This is added for lead convert scenario where branch account already exist then do not process
        if(request.ChildRecordId!=null && request.ChildRecordId!=''){
            return request.ChildRecordId.startsWith('001')?request.ChildRecordId:request.RecordId;
        }
        
        //User currentUser=[SELECT ID,Country,Title FROM User Where Id =:Userinfo.getUserId()];
        // Changes for international address --Rekha
        
        
        String userCountry=request.Usercountry!=null && request.Usercountry.toLowerCase()=='canada'?'CA':'US';
 
        // check search is for Personaccount or branch account
        String searchAccType='Org';
        if(request.CustomerType!=null && (personAccCustomerType.contains(request.CustomerType))){
            searchAccType='Person';
        }
        
        // Get Branch information based on BranchID
        String branchId =request.branchId;
        
        // Create Parent Account(Organization) record if user create fresh account
        if(request.RecordId==null || String.isBlank(request.RecordId) || searchAccType=='Person'){
            Account acc=new Account();
            if(searchAccType=='Org'){
                
                // Get List Of Relevent Duplicate account
                Map<String,String> AccountIdWiseRanking=duplicateAccountList(request,searchAccType,userCountry);
                
                String existingAccID=null;
                Decimal currentOrder=50;
                
                List<String> recordTypeSearch=new List<String>();
                String ProLowBusinessSegment='';
                if(request.currentRecId!=null && !String.isBlank(request.currentRecId)){
                    List<Account> listAcc=[SELECT ID,type,Branch_Number__c,BusinessSegment__c FROM Account where Id=:request.currentRecId];
                    if(listAcc.size()>0){
                        ProLowBusinessSegment=listAcc[0].BusinessSegment__c;
                    }
                }
                List<Account> listAccData=[SELECT ID,Branch__C,Branch_Number__c,BusinessSegment__c,ParentId,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,OwnerId,Owner.Name,Phone 
                                       FROM Account 
                                       Where Id in :AccountIdWiseRanking.keySet() and recordType.DeveloperName='BranchAccount'];//Name Like :request.OrganizationName];
                set<Id> listParentAccId=new set<Id>();
                
                for(Account accRec:listAccData){
                    if(request.currentRecId!=null && !String.isBlank(request.currentRecId)){
                        // Consider only Prodealer&PDSN account in case of Lowe's acc or Lowes's &PDSN account in case of Prodealer acc or 
                        if(accRec.BusinessSegment__c==null || accRec.BusinessSegment__c!=ProLowBusinessSegment){
                            if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE_ADDRESS_EMAIL' && currentOrder>1){
                                currentOrder=1;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE_EMAIL' && currentOrder>2){
                                currentOrder=2;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE_ADDRESS' && currentOrder>3){
                                currentOrder=3;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_EMAIL_ADDRESS' && currentOrder>4){
                                currentOrder=4;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE' && currentOrder>5){
                                currentOrder=5;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_ADDRESS' && currentOrder>6){
                                currentOrder=6;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_EMAIL' && currentOrder>7){
                                currentOrder=7;existingAccID=accRec.ParentId;
                            }else if(AccountIdWiseRanking.get(accRec.Id)=='PHONE_ADDRESS' && currentOrder>7){
                                currentOrder=7;existingAccID=accRec.ParentId;
                            }
                        }
                    }else{
                        // Consider Prodelaer & Low's Account
                        if(accRec.BusinessSegment__c!=null){
                            if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE_ADDRESS_EMAIL' && currentOrder>1){
                                currentOrder=1;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE_EMAIL' && currentOrder>2){
                                currentOrder=2;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE_ADDRESS' && currentOrder>3){
                                currentOrder=3;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_EMAIL_ADDRESS' && currentOrder>4){
                                currentOrder=4;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_PHONE' && currentOrder>5){
                                currentOrder=5;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_ADDRESS' && currentOrder>6){
                                currentOrder=6;existingAccID=accRec.ParentId;
                            }
                            else if(AccountIdWiseRanking.get(accRec.Id)=='NAME_EMAIL' && currentOrder>7){
                                currentOrder=7;existingAccID=accRec.ParentId;
                            }else if(AccountIdWiseRanking.get(accRec.Id)=='PHONE_ADDRESS' && currentOrder>7){
                                currentOrder=7;existingAccID=accRec.ParentId;
                            }
                        }
                    }
                } 
                
                if(request.currentRecId==null || String.isBlank(request.currentRecId)){
                    if(existingAccID==null){
                        List<Branch__c> listBranch=[SELECT Id,T_C_Branch_Number__c,Branch_Family__c,Branch_Family__r.Pella_Account_Owner__c  From Branch__c where id=:branchId];
                        // set Pella Account Owner as per branch Family
                        if(listBranch.size()>0 && listBranch[0].Branch_Family__r.Pella_Account_Owner__c!=null){
                            acc.OwnerId=listBranch[0].Branch_Family__r.Pella_Account_Owner__c;
                        }
                    }
                }else{
                    List<Account> listAcc=[SELECT ID,type,Branch_Number__c,BusinessSegment__c FROM Account where Id=:request.currentRecId];
                    if(listAcc.size()>0){
                        acc.Branch_Number__c=listAcc[0].Branch_Number__c;
                    }
                    if(existingAccID==null){
                        String userRoleDevName='Pro_Account_Manager';
                        if(ProLowBusinessSegment=='Pro Dealer'){
                            userRoleDevName='Pro_Account_Manager';
                        }else{
                            userRoleDevName='Lowe_s_Account_Manager';
                        }
                        List<User> listUser=[SELECT Id, Username, LastName, UserRole.developerName FROM User where UserRole.developerName =:userRoleDevName];
                        if(listUser.size()>0){
                            
                            acc.OwnerId=listUser[0].Id;
                        }
                    }
                }
                
                if(existingAccID!=null){
                    acc.Id=existingAccID;
                    request.RecordId=existingAccID;
                }
                
                
                acc.Name=request.OrganizationName;
                acc.Phone=request.Phone;
                acc.Company_Email__c = request.Email;
                acc.Type=request.CustomerType;
                acc.Is_From_Custom_UI__c=true;
                acc.Account_State__c = 'prospect';
                /*acc.BillingStreet=request.Address+' '+request.Address2;
                acc.BillingState=request.state;
                acc.BillingCity=request.city;
                acc.BillingPostalCode=request.zipcode;
                acc.BillingCountry=userCountry;
                acc.BillingCounty__c=request.county;*/
                acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
            }
            else if(searchAccType=='Person'){
                acc.FirstName=request.FirstName;
                acc.LastName=request.LastName;
                acc.Type=request.CustomerType;
                acc.Evening_Phone_Type__c=request.PhoneType;
                acc.Is_From_Custom_UI__c=true;
                acc.TC_Person_Account__c=true;
                acc.PersonEmail=request.Email;
                if(acc.Evening_Phone_Type__c=='Mobile'){
                    acc.PersonMobilePhone=request.Phone;
                }
                else if(acc.Evening_Phone_Type__c=='Home'){
                    acc.PersonHomePhone=request.Phone;
                }
                else{
                   acc.PersonOtherPhone= request.Phone;
                }
                acc.Phone=request.Phone;
                acc.PersonMailingStreet=request.Address+' '+request.Address2;
                acc.PersonMailingState=request.state;
                acc.PersonMailingCity=request.city;
                acc.PersonMailingPostalCode=request.zipcode;
                
                acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                if(!( request.RecordId==null || String.isBlank(request.RecordId))){
                    acc.Id=request.RecordId;
                }else{
                    acc.OwnerId=Userinfo.getUserId();
                }
            }
            
            if(request.RecordId==null || String.isBlank(request.RecordId)){
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
                Database.SaveResult saveResult = Database.insert(acc, dml);
                Map<String,Object> resultMap = checkDuplicates(saveResult);
                
                if(resultMap.containsKey('ErrorMessage')){
                    throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
                }
                
            }else{
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
                Database.SaveResult saveResult = Database.update(acc, dml);
                Map<String,Object> resultMap = checkDuplicates(saveResult);
                
                if(resultMap.containsKey('ErrorMessage')){
                    throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
                }
                
                system.debug('saveResult :: '+saveResult);
            }
               
            request.RecordId=acc.Id;
            returnRecId=acc.Id;
        }
        String accOrAbpId='';
        if(searchAccType=='Org'){
            // Create child Account(Branch Account) 
            Account acc=new Account();
            acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BranchAccount').getRecordTypeId();
            acc.Name=request.OrganizationName;
            acc.Type=request.CustomerType;
            acc.Is_From_Custom_UI__c=true;
            acc.Phone=request.Phone;
            acc.Company_Email__c = request.Email;
            /*acc.BillingStreet=request.Address+' '+request.Address2;
            acc.BillingState=request.state;
            acc.BillingCity=request.city;
            acc.BillingPostalCode=request.zipcode;
            acc.BillingCountry=userCountry;
            acc.BillingCounty__c=request.county;*/
            if(request.currentRecId==null || String.isBlank(request.currentRecId) || request.currentRecId.startsWithIgnoreCase('003')){
                acc.Branch__c=branchId;
            }else{
                List<Account> listAcc=[SELECT ID,type,Branch_Number__c,BusinessSegment__c FROM Account where Id=:request.currentRecId];
                if(listAcc.size()>0){
                    acc.Branch_Number__c=listAcc[0].Branch_Number__c;
                }

            }
            acc.ParentId=request.RecordId;
            acc.Account_State__c = 'prospect';
            if(String.isNotBlank(request.AccStatus)){
                acc.Account_Status__c = request.AccStatus;
            }
            if(String.isNotBlank(request.AccRank)){
                acc.Account_Rank__c = request.AccRank;
            }
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            Database.SaveResult saveResult = Database.insert(acc, dml);
            System.debug('@@acc : '+acc);
            System.debug('@@saveResult : '+saveResult);
            // Run Territory Rule to share parent account with new branch account
            //if(returnRecId==null)returnRecId=acc.Id;
            returnRecId=acc.Id;
            accOrAbpId=acc.Id;
            //EBSFullLoad.runEnterpriseTerritoryManagementRules(request.RecordId, fetchUserSessionId());
        }
        else if(searchAccType=='Person'){
            // Create or Update Account Branch Profile related to Account and Branch
            Account_Branch_Profile__c abf = createUpdateAccountBranchProfile(branchId, request.RecordId,request.Phone);
            //if(returnRecId==null)returnRecId=abf.Id;
            returnRecId=request.RecordId;
            EBSFullLoad.runEnterpriseTerritoryManagementRules(request.RecordId, fetchUserSessionId());
            accOrAbpId=abf.Id;
        }
        
        if(request.currentRecId!=null && !String.isBlank(request.currentRecId) && request.serviceContactId == NULL){
            // If it's ProLow Branch account, Create Assocition
            AssociateBranchAccount(accOrAbpId,request.currentRecId);
        }
        
        // Create or Update Address
        Address__c addr = createUpdateAddress(request,userCountry);
        
        Map<Id,Address_Assignment__c> updatelistAA=new Map<Id,Address_Assignment__c>();
        List<Address_Assignment__c> insertlistAA=new List<Address_Assignment__c>();
        Address_Assignment__c AA;
        // Get Address Assingment for Account and AccountBranchProfile, if doesn't exists then create new one
        if(request.Business)
            AA=createAddressAssignment(addr.Id, accOrAbpId,'Business',searchAccType,request.BusinessIdentify,request.BusinessPrimary);
        if(request.Business && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA); 
            else insertlistAA.add(AA);
        }
        
        if(request.BillTo)AA=createAddressAssignment(addr.Id, accOrAbpId,'Bill To',searchAccType,request.BillToIdentify,request.BillToPrimary);
        if(request.BillTo && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA); 
            else insertlistAA.add(AA);
        }
        
        if(request.ShipTo)AA=createAddressAssignment(addr.Id, accOrAbpId,'Ship To',searchAccType,request.ShipToIdentify,request.ShipToPrimary);
        if(request.ShipTo && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA);  
            else insertlistAA.add(AA);
        }
        
        if(request.InstallAt)AA=createAddressAssignment(addr.Id, accOrAbpId,'Install At',searchAccType,request.InstallAtIdentify,request.InstallAtPrimary);
        if(request.InstallAt && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA);  
            else insertlistAA.add(AA);
        }
        //system.debug('@@returnRecId :: '+returnRecId);
        
        //insert address
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
        Database.insert(insertlistAA,dml) ;
        Database.update(updatelistAA.values(),dml) ;
        
        
        // Update the Additional Address
        createAdditionalAddress(AdditionalAddress,accOrAbpId,searchAccType,userCountry);
        if(searchAccType=='Person'){
            EBSRESTCallout.createCustomerEBSCallout(request.RecordId);  
        }else{
            // added to not run for prolows
            if(request.currentRecId==null || String.isBlank(request.currentRecId) || request.currentRecId.startsWithIgnoreCase('003')){
                EBSRESTCallout.createCustomerEBSCallout(returnRecId);  
            }
        }
        If(request.serviceContactId != NULL){
            updateContactandCaseRecords(request.serviceContactId,returnRecId,searchAccType);
            Branch__c branch = [select Id from branch__c where branch__c.branch_number__C = '640'];
            Account_branch_profile__C[] abp = NULL;
            Account[] acc = NULL;
            System.debug('request.RecordId : '+request.RecordId);
            if(searchAccType=='Person')
                abp =  [select id from Account_branch_profile__C where Party_Account__c = :returnRecId and branch__c = :branch.id ];
            else
                acc =  [select id from Account where ParentId = :request.RecordId and branch__c = :branch.id ];
            if((searchAccType=='Person' && abp.size() == 0) || (searchAccType=='Org' && acc.size() == 0))
                createBranchAccorABPforCorporate(request,searchAccType,branch.Id,addr.Id,AdditionalAddress,userCountry);   
        }
        return returnRecId;
    }
    
    /**
    *   @Method:        AssociateBranchAccount
    *   @Purpose:       get associte branch account
    */
    @AuraEnabled
    public static void AssociateBranchAccount(String branchAccId,String ProLowAccId){
        Associated_Account__c AssocitateAcc=new Associated_Account__c();
        AssocitateAcc.Associated_Account_Name__c=ProLowAccId;
        AssocitateAcc.End_Customer_Account__c=branchAccId;
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.insert(AssocitateAcc,dml);
    }
    /**
    *   @Method:        fetchUserSessionId
    *   @Purpose:       get current logged in user session id to make api call for run the territory rule
    */
    public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionIdVF;
        // Get the content of the VF page
        String vfContent = 'Start_Of_Session_IdXYZEnd_Of_Session_Id';
        if(!test.isRunningTest()){
            vfContent = reportPage.getContent().toString();
        }
        
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
    }
    
    /**
    *   @Method:        createAdditionalAddress
    *   @Purpose:       Store additional address detail and link with branch account 
    */
    public static void createAdditionalAddress(String AdditionalAddress,String abpId,String accountType,String userCountry){
        List<RTARequest> listAddresses=(List<RTARequest>) JSON.deserialize(AdditionalAddress, List<RTARequest>.class);
        Map<String,Object> resultMap=new Map<String,Object>();
        List<SObject> duplicateRecords = new List<SObject>();
        
       
        List<Address__c> listAdddressToInsert=new List<Address__c>();   
        Map<Id,Address__c> updateaddress=new Map<Id,Address__c>();   
        // iterate over all record
        for(RTARequest req:listAddresses){
            Address__c addr = new Address__c(Street__c = req.Address+' '+req.Address2, City__c = req.City, State__c = req.State, Zipcode__c = req.Zipcode,County__c = req.county, Country__c =userCountry );
            listAdddressToInsert.add(addr);
        }
        
        AddressTriggerHandler.RUN_EBS_CALLOUT = false ;
        List<Database.SaveResult> addSaveResult = Database.insert(listAdddressToInsert, false);
        Integer i=0;
        for(Database.SaveResult Results :addSaveResult ){
            resultMap = checkDuplicates(Results);
            if(resultMap.containsKey('ErrorMessage')){
                //throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
            }
            
            duplicateRecords=(List<Sobject>)resultMap.get('duplicateRecords');
            if(duplicateRecords.size() > 0 ) 
            {
                listAdddressToInsert[i].Id = duplicateRecords[0].Id ;
                updateaddress.put(listAdddressToInsert[i].Id,listAdddressToInsert[i]);
            }
            i++;
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.update(updateaddress.values(), dml) ;
        
        
        // Address Assignment
        Map<Id,Address_Assignment__c> updatelistAA=new Map<Id,Address_Assignment__c>();
        List<Address_Assignment__c> insertlistAA=new List<Address_Assignment__c>();
        
        
        Address_Assignment__c AA;
        i=0;
        for(RTARequest request:listAddresses){
            Address__c addr=listAdddressToInsert[i];
            // Get Address Assingment for Account and AccountBranchProfile, if doesn't exists then create new one
            if(request.Business)insertlistAA.add(createAddressAssignment(addr.Id, abpId,'Business',accountType,request.BusinessIdentify,request.BusinessPrimary));
           
            if(request.BillTo)insertlistAA.add(createAddressAssignment(addr.Id, abpId,'Bill To',accountType,request.BillToIdentify,request.BillToPrimary));
                        
            if(request.ShipTo)insertlistAA.add(createAddressAssignment(addr.Id, abpId,'Ship To',accountType,request.ShipToIdentify,request.ShipToPrimary));
            
            if(request.InstallAt)insertlistAA.add(createAddressAssignment(addr.Id, abpId,'Install At',accountType,request.InstallAtIdentify,request.InstallAtPrimary));
                   
            i++;
        }
        //insert address
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
        Database.insert(insertlistAA,dml) ;
        //Database.update(updatelistAA.values(),dml) ;
        
        
    }
    
    /**
    *   @Method:        createAddressAssignment
    *   @Purpose:       create new address assignemnt records
    */
    public static Address_Assignment__c createAddressAssignment(String addrId, String accountBranchProfileId,String UsageType,String accountType,boolean Identify,boolean primary)
    {
        Address_Assignment__c addrAssignmentBillTo;
        if(addrId != null)
        {
            
            addrAssignmentBillTo = new Address_Assignment__c(  Address__c = addrId, Status__c = 'Active',
                                                                                   Identifying_Address__c = Identify, Address_Usage_Type__c = UsageType , Primary_Flag__c = primary );
            if(accountType=='Org'){
                addrAssignmentBillTo.account__c = accountBranchProfileId;
            }else if(accountType=='Person'){
                addrAssignmentBillTo.Account_Branch_Profile__c = accountBranchProfileId;
            }
        }
        return addrAssignmentBillTo;
    }
    
    public static Account_Branch_Profile__c createUpdateAccountBranchProfile(String branchId, String accountId,String phone )
    {
        // Get Account Branch Profile related to Account and Branch
        //List<Account_Branch_Profile__c> accountBranchProfiles = [SELECT Id FROM Account_Branch_Profile__c WHERE Branch__c = :branchId AND Party_Account__c = :accountId FOR UPDATE ];
        Account_Branch_Profile__c abf = new Account_Branch_Profile__c(Party_Account__c = accountId, Branch__c = branchId);
        //if(accountBranchProfiles.size() > 0 ) abf.Id = accountBranchProfiles[0].Id ;
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.SaveResult saveResult;
        if(abf.Id == null) saveResult=Database.insert(abf, dml) ;
        if(abf.Id != null) saveResult=Database.update(abf, dml) ; 
        
        return abf ;
    }
   
    /**
    *   @Method:        createUpdateAddress
    *   @Purpose:       create or update the address details
    */
    public static Address__c createUpdateAddress(RTARequest req,String userCountry)
    {
        // Insert Address and check for duplicate records
        Map<String,Object> resultMap=new Map<String,Object>();
        List<SObject> duplicateRecords = new List<SObject>();
        Address__c addr = new Address__c(Street__c = req.Address+' '+req.Address2, City__c = req.City, State__c = req.State, Zipcode__c = req.Zipcode,County__c = req.county, Country__c =userCountry );
        
        AddressTriggerHandler.RUN_EBS_CALLOUT = false ;
        Database.SaveResult addSaveResult = Database.insert(addr, false);
        resultMap = checkDuplicates(addSaveResult);
        
        if(resultMap.containsKey('ErrorMessage')){
            throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
        }
        
        duplicateRecords=(List<Sobject>)resultMap.get('duplicateRecords');
        if(duplicateRecords.size() > 0 ) 
        {
            addr.Id = duplicateRecords[0].Id ;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
           // Database.update(addr, dml) ;
        }
        return addr ;
    }
    
    public static Map<String,Object> checkDuplicates(Database.SaveResult saveResult)
    {
        Map<String,Object> resultMap=new Map<String,Object>();
        List<SObject> duplicateRecords = new List<SObject>();
        if(!saveResult.isSuccess())
        {
            for(Database.Error error : saveResult.getErrors()) 
            {
                
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
                    resultMap.put('ErrorMessage',error.getMessage() );
                    System.debug('UAC: error message ' + error.getMessage() );
                }
            }
        }
        resultMap.put('duplicateRecords',duplicateRecords);
        return resultMap ;
    }
    
    /**
    *   @Method:        getBranchName
    *   @Purpose:       get Branch Detail based on ETM for logged in users 
    */
    @AuraEnabled
    public static Map<String,Object> getBranchName(String serviceContactId) {
        Map<String,Object> returnMap=new Map<String,Object>();
        List<Branch__c> listBranch=new List<Branch__c>();
        String primaryBranchNumber='';
        Boolean isCSGUser=false;
        if(serviceContactId != NULL)
        {
            List<Branch_To_BranchGroup_Association__c> listBGA=new List<Branch_To_BranchGroup_Association__c>();
            Set<Id> setofBGAids = new Set<Id>();
            Set<Id> setofBranchids = new Set<Id>();
            Case c=[select AssignedBranch__c,AssignedBranch__r.T_C_Branch_Number__c from case where contactid = :serviceContactId order by createddate desc LIMIT 1];           
            User u=[SELECT Id,Trade_Branch_Number__c,Title, profile.name FROM User where Id=:Userinfo.getUserId()];
            if(u.profile.name != null && u.profile.name.equalsIgnoreCase('SERVICE - Corporate')){
                listBranch=[SELECT Id, Name, T_C_Branch_Number__c,Branch_Family__c,Country__c FROM Branch__c Where T_C_Branch_Number__c!=null order by Name asc];   
            }else{
                for(Branch_To_BranchGroup_Association__c BGA:[SELECT BranchGroup__c  FROM Branch_To_BranchGroup_Association__c 
                                                              WHERE Branch__c = :c.AssignedBranch__c]){
                                                                  setofBGAids.add(BGA.BranchGroup__c)  ;  
                                                              }
                for(Branch_To_BranchGroup_Association__c BGA:[SELECT Branch__c  FROM Branch_To_BranchGroup_Association__c 
                                                              WHERE BranchGroup__c in :setofBGAids and BranchGroup__r.name <> 'Corporate']){
                                                                  if(!setofBranchids.contains(BGA.Branch__c))
                                                                      setofBranchids.add(BGA.Branch__c)  ;  
                                                              }            
                listBranch = [SELECT Id, Name, T_C_Branch_Number__c,Branch_Family__c,Country__c FROM Branch__c Where id in :setofBranchids and T_C_Branch_Number__c!=null order by name];
            }
            returnMap.put('PrimaryBranch',c.AssignedBranch__r.T_C_Branch_Number__c);
            returnMap.put('BranchList',listBranch); 
            
        }    
        else{
            User u=[SELECT Id,Trade_Branch_Number__c,Title,profile.name FROM User where Id=:Userinfo.getUserId()];
            if(u.Trade_Branch_Number__c!=null){
                primaryBranchNumber=u.Trade_Branch_Number__c;
                // Added on 23-11-20 (allow CSG User to create account for any branch)
                if((u.Title!=null && u.Title.equalsIgnoreCase(Label.T_C_CSGGroupTitle)) || (u.profile.name != null && u.profile.name.equalsIgnoreCase('SERVICE - Corporate'))){
                    isCSGUser=true;
                }
            }
            
            if(isCSGUser){
                // IF CSGUser display All branch
                listBranch=[SELECT Id, Name, T_C_Branch_Number__c,Branch_Family__c,Country__c FROM Branch__c Where T_C_Branch_Number__c!=null order by Name asc];
                
            }else{
                // If not CSG user process based on ETM
                List<String> listBranchNumber=new list<String>();
                // Get list of Branch associate to logged in user
                List<UserTerritory2Association> listUTA=[SELECT Id,
                                                         Territory2Id,Territory2.Territory_Reference_Number__c,Territory2.TCBranchNumber__c ,Territory2.Territory_Type_Name__c,
                                                         Territory2.ParentTerritory2Id,Territory2.ParentTerritory2.Territory_Reference_Number__c,
                                                         Territory2.ParentTerritory2.TCBranchNumber__c,Territory2.ParentTerritory2.Territory_Type_Name__c, 
                                                         UserId, RoleInTerritory2 
                                                         FROM UserTerritory2Association Where userId = :Userinfo.getUserId()];
                
                for(UserTerritory2Association UTA:listUTA){
                    if(UTA.Territory2.Territory_Type_Name__c=='Branch'){
                        listBranchNumber.add(UTA.Territory2.TCBranchNumber__c);
                        //if(UTA.RoleInTerritory2=='Primary')primaryBranchNumber=UTA.Territory2.TCBranchNumber__c ;
                    }
                    else if(UTA.Territory2.ParentTerritory2.Territory_Type_Name__c=='Branch'){
                        listBranchNumber.add(UTA.Territory2.ParentTerritory2.TCBranchNumber__c );
                        // if(UTA.RoleInTerritory2=='Primary')primaryBranchNumber=UTA.Territory2.ParentTerritory2.TCBranchNumber__c;
                    }
                    
                } 
                
                if(listBranchNumber.size()>0){
                    listBranch=[SELECT Id, Name, T_C_Branch_Number__c,Branch_Family__c,Country__c FROM Branch__c Where T_C_Branch_Number__c in :listBranchNumber and T_C_Branch_Number__c!=null ];
                }
            }
            
            returnMap.put('PrimaryBranch',primaryBranchNumber);
            returnMap.put('BranchList',listBranch);
        }
        return returnMap;
    }
    /**
    *   @Method:        updateContactandCaseRecords
    *   @Purpose:       Link contact and case records to newly created account
    */
    public static void updateContactandCaseRecords(String serviceContactId, String accId, String searchAccType){
        system.debug('Inside updateContactandCase Method');
        List<Case> casesToUpdate = new List<Case>();
        if(searchAccType == 'Person'){
            Contact cont = [select id from contact where accountid = :accId];
            for(Case ca : [select id from Case where contactid = :serviceContactId]){
                Case c = new Case(Id = ca.id, accountid = accId,contactid = cont.id); 
                casesToUpdate.add(c);
            }
            if(casesToUpdate.size()>0)
                update casesToUpdate;
            Delete [select id from contact where id = :serviceContactId];
        }
        else if(searchAccType == 'Org'){
            Id recordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Trade_Comm_Record_Type').getRecordTypeId(); 
            Contact contact = new Contact(Id=serviceContactId, accountId=accId,recordtypeid =recordTypeId );
            update contact;
            for(Case ca : [select id from Case where contactid = :serviceContactId]){
                Case c = new Case(Id = ca.id, accountid = accId); 
                casesToUpdate.add(c);
            }
            if(casesToUpdate.size()>0)
                update casesToUpdate;
        }   
    }
    public static void createBranchAccorABPforCorporate(RTARequest request,String searchAccType,string branchid, String addressId, String AdditionalAddress,String userCountry){
        String accOrAbpId = '';
        if(searchAccType=='Org'){
            // Create child Account(Branch Account) 
            Account acc=new Account();
            acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BranchAccount').getRecordTypeId();
            acc.Name=request.OrganizationName;
            acc.Type=request.CustomerType;
            acc.Is_From_Custom_UI__c=true;
            acc.Phone=request.Phone;
            acc.Company_Email__c = request.Email;

            if(request.currentRecId==null || String.isBlank(request.currentRecId) || request.currentRecId.startsWithIgnoreCase('003')){
                acc.Branch__c=branchId;
            }
            acc.ParentId=request.RecordId;
            acc.Account_State__c = 'prospect';
            if(String.isNotBlank(request.AccStatus)){
                acc.Account_Status__c = request.AccStatus;
            }
            if(String.isNotBlank(request.AccRank)){
                acc.Account_Rank__c = request.AccRank;
            }
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            Database.SaveResult saveResult = Database.insert(acc, dml);
            System.debug('@@acc : '+acc);
            System.debug('@@saveResult : '+saveResult);
            // Run Territory Rule to share parent account with new branch account
            //if(returnRecId==null)returnRecId=acc.Id;
            accOrAbpId=acc.Id;
            //EBSFullLoad.runEnterpriseTerritoryManagementRules(request.RecordId, fetchUserSessionId());
        }
        else if(searchAccType=='Person'){
            // Create or Update Account Branch Profile related to Account and Branch
            Account_Branch_Profile__c abf = createUpdateAccountBranchProfile(branchId, request.RecordId,request.Phone);
            //if(returnRecId==null)returnRecId=abf.Id;
            EBSFullLoad.runEnterpriseTerritoryManagementRules(request.RecordId, fetchUserSessionId());
            accOrAbpId=abf.Id;
        }
        Map<Id,Address_Assignment__c> updatelistAA=new Map<Id,Address_Assignment__c>();
        List<Address_Assignment__c> insertlistAA=new List<Address_Assignment__c>();
        Address_Assignment__c AA;
        if(request.Business)
            AA=createAddressAssignment(addressId, accOrAbpId,'Business',searchAccType,request.BusinessIdentify,request.BusinessPrimary);
        if(request.Business && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA); 
            else insertlistAA.add(AA);
        }
        
        if(request.BillTo)AA=createAddressAssignment(addressId, accOrAbpId,'Bill To',searchAccType,request.BillToIdentify,request.BillToPrimary);
        if(request.BillTo && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA); 
            else insertlistAA.add(AA);
        }
        
        if(request.ShipTo)AA=createAddressAssignment(addressId, accOrAbpId,'Ship To',searchAccType,request.ShipToIdentify,request.ShipToPrimary);
        if(request.ShipTo && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA);  
            else insertlistAA.add(AA);
        }
        
        if(request.InstallAt)AA=createAddressAssignment(addressId, accOrAbpId,'Install At',searchAccType,request.InstallAtIdentify,request.InstallAtPrimary);
        if(request.InstallAt && AA!=null){
            if(AA.Id!=null)updatelistAA.put(AA.Id,AA);  
            else insertlistAA.add(AA);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
        Database.insert(insertlistAA,dml) ;
        Database.update(updatelistAA.values(),dml) ;
        
        createAdditionalAddress(AdditionalAddress,accOrAbpId,searchAccType,userCountry);
        
        if(searchAccType=='Person')
            EBSRESTCallout.createCustomerEBSCallout(request.RecordId);  
        else
            EBSRESTCallout.createCustomerEBSCallout(accOrAbpId);  
        
    }
}