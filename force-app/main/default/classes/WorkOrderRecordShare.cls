public class WorkOrderRecordShare {
    
    public static void shareWOwihtQuoteOwner(List<Id> woIds){
       List<WorkOrderShare> listwoshare = new List<WorkOrderShare>();
       List<WorkOrderShare> listWOSharewihtGroup = new List<WorkOrderShare>();
       Map<String, String> mapWOIdGrpId = new Map<String, String>();
       Map<String, String> mapGrpNamGrpId = new Map<String, String>();
       for(WorkOrder wo :[SELECT Id, Quote__r.OwnerId,ServiceTerritory.Name, Quote__r.Opportunity.ownerId FROM WorkOrder where Id IN :woIds]){
            system.debug('WorkOrderRecordShare :' + wo.ServiceTerritory.Name);
           
            WorkOrderShare woShare = new WorkOrderShare();
            woShare.ParentId = wo.Id;
            woShare.AccessLevel = 'Edit';
            woShare.RowCause = 'Manual';
            woShare.UserOrGroupId = wo.Quote__r.OwnerId;
            if(wo.Quote__r.OwnerId != wo.Quote__r.Opportunity.ownerId ){
                WorkOrderShare woSharewithOppOwner = new WorkOrderShare();
           		woSharewithOppOwner.ParentId = wo.Id;
                woSharewithOppOwner.AccessLevel = 'Edit';
                woSharewithOppOwner.RowCause = 'Manual';
                woSharewithOppOwner.UserOrGroupId = wo.Quote__r.Opportunity.ownerId ;
                listwoshare.add(woSharewithOppOwner);
            }
            listwoshare.add(woShare);
            
           
            if(wo.ServiceTerritory.Name != null){
               mapWOIdGrpId.put(wo.Id, wo.ServiceTerritory.Name);
            }
        }
        system.debug('WorkOrderRecordShare :' + mapWOIdGrpId);
        
        //share with territory group
        if(!mapWOIdGrpId.isEmpty()){
             for(Group grp : [SELECT Id, Name FROM Group where Name IN :mapWOIdGrpId.values()]){
            	mapGrpNamGrpId.put(grp.Name,grp.Id);
        	}
        }
       if (!mapGrpNamGrpId.isEmpty()){
            for(WorkOrder wo :[SELECT Id, ServiceTerritory.Name FROM WorkOrder where Id IN :woIds AND ServiceTerritory.Name != null ]){
            system.debug('WorkOrderRecordShare Line 26 ');
            if(mapWOIdGrpId.containsKey(wo.Id)){
                system.debug('WorkOrderRecordShare' + mapWOIdGrpId.get(wo.Id));
                if(mapGrpNamGrpId.containsKey(mapWOIdGrpId.get(wo.Id))){
                   	system.debug(' WorkOrderRecordShare Line 30 ');
                    WorkOrderShare woShare = new WorkOrderShare();
            		woShare.ParentId = wo.Id;
            		woShare.UserOrGroupId = mapGrpNamGrpId.get(mapWOIdGrpId.get(wo.Id));
            		woShare.AccessLevel = 'Edit';
            		woShare.RowCause = 'Manual';
                    listwoshare.add(woShare);
                }
            } 
        }
            
        }
        
	   if(listwoshare.size()>0){
            system.debug('Line 33:'+ listwoshare);
           Database.Insert(listwoshare, false); 
       }
       
    }
 
}