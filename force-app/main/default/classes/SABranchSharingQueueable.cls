public class SABranchSharingQueueable implements Queueable{
    
    public Map<Id, Id> caseAndRelatedOldBranchMap;

    public SABranchSharingQueueable(Map<Id, Id> caseAndRelatedOldBranchMap) {
        this.caseAndRelatedOldBranchMap = caseAndRelatedOldBranchMap;
    }


    public void execute(QueueableContext context) {
        Map<Id, Id> saAndCaseMap                            = new Map<Id, Id>();
  /*      Map<Id, List<Id>> caseAndRelatedSAMap               = new Map<Id, List<Id>>();
        List<Id> branchIdList                               = new List<Id>();
        Set<Id> saIdSet                                     = new Set<Id>();
        Map<Id, String> branchMap                           = new Map<Id, String>();
        Map<String, Id> groupMap                            = new Map<String, Id>();
        
        Map<Id, List<ServiceAppointmentShare>> shareMap     = new Map<Id, List<ServiceAppointmentShare>>();
        List<ServiceAppointmentShare> shareDeleteList       = new List<ServiceAppointmentShare>();
        Map<Id, List<Id>> branchAndBranchGroupMap           = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchGroupAndBranchMap           = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchAndRelBranchesMap           = new Map<Id, List<Id>>();

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

        for(Branch__c branchObj : SABranchSharingQueueableModel.getBranchDetails(branchIdList)) {
            branchMap.put(branchObj.Id, Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c);
        }

        for(Group groupObj : SABranchSharingQueueableModel.getPublicGroupsByName(branchMap.values())) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }
*/
        for(ServiceAppointment saObj : SABranchSharingQueueableModel.getSARelatedToCases(caseAndRelatedOldBranchMap.keySet())) {
            saAndCaseMap.put(saObj.Id, saObj.FSSK__FSK_Work_Order__r.CaseId);
      //      if(caseAndRelatedSAMap.containsKey(saObj.FSSK__FSK_Work_Order__r.CaseId)) caseAndRelatedSAMap.get(saObj.FSSK__FSK_Work_Order__r.CaseId).add(saObj.id);
      //      else caseAndRelatedSAMap.put(saObj.FSSK__FSK_Work_Order__r.CaseId, new List<Id>{saObj.Id});
      //      saIdSet.add(saObj.Id);
        }
/*
        for(ServiceAppointmentShare saShareObj : SABranchSharingQueueableModel.getSAShareRecords(saIdSet)) {
            if(shareMap.containsKey(saShareObj.ParentId)) shareMap.get(saShareObj.ParentId).add(saShareObj);
            else shareMap.put(saShareObj.ParentId, new List<ServiceAppointmentShare>{saShareObj});
        }

        for(Id caseId : caseAndRelatedOldBranchMap.keySet()) {
            if(caseAndRelatedOldBranchMap.get(caseId) != null && branchMap.containsKey(caseAndRelatedOldBranchMap.get(caseId))) {
                Id groupId              = groupMap.containsKey(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) ? groupMap.get(branchMap.get(caseAndRelatedOldBranchMap.get(caseId))) : null;
                List<Id> groupIdList    = new List<Id>();

                if(branchAndRelBranchesMap.containsKey(caseAndRelatedOldBranchMap.get(caseId))) {
                    for(Id gpId : branchAndRelBranchesMap.get(caseAndRelatedOldBranchMap.get(caseId)))
                    groupIdList.add(groupMap.get(branchMap.get(gpId)));
                }
                if(caseAndRelatedSAMap.containsKey(caseId)) {
                    for(Id woId : caseAndRelatedSAMap.get(caseId)) {
                        for(ServiceAppointmentShare shareObj : shareMap.get(woId)) {
                            if(shareObj.UserOrGroupId == groupId || groupIdList.contains(shareObj.UserOrGroupId)) shareDeleteList.add(shareObj);
                        }
                    }
                }                
            }            
        }

        if(!shareDeleteList.isEmpty()) try {
            delete shareDeleteList;
        }catch(Exception e) {
            
        }
*/
        if(!Test.isRunningTest())
        System.enqueueJob(new SANewBranchSharingQueueable(saAndCaseMap, caseAndRelatedOldBranchMap));
    }


}