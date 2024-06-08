@RestResource(urlMapping='/PostTC/*')
/************************************
 * Updated by: Dhruv Javiya
 * Update Date: 12/11/2020
 * Update Reason: change Upsert to insert and update 
 ************************************/
global without sharing class ServicePostTC 
{
    
    public static Integer partialSuccessCode=207;
    
    public class EBSRequest{
        
        public String orgname;
        public String byuser;
        public String partytype;
        public String partysubtype;
        public String spokesystemcode;
        public String partynumber;
        public String spokerecid;
        public List<Accounts> accounts;
        public List<Contacts> contacts;
        public List<Contactmethods> contactmethods;
        public String status;
        public List<Profiles> profiles;
    }
    
    public class Address {
        public String addressline1;
        public String addressline2;
        public String city;
        public String state;
        public String country;
        public String zipcode;
        public String spokerecid;
        public String spokesystemcode;
        public String byuser;
        public String status;
        public String mdmaddressid;
        public String identifyingaddress;
        
    }
    
    public class Profiles {
        public List<Profileattributes> profileattributes;
        public String mdmcontextcode;
        public String byuser;
    }
    
    public class Profileattributes {
        public String name;
        public String value;
        public String spokerecid;
        public String spokesystemcode;
        public String byuser;
    }
    
    public class Contactmethods {
        public String methodvalue;
        public String methodname;
        public String spokerecid;
        public String spokesystemcode;
        public String byuser;
        public String methodlinetype;
        public String methodsubtype;
        public String methodpurpose;
        public String mdmmethodid;
    }
    
    public class Accounts {
        public String accountname;
        public String spokerecid;
        public String spokesystemcode;
        public String byuser;
        public String status;
        public String mdmaccountid;
        public String mdmbranchid;
        public String mdmpartyid;
        public String mdmorgid;
        public String accountnumber;
        public List<Sites> sites;
    }
    public class Contacts {
        public String firstname;
        public String lastname;
        public String contactnumber;
        public String jobtitle;
        public String contactstatus;
        public String byuser;
        public String status;
        public String mdmpartyid;
        public String mdmcontactid;
        public List<Contactmethods> contactmethods;
        public List<Sites> sites;
    }
    public class Sites {
        public String addressusagecode;
        public String primaryflag;
        public String status;
        public String spokerecid;
        public String spokesystemcode;
        public String mdmaddressid;
        public String mdmbranchid;
        public String byuser;
        public Address address;
    }
    
    global class EBSResponse {
        
        //public String mdmrecid;
        public String spokerecid;
        public String message;
        public String objectcode;
        public String statuscode;
        public String spokesystemcode;
        //public List<Additionalresponsevalues> additionalresponsevalues;
        
        //public String status; 
        //public String httpStatusCode;
        //public String errorMessage ;
        public EBSResponse()
        {
            //status = 'SUCCESS';
            //httpStatusCode = '200' ;
        }
        public EBSResponse(String spokerecid,String objectcode,String message,String statuscode)
        {
            this.spokerecid=spokerecid;
            this.objectcode=objectcode;
            this.message=message;
            this.statuscode=statuscode;
            this.spokesystemcode='salesforce';
        }
    }
    
    public class Additionalresponsevalues {
        public String name;
        public String value;
    }
    
    
    @HttpPost
    global static List<EBSResponse> postData()
    {
        RestRequest reqst = Restcontext.request;
        EBSResponse res = new EBSResponse();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        String reqBody ;
        
        List<EBSResponse> listEBSResponse=new List<EBSResponse>();
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_TC_Integration__c ) ) return listEBSResponse ;
        // prepare Response
        
        
        
        try{
            EBSRequest request;
            reqBody = reqst.requestBody.toString() ;
            // Try to deserialize REQUEST
            try{
                
                // Fixed EBS Callout Issue 24-11
                AddressTriggerHandler.RUN_EBS_CALLOUT = false ;
                
                request = (EBSRequest)JSON.deserialize(reqBody,EBSRequest.class);
                
                Account acc=new Account();
                acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
                acc.Name=request.orgname;
                acc.mdmrecid__c=request.spokerecid;
                acc.Is_From_Custom_UI__c=true;
                acc.AccountNumber=request.partynumber;
                if(request.status=='A' || request.status=='I'){
                    acc.Account_Status__c=request.status=='A'?'Active':'Inactive';
                }
                if(request.partysubtype!=null){
                    String partySubType=request.partysubtype;
                    if(partySubType.toLowerCase().startsWith('person - ')){
                        partySubType=partySubType.substring(9);
                    }else if(partySubType.toLowerCase().startsWith('organization - ')){
                        partySubType=partySubType.substring(15);
                    }
                    acc.Type = partySubType;
                }
                List<Profiles> profiles=request.profiles;
                if(profiles!=null){
                    for(Profiles p :profiles){
                        for(Profileattributes PA : p.profileattributes){
                            if(PA.name=='CALL'){
                                //  acc.PersonDoNotCall=PA.value=='Yes';
                            }else if(PA.name=='AUTOCALL'){
                                acc.PersonAutoCall__c=PA.value=='Yes';
                            }else if(PA.name=='EMAIL'){
                                // acc.PersonHasOptedOutOfEmail=PA.value=='Yes';
                            }else if(PA.name=='SMS'){
                                acc.Text_Opt_Out__c=PA.value=='Yes';
                            }else if(PA.name=='MAIL'){
                                acc.Mail_Opt_Out__c=PA.value=='Yes';
                            }
                            
                        }
                    }
                }
                if(request.contactmethods!=null){
                    for(Contactmethods cm : request.contactmethods){
                        System.debug('@@methodname : '+cm.methodname);
                        if(cm.methodname=='PHONE'){
                            
                            if(cm.methodsubtype=='GEN'){
                                acc.phone=cm.methodvalue;
                                acc.mdmrecid_phone__c=cm.spokerecid;
                            }else if(cm.methodpurpose=='HOME' && cm.methodlinetype=='PHONEDAY'){
                                acc.phone=cm.methodvalue;
                                acc.mdmhomephonedayid__c=cm.spokerecid;
                            }else if(cm.methodpurpose=='MOBILE' && cm.methodlinetype=='PHONEDAY'){
                                acc.phone=cm.methodvalue;
                                acc.mdmmobilephonedayid__c=cm.spokerecid;
                            }else if(cm.methodpurpose=='WORK' && cm.methodlinetype=='PHONEDAY'){
                                acc.phone=cm.methodvalue;
                                acc.mdmworkphonedayid__c=cm.spokerecid;
                            }else if(cm.methodlinetype=='PHONEEVE'){
                                //acc.Evening_Phone_Type__c=cm.methodpurpose;
                                acc.phone=cm.methodvalue;
                                acc.MDMphoneeveId__c=cm.spokerecid;
                            }
                        }else if(cm.methodname=='EMAIL'){
                            if(ServiceUtil.isValidEmail(cm.methodvalue)){
                                acc.Company_Email__c=cm.methodvalue;
                                acc.mdmrecid_email__c=cm.spokerecid;
                            }
                        }
                    }
                }
                
                List<String> listMDMRecId=new List<String>();
                List<Accounts> accounts = request.accounts;
                set<String> listUserNames=new set<String>();
                set<String> listBranchNames=new set<String>();
                
                if(request.spokerecid!=null && !String.isBlank(request.spokerecid)){
                    listMDMRecId.add(request.spokerecid);
                }
                
                if(accounts!=null){
                    for(Accounts rec : accounts){
                        listUserNames.add(rec.byUser);
                        listBranchNames.add(rec.mdmorgid);
                        if(rec.spokerecid!=null && !String.isBlank(rec.spokerecid)){
                            listMDMRecId.add(rec.spokerecid);
                        }
                    }
                }
                system.debug('@@'+JSON.serialize(listMDMRecId));
                List<Account> listExistingAccount=[SELECT ID,mdmrecid__c,branchaccmdmrecid__c FROM Account where mdmrecid__c in :listMDMRecId or branchaccmdmrecid__c in:listMDMRecId];
                Map<String,Account> mapExistnigAcc=new Map<String,Account>();
                Map<String,Account> mapExistnigBranchAcc=new Map<String,Account>();
                for(Account accRec: listExistingAccount){
                    if(accRec.mdmrecid__c!=null && !String.isBlank(accRec.mdmrecid__c)){
                        mapExistnigAcc.put(accRec.mdmrecid__c,accRec);
                    }else if(accRec.branchaccmdmrecid__c!=null && !String.isBlank(accRec.branchaccmdmrecid__c)){
                        mapExistnigBranchAcc.put(accRec.branchaccmdmrecid__c,accRec);
                    }
                }
                
                List<User> listEBSUSer=[SELECT Id,NAME,EBS_UserName__c FROM User Where EBS_UserName__c in :listUserNames];
                Map<String,User> EbsUserMap=new Map<String,User>();
                List<Id> listUsers=new List<Id>();
                for(User u: listEBSUSer){
                    EbsUserMap.put(u.EBS_UserName__c,u);
                    listUsers.add(u.Id);
                }
                
                List<Branch__c> listBranch=[SELECT Id, Name, T_C_Branch_Number__c,Branch_Family__c,Branch_Family__r.Branch_Family_Number__c FROM Branch__c Where Branch_Family__r.Branch_Family_Number__c  in :listBranchNames];
                Map<String,List<String>> branchFamilyWiseBranch=new Map<String,List<String>>();
                Map<String,Branch__c> branchNumberWiseBranch=new Map<String,Branch__c>();
                for(Branch__c branch : listBranch){
                    if(!branchFamilyWiseBranch.containsKey(branch.Branch_Family__r.Branch_Family_Number__c)){
                        branchFamilyWiseBranch.put(branch.Branch_Family__r.Branch_Family_Number__c,new List<String>());
                    }
                    branchFamilyWiseBranch.get(branch.Branch_Family__r.Branch_Family_Number__c).add(branch.T_C_Branch_Number__c);
                    branchNumberWiseBranch.put(branch.T_C_Branch_Number__c,branch);
                }
                
                Map<String,Object> resultData=getUserWiseETMBranches(listUsers);
                
                Map<String,String> userWisePrimaryBranchNumner=(Map<String,String>)resultData.get('PrimaryBranch');
                Map<String,List<String>> userWiseBranchNumbers=(Map<String,List<String>>)resultData.get('BranchNumberList');
                
                
                
                system.debug('@@acc'+JSON.serialize(acc));
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
                
                Database.SaveResult saveResult;
                if(mapExistnigAcc.containsKey(request.spokerecid)){
                    acc.Id=mapExistnigAcc.get(request.spokerecid).Id;
                    saveResult=Database.Update(acc, dml) ;
                }else{
                    // Set Parent Account Created By
                    if(EbsUserMap.containsKey(request.byUser)){
                        //acc.CreatedById=EbsUserMap.get(request.byUser).Id;
                        acc.OwnerId=EbsUserMap.get(request.byUser).Id;
                        //acc.lastModifiedById=EbsUserMap.get(request.byUser).Id;
                    }
                    saveResult=Database.insert(acc, dml) ;
                    
                }
                
                Map<String,Object> resultMap=new Map<String,Object>();
                resultMap = checkDuplicates(saveResult);
                if(resultMap.containsKey('ErrorMessage')){
                    listEBSResponse.add(new EBSResponse('','Party',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                    restRes.statusCode=partialSuccessCode;
                    return listEBSResponse;
                }else{
                    listEBSResponse.add(new EBSResponse(acc.Id,'Party','OK','200'));
                }
                
                set<String> listAddressMDMrecId=new set<String>();
                set<String> listAAMDMrecId=new set<String>();
                
                List<Account> listChildAcc=new List<Account>();
                List<Account> listChildAccToUpdate=new List<Account>();
                Map<String,Address__c> existingAddressMdm=new Map<String,Address__c> ();
                List<Address__c> listAddress=new List<Address__c>();
                List<Address_Assignment__c> listAddressAssignment=new List<Address_Assignment__c>();
                if(accounts!=null){
                    for(Accounts rec : accounts){
                        Account childAcc=new Account();
                        childAcc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BranchAccount').getRecordTypeId();
                        childAcc.Name=rec.accountname==null?acc.Name:rec.accountname;
                        childAcc.ParentId=acc.Id;
                        childAcc.phone=Acc.phone;
                        childAcc.mdmrecid_phone__c=Acc.mdmrecid_phone__c;
                        childAcc.Company_Email__c=Acc.Company_Email__c;
                        childAcc.mdmrecid_email__c=Acc.mdmrecid_email__c;
                        childAcc.branchaccmdmrecid__c=rec.spokerecid;
                        childAcc.Is_From_Custom_UI__c=true;
                        childAcc.Oracle_Account_Number__c=rec.accountnumber;
                        //childAcc.PersonDoNotCall=acc.PersonDoNotCall;
                        childAcc.PersonAutoCall__c=acc.PersonAutoCall__c;
                        //childAcc.PersonHasOptedOutOfEmail=acc.PersonHasOptedOutOfEmail;
                        childAcc.Text_Opt_Out__c=acc.Text_Opt_Out__c;
                        childAcc.Mail_Opt_Out__c=acc.Mail_Opt_Out__c;
                        //childAcc.PersonHomePhone=acc.PersonHomePhone;
                        //childAcc.PersonMobilePhone=acc.PersonMobilePhone;
                        //childAcc.PersonOtherPhone=acc.PersonOtherPhone;
                        childAcc.Evening_Phone_Type__c=acc.Evening_Phone_Type__c;
                        //childAcc.PersonAssistantPhone=acc.PersonAssistantPhone;
                        // childAcc.PersonEmail=acc.PersonEmail;
                        // 
                        if(request.partysubtype!=null){
                            String partySubType=request.partysubtype;
                            if(partySubType.toLowerCase().startsWith('person - ')){
                                partySubType=partySubType.substring(9);
                            }else if(partySubType.toLowerCase().startsWith('organization - ')){
                                partySubType=partySubType.substring(15);
                            }
                            childAcc.Type = partySubType;
                        }
                        childAcc.Phone=acc.Phone;
                        if(rec.status=='A' || rec.status=='I'){
                            childAcc.Account_Status__c=rec.status=='A'?'Active':'Inactive';
                        }
                        
                        
                        if(mapExistnigAcc.containsKey(rec.spokerecid)){
                            childAcc.Id=mapExistnigAcc.get(rec.spokerecid).Id;
                            listChildAccToUpdate.add(childAcc);
                        }else if(mapExistnigBranchAcc.containsKey(rec.spokerecid)){
                            childAcc.Id=mapExistnigBranchAcc.get(rec.spokerecid).Id;
                            listChildAccToUpdate.add(childAcc);
                        }else{
                            if(EbsUserMap.containsKey(rec.byUser)){
                                //childAcc.CreatedById=EbsUserMap.get(rec.byUser).Id;
                                childAcc.OwnerId=EbsUserMap.get(rec.byUser).Id;
                                //childAcc.lastModifiedById=EbsUserMap.get(rec.byUser).Id;
                            }
                            childAcc.Account_State__c = 'prospect';
                            listChildAcc.add(childAcc);
                        }
                        
                        
                        if(rec.sites!=null){
                            for(Sites site : rec.sites){
                                
                                if(site.address!=null){
                                    
                                    //Added Shiping address and change in billing address condition on 24-11
                                    if(childAcc.BillingStreet==null || (site.primaryflag=='Y' && site.addressusagecode=='BILL_TO' )){
                                        childAcc.BillingStreet = ServiceUtil.checkNull(site.address.addressline1) + ' ' + ServiceUtil.checkNull(site.address.addressline2);
                                        childAcc.BillingCity=site.address.City;
                                        childAcc.BillingState=site.address.state;
                                        childAcc.BillingPostalCode=site.address.Zipcode;
                                        childAcc.BillingCountry=site.address.country;
                                    }else if(childAcc.ShippingStreet==null || (site.primaryflag=='Y' && site.addressusagecode=='SHIP_TO' )){
                                        childAcc.ShippingStreet = ServiceUtil.checkNull(site.address.addressline1) + ' ' + ServiceUtil.checkNull(site.address.addressline2);
                                        childAcc.ShippingCity=site.address.City;
                                        childAcc.ShippingState=site.address.state;
                                        childAcc.ShippingPostalCode=site.address.Zipcode;
                                        childAcc.ShippingCountry=site.address.country;
                                    }
                                    Address__c addr = new Address__c(Street__c = ServiceUtil.checkNull(site.address.addressline1) + ' ' + ServiceUtil.checkNull(site.address.addressline2), 
                                                                    City__c = site.address.City, State__c = site.address.state, Zipcode__c = site.address.Zipcode,Country__c =site.address.country );
                                    if(EbsUserMap.containsKey(site.address.byUser)){
                                        //addr.CreatedById=EbsUserMap.get(site.address.byUser).Id;
                                        addr.OwnerId=EbsUserMap.get(site.address.byUser).Id;
                                        //addr.lastModifiedById=EbsUserMap.get(site.address.byUser).Id;
                                    }
                                    addr.MDMrecid__c=site.address.spokerecid;
                                    if(addr.MDMrecid__c!=null){
                                        listAddressMDMrecId.add(addr.MDMrecid__c);
                                    }
                                    Address_Assignment__c AA=new Address_Assignment__c( Account__r = childAcc, 
                                                                                       Address__r = addr, 
                                                                                       Status__c = 'Active',
                                                                                       Identifying_Address__c = (site.address.identifyingaddress=='Y'?true:false), 
                                                                                       Address_Usage_Type__c = site.addressusagecode.replace('_',' ') , 
                                                                                       Primary_Flag__c = (site.primaryflag=='Y'?true:false) );
                                    if(EbsUserMap.containsKey(site.byUser)){
                                        //AA.CreatedById=EbsUserMap.get(site.byUser).Id;
                                        //AA.lastModifiedById=EbsUserMap.get(site.byUser).Id;
                                    }
                                    if(site.status=='A' || site.status=='I'){
                                        AA.Status__c=site.status=='A'?'Active':'Inactive';
                                    }
                                    
                                    AA.MDMrecid__c=site.spokerecid;
                                    
                                    if(AA.MDMrecid__c!=null){
                                        listAAMDMrecId.add(AA.MDMrecid__c);
                                    }
                                    
                                    
                                    if(!existingAddressMdm.containsKey(addr.mdmrecid__c)){
                                        listAddress.add(addr);
                                        existingAddressMdm.put(addr.mdmrecid__c,addr);
                                    }else{
                                        AA.Address__r = existingAddressMdm.get(addr.mdmrecid__c);
                                    }
                                      
                                    
                                    listAddressAssignment.add(AA);
                                    System.debug('@@AA :: '+JSON.serialize(AA));
                                    System.debug('@@AA :: '+JSON.serialize(AA.Address__r));
                                    System.debug('@@AA :: '+AA.MDMrecid__c);
                                    System.debug('@@AA :: '+AA.Address__r.MDMrecid__c);
                                }
                                
                            }
                        }
                         System.debug('@@AA :: '+JSON.serialize(listAddressAssignment));
                        // Branch Assignment
                        if(EbsUserMap.containsKey(rec.byUser)){
                            User branchUser=EbsUserMap.get(rec.byUser);
                            list<String> listBranchIds=userWiseBranchNumbers.get(branchUser.Id);
                            String PrimaryBranchNumber=userWisePrimaryBranchNumner.containsKey(rec.byUser)?userWisePrimaryBranchNumner.get(rec.byUser):'';
                            if(listBranchIds==null || listBranchIds.size()==0){
                                // User Not Configured in the ETM System
                                listEBSResponse.add(new EBSResponse('','account','User Not Configured in the ETM System','400'));
                                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),'Integration'));
                                restRes.statusCode=partialSuccessCode;
                                return listEBSResponse;
                            }else{
                                if(branchFamilyWiseBranch.containsKey(rec.mdmorgid)){
                                    String selectedbranchId='';
                                    for(String branchNumber :branchFamilyWiseBranch.get(rec.mdmorgid)){
                                        if(listBranchIds.contains(branchNumber)){
                                            if(selectedbranchId=='' || PrimaryBranchNumber== branchNumber){
                                                selectedbranchId=branchNumberWiseBranch.get(branchNumber).id;
                                            }
                                        }
                                    }
                                    if(selectedbranchId==''){
                                        // User not related with this branch family
                                        listEBSResponse.add(new EBSResponse('','account','User not related with this branch family','400'));
                                        new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),'Integration'));
                                        restRes.statusCode=partialSuccessCode;
                                        return listEBSResponse;
                                    }else{
                                       if(!mapExistnigBranchAcc.containsKey(rec.spokerecid))
                                        childAcc.Branch__c=selectedbranchId;
                                    }
                                    
                                }else{
                                    // Branch Family Number Not Found in the System
                                    listEBSResponse.add(new EBSResponse('','account','Branch Family Number Not Found in the System','400'));
                                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),'Integration'));
                                    restRes.statusCode=partialSuccessCode;
                                    return listEBSResponse;
                                }
                            }
                        }else{
                            // User Not Found in the System
                            listEBSResponse.add(new EBSResponse('','account','User Not Found in the System','400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                        }
                    }
                }
                // Create Child Accounts
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
                
                Map<String,String> partyIdWiseRecordId=new Map<String,String>();
                //List<Database.SaveResult> detailResult =Database.insert(listChildAcc, dml);
                
                List<Address__c> listExisitngAddress=[SELECT ID,NAME,MDMrecid__c FROM Address__c Where MDMrecid__c in :listAddressMDMrecId];
                List<Address_Assignment__c> listExisitngAA=[SELECT ID,NAME,MDMrecid__c FROM Address_Assignment__c Where MDMrecid__c in :listAAMDMrecId];
                Map<String,Address__c> mapMDMRecIdWiseAddress=new Map<String,Address__c>();
                Map<String,Address_Assignment__c> mapMDMRecIdWiseAA=new Map<String,Address_Assignment__c>();
                
                for(Address__c Addr:listExisitngAddress){
                    mapMDMRecIdWiseAddress.put(Addr.MDMrecid__c,Addr);
                }
                for(Address_Assignment__c AA: listExisitngAA){
                    mapMDMRecIdWiseAA.put(AA.MDMrecid__c,AA);
                }
                // Address Create/Update 
                List<Address__c> listAddrToUpdate=new List<Address__c>();
                List<Address__c> listAddrToCreate=new List<Address__c>();
                 for(Address__c addr: listAddress){
                    if(mapMDMRecIdWiseAddress.containsKey(addr.MDMrecid__c)){
                        addr.Id=mapMDMRecIdWiseAddress.get(addr.MDMrecid__c).Id;
                        listAddrToUpdate.add(addr);
                    }else{
                        listAddrToCreate.add(addr);
                    }
                }
                
                Integer i=0;
                // List Of Child Account to insert
                if(listChildAcc.size()>0){
                    List<Database.SaveResult>  detailResult = Database.insert(listChildAcc,dml);
                    i=0;
                    for(Database.SaveResult Results :detailResult ){
                        resultMap = checkDuplicates(Results);
                        if(resultMap.containsKey('ErrorMessage')){
                            listEBSResponse.add(new EBSResponse('','account',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                            
                        }else{
                            listEBSResponse.add(new EBSResponse(listChildAcc[i].Id,'account','OK','200'));
                        }
                        
                        partyIdWiseRecordId.put(request.spokerecid,listChildAcc[i].Id);
                        i++;
                    }
                }
                // List Of Child Account to insert
                if(listChildAccToUpdate.size()>0){
                    List<Database.SaveResult>  detailResult = Database.Update(listChildAccToUpdate,dml);
                    i=0;
                    for(Database.SaveResult Results :detailResult ){
                        resultMap = checkDuplicates(Results);
                        if(resultMap.containsKey('ErrorMessage')){
                            listEBSResponse.add(new EBSResponse('','account',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                            
                        }else{
                            listEBSResponse.add(new EBSResponse(listChildAccToUpdate[i].Id,'account','OK','200'));
                        }
                        
                        partyIdWiseRecordId.put(request.spokerecid,listChildAccToUpdate[i].Id);
                        i++;
                    }
                }
                
                
                
                List<Contact> listContact=new List<Contact>();
                
                // Create Contact
                if(request.contacts!=null){
                    for(Contacts rec : request.contacts){
                        Contact con=new Contact();
                        con.FirstName=rec.firstname;
                        con.LastName=rec.lastname;
                        con.mdmrecid__c=rec.mdmcontactid;
                        if(partyIdWiseRecordId.containsKey(rec.mdmpartyid)){
                            con.AccountId=partyIdWiseRecordId.get(rec.mdmpartyid);
                        }
                        if(EbsUserMap.containsKey(rec.byUser)){
                            //con.CreatedById=EbsUserMap.get(rec.byUser).Id;
                            con.OwnerId=EbsUserMap.get(rec.byUser).Id;
                            //con.lastModifiedById=EbsUserMap.get(rec.byUser).Id;
                        }
                        
                        con.Title=rec.jobtitle;
                        
                        listContact.add(con);
                        if(rec.sites!=null){
                            for(Sites site : rec.sites){
                                if(site.address!=null){
                                    if(con.MailingStreet==null || site.primaryflag=='Y' ){
                                        con.MailingStreet=site.address.addressline1+' '+site.address.addressline2;
                                        con.MailingCity=site.address.City;
                                        con.MailingState=site.address.state;
                                        con.MailingPostalCode=site.address.Zipcode;
                                        con.MailingCountry=site.address.country;
                                    }
                                }
                            }
                        }
                        if(rec.contactmethods!=null){
                            for(Contactmethods cm : rec.contactmethods){
                                if(cm.methodname=='PHONE'){
                                    if(cm.methodsubtype=='MOBILE'){
                                        con.MobilePhone=cm.methodvalue;
                                    }else if(cm.methodpurpose=='HOME' && cm.methodlinetype=='PHONEDAY'){
                                        con.HomePhone=cm.methodvalue;
                                    }else if(cm.methodpurpose=='MOBILE' && cm.methodlinetype=='PHONEDAY'){
                                        con.MobilePhone=cm.methodvalue;
                                    }else if(cm.methodpurpose=='WORK' && cm.methodlinetype=='PHONEDAY'){
                                        con.OtherPhone=cm.methodvalue;
                                    }else if(cm.methodlinetype=='PHONEEVE'){
                                        //con.Evening_Phone_Type__c=cm.methodpurpose;
                                        con.AssistantPhone=cm.methodvalue;
                                    }
                                }else if(cm.methodname=='EMAIL'){
                                    if(ServiceUtil.isValidEmail(cm.methodvalue)){
                                        con.Email=cm.methodvalue;
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    // create contact
                    i=0;
                    List<Database.UpsertResult> addContactSaveResult = Database.upsert(listContact, Contact.Field.mdmrecid__c,false);
                    for(Database.UpsertResult Results :addContactSaveResult ){
                        resultMap = checkDuplicates(Results);
                        if(resultMap.containsKey('ErrorMessage')){
                            //throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
                            listEBSResponse.add(new EBSResponse('','contact',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                        }
                        listEBSResponse.add(new EBSResponse(listContact[i].Id,'contact','OK','200'));
                        i++;
                    }
                    
                }
                // Create Address Record
                Map<Id,Address__c> updateaddress=new Map<Id,Address__c>();   
                
                if(listAddrToCreate.size()>0){
                    AddressTriggerHandler.RUN_EBS_CALLOUT = false ;
                    List<Database.SaveResult>  detailResult = Database.insert(listAddrToCreate,dml);
                    i=0;
                    for(Database.SaveResult Results :detailResult ){
                        resultMap = checkDuplicates(Results);
                        if(resultMap.containsKey('ErrorMessage')){
                            //throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
                            listEBSResponse.add(new EBSResponse('','address',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                        }
                        listEBSResponse.add(new EBSResponse(listAddrToCreate[i].Id,'address','OK','200'));
                        i++;
                    }
                }
                if(listAddrToUpdate.size()>0){
                    AddressTriggerHandler.RUN_EBS_CALLOUT = false ;
                    List<Database.SaveResult>  detailResult = Database.Update(listAddrToUpdate,dml);
                    i=0;
                    for(Database.SaveResult Results :detailResult ){
                        resultMap = checkDuplicates(Results);
                        if(resultMap.containsKey('ErrorMessage')){
                            //throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
                            listEBSResponse.add(new EBSResponse('','address',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                        }
                        listEBSResponse.add(new EBSResponse(listAddrToUpdate[i].Id,'address','OK','200'));
                        i++;
                    }
                }
               
                
                system.debug('@@listAddressAssignment'+JSON.serialize(listAddressAssignment));
                List<Address_Assignment__c> listAAToCreate=new List<Address_Assignment__c>();
                List<Address_Assignment__c> listAAToUpdate=new List<Address_Assignment__c>();
                for(Address_Assignment__c AA: listAddressAssignment){
                    AA.Account__c=AA.Account__r.Id;
                    AA.Address__c=AA.Address__r.Id;
                    AA.Account__r=null;
                    AA.Address__r=null; 
                    system.debug('@@mapMDMRecIdWiseAA'+mapMDMRecIdWiseAA.containsKey(AA.MDMrecid__c));
                    if(mapMDMRecIdWiseAA.containsKey(AA.MDMrecid__c)){
                        AA.Id=mapMDMRecIdWiseAA.get(AA.MDMrecid__c).Id;
                        listAAToUpdate.add(AA);
                    }else{
                        listAAToCreate.add(AA);
                    }
                }
                
                
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true; 
                
                if(listAAToCreate.size()>0){
                    AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                    List<Database.SaveResult>  detailResult = Database.insert(listAAToCreate,dml);
                    i=0;
                    for(Database.SaveResult Results :detailResult ){
                        resultMap = checkDuplicates(Results);
                        if(resultMap.containsKey('ErrorMessage')){
                            //throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
                            listEBSResponse.add(new EBSResponse('','addressassignment',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                        }
                        listEBSResponse.add(new EBSResponse(listAAToCreate[i].Address__c,'addressassignment','OK','200'));
                        i++;
                    }
                }
                if(listAAToUpdate.size()>0){
                    AddressAssignmentTriggerHandler.RUN_EBS_CALLOUT = FALSE ;
                    List<Database.SaveResult>  detailResult = Database.update(listAAToUpdate,dml);
                    i=0;
                    for(Database.SaveResult Results :detailResult ){
                        resultMap = checkDuplicates(Results);
                        if(resultMap.containsKey('ErrorMessage')){
                            //throw new AuraHandledException(String.valueOf(resultMap.get('ErrorMessage')));
                            listEBSResponse.add(new EBSResponse('','addressassignment',String.valueOf(resultMap.get('ErrorMessage')),'400'));
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,JSON.serialize(listEBSResponse),String.valueOf(resultMap.get('ErrorMessage')),'Integration'));
                            restRes.statusCode=partialSuccessCode;
                            return listEBSResponse;
                        }
                        listEBSResponse.add(new EBSResponse(listAAToUpdate[i].Address__c,'addressassignment','OK','200'));
                        i++;
                    }
                }
                
                
                
                
                
            }catch (Exception e){
                system.debug('@@'+e);
                listEBSResponse.add(new EBSResponse('','Party','INVALID_INPUT_FORMAT','400'));
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqBody,e,'Integration'));
                restRes.statusCode=partialSuccessCode;
                return listEBSResponse;
            }
            
            // Information Log Added on 26-02
            new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePostTC','postData',JSON.serialize(listEBSResponse),reqBody,'Integration'));
            
            //new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePostTC','postData',JSON.serialize(res),reqBody,'Integration'));
            
        }
        catch(Exception ex){
            System.debug('UAC: exception ' + ex.getMessage() );
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostTC','postData',reqst.requestBody.toString(),ex,'Integration'));
        }
        
        return listEBSResponse;
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
    public static Map<String,Object> checkDuplicates(Database.UpsertResult saveResult)
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
    
    @AuraEnabled
    public static Map<String,Object> getUserWiseETMBranches(list<Id> listUserIds) {
        
        Map<String,Object> returnMap=new Map<String,Object>();
        List<Branch__c> listBranch=new List<Branch__c>();
        Map<String,String> userWisePrimaryBranchNumner=new Map<String,String>();
        Map<String,List<String>> userWiseBranchNumbers=new Map<String,List<String>>();
        
        List<User> listUser=[SELECT Id,Trade_Branch_Number__c FROM User where Id=:listUserIds];
        for(User u : listUser){
            if(u.Trade_Branch_Number__c!=null){
                userWisePrimaryBranchNumner.put(u.Id,u.Trade_Branch_Number__c);
            }
        }
        
        // Get list of Branch associate to logged in user
        List<UserTerritory2Association> listUTA=[SELECT Id,
                                                 Territory2Id,Territory2.Territory_Reference_Number__c,Territory2.TCBranchNumber__c ,Territory2.Territory_Type_Name__c,
                                                 Territory2.ParentTerritory2.TCBranchNumber__c,Territory2.ParentTerritory2Id,Territory2.ParentTerritory2.Territory_Reference_Number__c,Territory2.ParentTerritory2.Territory_Type_Name__c, 
                                                 UserId, RoleInTerritory2 
                                                 FROM UserTerritory2Association Where userId = :listUserIds];
        
        for(UserTerritory2Association UTA:listUTA){
            if(!userWiseBranchNumbers.containsKey(UTA.userId)){
                userWiseBranchNumbers.put(UTA.userId,new List<String>());
            }
            if(UTA.Territory2.Territory_Type_Name__c=='Branch'){
                userWiseBranchNumbers.get(UTA.userId).add(UTA.Territory2.TCBranchNumber__c);
                //if(UTA.RoleInTerritory2=='Primary')userWisePrimaryBranchNumner.put(UTA.userId,UTA.Territory2.TCBranchNumber__c);
            }
            else if(UTA.Territory2.ParentTerritory2.Territory_Type_Name__c=='Branch'){
                userWiseBranchNumbers.get(UTA.userId).add(UTA.Territory2.ParentTerritory2.TCBranchNumber__c);
                //if(UTA.RoleInTerritory2=='Primary')userWisePrimaryBranchNumner.put(UTA.userId,UTA.Territory2.ParentTerritory2.TCBranchNumber__c);
            }
            
        }
        
        returnMap.put('PrimaryBranch',userWisePrimaryBranchNumner);
        returnMap.put('BranchNumberList',userWiseBranchNumbers);
        
        return returnMap;
    }
    
}