public class UserTerritory2AssociationTriggerHandler {
    
    public static Boolean runTrigger=true; 
    public static void validateUserTerritoryRole(List<UserTerritory2Association> AAList,Map<Id,UserTerritory2Association> oldMap){
        /*Map<Id, UserTerritory2Association> mapUserIds = new Map<Id, UserTerritory2Association>();
        Map<Id, UserTerritory2Association> mapUserIdNew = new Map<Id, UserTerritory2Association>();
        List<Id> listAAIds = new List<Id>();
        
        for(UserTerritory2Association AA : AAList){
            if((oldMap==null && AA.RoleInTerritory2  =='Primary')|| (oldMap!=null && (AA.RoleInTerritory2  != oldMap.get(AA.Id).RoleInTerritory2  && AA.RoleInTerritory2  =='Primary'))){
                if(mapUserIds.containsKey(AA.UserId)){
                    String errorMessage = Label.T_C_Primary_Territory_Validation;
                    errorMessage = errorMessage.replaceAll('\\{TerritoryId\\}', mapUserIds.get(AA.UserId).Territory2Id);
                    errorMessage = errorMessage.replaceAll('\\{TerritoryName\\}', mapUserIds.get(AA.UserId).Territory2Id);
                    continue;
                }
                
                mapUserIds.put(AA.UserId, AA);
                listAAIds.add(AA.Id);
            }
        }
        
        List<UserTerritory2Association> listExistinUTA = [SELECT Id, UserId, RoleInTerritory2, Territory2Id, Territory2.Name
                                                          FROM UserTerritory2Association WHERE RoleInTerritory2 = 'Primary' AND
                                                          ID not IN :listAAIds AND UserId in :mapUserIds.keySet()];
        for(UserTerritory2Association UTA : listExistinUTA){
            mapUserIdNew.put(UTA.UserId, UTA);
            
        }
        for(UserTerritory2Association AA : AAList){
            if(mapUserIdNew.containsKey(AA.UserId)){
                String errorMessage = Label.T_C_Primary_Territory_Validation;
                errorMessage = errorMessage.replaceAll('\\{TerritoryId\\}', mapUserIdNew.get(AA.UserId).Territory2Id);
                errorMessage = errorMessage.replaceAll('\\{TerritoryName\\}', mapUserIdNew.get(AA.UserId).Territory2.Name);
                AA.addError(errorMessage, false);
            }
        }
        */
        
    }
    
    public static void shareRecordsWithUTA(List<UserTerritory2Association> listUTA){
        List<String> listRecIds=new List<String>();
        for(UserTerritory2Association UTA : listUTA){
            listRecIds.add(UTA.Id); 
        } 
        UserTerritory2AssociationTriggerHandler.shareRecordsWithUTA(listRecIds); 
    }
     
