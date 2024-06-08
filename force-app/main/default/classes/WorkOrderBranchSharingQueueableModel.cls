public class WorkOrderBranchSharingQueueableModel {
    
    public static List<Branch__c> getBranchDetails(List<Id> branchIdList) {
        return [Select Id, Name, Branch_Number__c, Branch_Family__c
                from Branch__c where Id IN: branchIdList];           	
    }


    public static List<Branch__c> getBranchRelatedToGroup(List<Id> branchGroupIdList) {
        return [Select Id, Name, Branch_Number__c, Branch_Family__c
                from Branch__c where Branch_Family__c IN: branchGroupIdList];           	
    }


    public static List<WorkOrder> getWorkOrderRelatedToCases(Set<Id> caseIdSet) {
        return [Select Id, CaseId from WorkOrder
                where CaseId IN: caseIdSet AND RecordType.Name =: Constant.WO_CS_RT];
    }


    public static List<Case> getCaseDetails(Set<Id> caseIdSet) {
        return [Select Id, AssignedBranch__c, AssignedBranch__r.Branch_Family__c 
               from Case where Id IN: caseIdSet];
    }


    public static List<Group> getPublicGroupsByName (List<String> groupNameList) {
        return [Select Id, Name 
                from Group 
                where Type =: Constant.PUBLIC_GROUP_TYPE  AND Name IN: groupNameList];
    }


    public static List<WorkOrderShare> getWOShareRecords(Set<Id> woIdSet) {
        return [Select Id, ParentId, UserOrGroupId
                from WorkOrderShare 
                where ParentId IN: woIdSet];
    }


    public static List<Branch_To_BranchGroup_Association__c> getBranchGroupAssociations() {
        return [Select Id, Branch__c, Branch__r.Branch_Number__c , Branch__r.Name , BranchGroup__c, Legacy_Id__c 
                from Branch_To_BranchGroup_Association__c];
    }
}