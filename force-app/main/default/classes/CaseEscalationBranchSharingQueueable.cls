public class CaseEscalationBranchSharingQueueable implements Queueable {

    Map<Id, Id> caseAndRelatedOldBranchMap;

    public CaseEscalationBranchSharingQueueable(Map<Id, Id> caseAndRelatedOldBranchMap) {
        this.caseAndRelatedOldBranchMap     = caseAndRelatedOldBranchMap;
    }


    public void execute(QueueableContext context) {
        /*
        Map<Id, List<Id>> caseAndRelatedCaseEscMap      = new Map<Id, List<Id>>();
        Set<Id> caseEscIdSet                            = new Set<Id>();
        List<Id> branchIdList                           = new List<Id>();
        Map<Id, String> branchMap                       = new Map<Id, String>();
        Map<String, Id> groupMap                        = new Map<String, Id>();
        Map<Id, List<Case_Escalation__share>> shareMap  = new Map<Id, List<Case_Escalation__share>>();
        List<Case_Escalation__share> shareDeleteList    = new List<Case_Escalation__share>();
        Map<Id, Id> ceAndCaseMap                        = new Map<Id, Id>();
        Map<Id, Id> branchAndGroupMap                   = new Map<Id, Id>();
        Map<Id, List<Id>> groupAndRelatedBranchMap      = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchAndBranchGroupMap       = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchGroupAndBranchMap       = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchAndRelBranchesMap       = new Map<Id, List<Id>>();

        branchIdList.addAll(caseAndRelatedOldBranchMap.values());

        for(Case caseObj : WorkOrderBranchSharingQueueableModel.getCaseDetails(caseAndRelatedOldBranchMap.keySet())) {
            branchIdList.add(caseObj.AssignedBranch__c);
        }

        for(Branch_To_BranchGroup_Association__c branchAssociationObj : WorkOrderBranchSharingQueueableModel.getBranchGroupAssociations()) {
            branchIdList.add(branchAssociationObj.Branch__c);
            if(branchAndBranchGroupMap.containsKey(branchAssociationObj.Branch__c)) branchAndBranchGroupMap.get(branchAssociationObj.Branch__c).add(branchAssociationObj.BranchGroup__c);
            if(!branchAndBranchGroupMap.containsKey(branchAssociationObj.Branch__c)) branchAndBranchGroupMap.put(branchAssociationObj.Branch__c, new List<Id> {branchAssociationObj.BranchGroup__c});
            if(branchGroupAndBranchMap.containsKey(branchAssociationObj.BranchGroup__c)) branchGroupAndBranchMap.get(branchAssociationObj.BranchGroup__c).add(branchAssociationObj.Branch__c);
            if(!branchGroupAndBranchMap.containsKey(branchAssociationObj.BranchGroup__c)) branchGroupAndBranchMap.put(branchAssociationObj.BranchGroup__c, new List<Id> {branchAssociationObj.Branch__c});
        }

        for(Id branchId : caseAndRelatedOldBranchMap.values()) {
            if(branchAndBranchGroupMap.containsKey(branchId)) {
                for(Id branchGroupId : branchAndBranchGroupMap.get(branchId)) {
                    if(branchAndRelBranchesMap.containsKey(branchId)) branchAndRelBranchesMap.get(branchId).addAll(branchGroupAndBranchMap.get(branchGroupId));
                    else branchAndRelBranchesMap.put(branchId, branchGroupAndBranchMap.get(branchGroupId));
                }
            }            
        }

        for(Branch__c branchObj : CaseEscalationBranchSharingQueueModel.getBranchDetails(branchIdList)) {
            branchMap.put(branchObj.Id, Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c);
        }

        for(Group groupObj : CaseEscalationBranchSharingQueueModel.getPublicGroupsByName(branchMap.values())) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }

        for(Case_Escalation__c ceObj : CaseEscalationBranchSharingQueueModel.getCaseEscRelatedToCases(caseAndRelatedOldBranchMap.keySet())) {
            ceAndCaseMap.put(ceObj.Id, ceObj.Case__c);
            if(caseAndRelatedCaseEscMap.containsKey(ceObj.Case__c)) caseAndRelatedCaseEscMap.get(ceObj.Case__c).add(ceObj.id);
            else caseAndRelatedCaseEscMap.put(ceObj.Case__c, new List<Id>{ceObj.Id});
            caseEscIdSet.add(ceObj.Id);
        }

        for(Case_Escalation__share ceShareObj : CaseEscalationBranchSharingQueueModel.getCEShareRecords(caseEscIdSet)) {
            if(shareMap.containsKey(ceShareObj.ParentId)) shareMap.get(ceShareObj.ParentId).add(ceShareObj);
            else shareMap.put(ceShareObj.ParentId, new List<Case_Escalation__share>{ceShareObj});
        }

        for(Id caseId : caseAndRelatedOldBranchMap.keySet()) {
            if(caseAndRelatedOldBranchMap.get(caseId) != null && branchMap.containsKey(caseAndRelatedOldBranchMap.get(caseId))) {
                Id groupId              = groupMap.containsKey(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) ? groupMap.get(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) : null;
                List<Id> groupIdList    = new List<Id>();
                
                if(branchAndRelBranchesMap.containsKey(caseAndRelatedOldBranchMap.get(caseId))) {
                    for(Id gpId : branchAndRelBranchesMap.get(caseAndRelatedOldBranchMap.get(caseId)))
                    groupIdList.add(groupMap.get(branchMap.get(gpId)));
                }
                for(Id ceId : caseAndRelatedCaseEscMap.get(caseId)) {
                    for(Case_Escalation__share shareObj : shareMap.get(ceId)) {
                        if(shareObj.UserOrGroupId == groupId || groupIdList.contains(shareObj.UserOrGroupId)) shareDeleteList.add(shareObj);
                    }
                }
            }            
        }
        if(!shareDeleteList.isEmpty()) try {
            delete shareDeleteList;
        }catch(Exception e) {
            
        }

        if(!Test.isRunningTest())
        System.enqueueJob(new CaseEscNewBranchSharingQueueable(ceAndCaseMap, caseAndRelatedOldBranchMap));
        */
    }
}