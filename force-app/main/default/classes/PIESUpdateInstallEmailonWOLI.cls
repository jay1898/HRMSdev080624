global class PIESUpdateInstallEmailonWOLI implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /* String wt = 'Install' ; //String sId = '1WL1D000000F6UfWAK';//1WL1D000000F6QrWAK
        String query = 'SELECT Id,Work_Type_s_Schedule_Type__c , Primary_Installer__c, Installer_Payout_Email__c FROM WorkOrderLineItem where Work_Type_s_Schedule_Type__c =:wt';
        system.debug('query : ' +  query);*/
        return Database.getQueryLocator(System.Label.PIESUpdateInstallEmailonWOLIQuery);
    }
     
    global void execute(Database.BatchableContext BC, List<WorkOrderLineItem> woliList) {
       system.debug('woliList :' + woliList); 
       Id saRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('OV/Install').getRecordTypeId(); 
	   Set<Id> setSAId = new Set<Id>();Map<String, String> mapWOLIIdARSRId = new Map<String, String>(); Map<String, String> mapWOLIIdARSREmail = new Map<String, String>();
       List<WorkOrderLineItem> listWOLIUpdate = new List<WorkOrderLineItem>(); 
       for(ServiceAppointment sa : [SELECT Id FROM ServiceAppointment WHERE RecordTypeId=:saRecordTypeId AND 
                                    Parent_WOLI__c IN :woliList AND FSSK__FSK_Assigned_Service_Resource__c != null
                                    AND (StatusCategory != 'Completed' OR StatusCategory != 'Canceled' )  ]){
          	setSAId.add(sa.Id);                                 
       }
        system.debug('setSAId: ' +  setSAId);
       for(AssignedResource ar : [SELECT ServiceResourceId, ServiceResource.RelatedRecord.Email,ServiceAppointment.Parent_WOLI__c FROM AssignedResource 
                                  WHERE ServiceAppointmentId IN :setSAId AND ServiceResource.Installer_Third_Party__c = TRUE]){
            mapWOLIIdARSRId.put(ar.ServiceAppointment.Parent_WOLI__c, ar.ServiceResourceId );
             
       }
        system.debug('mapWOLIIdARSRId: ' +  mapWOLIIdARSRId);
        for(ServiceResource sr : [SELECT Id, RelatedRecord.Email FROM ServiceResource WHERE Id IN :mapWOLIIdARSRId.values()]) {
            system.debug('Email : ' + sr.RelatedRecord.Email);
            mapWOLIIdARSREmail.put(sr.Id, sr.RelatedRecord.Email );
        }
        system.debug('mapWOLIIdARSREmail: ' +  mapWOLIIdARSREmail);
       for(WorkOrderLineItem w :woliList){
           if(mapWOLIIdARSRId.containsKey(w.Id) && mapWOLIIdARSREmail.containsKey(mapWOLIIdARSRId.get(w.Id))){
              w.Primary_Installer__c =  mapWOLIIdARSRId.get(w.Id);
              w.Installer_Payout_Email__c =  mapWOLIIdARSREmail.get(mapWOLIIdARSRId.get(w.Id));
              listWOLIUpdate.add(w); 
           }          
        }
        system.debug('listWOLIUpdate :' + listWOLIUpdate);
        if(listWOLIUpdate.size() > 0){
            Database.update(listWOLIUpdate, false);
        }
    }   
     
    global void finish(Database.BatchableContext BC) {
       
    }
}