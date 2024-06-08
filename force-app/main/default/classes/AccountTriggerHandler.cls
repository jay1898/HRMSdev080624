/*
Created By: Mayank Srivastava
Created Date: 11/28/2019
Purpose: This is a trigger handler for sObject Account to perform required operations.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
----------------------------------------------------------------------------------------------
*/

public class AccountTriggerHandler 
{
    public static Boolean RUN_EBS_CALLOUT = true ; 
    public static Boolean RUN_TRIGGER=true;  
    
    public static void updateCustomerEBSCallout(List<Account> newAccounts, Map<Id, Account> oldAccMap) {
        String byUser='';
        User u=[SELECT id,name,EBS_UserName__c FROM User WHERE id = :Userinfo.getUserId()];
        if(String.isNotBlank(u.EBS_UserName__c)){
            byUser=u.EBS_UserName__c.toUpperCase();
        }
        system.debug('@@'+byUser);
        for(Account acc : newAccounts){
            if(acc.Name != oldAccMap.get(acc.Id).Name ||
               acc.FirstName  != oldAccMap.get(acc.Id).FirstName ||
               acc.LastName  != oldAccMap.get(acc.Id).LastName ||
               acc.PersonHomePhone != oldAccMap.get(acc.Id).PersonHomePhone ||
               acc.PersonAssistantPhone != oldAccMap.get(acc.Id).PersonAssistantPhone ||
               acc.PersonOtherPhone != oldAccMap.get(acc.Id).PersonOtherPhone ||
               acc.PersonMobilePhone != oldAccMap.get(acc.Id).PersonMobilePhone ||
               acc.PersonEmail != oldAccMap.get(acc.Id).PersonEmail ||
               acc.PersonDoNotCall != oldAccMap.get(acc.Id).PersonDoNotCall ||
               acc.PersonHasOptedOutOfEmail != oldAccMap.get(acc.Id).PersonHasOptedOutOfEmail ||
               acc.Text_Opt_Out__c != oldAccMap.get(acc.Id).Text_Opt_Out__c ||
               acc.Mail_Opt_Out__c != oldAccMap.get(acc.Id).Mail_Opt_Out__c ||
               acc.PersonAutoCall__c  != oldAccMap.get(acc.Id).PersonAutoCall__c ||
               acc.Phone  != oldAccMap.get(acc.Id).Phone ||
               acc.Company_Email__c  != oldAccMap.get(acc.Id).Company_Email__c ||
               acc.Fax  != oldAccMap.get(acc.Id).Fax){
                   
                   // Added on 03-03 to Ignore send update back in case of api call made by EBS
                   // It should check if last update was made by PELSFINTEGRATION, dont send that update back.
                   //if(byUser!='PELSFINTEGRATION')
                   if(u.Name!=Label.Integration_UserName)
                   {
                       EBSRESTCallout.updateCustomerEBSCallout(acc.Id,'');  // add one more parameter as a blank
                   }
               }
            Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
          // ParentId null check removed
         //   if(acc.RecordTypeId==recordTypeId && acc.ParentId!=null && (acc.Store_Number__c!=oldAccMap.get(acc.Id).Store_Number__c ||
      if(acc.RecordTypeId==recordTypeId && (acc.Store_Number__c!=oldAccMap.get(acc.Id).Store_Number__c ||
                                                  acc.Account_Number__c!=oldAccMap.get(acc.Id).Account_Number__c ||
                                                  acc.Inside_Sales_Rep__c!=oldAccMap.get(acc.Id).Inside_Sales_Rep__c ||
                                                  acc.Ad_Patch__c!=oldAccMap.get(acc.Id).Ad_Patch__c || 
                                                  acc.Pella_Region__c!=oldAccMap.get(acc.Id).Pella_Region__c ||
                                                  acc.Division__c!=oldAccMap.get(acc.Id).Division__c ||
                                                  acc.District__c!=oldAccMap.get(acc.Id).District__c || 
                                                  acc.Supply_DC__c!=oldAccMap.get(acc.Id).Supply_DC__c ||
                                                  acc.Territory_Name__c!=oldAccMap.get(acc.Id).Territory_Name__c ||
                                                  acc.Open_Date__c!=oldAccMap.get(acc.Id).Open_Date__c ||
                                                  acc.Close_Date__c!=oldAccMap.get(acc.Id).Close_Date__c ||
                                                  acc.NA_Type__c!=oldAccMap.get(acc.Id).NA_Type__c ||
                                                  acc.Store_Name__c!=oldAccMap.get(acc.Id).Store_Name__c ||
                                                  acc.description!=oldAccMap.get(acc.Id).description ||
                                                  acc.Account_Status__c!=oldAccMap.get(acc.Id).Account_Status__c ||
                                                  //Owner Change added here to fire EBS synch
                                                  acc.OwnerId != oldAccMap.get(acc.Id).OwnerId || 
                                                  acc.Parent!=oldAccMap.get(acc.Id).Parent||
                                                  acc.Customer_Region__c!=oldAccMap.get(acc.Id).Customer_Region__c||
                                                  acc.RSM_DSM_Overwrite__c!=oldAccMap.get(acc.Id).RSM_DSM_Overwrite__c ||
                                                 acc.RBM_Overwrite__c!=oldAccMap.get(acc.Id).RBM_Overwrite__c ))
            {
                
                // Added on 03-03 to Ignore send update back in case of api call made by EBS
                // It should check if last update was made by PELSFINTEGRATION, dont send that update back.
                //if(byUser!='PELSFINTEGRATION')
                if(u.Name!=Label.Integration_UserName)
                {
                    if(acc.OwnerId != oldAccMap.get(acc.Id).OwnerId ){
                        EBSRESTCallout.updateCustomerEBSCallout(acc.Id,true);  // add one more parameter as a blank
                    }else{
                        EBSRESTCallout.updateCustomerEBSCallout(acc.Id,'');  // add one more parameter as a blank
                    }
                    
                }
            }
        }
    }
    /*public static void CreateCustomerEBSCallout(List<Account> newAccounts){
         String byUser='';
        User u=[SELECT id,name,EBS_UserName__c FROM User WHERE id = :Userinfo.getUserId()];
        if(String.isNotBlank(u.EBS_UserName__c)){
            byUser=u.EBS_UserName__c.toUpperCase();
        }
        system.debug('@@'+byUser);
      
        for(Account acc : newAccounts){
              system.debug('acc.RecordTypeId: '+acc.RecordTypeId);
            system.debug('acc.ParentId: '+acc.ParentId);
            Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
            if(acc.RecordTypeId==recordTypeId && acc.ParentId!=null){
                if(u.Name!=Label.Integration_UserName)
                {
                    EBSRESTCallout.createCustomerEBSCallout(acc.Id); 
                }
            }
        }
    }*/
    
    
    @future(callout=true)
    public static void updateCustomerEBSCallout() {
        
        //calling external application for customer operations
        if(!Test.isRunningTest()) {
            
            //EBSRESTCallout.updateCustomerEBSData(); 
            
        }//End of  if(!Test.isRunningTest())
        
    }//End of updateCustomerEBSCallout
    
