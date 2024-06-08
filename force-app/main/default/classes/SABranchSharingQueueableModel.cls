public class SABranchSharingQueueableModel {
    
    public static List<ServiceAppointment> getSARelatedToCases(Set<Id> caseIdSet) {
        return [Select Id, FSSK__FSK_Work_Order__r.CaseId 
                from ServiceAppointment
                where FSSK__FSK_Work_Order__r.CaseId IN: caseIdSet AND RecordType.Name =: Constant.SA_CS_RT_NAME];
    }


    public static List<Case> getCaseDetails(Set<Id> caseIdSet) {
        return [Select Id, AssignedBranch__c 
               from Case where Id IN: caseIdSet];
    }


    public static List<Branch__c> getBranchRelatedToGroup(List<Id> branchGroupIdList) {
        return [Select Id, Name, Branch_Number__c, Branch_Family__c
                from Branch__c where Branch_Family__c IN: branchGroupIdList];           	
    }


    public static List<Branch__c> getBranchDetails(List<Id> branchIdList) {
        return [Select Id, Name, Branch_Number__c, Branch_Family__c
                from Branch__c where Id IN: branchIdList];           	
    }


    public static List<Group> getPublicGroupsByName (List<String> groupNameList) {
        return [Select Id, Name 
                from Group 
                where Type =: Constant.PUBLIC_GROUP_TYPE  AND Name IN: groupNameList];
    }


    public static List<ServiceAppointmentShare> getSAShareRecords(Set<Id> saIdSet) {
        return [Select Id, ParentId, UserOrGroupId
                from ServiceAppointmentShare 
                where ParentId IN: saIdSet];
    }
}