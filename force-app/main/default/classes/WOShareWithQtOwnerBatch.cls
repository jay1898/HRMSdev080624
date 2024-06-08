global class WOShareWithQtOwnerBatch implements Database.Batchable<sObject>  {
	  global Database.QueryLocator start(Database.BatchableContext BC){
        Id piesRT = Schema.SObjectType.WorkOrder.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        //String sId = '0WO1D000000E93rWAC';
        String query = 'SELECT Id, Quote__r.OwnerId FROM WorkOrder where quote__c != null AND RecordTypeId = :piesRT';
        system.debug('query : ' +  query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WorkOrder> scope) {
        
      	List<WorkOrderShare> listwoshare = new List<WorkOrderShare>(); List<WorkOrderShare> listWOSharewihtGroup = new List<WorkOrderShare>();
		Map<String, String> mapWOIdGrpId = new Map<String, String>();Map<String, String> mapGrpNamGrpId = new Map<String, String>();
		Map<String, String> mapWOIdGrpId2 = new Map<String, String>(); Map<String, String> mapSWOShareId = new Map<String, String>();
        for(workorder wo : scope){
            mapWOIdGrpId.put(wo.Id, wo.Quote__r.OwnerId);
        }

		for(WorkOrderShare wosh :[SELECt Id, ParentId, UserOrGroupId FROM  WorkOrderShare WHERE ParentId IN :mapWOIdGrpId.keySet() 
                          AND  UserOrGroupId IN: mapWOIdGrpId.values()]){
						  
						  String str = String.valueOf(wosh.ParentId) + String.valueOf(wosh.UserOrGroupId) ;
						  mapSWOShareId.put(str, wosh.Id);
		}

		for(String wo :mapWOIdGrpId.keyset()){
            system.debug('WorkOrderRecordShare Line 26 ');
			
			    if(!mapSWOShareId.containskey(String.valueOf(wo) + String.valueOf(mapWOIdGrpId.get(wo)))){
                   	system.debug(' WorkOrderRecordShare Line 30 ');
                    WorkOrderShare woShare = new WorkOrderShare();
            		woShare.ParentId = wo;
            		woShare.UserOrGroupId = mapWOIdGrpId.get(wo);
            		woShare.AccessLevel = 'Edit';
            		woShare.RowCause = 'Manual';
                    listwoshare.add(woShare);
              }
		}
		if(listwoshare.size()>0){
            system.debug('Line 33:'+ listwoshare);
           Database.Insert(listwoshare, false); 
		}
    }
    global void finish(Database.BatchableContext BC) {}
}