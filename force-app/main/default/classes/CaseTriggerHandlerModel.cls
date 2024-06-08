/*
Created By      : Rahul Sangwan
Created Date    : 8 May 2023
Purpose         : This is a Model Class for CaseTriggerHandler. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseTriggerHandlerModel {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 8 May 2023
    *   Purpose         : To get Account details related to Case.
    *   Input Param     : Set of Id's
    *   Output Param    : Map of Account Id as Key and Account Object as Value.
    */
    public static Map<Id, Contact> getContactDetailsRelatedToCase (Set<Id> contactIdSet) {
        return new Map<Id, Contact>([Select Id, MailingPostalCode from Contact where Id In: contactIdSet]);
    }


 /*   public static List<Zip_Code_Branch__c> getZipDetails(Set<String> zipCodeSet) {
        return [Select Id, Name, Branch__c, Branch__r.Name from Zip_Code_Branch__c where Name IN: zipCodeSet];
    }
*/

    public static List<ServiceTerritory> getTerritoryDetails(Set<String> zipCodeSet) {
        return [Select Id, Name, Branch__c, Branch_Hidden__c, Branch__r.Name from ServiceTerritory where Name IN: zipCodeSet];
    }
    
	/*
    *   Created By      : Subhash Panchani
    *   Added on        : 24 May 2023
    *   Purpose         : To get Details related to Case
    *   Input Param     : List of Case
    *   Output Param    : 
    *   User Story      : SCS-30 Case - Merge Cases
    */
    
    public static Map<Id, Case> getMasterCaseMap(Set<String> masterCaseIds){
        return new Map<Id, Case>([SELECT Id, Customer_Number__c, Status, AssignedBranch__c FROM Case WHERE Id IN :masterCaseIds]);
    }


    public static Map<Id, Group> getQueueDetails(Set<Id> queueIdSet) {
        return new Map<Id, Group>([select Id, Name from Group where Type = 'Queue' AND Id IN: queueIdSet]);
    }
    
    public static List<Contact> getContactDetails(Set<Id> contactIdSet) {
        return [SELECT Id,Contact_Notes__c FROM Contact Where Id=:contactIdSet];
    }
    
    public static List<Contact> getCaseContactDetails(List<String> contactIdSet) {
        return [SELECT Id,Email,IsEmailBounced FROM Contact Where Id=:contactIdSet and IsEmailBounced = true];
    }

    public static List<Account> getAccountDetails(Set<String> accountNameSet) {
        return [Select Id, Name from Account where Name IN: accountNameSet];
    }


    public static List<Branch__c> getBranchDetailsBasedOnName(List<String> branchNameList) {
        return [Select Id, Name from Branch__c where Name IN: branchNameList];
    }

    public static List<Contact> getContactBasedOnSuppliedEmail(List<String> emailIdList) {
        return [Select Id, Email from Contact where Email IN: emailIdList ORDER BY CreatedDate ASC];
    }
    
    public static List<Group> getGroups() {
        return [SELECT Id FROM Group WHERE Name = :Constant.GROUP_NAME_CX_COMMUNICATION LIMIT 1];
    }
        
    public static List<GroupMember> getGroupMembers() {
        return [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = :Constant.GROUP_NAME_CX_COMMUNICATION];
    }
            
    public static Id getCompletedEmailTemplateId() {
        return [SELECT Id FROM EmailTemplate WHERE Name = :Constant.CASE_COMPLETED_EMAIL_TEMPLATE_NAME].Id;
    }
    
    public static Id getCancelledEmailTemplateId() {
        return [SELECT Id FROM EmailTemplate WHERE Name = :Constant.CASE_CANCELLED_EMAIL_TEMPLATE_NAME].Id;
    }
    
    public static List<OrgWideEmailAddress> getOrgWideEmailAddress() {
        return [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = :Constant.ORGWIDE_EMAIL_WHERE_NAME_IS_PELLA_SUPPORT];
    }


    public static List<Branch_To_BranchGroup_Association__c> getBranchGroupAssociations() {
        return [Select Id, Branch__c, Branch__r.Branch_Number__c , Branch__r.Name , BranchGroup__c, Legacy_Id__c 
                from Branch_To_BranchGroup_Association__c];
    }


    public static List<Branch__c> getBranchDetails(Set<Id> branchIdList) {
        return [Select Id, Name, Branch_Number__c, Branch_Family__c
                from Branch__c where Id IN: branchIdList];           	
    }


    public static List<Group> getPublicGroupsByName (List<String> groupNameList) {
        return [Select Id, Name 
                from Group 
                where Type =: Constant.PUBLIC_GROUP_TYPE  AND Name IN: groupNameList];
    }


    public static List<CaseShare> getCaseShareRecords(Set<Id> caseIdSet) {
        return [Select Id, CaseId, UserOrGroupId
                from CaseShare 
                where CaseId IN: caseIdSet];
    }
    
    /*
    *   Created By      : Subhash Panchani
    *   Added on        : 20 November 2023
    *   Purpose         : To get Group details.
    *   Input Param     : Set of Queue Name
    *   Output Param    : List of Group Sobject.
    */
 	public static List<Group> getQueue (Set<String> queueList) {
        return new List<Group>([select Id,Name,DeveloperName from Group where Type = 'queue' and Id In : queueList]);
    }
    
    public static List<QuickText_Corporate_Queue_List__mdt> getCorporateQuoteMetadata() {
        return new List<QuickText_Corporate_Queue_List__mdt>([SELECT MasterLabel FROM QuickText_Corporate_Queue_List__mdt]);
    }
}