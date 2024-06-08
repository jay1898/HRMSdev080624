public class ServiceResourceTriggerHandler {
    
     public void BeforeInsert(List<ServiceResource> newItems) {
         /**02/18/22 Pallavi, getting the PIES recordtypeId so that sales code is not triggered for PIES***/
         Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
         set<Id> setBranchId=new set<Id>();
         // assign rank to newly create record
         for(ServiceResource SR : newItems){
             if(SR.Replacement_Sales_Rep__c==true &&  SR.IsActive==true && SR.Primary_Branch_Family__c!=null && SR.RecordTypeId != srRTId  ){
                 setBranchId.add(SR.Primary_Branch_Family__c);
             }
         }
         Map<Id,Decimal> branchWiseMaxResource=new Map<Id,Decimal>();
         List<AggregateResult> AggregateResultList = [select Primary_Branch_Family__c,Max(Ranker__c) Ranker from ServiceResource where Primary_Branch_Family__c in :setBranchId group by Primary_Branch_Family__c]; 
         if(AggregateResultList != null && AggregateResultList.size() > 0){ 
             for(AggregateResult aggr:AggregateResultList){     
                 branchWiseMaxResource.put((id)aggr.get('Primary_Branch_Family__c'),(Decimal)aggr.get('Ranker')!=null?(Decimal)aggr.get('Ranker'):0);
             } 
         }
         
         for(ServiceResource SR : newItems){  
             if(SR.Replacement_Sales_Rep__c==true && SR.IsActive==true && SR.Primary_Branch_Family__c!=null && SR.RecordTypeId != srRTId ){
                 if(!branchWiseMaxResource.containsKey(SR.Primary_Branch_Family__c)){
                     branchWiseMaxResource.put(SR.Primary_Branch_Family__c,0);
                 }
                 SR.Ranker__c=branchWiseMaxResource.get(SR.Primary_Branch_Family__c)+1;
                 branchWiseMaxResource.put(SR.Primary_Branch_Family__c,(Decimal)(SR.Ranker__c));
             }
         }
         
     }
     public void BeforeUpdate(List<ServiceResource> newItems,Map<Id, ServiceResource> newItemMap, Map<Id, ServiceResource> oldItems){
        
         // check rank already exist
         set<Decimal> updatedNewRank=new set<Decimal>();
         set<Decimal> oldRank=new set<Decimal>();
         set<Id> oldRankIds=new set<Id>();
         set<Id> setBranchUpdateSRIds=new set<Id>();
         
         /**02/18/22 Pallavi, getting the PIES recordtypeId so that sales code is not triggered for PIES***/
         Id sreRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
         
         
         // Check Resource Exist as primary Territory or not
         List<String> resourceExistAsPriTer=new list<String>();
         List<String> resourceExistAsTer=new list<String>();
         List<ServiceTerritoryMember> listSTM=[SELECT Id,ServiceResourceId,TerritoryType FROM ServiceTerritoryMember 
                                               Where ServiceResourceId =:newItems AND ServiceResource.RecordTypeId != :sreRTId];
         for(ServiceTerritoryMember STM : listSTM){
             if(STM.TerritoryType=='P'){
                 resourceExistAsPriTer.add(STM.ServiceResourceId);
             }
             resourceExistAsTer.add(STM.ServiceResourceId);
         }
         
         for(ServiceResource SR : newItems){
             if(SR.Replacement_Sales_Rep__c==true && oldItems.get(SR.Id).IsActive!=false && SR.IsActive==true && SR.Primary_Branch_Family__c!=null && oldItems.get(SR.Id).Ranker__c !=SR.Ranker__c  && SR.Ranker__c!=null && SR.RecordTypeId != sreRTId ){
                 updatedNewRank.add(SR.Ranker__c);
                 oldRank.add(((ServiceResource)(oldItems).get(SR.Id)).Ranker__c );
                 oldRankIds.add(SR.Id);
             }
             if(SR.Replacement_Sales_Rep__c==true && SR.RecordTypeId != sreRTId && (((ServiceResource)(oldItems).get(SR.Id)).IsActive!=false && SR.IsActive==true && SR.Primary_Branch_Family__c!=null && SR.Ranker__c==null  ) ){
                 SR.addError(System.Label.Ranking_Mandatory,false);
             }
             if(SR.Primary_Branch_Family__c!=null && SR.RecordTypeId != sreRTId  && oldItems.get(SR.Id).Primary_Branch_Family__c!=SR.Primary_Branch_Family__c  ){
                 setBranchUpdateSRIds.add(SR.Id);
             }
             // check resource exist as primary territory
             if(resourceExistAsTer.contains(SR.Id) && !resourceExistAsPriTer.contains(SR.Id) && SR.RecordTypeId != sreRTId ){
                 SR.addError(System.Label.Primary_Sales_Resource_Error,false);
             }
         }
         
         // Commented on 09-02 remove STM validation because of branch field change to primary branch family 
         /* //A user cannot change the Primary_Branch_Family__c field on a Service Resource unless all related ServiceTerritoryMember records are deleted (Count = 0).
         Map<Id,Decimal> ServiceResourceWiseMaxAllocation=new Map<Id,Decimal>();
         List<AggregateResult> AggregateSRList = [Select COUNT(Id) total,ServiceResourceId FROM ServiceTerritoryMember where ServiceResourceId In :setBranchUpdateSRIds Group By ServiceResourceId]; 
         if(AggregateSRList != null && AggregateSRList.size() > 0){ 
             for(AggregateResult aggr:AggregateSRList){             
                 ServiceResourceWiseMaxAllocation.put((id)aggr.get('ServiceResourceId'),(Decimal)aggr.get('Total')!=null?(Decimal)aggr.get('Total'):0);
             } 
         }
         for(ServiceResource SR : newItems){
             if(setBranchUpdateSRIds.contains(SR.Id) && ServiceResourceWiseMaxAllocation.containsKey(SR.Id) && ServiceResourceWiseMaxAllocation.get(SR.Id)>0){
                 SR.addError(System.Label.Branch_Change_Message,false);
             }
         }*/
         
         Map<String,Id> rankWiseRec=new Map<String,Id>();
         Map<String,String> idWiseName=new Map<String,String>();
         List<ServiceResource> listResource=[select Id,Name,Primary_Branch_Family__c,Ranker__c from ServiceResource where Replacement_Sales_Rep__c=true and  Ranker__c in :updatedNewRank and Id not in :oldRankIds  AND RecordTypeId != :sreRTId];
         for(ServiceResource SRRec:listResource){
             rankWiseRec.put(SRRec.Primary_Branch_Family__c+String.valueOf(SRRec.Ranker__c),SRRec.Id);
             idWiseName.put(SRRec.Primary_Branch_Family__c+String.valueOf(SRRec.Ranker__c),SRRec.Name);
         }
         
         for(ServiceResource SR : newItems){
             if(SR.Replacement_Sales_Rep__c==true && SR.RecordTypeId != sreRTId && oldItems.get(SR.Id).IsActive!=false && SR.IsActive==true && SR.Primary_Branch_Family__c!=null && oldItems.get(SR.Id).Ranker__c !=SR.Ranker__c && SR.Ranker__c!=null ){
                 if(rankWiseRec.containsKey(SR.Primary_Branch_Family__c+String.valueOf(SR.Ranker__c))){
                     // check rank already exist
                     SR.addError(System.Label.Duplicate_Ranking.replace(':Param1',idWiseName.get(SR.Primary_Branch_Family__c+String.valueOf(SR.Ranker__c))),false);
                                
                 }else{
                     idWiseName.put(SR.Primary_Branch_Family__c+String.valueOf(SR.Ranker__c),SR.Name);
                 }
             }
         }
         
         // update rank to blank if user get inactive and assign if active again
         set<Id> setBranchId=new set<Id>();
         
         for(ServiceResource SR : newItems){
             if(SR.Replacement_Sales_Rep__c==true && SR.RecordTypeId != sreRTId && oldItems.get(SR.Id).IsActive==false &&  SR.IsActive==true && SR.Primary_Branch_Family__c!=null  ){
                 setBranchId.add(SR.Primary_Branch_Family__c);
             }
             else if(SR.Replacement_Sales_Rep__c==true && SR.RecordTypeId != sreRTId && SR.IsActive==true && SR.Primary_Branch_Family__c!=null  && oldItems.get(SR.Id).Primary_Branch_Family__c!=SR.Primary_Branch_Family__c  ){
                 setBranchId.add(SR.Primary_Branch_Family__c);
             }
             if(SR.Replacement_Sales_Rep__c==true && SR.IsActive==false && SR.RecordTypeId != sreRTId){
                 SR.Ranker__c=null;
             }
         }
         Map<Id,Decimal> branchWiseMaxResource=new Map<Id,Decimal>();
         List<AggregateResult> AggregateResultList = [select Primary_Branch_Family__c,Max(Ranker__c) Ranker from ServiceResource where Primary_Branch_Family__c in :setBranchId group by Primary_Branch_Family__c]; 
         if(AggregateResultList != null && AggregateResultList.size() > 0){ 
             for(AggregateResult aggr:AggregateResultList){             
                 branchWiseMaxResource.put((id)aggr.get('Primary_Branch_Family__c'),(Decimal)aggr.get('Ranker')!=null?(Decimal)aggr.get('Ranker'):0);
             } 
         }
         
          for(ServiceResource SR : newItems){
              if(SR.Replacement_Sales_Rep__c==true && SR.RecordTypeId != sreRTId && oldItems.get(SR.Id).IsActive==false &&  SR.IsActive==true && SR.Primary_Branch_Family__c!=null  ){
                  if(!branchWiseMaxResource.containsKey(SR.Primary_Branch_Family__c)){
                     branchWiseMaxResource.put(SR.Primary_Branch_Family__c,0);
                 }
                 SR.Ranker__c=branchWiseMaxResource.get(SR.Primary_Branch_Family__c)+1;
                 branchWiseMaxResource.put(SR.Primary_Branch_Family__c,(Decimal)(SR.Ranker__c));
             }
             else if(SR.Replacement_Sales_Rep__c==true && SR.RecordTypeId != sreRTId && SR.IsActive==true && SR.Primary_Branch_Family__c!=null  && oldItems.get(SR.Id).Primary_Branch_Family__c!=SR.Primary_Branch_Family__c  ){
                 if(!branchWiseMaxResource.containsKey(SR.Primary_Branch_Family__c)){
                     branchWiseMaxResource.put(SR.Primary_Branch_Family__c,0);
                 }
                 SR.Ranker__c=branchWiseMaxResource.get(SR.Primary_Branch_Family__c)+1;
                 branchWiseMaxResource.put(SR.Primary_Branch_Family__c,(Decimal)(SR.Ranker__c));
             }
         }
         
     }
     public void BeforeDelete(Map<Id, SObject> oldItems) {}
     public void AfterInsert(List<ServiceResource> newItems) {
         ServiceResourceTriggerHandler.shareServiceResourceWithETM(newItems);
     }
     public void AfterUpdate(List<Sobject> newItems,Map<Id, SObject> newItemMap, Map<Id, SObject> oldItems) {}
     public void AfterDelete(Map<Id, SObject> oldItems) {}
     public void AfterUndelete(Map<Id, SObject> oldItems) {}

    public static void shareServiceResourceWithETM(List<ServiceResource> listSR){
        /**02/18/22 Pallavi, getting the PIES recordtypeId so that sales code is not triggered for PIES***/
        Id sreRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        try{
        List<Id> listUserId=new List<Id>();
        for(ServiceResource SR : listSR){
            if(SR.RecordTypeId != sreRTId){
                listUserId.add(SR.RelatedRecordId);
            }
        }
        
        if(listUserId.size() >0){
            
            List<UserTerritory2Association> listUTA=[SELECT Id, UserId,Territory2.ParentTerritory2Id,Territory2.ParentTerritory2.ParentTerritory2Id, Territory2.Territory_Type_Name__c, Territory2.Territory_Reference_Number__c, RoleInTerritory2 FROM UserTerritory2Association where UserId in :listUserId];
        	Map<String,Set<String>> userWiseTerritoryList=new Map<String,Set<String>>();
        	List<String> listParentTerritoryId=new List<String>();
        	for(UserTerritory2Association UTA : listUTA){
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
        
        // Share SA record With related parent Territory User
        List<ServiceResourceShare> lisSRS=new List<ServiceResourceShare>();
        for(ServiceResource SRS : listSR){
            if(userWiseTerritoryList.containsKey(SRS.RelatedRecordId) ){
                for(String TerritoryId : userWiseTerritoryList.get(SRS.RelatedRecordId)){
                    ServiceResourceShare SRSNew=new ServiceResourceShare(); 
                    SRSNew.parentId = SRS.Id; 
                    SRSNew.UserOrGroupId = TerritoryWiseGroup.get(TerritoryId); 
                    SRSNew.AccessLevel  = 'Edit';
                    SRSNew.RowCause = 'Manual';
                    lisSRS.add(SRSNew);
                }
            }
        }
        
        if(lisSRS.size()>0){
            Database.SaveResult[] srList = Database.insert(lisSRS, false);	
            // insert lisSRS;
        }
                
       }    
    }catch(Exception ex){
            system.debug('@@'+ex);
        }
    }
    
 /**
*   @Method:        CreateUserTerritoryforBranchFamilyTerritories
*   @Purpose:       When ever a resource is flagged as manager or PC, then create user territory records for
					all the branch territories that belong to Primary Branch Famliy mapped or to Branch on resource
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/
    
    public static void CreateUserTerritoryforBranchFamilyTerritories(List<ServiceResource> srs, Map<Id, ServiceResource> oldMap){
        
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Id stRTId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('OV_Install_Territory').getRecordTypeId();
		Set<Id> setBranchFamilyId = new Set<Id>();
        Set<Id> setBranchId = new Set<Id>();
        Map<String, ServiceResource> mapSrIdSr = new Map<String, ServiceResource>();
        Map<String, List<String>> mapBrFmIdSTId = new Map<String, List<String>>();
        Map<String, List<String>> mapBrIdSTId = new Map<String, List<String>>();
        List<FSL__User_Territory__c> insertUserTerritory = new List<FSL__User_Territory__c>();
        
        for(ServiceResource sr : srs){
         	//for new records
            if(oldMap == null && sr.RecordTypeId == srRTId && sr.IsActive == TRUE &&
               (sr.Project_Coordinator__c == TRUE || sr.Manager__c == TRUE)){
                   mapSrIdSr.put(sr.Id, sr);
                   if(sr.Primary_Branch_Family__c != null){setBranchFamilyId.add(sr.Primary_Branch_Family__c);}
                   else if(sr.Branch__c != null){setBranchId.add(sr.Branch__c);}
            }
            //for existing records
            if(oldMap != null && sr.RecordTypeId == srRTId && sr.IsActive == TRUE && 
               ((sr.Primary_Branch_Family__c != oldMap.get(sr.Id).Primary_Branch_Family__c) || 
                (sr.Branch__c != oldMap.get(sr.Id).Branch__c))){
                if(sr.Project_Coordinator__c == TRUE || sr.Manager__c == TRUE){
                    mapSrIdSr.put(sr.Id, sr);
                    if(sr.Primary_Branch_Family__c != null){setBranchFamilyId.add(sr.Primary_Branch_Family__c);}
                    else if(sr.Branch__c != null){ setBranchId.add(sr.Branch__c);}
                    system.debug('setBranchFamilyId :' +  setBranchFamilyId + '::' + 'setBranchId : ' + setBranchId);
                 }
            }
        }
        for(ServiceTerritory st :[SELECT Id,Branch__c,Branch__r.Branch_Family__c FROM ServiceTerritory WHERE RecordTypeId =:stRTId AND IsActive = TRUE AND ((Branch__r.Branch_Family__c IN :setBranchFamilyId) OR (Branch__c IN :setBranchId))]){
            if(st.Branch__r.Branch_Family__c != null){
                 if(!mapBrFmIdSTId.containsKey(st.Branch__r.Branch_Family__c)){
                 	mapBrFmIdSTId.put(st.Branch__r.Branch_Family__c, new list<String>{st.Id} );
            	}
            	else {mapBrFmIdSTId.get(st.Branch__r.Branch_Family__c).add(st.Id);}
            }
            if(st.Branch__c != null){
                if(!mapBrIdSTId.containsKey(st.Branch__c)){
                	mapBrIdSTId.put(st.Branch__c, new list<String>{st.Id});
            	}
                 else { mapBrIdSTId.get(st.Branch__c).add(st.Id);  }
            }
       }
        system.debug('mapBrIdSTId :' +  mapBrIdSTId + '::' + 'mapBrFmIdSTId : ' + mapBrFmIdSTId);
        for(ServiceResource sr : mapSrIdSr.values()){
         	if(mapBrFmIdSTId.containsKey(sr.Primary_Branch_Family__c)){
                for(String stid :mapBrFmIdSTId.get(sr.Primary_Branch_Family__c)){
                    system.debug('ServiceResourceTriggerHandler :: CreateUserTerritoryforBranchFamilyTerritories :: BranchFamily' +  stid);
                    FSL__User_Territory__c userTerr = new FSL__User_Territory__c();
                    userTerr.FSL__ServiceTerritory__c = stid;
                    userTerr.FSL__User__c = sr.RelatedRecordId ;
                    insertUserTerritory.add(userTerr);
                }
            }
            else if(mapBrIdSTId.containsKey(sr.Branch__c)){
                for(String stid :mapBrIdSTId.get(sr.Branch__c)){
                    system.debug('ServiceResourceTriggerHandler :: CreateUserTerritoryforBranchFamilyTerritories :: Branch' +  stid);
                    FSL__User_Territory__c userTerr = new FSL__User_Territory__c();
                    userTerr.FSL__ServiceTerritory__c = stid;
                    userTerr.FSL__User__c = sr.RelatedRecordId ;
                    insertUserTerritory.add(userTerr);
                }
            }
         }
        if(insertUserTerritory.size()>0){
           system.debug('ServiceResourceTriggerHandler :: CreateUserTerritoryforBranchFamilyTerritories :: Branch or BranchFamily' + insertUserTerritory);
           INSERT insertUserTerritory; 
        }
    }
 /**
*   @Method:        DeleteUserTerritoryforBranchTerritories
*   @Purpose:       When ever Primary Branch Family or branch is updated then delete the previous user territories 
					to which the resource was part of.
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/
    public static void DeleteUserTerritoryforBranchTerritories(List<ServiceResource> srs,Map<Id, ServiceResource> oldMap){
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
       	Id stRTId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('OV_Install_Territory').getRecordTypeId();
        Set<String> setOldBranchFmId = new Set<String>();
        Set<String> setOldResId = new Set<String>();
        Set<String> setOldBrFmIdSTId = new Set<String>();
        List<FSL__User_Territory__c> listDeleteOldUserTerrMapping = new List<FSL__User_Territory__c>();
        string oldBranchFmId = ''; string oldBranchId = '';
        for(ServiceResource sr: srs){
            if(oldMap != null && sr.RecordTypeId == srRTId && sr.IsActive == TRUE && (sr.Project_Coordinator__c == TRUE || sr.Manager__c == TRUE)
               && ((sr.Primary_Branch_Family__c != oldMap.get(sr.Id).Primary_Branch_Family__c) || (sr.Branch__c != oldMap.get(sr.Id).Branch__c))){
               
                   if(oldMap.get(sr.Id).Primary_Branch_Family__c != null){
                      oldBranchFmId = oldMap.get(sr.Id).Primary_Branch_Family__c ; 
                   }    
                   else if(oldMap.get(sr.Id).Branch__c != null){
                       oldBranchFmId = oldMap.get(sr.Id).Branch__c ;
                   }	
              	setOldBranchFmId.add(oldBranchFmId) ;
               	setOldResId.add(sr.RelatedRecordId);
            }
        }
        system.debug('Line 281 :' + setOldBranchFmId + ' :: ' + setOldResId);
        for(ServiceTerritory st :[SELECT Id,Branch__c, Branch__r.Branch_Family__c FROM ServiceTerritory WHERE RecordTypeId =:stRTId AND ((Branch__r.Branch_Family__c IN :setOldBranchFmId) OR (Branch__c IN :setOldBranchFmId))]){
			setOldBrFmIdSTId.add(st.Id);
        }
        system.debug('Line 285 :' + setOldBrFmIdSTId );
        for(FSL__User_Territory__c userTerr :[SELECT Id FROM FSL__User_Territory__c where FSL__ServiceTerritory__c IN :setOldBrFmIdSTId AND FSL__User__c IN :setOldResId]){
            listDeleteOldUserTerrMapping.add(userTerr);
        }
        system.debug('Line 289 :' + listDeleteOldUserTerrMapping );
        if(listDeleteOldUserTerrMapping.size()>0){
            system.debug('Line 291: ' + listDeleteOldUserTerrMapping);
            DELETE listDeleteOldUserTerrMapping;
        }
    }
    
/**
*   @Method:        CreateSTMforSquaresetResouces
*   @Purpose:       If a resource is of group Squareset and primary branch family or branch is not null then 
					create service territroy member record for all the territories that fall under the PBF or branch.
                    If that resource has a primary STM record then all the other STM records will be created as sceondary 
                    else the first STM record will be Primary and others will be secondary.
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/    
    
     public static void CreateSTMforSquaresetResouces(List<ServiceResource> srs, Map<Id, ServiceResource> oldMap){
        
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Id stRTId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('OV_Install_Territory').getRecordTypeId();
		Set<Id> setBranchFamilyId = new Set<Id>(); Set<Id> setBranchId = new Set<Id>();
        Set<Id> setSTIds = new Set<Id>();
		Map<String, ServiceResource> mapSrIdSr = new Map<String, ServiceResource>(); 
        Map<String, List<String>> mapBrFmIdSTId = new Map<String, List<String>>(); Map<String, List<String>> mapBrIdSTId = new Map<String, List<String>>();
        Map<String, String> mapSTMSrStId = new Map<String, String>(); Map<String, String> mapSTMSrBrId = new Map<String, String>();
        Set<String> setSRId = new Set<String>();
        List<ServiceTerritoryMember> listSTM = new List<ServiceTerritoryMember>();
         
        for(ServiceResource sr : srs){
            //for new records
            if(oldMap == null && sr.RecordTypeId == srRTId && sr.IsActive == TRUE && sr.Installer__c == TRUE && sr.Resource_Group__c == 'Squareset'){ 
                mapSrIdSr.put(sr.Id, sr); 
                if(sr.Primary_Branch_Family__c != null ){setBranchFamilyId.add(sr.Primary_Branch_Family__c);}
                else if (sr.Branch__c != null){ setBranchId.add(sr.Branch__c);}    
                system.debug('CreateSTMforSquaresetResouces : ' + 'setBranchFamilyId : ' + setBranchFamilyId + '::' + 'setBranchId : ' + setBranchId);
             }
            //for existing records
             if(oldMap != null && sr.RecordTypeId == srRTId && sr.IsActive == TRUE && sr.Installer__c == TRUE && 
                ((sr.Primary_Branch_Family__c != oldMap.get(sr.Id).Primary_Branch_Family__c) || (sr.Branch__c != oldMap.get(sr.Id).Branch__c)) && sr.Resource_Group__c == 'Squareset' ){
                   mapSrIdSr.put(sr.Id, sr); 
                   if(sr.Primary_Branch_Family__c != null){setBranchFamilyId.add(sr.Primary_Branch_Family__c);}
                   else if(sr.Branch__c != null){setBranchId.add(sr.Branch__c);}
                   system.debug('CreateSTMforSquaresetResouces : ' + 'setBranchFamilyId : ' + setBranchFamilyId + '::' + 'setBranchId : ' + setBranchId);
             }
       }
       //get the ST for above branch family or Branch
       for(ServiceTerritory st :[SELECT Id,Branch__c,Branch__r.Branch_Family__c FROM ServiceTerritory WHERE 
                                 RecordTypeId =:stRTId AND IsActive = TRUE AND Type__c = 'Install' AND 
                                 ((Branch__r.Branch_Family__c IN :setBranchFamilyId) OR (Branch__c IN :setBranchId))]){
                        if(st.Branch__r.Branch_Family__c != null){
                            if(!mapBrFmIdSTId.containsKey(st.Branch__r.Branch_Family__c)){
              					mapBrFmIdSTId.put(st.Branch__r.Branch_Family__c, new list<String>{st.Id} );
            				}
            				else {mapBrFmIdSTId.get(st.Branch__r.Branch_Family__c).add(st.Id);}
                        }
                        if(st.Branch__c != null){
                			if(!mapBrIdSTId.containsKey(st.Branch__c)){
                				mapBrIdSTId.put(st.Branch__c, new list<String>{st.Id});
            				}
                 	   		else { mapBrIdSTId.get(st.Branch__c).add(st.Id);  }
            		   }
         }
         system.debug('CreateSTMforSquaresetResouces : '+ 'mapBrFmIdSTId : ' + mapBrFmIdSTId + '::' + 'mapBrIdSTId :' + mapBrIdSTId );
         DateTime stoday = system.now();
         for(ServiceTerritoryMember stm :[SELECT Id, ServiceTerritoryId, ServiceTerritory.Branch__r.Branch_Family__c ,
                                          ServiceTerritory.Branch__c, ServiceResourceId FROM ServiceTerritoryMember WHERE 
                                          ServiceResourceId IN :mapSrIdSr.keyset() AND TerritoryType = 'P' AND 
                                          (EffectiveEndDate = null OR EffectiveEndDate >= :stoday ) ] ){
               mapSTMSrStId.put(stm.ServiceResourceId, stm.ServiceTerritory.Branch__r.Branch_Family__c );
             
         }
         system.debug('CreateSTMforSquaresetResouces : '+ 'mapSTMSrStId : ' + mapSTMSrStId + 'mapSTMSrBrId :' + mapSTMSrBrId);
          for(ServiceResource sr : mapSrIdSr.values()){
              system.debug('sr.Primary_Branch_Family__c :' + sr.Primary_Branch_Family__c);
              //if primary branch family is found
               if(mapBrFmIdSTId.containsKey(sr.Primary_Branch_Family__c)){
                    system.debug('Line 388');
                    if(mapSTMSrStId.containskey(sr.Id)){
                        //if resource has primary STM then created all STM's as secondary
                        for(String stid :mapBrFmIdSTId.get(sr.Primary_Branch_Family__c)){
                      		system.debug('CreateSTMforSquaresetResouces : for Prim SR present ' + 'stid : ' + stid);
                        	ServiceTerritoryMember stm = new ServiceTerritoryMember();
                        	stm.ServiceTerritoryId = stid ;
                        	stm.ServiceResourceId = sr.Id;
                        	stm.TerritoryType = 'S';
                        	stm.EffectiveStartDate = system.now();
                        	listSTM.add(stm);
                   		}	
                    }
                   else {
                        //if resource does not have primary STM then create 1st STM has Primary and other STM as secondary.
						 for(String stid :mapBrFmIdSTId.get(sr.Primary_Branch_Family__c)){
                      		system.debug('CreateSTMforSquaresetResouces : ' + 'stid : ' + stid);
                        	ServiceTerritoryMember stm = new ServiceTerritoryMember();
                        	stm.ServiceTerritoryId = stid ;
                        	stm.ServiceResourceId = sr.Id;
                            if(!setSRId.contains(sr.id)){
                                 stm.TerritoryType = 'P';
                             } 
                        	else stm.TerritoryType = 'S';
                        	stm.EffectiveStartDate = system.now();
                        	listSTM.add(stm);
                            setSRId.add(sr.Id);
                   		}	                       		
                   }
               }
               //if branch is found
               else if(mapBrIdSTId.containsKey(sr.Branch__c)){
                    system.debug('Line 388');
                    if(mapSTMSrStId.containskey(sr.Id)){
                        for(String stid :mapBrIdSTId.get(sr.Branch__c)){
                      		system.debug('CreateSTMforSquaresetResouces : for Prim SR present ' + 'stid : ' + stid);
                        	ServiceTerritoryMember stm = new ServiceTerritoryMember();
                        	stm.ServiceTerritoryId = stid ;
                        	stm.ServiceResourceId = sr.Id;
                        	stm.TerritoryType = 'S';
                        	stm.EffectiveStartDate = system.now();
                        	listSTM.add(stm);
                   		}	
                    }
                   else {
						 for(String stid :mapBrIdSTId.get(sr.Branch__c)){
                      		system.debug('CreateSTMforSquaresetResouces : ' + 'stid : ' + stid);
                        	ServiceTerritoryMember stm = new ServiceTerritoryMember();
                        	stm.ServiceTerritoryId = stid ;
                        	stm.ServiceResourceId = sr.Id;
                            if(!setSRId.contains(sr.id)){
                                 stm.TerritoryType = 'P';
                             } 
                        	else stm.TerritoryType = 'S';
                        	stm.EffectiveStartDate = system.now();
                        	listSTM.add(stm);
                            setSRId.add(sr.Id);
                   		}	                       		
                   }
               }
          }
          if(listSTM.size() >0){
             system.debug('listSTM: '+ listSTM);
             INSERT listSTM ;
         }
     }
    
 /**
*   @Method:        DeleteSTMForSquareSet
*   @Purpose:       If primary branch family or branch is changed then delete the STM Records created for 
					old primary branch family or branch
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/
    
     public static void DeleteSTMForSquareSet(List<ServiceResource> srs,Map<Id, ServiceResource> oldMap){
         Id stRTId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('OV_Install_Territory').getRecordTypeId();
         Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
         Set<String> setOldBranchFmId = new Set<String>();
         Set<String> setOldResId = new Set<String>();
         Set<String> setOldBrFmIdSTId = new Set<String>(); string oldBranchId ;
         List<ServiceTerritoryMember> deleteSTM = new List<ServiceTerritoryMember>();
         for(ServiceResource sr: srs){
         	 if(oldMap != null && ((sr.Primary_Branch_Family__c != oldMap.get(sr.Id).Primary_Branch_Family__c) || (sr.Branch__c != oldMap.get(sr.Id).Branch__c)) 
                && sr.RecordTypeId == srRTId && sr.IsActive == TRUE && sr.Installer__c == TRUE && sr.Resource_Group__c == 'Squareset'){
                    
                    if(oldMap.get(sr.Id).Primary_Branch_Family__c != null){
                        oldBranchId = oldMap.get(sr.Id).Primary_Branch_Family__c ; 
                    }
                    else if(oldMap.get(sr.Id).Branch__c != null){
                       oldBranchId = oldMap.get(sr.Id).Branch__c ; 
                    }
               		system.debug('DeleteSTMForSquareSet :' + oldBranchId + 'New Br :' + sr.Primary_Branch_Family__c); 
               		setOldBranchFmId.add(oldBranchId) ;
               		setOldResId.add(sr.Id);
        	 }
         }   
         system.debug('DeleteSTMForSquareSet :' + setOldBranchFmId + ' :: ' + setOldResId);
         for(ServiceTerritory st :[SELECT Id,Branch__c, Branch__r.Branch_Family__c FROM ServiceTerritory WHERE 
                                   ((Branch__r.Branch_Family__c IN :setOldBranchFmId) OR (Branch__c IN :setOldBranchFmId)) 
                                   AND RecordTypeId =:stRTId AND Type__c = 'Install']){
			setOldBrFmIdSTId.add(st.Id);
        }
        system.debug('DeleteSTMForSquareSet:' + 'setOldBrFmIdSTId: ' + ' :: ' + setOldBrFmIdSTId);
        for(ServiceTerritoryMember stm :[SELECT Id FROM ServiceTerritoryMember WHERE ServiceTerritoryId IN :setOldBrFmIdSTId 
                                          AND ServiceResourceId IN :setOldResId ]){
                                              deleteSTM.add(stm);
             
         } 
         system.debug('DeleteSTMForSquareSet:' + 'deleteSTM: ' + ' :: ' + deleteSTM);
         if(deleteSTM.size()>0)
         {DELETE deleteSTM ;}
  }
}