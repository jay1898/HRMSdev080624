public without sharing class CampaignRecordShare {
   /* public static void shareCampaignRecordWithSTMOld(List<Campaign> listCampaigns){
        List<Id> listAORBranchIds=new List<Id>();
        List<Id> listBranchIds=new List<Id>();
        for(Campaign cmp : listCampaigns){
            if(cmp.Branch_Name__c!=null){
                listBranchIds.add(cmp.Branch_Name__c);
                if(cmp.Branch_AOR__c!=null){
                     listAORBranchIds.add(cmp.Branch_AOR__c); 
                }
            }
            if(cmp.AOR__c!=null){
                listAORBranchIds.add(cmp.AOR__c);
            }
        }
        
        // Get List Of all the branches related to campaign
        List<Branch__c> listBranch=[SELECT ID,Name,Branch_Number__c,AOR__c From Branch__c where id in :listBranchIds Or  AOR__c in :listAORBranchIds ];
        
        List<String> listBranchNumber=new List<String>();
        Map<Id,Set<String>> AORWiseBranchNumbers=new Map<Id,Set<String>>();
        Map<Id,branch__c> branchIdWiseBranch=new Map<Id,branch__c>();
        
        for(Branch__c branch:listBranch){
            
            listBranchNumber.add(branch.Branch_Number__c);
            branchIdWiseBranch.put(branch.Id,branch);
            if(branch.AOR__c!=null){
                if(!AORWiseBranchNumbers.containsKey(branch.AOR__c)){
                    AORWiseBranchNumbers.put(branch.AOR__c,new set<String>());
                }
                AORWiseBranchNumbers.get(branch.AOR__c).add(branch.Branch_Number__c);
            }
        }
        
        List<UserTerritory2Association> listUTA=[SELECT Id, UserId, Territory2Id,Territory2.Territory_Reference_Number__c FROM UserTerritory2Association where (Territory2.Territory_Type_Name__c='Branch' and  Territory2.Territory_Reference_Number__c in :listBranchNumber)];
        
        // Branch Number wise User sharing from ETM
        Map<String,set<Id>> mapBranchWiseUsers=new Map<String,set<Id>>();
        for(UserTerritory2Association UTA : listUTA){
            if(!mapBranchWiseUsers.containsKey(UTA.Territory2.Territory_Reference_Number__c)){
                mapBranchWiseUsers.put(UTA.Territory2.Territory_Reference_Number__c,new set<Id>());
            }
            mapBranchWiseUsers.get(UTA.Territory2.Territory_Reference_Number__c).add(UTA.UserId);
        }
        
        List<Branch_Grouping__c> BranchGroupList=[SELECT ID,NAME FROM Branch_Grouping__c where Id in :listAORBranchIds ];
        set<String> setAORBranch=new set<String>();
        Map<Id,String> idWiseName=new Map<Id,String>();
        for(Branch_Grouping__c BG : BranchGroupList){
            setAORBranch.add(BG.Name);
            idWiseName.put(BG.Id,BG.Name);
        } 
        
        // get List Of AOR User
        List<User> listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c in :setAORBranch];
        
        // AOR Wise User List for share with all the related AOR
        Map<String,set<Id>> AORWiseUserlist=new Map<String,set<Id>>();
        for(User u:listAORUser){
            if(!AORWiseUserlist.containsKey(u.AOR__c)){
                AORWiseUserlist.put(u.AOR__c,new set<Id>());
            }
            AORWiseUserlist.get(u.AOR__c).add(u.Id);
        }
     
        Map<Id,set<ID>> CampWiseUsersIdsToShare=new Map<Id,set<ID>>();
        
        List<CampaignShare> listCampShare=new list<CampaignShare>();
        for(Campaign cmp : listCampaigns){
            Id AORId;
            // Branch Number wise User sharing
            if(cmp.Branch_Name__c!=null){
                if(branchIdWiseBranch.containsKey(cmp.Branch_Name__c)){
                    if(!CampWiseUsersIdsToShare.containsKey(cmp.Id)){
                        CampWiseUsersIdsToShare.put(cmp.Id,new set<Id>());
                    }
                    if(mapBranchWiseUsers.containsKey(branchIdWiseBranch.get(cmp.Branch_Name__c).Branch_Number__c)){
                        CampWiseUsersIdsToShare.get(cmp.Id).addAll(mapBranchWiseUsers.get(branchIdWiseBranch.get(cmp.Branch_Name__c).Branch_Number__c));
                    }
                    
                    if(cmp.AOR__c==null){
                        AORId=branchIdWiseBranch.get(cmp.Branch_Name__c).AOR__c;
                    }
                }
            }
            if(cmp.AOR__c!=null){
                AORId=cmp.AOR__c;
            }
            // AOR wise User Sharing
            if(AORId!=null){
                if(idWiseName.containsKey(AORId)){
                    if(!CampWiseUsersIdsToShare.containsKey(cmp.Id)){
                        CampWiseUsersIdsToShare.put(cmp.Id,new set<Id>());
                    }
                    if(AORWiseUserlist.containsKey(idWiseName.get(AORId))){
                        CampWiseUsersIdsToShare.get(cmp.Id).addAll(AORWiseUserlist.get(idWiseName.get(AORId)));
                    }
                }
                
                // IF AOR EXIST and BRANCH not selected than share with all the branches
                if(cmp.Branch_Name__c==null && AORWiseBranchNumbers.containsKey(AORId)){
                    for(String branchNumber : AORWiseBranchNumbers.get(AORId)){
                        if(mapBranchWiseUsers.containsKey(branchNumber)){
                            CampWiseUsersIdsToShare.get(cmp.Id).addAll(mapBranchWiseUsers.get(branchNumber));
                        }
                    }
                }
            }
            
            if(CampWiseUsersIdsToShare.get(cmp.Id)!=null && CampWiseUsersIdsToShare.get(cmp.Id).size()>0){
                for(Id userId : CampWiseUsersIdsToShare.get(cmp.Id)){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = cmp.Id; 
                    campShare.UserOrGroupId = userId; 
                    campShare.CampaignAccessLevel  = 'Edit';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
            }
        } 
         Database.SaveResult[] srList = Database.insert(listCampShare, false);

        //insert listCampShare;
    }*/
    
    public static void shareCampaignRecordWithSTM(List<Campaign> listCampaigns){
        List<Id> listAORBranchIds=new List<Id>();
        List<Id> listBranchIds=new List<Id>();
        List<Id> listTCBranchIds=new List<Id>();
        for(Campaign cmp : listCampaigns){
            if(cmp.Business_Segment__c=='Trade' ||cmp.Business_Segment__c=='Commercial' ){
                if(cmp.Type=='Branch'){
                    if(cmp.Branch_Name__c!=null){
                        listTCBranchIds.add(cmp.Branch_Name__c);
                    }
                }
            }else{
                if(cmp.Branch_Name__c!=null){
                    listBranchIds.add(cmp.Branch_Name__c);
                    if(cmp.Branch_AOR__c!=null){
                        listAORBranchIds.add(cmp.Branch_AOR__c); 
                    }
                }
                if(cmp.AOR__c!=null){
                    listAORBranchIds.add(cmp.AOR__c);
                }
            }
        }
        
        // Get List Of all the branches related to campaign
        List<Branch__c> listBranch=[SELECT ID,Name,Branch_Number__c,T_C_Branch_Number__c,AOR__c From Branch__c where id in :listBranchIds Or  AOR__c in :listAORBranchIds Or id in :listTCBranchIds ];
        
        List<String> listBranchNumber=new List<String>();
        List<String> listTCBranchNumber=new List<String>();
        Map<Id,Set<String>> AORWiseBranchNumbers=new Map<Id,Set<String>>();
        Map<Id,branch__c> branchIdWiseBranch=new Map<Id,branch__c>();
        
        for(Branch__c branch:listBranch){
            
            if(listTCBranchIds.contains(branch.Id)){
                listTCBranchNumber.add(branch.T_C_Branch_Number__c);
                branchIdWiseBranch.put(branch.Id,branch);
            }else{
                listBranchNumber.add(branch.Branch_Number__c);
                branchIdWiseBranch.put(branch.Id,branch);
                if(branch.AOR__c!=null){
                    if(!AORWiseBranchNumbers.containsKey(branch.AOR__c)){
                        AORWiseBranchNumbers.put(branch.AOR__c,new set<String>());
                    }
                    AORWiseBranchNumbers.get(branch.AOR__c).add(branch.Branch_Number__c);
                }
            }
        }
        
        // Get aa ETM record relate with 
        List<Territory2> listETM =[SELECT ID,ParentTerritory2Id,parentTerritory2.TCBranchNumber__c,Territory_Reference_Number__c,TCBranchNumber__c,Territory_Type_Name__c FROM Territory2 Where  Territory_Type_Name__c in ('Branch','Trade') and  (Territory_Reference_Number__c in : listBranchNumber OR TCBranchNumber__c in :listTCBranchNumber or parentTerritory2.TCBranchNumber__c in :listTCBranchNumber ) ];
        Map<String,List<Id>> branchNumberWiseETM=new Map<String,List<Id>>();
        Map<String,set<Id>> TCTradebranchNumberWiseETM=new Map<String,set<Id>>();
        List<Id> listTerrirotyIds=new List<Id>();
        for(Territory2 T : listETM){
            
            if(T.Territory_Reference_Number__c!=null || T.TCBranchNumber__c!=null){
                if(T.TCBranchNumber__c!=null && listTCBranchNumber.contains(T.TCBranchNumber__c)){
                    if(T.Territory_Type_Name__c=='Branch' ){
                        if(!branchNumberWiseETM.containsKey(T.TCBranchNumber__c)){
                            branchNumberWiseETM.put(T.TCBranchNumber__c,new List<Id>());
                        }
                        branchNumberWiseETM.get(T.TCBranchNumber__c).add(T.Id);
                        branchNumberWiseETM.get(T.TCBranchNumber__c).add(T.ParentTerritory2Id);
                        listTerrirotyIds.add(T.Id);
                        listTerrirotyIds.add(T.ParentTerritory2Id);
                    }
                    else if(T.Territory_Type_Name__c=='Trade'){
                        // for trade and commercial
                        if(T.parentTerritory2.TCBranchNumber__c!=null){
                            if(!TCTradebranchNumberWiseETM.containsKey(T.parentTerritory2.TCBranchNumber__c)){
                                TCTradebranchNumberWiseETM.put(T.parentTerritory2.TCBranchNumber__c,new set<Id>());
                            }
                            TCTradebranchNumberWiseETM.get(T.parentTerritory2.TCBranchNumber__c).add(T.Id);
                            listTerrirotyIds.add(T.Id);
                        }
                    }
                }
                if(T.Territory_Reference_Number__c!=null && listBranchNumber.contains(T.Territory_Reference_Number__c)){
                    if(T.Territory_Type_Name__c=='Branch' ){
                        if(!branchNumberWiseETM.containsKey(T.Territory_Reference_Number__c)){
                            branchNumberWiseETM.put(T.Territory_Reference_Number__c,new List<Id>());
                        }
                        branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.Id);
                        branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.ParentTerritory2Id);
                        listTerrirotyIds.add(T.Id);
                        listTerrirotyIds.add(T.ParentTerritory2Id);
                    }
                }
            }
        }
        
        Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :listTerrirotyIds];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.RelatedId,g.Id);
        }
        
        // Branch Number wise User sharing from ETM
        Map<String,set<Id>> mapBranchWiseUsers=new Map<String,set<Id>>();
        for(String branchNumber : branchNumberWiseETM.keySet()){
            if(!mapBranchWiseUsers.containsKey(branchNumber)){
                mapBranchWiseUsers.put(branchNumber,new set<Id>());
            }
            for(String TId : branchNumberWiseETM.get(branchNumber)){
                if(TerritoryWiseGroup.containsKey(TId)){
                    mapBranchWiseUsers.get(branchNumber).add(TerritoryWiseGroup.get(TId));
                }
            }
            
        }
        // Branch Number wise User sharing from ETM
        Map<String,set<Id>> mapTCBranchWiseUsers=new Map<String,set<Id>>();
        for(String branchNumber : TCTradebranchNumberWiseETM.keySet()){
            if(!mapTCBranchWiseUsers.containsKey(branchNumber)){
                mapTCBranchWiseUsers.put(branchNumber,new set<Id>());
            }
            for(String TId : TCTradebranchNumberWiseETM.get(branchNumber)){
                if(TerritoryWiseGroup.containsKey(TId)){
                    mapTCBranchWiseUsers.get(branchNumber).add(TerritoryWiseGroup.get(TId));
                }
            }
        }
        
        List<Branch_Grouping__c> BranchGroupList=[SELECT ID,NAME FROM Branch_Grouping__c where Id in :listAORBranchIds ];
        set<String> setAORBranch=new set<String>();
        Map<Id,String> idWiseName=new Map<Id,String>();
        for(Branch_Grouping__c BG : BranchGroupList){
            setAORBranch.add(BG.Name);
            idWiseName.put(BG.Id,BG.Name);
        } 
        
        // get List Of AOR User
        List<User> listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c in :setAORBranch];
        
        // AOR Wise User List for share with all the related AOR
        Map<String,set<Id>> AORWiseUserlist=new Map<String,set<Id>>();
        for(User u:listAORUser){
            if(!AORWiseUserlist.containsKey(u.AOR__c)){
                AORWiseUserlist.put(u.AOR__c,new set<Id>());
            }
            AORWiseUserlist.get(u.AOR__c).add(u.Id);
        }
     
        Map<Id,set<ID>> CampWiseUsersIdsToShare=new Map<Id,set<ID>>();
        Map<Id,set<ID>> CampWiseRepsUsersIdsToShare=new Map<Id,set<ID>>();
        
        List<CampaignShare> listCampShare=new list<CampaignShare>();
        for(Campaign cmp : listCampaigns){
            Id AORId;
            if(cmp.Business_Segment__c=='Trade' ||cmp.Business_Segment__c=='Commercial' ){
                if(cmp.Type=='Branch'){
                    // Branch Number wise User sharing
                    if(cmp.Branch_Name__c!=null){
                        if(branchIdWiseBranch.containsKey(cmp.Branch_Name__c)){
                            if(!CampWiseUsersIdsToShare.containsKey(cmp.Id)){
                                CampWiseUsersIdsToShare.put(cmp.Id,new set<Id>());
                            }
                            if(mapBranchWiseUsers.containsKey(branchIdWiseBranch.get(cmp.Branch_Name__c).T_C_Branch_Number__c)){
                                CampWiseUsersIdsToShare.get(cmp.Id).addAll(mapBranchWiseUsers.get(branchIdWiseBranch.get(cmp.Branch_Name__c).T_C_Branch_Number__c));
                            }
                            
                            if(!CampWiseRepsUsersIdsToShare.containsKey(cmp.Id)){
                                CampWiseRepsUsersIdsToShare.put(cmp.Id,new set<Id>());
                            }
                            if(mapTCBranchWiseUsers.containsKey(branchIdWiseBranch.get(cmp.Branch_Name__c).T_C_Branch_Number__c)){
                                CampWiseRepsUsersIdsToShare.get(cmp.Id).addAll(mapTCBranchWiseUsers.get(branchIdWiseBranch.get(cmp.Branch_Name__c).T_C_Branch_Number__c));
                            }
                        }
                        
                    }
                }
            }else{
                // Branch Number wise User sharing
                if(cmp.Branch_Name__c!=null){
                    if(branchIdWiseBranch.containsKey(cmp.Branch_Name__c)){
                        if(!CampWiseUsersIdsToShare.containsKey(cmp.Id)){
                            CampWiseUsersIdsToShare.put(cmp.Id,new set<Id>());
                        }
                        if(mapBranchWiseUsers.containsKey(branchIdWiseBranch.get(cmp.Branch_Name__c).Branch_Number__c)){
                            CampWiseUsersIdsToShare.get(cmp.Id).addAll(mapBranchWiseUsers.get(branchIdWiseBranch.get(cmp.Branch_Name__c).Branch_Number__c));
                        }
                        
                        if(cmp.AOR__c==null){
                            AORId=branchIdWiseBranch.get(cmp.Branch_Name__c).AOR__c;
                        }
                    }
                }
                if(cmp.AOR__c!=null){
                    AORId=cmp.AOR__c;
                }
                // AOR wise User Sharing
                if(AORId!=null){
                    if(idWiseName.containsKey(AORId)){
                        if(!CampWiseUsersIdsToShare.containsKey(cmp.Id)){
                            CampWiseUsersIdsToShare.put(cmp.Id,new set<Id>());
                        }
                        if(AORWiseUserlist.containsKey(idWiseName.get(AORId))){
                            CampWiseUsersIdsToShare.get(cmp.Id).addAll(AORWiseUserlist.get(idWiseName.get(AORId)));
                        }
                    }
                    
                    // IF AOR EXIST and BRANCH not selected than share with all the branches
                    if(cmp.Branch_Name__c==null && AORWiseBranchNumbers.containsKey(AORId)){
                        for(String branchNumber : AORWiseBranchNumbers.get(AORId)){
                            if(mapBranchWiseUsers.containsKey(branchNumber)){
                                CampWiseUsersIdsToShare.get(cmp.Id).addAll(mapBranchWiseUsers.get(branchNumber));
                            }
                        }
                    }
                }
            }
            if(CampWiseUsersIdsToShare.get(cmp.Id)!=null && CampWiseUsersIdsToShare.get(cmp.Id).size()>0){
                for(Id userId : CampWiseUsersIdsToShare.get(cmp.Id)){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = cmp.Id; 
                    campShare.UserOrGroupId = userId; 
                    campShare.CampaignAccessLevel  = 'Edit';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
            }
            if(CampWiseRepsUsersIdsToShare.get(cmp.Id)!=null && CampWiseRepsUsersIdsToShare.get(cmp.Id).size()>0){
                for(Id userId : CampWiseRepsUsersIdsToShare.get(cmp.Id)){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = cmp.Id; 
                    campShare.UserOrGroupId = userId; 
                    campShare.CampaignAccessLevel  = 'Read';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
            }
        } 
         Database.SaveResult[] srList = Database.insert(listCampShare, false);

        //insert listCampShare;
    }
    
    public static void shareCampaingWithAORUser(List<String> userIds){
        List<User> listUser=[SELECT Id,AOR__C from User where Id in :userIds];
        Map<String,Set<Id>> listAORBranchName=new Map<String,Set<Id>>();
        for(User u: listUser){
            if(u.AOR__c!=null){
                if(!listAORBranchName.containsKey(u.AOR__c)){
                    listAORBranchName.put(u.AOR__c,new set<Id>());
                }
                listAORBranchName.get(u.AOR__c).add(u.Id);
            }
        }
        
        List<CampaignShare> listCampShare=new List<CampaignShare>();
        List<Campaign> listCampaign=[Select Id,AOR__r.Name,Branch_name__r.AOR__r.Name from Campaign where AOR__r.Name in :listAORBranchName.keySet() or Branch_name__r.AOR__r.Name in :listAORBranchName.keySet()  ];
        for(Campaign camp :listCampaign){
            if(camp.AOR__r.Name!=null && listAORBranchName.containsKey(camp.AOR__r.Name)){
                for(Id u : listAORBranchName.get(camp.AOR__r.Name)){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = camp.Id; 
                    campShare.UserOrGroupId = u; 
                    campShare.CampaignAccessLevel  = 'Edit';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
            }
            else if(camp.Branch_name__r.AOR__r.Name!=null && listAORBranchName.containsKey(camp.Branch_name__r.AOR__r.Name)){
                for(Id u : listAORBranchName.get(camp.Branch_name__r.AOR__r.Name)){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = camp.Id; 
                    campShare.UserOrGroupId = u; 
                    campShare.CampaignAccessLevel  = 'Edit';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
            }
        }
        if(listCampShare.size()>0){
             Database.SaveResult[] srList = Database.insert(listCampShare, false);

           // insert listCampShare;
        }  
        
    }
   
    public static void removeShareCampaingWithAORUser(List<String> userIds){
        List<CampaignShare> listCampShare=[SELECT ID from CampaignShare where UserOrGroupId in :userIds];
        // remove access from all the campaign for that user
        //delete listCampShare;
         Database.delete(listCampShare, false);
    }
    @future()
    public static void addRemoveShareCampaingWithAORUser(List<String> userIds,List<String> removeUserIds){
        if(removeUserIds.size()>0){
            removeShareCampaingWithAORUser(removeUserIds);
        }
        if(userIds.size()>0){
            shareCampaingWithAORUser(userIds);
        }
    }
    
    @future()
    public static void removeShareCampaignRecordWithETMGroupFuture(List<String> branchNumbers){
        removeShareCampaignRecordWithETMGroup(branchNumbers);
    }
    
    public static void removeShareCampaignRecordWithETMGroup(List<String> branchNumbers){
        List<Campaignshare> removelistCampShare=[SELECT ID,Campaign.Branch_Name__r.Branch_Number__c,Campaign.Branch_Name__r.Branch_Family__c,Campaign.Branch_Name__r.Branch_Family__r.Branch_Family_Number__c,UserOrGroupId from Campaignshare 
                                                   Where Campaign.Branch_Name__r.Branch_Number__c in :branchNumbers];
        
        
        // remove access from all the branch for that user
        Database.Delete(removelistCampShare, false);
        //delete removelistBranchShare; 
        
    }
    
    @future()
    public static void shareCampaignRecordWithETMGroupFuture(List<String> branchNumbers){
        shareCampaignRecordWithETMGroup(branchNumbers);
    }
    
    public static void shareCampaignRecordWithETMGroup(List<String> branchNumbers){
        List<Campaign> listCampaign=[SELECT ID,AOR__C,AOR__r.Name,Branch_Name__c,Branch_Name__r.AOR__c,Branch_Name__r.AOR__r.Name,Branch_Name__r.Branch_Number__c,Branch_Name__r.Branch_Family__r.Branch_Family_Number__c
                                       FROM Campaign Where Branch_Name__r.Branch_Number__c in :branchNumbers ];
        Map<String,set<Id>> branchGroupWiseCampId=new Map<String,set<Id>>();
        Map<String,set<Id>> branchWiseCampId=new Map<String,set<Id>>();
        List<String> listAORBranchName=new List<String>();
       
        String BranchNumber,BranchGrouping;
        for(Campaign cmp : listCampaign){
            BranchNumber=cmp.Branch_Name__r.Branch_Number__c!=null?cmp.Branch_Name__r.Branch_Number__c:null;
            BranchGrouping=cmp.Branch_Name__r.Branch_Family__c!=null?cmp.Branch_Name__r.Branch_Family__r.Branch_Family_Number__c:null;
            If(BranchNumber!=null){
                if(!branchWiseCampId.containsKey(BranchNumber)){
                    branchWiseCampId.put(BranchNumber,new set<Id>());
                }
                branchWiseCampId.get(BranchNumber).add(cmp.Id);
                if(cmp.Branch_Name__r.AOR__c!=null){
                    listAORBranchName.add(cmp.Branch_Name__r.AOR__r.Name);
                }
            }
            If(BranchGrouping!=null){
                if(!branchGroupWiseCampId.containsKey(BranchGrouping)){
                    branchGroupWiseCampId.put(BranchGrouping,new set<Id>());
                }
                branchGroupWiseCampId.get(BranchGrouping).add(cmp.Id);
            }
            if(cmp.AOR__c!=null){
                listAORBranchName.add(cmp.AOR__r.Name);
            }
        }
        
        // Get aa ETM record relate with 
        List<Territory2> listETM =[SELECT ID,Territory_Reference_Number__c,Territory_Type_Name__c FROM Territory2 Where ( Territory_Type_Name__c='Branch' and  Territory_Reference_Number__c in : branchNumbers) or ( Territory_Type_Name__c='Branch_Family' and Territory_Reference_Number__c in :branchGroupWiseCampId.keySet())];
        Map<String,Id> branchNumberWiseETM=new Map<String,Id>();
        Map<String,Id> LegacyIdWiseETM=new Map<String,Id>();
        for(Territory2 T : listETM){
            
            if(T.Territory_Reference_Number__c!=null){
                if(T.Territory_Type_Name__c=='Branch' ){
                    branchNumberWiseETM.put(T.Territory_Reference_Number__c,T.Id);
                }else if(T.Territory_Type_Name__c=='Branch_Family' ){
                    LegacyIdWiseETM.put(T.Territory_Reference_Number__c,T.Id);
                }
            }
        }
        
        Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :listETM];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.RelatedId,g.Id);
        }
        
        
        // get List Of AOR User
        List<User> listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c in :listAORBranchName];
        
        // AOR Wise User List for share with all the related AOR
        Map<String,set<Id>> AORWiseUserlist=new Map<String,set<Id>>();
        for(User u:listAORUser){
            if(!AORWiseUserlist.containsKey(u.AOR__c)){
                AORWiseUserlist.put(u.AOR__c,new set<Id>());
            }
            AORWiseUserlist.get(u.AOR__c).add(u.Id);
        }
        
        String groupId;
        List<CampaignShare> listCampShare=new List<CampaignShare>();
        for(Campaign camp : listCampaign){
            BranchNumber=camp.Branch_Name__r.Branch_Number__c!=null?camp.Branch_Name__r.Branch_Number__c:null;
            BranchGrouping=camp.Branch_Name__r.Branch_Family__c!=null?camp.Branch_Name__r.Branch_Family__r.Branch_Family_Number__c:null;
           
            If(BranchNumber!=null){
                groupId=branchNumberWiseETM.containsKey(BranchNumber)?TerritoryWiseGroup.get(branchNumberWiseETM.get(BranchNumber)):null;
                if(groupId!=null){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = camp.Id; 
                    campShare.UserOrGroupId = groupId; 
                    campShare.CampaignAccessLevel  = 'Edit';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
                if(camp.Branch_Name__r.AOR__c!=null){
                    if(AORWiseUserlist.containsKey(camp.Branch_Name__r.AOR__r.Name))
                    {
                        for(String UId: AORWiseUserlist.get(camp.Branch_Name__r.AOR__r.Name)){
                            CampaignShare campShare = new CampaignShare();
                            campShare.CampaignId = camp.Id; 
                            campShare.UserOrGroupId = UId; 
                            campShare.CampaignAccessLevel  = 'Edit';
                            campShare.RowCause = 'Manual';
                            listCampShare.add(campShare);
                        }
                    }
                }
            }
            If(BranchGrouping!=null){
                groupId=LegacyIdWiseETM.containsKey(BranchGrouping)?TerritoryWiseGroup.get(LegacyIdWiseETM.get(BranchGrouping)):null;
                if(groupId!=null){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = camp.Id; 
                    campShare.UserOrGroupId = groupId; 
                    campShare.CampaignAccessLevel  = 'Edit';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
            }
            if(camp.AOR__c!=null){
                if(AORWiseUserlist.containsKey(camp.AOR__r.Name))
                {
                    for(String UId: AORWiseUserlist.get(camp.AOR__r.Name)){
                        CampaignShare campShare = new CampaignShare();
                        campShare.CampaignId = camp.Id; 
                        campShare.UserOrGroupId = UId; 
                        campShare.CampaignAccessLevel  = 'Edit';
                        campShare.RowCause = 'Manual';
                        listCampShare.add(campShare);
                    }
                }
            }
            
        }
        system.debug('@@Insert listSTShare '+listCampShare);
        if(listCampShare.size()>0){
            
            Database.SaveResult[] srList = Database.insert(listCampShare, false);
            
            //insert listBranchShare;
        }  
    }
    
      @future()
    public static void updateCampaignRecordWithETMUser(List<String> branchNumbers,List<String> removebranchNumbers){
        if(removebranchNumbers.size()>0){
            removeShareCampaignRecordWithETMGroup(removebranchNumbers);
        }
        if(branchNumbers.size()>0){
            shareCampaignRecordWithETMGroup(branchNumbers);
        }
    }
    
    
    public static void removeShareCampWithAORUserByOpps(Map<String,String> mapCampAORtoremoveShare){
        // get List Of AOR User
        List<User> listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c in :mapCampAORtoremoveShare.values()];
       
        List<CampaignShare> listCampShare=[SELECT ID,CampaignId from CampaignShare where CampaignId in :mapCampAORtoremoveShare.keySet() and UserOrGroupId in :listAORUser ];
        system.debug('@@'+listCampShare);
        // remove access from all the campaign for that user
        //delete listCampShare;
        Database.delete(listCampShare, false);
    }
    public static void shareCampWithAORUserByOpps(Map<string,String> mapCampAORtoShare){
        // get List Of AOR User
        List<User> listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c in :mapCampAORtoShare.values()];
       
        // AOR Wise User List for share with all the related AOR
        Map<String,set<Id>> AORWiseUserlist=new Map<String,set<Id>>();
        for(User u:listAORUser){
            if(!AORWiseUserlist.containsKey(u.AOR__c)){
                AORWiseUserlist.put(u.AOR__c,new set<Id>());
            }
            AORWiseUserlist.get(u.AOR__c).add(u.Id);
        }
        
        List<CampaignShare> listCampShare=new List<CampaignShare>();
        for(String campId : mapCampAORtoShare.keySet()){
            if(mapCampAORtoShare.get(campId)!=null)
            {
                for(String UId: AORWiseUserlist.get(mapCampAORtoShare.get(campId))){
                    CampaignShare campShare = new CampaignShare();
                    campShare.CampaignId = campId; 
                    campShare.UserOrGroupId = UId; 
                    campShare.CampaignAccessLevel  = 'Read';
                    campShare.RowCause = 'Manual';
                    listCampShare.add(campShare);
                }
            }
        }
        
        if(listCampShare.size()>0){
            
            Database.SaveResult[] srList = Database.insert(listCampShare, false);
            
            //insert listBranchShare;
        }  
       
    }
    
    public static void ShareCampWithUserByOpps(List<Id> opportunityIds){
        List<Opportunity> opportunities =
            [Select Id, AccountId, Territory2Id,Account_Branch_Profile__r.Branch__r.Branch_Number__c,Zone__r.ParentTerritory.Branch__r.Branch_Number__c,
             Zone__r.ParentTerritory.Branch__r.AOR__c,Zone__r.ParentTerritory.Branch__r.AOR__r.Name,CampaignId 
             from Opportunity where Id IN :opportunityIds];
        List<String> BranchNumbers = new List<String>();
        // Create set of parent accountIds
        for(Opportunity opp:opportunities){
            if(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c != null){
                BranchNumbers.add(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c);
            }
            
        }
        
        List<Territory2> listETM =[SELECT ID,Territory_Reference_Number__c,parentTerritory2Id,Territory_Type_Name__c FROM Territory2 Where Territory_Type_Name__c='Branch' and Territory_Reference_Number__c in :BranchNumbers];
        Map<String,List<Id>> branchNumberWiseETM=new Map<String,List<Id>>();
        Set<Id> setTerritoryIds=new set<Id>();
        for(Territory2 T : listETM){
            if(T.Territory_Reference_Number__c!=null){
                branchNumberWiseETM.put(T.Territory_Reference_Number__c,new List<Id>());
                branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.Id);
                branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.parentTerritory2Id);
                
                setTerritoryIds.add(T.Id);
                setTerritoryIds.add(T.parentTerritory2Id);
            }
        }
        
        Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :setTerritoryIds];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.RelatedId,g.Id);
        }
        
        List<CampaignShare> listCampShare=new List<CampaignShare>(); 
        for(Opportunity opp: opportunities){
            if(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c != null && branchNumberWiseETM.containsKey(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c)){
                for(String Tid : branchNumberWiseETM.get(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c)){
                    if(opp.CampaignId!=null){
                        CampaignShare campShare = new CampaignShare();
                        campShare.CampaignId = opp.CampaignId; 
                        campShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                        campShare.CampaignAccessLevel  = 'Read';
                        campShare.RowCause = 'Manual';
                        listCampShare.add(campShare);
                    }
                }
            }
        } 
        if(listCampShare.size()>0)
            Database.Insert(listCampShare, false);
       
    }
    
    
}