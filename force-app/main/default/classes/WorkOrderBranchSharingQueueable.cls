public class WorkOrderBranchSharingQueueable implements Queueable {
    
    Map<Id, Id> caseAndRelatedOldBranchMap;

    public WorkOrderBranchSharingQueueable(Map<Id, Id> caseAndRelatedOldBranchMap) {
        this.caseAndRelatedOldBranchMap     = caseAndRelatedOldBranchMap;
    }

    public void execute(QueueableContext context) {
        /*Map<Id, List<Id>> caseAndRelatedWorkOrderMap    = new Map<Id, List<Id>>();
        Set<Id> woIdSet                                 = new Set<Id>();
        List<Id> branchIdList                           = new List<Id>();
        Map<Id, String> branchMap                       = new Map<Id, String>();
        Map<String, Id> groupMap                        = new Map<String, Id>();
        Map<Id, List<WorkOrderShare>> shareMap          = new Map<Id, List<WorkOrderShare>>();
        List<WorkOrderShare> shareDeleteList            = new List<WorkOrderShare>(); */
        Map<Id, Id> woAndCaseMap                        = new Map<Id, Id>();
       /* Map<Id, List<Id>> branchAndBranchGroupMap       = new Map<Id, List<Id>>();
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

        for(Branch__c branchObj : WorkOrderBranchSharingQueueableModel.getBranchDetails(branchIdList)) {
            branchMap.put(branchObj.Id, Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c);
        }

        for(Group groupObj : WorkOrderBranchSharingQueueableModel.getPublicGroupsByName(branchMap.values())) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }
        */
        for(WorkOrder woObj : WorkOrderBranchSharingQueueableModel.getWorkOrderRelatedToCases(caseAndRelatedOldBranchMap.keySet())) {
            woAndCaseMap.put(woObj.Id, woObj.CaseId);
//            if(caseAndRelatedWorkOrderMap.containsKey(woObj.CaseId)) caseAndRelatedWorkOrderMap.get(woObj.CaseId).add(woObj.id);
//            else caseAndRelatedWorkOrderMap.put(woObj.CaseId, new List<Id>{woObj.Id});
//            woIdSet.add(woObj.Id);
        }
/*
        for(WorkOrderShare woShareObj : WorkOrderBranchSharingQueueableModel.getWOShareRecords(woIdSet)) {
            if(shareMap.containsKey(woShareObj.ParentId)) shareMap.get(woShareObj.ParentId).add(woShareObj);
            else shareMap.put(woShareObj.ParentId, new List<WorkOrderShare>{woShareObj});
        }

        for(Id caseId : caseAndRelatedOldBranchMap.keySet()) {
            if(caseAndRelatedOldBranchMap.get(caseId) != null && branchMap.containsKey(caseAndRelatedOldBranchMap.get(caseId))) {
                Id groupId              = groupMap.containsKey(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) ? groupMap.get(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) : null;
                List<Id> groupIdList    = new List<Id>();
                
                if(branchAndRelBranchesMap.containsKey(caseAndRelatedOldBranchMap.get(caseId))) {
                    for(Id gpId : branchAndRelBranchesMap.get(caseAndRelatedOldBranchMap.get(caseId)))
                    groupIdList.add(groupMap.get(branchMap.get(gpId)));
                }
                for(Id woId : caseAndRelatedWorkOrderMap.get(caseId)) {
                    for(WorkOrderShare shareObj : shareMap.get(woId)) {
                        if(shareObj.UserOrGroupId == groupId || groupIdList.contains(shareObj.UserOrGroupId)) shareDeleteList.add(shareObj);
                    }
                }
            }            
        }

        if(!shareDeleteList.isEmpty()) try {
            delete shareDeleteList;
        }catch(Exception e) {
            System.debug(e.getMessage());
        } */
        if(!Test.isRunningTest())
        System.enqueueJob(new WorkOrderNewBranchSharingQueueable(woAndCaseMap, caseAndRelatedOldBranchMap));
    }


    /*
Map<Id, List<Id>> caseAndRelatedWorkOrderMap    = new Map<Id, List<Id>>();
        Set<Id> woIdSet                                 = new Set<Id>();
        List<Id> branchIdList                           = new List<Id>();
        Map<Id, String> branchMap                       = new Map<Id, String>();
        Map<String, Id> groupMap                        = new Map<String, Id>();
        Map<Id, List<WorkOrderShare>> shareMap          = new Map<Id, List<WorkOrderShare>>();
        List<WorkOrderShare> shareDeleteList            = new List<WorkOrderShare>();
        Map<Id, Id> woAndCaseMap                        = new Map<Id, Id>();
        Map<Id, Id> branchAndGroupMap                   = new Map<Id, Id>();
        Map<Id, List<Id>> groupAndRelatedBranchMap      = new Map<Id, List<Id>>();

        branchIdList.addAll(caseAndRelatedOldBranchMap.values());

        for(Branch__c branchObj : WorkOrderBranchSharingQueueableModel.getBranchDetails(caseAndRelatedOldBranchMap.values())) {
            branchAndGroupMap.put(branchObj.Id, branchObj.Branch_Family__c);
        }

        for(Branch__c branchObj : WorkOrderBranchSharingQueueableModel.getBranchRelatedToGroup(branchAndGroupMap.values())) {
            branchIdList.add(branchObj.Id);
            if(groupAndRelatedBranchMap.containsKey(branchObj.Branch_Family__c))
                groupAndRelatedBranchMap.get(branchObj.Branch_Family__c).add(branchObj.Id);
            else 
                groupAndRelatedBranchMap.put(branchObj.Branch_Family__c, new List<Id>{branchObj.Id});
        }

        for(Case caseObj : WorkOrderBranchSharingQueueableModel.getCaseDetails(caseAndRelatedOldBranchMap.keySet())) {
            branchIdList.add(caseObj.AssignedBranch__c);
        }

        for(Branch__c branchObj : WorkOrderBranchSharingQueueableModel.getBranchDetails(branchIdList)) {
            branchMap.put(branchObj.Id, Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c + ' ' + branchObj.Name);
        }

        for(Group groupObj : WorkOrderBranchSharingQueueableModel.getPublicGroupsByName(branchMap.values())) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }
        
        for(WorkOrder woObj : WorkOrderBranchSharingQueueableModel.getWorkOrderRelatedToCases(caseAndRelatedOldBranchMap.keySet())) {
            woAndCaseMap.put(woObj.Id, woObj.CaseId);
            if(caseAndRelatedWorkOrderMap.containsKey(woObj.CaseId)) caseAndRelatedWorkOrderMap.get(woObj.CaseId).add(woObj.id);
            else caseAndRelatedWorkOrderMap.put(woObj.CaseId, new List<Id>{woObj.Id});
            woIdSet.add(woObj.Id);
        }

        for(WorkOrderShare woShareObj : WorkOrderBranchSharingQueueableModel.getWOShareRecords(woIdSet)) {
            if(shareMap.containsKey(woShareObj.ParentId)) shareMap.get(woShareObj.ParentId).add(woShareObj);
            else shareMap.put(woShareObj.ParentId, new List<WorkOrderShare>{woShareObj});
        }

        for(Id caseId : caseAndRelatedOldBranchMap.keySet()) {
            if(caseAndRelatedOldBranchMap.get(caseId) != null && branchMap.containsKey(caseAndRelatedOldBranchMap.get(caseId))) {
                Id groupId              = groupMap.containsKey(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) ? groupMap.get(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) : null;
                List<Id> groupIdList    = new List<Id>();
                
                if(branchAndGroupMap.containsKey(caseAndRelatedOldBranchMap.get(caseId)) && groupAndRelatedBranchMap.containsKey(branchAndGroupMap.get(caseAndRelatedOldBranchMap.get(caseId)))) {
                    for(Id gpId : groupAndRelatedBranchMap.get(branchAndGroupMap.get(caseAndRelatedOldBranchMap.get(caseId))))
                    groupIdList.add(groupMap.get(branchMap.get(gpId)));
                }
                for(Id woId : caseAndRelatedWorkOrderMap.get(caseId)) {
                    for(WorkOrderShare shareObj : shareMap.get(woId)) {
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
        System.enqueueJob(new WorkOrderNewBranchSharingQueueable(woAndCaseMap, caseAndRelatedOldBranchMap));
    */
}