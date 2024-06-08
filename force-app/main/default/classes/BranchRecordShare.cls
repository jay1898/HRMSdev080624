public without sharing class BranchRecordShare {
   /* public static void shareBranchRecordWithETM(List<Branch__c> listBranchRecs){
        List<Id> listAORBranchIds=new List<Id>();
        List<Id> listBranchIds=new List<Id>();
        for(Branch__c branch : listBranchRecs){
            listBranchIds.add(branch.Id);
            if(branch.AOR__c!=null){
                listAORBranchIds.add(branch.AOR__c); 
            }
        }
        
        // Get List Of all the branches related to AOR
        List<Branch__c> listBranch=[SELECT ID,Name,Branch_Number__c,AOR__c,AOR__r.Name From Branch__c where id in :listBranchIds Or  AOR__c in :listAORBranchIds ];
        
        List<String> listBranchNumber=new List<String>();
        Map<Id,Set<String>> AORWiseBranchNumbers=new Map<Id,Set<String>>();
        Map<Id,branch__c> branchIdWiseBranch=new Map<Id,branch__c>();
        
        set<String> setAORBranch=new set<String>();
        Map<Id,String> idWiseName=new Map<Id,String>();
        for(Branch__c branch:listBranch){
            
            listBranchNumber.add(branch.Branch_Number__c);
            branchIdWiseBranch.put(branch.Id,branch);
            if(branch.AOR__c!=null){
                if(!AORWiseBranchNumbers.containsKey(branch.AOR__c)){
                    AORWiseBranchNumbers.put(branch.AOR__c,new set<String>());
                }
                AORWiseBranchNumbers.get(branch.AOR__c).add(branch.Branch_Number__c);
            }
            if(branch.AOR__c!=null){
                setAORBranch.add(branch.AOR__r.Name);
                idWiseName.put(branch.AOR__c,branch.AOR__r.Name);
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
     
        Map<Id,set<ID>> branchWiseUsersIdsToShare=new Map<Id,set<ID>>();
        
        List<Branch__share> listBranchShare=new list<Branch__share>();
        for(Branch__c branch : listBranchRecs){
            // Branch Number wise User sharing
            if(!branchWiseUsersIdsToShare.containsKey(branch.Id)){
                branchWiseUsersIdsToShare.put(branch.Id,new set<Id>());
            }
            if(mapBranchWiseUsers.containsKey(branch.Branch_Number__c)){
                branchWiseUsersIdsToShare.get(branch.Id).addAll(mapBranchWiseUsers.get(branch.Branch_Number__c));
            }
            
            // AOR wise User Sharing
            if(branch.AOR__c!=null){
                if(idWiseName.containsKey(branch.AOR__c)){
                    if(!branchWiseUsersIdsToShare.containsKey(branch.Id)){
                        branchWiseUsersIdsToShare.put(branch.Id,new set<Id>());
                    }
                    if(AORWiseUserlist.containsKey(idWiseName.get(branch.AOR__c))){
                        branchWiseUsersIdsToShare.get(branch.Id).addAll(AORWiseUserlist.get(idWiseName.get(branch.AOR__c)));
                    }
                }
            }
            
            if(branchWiseUsersIdsToShare.get(branch.Id)!=null && branchWiseUsersIdsToShare.get(branch.Id).size()>0){
                for(Id userId : branchWiseUsersIdsToShare.get(branch.Id)){
                    Branch__share branchShare = new Branch__share();
                    branchShare.ParentId = branch.Id; 
                    branchShare.UserOrGroupId = userId; 
                    branchShare.AccessLevel  = 'Edit';
                    branchShare.RowCause = 'Manual';
                    listBranchShare.add(branchShare);
                }
            }
        } 
        Database.SaveResult[] srList = Database.insert(listBranchShare, false);

        //insert listBranchShare; 
    }*/
    
   /* public static void removeShareBranchRecordWithETM(List<Branch__c> listBranchRecs){
        List<Branch__share> listBranchShare=[SELECT ID from Branch__share where parentId in :listBranchRecs];
        // remove access from all the branch for that user
         Database.Delete(listBranchShare, false);
        //delete listBranchShare;
        
    }*/
    
   /* public static void shareBranchRecordWithAORUser(List<Branch__c> listBranchRecs){
        List<Id> listAORBranchIds=new List<Id>();
        for(Branch__c branch : listBranchRecs){
            if(branch.AOR__c!=null){
                listAORBranchIds.add(branch.AOR__c); 
            }
        }
        
        // Get List Of all the branches related to AOR
        List<Branch__c> listBranch=[SELECT ID,Name,Branch_Number__c,AOR__c,AOR__r.Name From Branch__c where AOR__c in :listAORBranchIds ];
        
        Map<Id,Set<String>> AORWiseBranchNumbers=new Map<Id,Set<String>>();
        
        set<String> setAORBranch=new set<String>();
        Map<Id,String> idWiseName=new Map<Id,String>();
        for(Branch__c branch:listBranch){
            if(branch.AOR__c!=null){
                if(!AORWiseBranchNumbers.containsKey(branch.AOR__c)){
                    AORWiseBranchNumbers.put(branch.AOR__c,new set<String>());
                }
                AORWiseBranchNumbers.get(branch.AOR__c).add(branch.Branch_Number__c);
                setAORBranch.add(branch.AOR__r.Name);
                idWiseName.put(branch.AOR__c,branch.AOR__r.Name);
            }
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
     
        Map<Id,set<ID>> branchWiseUsersIdsToShare=new Map<Id,set<ID>>();
        
        List<Branch__share> listBranchShare=new list<Branch__share>();
        for(Branch__c branch : listBranchRecs){
            // Branch Number wise User sharing
            if(!branchWiseUsersIdsToShare.containsKey(branch.Id)){
                branchWiseUsersIdsToShare.put(branch.Id,new set<Id>());
            }
          
            
            // AOR wise User Sharing
            if(branch.AOR__c!=null){
                if(idWiseName.containsKey(branch.AOR__c)){
                    if(!branchWiseUsersIdsToShare.containsKey(branch.Id)){
                        branchWiseUsersIdsToShare.put(branch.Id,new set<Id>());
                    }
                    if(AORWiseUserlist.containsKey(idWiseName.get(branch.AOR__c))){
                        branchWiseUsersIdsToShare.get(branch.Id).addAll(AORWiseUserlist.get(idWiseName.get(branch.AOR__c)));
                    }
                }
            }
            
            if(branchWiseUsersIdsToShare.get(branch.Id)!=null && branchWiseUsersIdsToShare.get(branch.Id).size()>0){
                for(Id userId : branchWiseUsersIdsToShare.get(branch.Id)){
                    Branch__share branchShare = new Branch__share();
                    branchShare.ParentId = branch.Id; 
                    branchShare.UserOrGroupId = userId; 
                    branchShare.AccessLevel  = 'Edit';
                    branchShare.RowCause = 'Manual';
                    listBranchShare.add(branchShare);
                }
            }
        } 
        Database.SaveResult[] srList = Database.insert(listBranchShare, false);

        //insert listBranchShare; 
    }*/
    
   
    public static void shareBranchWithAORUser(List<String> userIds){
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
        
        List<Branch__Share> listBranchShare=new List<Branch__Share>();
        List<Branch__c> listBranches=[Select Id,AOR__r.Name from Branch__c where AOR__r.Name in :listAORBranchName.keySet()  ];
        for(Branch__c branch :listBranches){
            if(branch.AOR__r.Name!=null && listAORBranchName.containsKey(branch.AOR__r.Name)){
                for(Id u : listAORBranchName.get(branch.AOR__r.Name)){
                    Branch__Share branchShare = new Branch__Share();
                    branchShare.parentId = branch.Id; 
                    branchShare.UserOrGroupId = u; 
                    branchShare.AccessLevel  = 'Edit';
                    branchShare.RowCause = 'Manual';
                    listBranchShare.add(branchShare);
                }
            }
           
        }
        if(listBranchShare.size()>0){
            Database.SaveResult[] srList = Database.insert(listBranchShare, false);

            //insert listBranchShare;
        } 
        
    }
    
    public static void removeShareBranchWithAORUser(List<String> userIds){
        List<Branch__Share> listBranchShare=[SELECT ID from Branch__Share where UserOrGroupId in :userIds];
         Database.Delete(listBranchShare, false);

        // remove access from all the branch for that user
       // delete listBranchShare;
        
    }
    @future()
    public static void addRemoveShareBranchWithAORUser(List<String> userIds,List<String> removeUserIds){
        if(removeUserIds.size()>0){
            removeShareBranchWithAORUser(removeUserIds);
        }
        if(userIds.size()>0){
            shareBranchWithAORUser(userIds);
        }
        
    }
    
    @future()
    public static void removeShareBranchRecordWithETMGroupFuture(List<String> branchNumbers){
        removeShareBranchRecordWithETMGroup(branchNumbers);
    }
    
    public static void removeShareBranchRecordWithETMGroup(List<String> branchNumbers){
        List<Branch__share> removelistBranchShare=[SELECT ID,Parent.Branch_Number__c,Parent.Branch_Family__c,Parent.Branch_Family__r.Branch_Family_Number__c,UserOrGroupId from Branch__share 
                                                   Where Parent.Branch_Number__c in :branchNumbers];
        
        
        // remove access from all the branch for that user
        Database.Delete(removelistBranchShare, false);
        //delete removelistBranchShare; 
        
    }

    @future()
    public static void shareBranchRecordWithETMGroupFuture(List<String> branchNumbers){
        shareBranchRecordWithETMGroup(branchNumbers);
    }
    
    public static void shareBranchRecordWithETMGroup(List<String> branchNumbers){
        List<Branch__c> listBranch=[SELECT ID,Branch_Number__c,AOR__c,AOR__r.Name,Branch_Family__r.Branch_Family_Number__c
                                       FROM Branch__c Where Branch_Number__c in :branchNumbers ];
        Map<String,set<Id>> branchGroupWisebranchId=new Map<String,set<Id>>();
        List<String> listAORBranchName=new List<String>();
       
        String BranchNumber,BranchGrouping;
        for(Branch__c Branch : listBranch){
            BranchGrouping=branch.Branch_Family__c!=null?branch.Branch_Family__r.Branch_Family_Number__c:null;
            If(BranchGrouping!=null){
                if(!branchGroupWisebranchId.containsKey(BranchGrouping)){
                    branchGroupWisebranchId.put(BranchGrouping,new set<Id>());
                }
                branchGroupWisebranchId.get(BranchGrouping).add(Branch.Id);
            }
            if(Branch.AOR__c!=null){
                listAORBranchName.add(Branch.AOR__r.Name);
            }
        }
        
        // Get aa ETM record relate with 
        List<Territory2> listETM =[SELECT ID,Territory_Reference_Number__c,Territory_Type_Name__c FROM Territory2 Where ( Territory_Type_Name__c='Branch' and  Territory_Reference_Number__c in : branchNumbers) or ( Territory_Type_Name__c='Branch_Family' and Territory_Reference_Number__c in :branchGroupWisebranchId.keySet())];
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
        List<Branch__Share> listBranchShare=new List<Branch__Share>();
        for(Branch__c Branch : listBranch){
            BranchNumber=branch.Branch_Number__c!=null?branch.Branch_Number__c:null;
            BranchGrouping=branch.Branch_Family__c!=null?branch.Branch_Family__r.Branch_Family_Number__c:null;
            If(BranchNumber!=null){
                groupId=branchNumberWiseETM.containsKey(BranchNumber)?TerritoryWiseGroup.get(branchNumberWiseETM.get(BranchNumber)):null;
                if(groupId!=null){
                    Branch__Share branchShare = new Branch__Share();
                    branchShare.parentId = branch.Id; 
                    branchShare.UserOrGroupId = groupId; 
                    branchShare.AccessLevel  = 'Edit';
                    branchShare.RowCause = 'Manual';
                    listBranchShare.add(branchShare);
                }
            }
            If(BranchGrouping!=null){
                groupId=LegacyIdWiseETM.containsKey(BranchGrouping)?TerritoryWiseGroup.get(LegacyIdWiseETM.get(BranchGrouping)):null;
                if(groupId!=null){
                    Branch__Share branchShare = new Branch__Share();
                    branchShare.parentId = branch.Id; 
                    branchShare.UserOrGroupId = groupId; 
                    branchShare.AccessLevel  = 'Edit';
                    branchShare.RowCause = 'Manual';
                    listBranchShare.add(branchShare);
                }
            }
            if(Branch.AOR__c!=null){
                if(AORWiseUserlist.containsKey(Branch.AOR__r.Name))
                {
                    for(String UId: AORWiseUserlist.get(Branch.AOR__r.Name)){
                        Branch__Share branchShare = new Branch__Share();
                        branchShare.parentId = branch.Id; 
                        branchShare.UserOrGroupId = UId; 
                        branchShare.AccessLevel  = 'Edit';
                        branchShare.RowCause = 'Manual';
                        listBranchShare.add(branchShare);
                    }
                }
            }
        }
        system.debug('@@Insert listSTShare '+listBranchShare);
        if(listBranchShare.size()>0){
            
            Database.SaveResult[] srList = Database.insert(listBranchShare, false);
            
            //insert listBranchShare;
        }  
    }
    
    @future()
    public static void updateBranchRecordWithETMUser(List<String> branchNumbers,List<String> removebranchNumbers){
        if(removebranchNumbers.size()>0){
            removeShareBranchRecordWithETMGroup(removebranchNumbers);
        }
        if(branchNumbers.size()>0){
            shareBranchRecordWithETMGroup(branchNumbers);
        }
    }
    
}