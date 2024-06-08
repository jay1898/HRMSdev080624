public without sharing class ServiceTerritoryRecordShare {
    public static void shareSTRecordWithETM(List<String> listSTIds){
        List<ServiceTerritory> listST=[SELECT ID,ParentTerritoryId,ParentTerritory.ParentTerritoryId,
                                       		Branch__c,ParentTerritory.Branch__c,ParentTerritory.ParentTerritory.Branch__c,
                                       		Branch__r.Branch_Number__c,ParentTerritory.Branch__r.Branch_Number__c,ParentTerritory.ParentTerritory.Branch__r.Branch_Number__c,
                                      		Branch__r.Branch_Family__c,ParentTerritory.Branch__r.Branch_Family__c,ParentTerritory.ParentTerritory.Branch__r.Branch_Family__c,
                                       		Branch__r.Branch_Family__r.Branch_Family_Number__c,ParentTerritory.Branch__r.Branch_Family__r.Branch_Family_Number__c,
                                       		ParentTerritory.ParentTerritory.Branch__r.Branch_Family__r.Branch_Family_Number__c
                                          FROM ServiceTerritory Where Id in :listSTIds or ParentTerritoryId in :listSTIds or ParentTerritory.ParentTerritoryId in :listSTIds];
        Map<String,set<Id>> branchWiseSTId=new Map<String,set<Id>>();
        Map<String,set<Id>> branchGroupWiseSTId=new Map<String,set<Id>>();
        
        String BranchNumber,BranchGrouping;
        for(ServiceTerritory ST : listST){
            BranchNumber=ST.Branch__c!=null?ST.Branch__r.Branch_Number__c:(ST.ParentTerritory.Branch__c!=null?ST.ParentTerritory.Branch__r.Branch_Number__c:ST.ParentTerritory.ParentTerritory.Branch__r.Branch_Number__c);
            BranchGrouping=ST.Branch__r.Branch_Family__c!=null?ST.Branch__r.Branch_Family__r.Branch_Family_Number__c:(ST.ParentTerritory.Branch__r.Branch_Family__c!=null?ST.ParentTerritory.Branch__r.Branch_Family__r.Branch_Family_Number__c:ST.ParentTerritory.ParentTerritory.Branch__r.Branch_Family__r.Branch_Family_Number__c);
            
            If(BranchNumber!=null){
                if(!branchWiseSTId.containsKey(BranchNumber)){
                    branchWiseSTId.put(BranchNumber,new set<Id>());
                }
                branchWiseSTId.get(BranchNumber).add(ST.Id);
            }
            If(BranchGrouping!=null){
                if(!branchGroupWiseSTId.containsKey(BranchGrouping)){
                    branchGroupWiseSTId.put(BranchGrouping,new set<Id>());
                }
                branchGroupWiseSTId.get(BranchGrouping).add(ST.Id);
            }
        }
     
        // Get aa ETM record relate with 
        List<Territory2> listETM =[SELECT ID,Territory_Reference_Number__c,Territory_Type_Name__c FROM Territory2 Where ( Territory_Type_Name__c='Branch' and  Territory_Reference_Number__c in : branchWiseSTId.keySet()) or ( Territory_Type_Name__c='Branch_Family' and Territory_Reference_Number__c in :branchGroupWiseSTId.keySet())];
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
        String groupId;
        List<ServiceTerritoryShare> listSTShare=new List<ServiceTerritoryShare>();
        for(ServiceTerritory ST : listST){
            BranchNumber=ST.Branch__c!=null?ST.Branch__r.Branch_Number__c:(ST.ParentTerritory.Branch__c!=null?ST.ParentTerritory.Branch__r.Branch_Number__c:ST.ParentTerritory.ParentTerritory.Branch__r.Branch_Number__c);
            BranchGrouping=ST.Branch__r.Branch_Family__c!=null?ST.Branch__r.Branch_Family__r.Branch_Family_Number__c:(ST.ParentTerritory.Branch__r.Branch_Family__c!=null?ST.ParentTerritory.Branch__r.Branch_Family__r.Branch_Family_Number__c:ST.ParentTerritory.ParentTerritory.Branch__r.Branch_Family__r.Branch_Family_Number__c);
            
            If(BranchNumber!=null){
                groupId=branchNumberWiseETM.containsKey(BranchNumber)?TerritoryWiseGroup.get(branchNumberWiseETM.get(BranchNumber)):null;
                if(groupId!=null){
                    ServiceTerritoryShare STShare = new ServiceTerritoryShare();
                    STShare.parentId = ST.Id; 
                    STShare.UserOrGroupId = groupId; 
                    STShare.AccessLevel  = 'Edit';
                    STShare.RowCause = 'Manual';
                    listSTShare.add(STShare);
                }
            }
            If(BranchGrouping!=null){
               groupId=LegacyIdWiseETM.containsKey(BranchGrouping)?TerritoryWiseGroup.get(LegacyIdWiseETM.get(BranchGrouping)):null;
                if(groupId!=null){
                    ServiceTerritoryShare STShare = new ServiceTerritoryShare();
                    STShare.parentId = ST.Id; 
                    STShare.UserOrGroupId = groupId; 
                    STShare.AccessLevel  = 'Edit';
                    STShare.RowCause = 'Manual';
                    listSTShare.add(STShare);
                }
            }
        }
        system.debug('@@Insert listSTShare '+listSTShare);
        if(listSTShare.size()>0){
            
            Database.SaveResult[] srList = Database.insert(listSTShare, false);
            
            //insert listSTShare;
        } 
        
        
        
    }
    
    public static void removeShareSTRecordWithETM(List<String> listSTIds){
        List<ServiceTerritory> listST=[SELECT ID  FROM ServiceTerritory 
                                       Where Id in :listSTIds or ParentTerritoryId in :listSTIds or ParentTerritory.ParentTerritoryId in :listSTIds];
        
        List<ServiceTerritoryShare> listSTShare=[SELECT ID from ServiceTerritoryShare where parentId in :listST ];
        // remove access from all the ST for that territory
         Database.Delete(listSTShare, false);
        //delete listSTShare;
        
    }
    @future()
    public static void shareSTRecordWithETMUser(List<String> branchNumberWiseETM,List<String> LegacyIdWiseETM){
        List<ServiceTerritory> listSTFromBranch=[SELECT ID FROM ServiceTerritory 
                                                 Where Branch__r.Branch_Number__c = :branchNumberWiseETM
                                                 OR Branch__r.Branch_Family__r.Branch_Family_Number__c = :LegacyIdWiseETM];
        List<String> listSTIds=new List<String>();
        for(ServiceTerritory ST: listSTFromBranch){
            listSTIds.add(ST.Id);
        }
        system.debug('@@listSTIds :: '+listSTIds);
        if(listSTIds.size()>0){
            shareSTRecordWithETM(listSTIds);
        }
    }
    @future()
     public static void updateSTRecordWithETMUser(List<String> branchNumberWiseETM,List<String> LegacyIdWiseETM,List<String> newbranchNumberWiseETM,List<String> newLegacyIdWiseETM){
         // remove
         List<ServiceTerritory> listSTFromBranch=[SELECT ID FROM ServiceTerritory 
                                                  Where Branch__r.Branch_Number__c = :branchNumberWiseETM
                                                  OR Branch__r.Branch_Family__r.Branch_Family_Number__c = :LegacyIdWiseETM];
         List<String> listSTIds=new List<String>();
         for(ServiceTerritory ST: listSTFromBranch){
             listSTIds.add(ST.Id);
         }
         if(listSTIds.size()>0){ 
             removeShareSTRecordWithETM(listSTIds);
         }
         // ADD
         listSTFromBranch=[SELECT ID FROM ServiceTerritory 
                           Where Branch__r.Branch_Number__c = :NewbranchNumberWiseETM
                           OR Branch__r.Branch_Family__r.Branch_Family_Number__c = :NewLegacyIdWiseETM];
         listSTIds=new List<String>();
         for(ServiceTerritory ST: listSTFromBranch){
             listSTIds.add(ST.Id);
         }
         system.debug('@@listSTIds :: '+listSTIds);
         if(listSTIds.size()>0){
             shareSTRecordWithETM(listSTIds);
         }
    }
    
}