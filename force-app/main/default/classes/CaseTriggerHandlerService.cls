/*
Created By      : Rahul Sangwan
Created Date    : 8 May 2023
Purpose         : This is a Service Class for CaseTriggerHandler. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseTriggerHandlerService implements ITriggerService{
    
    static String keyPrefix                     = Utility.getKeyPrefixOfObjectId('User');
    static Map<Id, Group> queueMap              = new Map<Id, Group>();
    static Map<String, Contact> contactEmailMap = new Map<String, Contact>(); 
    static Map<Id, Contact> contactMap ;
    
    public static void prepareDataBeforeEvent(List<Case> newList) {
        Set<Id> queueIdSet              = new Set<Id>();
        Set<Id> contactIdSet            = new Set<Id>();
        for(Case caseObj : newList) {
            String caseOwner    = caseObj.OwnerId;
            if(!caseOwner.contains(keyPrefix)) queueIdSet.add(caseOwner);
            else if(caseObj.ContactId != null) contactIdSet.add(caseObj.ContactId);
        }
        if(queueMap.isEmpty()) {
            queueMap = CaseTriggerHandlerModel.getQueueDetails(queueIdSet);
        }
        if(contactMap == null && !contactIdSet.isEmpty()) {
            contactMap  = CaseTriggerHandlerModel.getContactDetailsRelatedToCase(contactIdSet);
        }
    }
    
    
    public static void prepareDataAfterEvent(List<Case> newList) {
        List<String> suppliedEmailList  = new List<String>();
        for(Case caseObj : newList) {
            String caseOwner = caseObj.OwnerId;
            if(caseObj.ContactId == null && String.isNotBlank(caseObj.SuppliedEmail) && !caseOwner.contains(keyPrefix)) {
                suppliedEmailList.add(caseObj.SuppliedEmail);
            }
        }
        if(!suppliedEmailList.isEmpty() && contactEmailMap.isEmpty()) {
            for(Contact contactObj : CaseTriggerHandlerModel.getContactBasedOnSuppliedEmail(suppliedEmailList)) {
                if(!contactEmailMap.containsKey(contactObj.Email)) contactEmailMap.put(contactObj.Email, contactObj);
            }
        }
    }
    
    
    public static void checkAndInsertContactIfNull(List<Case> newList) {
        List<Contact> contactList           = new List<Contact>();
        Set<Id> queueIdSet                  = new Set<Id>();
        Set<String> accountNameSet          = new Set<String>();
        Map<String, Id> accountMap          = new Map<String, Id>();
        List<Case> caseToBeUpdatedList      = new List<Case>();
        
        if(!queueMap.isEmpty()) {
            for(Group queueObj : queueMap.values()) {
                accountNameSet.add(queueObj.Name + ' ' + Constant.ACCOUNT_BUCKET_SUFFIX);
            }
            for(Account accObj : CaseTriggerHandlerModel.getAccountDetails(accountNameSet)) {
                accountMap.put(accObj.Name, accObj.Id);
            }
        }
        
        for(Case caseObj : newList) {
            String caseOwner = caseObj.OwnerId;
            if(caseObj.ContactId == null && String.isNotBlank(caseObj.SuppliedEmail) && !caseOwner.contains(keyPrefix) && !contactEmailMap.containsKey(caseObj.SuppliedEmail)) {
                Contact contactObj          = new Contact();
                contactObj.Email            = caseObj.SuppliedEmail;
                contactObj.LastName         = caseObj.SuppliedEmail;
                contactObj.RecordTypeId     = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Constant.CONTACT_NEW_BLANK_CASE_RT).getRecordTypeId();
                if(queueMap.containsKey(caseObj.OwnerId) && accountMap.containsKey(queueMap.get(caseObj.OwnerId).Name + ' ' + Constant.ACCOUNT_BUCKET_SUFFIX))
                    contactObj.AccountId     = accountMap.get(queueMap.get(caseObj.OwnerId).Name + ' ' + Constant.ACCOUNT_BUCKET_SUFFIX);
                contactList.add(contactObj);
            }
        }
        
        if(!contactList.isEmpty()) {
            insert contactList;
            for(Contact contacObj : contactList) {
                contactEmailMap.put(contacObj.Email, contacObj);
            }
        }
        
        for(Case caseObj : [Select Id, ContactId, OwnerId, SuppliedEmail from Case where Id IN: newList]) {
            String caseOwner = caseObj.OwnerId;
            if(caseObj.ContactId == null && String.isNotBlank(caseObj.SuppliedEmail) &&
               !caseOwner.contains(keyPrefix) && contactEmailMap.containsKey(caseObj.SuppliedEmail)) {
                   caseObj.ContactId   = contactEmailMap.get(caseObj.SuppliedEmail).Id;
                   caseToBeUpdatedList.add(caseObj);
               }
        }
        
        if(!caseToBeUpdatedList.isEmpty()) update caseToBeUpdatedList;
    }
    
    public static void checkAndInsertContact(Map<Id, Case> newList) {
        List<Id> idList = new List<Id>(newList.KeySet());
        Map < Id, Case > lstOfCaseToUpdate = new Map < Id, Case >();       
        for( Case caseRecord : [Select Id, Contact.AccountId, AccountId from Case where id IN :idList]){
            if(caseRecord.AccountId != caseRecord.Contact.AccountId) {
                caseRecord.AccountId = caseRecord.Contact.AccountId;
                lstOfCaseToUpdate.put(caseRecord.Id, caseRecord);
                
            }
            
        }
        
        system.debug('lstOfCaseToUpdate'+lstOfCaseToUpdate);
        List<Case> CaseAccountUpdate = new List<Case>(lstOfCaseToUpdate.values());
        
        if(!CaseAccountUpdate.isEmpty()){
            update CaseAccountUpdate;
        }
        
        
    }
       /*
*   Created By      : Subhash Panchani
*   Added on        : 5 December 2023
*   Purpose         : This method will check conditions like case contact chagend or not and based on that it will update the branch on case
*   Input Param     : List of Case
*   Output Param    : 
*   User Story      : SCS-1342 Update Assigned Branch on Contact Update 
*/
    
    public static void assignBranchBasedOnContactZipCode(List<Case> newList, Map<Id, Case>oldMap){
        
         Set<String> zipCodeSet                                  = new Set<String>();
         Map<String, ServiceTerritory> zipAndBranchMap           = new Map<String, ServiceTerritory>();
         List<String> branchNameList                             = new List<String>();
        
        // new case list
        List<Case> caseList = new List<Case>();
        Set<Id> contactIdSet            = new Set<Id>();
        for(Case caseObj : newList){
            
            //old case obj
            Case oldCase = oldMap.get(caseObj.Id);
            //check contact Id changed
            //System.debug('oldCase'+oldCase.ContactId);
            //System.debug('caseObj'+caseObj.ContactId);
            if(caseObj.ContactId != oldCase.ContactId){
                //add to the new case list
                System.debug('CHECK CONTACT');
                caseList.add(caseObj);
            }
            contactIdSet.add(caseObj.ContactId);
        }
        if(contactMap == null && !contactIdSet.isEmpty()) {
            contactMap  = CaseTriggerHandlerModel.getContactDetailsRelatedToCase(contactIdSet);
        }
        //System.debug('zipAndBranchMap-->'+zipAndBranchMap);
        //System.debug('caseList-->'+caseList);
        //System.debug('contactMap-->'+contactMap);
        if(!caseList.isEmpty()){
            // update the branch using zip code
            if(contactMap != null) {            
                for(Contact contactObj : contactMap.values()) {
                    if(String.isNotBlank(contactObj.MailingPostalCode)) zipCodeSet.add(contactObj.MailingPostalCode);
                }
                //System.debug('zipCodeSet-->'+zipCodeSet);
                for(ServiceTerritory zipObj : CaseTriggerHandlerModel.getTerritoryDetails(zipCodeSet)) {
                    zipAndBranchMap.put(zipObj.Name, zipObj);
                    if(zipObj.Branch__c != null)branchNameList.add(zipObj.Branch_Hidden__c);
                }
                
                //System.debug('zipAndBranchMap-->'+zipAndBranchMap);
                //Traverse case records and accordingly find the Branch from zipAndBranchMap
                for(Case caseObj : newList) {
                    if(caseObj.ContactId != null && contactMap.containsKey(caseObj.ContactId) && zipAndBranchMap.containsKey(contactMap.get(caseObj.ContactId).MailingPostalCode)) {
                        caseObj.AssignedBranch__c   = zipAndBranchMap.get(contactMap.get(caseObj.ContactId).MailingPostalCode).Branch__c;
                        caseObj.Assigned_Branch_Text__c = zipAndBranchMap.get(contactMap.get(caseObj.ContactId).MailingPostalCode).Branch__r.Name;
                    }
                }
            }
        }
    }
    
    
    /*
*   Created By      : Rahul Sangwan
*   Added on        : 8 May 2023
*   Purpose         : This method will assign Branch on the Case to the correct queue based on the zip code.
*   Input Param     : List of Case
*   Output Param    : void.
*   User Story      : SCS-275
*/
    public static void assignOwnerBasedOnZipCode(List<Case> newList) {
        
        Set<Id> contactIdSet                                    = new Set<Id>();
        Set<String> zipCodeSet                                  = new Set<String>();
        Map<String, ServiceTerritory> zipAndBranchMap           = new Map<String, ServiceTerritory>();
        Map<String, String> branchAndQueueMap                   = new Map<String, String>();
        List<String> branchNameList                             = new List<String>();
        Map<String, String> branchMap                           = new Map<String, String>();
        Map<Id, String> queueLMap                                = new Map<Id, String>();                
        
        for(Group queueObj : queueMap.values()) {
            queueLMap.put(queueObj.Id, queueObj.Name);
        }
        
        for(Branch__c branchObj : CaseTriggerHandlerModel.getBranchDetailsBasedOnName(queueLMap.values())) {
            branchMap.put(branchObj.Name, branchObj.Id);
        }
        
        for(Case caseObj : newList) {
            String ownerId = caseObj.OwnerId;
            caseObj.Assigned_Queue__c = String.valueOf(caseObj.ownerId).startsWith('00G') ? queueLMap.get(OwnerId) : null; // SCS-738
            if(!ownerId.startsWithIgnoreCase(keyPrefix) && branchMap.containsKey(queueLMap.get(OwnerId))) {
                caseObj.AssignedBranch__c       = branchMap.get(queueLMap.get(OwnerId));
                caseObj.Assigned_Branch_Text__c = queueLMap.get(OwnerId);
            }
        }
        
        if(contactMap != null) {            
            for(Contact contactObj : contactMap.values()) {
                if(String.isNotBlank(contactObj.MailingPostalCode)) zipCodeSet.add(contactObj.MailingPostalCode);
            }
            
            for(ServiceTerritory zipObj : CaseTriggerHandlerModel.getTerritoryDetails(zipCodeSet)) {
                zipAndBranchMap.put(zipObj.Name, zipObj);
                if(zipObj.Branch__c != null)branchNameList.add(zipObj.Branch_Hidden__c);
            }
            //Traverse case records and accordingly find the Branch from zipAndBranchMap
            for(Case caseObj : newList) {
                if(caseObj.ContactId != null && contactMap.containsKey(caseObj.ContactId) && zipAndBranchMap.containsKey(contactMap.get(caseObj.ContactId).MailingPostalCode)) {
                    caseObj.AssignedBranch__c   = zipAndBranchMap.get(contactMap.get(caseObj.ContactId).MailingPostalCode).Branch__c;
                    caseObj.Assigned_Branch_Text__c = zipAndBranchMap.get(contactMap.get(caseObj.ContactId).MailingPostalCode).Branch__r.Name;
                }
            }
        }
        
        
    }
    
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 24 May 2023
*   Purpose         : This method will check conditions like customer numbers must be same and closed cases can't get merged while Case Merge
*   Input Param     : List of Case
*   Output Param    : 
*   User Story      : SCS-30 Case - Merge Cases
*/
    
    public static void caseMergeValidations(List<Case> newList,Map<Id, Case> oldCaseMap) {
        Set<String> customerNumbers     = new Set<String>();
        Set<String> masterCaseIds       = new Set<String>();
        Set<Id> caseIdsToUpdate         = new Set<Id>();
        
        // Collect the Customer Numbers from the Case objects being updated
        for (Case caseObj : newList) {
            if (caseObj.MasterRecordId != null) {
                masterCaseIds.add(caseObj.MasterRecordId);
                
            }
            customerNumbers.add(caseObj.Customer_Number__c);
            
            // If Child Case old status is "Closed" and Child Case new status is "Merged" then addError
            // SCS-504 Case - Merge Cases Validations
            if (oldCaseMap.containsKey(caseObj.Id) && oldCaseMap.get(caseObj.Id).Status == Constant.CASE_STATUS_CLOSED
                && (caseObj.Status == Constant.CASE_STATUS_MERGED)) {
                    caseObj.addError(Constant.CLOSED_CASES_MERGE_ERROR_TEXT);
                }
        }
        
        Map<Id, Case> mapMasterCase = CaseTriggerHandlerModel.getMasterCaseMap(masterCaseIds);
        
        //SCS-504 Case - Merge Cases Validations
        for (Case caseObj : newList) {
            if (oldCaseMap.get(caseObj.Id).MasterRecordId ==null && caseObj.MasterRecordId != null && mapMasterCase.containsKey(caseObj.MasterRecordId)) {
                if (mapMasterCase.get(caseObj.MasterRecordId).Customer_Number__c != caseObj.Customer_Number__c) {
                    caseObj.addError(Constant.CUSTOMER_NUMBER_ERROR);
                    
                }
                if (mapMasterCase.get(caseObj.MasterRecordId).AssignedBranch__c != caseObj.AssignedBranch__c) {
                    caseObj.addError(Constant.ASSIGNED_BRANCH_ERROR);
                }
            }
        }
        
        // Collect the Customer Numbers from the Case objects being updated
        for (Case caseObj : newList) {
            
            // If Master Case status is "Closed" and Child Case New status "Merged" then addError
            // SCS-504 Case - Merge Cases Validations //Added on 16-06-2023
            if ( caseObj.MasterRecordId!=null && mapMasterCase.get(caseObj.MasterRecordId).Status == Constant.CASE_STATUS_CLOSED && caseObj.Status == Constant.CASE_STATUS_MERGED) {
                caseObj.addError(Constant.CLOSED_CASES_MERGE_ERROR_TEXT);
            }
        }
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 29 May 2023
*   Purpose         : To Prevent Changing 'Assigned To' and 'Status'
*   Input Param     : List of Case
*   Output Param    : 
*   User Story      : SCS-421/SCS-422
*/
    public static void caseUpdateValidations(List<Case> newList , Map<Id, Case> oldCaseMap) {
        List<Group> groups = CaseTriggerHandlerModel.getGroups();
        
        for (Case caseObj : newList) {
            Case oldCase = oldCaseMap.get(caseObj.Id);
            if(oldCase!=null ) {
                if (oldCase.Status != Constant.CASE_STATUS_COMPLETED && oldCase.Status != Constant.CASE_STATUS_CANCELLED && oldCase.Status != Constant.CASE_STATUS_MERGED && oldCase.Status != Constant.CASE_STATUS_INACTIVE) {
                    if ((groups.size()>0  && oldCase.OwnerId == groups[0].Id )&& (caseObj.OwnerId != oldCase.OwnerId || caseObj.Status != oldCase.Status)) {
                        if (!isCommunicationQueueMember(userinfo.getUserId())) {
                            caseObj.addError(Constant.CASE_UPDATE_PERMISSION_ERROR);
                        }
                    }
                }
            }
        }
    }
    
    public static Boolean isCommunicationQueueMember(Id ownerId) {
        Set<Id> communicationQueueIds = new Set<Id>();
        List<GroupMember> groupMembers = CaseTriggerHandlerModel.getGroupMembers();
        
        for (GroupMember member : groupMembers) {
            communicationQueueIds.add(member.UserOrGroupId);
        }
        
        return communicationQueueIds.contains(ownerId);
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 29 May 2023
*   Purpose         : it will show an Red Flag on the case when there is something in Internal Comment
*   Input Param     : List of Case
*   Output Param    : 
*   User Story      : SCS-425
*/
    public static void UpdateHasInternalComments(List<Case> newList) {
        for (Case caseObj : newList) {
            caseObj.Has_Internal_Comments__c = String.isNotBlank(caseObj.Internal_Comments__c);
        }
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 6 June 2023
*   Purpose         : This will Check 3 Conditions on the Cc: Other Email Addresses field , 1)Format of Email 2)Semicolon Saperated Emails 3)Remove Duplicates
*   Input Param     : List of Case
*   Output Param    : 
*   User Story      : SCS-425
*/  
    public static void CheckCcOtherEmailAddresses(List<Case> newList) {
        // List<Case> newCasesList = Trigger.new;
        Set<String> uniqueEmails = new Set<String>();
        
        for (Case caseObj : newList) {
            // Check if the Cc_Other_Email_Addresses__c field is not null or empty
            if (!String.isBlank(caseObj.Cc_Other_Email_Addresses__c)) {
                // Remove extra spaces from the email addresses and surrounding spaces
                String cleanedEmailAddresses = caseObj.Cc_Other_Email_Addresses__c.replaceAll(' ', '').trim();
                
                // Split the cleaned field value into individual email addresses
                List<String> emailAddresses = cleanedEmailAddresses.split(';');
                
                for (Integer i = 0; i < emailAddresses.size(); i++) {
                    String email = emailAddresses[i];
                    
                    // Check if the email address is in the correct format
                    if (!Pattern.matches('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}', email)) {
                        caseObj.addError('Email address \'' + email + '\' is not in the correct format. Make sure to separate each email address with a semicolon ";"');
                    }
                    
                    if (uniqueEmails.contains(email)) {
                        emailAddresses.remove(i);
                        i--;
                    } else {
                        uniqueEmails.add(email);
                    }
                }
                
                // Join the cleaned email addresses back into a single string separated by semicolons
                caseObj.Cc_Other_Email_Addresses__c = String.join(emailAddresses, ' ; ');
            }
        }
    }
    /*
*   Created By      : Subhash Panchani
*   Added on        : 7 June 2023
*   Purpose         : It will make Has_Contact_Notes__c true and false based on there is value in Contact_Notes__c or not.
*   Input Param     : List of Case
*   Output Param    : 
*   User Story      : SCS-426
*/
    public static void UpdateHasContactNotes(List<Case> newList) {
        set<Id> setContactIds=new set<Id>();
        for (Case caseObj : newList) {
            
            caseObj.Has_Contact_Notes__c = String.isNotBlank(caseObj.Contact_Notes__c);
            
            if (caseObj.ContactId != null) {
                setContactIds.add(caseObj.ContactId);
            }
        }
        // If found any contact
        if(setContactIds.size()>0){
            Map<Id,String> contactIdWiseMap=new Map<Id,String>();
            for(Contact con : CaseTriggerHandlerModel.getContactDetails(setContactIds)){
                contactIdWiseMap.put(con.id,con.Contact_Notes__c);
            }
            
            // Update on Case If contact found
            for (Case caseObj : newList) {
                // If new case created with contact or linked contact updated
                if(caseObj.ContactId != null && contactIdWiseMap.containsKey(caseObj.ContactId)){
                    caseObj.Contact_Notes__c=contactIdWiseMap.get(caseObj.ContactId);
                    caseObj.Has_Contact_Notes__c=String.isNotBlank(caseObj.Contact_Notes__c);
                }
            }
        }
    }
    
    /*
*   Created By      : Rahul Sangwan
*   Added on        : 8 June 2023
*   Purpose         : It will update Assigned Branch field based on the Queue, if the Owner of Case has been changed to Queue. 
*                     System will check Branch with same name as Queue Name and accordingly find Branch with same name.
*   Input Param     : New and Old Map of Case
*   Output Param    : void
*   User Story      : SCS-307
*/
    public static void assignBranchBasedOnQueue(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        Map<Id, String> queueLMap           = new Map<Id, String>();
        Map<String, String> branchMap       = new Map<String, String>();
        
        for(Group queueObj : queueMap.values()) {
            queueLMap.put(queueObj.Id, queueObj.Name);
        }
        
        for(Branch__c branchObj : CaseTriggerHandlerModel.getBranchDetailsBasedOnName(queueLMap.values())) {
            branchMap.put(branchObj.Name, branchObj.Id);
        }
        
        for(Case caseObj : newMap.values()) {
            String ownerId = caseObj.OwnerId;
            if(caseObj.OwnerId != oldMap.get(caseObj.Id).OwnerId && String.valueOf(caseObj.ownerId).startsWith('00G')) { // SCS-738
                caseObj.Assigned_Queue__c = queueLMap.get(OwnerId); 
            }
            if(!ownerId.startsWithIgnoreCase(keyPrefix) && caseObj.OwnerId != oldMap.get(caseObj.Id).OwnerId && branchMap.containsKey(queueLMap.get(OwnerId))) {
                caseObj.AssignedBranch__c       = branchMap.get(queueLMap.get(OwnerId));
                caseObj.Assigned_Branch_Text__c = queueLMap.get(OwnerId);
            }
        }  
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 9 June 2023
*   Purpose         : This Method with add Current date in Invoice_Close_Date__c field when case Status is updated to 'Closed'
*   Input Param     : New and Old Map of Case
*   Output Param    : void
*   User Story      : SCS-434
*/
    public static void updateInvoiceCloseDate(List<Case> newList , Map<Id, Case> oldMap) {
        Metadata_Control__c metadataControl = Metadata_Control__c.getInstance();
        if (metadataControl != null && !metadataControl.Case_Disable_Trigger__c) {
            for (Case caseObj : newList) {
                // Check if old case exists and its status is not Completed or Cancelled
                Case oldCase = oldMap.get(caseObj.Id);
                if (oldCase != null && (oldCase.Status != caseObj.Status)) {
                    if (caseObj.Status == Constant.CASE_STATUS_CLOSED) {
                        caseObj.Invoice_Close_Date__c = DateTime.now();
                    }
                }
            }
        }
    }
    
    
    /*
*   Created By      : Rahul Sangwan
*   Added on        : 9 June 2023
*   Purpose         : This Method is to reset the Branch Sharing for Case related child records.
*   Input Param     : New and Old Map of Case
*   Output Param    : void
*   User Story      : SCS-406
*/
    public static void checkBranchChangeForResettingSharing(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        /* 
Whenver Case Assigned Branch is changed, we need to reset sharing settings for all related Objects.(Currently handling Work Order, Service Appointment and Case Escalation).
To Handle all the related data, as the number of data to be processed can hit Governor limits, we divided the logic into Queues.
For each related object, we have added 2 Queuables. 1st one to delete the old Branch Sharing and 2nd Queueable to add sharing for new Branch.
As of now we have 6 Queueables which are chained.
1) WorkOrderBranchSharingQueueable       - To delete old Branch sharing for case related Work Orders.
2) WorkOrderNewBranchSharingQueueable    - To insert new Branch sharing for case related Work Orders.
3) SABranchSharingQueueable              - To delete old Branch sharing for case related Service Appointments.
4) SANewBranchSharingQueueable           - To insert new Branch sharing for case related Service Appointments.
5) CaseEscalationBranchSharingQueueable  - To delete old Branch sharing for case related Case Escalations.
6) CaseEscNewBranchSharingQueueable      - To insert new Branch sharing for case related Case Escalations.
*/
        Map<Id, Id> caseAndRelatedOldBranchMap  = new Map<Id, Id>();
        for(Case caseObj : newMap.values()) {
            if(caseObj.AssignedBranch__c != oldMap.get(caseObj.Id).AssignedBranch__c) caseAndRelatedOldBranchMap.put(caseObj.Id, oldMap.get(caseObj.Id).AssignedBranch__c);
        }
        if(!caseAndRelatedOldBranchMap.isEmpty()) {
            System.enqueueJob(new WorkOrderBranchSharingQueueable(caseAndRelatedOldBranchMap));
        }
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 29 June 2023
*   Purpose         : When Case Status is updated to 'Completed' or 'Cancelled' then it will send email to user.
*   Input Param     : New and Old Map of Case
*   Output Param    : void
*   User Story      : SCS-434
*/
    public static void sendEmailOnCaseStatusUpdate(List<Case> newList , Map<Id, Case> oldMap) {
        Id completedEmailTemplateId = CaseTriggerHandlerModel.getCompletedemailTemplateId();
        Id cancelledEmailTemplateId = CaseTriggerHandlerModel.getCancelledEmailTemplateId();
        OrgWideEmailAddress[] owea = CaseTriggerHandlerModel.getOrgWideEmailAddress();
        
        //SCS-874
        List<Contact> caseContactList = new List<Contact>();
        List<String> caseContactIds = new List<String>();
        for(Case caseObj : newList){
            caseContactIds.add(caseObj.ContactId);
        }
        caseContactList = CaseTriggerHandlerModel.getCaseContactDetails(caseContactIds);
        Map<Id, Contact> caseContactMap = new Map<Id, Contact>(caseContactList);
        //SCS-874
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Case caseObj : newList) {
            if((caseObj.Status == Constant.CASE_STATUS_COMPLETED && caseObj.Status != oldMap.get(caseObj.Id).Status && caseObj.ContactEmail != null) ||
               (caseObj.Status == Constant.CASE_STATUS_CANCELLED && caseObj.Status != oldMap.get(caseObj.Id).Status && caseObj.ContactEmail != null)){
                   if(caseContactMap.containsKey(caseObj.ContactId)){
                       caseObj.addError('The email address '+ caseContactMap.get(caseObj.ContactId).Email +' on this record is invalid. Please verify and update the recipient’s email address');
                       continue;
                   }
               }
            
            
            
            
            // Check if the case status has been updated to "Completed"
            if (caseObj.Status == Constant.CASE_STATUS_COMPLETED && caseObj.Status != oldMap.get(caseObj.Id).Status && caseObj.ContactEmail != null) {
                // Create an email message with an email template
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(completedEmailTemplateId); // Set the retrieved email template ID
                email.setTargetObjectId(caseObj.ContactId); // Replace with the appropriate recipient's contact ID
                email.setWhatId(caseObj.Id); // Set the related case ID
                email.setSaveAsActivity(true); // Set whether to save the email as an activity on the case
                // Set the "From" address
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                // Set the "Reply-To" address
                email.setReplyTo(Constant.CASE_REPLY_TO_ADDRESS); // Replace with the desired reply-to email address
                emailsToSend.add(email);
                // System.debug('emailsToSend '+ emailsToSend);
            }
            if (caseObj.Status == Constant.CASE_STATUS_CANCELLED && caseObj.Status != oldMap.get(caseObj.Id).Status && caseObj.ContactEmail != null) {
                // Create an email message with an email template
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(cancelledEmailTemplateId); // Set the retrieved email template ID
                email.setTargetObjectId(caseObj.ContactId); // Replace with the appropriate recipient's contact ID
                email.setWhatId(caseObj.Id); // Set the related case ID
                email.setSaveAsActivity(true); // Set whether to save the email as an activity on the case
                // Set the "From" address
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                // Set the "Reply-To" address
                email.setReplyTo(Constant.CASE_REPLY_TO_ADDRESS); // Replace with the desired reply-to email address
                emailsToSend.add(email);
            }
        }
        
        // Send the emails
        if (!emailsToSend.isEmpty()) {
            //Messaging.sendEmail(emailsToSend);
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailsToSend);
            for (Messaging.SendEmailResult result : sendResults) {
                if (result.isSuccess()) {
                    System.debug('Email sent successfully.');
                } else {
                    System.debug('Failed to send email: ' + result.getErrors());
                }
            }
        }
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 3 July 2023
*   Purpose         : This method will populate 'Description_Brief__c' from 'Description' when case is created through Email-to-Case.
*   Input Param     : New List
*   Output Param    : void
*   User Story      : SCS-588
*/
    public static void updateDescriptionOnCreationOfCase(List<Case> newList) {
        for (Case newCase : newList) {
            String caseDescription = newCase.Description;
            
            // Check if the Case origin is Email and the description is not blank
            if (newCase.Origin == Constant.CASE_ORIGIN_EMAIL && String.isNotBlank(caseDescription)) {
                
                if (caseDescription.length() > 350) {
                    caseDescription = caseDescription.substring(0, 350);
                }
                
                newCase.Description_Brief__c = caseDescription;
            }
        }
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 7 July 2023
*   Purpose         : This Method will be called on BeforeInsert which will Update Internal Comment if Case doesn't have any ContactEmail.
*   Input Param     : Old Map, New List
*   Output Param    : void
*   User Story      : 
*/
    public static void updateInternalCommentsOnCaseReopen(List<Case> newList, Map<Id, Case> oldMap) {
        DateTime currentTime = DateTime.now();
        
        for (Case caseObj : newList) {
            Case oldCase = oldMap.get(caseObj.Id);
            
            // Check if the old status is Completed or Cancelled and the new status is not Completed or Cancelled
            if ((oldCase.Status == Constant.CASE_STATUS_COMPLETED || oldCase.Status == Constant.CASE_STATUS_CANCELLED) &&
                !(caseObj.Status == Constant.CASE_STATUS_COMPLETED || caseObj.Status == Constant.CASE_STATUS_CANCELLED) &&
                String.isBlank(caseObj.ContactEmail) && !caseObj.Case_Updated_By_Email__c) {
                    
                    // Prepend 'Case was Reopened By:' to the existing Internal_Comments__c field value
                    if (String.isBlank(caseObj.Internal_Comments__c)) {
                        caseObj.Internal_Comments__c = 'Case was Reopened By Agent - ' + currentTime.format('M/d/yyyy h:mm a');
                    } else {
                        String newComment = 'Case was Reopened By Agent - ' + currentTime.format('M/d/yyyy h:mm a') + '\n' + caseObj.Internal_Comments__c;
                        caseObj.Internal_Comments__c = newComment;
                    }
                }else{
                    caseObj.Case_Updated_By_Email__c = false;
                }
            
        }
    }
    
    /*
*   Created By      : Dev Anand
*   Added on        : 21 July 2023
*   Purpose         : To allow only few fields to be editable when a Case is Closed or Cancelled
*   Input Param     : List of Case
*   Output Param    : 
*   User Story      : SCS-320/SCS-382
*/
    public static void caseUpdateValidationsForClosedOrCancelledStatus(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        
        // List of fields which can be edited even if the Case status is Closed or Cancelled
        List<String> allowedFields = Constant.CASE_EDITABLE_FIELDS_LIST.split(',',0);
        // Custom Permission name that if assigned to a user, the below validation will be skipped
        String editPermissionName = Constant.CASE_MODIFY_CUSTOM_PERMISSION;
        // Does the current user has the Custom Persmission that disabled this validation
        Boolean hasEditPermission = FeatureManagement.checkPermission(editPermissionName);
        // Custom Setting instance
        Metadata_Control__c customSetting = Metadata_Control__c.getInstance();
        // Using Type instead of Schema.describeSObjects or Schema.getGlobalDescribe which are way slower
        Map<String,Schema.SObjectField> caseFieldsMap = ((SObject)Type.forName('Schema','Case').newInstance()).getSObjectType().getDescribe().fields.getMap();
        
        for (Case newRecord : newMap.values()) {
            // Case record before the edit
            Case oldRecord = oldMap.get(newRecord.Id);
            // NULL check
            if(oldRecord !=null ) {
                // Case status before the trigger was triggered due to Case Edit
                if (oldRecord.Status == Constant.CASE_STATUS_CLOSED || oldRecord.Status == Constant.CASE_STATUS_CANCELLED) {
                    // Loop through the list of all the fields that have values
                    // Commented the code in 1st loop as the 2nd loop handles all the fields
                    /*
for (String fieldInUpperCase : newRecord.getPopulatedFieldsAsMap().keySet()) {
String field = fieldInUpperCase.toLowerCase();
// Check if the field value as changed and the field modified is not among the allowed fields and custom setting for validation is not disabled 
if (!hasEditPermission && (newRecord.get(field) != oldRecord.get(field) && !allowedFields.contains(field) && (customSetting != null && !customSetting.Case_Disable_VR__c))) {
// Throw an error to the user                 
newRecord.addError('Since the Case is '+ oldRecord.Status + ', you cannot edit the field ' + caseFieldsMap.get(field).getDescribe().getLabel());
}
}*/
                    // Loop through all the fields if the above condition didn't fire for NULLified fields                    
                    for (String field : caseFieldsMap.keyset()) {
                        // Check if the field value as changed and the field modified is not among the allowed fields and custom setting for validation is not disabled 
                        if (!hasEditPermission && (newRecord.get(field) != oldRecord.get(field) && !allowedFields.contains(field) && (customSetting != null && !customSetting.Case_Disable_VR__c))) {
                            // Throw an error to the user                 
                            newRecord.addError('Since the Case is '+ oldRecord.Status + ', you cannot edit the field ' + caseFieldsMap.get(field).getDescribe().getLabel());
                        }
                    }                    
                }
            }
        }
    }
    
    
    /*
*   Created By      : Rahul Sangwan
*   Added on        : 28 July 2023
*   Purpose         : Share Case record with related Branches based on Assigned Branch.
*   Input Param     : Map<Id, Case> newMap, Map<Id, Case> oldMap
*   Output Param    : 
*   User Story      : SCS-681
*/
    public static void shareCaseWithRelatedBranches(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        Map<Id, Case> sharingCaseRecords                = new Map<Id, Case>();
        Map<Id, Case> oldSharingCaseRecords             = new Map<Id, Case>();
        Set<Id> branchIdSet                             = new Set<Id>();
        Map<Id, String> branchMap                       = new Map<Id, String>();
        Map<String, Id> groupMap                        = new Map<String, Id>();
        Map<Id, List<Id>> branchAndBranchGroupMap       = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchGroupAndBranchMap       = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchAndRelBranchesMap       = new Map<Id, List<Id>>();
        Map<Id, List<CaseShare>> shareMap               = new Map<Id, List<CaseShare>>();
        List<CaseShare> shareRecordsToInsertList        = new List<CaseShare>();
        List<CaseShare> shareRecordsToDeleteList        = new List<CaseShare>();
        
        for(Case caseObj : newMap.values()) {
            if((oldMap == null && caseObj.AssignedBranch__c != null) || (oldMap != null && caseObj.AssignedBranch__c != null && caseObj.AssignedBranch__c != oldMap.get(caseObj.Id).AssignedBranch__c)) {
                sharingCaseRecords.put(caseObj.Id, caseObj);
                branchIdSet.add(caseObj.AssignedBranch__c);
                if(oldMap != null) {
                    oldSharingCaseRecords.put(caseObj.Id, oldMap.get(caseObj.Id));
                    branchIdSet.add(oldMap.get(caseObj.Id).AssignedBranch__c);
                }
            } 
        }
        
        if(!sharingCaseRecords.isEmpty()) {
            for(Branch_To_BranchGroup_Association__c branchAssociationObj : CaseTriggerHandlerModel.getBranchGroupAssociations()) {
                branchIdSet.add(branchAssociationObj.Branch__c);
                if(branchAndBranchGroupMap.containsKey(branchAssociationObj.Branch__c)) branchAndBranchGroupMap.get(branchAssociationObj.Branch__c).add(branchAssociationObj.BranchGroup__c);
                if(!branchAndBranchGroupMap.containsKey(branchAssociationObj.Branch__c)) branchAndBranchGroupMap.put(branchAssociationObj.Branch__c, new List<Id> {branchAssociationObj.BranchGroup__c});
                if(branchGroupAndBranchMap.containsKey(branchAssociationObj.BranchGroup__c)) branchGroupAndBranchMap.get(branchAssociationObj.BranchGroup__c).add(branchAssociationObj.Branch__c);
                if(!branchGroupAndBranchMap.containsKey(branchAssociationObj.BranchGroup__c)) branchGroupAndBranchMap.put(branchAssociationObj.BranchGroup__c, new List<Id> {branchAssociationObj.Branch__c});
            }
            
            for(Id branchId : branchIdSet) {
                if(branchAndBranchGroupMap.containsKey(branchId)) {
                    for(Id branchGroupId : branchAndBranchGroupMap.get(branchId)) {
                        if(branchAndRelBranchesMap.containsKey(branchId)) branchAndRelBranchesMap.get(branchId).addAll(branchGroupAndBranchMap.get(branchGroupId));
                        else branchAndRelBranchesMap.put(branchId, branchGroupAndBranchMap.get(branchGroupId));
                    }
                }            
            }
            
            for(Branch__c branchObj : CaseTriggerHandlerModel.getBranchDetails(branchIdSet)) {
                branchMap.put(branchObj.Id, Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c);
            }
            
            for(Group groupObj : CaseTriggerHandlerModel.getPublicGroupsByName(branchMap.values())) {
                groupMap.put(groupObj.Name, groupObj.Id);
            }
            
            if(!oldSharingCaseRecords.isEmpty()) {
                for(CaseShare caseShareObj : CaseTriggerHandlerModel.getCaseShareRecords(oldMap.keySet())) {
                    if(shareMap.containsKey(caseShareObj.CaseId)) shareMap.get(caseShareObj.CaseId).add(caseShareObj);
                    else shareMap.put(caseShareObj.CaseId, new List<CaseShare>{caseShareObj});
                }
            }
            
            for(Id caseId : sharingCaseRecords.keySet()) {
                if(branchAndRelBranchesMap.containsKey(sharingCaseRecords.get(caseId).AssignedBranch__c)) {
                    for(Id branchRecId : branchAndRelBranchesMap.get(sharingCaseRecords.get(caseId).AssignedBranch__c)) {
                        if(branchMap.containsKey(branchRecId) && groupMap.containsKey(branchMap.get(branchRecId))) 
                            shareRecordsToInsertList.add(createCaseShareRecord(caseId, groupMap.get(branchMap.get(branchRecId))));
                    }
                }else{
                    if(branchMap.containsKey(sharingCaseRecords.get(caseId).AssignedBranch__c) && groupMap.containsKey(branchMap.get(sharingCaseRecords.get(caseId).AssignedBranch__c))) 
                        shareRecordsToInsertList.add(createCaseShareRecord(caseId, groupMap.get(branchMap.get(sharingCaseRecords.get(caseId).AssignedBranch__c))));
                }
                
                if(oldSharingCaseRecords.containsKey(caseId) && branchMap.containsKey(oldSharingCaseRecords.get(caseId).AssignedBranch__c)) {
                    Id caseBranchId         = oldSharingCaseRecords.get(caseId).AssignedBranch__c;
                    Id groupId              = groupMap.containsKey(branchMap.get(caseBranchId)) ? groupMap.get(branchMap.get(caseBranchId)) : null;
                    List<Id> groupIdList    = new List<Id>();
                    
                    if(branchAndRelBranchesMap.containsKey(caseBranchId)) {
                        for(Id gpId : branchAndRelBranchesMap.get(caseBranchId))
                            groupIdList.add(groupMap.get(branchMap.get(gpId)));
                    }
                    
                    for(CaseShare shareObj : shareMap.get(caseId)) {
                        if(shareObj.UserOrGroupId == groupId || groupIdList.contains(shareObj.UserOrGroupId)) shareRecordsToDeleteList.add(shareObj);
                    }
                }
            }
            if(!shareRecordsToDeleteList.isEmpty()) Database.delete(shareRecordsToDeleteList, false);
            if(!shareRecordsToInsertList.isEmpty()) Database.insert(shareRecordsToInsertList, false);
            
        }
    }
    
    
    public static void shareCaseWithRelatedBranches_v2(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
//        System.debug('Line 742:::::');
        Map<Id, Case> sharingCaseRecords                		= new Map<Id, Case>();
  //      Map<Id, Case> oldSharingCaseRecords             		= new Map<Id, Case>();
        Map<String, List<String>> branchAndPublicGroupNameMap   = new Map<String, List<String>>();
        Map<String, List<String>> bGroupAndPublicGroupNameMap   = new Map<String, List<String>>();
        Set<Id> branchShareWithAssociationIdSet                 = new Set<Id>();
        Map<String, List<String>> branchAndBranchGroupMap       = new Map<String, List<String>>();
        Set<Id> branchGroupIdSet                                = new Set<Id>();
        Set<Id> branchIdSet                             		= new Set<Id>();
        List<String> publicGroupNameSet                         = new List<String>();
        Map<String, Id> groupMap                                = new Map<String, Id>();
        List<CaseShare> shareRecordsToInsertList                = new List<CaseShare>();
        
        for(Case caseObj : newMap.values()) {
            if((oldMap == null && caseObj.AssignedBranch__c != null) || (oldMap != null && caseObj.AssignedBranch__c != null && caseObj.AssignedBranch__c != oldMap.get(caseObj.Id).AssignedBranch__c)) {
                sharingCaseRecords.put(caseObj.Id, caseObj);
                branchIdSet.add(caseObj.AssignedBranch__c);
                if(oldMap != null) {
       //             oldSharingCaseRecords.put(caseObj.Id, oldMap.get(caseObj.Id));
       //             branchIdSet.add(oldMap.get(caseObj.Id).AssignedBranch__c);
                }
            }
        }
        System.debug('branchIdSet:::'+branchIdSet);
        
        for(Branch__c branchObj : [Select Id, Share_to_other_Branches_in_Group__c, T_C_Branch_Number__c from Branch__c where Id IN: branchIdSet]) {
            if(branchObj.Share_to_other_Branches_in_Group__c == false) {
                branchAndPublicGroupNameMap.put(branchObj.Id, new List<String>{Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.T_C_Branch_Number__c});
                publicGroupNameSet.add(Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.T_C_Branch_Number__c);
            } else {
                branchShareWithAssociationIdSet.add(branchObj.Id);
            }
        }
        System.debug('branchAndPublicGroupNameMap:::'+branchAndPublicGroupNameMap);
        System.debug('branchShareWithAssociationIdSet:::'+branchShareWithAssociationIdSet);
        
        for(Branch_To_BranchGroup_Association__c bbaObj : [SELECT Id, Branch__c, Branch__r.Name, BranchGroup__c, BranchGroup__r.Name, BranchGroup__r.Grouping_Type__c, BranchGroup__r.Share_with_Related_Branches__c, BranchGroup__r.Public_Group_Name__c FROM Branch_To_BranchGroup_Association__c WHERE Branch__c IN: branchShareWithAssociationIdSet]) {
            if(bbaObj.BranchGroup__r.Share_with_Related_Branches__c == false && bbaObj.BranchGroup__r.Public_Group_Name__c != null) {
                if(branchAndPublicGroupNameMap.containsKey(bbaObj.Branch__c)) branchAndPublicGroupNameMap.get(bbaObj.Branch__c).add(bbaObj.BranchGroup__r.Public_Group_Name__c);
                else branchAndPublicGroupNameMap.put(bbaObj.Branch__c, new List<String>{bbaObj.BranchGroup__r.Public_Group_Name__c});
                publicGroupNameSet.add(bbaObj.BranchGroup__r.Public_Group_Name__c);
            }
            if(bbaObj.BranchGroup__r.Share_with_Related_Branches__c == true) {
                branchGroupIdSet.add(bbaObj.BranchGroup__c);
                if(branchAndBranchGroupMap.containsKey(bbaObj.Branch__c)) branchAndBranchGroupMap.get(bbaObj.Branch__c).add(bbaObj.BranchGroup__c);
                else branchAndBranchGroupMap.put(bbaObj.Branch__c, new List<String>{bbaObj.BranchGroup__c});
            }
        }
        System.debug('branchAndPublicGroupNameMap:::'+branchAndPublicGroupNameMap);
        System.debug('branchAndBranchGroupMap:::'+branchAndBranchGroupMap);
        
        for(Branch_To_BranchGroup_Association__c bbaObj : [SELECT Id, Branch__c, Branch__r.Name, Branch__r.T_C_Branch_Number__c, BranchGroup__c, BranchGroup__r.Name, BranchGroup__r.Grouping_Type__c, BranchGroup__r.Share_with_Related_Branches__c, BranchGroup__r.Public_Group_Name__c FROM Branch_To_BranchGroup_Association__c WHERE BranchGroup__c IN: branchGroupIdSet AND BranchGroup__r.Share_with_Related_Branches__c = true]) {
            if(bGroupAndPublicGroupNameMap.containsKey(bbaObj.BranchGroup__c)) bGroupAndPublicGroupNameMap.get(bbaObj.BranchGroup__c).add(Constant.SERVICE_GROUP_PREFIX + ' ' + bbaObj.Branch__r.T_C_Branch_Number__c);
            else bGroupAndPublicGroupNameMap.put(bbaObj.BranchGroup__c, new List<String>{Constant.SERVICE_GROUP_PREFIX + ' ' + bbaObj.Branch__r.T_C_Branch_Number__c});    
            publicGroupNameSet.add(Constant.SERVICE_GROUP_PREFIX + ' ' + bbaObj.Branch__r.T_C_Branch_Number__c);                
        }
        System.debug('publicGroupNameSet:::'+publicGroupNameSet);
        
        for(Group groupObj : CaseTriggerHandlerModel.getPublicGroupsByName(publicGroupNameSet)) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }
        System.debug('groupMap:::'+groupMap);
        
        for(Case caseObj : sharingCaseRecords.values()) {
            if(branchAndPublicGroupNameMap.containsKey(caseObj.AssignedBranch__c)) {
                for(String publicGPName : branchAndPublicGroupNameMap.get(caseObj.AssignedBranch__c)) {
                    if(groupMap.containsKey(publicGPName))
                        shareRecordsToInsertList.add(createCaseShareRecord(caseObj.Id, groupMap.get(publicGPName)));
                }
            }
            if(branchAndBranchGroupMap.containsKey(caseObj.AssignedBranch__c)) {
                for(String branchGroup : branchAndBranchGroupMap.get(caseObj.AssignedBranch__c)) {
                    if(bGroupAndPublicGroupNameMap.containsKey(branchGroup)){
                        for(String publicGPName : bGroupAndPublicGroupNameMap.get(branchGroup)) {
                            if(groupMap.containsKey(publicGPName))
                                shareRecordsToInsertList.add(createCaseShareRecord(caseObj.Id, groupMap.get(publicGPName)));
                        }
                    }                
                }
            }
        }        
        if(!shareRecordsToInsertList.isEmpty()) insert shareRecordsToInsertList;
    }

    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 20 November 2023
*   Purpose         : This Method will be called on BeforeInsert and BeforeUpdare which Flaged the trigger if it's Corporate or not.
*   Input Param     : new Map, New List
*   Output Param    : void
*   User Story      : 
*/
    public static void CheckCaseCorporateOrBranch(List<Case> newList, Map<Id, Case> newMap) {
        
        Set<String> ownerIds = new Set<String>();
        for(Case caseObj : newList){
            ownerIds.add(caseObj.OwnerId);
        }
        
        List<Group> groupList = CaseTriggerHandlerModel.getQueue(ownerIds);
        List<String> queueList = new List<String>();
        
        for(QuickText_Corporate_Queue_List__mdt mcs : CaseTriggerHandlerModel.getCorporateQuoteMetadata()){
            queueList.add(mcs.MasterLabel);
        }
        
        Map<String,Group> groupMap = new  Map<String,Group>();
        for(Group gl : groupList){
            groupMap.put(gl.Id,gl);
        }
        
        /*System.debug('groupMap ===> '+ groupMap);
        System.debug('queueList ===> '+ queueList);
        System.debug('ownerIds ===> '+ ownerIds);*/
        
        for(Case caseObj : newList){
            if(groupMap.containskey(caseObj.OwnerId)){
                if(queueList.contains(groupMap.get(caseObj.OwnerId).Name)){
                    caseObj.Is_Corporate__c = true;
                }else{
                    caseObj.Is_Corporate__c = false;
                }
            }
        }
    }
    
    private static CaseShare createCaseShareRecord(Id caseId, Id groupId) {
        CaseShare jobShr        = new CaseShare();
        jobShr.CaseId           = caseId;
        jobShr.UserOrGroupId    = groupId;
        jobShr.CaseAccessLevel  = 'Edit';
        return jobShr;
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 09 December 2023
*   Purpose         : This Method will be called on AfterInsert and AfterUpdate For Creating case Record on Case Status Change For Cumulative time for each Status on the Case .
*	Ticket No		: [SCS-1381]Metrics Reports for Corp and Branches - Scheduled and On-Demand
*   Input Param     : List<Case> newList, Map<Id, Case> newMap
*   Output Param    : void
*   User Story      : 
*/
    
    public static void createUpdateCaseStatus(List<Case> newList, Map<Id, Case> oldObjectMap){
        
        List<Case_Status_Change__c> statusChanges = new List<Case_Status_Change__c>();
        Map<String,String> caseWiseOldStatus=new Map<String,String>();
        
        for (Case caseObject: newList) {
            if (oldObjectMap==null || (oldObjectMap!=null && caseObject.Status != oldObjectMap.get(caseObject.Id).Status)){
                
                Case_Status_Change__c statusChange = new Case_Status_Change__c();
                statusChange.Field_Value__c = caseObject.Status;
                statusChange.Start_Time__c = Datetime.now();
                statusChange.Field_Type__c = 'Status';
                statusChange.Name = caseObject.CaseNumber+' status: '+caseObject.Status;
                if(Trigger.isUpdate){
                    statusChange.Name = caseObject.CaseNumber+' from '+oldObjectMap.get(caseObject.Id).Status +' to '+caseObject.Status;
                    caseWiseOldStatus.put(caseObject.Id,oldObjectMap.get(caseObject.Id).Status);
                }
                statusChange.Case_Number__c = caseObject.Id;
                statusChanges.add(statusChange);
            }
        }
        if(statusChanges.size()==0) return;
        
        List<Case_Status_Change__c> caseStatusChangeList= [SELECT Id, Name, Case_Number__c,Field_Value__c, Field_Type__c,Start_Time__c,End_Time__c
                                     from Case_Status_Change__c
                                     WHERE Field_Value__c IN :caseWiseOldStatus.values() AND Case_Number__c IN :caseWiseOldStatus.keyset() AND End_Time__c = null And Field_Type__c = 'Status'];
        for(Case_Status_Change__c caseStatusChange : caseStatusChangeList){
            caseStatusChange.End_Time__c = Datetime.now();
        }
        
        Insert statusChanges;
        update caseStatusChangeList;
    }
    
    public static void createUpdateCaseOwner(List<Case> newList, Map<Id, Case> oldObjectMap){
        
        List<Case_Status_Change__c> ownerChanges = new List<Case_Status_Change__c>();
        Map<String,String> caseWiseOldStatus=new Map<String,String>();
        List<Id> listOwnerIds=new List<Id>();
        
        for (Case caseObject: newList) {
            if (oldObjectMap==null || (oldObjectMap!=null && caseObject.ownerId != oldObjectMap.get(caseObject.Id).ownerId)){
                listOwnerIds.add(caseObject.ownerId);
                if(oldObjectMap!=null){
                     listOwnerIds.add( oldObjectMap.get(caseObject.Id).ownerId);
                }
            }
        }
        
        if(listOwnerIds.size()==0) return;
        
        Map<String,String> idWiseName=new Map<String,String>();
        
        for(User user : [select id,name from user where id=:listOwnerIds]){
            idWiseName.put(user.Id,user.Name);
        }
        for(Group groupRec : [select id,name from Group where id=:listOwnerIds]){
            idWiseName.put(groupRec.Id,groupRec.Name);
        }
        for (Case caseObject: newList) {
            if (oldObjectMap==null || (oldObjectMap!=null && caseObject.ownerId != oldObjectMap.get(caseObject.Id).ownerId)){
                Case_Status_Change__c statusChange = new Case_Status_Change__c();
                statusChange.Field_Value__c = idWiseName.get(caseObject.OwnerId);
                statusChange.Start_Time__c = Datetime.now();
                statusChange.Field_Type__c = 'Owner';
                statusChange.Name = caseObject.CaseNumber+' Owner: '+idWiseName.get(caseObject.OwnerId);
                if(String.valueOf(caseObject.OwnerId).StartsWith('00G')){
                     statusChange.IS_Queue__c =true;
                }
                if(Trigger.isUpdate){
                    statusChange.Name = caseObject.CaseNumber+' from '+idWiseName.get(oldObjectMap.get(caseObject.Id).OwnerId) +' to '+idWiseName.get(caseObject.OwnerId);
                    caseWiseOldStatus.put(caseObject.Id,idWiseName.get(oldObjectMap.get(caseObject.Id).OwnerId));
                }
                statusChange.Case_Number__c = caseObject.Id;
                ownerChanges.add(statusChange);
            }
        }
        
        List<Case_Status_Change__c> caseOwnerChangeList= [SELECT Id, Name, Case_Number__c,Field_Value__c, Field_Type__c,Start_Time__c,End_Time__c
                                     from Case_Status_Change__c
                                     WHERE Field_Value__c IN :caseWiseOldStatus.values() AND Case_Number__c IN :caseWiseOldStatus.keyset() AND End_Time__c = null And Field_Type__c = 'Owner'];
        for(Case_Status_Change__c caseOwnerChange : caseOwnerChangeList){
            caseOwnerChange.End_Time__c = Datetime.now();
        }
        
        insert ownerChanges;
        update caseOwnerChangeList;
    }
    
    public static void updateCaseActionInfomation(List<Case> newCaseList,Map<Id, Case> oldObjectMap){
        
        for(Case caseRec:newCaseList)
        {
            if (oldObjectMap==null || (oldObjectMap!=null && caseRec.Status != oldObjectMap.get(caseRec.Id).Status)){
                caseRec.Last_Status_Update_Date_Time__c=DateTime.now();
            }
            if (oldObjectMap!=null && caseRec.First_Action_Updated__c == null){
                caseRec.First_Action_Updated__c=DateTime.now();
            }
        }
    }
    
    
    /*
*   Created By      : Lucas Soderstrom
*   Added on        : 22 April 2024
*   Purpose         : Checks for open Case Esclation records and returns an error the user if they are trying to close the Case.
*	Ticket No		: [SCS-1802] [SCS-1799] 
*/
    public static void checkForOpenEscalationsOnCaseClose(List<Case> newCaseList,Map<Id, Case> oldCaseMap){
        system.debug('in 11111');
        Set <Id> completedCaseIds = new Set <Id>(); 
        Set <Id> casesWithOpenEscalations = new Set <Id>(); 
        
        // logic below should onlyt execute if the user is closing the Case
        for(Case caseRec:newCaseList)
        {
            if(caseRec.Status == 'Completed' && caseRec.Status != oldCaseMap.get(caseRec.id).Status){
                completedCaseIds.add(caseRec.Id);
            }
        }
        
        if(completedCaseIds.size() > 0){ 
            system.debug('in 111112');
            
            // check if user is trying to close a Case with open Case Escalation records    
            for (Case completedCase : [Select Id, (Select id FROM Case_Escalations1__r WHERE Escalation_Status__c NOT IN ('Complete','Canceled'))
                                       FROM Case 
                                       WHERE Id in :completedCaseIds]){
                                           if(completedCase.Case_Escalations1__r.size() > 0){ 
                                               casesWithOpenEscalations.add(completedCase.Id);
                                           }   
                                       }
            
            if(casesWithOpenEscalations.size() > 0){ 
                system.debug('in 11113');
                
                // loop through new list to throw error on Cases with open Escalations
                for (Case caseRec : newCaseList){
                    if(casesWithOpenEscalations.contains(caseRec.Id)){
                        caseRec.addError('You cant close this Case');
                    }
                }
            }
        }
    }
}