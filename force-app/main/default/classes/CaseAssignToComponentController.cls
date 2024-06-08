public class CaseAssignToComponentController {

    @AuraEnabled(cacheable=true)
    public static List<GroupWrapper> searchQueueandQueueMembers(String searchKey, String caseId){
        

        Set<String> userIdList = new Set<String>();
        Set<Group> groupList = new Set<Group>();

        String query;
        String queueMemberQuery;
        
        if(String.isBlank(searchKey)) {
            
            Case caseRec = [Select Id, AssignedBranch__c, AssignedBranch__r.Name from Case WHERE Id =: caseId AND AssignedBranch__c != null];
            String assignBranchName = caseRec.AssignedBranch__r.Name;
            query = 'SELECT Id, Name, Type, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Type = \'Queue\' AND (Name =: assignBranchName OR Name = \'Corporate\')';
        } else {
            
            query = 'SELECT Id, Name, Type, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Type = \'Queue\'';
        }
        System.debug('query '+query);

        for(Group grop : Database.Query(query)) {
            for(GroupMember grpMem : grop.GroupMembers){
                userIdList.add(grpMem.UserOrGroupId);
            }
            groupList.add(grop);
        }

        System.debug('userIdList '+JSON.serialize(userIdList));
        Map<Id, User> userNameMap = new Map<Id, User>([Select Id, Title, UserName, Name  from User Where Id =:userIdList]);
        List<GroupWrapper> GroupWrapperList = new List<GroupWrapper>();
        for(Group grop : groupList) {
            GroupWrapper wrap = new GroupWrapper();
            wrap.Id = grop.Id;
            wrap.Name = grop.Name;
            wrap.Type = grop.Type;
            Boolean isGroupMember = false;
            List<GroupMemberWrapper> grpMemList = new List<GroupMemberWrapper>();
            for(GroupMember grpMem : grop.GroupMembers){

                if(userNameMap.containskey(grpMem.UserOrGroupId) && String.isBlank(searchKey)) { //&& String.isBlank(searchKey)
                    GroupMemberWrapper grpWrap = new GroupMemberWrapper();
                    grpWrap.Id = grpMem.Id;
                    grpWrap.UserId = grpMem.UserOrGroupId;
                    grpWrap.Name = userNameMap.get(grpMem.UserOrGroupId).Name+' - '+userNameMap.get(grpMem.UserOrGroupId).Title;
                    grpMemList.add(grpWrap);

                }

                if(String.isNotBlank(searchKey) && grop.Name.containsIgnoreCase(searchKey) && userNameMap.containskey(grpMem.UserOrGroupId)) {
                    GroupMemberWrapper grpWrap = new GroupMemberWrapper();
                    grpWrap.Id = grpMem.Id;
                    grpWrap.UserId = grpMem.UserOrGroupId;
                    grpWrap.Name = userNameMap.get(grpMem.UserOrGroupId).Name+' - '+userNameMap.get(grpMem.UserOrGroupId).Title;
                    grpMemList.add(grpWrap);
                } else if (String.isNotBlank(searchKey) && userNameMap.containskey(grpMem.UserOrGroupId) && userNameMap.get(grpMem.UserOrGroupId).Name.containsIgnoreCase(searchKey)) {
                    GroupMemberWrapper grpWrap = new GroupMemberWrapper();
                    grpWrap.Id = grpMem.Id;
                    grpWrap.UserId = grpMem.UserOrGroupId;
                    grpWrap.Name = userNameMap.get(grpMem.UserOrGroupId).Name+' - '+userNameMap.get(grpMem.UserOrGroupId).Title;
                    grpMemList.add(grpWrap);
                    isGroupMember = true;
                }
            }

            if(String.isNotBlank(searchKey) && (grop.Name.containsIgnoreCase(searchKey) || isGroupMember)) {
                wrap.groupMembers = grpMemList;
                wrap.isChild = grpMemList.size() > 0 ? true : false;
                wrap.isExpand = false;
                GroupWrapperList.add(wrap);
            } else if(String.isBlank(searchKey)){
                wrap.groupMembers = grpMemList;
                wrap.isChild = grpMemList.size() > 0 ? true : false;
                wrap.isExpand = false;
                GroupWrapperList.add(wrap);
            }
        }
        return GroupWrapperList;
    }

    public class GroupWrapper {

        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Type;
        @AuraEnabled public Boolean isChild;
        @AuraEnabled public Boolean isExpand;
        @AuraEnabled public List<GroupMemberWrapper> groupMembers;
    }

    public class GroupMemberWrapper {

        @AuraEnabled public String Id;
        @AuraEnabled public String UserId;
        @AuraEnabled public String Name;
    }



    @AuraEnabled
    public static List<BranchWrapper> getAssignHierarchy(){
        Map<String, Map<String, List<String>>> hierarchyMap = new Map<String, Map<String, List<String>>>();
        Map<String, GroupMember> recordAndDetailMap         = new Map<String, GroupMember>();
        List<BranchWrapper> respWrapper                     = new List<BranchWrapper>();
        try {
            List<GroupMember> groupMemberList   = [Select UserOrGroup.Branch_Name_2__c, GroupId, Group.Name, UserOrGroup.Name, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND UserOrGroup.Branch_Name_2__c != null ORDER BY UserOrGroup.Branch_Name_2__c];
            for(GroupMember gpMemberObj : groupMemberList) {
                recordAndDetailMap.put(gpMemberObj.UserOrGroupId, gpMemberObj);
                recordAndDetailMap.put(gpMemberObj.GroupId, gpMemberObj);
                if(hierarchyMap.containsKey(gpMemberObj.UserOrGroup.Branch_Name_2__c)) {
                    if(hierarchyMap.get(gpMemberObj.UserOrGroup.Branch_Name_2__c).containsKey(gpMemberObj.GroupId)) {
                        hierarchyMap.get(gpMemberObj.UserOrGroup.Branch_Name_2__c).get(gpMemberObj.GroupId).add(gpMemberObj.UserOrGroupId);

                    } else {
                        hierarchyMap.get(gpMemberObj.UserOrGroup.Branch_Name_2__c).put(gpMemberObj.GroupId, new List<String>{gpMemberObj.UserOrGroupId});
                    }
                } else {
                    hierarchyMap.put(gpMemberObj.UserOrGroup.Branch_Name_2__c, new Map<String,List<String>>{gpMemberObj.GroupId => new List<String>{gpMemberObj.UserOrGroupId}});
                }
            }

            for(String key : hierarchyMap.keySet()) {
                BranchWrapper newBranch     = new BranchWrapper(key, true, key, true);
                List<QueueWrapper> queueWrapperList = new List<QueueWrapper>();
                for(String queue : hierarchyMap.get(key).keySet()) {
                    QueueWrapper newQueue = new QueueWrapper(recordAndDetailMap.get(queue).Group.Name, true, queue, true);
                    List<UserWrapper> userWrapperList = new List<UserWrapper>();
                    for(String userObj :  hierarchyMap.get(key).get(queue)) {
                        UserWrapper newUser = new UserWrapper(recordAndDetailMap.get(userObj).UserOrGroup.Name, true, userObj);
                        userWrapperList.add(newUser);
                    }
                    newQueue.userWrapperList = userWrapperList;
                    queueWrapperList.add(newQueue);
                }
                newBranch.queueWrapperList = queueWrapperList;
                respWrapper.add(newBranch);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        System.debug('respWrapper::::'+respWrapper);
        return respWrapper;
    }


    public class UserWrapper {
        @AuraEnabled 
        public String name;
        @AuraEnabled 
        public Boolean isVisible;
        @AuraEnabled 
        public String recordId;

        public UserWrapper (String name, Boolean isVisible, String recordId) {
            this.name = name;
            this.isVisible = isVisible;
            this.recordId = recordId;
        }
    }


    public class QueueWrapper {
        @AuraEnabled 
        public String name{get; set;}
        @AuraEnabled 
        public Boolean expand{get; set;}
        @AuraEnabled 
        public String recordId{get; set;}
        @AuraEnabled 
        public Boolean isVisible{get; set;}
        @AuraEnabled 
        public List<UserWrapper> userWrapperList{get; set;}

        public QueueWrapper (String name, Boolean isVisible, String recordId, Boolean expand) {
            this.name = name; 
            this.isVisible = isVisible;
            this.recordId = recordId;
            this.expand = expand;
        }
    }

    public class BranchWrapper {
        @AuraEnabled 
        public String name{get; set;}
        @AuraEnabled 
        public Boolean expand{get; set;}
        @AuraEnabled 
        public String recordId{get; set;}
        @AuraEnabled 
        public Boolean isVisible{get; set;}
        @AuraEnabled 
        public List<QueueWrapper> queueWrapperList{get; set;}

        public BranchWrapper (String name, Boolean isVisible, String recordId, Boolean expand) {
            this.name = name;
            this.isVisible = isVisible;
            this.recordId = recordId;
            this.expand = expand;
        }
    }
}