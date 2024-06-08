public class UserTriggerHandler {
    public static void addRemoveShareAORCampaingWithUser(List<String> listUserId,List<String> removelistUserId){
        CampaignRecordShare.addRemoveShareCampaingWithAORUser(listUserId,removelistUserId);
    }
   
    public static void addRemoveShareBranchWithAORUser(List<String> listUserId,List<String> removelistUserId){
        BranchRecordShare.addRemoveShareBranchWithAORUser(listUserId,removelistUserId);
    }
    public static void addRemoveShareOpportuniryWithAORUser(List<String> listUserId,List<String> removelistUserId){
        OpportunityRecordShare.addRemoveShareOpportuniryWithAORUser(listUserId,removelistUserId);
    }
    public static void validateUserExistAsLeadReceiver(List<User> lstNew,Map<Id,User> oldMap){
        List<Id> listUserIds=new List<Id>();
        for(User us : lstNew){
            if(us.isActive==false && us.isActive != oldMap.get(us.Id).isActive){
                listUserIds.add(us.Id);
            }    
        }
        if(listUserIds.size()==0)return;
        /*system.debug('@@listUserIds: '+listUserIds);
        List<User> listOfUserUnderManager=[SELECT Id,ManagerId, Reports_To__c FROM USER where ManagerId in :listUserIds];
        system.debug('@@listOfUserUnderManager: '+listOfUserUnderManager);
        for(User u: listOfUserUnderManager){
            u.ManagerId=null;
            u.Reports_To__c = null;
        }
        update listOfUserUnderManager;*/
        system.debug('@@'+[SELECT Id,ManagerId FROM USER where ManagerId in :listUserIds]);
        Map<Id,set<String>> userWiseBranchLeadReceiver=new Map<Id,set<String>>();
        for(Branch__C branch :  [SELECT Id,Name,Trade_Lead_Receiver__c,Commercial_Lead_Receiver__c,PCC_Lead_Receiver__c FROM Branch__C where Trade_Lead_Receiver__c=:listUserIds or  Commercial_Lead_Receiver__c=:listUserIds or PCC_Lead_Receiver__c=:listUserIds]){
            if(branch.Trade_Lead_Receiver__c!=null){
                if(!userWiseBranchLeadReceiver.containsKey(branch.Trade_Lead_Receiver__c))userWiseBranchLeadReceiver.put(branch.Trade_Lead_Receiver__c,new set<String>());
                userWiseBranchLeadReceiver.get(branch.Trade_Lead_Receiver__c).add(branch.Name);
            }
            if(branch.Commercial_Lead_Receiver__c!=null){
                if(!userWiseBranchLeadReceiver.containsKey(branch.Commercial_Lead_Receiver__c))userWiseBranchLeadReceiver.put(branch.Commercial_Lead_Receiver__c,new set<String>());
                userWiseBranchLeadReceiver.get(branch.Commercial_Lead_Receiver__c).add(branch.Name);
            }
            if(branch.PCC_Lead_Receiver__c!=null){
                if(!userWiseBranchLeadReceiver.containsKey(branch.PCC_Lead_Receiver__c))userWiseBranchLeadReceiver.put(branch.PCC_Lead_Receiver__c,new set<String>());
                userWiseBranchLeadReceiver.get(branch.PCC_Lead_Receiver__c).add(branch.Name);
            }
        }
        
        Map<Id,List<String>> userWiseTerritoryLeadReceiver=new Map<Id,List<String>>();
        for(ServiceTerritory ST : [select id,Name,Lead_Receiver__c from ServiceTerritory Where Lead_Receiver__c =:listUserIds and (RecordType.DeveloperName='NRT_Zone' or RecordType.DeveloperName='RT_Zone' ) ]){
            if(ST.Lead_Receiver__c!=null){
                if(!userWiseTerritoryLeadReceiver.containsKey(ST.Lead_Receiver__c))userWiseTerritoryLeadReceiver.put(ST.Lead_Receiver__c,new List<String>());
                userWiseTerritoryLeadReceiver.get(ST.Lead_Receiver__c).add(ST.Name);
            }
        }
        
        for(User us : lstNew){
            if(us.isActive==false && us.isActive != oldMap.get(us.Id).isActive){
                
                if(userWiseBranchLeadReceiver.containsKey(us.Id) && userWiseTerritoryLeadReceiver.containsKey(us.Id)){
                    us.addError('This User Currently Used as Lead Receiver In '+String.join(new List<String>(userWiseBranchLeadReceiver.get(us.Id)),',') +' Branch(s) And '+String.join(userWiseTerritoryLeadReceiver.get(us.Id),',') +' Territory(s)');
                }else if(userWiseBranchLeadReceiver.containsKey(us.Id)){
                    us.addError('This User Currently Used as Lead Receiver In '+String.join(new List<String>(userWiseBranchLeadReceiver.get(us.Id)),',') +' Branch(s)');
                }else if(userWiseTerritoryLeadReceiver.containsKey(us.Id)){
                    us.addError('This User Currently Used as Lead Receiver In '+String.join(userWiseTerritoryLeadReceiver.get(us.Id),',') +' Territory(s)');
                }
            }    
        }
    }
    //Method to update the EDW Last Modified 
    public static void updateEDWLastModified(List<User> lstNew,Map<Id,User> oldMap){
        //Query to fetch all related fileds of User from metadata
        List<EDW_Object_Mapping__mdt> lstobjUserMetadta =[select id,Field_Api_Name__c,Source_Object__c from EDW_Object_Mapping__mdt where Source_Object__c='User'];
        set<String> fieldSet = new Set<String>();
        //dynamically get the fields from the metadata and then use the same for comparison in the trigger. 
        for(EDW_Object_Mapping__mdt fields :lstobjUserMetadta){
            fieldSet.add(fields.Field_Api_Name__c);
        }
        for(User objUser: lstNew){
            
            for(string s: fieldSet){
                if(s.indexOf('.') > -1){
                    
                }
                else{
                    if(trigger.oldMap!=null){
                        if(objUser.get(s) != trigger.oldMap.get(objUser.Id).get(s)){
                            objUser.EDW_Last_Modified__c=Datetime.now();
                            break;
                        }
                    }
                    else{
                        if(objUser.get(s)!=null)
                            objUser.EDW_Last_Modified__c=Datetime.now();
                    }
                }
            }
            
            
        }
        
    }
    
    //Method to update the User Public Group
    public static void updateUserPublicGroup(List<User> lstNew,Map<Id,User> oldMap){
        //initializing the list of Group Member for Insertion and Deletion
        list<groupMember> groupList = new list<groupMember>();
        list<groupMember> groupListDel = new list<groupMember>();
        // Initializing the set of Ids for storing GroupId and UserOrGroupId
        Set<ID> setGroupId = new Set<Id>();
        Set<ID> setUserOrGroupId = new Set<Id>();
        String customLabelValue = Label.User_Profile_Name;
        //Query to get list of Group having developer name is Replacement_Sales_Management
        list<Group> grp = [select id,DeveloperName from Group where DeveloperName=: Label.Group_Developer];
        //Initializing the map to get the profile
        Map<Id, Profile> profileIdMap = new Map<Id, Profile>([SELECT Id, name from profile]);
        //Iterating the list of user
        for(User us : lstNew){
            //check to find user profile name should be Replacement Sales Management
            if(profileIdMap.get(us.profileid).name.equalsIgnoreCase(customLabelValue)){
                //Iterating the list of group
                for(group g : grp){
                    groupMember gp = new groupMember(groupId = g.Id);
                    gp.UserOrGroupId = us.Id;
                    groupList.add(gp);
                }
            }           
            //check to find user profile name should not be Replacement Sales Management
            else
            {
                //Iterating the list of group
                for(group g : grp){
                    setGroupId.add(g.id);
                    setUserOrGroupId.add(us.id);
                }
            }
        }
        //checking the size of list
        if(groupList.size() > 0){
            insert groupList; 
        }
        //checking the size of list
        if( setGroupId.size() > 0 && setUserOrGroupId.size() > 0 )
        {
            //Initializing the List to get the GroupMember
            List<GroupMember> ListGM  = [ Select Id from GroupMember where UserOrGroupID in :setUserOrGroupId and GroupId  in :setGroupId ];
            if(ListGM.size() > 0 )
            {
                delete ListGM;
            }
            
        }
    }
    //Method to populate Branch Name
    public static void populateBranchName(List<User> lstNew,Map<Id,User> oldMap){
        Map<Id,String> usrIdTobranchnumber = new Map<Id,String>();
        Map<String,String> branchnumTobranchname = new Map<String,String>();
        List<User> usersToUpdate = new List<User>();
        for(User us : lstNew){
            If(oldMap == NULL || us.Trade_Branch_Number__c != oldMap.get(us.Id).Trade_Branch_Number__c)
                usrIdTobranchnumber.put(us.ID, us.Trade_Branch_Number__c);      
        }
        for(Branch__c ba : [select T_C_Branch_Number__c,name from branch__C where T_C_Branch_Number__c IN :usrIdTobranchnumber.values()]) {
            branchnumTobranchname.put(ba.T_C_Branch_Number__c,ba.name);       
        }
        for(ID uniqid : usrIdTobranchnumber.keySet()){
            usersToUpdate.add(new User(Id= uniqid, Branch_Name_2__c =branchnumTobranchname.get(usrIdTobranchnumber.get(uniqid)))) ;   
        } 
        if(usersToUpdate.size() > 0)
            update usersToUpdate;
    }
    public static void CreateSharingForCommunityUser(List<String> listSharingUser){
        ShareSAWOPIESContForCommUserBatch b = new ShareSAWOPIESContForCommUserBatch(listSharingUser); 
        database.executebatch(b,1);
    }
    
    //**04-04-24

}