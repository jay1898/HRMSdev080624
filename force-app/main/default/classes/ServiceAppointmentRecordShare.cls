public class ServiceAppointmentRecordShare {
    public static void shareSARecordWithSTM(List<ServiceAppointment> listSA){
        
        List<String> listBranchNumber=new List<String>();
        For(ServiceAppointment SA : listSA){
            listBranchNumber.add(SA.Branch_Number__c);
        }
        
        // Get aa ETM record relate with 
        List<Territory2> listETM =[SELECT ID,ParentTerritory2Id,Territory_Reference_Number__c,Territory_Type_Name__c FROM Territory2 Where  Territory_Type_Name__c='Branch' and  Territory_Reference_Number__c in : listBranchNumber ];
        Map<String,List<Id>> branchNumberWiseETM=new Map<String,List<Id>>();
        List<Id> listTerrirotyIds=new List<Id>();
        for(Territory2 T : listETM){
            
            if(T.Territory_Reference_Number__c!=null){
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
        
      
        List<ServiceAppointmentShare> listSAShare=new list<ServiceAppointmentShare>();
        for(ServiceAppointment sa : listSA){
            Id AORId;
            // Branch Number wise User sharing
            
            if(sa.Branch_Number__c!=null && mapBranchWiseUsers.containsKey(sa.Branch_Number__c)){
                for(Id userId : mapBranchWiseUsers.get(sa.Branch_Number__c)){
                    ServiceAppointmentShare SAS = new ServiceAppointmentShare();
                    SAS.ParentId = sa.Id; 
                    SAS.UserOrGroupId = userId; 
                    SAS.AccessLevel  = 'Edit';
                    SAS.RowCause = 'Manual';
                    listSAShare.add(SAS);
                }
            }
               
        } 
        Database.SaveResult[] srList = Database.insert(listSAShare, false);
        
        //insert listCampShare;
    }
   
    public static void shareSARecordWithSTMFuture(List<String> listSAIds){
        List<ServiceAppointment> listSA=[SELECT ID,Branch_Number__c FROM ServiceAppointment where Id in:listSAIds ];
        shareSARecordWithSTM(listSA);
    }
    
    /**
*   @Method:        piesserviceapptRecordShare
*   @Purpose:       To share the service appointments with sales reps for PIES
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/
    public static void shareSAwihtWOQuoteOwner(Map<String, List<String>> mapwosaIds){
        List<ServiceAppointmentShare> listsashare = new List<ServiceAppointmentShare>();
        Map<String, String> mapWOQouteOwner = new Map<String, String>(); Set<Id> setWOID = new Set<Id>();
        Map<String, String> mapOppOwner = new Map<String, String>();
        List<WorkOrderShare> listwoshare = new List<WorkOrderShare>(); 
        for(WorkOrderLineItem woli :[SELECT Id,workorderId, workOrder.Quote__r.OwnerId,workOrder.Quote__r.Opportunity.ownerId from WorkOrderLineItem where Id IN :mapwosaIds.keySet()]){
            system.debug('Quote Owner : '+ woli.workOrder.quote__r.OwnerId);
            mapWOQouteOwner.put(woli.Id, woli.workOrder.quote__r.ownerId);
            mapOppOwner.put(woli.Id, woli.workOrder.Quote__r.Opportunity.ownerId);
            //setWOID.add(woli.workorderId);
        }
        //loop through WO records
        for(String woliId :mapwosaIds.keySet()){
            system.debug('shareSAwihtWOQuoteOwner ::mapwosaIds : ' + mapwosaIds);
            //if mapWOQouteOwner has above WO as key
            if(mapWOQouteOwner.containskey(woliId)){
                system.debug('shareSAwihtWOQuoteOwner :: mapWOQouteOwner '+ mapWOQouteOwner);
                //loop through all the SA's of the above WO and share each SA
                for(String saId :mapwosaIds.get(woliId) ){
                    system.debug('shareSAwihtWOQuoteOwner :: saId ' + saId);
                    ServiceAppointmentShare saShare = new ServiceAppointmentShare();
                    saShare.ParentId = saId;
                    saShare.UserOrGroupId = mapWOQouteOwner.get(woliId);
                    saShare.AccessLevel = 'Edit';
            		saShare.RowCause = 'Manual';
            		listsashare.add(saShare);
                    if(mapWOQouteOwner.get(woliId) != mapOppOwner.get(woliId)){
                        ServiceAppointmentShare saSharewithOppOwner = new ServiceAppointmentShare();
                        saSharewithOppOwner.ParentId = saId;
                        saSharewithOppOwner.UserOrGroupId = mapOppOwner.get(woliId);
                        saSharewithOppOwner.AccessLevel = 'Edit';
                        saSharewithOppOwner.RowCause = 'Manual';
                        listsashare.add(saSharewithOppOwner);
                    }
                }
            } 
        }
       
        if(listsashare.size()>0){
           Database.Insert(listsashare, false); 
        }
       
        
    }
    
     /**
*   @Method:        shareWORecordWihtLoggedinUser
*   @Purpose:       To share the service appointments WO , with the logged in user who will be scheudling the WO.
*   @Author:        Pallavi (eVerge)
*   @Date:          06/03/2022
*   @TaskSource:    

*   @Updates:       
*/
    public static void shareWORecordWithLoggedinUser(Set<Id> saWOLIId){
        String sUserId = UserInfo.getUserId();
        List<WorkOrderShare> listwoshare = new List<WorkOrderShare>(); 
        Set<String> setWOId = new Set<String>();
        system.debug('saWOLIId :' + saWOLIId);
        for(WOrkOrderLineItem woli : [SELECT Id , workorderId FROM WOrkOrderLineItem where Id IN  :saWOLIId]){
            setWOId.add(woli.WorkOrderId);
        }
        system.debug('shareWORecordWithLoggedinUser :' + setWOId);
        for(String woId : setWOId){
            
                WorkOrderShare woShare = new WorkOrderShare();
                woShare.ParentId = woId;
                woShare.UserOrGroupId = sUserId ;
                woShare.AccessLevel = 'Edit';
            	woShare.RowCause = 'Manual';
            	listwoshare.add(woShare);
        }
        if(listwoshare.size() > 0){
            system.debug('shareWORecordWihtLoggedinUser : ' + listwoshare);
            Database.insert(listwoshare, false) ;
        }
    }
}