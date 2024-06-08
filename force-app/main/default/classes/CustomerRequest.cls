/*
Created By: Anh Phan
Created Date: 11/28/2019
Purpose: This class is used to fetch and map required customer request for callouts.
----------------------------------------------------------------------------------------------
Modified By:Sachin Padhiyar
Modified Date.: 04/01/2020
Purpose: Retunning status code form handleCustomerResponse method to indentify error or success.
-------------------------------------------------------------------------------------------------
*/

public without sharing class  CustomerRequest {
    public static String updateCustomerRequest(String accId,String SetNullBody) {
        return updateCustomerRequest(accId,false,SetNullBody);
    }
    //Creating updateCustomer data for EBS
    public static String updateCustomerRequest(String accId,Boolean isOwnerChange,String SetNullBody) {
        
        Account acc=[SELECT Id,Name,fax,mdmfaxid__c,website,mdmwebsiteId__c,type,RecordType.DeveloperName,Store_Name__c,mdmrecid_phone__c,oracle_Account_Number__c,parent.AccountNumber,Parent.Account_Number__c,FirstName,LastName,Company_Email__c,Phone,Account_Status__c,Description,
                     mdmrecid_email__c,Branch_Number__c,mdmhomephonedayid__c,mdmmobilephonedayid__c,mdmworkphonedayid__c,MDMphoneeveId__c,Evening_Phone_Type__c,
                     PersonHomePhone,PersonAssistantPhone,PersonMobilePhone,PersonOtherPhone,PersonEmail,PersonHasOptedOutOfEmail,PersonDoNotCall,
                     Text_Opt_Out__c,Mail_Opt_Out__c,PersonAutoCall__c,Parent.mdmrecid__c,branchaccmdmrecid__c,Territory_Name__c,Pella_Region__c,Customer_Region__c,
                     Store_Number__c,Account_Number__c,Inside_Sales_Rep__c,Inside_Sales_Rep__r.EBS_UserName__c,Ad_Patch__c,Division__c,District__c,Supply_DC__c,
                     Sq_Footage__c,Open_Date__c,Close_Date__c,NA_Type__c,Parent.branchaccmdmrecid__c ,Sales_Rep__c,owner.EBS_UserName__c ,
                     rsm_dsm_overwrite__c,RSM_DSM_Overwrite__r.firstname,RSM_DSM_Overwrite__r.ebs_username__c, RSM_DSM_Overwrite__r.lastname,rbm_overwrite__c,rbm_overwrite__r.ebs_username__c, rbm_overwrite__r.firstname, rbm_overwrite__r.lastname
                     FROM Account WHERE Id = :accId];
        Account_Branch_Profile__c ABP;
        /*List<Account_Branch_Profile__c> ABPList=[SELECT Id,Name, Party_Account__c, Branch__r.Branch_Number__c FROM Account_Branch_Profile__c WHERE Party_Account__c=:acc.Id order by lastmodifieddate desc Limit 1];
if(ABPList.size()>0){
ABP=ABPList[0];
}
List<Address_Assignment__c> listAddressAssignment=new List<Address_Assignment__c>();
if(ABP!=null){
listAddressAssignment=[SELECT Id, Name, Address__c, Account_Branch_Profile__c, Full_Address__c, Primary_Flag__c, Identifying_Address__c, Status__c, Address_Usage_Type__c, 
Address__r.Name, Address__r.Street__c, Address__r.City__c, Address__r.Country__c, Address__r.State__c, Address__r.Zipcode__c, Address__r.County__c, Address__r.Location_Id__c
FROM Address_Assignment__c Where Account_Branch_Profile__c =:ABP.Id ];
}*/
        String byUser='PELSFINTEGRATION';
        User u=[SELECT id,name,EBS_UserName__c FROM User WHERE id = :Userinfo.getUserId()];
        if(String.isNotBlank(u.EBS_UserName__c)){
            byUser=u.EBS_UserName__c.toUpperCase();
        }
        EBSRequest req = new EBSRequest();
        
        if(acc.RecordType.DeveloperName=='PersonAccount'){
            req.firstname=acc.FirstName;
            req.lastname=acc.LastName;
            req.partytype='PERSON';
            //req.partysubtype='Person - '+ acc.type;
        }else{
            req.orgname=acc.Name;
        }
        if(acc.RecordType.DeveloperName=='ORGANIZATION'){
            //req.partysubtype=acc.type;
            //req.partysubtype='Organization - '+acc.type;
        }
        req.byUser=byUser;
        req.spokesystemcode='Salesforce';
        req.spokerecid=acc.Id;
        
        //req.accounts=new List<Accounts>();
        if(String.isNotBlank(acc.Account_Status__c)){
            req.status=acc.Account_Status__c=='Active'?'A':acc.Account_Status__c=='Inactive'?'I':'';
        }
        //Add Accounts
        req.contactmethods=new List<contactmethods>();
        
        contactmethods cm=new contactmethods();
        
        //Create contactmethods
        if(acc.PersonAssistantPhone!=null || acc.PersonOtherPhone!=null || acc.PersonMobilePhone !=null || acc.PersonHomePhone!=null ){
            /* cm.methodvalue= acc.PersonHomePhone != null ? ServiceUtil.formatPhone(acc.PersonHomePhone) : 
acc.PersonMobilePhone != null ? ServiceUtil.formatPhone(acc.PersonMobilePhone) : 
acc.PersonOtherPhone != null ? ServiceUtil.formatPhone(acc.PersonOtherPhone) : ServiceUtil.formatPhone(acc.PersonAssistantPhone) ;
cm.methodname='PHONE';
cm.spokerecid=acc.Id;
cm.spokesystemcode='Salesforce';
cm.byuser=byuser;
req.contactmethods.add(cm);*/
            if(acc.PersonHomePhone!=null){
                cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(acc.PersonHomePhone); 
                cm.methodname='PHONE';
                cm.methodpurpose='HOME';
                cm.methodlinetype='PHONEDAY';
                cm.spokerecid=acc.Id;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                if(!String.isBlank(acc.mdmhomephonedayid__c)){
                    cm.mdmmethodid=acc.mdmhomephonedayid__c;
                }
                req.contactmethods.add(cm);
            }
            if(acc.PersonMobilePhone!=null){
                cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(acc.PersonMobilePhone); 
                cm.methodname='PHONE';
                cm.methodpurpose='MOBILE';
                cm.methodlinetype='PHONEDAY';
                cm.spokerecid=acc.Id;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                if(!String.isBlank(acc.mdmmobilephonedayid__c)){
                    cm.mdmmethodid=acc.mdmmobilephonedayid__c;
                }
                req.contactmethods.add(cm);
            }
            if(acc.PersonOtherPhone!=null){
                cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(acc.PersonOtherPhone); 
                cm.methodname='PHONE';
                cm.methodpurpose='WORK';
                cm.methodlinetype='PHONEDAY';
                cm.spokerecid=acc.Id;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                if(!String.isBlank(acc.mdmworkphonedayid__c)){
                    cm.mdmmethodid=acc.mdmworkphonedayid__c;
                }
                req.contactmethods.add(cm);
            }
            if(acc.PersonAssistantPhone!=null && acc.Evening_Phone_Type__c!=null){
                cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(acc.PersonAssistantPhone); 
                cm.methodname='PHONE';
                cm.methodpurpose=acc.Evening_Phone_Type__c;
                cm.methodlinetype='PHONEEVE';
                cm.spokerecid=acc.Id;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                if(!String.isBlank(acc.MDMphoneeveId__c)){
                    cm.mdmmethodid=acc.MDMphoneeveId__c;
                }
                req.contactmethods.add(cm);
            }
        }
        
        if(acc.PersonEmail!=null && acc.PersonEmail!=''){
            cm=new contactmethods();
            cm.methodvalue=acc.PersonEmail;
            cm.methodname='EMAIL';
            cm.spokerecid=acc.Id;
            cm.spokesystemcode='Salesforce';
            
            cm.byuser=byuser;
            if(!String.isBlank(acc.mdmrecid_email__c)){
                cm.mdmmethodid=acc.mdmrecid_email__c;
            }
            req.contactmethods.add(cm);
        }
        if(acc.Fax!=null && acc.Fax!=''){
            cm=new contactmethods();
            cm.methodvalue=acc.Fax;
            cm.methodname='PHONE';
            cm.methodpurpose='BUSINESS';
            cm.methodlinetype='FAX';
            cm.spokerecid=acc.Id+'_PHONE_BUSINESS_FAX';
            cm.spokesystemcode='Salesforce';
            cm.byuser=byuser;
            if(!String.isBlank(acc.mdmfaxid__c)){
                cm.mdmmethodid=acc.mdmfaxid__c;
            }
            req.contactmethods.add(cm);
        }
        if(acc.Website!=null && acc.Website!=''){
            cm=new contactmethods();
            cm.methodvalue=acc.Website;
            cm.methodname='WEB';
            cm.methodpurpose='HOMEPAGE';
            cm.spokerecid=acc.Id+'_WEB_HOMEPAGE';
            cm.spokesystemcode='Salesforce';
            cm.byuser=byuser;
            if(!String.isBlank(acc.mdmwebsiteId__c)){
                cm.mdmmethodid=acc.mdmwebsiteId__c;
            }
            req.contactmethods.add(cm);
        }
        
        if(acc.RecordType.DeveloperName!='PersonAccount'){
            if(acc.Company_Email__c!=null && acc.Company_Email__c!=''){
                cm=new contactmethods();
                cm.methodvalue=acc.Company_Email__c;
                cm.methodname='EMAIL';
                cm.spokerecid=acc.Id;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                if(!String.isBlank(acc.mdmrecid_email__c)){
                    cm.mdmmethodid=acc.mdmrecid_email__c;
                }
                req.contactmethods.add(cm);
            }
            if(acc.Phone!=null && acc.Phone!=''){
                cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(acc.Phone);
                cm.methodname='PHONE';
                cm.methodlinetype='GEN';
                cm.methodpurpose='BUSINESS';
                cm.spokerecid=acc.Id;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                if(!String.isBlank(acc.mdmrecid_phone__c)){
                    cm.mdmmethodid=acc.mdmrecid_phone__c;
                }
                req.contactmethods.add(cm);
            }
        }
        
        req.profiles=new List<profiles>();
        
        profiles profile=new profiles();
        
        profile.profileattributes=new List<profileattributes>();
        
        profileattributes PA=new profileattributes();
        PA.name='CALL';
        PA.value=!acc.PersonDoNotCall?'Yes':'No';
        PA.spokerecid=acc.Id;
        PA.spokesystemcode='Salesforce';
        PA.byuser=byuser;
        profile.profileattributes.add(PA);
        
        PA=new profileattributes();
        PA.name='AUTOCALL';
        PA.value=!acc.PersonAutoCall__c?'Yes':'No';
        PA.spokerecid=acc.Id;
        PA.spokesystemcode='Salesforce';
        PA.byuser=byuser; 
        profile.profileattributes.add(PA);
        
        PA=new profileattributes();
        PA.name='EMAIL';
        PA.value=!acc.PersonHasOptedOutOfEmail?'Yes':'No';
        PA.spokerecid=acc.Id;
        PA.spokesystemcode='Salesforce';
        PA.byuser=byuser;
        profile.profileattributes.add(PA);
        
        PA=new profileattributes();
        PA.name='SMS';
        PA.value=!acc.Text_Opt_Out__c?'Yes':'No';
        PA.spokerecid=acc.Id;
        PA.spokesystemcode='Salesforce';
        PA.byuser=byuser;
        profile.profileattributes.add(PA);
        
        PA=new profileattributes();
        PA.name='MAIL';
        PA.value=!acc.Mail_Opt_Out__c?'Yes':'No';
        PA.spokerecid=acc.Id;
        PA.spokesystemcode='Salesforce';
        PA.byuser=byuser;
        profile.profileattributes.add(PA);
        
        profile.mdmcontextcode='contactmethods';
        profile.byuser=byuser;
        
        // Remove profile section for trade and Commercial
        if(acc.RecordType.DeveloperName=='PersonAccount'){
            req.profiles.add(profile);
        }else{
            req.profiles=null;
        }
        
        req.accounts=new List<Accounts>();
        Accounts account=new Accounts();
        account.accountname=acc.Name;
        
        if(acc.RecordType.DeveloperName=='Pro_Lowes'){
            account.mdmbranchid=acc.Branch_Number__c;
            req.knownas=acc.Store_Name__c;
            // account.knownas=acc.Store_Name__c;
            account.mdmaccountid=acc.branchaccmdmrecid__c;
            account.byuser=byuser;
            account.attributecontext='NA Additional Info';
            // if(SetNullBody == 'SendNULLBody'){
            //    account.attribute10='NULL';
            //}else{
            IF (acc.rsm_dsm_overwrite__c <> null)
                account.attribute8= acc.rsm_dsm_overwrite__r.ebs_username__c;     //acc.rsm_dsm_overwrite__r.firstname+' '+acc.rsm_dsm_overwrite__r.lastname;
            IF (acc.rbm_overwrite__c <> null)
                account.attribute9=  acc.rbm_overwrite__r.ebs_username__c;                 //acc.rbm_overwrite__r.firstname+' '+acc.rbm_overwrite__r.lastname;
            
            /*List<AccountTeamMember> listAccTeam=[SELECT ID,User.Name, AccountId,UserId,User.EBS_UserName__c FROM AccountTeamMember Where TeamMemberRole='Inside Sales Support' and AccountId=:acc.Id ORDER BY LastModifiedDate desc];
            if(listAccTeam.size()>0){ 
                account.attribute10=listAccTeam[0].User.Name;  // Rekha (6/18/21) changed name from EBS_UserName__c;
            }
            else{
                account.attribute10='NULL';
            }*/
            if(String.isNotBlank(acc.Account_Status__c))
            account.status=acc.Account_Status__c=='Active'?'A':acc.Account_Status__c=='Inactive'?'I':'';
            account.attribute11=acc.Ad_Patch__c;
            account.attribute10=string.valueOf(acc.Customer_Region__c);
            account.attribute12=string.valueOf(acc.Pella_Region__c);
            account.attribute13=acc.Division__c;
            account.attribute14=string.valueOf(acc.District__c);
            account.attribute15=string.valueOf(acc.Supply_DC__c);
            account.attribute16=string.valueOf(acc.Territory_Name__c);
            account.attribute17=string.valueOf(acc.Open_Date__c);
            account.attribute18=string.valueOf(acc.Close_Date__c);
            // IF   (acc.Description ==null)
            //  account.attribute19 = '';
            //else
            account.attribute19=acc.Description;
            account.attribute1=acc.NA_Type__c;
            account.Relationship=new Relationship();
            account.Relationship.relationcode='PARENT';
            account.Relationship.relatedmdmpartyid=acc.Parent.mdmrecid__c;
            account.Relationship.relatedmdmaccountid=acc.parent.branchaccmdmrecid__c;
            account.profileclass='NA';
            
            // If owner change also send address assigment
            if(isOwnerChange){
                List<Address_Assignment__c>   listAddressAssignment=[SELECT Id,mdmrecId__c,HQ_Bill_To__r.MDMrecid__c, Name, Address__c, Account_Branch_Profile__c,Account__c, Full_Address__c, Primary_Flag__c, Identifying_Address__c, Status__c, Address_Usage_Type__c, 
                                                                     Address__r.mdmrecId__c,Address__r.Name,Address__r.Address_Line_1__c,Address__r.Address_Line_3__c, Address__r.Street__c, Address__r.City__c, Address__r.Country__c, Address__r.State__c, Address__r.Zipcode__c, Address__r.County__c, Address__r.Location_Id__c
                                                                     FROM Address_Assignment__c Where Account__c =:acc.Id ];
                account.sites=new List<Sites>();
                
                for(Address_Assignment__c AA : listAddressAssignment){
                    Sites sites=new Sites();
                    sites.addressusagecode=String.isNotBlank(AA.Address_Usage_Type__c)?AA.Address_Usage_Type__c.replace(' ','_').toUpperCase():AA.Address_Usage_Type__c;
                    sites.primaryflag=AA.Primary_Flag__c?'Y':'N';
                    
                    if(String.isNotBlank(AA.Status__c)){
                        sites.status=AA.Status__c=='Active'?'A':AA.Status__c=='Inactive'?'I':'';
                    }
                    sites.spokerecid=AA.Id;
                    sites.spokesystemcode='Salesforce';
                    sites.mdmaddressid=AA.mdmrecId__c;
                    sites.salesrep=acc.owner.EBS_UserName__c;
                    sites.billtositeuseid=AA.HQ_Bill_To__r.MDMrecid__c;
                    sites.byuser=byuser;
                    sites.address=new address();
                    sites.address.mdmaddressid=AA.Address__r.mdmrecId__c;
                    sites.address.addressline1=AA.Address__r.Street__c;
                    if(!String.isBlank(AA.Address__r.Address_Line_1__c)){
                        sites.address.addressline1=AA.Address__r.Address_Line_1__c;
                        sites.address.addressline2=AA.Address__r.Street__c;
                        sites.address.addressline3=AA.Address__r.Address_Line_3__c;
                    }
                    
                    sites.address.city=AA.Address__r.City__c;
                    sites.address.state=AA.Address__r.State__c;
                    sites.address.country=AA.Address__r.Country__c;
                    sites.address.zipcode=AA.Address__r.Zipcode__c;
                    sites.address.spokerecid=AA.Address__c;
                    sites.address.spokesystemcode='Salesforce';
                    sites.address.byuser=byuser;
                    sites.address.identifyingaddress=AA.Identifying_Address__c?'Y':'N';
                    if(String.isNotBlank(AA.Status__c)){
                        sites.address.status=AA.Status__c=='Active'?'A':AA.Status__c=='Inactive'?'I':'';
                    }
                    
                    account.sites.add(sites);
                }
                
            }
            
        }
        req.accounts.add(account);
        
        return JSON.serialize(req,true);
        
    }//End of createCustomerRequest
    
    //Creating createCustomer data for EBS
    public static String createCustomerRequest(String AccId) {
        try{
            Account acc=[SELECT Id,Name,Fax,mdmfaxid__c,website,mdmwebsiteId__c,FirstName,LastName,oracle_Account_Number__c,Store_Name__c,Territory_Name__c,Pella_Region__c,Customer_Region__c,parent.mdmrecid__c,type,Branch__r.Branch_Number__c,Parent.Account_Number__c,Company_Email__c,Description,
                         Phone,Branch_Number__c,Branch__r.Branch_Family__r.Branch_Family_Number__c ,parentId,RecordTypeId,RecordType.DeveloperName,
                         Account_Status__c,Evening_Phone_Type__c,PersonHomePhone,PersonAssistantPhone,PersonMobilePhone,
                         PersonOtherPhone,PersonEmail,PersonHasOptedOutOfEmail,PersonDoNotCall,Text_Opt_Out__c,Mail_Opt_Out__c,PersonAutoCall__c,
                         Store_Number__c,Account_Number__c,Inside_Sales_Rep__c,Inside_Sales_Rep__r.EBS_UserName__c,Ad_Patch__c,Division__c,District__c,Supply_DC__c,
                         Sq_Footage__c,Open_Date__c,Close_Date__c,NA_Type__c,Parent.branchaccmdmrecid__c ,Sales_Rep__c,owner.EBS_UserName__c 
                         FROM Account WHERE Id = :accId];
            Account_Branch_Profile__c ABP;
            Account branchAccount;
            
            if(acc.RecordType.DeveloperName=='BranchAccount'){
                branchAccount=acc;
                acc=[SELECT Id,Name,Fax,mdmfaxid__c,website,mdmwebsiteId__c,FirstName,LastName,oracle_Account_Number__c,Store_Name__c,Territory_Name__c,Pella_Region__c,type,RecordTypeId,Description,RecordType.DeveloperName,parent.AccountNumber,Parent.Account_Number__c,Company_Email__c,Phone,Account_Status__c,
                     Evening_Phone_Type__c,PersonHomePhone,PersonAssistantPhone,PersonMobilePhone,PersonOtherPhone,PersonEmail,
                     PersonHasOptedOutOfEmail,PersonDoNotCall,Text_Opt_Out__c,Mail_Opt_Out__c,PersonAutoCall__c,
                     Store_Number__c,Account_Number__c,Inside_Sales_Rep__c,Inside_Sales_Rep__r.EBS_UserName__c,Ad_Patch__c,Division__c,District__c,Supply_DC__c,
                     Sq_Footage__c,Open_Date__c,Close_Date__c,NA_Type__c,Parent.branchaccmdmrecid__c ,Sales_Rep__c,parent.mdmrecid__c,parentId,owner.EBS_UserName__c 
                     FROM Account WHERE Id = :acc.parentId];
            }else if(acc.RecordType.DeveloperName=='Pro_Lowes'){
                branchAccount=acc;
            }else{
                List<Account_Branch_Profile__c> ABPList=[SELECT Id,Name, Party_Account__c, Branch__r.Branch_Number__c FROM Account_Branch_Profile__c WHERE Party_Account__c=:acc.Id order by lastmodifieddate desc Limit 1];
                if(ABPList.size()>0){
                    ABP=ABPList[0];
                }
            }
            List<Address_Assignment__c> listAddressAssignment=new List<Address_Assignment__c>();
            if(ABP!=null){
                listAddressAssignment=[SELECT Id,HQ_Bill_To__r.MDMrecid__c, Name, Address__c, Account_Branch_Profile__c, Full_Address__c, Primary_Flag__c, Identifying_Address__c, Status__c, Address_Usage_Type__c, 
                                       Address__r.Name,Address__r.Address_Line_1__c,Address__r.Address_Line_3__c, Address__r.Street__c, Address__r.City__c, Address__r.Country__c, Address__r.State__c, Address__r.Zipcode__c, Address__r.County__c, Address__r.Location_Id__c
                                       FROM Address_Assignment__c Where Account_Branch_Profile__c =:ABP.Id ];
            }else{
                listAddressAssignment=[SELECT Id,HQ_Bill_To__r.MDMrecid__c, Name, Address__c, Account_Branch_Profile__c,Account__c, Full_Address__c, Primary_Flag__c, Identifying_Address__c, Status__c, Address_Usage_Type__c, 
                                       Address__r.Name,Address__r.Address_Line_1__c,Address__r.Address_Line_3__c, Address__r.Street__c, Address__r.City__c, Address__r.Country__c, Address__r.State__c, Address__r.Zipcode__c, Address__r.County__c, Address__r.Location_Id__c
                                       FROM Address_Assignment__c Where Account__c =:branchAccount.Id ];
            }
            String byUser='PELSFINTEGRATION';
            User u=[SELECT id,name,EBS_UserName__c FROM User WHERE id = :Userinfo.getUserId()];
            if(String.isNotBlank(u.EBS_UserName__c)){
                byUser=u.EBS_UserName__c.toUpperCase();
            }
            EBSRequest req = new EBSRequest();
            
            if(acc.RecordType.DeveloperName=='PersonAccount'){
                req.firstname=acc.FirstName;
                req.lastname=acc.LastName;
                req.partytype='PERSON';
                req.partysubtype='Person - '+ acc.type;
            }else{
                req.orgname=acc.Name;
                // remove condition as it always  send
                //if(branchAccount.parent.mdmrecid__c==null){
                req.partytype='ORGANIZATION';
                req.partysubtype='Organization - '+acc.type;
                //}
            }
            req.byUser=byUser;
            req.spokesystemcode='Salesforce';
            req.spokerecid=acc.Id;
            
            req.accounts=new List<Accounts>();
            if(String.isNotBlank(acc.Account_Status__c)){
                req.status=acc.Account_Status__c=='Active'?'A':acc.Account_Status__c=='Inactive'?'I':'';
            }
            //Add Accounts
            Accounts account=new Accounts();
            account.accountname=acc.Name;
            account.spokerecid=branchAccount==null?ABP.Id:branchAccount.Id;
            account.spokesystemcode='Salesforce';
            account.byuser=byuser;
            if(String.isNotBlank(acc.Account_Status__c)){
                account.status=acc.Account_Status__c=='Active'?'A':acc.Account_Status__c=='Inactive'?'I':'';
            }
            account.mdmaccountid=null;
            if(ABP!=null){
                account.mdmbranchid=ABP.Branch__r.Branch_Number__c;
                account.mdmorgid=null;
            }else if(branchAccount!=null){
                account.mdmorgid=branchAccount.Branch__r.Branch_Family__r.Branch_Family_Number__c ;
                account.mdmbranchid=branchAccount.Branch__r.Branch_Number__c;
            }
            if(acc.RecordType.DeveloperName=='Pro_Lowes'){
                account.mdmbranchid=branchAccount.Branch_Number__c;
            }
            account.mdmpartyid=null;
            account.sites=new List<Sites>();
            
            for(Address_Assignment__c AA : listAddressAssignment){
                Sites sites=new Sites();
                sites.addressusagecode=String.isNotBlank(AA.Address_Usage_Type__c)?AA.Address_Usage_Type__c.replace(' ','_').toUpperCase():AA.Address_Usage_Type__c;
                sites.primaryflag=AA.Primary_Flag__c?'Y':'N';
                
                if(String.isNotBlank(AA.Status__c)){
                    sites.status=AA.Status__c=='Active'?'A':AA.Status__c=='Inactive'?'I':'';
                }
                sites.spokerecid=AA.Id;
                sites.spokesystemcode='Salesforce';
                sites.mdmaddressid=null;
                sites.salesrep=acc.owner.EBS_UserName__c;
                sites.billtositeuseid=AA.HQ_Bill_To__r.MDMrecid__c;
                sites.byuser=byuser;
                sites.address=new address();
                sites.address.addressline1=AA.Address__r.Street__c;
                if(!String.isBlank(AA.Address__r.Address_Line_1__c)){
                    sites.address.addressline1=AA.Address__r.Address_Line_1__c;
                    sites.address.addressline2=AA.Address__r.Street__c;
                    sites.address.addressline3=AA.Address__r.Address_Line_3__c;
                }
                
                sites.address.city=AA.Address__r.City__c;
                sites.address.state=AA.Address__r.State__c;
                sites.address.country=AA.Address__r.Country__c;
                sites.address.zipcode=AA.Address__r.Zipcode__c;
                sites.address.spokerecid=AA.Address__c;
                sites.address.spokesystemcode='Salesforce';
                sites.address.byuser=byuser;
                sites.address.identifyingaddress=AA.Identifying_Address__c?'Y':'N';
                if(String.isNotBlank(AA.Status__c)){
                    sites.address.status=AA.Status__c=='Active'?'A':AA.Status__c=='Inactive'?'I':'';
                }
                
                account.sites.add(sites);
            }
            
            if(acc.RecordType.DeveloperName=='Pro_Lowes'){
                req.knownas=branchAccount.Store_Name__c;
                account.attributecontext='NA Additional Info';
                account.accountnumber=branchAccount.oracle_Account_Number__c;
                
                /*List<AccountTeamMember> listAccTeam=[SELECT ID,User.Name, AccountId,UserId,User.EBS_UserName__c FROM AccountTeamMember Where TeamMemberRole='Inside Sales Support' and AccountId=:branchAccount.Id ORDER BY LastModifiedDate desc];
                if(listAccTeam.size()>0){
                    account.attribute10=listAccTeam[0].User.Name; // Rekha (6/18/21) changed name from EBS_UserName__c;
                }
                else
                {
                    account.attribute10='NULL';
                }*/
                if(String.isNotBlank(acc.Account_Status__c))
                account.status=acc.Account_Status__c=='Active'?'A':acc.Account_Status__c=='Inactive'?'I':'';
                account.attribute10=string.valueOf(branchAccount.Customer_Region__c);
                account.attribute11=branchAccount.Ad_Patch__c;
                account.attribute12=string.valueOf(branchAccount.Pella_Region__c);
                account.attribute13=branchAccount.Division__c;
                account.attribute14=string.valueOf(branchAccount.District__c);
                account.attribute15=string.valueOf(branchAccount.Supply_DC__c);
                account.attribute16=string.valueOf(branchAccount.Territory_Name__c);
                account.attribute17=string.valueOf(branchAccount.Open_Date__c);
                account.attribute18=string.valueOf(branchAccount.Close_Date__c);
                account.attribute19=acc.Description;
                account.attribute1=branchAccount.NA_Type__c;
                account.Relationship=new Relationship();
                account.Relationship.relationcode='PARENT';
                account.Relationship.relatedmdmpartyid=branchAccount.Parent.mdmrecid__c;
                account.Relationship.relatedmdmaccountid=branchAccount.Parent.branchaccmdmrecid__c;
                
                account.saleschannel='INDIRECT';
                account.profileclass='NA';
                account.classification='NA';
                //Moved to here from as it's applicable for both Lowes and Pros
                account.requestdatetype='ARRIVAL';
                if(branchAccount.branch_number__c=='L50'){
                    account.itemtypeidentifier='LOWES';
                    account.freightterm='Paid';      
                }
            }
            req.accounts.add(account);
            
            req.contactmethods=new List<contactmethods>();
            
            contactmethods cm=new contactmethods();
            
            //Create contactmethods
            if(acc.PersonAssistantPhone!=null || acc.PersonOtherPhone!=null || acc.PersonMobilePhone !=null || acc.PersonHomePhone!=null){
                /*cm.methodvalue= acc.PersonHomePhone != null ? ServiceUtil.formatPhone(acc.PersonHomePhone) : 
acc.PersonMobilePhone != null ? ServiceUtil.formatPhone(acc.PersonMobilePhone) : 
acc.PersonOtherPhone != null ? ServiceUtil.formatPhone(acc.PersonOtherPhone) : ServiceUtil.formatPhone(acc.PersonAssistantPhone) ;
cm.methodname='PHONE';
cm.spokerecid=acc.Id;
cm.spokesystemcode='Salesforce';
cm.byuser=byuser;
req.contactmethods.add(cm);
*/
                if(acc.PersonHomePhone!=null){
                    cm=new contactmethods();
                    cm.methodvalue=ServiceUtil.formatPhone(acc.PersonHomePhone); 
                    cm.methodname='PHONE';
                    cm.methodpurpose='HOME';
                    cm.methodlinetype='PHONEDAY';
                    cm.spokerecid=acc.Id+'_PHONE_HOME_PHONEDAY';
                    cm.spokesystemcode='Salesforce';
                    cm.byuser=byuser;
                    req.contactmethods.add(cm);
                }
                if(acc.PersonMobilePhone!=null){
                    cm=new contactmethods();
                    cm.methodvalue=ServiceUtil.formatPhone(acc.PersonMobilePhone); 
                    cm.methodname='PHONE';
                    cm.methodpurpose='MOBILE';
                    cm.methodlinetype='PHONEDAY';
                    cm.spokerecid=acc.Id+'_PHONE_MOBILE_PHONEDAY';
                    cm.spokesystemcode='Salesforce';
                    cm.byuser=byuser;
                    req.contactmethods.add(cm);
                }
                if(acc.PersonOtherPhone!=null){
                    cm=new contactmethods();
                    cm.methodvalue=ServiceUtil.formatPhone(acc.PersonOtherPhone); 
                    cm.methodname='PHONE';
                    cm.methodpurpose='WORK';
                    cm.methodlinetype='PHONEDAY';
                    cm.spokerecid=acc.Id+'_PHONE_WORK_PHONEDAY';
                    cm.spokesystemcode='Salesforce';
                    cm.byuser=byuser;
                    req.contactmethods.add(cm);
                }
                if(acc.PersonAssistantPhone!=null && acc.Evening_Phone_Type__c!=null){
                    cm=new contactmethods();
                    cm.methodvalue=ServiceUtil.formatPhone(acc.PersonAssistantPhone); 
                    cm.methodname='PHONE';
                    cm.methodpurpose=acc.Evening_Phone_Type__c.toUpperCase();
                    cm.methodlinetype='PHONEEVE';
                    cm.spokerecid=acc.Id+'_PHONE_WORK_PHONEEVE';
                    cm.spokesystemcode='Salesforce';
                    cm.byuser=byuser;
                    req.contactmethods.add(cm);
                }
            }
            
            if(acc.PersonEmail!=null && acc.PersonEmail!=''){
                cm=new contactmethods();
                cm.methodvalue=acc.PersonEmail;
                cm.methodname='EMAIL';
                cm.spokerecid=acc.Id;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                
                req.contactmethods.add(cm);
            }
            if(acc.Fax!=null && acc.Fax!=''){
                cm=new contactmethods();
                cm.methodvalue=acc.Fax;
                cm.methodname='PHONE';
                cm.methodpurpose='BUSINESS';
                cm.methodlinetype='FAX';
                cm.spokerecid=acc.Id+'_PHONE_BUSINESS_FAX';
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                req.contactmethods.add(cm);
            }
            if(acc.Website!=null && acc.Website!=''){
                cm=new contactmethods();
                cm.methodvalue=acc.Website;
                cm.methodname='WEB';
                cm.methodpurpose='HOMEPAGE';
                cm.spokerecid=acc.Id+'_WEB_HOMEPAGE';
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                req.contactmethods.add(cm);
            }
            
            if(acc.RecordType.DeveloperName!='PersonAccount'){
                if(branchAccount.Company_Email__c!=null && branchAccount.Company_Email__c!=''){
                    cm=new contactmethods();
                    cm.methodvalue=branchAccount.Company_Email__c;
                    cm.methodname='EMAIL';
                    cm.spokerecid=branchAccount.Id;
                    cm.spokesystemcode='Salesforce';
                    cm.byuser=byuser;
                    req.contactmethods.add(cm);
                }
                if(branchAccount.Phone!=null && branchAccount.Phone!=''){
                    cm=new contactmethods();
                    cm.methodvalue=ServiceUtil.formatPhone(branchAccount.Phone);
                    cm.methodname='PHONE';
                    cm.methodlinetype='GEN';
                    cm.methodpurpose='BUSINESS';
                    cm.spokerecid=branchAccount.Id;
                    cm.spokesystemcode='Salesforce';
                    cm.byuser=byuser;
                    req.contactmethods.add(cm);
                }
            }
            req.profiles=new List<profiles>();
            
            profiles profile=new profiles();
            
            profile.profileattributes=new List<profileattributes>();
            
            profileattributes PA=new profileattributes();
            PA.name='CALL';
            PA.value=!acc.PersonDoNotCall?'Yes':'No';
            PA.spokerecid=acc.Id;
            PA.spokesystemcode='Salesforce';
            PA.byuser=byuser;
            profile.profileattributes.add(PA);
            
            PA=new profileattributes();
            PA.name='AUTOCALL';
            PA.value=!acc.PersonAutoCall__c?'Yes':'No';
            PA.spokerecid=acc.Id;
            PA.spokesystemcode='Salesforce';
            PA.byuser=byuser;
            profile.profileattributes.add(PA);
            
            PA=new profileattributes();
            PA.name='EMAIL';
            PA.value=!acc.PersonHasOptedOutOfEmail?'Yes':'No';
            PA.spokerecid=acc.Id;
            PA.spokesystemcode='Salesforce';
            PA.byuser=byuser;
            profile.profileattributes.add(PA);
            
            PA=new profileattributes();
            PA.name='SMS';
            PA.value=!acc.Text_Opt_Out__c?'Yes':'No';
            PA.spokerecid=acc.Id;
            PA.spokesystemcode='Salesforce';
            PA.byuser=byuser;
            profile.profileattributes.add(PA);
            
            PA=new profileattributes();
            PA.name='MAIL';
            PA.value=!acc.Mail_Opt_Out__c?'Yes':'No';
            PA.spokerecid=acc.Id;
            PA.spokesystemcode='Salesforce';
            PA.byuser=byuser;
            profile.profileattributes.add(PA);
            
            profile.mdmcontextcode='contactmethods';
            profile.byuser=byuser;
            
            // Remove profile section for trade and Commercial
            if(acc.RecordType.DeveloperName=='PersonAccount'){
                req.profiles.add(profile);
            }else{
                req.profiles=null;
            }
            system.debug('req: '+req);
            
            return JSON.serialize(req,true);
        }
        catch(Exception e){
            system.debug('test: '+e.getLineNumber());
            system.debug('test: '+e.getMessage());
            return '';
        }
    }//End of createCustomerRequest
    
    public static String createLeadRequest(String leadId) {
        
        Lead leadRecord = [SELECT Id, LastName, FirstName, Street, City, PostalCode, State, Country, Email, No_of_Windows__c, No_of_Doors__c, 
                           Status, Description, LeadSource, Pel_Campaign_Code__c, Year_Home_Built__c,HomePhone__c, MobilePhone__c, Phone, AsstPhone__c
                           FROM Lead WHERE Id = :leadId];
        
        Leads leads = new Leads();
        String lName = String.valueOf(leadRecord.LastName).toUpperCase();
        String fName = String.valueOf(leadRecord.FirstName).toUpperCase().substring(0,1);
        
        leads.customername = lName + fName;
        leads.address1 = leadRecord.Street;
        leads.city = leadRecord.City;
        leads.zip = leadRecord.PostalCode;
        leads.state = leadRecord.State;
        leads.country = leadRecord.Country;
        leads.lastname = leadRecord.LastName;
        leads.firstname = leadRecord.FirstName;
        leads.emailaddress = leadRecord.Email;
        leads.apptdate = '';
        leads.appttime = '';
        leads.windows = String.valueOf(leadRecord.No_of_Windows__c);
        leads.doors = String.valueOf(leadRecord.No_of_Doors__c);
        leads.leadid = leadRecord.Id;
        leads.leadnote = leadRecord.Description;
        leads.leadsourcecode = leadRecord.LeadSource==null?leadRecord.LeadSource:String.valueOf(leadRecord.LeadSource).toUpperCase();
        leads.campaigncode = leadRecord.Pel_Campaign_Code__c;
        leads.homeimprovement = leadRecord.Year_Home_Built__c;
        leads.mdmpartyid = '';
        leads.closereason = '';
        if(leadRecord.Status.equalsIgnoreCase('Closed Transferred to New Construction'))
            leads.closereason = 'TRADE BUILDING NEW HOME';
        else if(leadRecord.Status.equalsIgnoreCase('Closed Transferred to Commercial'))
            leads.closereason = 'COMMERCIAL NON-RESIDENTIAL';
        
        if(leadRecord.HomePhone__c!=null || leadRecord.MobilePhone__c!=null || leadRecord.Phone !=null || leadRecord.AsstPhone__c!=null){
            leads.phonenumber =  leadRecord.HomePhone__c != null ? ServiceUtil.formatPhone(leadRecord.HomePhone__c) : 
            leadRecord.MobilePhone__c != null ? ServiceUtil.formatPhone(leadRecord.MobilePhone__c) : 
            leadRecord.Phone != null ? ServiceUtil.formatPhone(leadRecord.Phone) : ServiceUtil.formatPhone(leadRecord.AsstPhone__c) ;
        }
        
        return JSON.serialize(leads,true);
        
    }//End of createLeadRequest
    
    public static String createOpportunityRequest(String oppId) {
        
        Opportunity oppRecord = [SELECT Id, Name,Account.LastName,Account.FirstName, Street__c, City__c, State__c,Zipcode__c, Country__c, Email__c,
                                 Status__c, Description, LeadSource, Pel_Campaign_Code__c, Year_Home_Built__c,Phone__c,Number_of_Doors__c,Number_of_Windows__c,
                                 Account.PersonHomePhone,Account.PersonEmail, Account.PersonMobilePhone,Account.Phone, Account.PersonOtherPhone, Account.PersonAssistantPhone,
                                 Account.PersonMailingStreet ,Account.PersonMailingCity,Account.PersonMailingCountry,Account.PersonMailingState,Account.PersonMailingPostalCode 
                                 FROM Opportunity WHERE Id = :oppId];
        
        Leads Opp = new Leads();
        String lName = String.valueOf(oppRecord.Account.LastName).toUpperCase();
        String fName = String.valueOf(oppRecord.Account.FirstName).toUpperCase().substring(0,1);
        
        Opp.customername = lName + fName;
        Opp.address1 = oppRecord.Account.PersonMailingStreet ;
        Opp.city = oppRecord.Account.PersonMailingCity;
        Opp.zip = oppRecord.Account.PersonMailingPostalCode;
        Opp.state = oppRecord.Account.PersonMailingState;
        Opp.country = oppRecord.Account.PersonMailingCountry;
        Opp.lastname = oppRecord.Account.LastName;
        Opp.firstname = oppRecord.Account.FirstName;
        Opp.emailaddress = oppRecord.Account.PersonEmail;
        Opp.apptdate = '';
        Opp.appttime = '';
        Opp.windows = String.valueOf(oppRecord.Number_of_Windows__c);
        Opp.doors = String.valueOf(oppRecord.Number_of_Doors__c);
        Opp.leadid = oppRecord.Id;
        Opp.leadnote = oppRecord.Description;
        Opp.leadsourcecode = oppRecord.LeadSource==null?oppRecord.LeadSource:String.valueOf(oppRecord.LeadSource).toUpperCase();
        Opp.campaigncode = oppRecord.Pel_Campaign_Code__c;
        Opp.homeimprovement = oppRecord.Year_Home_Built__c;
        Opp.mdmpartyid = '';
        Opp.closereason = '';
        if(oppRecord.Status__c.equalsIgnoreCase('Transferred to New Construction'))
            Opp.closereason = 'TRADE BUILDING NEW HOME';
        else if(oppRecord.Status__c.equalsIgnoreCase('Transferred to Commercial'))
            Opp.closereason = 'COMMERCIAL NON-RESIDENTIAL';
        
        if(oppRecord.Account.PersonHomePhone!=null || oppRecord.Account.PersonMobilePhone!=null ||  oppRecord.Account.Phone!=null  || oppRecord.Account.PersonAssistantPhone!=null){
            Opp.phonenumber =  oppRecord.Account.PersonHomePhone != null ? ServiceUtil.formatPhone(oppRecord.Account.PersonHomePhone) : 
            oppRecord.Account.PersonMobilePhone != null ? ServiceUtil.formatPhone(oppRecord.Account.PersonMobilePhone) : 
            oppRecord.Account.Phone != null ? ServiceUtil.formatPhone(oppRecord.Account.Phone) : ServiceUtil.formatPhone(oppRecord.Account.PersonAssistantPhone) ;
        }
        
        return JSON.serialize(Opp,true);
        
    }//End of createLeadRequest
    
    public static String createUpdateAARequest(Address_Assignment__c AA) {
        
        String byUser='PELSFINTEGRATION';
        
        //Add Sites
        
        Sites sites=new Sites();
        sites.addressusagecode=String.isNotBlank(AA.Address_Usage_Type__c)?AA.Address_Usage_Type__c.replace(' ','_').toUpperCase():AA.Address_Usage_Type__c;
        sites.primaryflag=AA.Primary_Flag__c?'Y':'N';
        
        if(String.isNotBlank(AA.Status__c)){
            sites.status=AA.Status__c=='Active'?'A':AA.Status__c=='Inactive'?'I':'';
        }
        sites.spokerecid=AA.Id;
        sites.spokesystemcode='Salesforce';
        sites.mdmaddressid=AA.MDMrecid__c;
        
        sites.mdmbranchid=AA.Account__c==null?AA.Account_Branch_Profile__r.Branch__r.Branch_Number__c:AA.Account__r.Branch__r.T_C_Branch_Number__c;
        if(AA.Account__c!=null && AA.Account__r.RecordType.DeveloperName=='Pro_Lowes'){
            sites.mdmbranchid=AA.Account__r.Branch_Number__c;
            sites.profileclass='NA';
            sites.salesrep=AA.Account__r.owner.EBS_UserName__c;
            sites.billtositeuseid=AA.HQ_Bill_To__r.MDMrecid__c;
        }
        sites.byuser=byuser;
        sites.address=new address();
        
        sites.address.addressline1=AA.Address__r.Street__c;
        if(!String.isBlank(AA.Address__r.Address_Line_1__c)){
            sites.address.addressline1=AA.Address__r.Address_Line_1__c;
            sites.address.addressline2=AA.Address__r.Street__c;
            sites.address.addressline3=AA.Address__r.Address_Line_3__c;
        }
        sites.address.city=AA.Address__r.City__c;
        sites.address.state=AA.Address__r.State__c;
        sites.address.country=AA.Address__r.Country__c;
        sites.address.zipcode=AA.Address__r.Zipcode__c;
        sites.address.spokerecid=AA.Address__c;
        sites.address.spokesystemcode='Salesforce';
        sites.address.byuser=byuser;
        sites.address.mdmaddressid=AA.Address__r.MDMrecid__c;
        sites.address.identifyingaddress=AA.Identifying_Address__c?'Y':'N';
        if(String.isNotBlank(AA.Status__c)){
            sites.address.status=AA.Status__c=='Active'?'A':AA.Status__c=='Inactive'?'I':'';
        }
        
        return JSON.serialize(sites,true);
        
    }//End of createUpdateAARequest
    
    public static String createUpdateAddressRequest(Address__c add) {
        
        String byUser='PELSFINTEGRATION';
        
        //Add Address
        
        Address address = new Address();
        
        address.addressline1=add.Street__c;
        if(!String.isBlank(add.Address_Line_1__c)){
            address.addressline1=add.Address_Line_1__c;
            address.addressline2=add.Street__c;
            address.addressline3=add.Address_Line_3__c;
        }
        address.city=add.City__c;
        address.state=add.State__c;
        address.country=add.Country__c;
        address.zipcode=add.Zipcode__c;
        address.spokerecid=add.Id;
        address.spokesystemcode='Salesforce';
        address.byuser=byuser;
        address.mdmaddressid=add.MDMrecid__c;
        
        return JSON.serialize(address,true);
        
    }//End of createUpdateAddressRequest
    
    //Creating createCustomer data for EBS
    public static String createContactRequest(String ConId) {
        Contact con=[SELECT Id, LastName,Active__c, FirstName,fax,mdmfaxid__c,Contact_Type__c, Org_Contact_ID__c,mdmrecid__c,MobilePhone,mdmhomephoneId__c,mdmphoneId__c,mdmOtherphoneId__c,mdmAssistantPhoneId__c,mdmEmailId__c,Title, Phone, HomePhone, OtherPhone, AssistantPhone, Contact_Status__c, Email, AccountId, 
                     Account.mdmrecid__c,Account.Job_Title__c,Account.branch_Number__c,mdmmobilephoneid__c,Account.branchaccmdmrecid__c ,Account.Parent.mdmrecid__c,Account.RecordType.DeveloperName,Account.Account_Status__c FROM Contact where Id=:ConId];
        
        string byuser='PELSFINTEGRATION';
        
        EBSContactRequest req = new EBSContactRequest();
        
        req.mdmbranchid=con.Account.branch_Number__c;
        req.spokesystemcode='Salesforce';
        req.spokerecid=con.AccountId;
        req.byuser=byuser;
        
        req.contacts=new List<contacts>();
        
        contacts conts=new contacts();
        conts.spokesystemcode='Salesforce';
        conts.spokerecid=con.Id;
        conts.mdmorgcontactid=con.Org_Contact_ID__c;
        conts.fisrtname=con.FirstName;
        conts.lastname=con.LastName;
        //conts.status=con.Contact_Status__c=='Active'?'A':con.Contact_Status__c=='Inactive'?'I':'A';
        //make changes as field change as discussed with rekha
        conts.status=con.Active__c?'A':'I';
        //conts.jobTitle=con.Title;
        // contact type need to go as job title
        conts.jobTitle=con.Contact_Type__c;
        //Create contactmethods
        List<contactmethods> contactmethods=new List<contactmethods>();
        if(con.HomePhone!=null || con.Phone!=null || con.OtherPhone !=null || con.AssistantPhone!=null || con.MobilePhone!=null){
            if(con.HomePhone!=null){
                contactmethods cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(con.HomePhone); 
                cm.methodname='PHONE';
                cm.methodpurpose='HOME';
                cm.methodlinetype='PHONEDAY';
                cm.spokesystemcode='Salesforce';
                cm.spokerecid=con.Id+'_PHONE_HOME_PHONEDAY';
                cm.mdmmethodid=con.mdmhomephoneId__c;
                cm.byuser=byuser;
                contactmethods.add(cm);
            }
            if(con.Phone!=null){
                contactmethods cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(con.Phone); 
                cm.methodname='PHONE';
                cm.methodpurpose='MOBILE';
                cm.methodlinetype='PHONEDAY';
                cm.spokesystemcode='Salesforce';
                cm.spokerecid=con.Id+'_PHONE_MOBILE_PHONEDAY';
                cm.mdmmethodid=con.mdmphoneid__c;
                cm.byuser=byuser;
                contactmethods.add(cm);
            }if(con.MobilePhone!=null){
                contactmethods cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(con.MobilePhone); 
                cm.methodname='PHONE';
                cm.methodpurpose='MOBILE';
                cm.methodlinetype='PHONEEVE';
                cm.spokesystemcode='Salesforce';
                cm.spokerecid=con.Id+'_PHONE_MOBILE_PHONEEVE';
                cm.mdmmethodid=con.mdmmobilephoneid__c;
                cm.byuser=byuser;
                contactmethods.add(cm);
            }
            if(con.OtherPhone!=null){
                contactmethods cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(con.OtherPhone); 
                cm.methodname='PHONE';
                cm.methodpurpose='WORK';
                cm.methodlinetype='PHONEDAY';
                cm.spokesystemcode='Salesforce';
                cm.spokerecid=con.Id+'_PHONE_WORK_PHONEDAY';
                cm.mdmmethodid=con.mdmotherphoneid__C;
                cm.byuser=byuser;
                contactmethods.add(cm);
            }
            if(con.AssistantPhone!=null){
                contactmethods cm=new contactmethods();
                cm.methodvalue=ServiceUtil.formatPhone(con.AssistantPhone); 
                cm.methodname='PHONE';
                cm.methodpurpose='WORK';
                cm.methodlinetype='PHONEEVE';
                cm.spokerecid=con.Id+'_PHONE_WORK_PHONEEVE';
                cm.mdmmethodid=con.mdmAssistantPhoneId__c;
                cm.spokesystemcode='Salesforce';
                cm.byuser=byuser;
                contactmethods.add(cm);
            }
        }
        
        if(con.Email!=null && con.Email!=''){
            contactmethods cm=new contactmethods();
            cm.methodvalue=con.Email;
            cm.methodname='EMAIL';
            cm.spokesystemcode='Salesforce';
            cm.spokerecid=con.Id;
            cm.mdmmethodid=con.mdmEmailId__c;
            cm.byuser=byuser;
            
            contactmethods.add(cm);
        }
        if(con.Fax!=null && con.Fax!=''){
            contactmethods cm=new contactmethods();
            cm.methodvalue=con.Fax;
            cm.methodname='PHONE';
            cm.methodpurpose='BUSINESS';
            cm.methodlinetype='FAX';
            cm.spokerecid=con.Id+'_PHONE_BUSINESS_FAX';
            cm.spokesystemcode='Salesforce';
            cm.byuser=byuser;
            cm.mdmmethodid=con.mdmfaxid__c;
            contactmethods.add(cm);
        }
        conts.contactmethods=contactmethods;
        req.contacts.add(conts); 
        return JSON.serialize(req,true);
        
    }//End of createCustomerRequest
    
    public static String inActiveContactRequest(String ConId,String AccountId,String orgContactId) {
        //Contact con=[SELECT Id, LastName, FirstName,fax,mdmfaxid__c,Contact_Type__c, Org_Contact_ID__c,mdmrecid__c,MobilePhone,mdmhomephoneId__c,mdmphoneId__c,mdmOtherphoneId__c,mdmAssistantPhoneId__c,mdmEmailId__c,Title, Phone, HomePhone, OtherPhone, AssistantPhone, Contact_Status__c, Email, AccountId, 
        //             Account.mdmrecid__c,Account.Job_Title__c,Account.branch_Number__c,mdmmobilephoneid__c,Account.branchaccmdmrecid__c ,Account.Parent.mdmrecid__c,Account.RecordType.DeveloperName,Account.Account_Status__c FROM Contact where Id=:ConId];
        
        string byuser='PELSFINTEGRATION';
        
        EBSContactRequest req = new EBSContactRequest();
        
        //req.mdmbranchid=con.Account.branch_Number__c;
        req.spokesystemcode='Salesforce';
        req.spokerecid=AccountId;
        req.byuser=byuser;
        
        req.contacts=new List<contacts>();
        
        contacts conts=new contacts();
        conts.spokesystemcode='Salesforce';
        conts.spokerecid=ConId;
        conts.mdmorgcontactid=orgContactId;
        //conts.fisrtname=con.FirstName;
        //conts.lastname=con.LastName;
        conts.status='I';
        //conts.jobTitle=con.Title;
        // contact type need to go as job title
        //conts.jobTitle=con.Contact_Type__c;
        
        req.contacts.add(conts); 
        return JSON.serialize(req,true);
        
    }//End of createCustomerRequest
    
    public static string handleCustomerResponse(String responseBody){
        try{
            List<EBSResponse> EBSResponseList=(List<EBSResponse>)JSON.deserialize(responseBody, List<EBSResponse>.class);
            Account acc=new Account();
            Account_Branch_Profile__c ABP=new Account_Branch_Profile__c();
            Account BranchAcc=new Account();
            Map<String,Address_Assignment__c> listAA=new Map<String,Address_Assignment__c>();
            Map<String,Address__c> listAddress=new Map<String,Address__c>();
            
            for(EBSResponse res : EBSResponseList){
                Address_Assignment__c AA=new Address_Assignment__c();
                Address__c address=new Address__c();
                //If party Account
                if(res.objectcode.equalsIgnoreCase('PARTY')){
                    acc.Id=res.spokerecid;
                    acc.mdmrecid__c=res.mdmrecid;
                    if(res.additionalresponsevalues!=null){
                        for(Additionalresponsevalues ar :res.additionalresponsevalues){
                            if(ar.name.toLowerCase().contains('partynumber')){
                                acc.AccountNumber = ar.value;
                            }
                        }
                    }
                }
                //If  contact Method Phone
                if(res.objectcode.equalsIgnoreCase('contactmethods')){
                    if(res.spokerecid==acc.Id+'_PHONE_HOME_PHONEDAY'){
                        acc.mdmhomephonedayid__c=res.mdmrecid;
                    }else if(res.spokerecid==acc.Id+'_PHONE_MOBILE_PHONEDAY'){
                        acc.mdmmobilephonedayid__c=res.mdmrecid;
                    }
                    else if(res.spokerecid==acc.Id+'_PHONE_WORK_PHONEDAY'){
                        acc.mdmworkphonedayid__c=res.mdmrecid;
                    }
                    else if(res.spokerecid==acc.Id+'_PHONE_WORK_PHONEEVE'){
                        acc.MDMphoneeveId__c=res.mdmrecid;
                    }
                    else if(res.spokerecid==acc.Id+'_PHONE_BUSINESS_FAX'){
                        acc.mdmfaxid__c =res.mdmrecid;
                    }
                    else if(res.spokerecid==acc.Id+'_WEB_HOMEPAGE'){
                        acc.mdmwebsiteId__c =res.mdmrecid;
                    }
                    if(res.additionalresponsevalues!=null){
                        for(Additionalresponsevalues ar :res.additionalresponsevalues){
                            if(ar.value.toLowerCase().contains('email')){
                                acc.mdmrecid_email__c=res.mdmrecid;
                            }else if(ar.value.toLowerCase().contains('phone')){
                                acc.MDMrecid_Phone__c=res.mdmrecid;
                            }
                        }
                    }
                }
                
                //If  contact Method Phone
                if(res.objectcode.equalsIgnoreCase('PHONE')){
                    acc.mdmrecid_phone__c=res.mdmrecid;
                }
                //If  contact Method Email
                if(res.objectcode.equalsIgnoreCase('EMAIL')){
                    acc.mdmrecid_email__c=res.mdmrecid;
                }
                
                //If  Account branch
                if(res.objectcode.equalsIgnoreCase('ACCOUNT')){
                    system.debug('---------'+res);
                    
                    String sObjName = ((Id)(res.spokerecid)).getSObjectType().getDescribe().getName();
                    
                    if(sObjName=='Account'){
                        BranchAcc.Id=res.spokerecid;
                        BranchAcc.branchaccmdmrecid__c=res.mdmrecid;
                        
                        //If  contact Method Phone
                        if(acc.mdmrecid_phone__c!=null){
                            BranchAcc.mdmrecid_phone__c=acc.mdmrecid_phone__c;
                            //acc.mdmrecid_phone__c=null;
                        }
                        //If  contact Method Email
                        if(acc.mdmrecid_email__c!=null){
                            BranchAcc.mdmrecid_email__c=acc.mdmrecid_email__c;
                            //acc.mdmrecid_email__c=null;
                        }
                        
                        if(res.additionalresponsevalues != null && res.additionalresponsevalues.size() > 0 )
                        {
                            for(Additionalresponsevalues ar :res.additionalresponsevalues){
                                if(ar.name.toLowerCase().contains('accountnumber') &&  ar.value!=null){
                                    BranchAcc.oracle_Account_Number__c = ar.value;
                                }
                                
                            }
                        }
                        
                    }else{
                        ABP.Id=res.spokerecid;
                        ABP.MDMrecid__c =res.mdmrecid;
                        if(res.additionalresponsevalues != null && res.additionalresponsevalues.size() > 0 )
                        {
                            for(Additionalresponsevalues ar :res.additionalresponsevalues){
                                if(ar.name.toLowerCase().contains('accountnumber')){
                                    ABP.Account_Number__c = ar.value;
                                }
                                
                            }
                        }
                    }
                }
                
                //If  Address Assignment
                if(res.objectcode.equalsIgnoreCase('addressassignment')){
                    if(String.isNotBlank(res.spokerecid)){
                        AA.Id = res.spokerecid;
                        AA.MDMrecid__c =res.mdmrecid;
                        listAA.put(AA.Id,AA);
                    }
                }
                
                //If  Address Assignment
                if(res.objectcode.equalsIgnoreCase('Address')){
                    if(String.isNotBlank(res.spokerecid)){
                        address.Id=res.spokerecid;
                        address.MDMrecid__c =res.mdmrecid;
                        listAddress.put(address.Id,address);
                    }
                }
            }
            
            // Update record based on response
            if(acc.Id!=null){
                update acc;
            }
            if(BranchAcc.Id!=null){
                update BranchAcc;
            }
            if(ABP.Id !=null){
                update ABP;
            }
            if(listAddress.values().size()>0){
                update listAddress.values();
            }
            if(listAA.values().size()>0){
                update listAA.values();
            }
            System.debug('@@ACC : '+acc);
            System.debug('@@ABP : '+ABP);
            return 'Sucesss';
        }
        catch(Exception ex){
            new ApexDebugLog().createLog( new ApexDebugLog.Error('CustomerRequest','handleCustomerResponse',responseBody,ex));
            return ex.getmessage();
        }
    }
    public static string handleUpdateCustomerResponse(String responseBody){
        try{
            List<EBSUpdateResponse> EBSResponseList=(List<EBSUpdateResponse>)JSON.deserialize(responseBody, List<EBSUpdateResponse>.class);
            Map<String,Contact> mapContact=new Map<String,Contact>();
            Map<String,Account> mapAccount=new Map<String,Account>();
            for(EBSUpdateResponse EBSRes : EBSResponseList){
                if(EBSRes.spokerecid!=null && EBSRes.spokerecid.startsWith('003')){
                    if(EBSRes.objectcode == 'OrgContactId'){
                        String contactId=EBSRes.spokerecid;
                        if(!mapContact.containsKey(contactId)){
                            mapContact.put(contactId,new Contact(Id =contactId ));
                        }
                        mapContact.get(contactId).Org_Contact_ID__c=EBSRes.mdmrecid;
                    }else if(EBSRes.objectcode=='Email'){
                        String contactId=EBSRes.spokerecid;
                        if(!mapContact.containsKey(contactId)){
                            mapContact.put(contactId,new Contact(Id =contactId ));
                        }
                        mapContact.get(contactId).mdmEmailid__c=EBSRes.mdmrecid;
                    }
                    else if(EBSRes.spokerecid.indexOf('_')!=-1){
                        String contactId=EBSRes.spokerecid.substring(0,EBSRes.spokerecid.indexOf('_'));
                        if(!mapContact.containsKey(contactId)){
                            mapContact.put(contactId,new Contact(Id =contactId ));
                        }
                        
                        if(EBSRes.spokerecid==contactId+'_PHONE_HOME_PHONEDAY'){
                            mapContact.get(contactId).mdmhomephoneId__C=EBSRes.mdmrecid;
                        }else if(EBSRes.spokerecid==contactId+'_PHONE_MOBILE_PHONEDAY'){
                            mapContact.get(contactId).mdmphoneid__c=EBSRes.mdmrecid;
                        }else if(EBSRes.spokerecid==contactId+'_PHONE_MOBILE_PHONEEVE'){
                            mapContact.get(contactId).mdmmobilephoneid__c=EBSRes.mdmrecid;
                        }else if(EBSRes.spokerecid==contactId+'_PHONE_WORK_PHONEDAY'){
                            mapContact.get(contactId).mdmotherphoneId__c=EBSRes.mdmrecid;
                        }else if(EBSRes.spokerecid==contactId+'_PHONE_WORK_PHONEEVE'){
                            mapContact.get(contactId).mdmAssistantPhoneid__c=EBSRes.mdmrecid;
                        }else if(EBSRes.spokerecid==contactId+'_PHONE_BUSINESS_FAX'){
                            mapContact.get(contactId).mdmfaxid__c=EBSRes.mdmrecid;
                        }
                        
                    }
                }
                if(EBSRes.spokerecid!=null && EBSRes.spokerecid.startsWith('001')){
                    if(EBSRes.spokerecid.indexOf('_')!=-1){
                        String contactId=EBSRes.spokerecid.substring(0,EBSRes.spokerecid.indexOf('_'));
                        if(!mapAccount.containsKey(contactId)){
                            mapAccount.put(contactId,new Account(Id =contactId ));
                        }
                        
                        if(EBSRes.spokerecid==contactId+'_PHONE_BUSINESS_FAX'){
                            mapAccount.get(contactId).mdmfaxid__c=EBSRes.mdmrecid;
                        }
                        else if(EBSRes.spokerecid==contactId+'_WEB_HOMEPAGE'){
                            mapAccount.get(contactId).mdmwebsiteId__c=EBSRes.mdmrecid;
                        }
                    }else{
                        if(!mapAccount.containsKey(EBSRes.spokerecid)){
                            mapAccount.put(EBSRes.spokerecid,new Account(Id =EBSRes.spokerecid ));
                        }
                        if(EBSRes.objectcode=='Email'){
                            mapAccount.get(EBSRes.spokerecid).MDMrecid_Email__c=EBSRes.mdmrecid;
                        }else if(EBSRes.objectcode=='Phone'){
                            mapAccount.get(EBSRes.spokerecid).MDMrecid_Phone__c=EBSRes.mdmrecid;
                        }
                    }
                    
                }
            }
            update mapContact.values();
            update mapAccount.values();
            return 'Sucesss';
        }
        catch(Exception ex){
            new ApexDebugLog().createLog( new ApexDebugLog.Error('CustomerRequest','handleUpdateCustomerResponse',responseBody,ex));
            return ex.getmessage();
        }
    }
    public class EBSUpdateResponse{
        public String objectcode;
        public String spokerecid;
        public String mdmrecid;
    }
    
    public class EBSRequest{
        
        public String firstname;
        public String lastname;
        public String orgname;
        public String byuser;
        public String partytype;
        public String partysubtype;
        public String spokesystemcode;
        public String spokerecid;
        public List<Accounts> accounts;
        public List<Contactmethods> contactmethods;
        public String status;
        public List<Profiles> profiles;
        public List<relations> relations;
        public String knownas;
    }
    
    public class Address {
        public String addressline1;
        public String addressline2;
        public String addressline3;
        public String city;
        public String state;
        public String country;
        public String zipcode;
        public String spokerecid;
        public String spokesystemcode;
        public String byuser;
        public String status;
        public String identifyingaddress;
        public String mdmaddressid;
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
        public String mdmorgid;
        public String mdmpartyid;
        public List<Sites> sites;
        public Relationship Relationship;
        public String knownas;
        public String accountnumber;
        public String attributecontext;
        public String attribute8;
        public String attribute9;
        public String attribute10;
        public String attribute11;
        public String attribute12;
        public String attribute13;
        public String attribute14;
        public String attribute15;
        public String attribute16;
        public String attribute17;
        public String attribute18;
        public String attribute19;
        public String attribute1;
        public String saleschannel;
        public String profileclass;
        public String classification;
        public String requestdatetype;
        public String itemtypeidentifier;
        public String freightterm;
    }
    public class Relationship{
        public String relationcode;
        public String relatedmdmpartyid;
        public String relatedmdmaccountid;
        
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
        public String salesrep;
        public String profileclass;
        public String billtositeuseid;
        
        public Address address;
    }
    
    public class EBSResponse {
        
        public String mdmrecid;
        public String spokerecid;
        public String message;
        public String objectcode;
        public String statuscode;
        public List<Additionalresponsevalues> additionalresponsevalues;
    }
    
    public class Additionalresponsevalues {
        public String name;
        public String value;
    }
    
    public class Leads{
        public String customername;
        public String address1;
        public String city;
        public String zip;
        public String state;
        public String country;
        public String lastname;
        public String firstname;
        public String phonenumber;
        public String emailaddress;
        public String apptdate;
        public String appttime;
        public String windows;
        public String doors;
        public String leadid;
        public String leadnote;
        public String leadsourcecode;
        public String campaigncode;
        public String homeimprovement;
        public String mdmpartyid;
        public String closereason;
    }
    public class contacts{
        public string spokesystemcode;
        public string spokerecid;
        public string mdmorgcontactid;
        public String fisrtname;
        public String lastname;
        public String status;
        public String jobtitle;
        public List<Contactmethods> contactmethods;
    }
    public class EBSContactRequest{
        
        public String byuser;
        public String spokesystemcode;
        public String spokerecid;
        public List<contacts> contacts;
        public String mdmbranchid;
    }
    public class relations{
        public String relationcode;
        public String status;
        public String relatedmdmpartyid;
        public String relatedmdmaccountid;
        public String jobtitle;
    }
}//End of CustomerRequest