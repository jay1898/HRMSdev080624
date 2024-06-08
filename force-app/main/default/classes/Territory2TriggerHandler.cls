public class Territory2TriggerHandler {
    public static void shareSTWithETM(List<Territory2> listTerritory2){
        List<String> listBranchNumber=new List<String>();
        List<String> listBranchFamilyNumber=new List<String>();
        for(Territory2 T : listTerritory2){
            if(T.Territory_Reference_Number__c!=null ){
                if(T.Territory_Type_Name__c=='Branch'  ){
                    listBranchNumber.add(T.Territory_Reference_Number__c);
                }
                else if(T.Territory_Type_Name__c=='Branch_Family' ){
                    listBranchFamilyNumber.add(T.Territory_Reference_Number__c);
                }
            }
        } 
        if(listBranchNumber.size()>0 || listBranchFamilyNumber.size()>0){
            ServiceTerritoryRecordShare.shareSTRecordWithETMUser(listBranchNumber,listBranchFamilyNumber);
            BranchRecordShare.shareBranchRecordWithETMGroupFuture(listBranchNumber);
            CampaignRecordShare.shareCampaignRecordWithETMGroupFuture(listBranchNumber);
        }
    }
    public static void updateShareSTWithETM(List<Territory2> listTerritory2,Map<Id,Territory2> oldMap){
        List<String> listBranchNumber=new List<String>();
        List<String> listBranchFamilyNumber=new List<String>();
        List<String> listRemoveBranchNumber=new List<String>();
        List<String> listRemoveBranchFamilyNumber=new List<String>();
        for(Territory2 T : listTerritory2){
            if(T.Territory_Reference_Number__c!=oldMap.get(T.Id).Territory_Reference_Number__c ){
                if(T.Territory_Type_Name__c=='Branch'  ){
                    listRemoveBranchNumber.add(oldMap.get(T.Id).Territory_Reference_Number__c);
                    listBranchNumber.add(T.Territory_Reference_Number__c);
                }
                else if(T.Territory_Type_Name__c=='Branch_Family' ){
                    listRemoveBranchFamilyNumber.add(oldMap.get(T.Id).Territory_Reference_Number__c);
                    listBranchFamilyNumber.add(T.Territory_Reference_Number__c);
                }
            }
            
        }
        if(listBranchNumber.size()>0 || listBranchFamilyNumber.size()>0){
            ServiceTerritoryRecordShare.updateSTRecordWithETMUser(listRemoveBranchNumber,listRemoveBranchFamilyNumber,listBranchNumber,listBranchFamilyNumber);
            BranchRecordShare.updateBranchRecordWithETMUser(listBranchNumber,listRemoveBranchNumber);
            CampaignRecordShare.updateCampaignRecordWithETMUser(listBranchNumber,listRemoveBranchNumber);
        }
    }
    public static void updateShareSRWithETM(List<Territory2> listTerritory2,Map<Id,Territory2> oldMap){
        List<String> listParentTerritoryIds=new List<String>();
        Map<String,String> listTerritory=new Map<String,String>();
        List<String> listTerritoryIds=new List<String>();
        for(Territory2 T : listTerritory2){
            if(T.ParentTerritory2Id!=oldMap.get(T.Id).ParentTerritory2Id ){
                if(T.Territory_Type_Name__c=='Branch'  ){
                    listParentTerritoryIds.add(T.ParentTerritory2Id);
                    listParentTerritoryIds.add(oldMap.get(T.Id).ParentTerritory2Id);
                    listTerritoryIds.add(T.Id);
                    listTerritory.put(T.Id,T.ParentTerritory2Id+'~'+oldMap.get(T.Id).ParentTerritory2Id);
                }
            }
            
        }
        if(listParentTerritoryIds.size()>0){
            reShareRecordsWithUTA(listParentTerritoryIds,listTerritory,listTerritoryIds);
        }    
    }
    @future 
    public static void reShareRecordsWithUTA(List<String> listParentTerritoryIds,Map<String,String> listTerritory,List<string> listTerritoryIds){
        
        // Get Territory Group By Territory Id
        Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :listParentTerritoryIds];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.RelatedId,g.Id);
        }
        Map<String,List<String>> userWiseTerrToRemove=new Map<String,List<String>>();
        Map<String,List<String>> userWiseTerrToAdd=new Map<String,List<String>>();
        List<UserTerritory2Association> listUTA=[SELECT Id, UserId,Territory2.ParentTerritory2Id,Territory2.ParentTerritory2.ParentTerritory2Id, Territory2.Territory_Type_Name__c, Territory2.Territory_Reference_Number__c, RoleInTerritory2 FROM UserTerritory2Association where Territory2.Territory_Type_Name__c='Replacement' and Territory2.ParentTerritory2Id in :listTerritoryIds];
        for(UserTerritory2Association UTA : listUTA ){
            if(listTerritory.containsKey(UTA.Territory2.ParentTerritory2Id)){
                if(!userWiseTerrToRemove.containsKey(UTA.UserId)){
                    userWiseTerrToRemove.put(UTA.UserId,new List<String>());
                    userWiseTerrToAdd.put(UTA.UserId,new List<String>());
                }
                userWiseTerrToAdd.get(UTA.UserId).add(TerritoryWiseGroup.get(listTerritory.get(UTA.Territory2.ParentTerritory2Id).split('~')[0]));
                userWiseTerrToRemove.get(UTA.UserId).add(TerritoryWiseGroup.get(listTerritory.get(UTA.Territory2.ParentTerritory2Id).split('~')[1]));
                
            }
        }
        Map<String,String> userIdWiseSR=new Map<String,String>(); 
        List<ServiceResource> listSRToRemove= [SELECT ID,RelatedRecordId from ServiceResource where RelatedRecordId in :userWiseTerrToRemove.keySet()];
        for(ServiceResource SR : listSRToRemove){
            userIdWiseSR.put(SR.Id,SR.RelatedRecordId);
        }    
        
        List<ServiceResourceShare> removeListSRS=new List<ServiceResourceShare>();
        for(ServiceResourceShare SRS :[SELECT ID,UserOrGroupId,parentId from ServiceResourceShare where parentId in :listSRToRemove  and UserOrGroupId in :TerritoryWiseGroup.values()]){
            if(userWiseTerrToRemove.containsKey(userIdWiseSR.get(SRS.parentId)) && userWiseTerrToRemove.get(userIdWiseSR.get(SRS.parentId)).contains(SRS.UserOrGroupId)){
                removeListSRS.add(SRS);
            }
        }
        system.debug('@@'+removeListSRS);
        Database.delete(removeListSRS, false);
        List<ServiceResourceShare> addListSRS=new List<ServiceResourceShare>();
        for(ServiceResource SR :  [SELECT ID,RelatedRecordId from ServiceResource where RelatedRecordId in :userWiseTerrToAdd.keySet()]){
            if(userWiseTerrToAdd.containsKey(SR.RelatedRecordId)){
                for(String groupId : userWiseTerrToAdd.get(SR.RelatedRecordId)){
                    ServiceResourceShare SRSNew=new ServiceResourceShare(); 
                    SRSNew.parentId = SR.Id; 
                    SRSNew.UserOrGroupId = groupId; 
                    SRSNew.AccessLevel  = 'Edit';
                    SRSNew.RowCause = 'Manual';
                    addListSRS.add(SRSNew);
                }
                
            }
        }
        system.debug('@@'+addListSRS);
         Database.insert(addListSRS, false);
        
    }
    
}