public class CaseEscalationBranchSharingQueueModel {

    public static List<Branch__c> getBranchDetails(List<Id> branchIdList) {
        return [Select Id, Name, Branch_Number__c, Branch_Family__c
                from Branch__c where Id IN: branchIdList];           	
    }


    public static List<Branch__c> getBranchRelatedToGroup(List<Id> branchGroupIdList) {
        return [Select Id, Name, Branch_Number__c, Branch_Family__c
                from Branch__c where Branch_Family__c IN: branchGroupIdList];           	
    }


    public static List<Case_Escalation__c> getCaseEscRelatedToCases(Set<Id> caseIdSet) {
        return [Select Id, Case__c from Case_Escalation__c
                where Case__c IN: caseIdSet];
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

    /*
    public static List<Case_Escalation__share> getCEShareRecords(Set<Id> ceIdSet) {
        return [Select Id, ParentId, UserOrGroupId
                from Case_Escalation__share 
                where ParentId IN: ceIdSet];
    } */
}