    @future(callout=true)
    public static void createCustomerEBSCallout(String AccId) {
        
        //calling external application for customer operations
        if(!Test.isRunningTest()) {
            
            //EBSRESTCallout.createCustomerEBSData(AccId); 
            
        }//End of  if(!Test.isRunningTest())
        
    }//End of createCustomerEBSCallout
    
    /**
*   @Method:        updateBranchNumberOnBranchAccount
*   @Purpose:       To update BranchNumbers on Branch Account based on selected branch family
*/
    public static void updateBranchNumberOnBranchAccount(List<Account> listAcc,Map<Id,Account> oldAccMap) 
    {
        List<String> listBranchIds=new list<String>();
        for(Account acc : listAcc)
        {
            // Get Account Ids 
            if(acc.Branch__c!=null && (oldAccMap==null || acc.Branch__c!=oldAccMap.get(acc.Id).Branch__c)) listBranchIds.add(acc.Branch__c);
        }
        
        if(listBranchIds.size()==0)
            return;
        
        Map<Id,Id> branchWiseBranchFamily=new Map<Id,Id>();
        for(Branch__c branch : [SELECT ID,Branch_Family__c FROM Branch__c where Id in :listBranchIds]){
            branchWiseBranchFamily.put(branch.Id,branch.Branch_Family__c);
        }
        
        Map<Id,List<String>> branchFamilyWiseBranchNumbers=new Map<Id,List<String>>();
        for(Branch__c branch : [SELECT ID,Branch_Family__c,T_C_Branch_Number__c FROM Branch__c where Branch_Family__c in :branchWiseBranchFamily.values()]){
            if(!branchFamilyWiseBranchNumbers.containsKey(branch.Branch_Family__c)){
                branchFamilyWiseBranchNumbers.put(branch.Branch_Family__c,new List<String>());
            }
            branchFamilyWiseBranchNumbers.get(branch.Branch_Family__c).add(branch.T_C_Branch_Number__c);
        }
        for(Account acc : listAcc)
        {
            // Get Account Ids 
            if(acc.Branch__c!=null){
                if(branchFamilyWiseBranchNumbers.containsKey(branchWiseBranchFamily.get(acc.Branch__c))){
                    acc.Branch_Number__c=';'+String.join(branchFamilyWiseBranchNumbers.get(branchWiseBranchFamily.get(acc.Branch__c)),';')+';';
                }
            }
        }
        
    }
    