    public static void removeShareRecordsWithUTA(List<UserTerritory2Association> listOldUTA){
        Map<String,set<String>> userWiseTerritoryList=new Map<String,set<String>>();
        
        Map<String,String> userWiseTerritoryMap=new Map<String,String>();
        Map<Id,Id> TerritoryWiseBFMap=new Map<Id,Id>();
        List<UserTerritory2Association> listUTA=[SELECT Id,Territory2Id,Territory2.ParentTerritory2Id,Territory2.ParentTerritory2.ParentTerritory2Id, Territory2.Territory_Type_Name__c, UserId, Territory2.Territory_Reference_Number__c, RoleInTerritory2 FROM UserTerritory2Association where id in :listOldUTA];
        // Branch Number wise User Id list to give access to campaign
        List<String> branchNumberUserIdList=new List<String>();
        for(UserTerritory2Association UTA : listUTA){
            if(UTA.Territory2.Territory_Reference_Number__c!=null){ 
                branchNumberUserIdList.add(UTA.Territory2.Territory_Reference_Number__c+'~'+UTA.UserId); 
            } 
            system.debug('UTA.Territory2.Territory_Type_Name__c: '+UTA.Territory2);
            if(UTA.Territory2.Territory_Type_Name__c=='Replacement'){
                if(!userWiseTerritoryList.containsKey(UTA.UserId)){
                    userWiseTerritoryList.put(UTA.UserId,new set<String>());
                }
                userWiseTerritoryList.get(UTA.UserId).add(UTA.Territory2.ParentTerritory2Id);
                userWiseTerritoryList.get(UTA.UserId).add(UTA.Territory2.ParentTerritory2.ParentTerritory2Id);
                TerritoryWiseBFMap.put(UTA.Territory2Id,UTA.Territory2.ParentTerritory2.ParentTerritory2Id);
            }
        } 
        
        List<UserTerritory2Association> listUTABF=[SELECT ID,UserId,Territory2.ParentTerritory2.ParentTerritory2Id FROM UserTerritory2Association 
                                                   Where Territory2Id not in :TerritoryWiseBFMap.keySet() 
                                                   and Territory2.ParentTerritory2.ParentTerritory2Id in :TerritoryWiseBFMap.values()
                                                   and userId in :userWiseTerritoryList.keySet()];
        Integer indx;
        for(UserTerritory2Association UTA : listUTABF){
            userWiseTerritoryList.get(UTA.UserId).remove(UTA.Territory2.ParentTerritory2.ParentTerritory2Id);
        }
        for(String key : userWiseTerritoryList.keySet()){
            userWiseTerritoryMap.put(key,String.join(new List<String>(userWiseTerritoryList.get(key)),'~'));
        }
        system.debug('@@'+branchNumberUserIdList);
        UserTerritory2AssociationTriggerHandler.removeShareRecordsWithUTA(branchNumberUserIdList,userWiseTerritoryMap);
    }
    @future()
    public static void shareRecordsWithUTA(List<String> listUTAIds){
        shareRecordsWithUTAWithoutFuture(listUTAIds);
    }
    public static void shareRecordsWithUTAWithoutFuture(List<String> listUTAIds){
        List<UserTerritory2Association> listUTA=[SELECT Id, UserId,Territory2.ParentTerritory2Id,Territory2.ParentTerritory2.ParentTerritory2Id, Territory2.Territory_Type_Name__c, Territory2.Territory_Reference_Number__c, RoleInTerritory2 FROM UserTerritory2Association where id in :listUTAIds];
        // Branch Number wise User Id list to give access to campaign
        Map<String,set<Id>> branchNumbers=new Map<String,set<Id>>();
		Map<String,Set<String>> userWiseTerritoryList=new Map<String,Set<String>>();
		List<String> listParentTerritoryId=new List<String>();
        for(UserTerritory2Association UTA : listUTA){
            if(UTA.Territory2.Territory_Reference_Number__c!=null){ 
                if(!branchNumbers.containsKey(UTA.Territory2.Territory_Reference_Number__c)){ 
                    branchNumbers.put(UTA.Territory2.Territory_Reference_Number__c,new set<Id>());
                }
                branchNumbers.get(UTA.Territory2.Territory_Reference_Number__c).add(UTA.UserId); 
            } 
			
			// check if new resource added in the type = Replacement
			if(UTA.Territory2.Territory_Type_Name__c=='Replacement'){
				if(!userWiseTerritoryList.containsKey(UTA.UserId)){
					userWiseTerritoryList.put(UTA.UserId,new Set<String>());
				}
				userWiseTerritoryList.get(UTA.UserId).add(UTA.Territory2.ParentTerritory2Id);
				userWiseTerritoryList.get(UTA.UserId).add(UTA.Territory2.ParentTerritory2.ParentTerritory2Id);
				listParentTerritoryId.add(UTA.Territory2.ParentTerritory2Id);
				listParentTerritoryId.add(UTA.Territory2.ParentTerritory2.ParentTerritory2Id);
			}
        }
		
		// Get Territory Group By Territory Id
		Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :listParentTerritoryId];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.RelatedId,g.Id);
        }
		
        // Get List Of ServiceResource from userId
		List<ServiceResource> listSA=[SELECT ID,RelatedRecordId FROM ServiceResource Where RelatedRecordId = :userWiseTerritoryList.KeySet()];
		
		// Share SA record With related parent Territory User
		List<ServiceResourceShare> lisSRS=new List<ServiceResourceShare>();
		for(ServiceResource SRS : listSA){
			for(String TerritoryId : userWiseTerritoryList.get(SRS.RelatedRecordId)){
				ServiceResourceShare SRSNew=new ServiceResourceShare(); 
				SRSNew.parentId = SRS.Id; 
				SRSNew.UserOrGroupId = TerritoryWiseGroup.get(TerritoryId); 
				SRSNew.AccessLevel  = 'Edit';
				SRSNew.RowCause = 'Manual';
				lisSRS.add(SRSNew);
			}
		}
		
		if(lisSRS.size()>0){
			Database.SaveResult[] srList = Database.insert(lisSRS, false);	
			   // insert lisSRS;
		}
        
    }
    
    @future()
    public static void removeShareRecordsWithUTA(List<String> listBranchUser, Map<String,String> userWiseTerritorys){
        set<String> branchNumber=new set<String>(); 
        set<String> setUserIds=new set<String>();
        String[] rec;
        for(String branchUserId :listBranchUser){
            rec=branchUserId.split('~');
            branchNumber.add(rec[0]);
            setUserIds.add(rec[1]);
        }
        
       
        
        // Remove Sales Resource
        Map<String,List<String>> userWiseTerritoryList=new  Map<String,List<String>>();
        Set<String> setTerritoryIds=new Set<String>();
        for(String userId : userWiseTerritorys.keySet()){
            userWiseTerritoryList.put(userId,userWiseTerritorys.get(userId).split('~'));
            setTerritoryIds.addAll(userWiseTerritorys.get(userId).split('~'));
        }
        system.debug('@@setTerritoryIds'+setTerritoryIds);     

        // Get List Of ServiceResource from userId
        List<ServiceResource> listSA=[SELECT ID,RelatedRecordId FROM ServiceResource Where RelatedRecordId = :userWiseTerritoryList.KeySet()];
        Map<String,String> SAwiseUserIdMap=new Map<String,String>();
        for(ServiceResource SA: listSA){
            SAwiseUserIdMap.put(SA.Id,SA.RelatedRecordId);
        }
        Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :setTerritoryIds];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.Id,g.RelatedId);
        }
        List<ServiceResourceShare> removeListSRS=new List<ServiceResourceShare>();
        List<ServiceResourceShare> listSRS=[SELECT ID,UserOrGroupId,parentId from ServiceResourceShare where parentId in :listSA  and UserOrGroupId in :TerritoryWiseGroup.keySet()];
        
        for(ServiceResourceShare SRS :listSRS){
            if(userWiseTerritoryList.containsKey(SAwiseUserIdMap.get(SRS.parentId)) && TerritoryWiseGroup.containsKey(SRS.UserOrGroupId)){
                if(userWiseTerritoryList.get(SAwiseUserIdMap.get(SRS.parentId)).contains(TerritoryWiseGroup.get(SRS.UserOrGroupId))){
                    removeListSRS.add(SRS);
                }
            }
        }
        Database.delete(removeListSRS, false);

    }
    
    public static void updateOpportunityContactOwner(List<UserTerritory2Association> listOldUTA){
        Set<String> territoryIds = new Set<String>();
        Set<String> userIds = new Set<String>();
        Set<String> branchNumbers = new Set<String>();
        for(UserTerritory2Association UTA : listOldUTA){
            territoryIds.add(UTA.Territory2Id);
            userIds.add(UTA.UserId);
        }
        List<Territory2> listTerritory =[SELECT ID, TCBranchNumber__c, ParentTerritory2.TCBranchNumber__c,ParentTerritory2Id, Territory_Type_Name__c FROM Territory2 
                                         WHERE Id IN :territoryIds];
        for(Territory2 TR : listTerritory){
            if(TR.Territory_Type_Name__c=='Branch' && TR.TCBranchNumber__c != null){
                branchNumbers.add(TR.TCBranchNumber__c);
            }
            else if(TR.Territory_Type_Name__c=='Trade' && TR.ParentTerritory2.TCBranchNumber__c != null){
                branchNumbers.add(TR.ParentTerritory2.TCBranchNumber__c);
            }
        }
        
        System.debug('@@Branch : '+branchNumbers);
        
        List<Branch__c> listBranch = [SELECT Id, T_C_Branch_Number__c, Branch_Family__c, Branch_Family__r.Pella_Account_Owner__c FROM Branch__c
                                      WHERE T_C_Branch_Number__c IN :branchNumbers];
        Map<String, Branch__c> mapBranch = new Map<String, Branch__c>();
        for(Branch__c BR : listBranch){
            mapBranch.put(BR.T_C_Branch_Number__c, BR);
        }
        
        for(String brNumber : branchNumbers){
            
            List<Opportunity> oppList = [SELECT Id, OwnerId, Account.Branch_Number__c FROM Opportunity 
                                         WHERE OwnerId IN :userIds AND Account.Branch_Number__c LIKE :'%;'+ brNumber +';%'];
            System.debug('@@oppList : '+oppList.size());
            for(Opportunity opp : oppList){
                if(mapBranch.containsKey(opp.Account.Branch_Number__c)){
                    opp.OwnerId = mapBranch.get(opp.Account.Branch_Number__c).Branch_Family__r.Pella_Account_Owner__c;
                }
            }
            List<Contact> conList = [SELECT Id, OwnerId, Account.Branch_Number__c FROM Contact 
                                     WHERE OwnerId IN :userIds AND Account.Branch_Number__c LIKE :'%;'+ brNumber +';%'];
            System.debug('@@conList : '+conList.size());
            for(Contact con : conList){
                if(mapBranch.containsKey(con.Account.Branch_Number__c)){
                    con.OwnerId = mapBranch.get(con.Account.Branch_Number__c).Branch_Family__r.Pella_Account_Owner__c;
                }
            }
            OpportunityTriggerHandler.Check_Conflict_Overriden=false;
            update oppList;
            update conList;
        }
        
    }
    
}