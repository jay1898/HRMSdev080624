/*
Created By      : Rahul Sangwan
Created Date    : 13 July 2023
Purpose         : This is a Utility class for reusable sharing methods of Customer Service. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class SharingUtility {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 13 July 2023
    *   Purpose         : To share the Case related objects with Groups related to Case Branch, and Branch Grouping related to Case Branch.
    */
    public static void createSharingRecords(Map<Id, Id> recordAndCaseMap, String shareObjectName) {
        /*
           Solution steps:
           1) Get Case Details based on recordAndCaseMap.
           2) Traverse Cases from Step 1:
                A) to prepare Map of Case and related Branch. 
                B) prepare Map of Case and related Branch Group. -- Remove this part
                C) Add values to Branch Name set, which will be used to query Public groups based on the Name.
           3) Get all Branch details based on the Map created in Step 2.B.
                A) Prepare Map of Branch Family as key and all related Branches as Values(This is created for Providing access to all Braches related to Branch Group.)
           4) Create Map of Public Group, keep Group Name as Key and Group Id as value.(Because in previous map, Step 2.A we will get Branch Name which will be same as Public Group Name).
           5) If Case has related Branch,Traverse recordAndCaseMap, get Case value, use this value to find the related Branch Family(Step 2.B), use Branch Family to find related Branches(Step 3.A).
                A) Traverse related Branches, find the Group Id based on Branch Name(Step 4) and create Sharing record accordingly.
           6) If case is not related to Brach Group, get Case Value, use this value to find related Branch(Step 2.A), use this Branch Name to find related group(Step 4), and create Sharing record accordingly.
        */
        Map<Id, Id> caseAndBranchMap                = new Map<Id, Id>();
        Map<Id, List<Id>> branchAndBranchGroupMap   = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchGroupAndBranchMap   = new Map<Id, List<Id>>();
        Map<Id, List<Id>> branchAndRelBranchesMap   = new Map<Id, List<Id>>();  
        Map<Id, String> branchMap                   = new Map<Id, String>();
        Map<String, String> groupMap                = new Map<String, String>();
        List<SObject> jobShrList                    = new List<SObject>();
        List<Case> caseList                         = new List<Case>();
        Set<String> branchNameSet                   = new Set<String>();
        Map<Id, List<String>> bFamilyAndBranchMap   = new Map<Id, List<String>>();

        caseList                                    =  getCaseDetails(recordAndCaseMap.values());
        
        for(Case caseObj : caseList) {
            System.debug('caseObj.AssignedBranch__c::::'+caseObj.AssignedBranch__c);
            if(caseObj.AssignedBranch__c != null) {
                branchMap.put(caseObj.AssignedBranch__c, Constant.SERVICE_GROUP_PREFIX + ' ' + caseObj.AssignedBranch__r.Branch_Number__c);
                caseAndBranchMap.put(caseObj.Id, caseObj.AssignedBranch__c);
                branchNameSet.add(Constant.SERVICE_GROUP_PREFIX + ' ' + caseObj.AssignedBranch__r.Branch_Number__c);
            }
        }

        for(Branch_To_BranchGroup_Association__c branchAssociationObj : getBranchGroupAssociations()) {
            branchMap.put(branchAssociationObj.Branch__c, Constant.SERVICE_GROUP_PREFIX + ' ' + branchAssociationObj.Branch__r.Branch_Number__c);
            if(branchAndBranchGroupMap.containsKey(branchAssociationObj.Branch__c)) branchAndBranchGroupMap.get(branchAssociationObj.Branch__c).add(branchAssociationObj.BranchGroup__c);
            if(!branchAndBranchGroupMap.containsKey(branchAssociationObj.Branch__c)) branchAndBranchGroupMap.put(branchAssociationObj.Branch__c, new List<Id> {branchAssociationObj.BranchGroup__c});
            if(branchGroupAndBranchMap.containsKey(branchAssociationObj.BranchGroup__c)) branchGroupAndBranchMap.get(branchAssociationObj.BranchGroup__c).add(branchAssociationObj.Branch__c);
            if(!branchGroupAndBranchMap.containsKey(branchAssociationObj.BranchGroup__c)) branchGroupAndBranchMap.put(branchAssociationObj.BranchGroup__c, new List<Id> {branchAssociationObj.Branch__c});
        }

        for(Id branchId : caseAndBranchMap.values()) {
            for(Id branchGroupId : branchAndBranchGroupMap.get(branchId)) {
                if(branchAndRelBranchesMap.containsKey(branchId)) branchAndRelBranchesMap.get(branchId).addAll(branchGroupAndBranchMap.get(branchGroupId));
                else branchAndRelBranchesMap.put(branchId, branchGroupAndBranchMap.get(branchGroupId));
            }
        }

        for(Group groupObj : getPublicGroupsByName(branchMap.values())) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }

        for(Id recordId : recordAndCaseMap.keySet()) {
            for(Id branchId : branchAndRelBranchesMap.get(caseAndBranchMap.get(recordAndCaseMap.get(recordId)))) {
                if(groupMap.containsKey(branchMap.get(branchId))) {
                    SObject jobShr = (SObject)(Type.forName('Schema.'+ shareObjectName).newInstance());  
                    jobShr.put('ParentId',recordId);
                    jobShr.put('UserOrGroupId', groupMap.get(branchMap.get(branchId)));
                    jobShr.put('AccessLevel','Edit');
                    jobShrList.add(jobShr);
                }
            }

            if(!branchAndRelBranchesMap.containsKey(recordId) && groupMap.containsKey(branchMap.get(caseAndBranchMap.get(recordAndCaseMap.get(recordId))))) {
                SObject jobShr = (SObject)(Type.forName('Schema.'+ shareObjectName).newInstance());  
                jobShr.put('ParentId',recordId);
                jobShr.put('UserOrGroupId', groupMap.get(branchMap.get(caseAndBranchMap.get(recordAndCaseMap.get(recordId)))));
                jobShr.put('AccessLevel','Edit');
                jobShrList.add(jobShr);
            }
        } 
        if(!jobShrList.isEmpty()) Database.insert(jobShrList, false);
    }
    
    
    public static void createSharingRecords_v2(Map<Id, Id> recordAndCaseMap, String shareObjectName) {
        List<Case> caseList                         			= new List<Case>();
        Set<Id> branchIdSet                                     = new Set<Id>();
        Set<Id> branchGroupIdSet                                = new Set<Id>();
        Map<Id, Id> caseAndBranchMap                            = new Map<Id, Id>();
        Map<String, List<String>> branchAndPublicGroupNameMap   = new Map<String, List<String>>();
        Map<String, List<String>> bGroupAndPublicGroupNameMap   = new Map<String, List<String>>();
        Map<String, List<String>> branchAndBranchGroupMap       = new Map<String, List<String>>();
        Set<Id> branchShareWithAssociationIdSet                 = new Set<Id>();
        List<String> publicGroupNameSet                         = new List<String>();
        Map<String, Id> groupMap                                = new Map<String, Id>();
        List<SObject> jobShrList                                = new List<SObject>();
        
        caseList                                                = getCaseDetails(recordAndCaseMap.values());
        
        for(Case caseObj : caseList) {
            caseAndBranchMap.put(caseObj.Id, caseObj.AssignedBranch__c);
            branchIdSet.add(caseObj.AssignedBranch__c);
        }
        
        for(Branch__c branchObj : [Select Id, Share_to_other_Branches_in_Group__c, T_C_Branch_Number__c from Branch__c where Id IN: branchIdSet]) {
            if(branchObj.Share_to_other_Branches_in_Group__c == false) {
                branchAndPublicGroupNameMap.put(branchObj.Id, new List<String>{Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.T_C_Branch_Number__c});
                publicGroupNameSet.add(Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.T_C_Branch_Number__c);
            } else {
                branchShareWithAssociationIdSet.add(branchObj.Id);
            }
        }
        
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
        
        for(Branch_To_BranchGroup_Association__c bbaObj : [SELECT Id, Branch__c, Branch__r.Name, Branch__r.T_C_Branch_Number__c, BranchGroup__c, BranchGroup__r.Name, BranchGroup__r.Grouping_Type__c, BranchGroup__r.Share_with_Related_Branches__c, BranchGroup__r.Public_Group_Name__c FROM Branch_To_BranchGroup_Association__c WHERE BranchGroup__c IN: branchGroupIdSet AND BranchGroup__r.Share_with_Related_Branches__c = true]) {
            if(bGroupAndPublicGroupNameMap.containsKey(bbaObj.BranchGroup__c)) bGroupAndPublicGroupNameMap.get(bbaObj.BranchGroup__c).add(Constant.SERVICE_GROUP_PREFIX + ' ' + bbaObj.Branch__r.T_C_Branch_Number__c);
            else bGroupAndPublicGroupNameMap.put(bbaObj.BranchGroup__c, new List<String>{Constant.SERVICE_GROUP_PREFIX + ' ' + bbaObj.Branch__r.T_C_Branch_Number__c});    
            publicGroupNameSet.add(Constant.SERVICE_GROUP_PREFIX + ' ' + bbaObj.Branch__r.T_C_Branch_Number__c);                
        }
        
        for(Group groupObj : CaseTriggerHandlerModel.getPublicGroupsByName(publicGroupNameSet)) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }
        
        for(Id recordId : recordAndCaseMap.keySet()) {
            if(branchAndPublicGroupNameMap.containsKey(caseAndBranchMap.get(recordAndCaseMap.get(recordId)))) {
                for(String publicGPName : branchAndPublicGroupNameMap.get(caseAndBranchMap.get(recordAndCaseMap.get(recordId)))) {
                    if(groupMap.containsKey(publicGPName)){
                        SObject jobShr = (SObject)(Type.forName('Schema.'+ shareObjectName).newInstance());  
                        jobShr.put('ParentId',recordId);
                        jobShr.put('UserOrGroupId', groupMap.get(publicGPName));
                        jobShr.put('AccessLevel','Edit');
                        jobShrList.add(jobShr);
                    }
                }
            }
            
            if(branchAndBranchGroupMap.containsKey(caseAndBranchMap.get(recordAndCaseMap.get(recordId)))) {
                for(String branchGroup : branchAndBranchGroupMap.get(caseAndBranchMap.get(recordAndCaseMap.get(recordId)))) {
                    if(bGroupAndPublicGroupNameMap.containsKey(branchGroup)){
                        for(String publicGPName : bGroupAndPublicGroupNameMap.get(branchGroup)) {
                            if(groupMap.containsKey(publicGPName)) {
                                SObject jobShr = (SObject)(Type.forName('Schema.'+ shareObjectName).newInstance());  
                                jobShr.put('ParentId',recordId);
                                jobShr.put('UserOrGroupId', groupMap.get(publicGPName));
                                jobShr.put('AccessLevel','Edit');
                                jobShrList.add(jobShr);
                            }
                        }
                    }
                }                
            }
        }
        if(!jobShrList.isEmpty()) Database.insert(jobShrList, false);        
    }


    private static List<Case> getCaseDetails(List<Id> caseIdList) {
        return [Select Id, AssignedBranch__c, AssignedBranch__r.Branch_Number__c, AssignedBranch__r.Name, AssignedBranch__r.Branch_Family__c 
                from Case
                where Id IN: caseIdList];
    }


    private static List<Group> getPublicGroupsByName (List<String> groupNameSet) {
        return [Select Id, Name from Group where Type =: Constant.PUBLIC_GROUP_TYPE AND Name IN: groupNameSet];
    }


    private static List<Branch_To_BranchGroup_Association__c> getBranchGroupAssociations() {
        return [Select Id, Branch__c, Branch__r.Branch_Number__c , Branch__r.Name , BranchGroup__c, Legacy_Id__c from Branch_To_BranchGroup_Association__c];
    }


    /*
    Map<Id, String> caseAndBranchMap            = new Map<Id, String>();
        Map<Id, String> caseAndBranchGroupMap       = new Map<Id, String>();
        Map<String, String> groupMap                = new Map<String, String>();
        List<SObject> jobShrList                    = new List<SObject>();
        List<Case> caseList                         = new List<Case>();
        Set<String> branchNameSet                   = new Set<String>();
        Map<Id, List<String>> bFamilyAndBranchMap   = new Map<Id, List<String>>();

        caseList                                    =  getCaseDetails(recordAndCaseMap.values());
        
        for(Case caseObj : caseList) {
            if(caseObj.AssignedBranch__c != null) {
                caseAndBranchMap.put(caseObj.Id, Constant.SERVICE_GROUP_PREFIX + ' ' + caseObj.AssignedBranch__r.Branch_Number__c + ' ' + caseObj.AssignedBranch__r.Name);
                branchNameSet.add(Constant.SERVICE_GROUP_PREFIX + ' ' + caseObj.AssignedBranch__r.Branch_Number__c + ' ' + caseObj.AssignedBranch__r.Name);
                if(caseObj.AssignedBranch__r.Branch_Family__c != null)
                caseAndBranchGroupMap.put(caseObj.Id, caseObj.AssignedBranch__r.Branch_Family__c);
            }
        }

        if(!caseAndBranchGroupMap.isEmpty()){
            for(Branch__c branchObj : [Select Id, Branch_Number__c, Name, Branch_Family__c from Branch__c where Branch_Family__c IN: caseAndBranchGroupMap.values()]) {
                branchNameSet.add(Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c + ' ' + branchObj.Name);
                if(bFamilyAndBranchMap.containsKey(branchObj.Branch_Family__c)) 
                    bFamilyAndBranchMap.get(branchObj.Branch_Family__c).add(Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c + ' ' + branchObj.Name);
                else 
                    bFamilyAndBranchMap.put(branchObj.Branch_Family__c, new List<String>{Constant.SERVICE_GROUP_PREFIX + ' ' + branchObj.Branch_Number__c + ' ' + branchObj.Name});
            }
        }

        for(Group groupObj : getPublicGroupsByName(branchNameSet)) {
            groupMap.put(groupObj.Name, groupObj.Id);
        }

        for(Id recordId : recordAndCaseMap.keySet()) {
            if(caseAndBranchGroupMap.containsKey(recordAndCaseMap.get(recordId)) && bFamilyAndBranchMap.containsKey(caseAndBranchGroupMap.get(recordAndCaseMap.get(recordId)))) {
                for(String branchName : bFamilyAndBranchMap.get(caseAndBranchGroupMap.get(recordAndCaseMap.get(recordId)))) {
                    if(groupMap.containsKey(branchName)) {
                        SObject jobShr = (SObject)(Type.forName('Schema.'+ shareObjectName).newInstance());  
                        jobShr.put('ParentId',recordId);
                        jobShr.put('UserOrGroupId', groupMap.get(branchName));
                        jobShr.put('AccessLevel','Edit');
                        jobShrList.add(jobShr);
                    }
                }
            }
            if(!caseAndBranchGroupMap.containsKey(recordAndCaseMap.get(recordId)) && caseAndBranchMap.containsKey(recordAndCaseMap.get(recordId)) && groupMap.containsKey(caseAndBranchMap.get(recordAndCaseMap.get(recordId)))) {
                SObject jobShr = (SObject)(Type.forName('Schema.'+ shareObjectName).newInstance());  
                jobShr.put('ParentId',recordId);
                jobShr.put('UserOrGroupId', groupMap.get(caseAndBranchMap.get(recordAndCaseMap.get(recordId))));
                jobShr.put('AccessLevel','Edit');
                jobShrList.add(jobShr);
            }
        }
        if(!jobShrList.isEmpty()) Database.insert(jobShrList, false);
    */
}