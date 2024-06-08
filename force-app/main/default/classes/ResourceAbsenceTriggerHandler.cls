public class ResourceAbsenceTriggerHandler {
   public static Boolean runTrigger=true; 
    public static Boolean CREATE_UPADTE_EVENT=true; 
    
    public static void createOrUpdateEventforAbsence(List<ResourceAbsence> RAList,Map<Id,ResourceAbsence> oldMap)
    {
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        List<Event> createEventList = new List<Event>();
        set<Id> resourceId=new set<Id>();
        List<ResourceAbsence> listAR=new List<ResourceAbsence>();
       try{
        // Iterate over Service Appointments
        for(ResourceAbsence ar : RAList)
        {
            if(oldMap==null ||
               ( ar.start != oldMap.get(ar.Id).start
               || ar.end != oldMap.get(ar.Id).end
               || ar.ResourceId != oldMap.get(ar.Id).ResourceId)){
                   listAR.add(ar);
                   resourceId.add(ar.ResourceId);
               }
            
        }
        Map<Id,ServiceResource> mapServiceResource=new Map<Id,ServiceResource>([SELECT ID,relatedRecordId, RecordTypeId from ServiceResource where Id in :resourceId ]);
        
        Map<Id,Id> mapEventAR=new Map<Id,Id>();
        
        List<Event> listEvent=[SELECT Id,WhatId FROM Event Where WhatId In :listAR];
        for(Event ev:listEvent){
            mapEventAR.put(ev.WhatId,ev.Id);
        }
        
        for(ResourceAbsence ar : listAR){
            String srRT ;
            Event evtObj = new Event();
            if(mapEventAR.containsKey(ar.Id)){
                evtObj.Id=mapEventAR.get(ar.Id);
            }
            if(mapServiceResource.containsKey(ar.ResourceId)){
                evtObj.OwnerId=mapServiceResource.get(ar.ResourceId).relatedRecordId;
                srRT = mapServiceResource.get(ar.ResourceId).recordTypeId;
            }
            if(srRT == srRTId){
                evtObj.Type = 'Other';
                evtObj.Subject =  ar.AbsenceNumber + '-' + ar.Type  ;
                evtObj.RecordTypeId = evRTId;
            }
            evtObj.WhatId = ar.Id; 
            evtObj.StartDateTime = ar.start;
            evtObj.EndDateTime = ar.end;
            createEventList.add(evtObj);
        }
     
      
        if(!createEventList.IsEmpty())
        {
            system.debug('createEventList :' +createEventList);
            Boolean currentFlag=EventTriggerHandler.runTrigger;
            EventTriggerHandler.runTrigger=false;
			upsert createEventList;
            EventTriggerHandler.runTrigger=currentFlag;
            
        }
		system.debug('event Id' +createEventList[0].Id );
       
       }  
        catch(exception e){
            system.debug( e.getMessage() );
        }
    }
    /*public static void deleteEventforAbsence(List<ResourceAbsence> RAList)
    {
        List<Event> listEventToDelete=[SELECT Id,WhatId FROM Event Where WhatId In :RAList];
        Boolean currentFlag=EventTriggerHandler.runTrigger;
        EventTriggerHandler.runTrigger=false;
        delete listEventToDelete;
        EventTriggerHandler.runTrigger=currentFlag;
       
    }*/
}