    /**
*   @Method:        updateBrancIdsOnParentAccount
*   @Purpose:       To update BranchIds on Account from all child account records 
*/
    public static void updateBrancIdsOnParentAccount(List<Account> listAcc) 
    {
        Map<Id,Set<String>> accountIdToBranchIds = new Map<Id,Set<String>>();
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        
        for(Account acc : listAcc)
        {
            // Get Account Ids 
            if(acc.parentId!=null && String.isNotBlank(acc.parentId)) accountIds.add(acc.parentId);
        }
        
        System.debug('UAC: accountIds ' + accountIds );
        if(accountIds.size() == 0) return ;
        
        // Get all account branch profiles related to Account 
        for(Account acc : [ SELECT Id, Branch__r.Branch_Number__c,ParentId 
                           FROM Account 
                           WHERE parentId IN :accountIds ])
        {
            // If null then initialize 
            if(!accountIdToBranchIds.containsKey(acc.parentId))
            {
                accountIdToBranchIds.put(acc.parentId, new Set<String>());
            }
            accountIdToBranchIds.get(acc.parentId).add(acc.Branch__r.Branch_Number__c);
        }
        System.debug('UAC: accountIdToBranchIds '  + accountIdToBranchIds);
        
        // Iterate over account Ids 
        for(Id accountId : accountIdToBranchIds.keySet() )
        {
            // Get branch Ids for current account Id
            String branchIds = ';' + String.join(new List<String>(accountIdToBranchIds.get(accountId)), ';' ) + ';' ;
            
            // Assign Branch Numbers on Account
            Account ac = new Account(Id=accountId, Branch_Number__c = branchIds );
            
            // Add into list 
            accountsToUpdate.add(ac);
        }
        System.debug('UAC: accountsToUpdate ' + accountsToUpdate );
        
        // Update Accounts  
        if(accountsToUpdate.size() > 0) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            Database.update(accountsToUpdate, dml);
        }
    }
    
    public static void updateAddressAssignment(Map<Id, Account> mapAcc,Map<Id, Account> oldMap){
        
        List<Id> listAccBillToUpdate=new List<Id>();
        List<Id> listAccShipToUpdate=new List<Id>();
        Id branchRecordTypeID=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BranchAccount').getRecordTypeId();
        for(Account acc:mapAcc.values()){
            system.debug('@@BillingStreet ::'+acc.BillingStreet);
            if(acc.RecordTypeId == branchRecordTypeID){
                if(acc.BillingStreet!=oldMap.get(acc.Id).BillingStreet || acc.BillingCity!=oldMap.get(acc.Id).BillingCity
                   || acc.BillingState!=oldMap.get(acc.Id).BillingState || acc.BillingCountry!=oldMap.get(acc.Id).BillingCountry
                   || acc.BillingPostalCode!=oldMap.get(acc.Id).BillingPostalCode || acc.BillingCounty__c!=oldMap.get(acc.Id).BillingCounty__c){
                       listAccBillToUpdate.add(acc.Id);
                   }
                if(acc.ShippingStreet!=oldMap.get(acc.Id).ShippingStreet || acc.ShippingCity!=oldMap.get(acc.Id).ShippingCity
                   || acc.ShippingState!=oldMap.get(acc.Id).ShippingState || acc.ShippingCountry!=oldMap.get(acc.Id).ShippingCountry
                   || acc.ShippingPostalCode!=oldMap.get(acc.Id).ShippingPostalCode || acc.ShippingCounty__c!=oldMap.get(acc.Id).ShippingCounty__c){
                       listAccShipToUpdate.add(acc.Id);
                   }
            }
        }
        system.debug('@@'+listAccBillToUpdate);
        system.debug('@@'+listAccShipToUpdate);
        Map<Id, Address__c> mapAddressToUpdate = new Map<Id, Address__c>();
        List<Address_Assignment__c> addressAssignments = [SELECT Id, Address__c, Primary_Flag__c, Account__c, Address_Usage_Type__c,
                                                          Address__r.City__c, Address__r.Country__c, Address__r.State__c, Address__r.Street__c, Address__r.Zipcode__c
                                                          FROM Address_Assignment__c
                                                          WHERE Primary_Flag__c = true 
                                                          AND Address_Usage_Type__c in ('Bill To','Ship To')
                                                          AND (Account__c IN :listAccShipToUpdate or  Account__c IN :listAccBillToUpdate)];
        
        if(addressAssignments.size() > 0){
            for(Address_Assignment__c addAss : addressAssignments){
                if(addAss.Address_Usage_Type__c=='Bill To' && listAccBillToUpdate.contains(addAss.Account__c) && mapAcc.containsKey(addAss.Account__c)){
                    
                    system.debug('@@BillingStreet11 ::'+mapAcc.get(addAss.Account__c).BillingStreet);
                    
                    Address__c newAdd = new Address__c();
                    newAdd.Id = addAss.Address__c;
                    newAdd.City__c = mapAcc.get(addAss.Account__c).BillingCity;
                    newAdd.Country__c = mapAcc.get(addAss.Account__c).BillingCountry;
                    newAdd.State__c = mapAcc.get(addAss.Account__c).BillingState;
                    newAdd.Street__c = mapAcc.get(addAss.Account__c).BillingStreet;
                    newAdd.Zipcode__c = mapAcc.get(addAss.Account__c).BillingPostalCode;
                    newAdd.County__c = mapAcc.get(addAss.Account__c).BillingCounty__c;
                    mapAddressToUpdate.put(newAdd.Id, newAdd);
                }
                if(addAss.Address_Usage_Type__c=='Ship To' && listAccShipToUpdate.contains(addAss.Account__c) && mapAcc.containsKey(addAss.Account__c)){
                    Address__c newAdd = new Address__c();
                    newAdd.Id = addAss.Address__c;
                    newAdd.City__c = mapAcc.get(addAss.Account__c).ShippingCity;
                    newAdd.Country__c = mapAcc.get(addAss.Account__c).ShippingCountry;
                    newAdd.State__c = mapAcc.get(addAss.Account__c).ShippingState;
                    newAdd.Street__c = mapAcc.get(addAss.Account__c).ShippingStreet;
                    newAdd.Zipcode__c = mapAcc.get(addAss.Account__c).ShippingPostalCode;
                    newAdd.County__c = mapAcc.get(addAss.Account__c).ShippingCounty__c;
                    mapAddressToUpdate.put(newAdd.Id, newAdd);
                }
            }
            system.debug('@@'+mapAddressToUpdate.values());
            Boolean currentFlag = AddressTriggerHandler.update_Account_Address;
            AddressTriggerHandler.update_Account_Address = false;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            Database.update(mapAddressToUpdate.values(), dml);
            //update  mapAddressToUpdate.values();
            AddressTriggerHandler.update_Account_Address = currentFlag;
        }
        
    }
    
    public static void isCreatedFromStandardUI(List<Account> listAcc){
        User u=[SELECT Id,profile.Name FROM User where Id=:userinfo.getUserId()];
        for(Account acc: listAcc){
            if(u.profile.Name <> 'Integration User' && acc.Is_From_Custom_UI__c==false && acc.IsImported__c==false){
           //     acc.addError(Label.Account_Creation_Validation, false);
            }
        }
    }
    //Method to update the EDW Last Modified 
    public static void updateEDWLastModified(List<Account> lstNew,Map<Id,Account> oldMap){
        //Query to fetch all related fileds of Account from metadata
        List<EDW_Object_Mapping__mdt> lstaccMetadta =[select id,Field_Api_Name__c,Source_Object__c from EDW_Object_Mapping__mdt where Source_Object__c='Account'];
        set<String> fieldSet = new Set<String>();
        //dynamically get the fields from the metadata and then use the same for comparison in the trigger. 
        for(EDW_Object_Mapping__mdt fields :lstaccMetadta){
            fieldSet.add(fields.Field_Api_Name__c);
        }
        for(Account acc: lstNew){
            
            for(string s: fieldSet){
                if(s.indexOf('.') > -1){
                    
                }
                else{
                    if(trigger.oldMap!=null){
                        if(acc.get(s) != trigger.oldMap.get(acc.Id).get(s)){
                            acc.EDW_Last_Modified__c=Datetime.now();
                            break;
                        }
                    }
                    else{
                        if(acc.get(s)!=null)
                            acc.EDW_Last_Modified__c=Datetime.now();
                    }
                }
            }
        }
    }
    //Method to update current priority value 
    public static void updatePriorityValue(List<Account> lstNew, Map<Id,Account> oldMap){
        Id naRecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        for(Account acc: lstNew){
        if(acc.RecordTypeId==naRecordTypeId && (acc.Priority__c!=oldMap.get(acc.Id).Priority__c )){
                acc.Priority_Prior_Value__c=oldMap.get(acc.Id).Priority__c;
            }
        if(acc.RecordTypeId==naRecordTypeId && (acc.Approved__c != oldMap.get(acc.Id).Approved__c && acc.Approved__c=='Priority Approval Rejected')){
            acc.Priority__c=acc.Priority_Prior_Value__c;
            }
         //   update acc;
        }
    }     
    
    //Update Account Phone
    public static void updateAccountPhone(List<Account> lstNew, Map<Id,Account> oldMap){
        for(Account acc : lstnew){
            if(acc.PersonHomePhone != oldMap.get(acc.Id).PersonHomePhone || acc.PersonOtherPhone != oldMap.get(acc.Id).PersonOtherPhone 
               || acc.PersonAssistantPhone != oldMap.get(acc.Id).PersonAssistantPhone || acc.PersonMobilePhone != oldMap.get(acc.Id).PersonMobilePhone
               || acc.PersonEmail != oldMap.get(acc.Id).PersonEmail){
                if(acc.PersonMobilePhone != null && String.isNotBlank(acc.PersonMobilePhone)){
                    acc.Phone = acc.PersonMobilePhone;
                }else if(acc.PersonHomePhone != null && String.isNotBlank(acc.PersonHomePhone)){
                    acc.Phone = acc.PersonHomePhone;
                }else if(acc.PersonOtherPhone != null && String.isNotBlank(acc.PersonOtherPhone)){
                    acc.Phone = acc.PersonOtherPhone;
                }else if(acc.PersonAssistantPhone != null && String.isNotBlank(acc.PersonAssistantPhone)){
                    acc.Phone = acc.PersonAssistantPhone; 
                }
            }
        }
    }
    public static void replacementOppRecordShare(List<Account> lstNew, Map<Id,Account> oldMap){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        List<Id> accIds = new List<Id>();
        List<id> oppIdstoShare = new List<Id>();
        for(Account acc : lstnew){
            if(oldMap != null && acc.OwnerId != oldMap.get(acc.Id).ownerId && acc.RecordTypeId == recordTypeId){
                accIds.add(acc.Id);
            }
        }
        if(!accIds.isEmpty()){
            for(Opportunity opp : [Select id from opportunity where account.id = :accIds and opportunity.RecordType.Name = 'Replacement']){
             oppIdstoShare.add(opp.Id);   
            }
        }
        if(!oppIdstoShare.isEmpty()){
            OpportunityRecordShare.removeShareOppWithETM(oppIdstoShare);
            OpportunityRecordShare.shareOppRecordWithETMGroup(oppIdstoShare);
        }     
    }
    
    public static void updateServiceAccountPhones(List<Account> newAccounts, Map<Id, Account> oldMap) {
        for (Account acc : newAccounts) {
            Account oldAccount = oldMap != null ? oldMap.get(acc.Id) : null;

            Boolean phoneFieldsChangedOrNew = oldAccount == null || 
                    (acc.Phone != oldAccount.Phone) ||
                    (acc.PersonOtherPhone != oldAccount.PersonOtherPhone) ||
                    (acc.PersonMobilePhone != oldAccount.PersonMobilePhone) ||
                    (acc.PersonHomePhone != oldAccount.PersonHomePhone) ||
                    (acc.PersonAssistantPhone != oldAccount.PersonAssistantPhone);

            // Concatenate and format all phone numbers, separated by hyphens
            String allPhonesConcatenated = ServiceUtil.concatenatePhoneNumbers(new List<String>{
                acc.Phone, acc.PersonOtherPhone, acc.PersonMobilePhone, acc.PersonHomePhone, acc.PersonAssistantPhone
            });

            if (phoneFieldsChangedOrNew) {
                acc.Phone_Idx__c = acc.Phone != null ? ServiceUtil.formatPhone(acc.Phone) : '';
                acc.Other_Phone_Idx__c = acc.PersonOtherPhone != null ? ServiceUtil.formatPhone(acc.PersonOtherPhone) : '';
                acc.Mobile_Idx__c = acc.PersonMobilePhone != null ? ServiceUtil.formatPhone(acc.PersonMobilePhone) : '';
                acc.Home_Phone_Idx__c = acc.PersonHomePhone != null ? ServiceUtil.formatPhone(acc.PersonHomePhone) : '';
                acc.Asst_Phone_Idx__c = acc.PersonAssistantPhone != null ? ServiceUtil.formatPhone(acc.PersonAssistantPhone) : '';
                acc.All_Account_Phones_Idx__c = allPhonesConcatenated;
            }

        }
    }
    
}//End of AccountTriggerHandler