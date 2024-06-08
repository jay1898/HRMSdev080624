global class WOShareWithSTPublicGroupBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        Id piesRT = Schema.SObjectType.WorkOrder.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        //String sId = '0WO1D000000E93rWAC';
        String query = 'SELECT Id,ServiceTerritory.Name, ServiceTerritoryId FROM WorkOrder where ServiceTerritoryId != null ORDER BY Id,ServiceTerritoryId';
        system.debug('query : ' +  query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WorkOrder> scope) {
        
        Map<String, String> mapWOIdGrpId = new Map<String, String>();Map<String, String> mapWOIdGrpId2 = new Map<String, String>();
        Map<String, String> mapGrpNamGrpId = new Map<String, String>();Map<String, String> mapSWOShareId = new Map<String, String>();
		List<WorkOrderShare> listwoshare = new List<WorkOrderShare>(); 
        //from the scope , get the wo id and ST name and ST Id
        for(WorkOrder wo : scope){
             mapWOIdGrpId.put(wo.Id, wo.ServiceTerritory.Name);
		}
        //system.debug('mapWOIdGrpId: ' + mapWOIdGrpId);
        //get the group name and group id for above ST id's
        for(Group grp : [SELECT Id, Name FROM Group where Name IN :mapWOIdGrpId.values()]){
            mapGrpNamGrpId.put(grp.Name,grp.Id);
		}

        for(WorkOrderShare wosh :[SELECT Id, ParentId, UserOrGroupId FROM  WorkOrderShare WHERE ParentId IN :mapWOIdGrpId.keySet() 
                                  AND UserOrGroupId IN: mapGrpNamGrpId.values()]){
						  
						  String str = String.valueOf(wosh.ParentId) + String.valueOf(wosh.UserOrGroupId) ;
						  mapSWOShareId.put(str, wosh.Id);
		}
        //check if WO is already shared with WO's ST
        for(String wo :mapWOIdGrpId.keyset()){
            if(mapGrpNamGrpId.containsKey(mapWOIdGrpId.get(wo))){
                //if WO share does not contain any record with combination wo+wo.st
                String sWO = wo + String.valueOf(mapGrpNamGrpId.get(mapWOIdGrpId.get(wo)));
                if(!mapSWOShareId.containskey(sWO)){
                    system.debug('Line 41');
                   	WorkOrderShare woShare = new WorkOrderShare();
            		woShare.ParentId = wo;
            		woShare.UserOrGroupId = mapGrpNamGrpId.get(mapWOIdGrpId.get(wo));
            		woShare.AccessLevel = 'Edit';
            		woShare.RowCause = 'Manual';
                    listwoshare.add(woShare);
            	}    
            }
        }
        if(listwoshare.size()>0){
            system.debug('listwoshare.size() : '+ listwoshare.size());
            Database.insert(listwoshare, false);
        }
    }
    global void finish(Database.BatchableContext BC) {}
}