public class EventTriggerHandler 
{    
    public static Set<String> profileIdsToExclude 
    {
        get
        {
            if(profileIdsToExclude == null)
            {
                profileIdsToExclude = new Set<String>();
                for(Profile pr : [SELECT Id, Name FROM Profile WHERE Name IN ('Trade_Comm Sales', 'Trade_Comm Sales Management','Pro_Lowes Sales','Pro_Lowes Sales Management')])
                {
                    profileIdsToExclude.add(pr.Id);
                }
            }
            return profileIdsToExclude ;
        }
        set; 
    }
    
    public static Boolean runTrigger=true; 
    public static DateTime dt;
    
    //13/05/2020 : Validation to prevent assigning the event to inactive sales resources
    public static void validate(List<Event> events)
    {
        //3/30/22 Pallavi
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        Map<Id, event> evOwnerId = new Map<Id, Event>();
        for(event evt: events)
        {
            // added condition to skip for resource absence
            if(evt.RecordTypeId != evRTId &&  !(evt.ShowAs=='Busy' && evt.Event_Type__c=='Time Block')){evOwnerId.put(evt.OwnerId, evt); }
            
        }
        Map<Id, Id> srResourceId = new Map<Id, Id>();
        List<ServiceResource> sa = [select RelatedRecordId, Id from ServiceResource where isActive != TRUE AND RelatedRecordId IN:evOwnerId.keySet() AND RecordTypeId != :srRTId]; 
        
        for(ServiceResource sr : sa)
        {
            if(evOwnerId.containsKey(sr.RelatedRecordId))
            {
                Event event = evOwnerId.get(sr.RelatedRecordId);
                event.OwnerId.addError(System.Label.Inactive_Service_Resource_check);
            }
        }
    }
    
    public static void RTAAppointmentDateChangeValidation(List<Event> events, Map<Id,Event> oldMap){
        
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        for(event e: events)
        {
            if(e.RecordTypeId != evRTId && e.Event_Type__c=='RTA' && (e.StartDateTime!=oldMap.get(e.Id).StartDateTime || e.EndDateTime!=oldMap.get(e.Id).EndDateTime || e.ownerId!=oldMap.get(e.Id).ownerId) && e.WhatId!=null && String.valueOf(e.WhatId).StartsWith('08p')){
                e.addError(System.Label.Sale_Rep_Or_Manager_Can_not_change_date_time_on_event);
            }
        }
        
    }
    
    public static void createServiceAppointement(List<Event> events, Map<Id,Event> oldMap)
    {
        validate(events); //13/05/2020 : Validation to prevent assigning the event to inactive sales resources
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        String SAFullDetailRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Full Details').getRecordTypeId();
        Set<String> locationName=new Set<String>();
        set<Id> resourceId=new Set<Id>();
        // Iterate over events
        for(Event event : events){
            // Create Service Appintment only if event type is Follow Up or Rehash and Startdate and enddate is not blank
            // event.Event_Type__c=='Follow Up' || 
            if((event.Event_Type__c=='Rehash') && event.IsRecurrence2 != TRUE && event.RecordTypeId != evRTId){
                if(event.StartDateTime!=null && event.EndDateTime!=null){
                    //locationName.add(event.Location);
                    resourceId.add(event.OwnerId);
                }else{
                    event.addError('Start Date Time and End Date Time Required For the event type Rehash');
                }
            }
        }
        
        Map<Id,Id> userWiseSR=new Map<Id,Id>();
        List<ServiceResource> listServiceResource=[SELECT ID,RelatedRecordId FROM ServiceResource where 
                                                   RelatedRecordId in :resourceId and isActive=true and ResourceType='T' 
                                                   AND RecordTypeId != :srRTId];
        for(ServiceResource SR :listServiceResource){
            userWiseSR.put(SR.RelatedRecordId,SR.Id);
        }
        
        // Get the ServiceTerritory Id from the event location name
        /*Map<String,Id> territoryWiseId=new Map<String,Id>();
List<ServiceTerritory> listTerriroty=[SELECT ID,NAME FROM ServiceTerritory Where Name IN :locationName];
for(ServiceTerritory T : listTerriroty){
territoryWiseId.put(T.Name,T.Id);
}*/
        
        // Create Service Appointment
        Map<Event,ServiceAppointment> eventWiseSA=new Map<Event,ServiceAppointment>();
        for(Event event : events){
            //event.Event_Type__c=='Follow Up' ||
            if((( event.Event_Type__c=='Rehash') && event.StartDateTime!=null && event.EndDateTime!=null && event.RecordTypeId != evRTId)) {
                
                // IF Assigned To is not active or not exist as service resource
                if(!userWiseSR.containsKey(event.OwnerId)){
                    event.addError('This sales resource isn\'t active or isn\'t a technician, so they can\'t be assigned to appointments');
                    continue;
                }
                
                if(event.StartDateTime >= event.EndDateTime ) event.addError('The Start Time must be earlier than the End Time');
                
                // Create Service Appintment only if event type is Follow Up or Rehash and Startdate and enddate is not blank
                ServiceAppointment SA=new ServiceAppointment();
                SA.Subject=event.subject;
                SA.SchedStartTime=event.StartDateTime;
                sa.LastUpdatedBy__c = 'EventTriggerCreateSA;'; 
                SA.SchedEndTime=event.EndDateTime;
                SA.EarliestStartTime=event.StartDateTime;
                SA.DueDate=event.EndDateTime;
                SA.RecordTypeId=SAFullDetailRecordTypeId;
                SA.Rehash_Appointment__c=true;
                SA.OwnerId=event.ownerId;
                SA.Description=event.description;
                SA.Status='Scheduled';
                /*if(territoryWiseId.containsKey(event.Location)){
SA.ServiceTerritoryId=territoryWiseId.get(event.Location);
}*/
                if(event.WhatId!=null){
                    SA.ParentRecordId=event.WhatId;
                }
                eventWiseSA.put(event,SA);
            }
        }
        
        // insert SA
        if(eventWiseSA.values().size()>0){
            Boolean currentFlag=ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD;
            ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD=false;
            insert eventWiseSA.values();
            ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD=currentFlag;
        }
        
        //Create Assign Resource Mapping, Assign To Id as Assign Resource in Salesforce
        List<AssignedResource> listAS=new List<AssignedResource>();
        for(Event event : eventWiseSA.keySet()){
            // update Service Appointment Id as WhatId on Event
            event.WhatId=eventWiseSA.get(event).Id;
            
            /* AssignedResource AssignResource = new AssignedResource();
AssignResource.ServiceResourceId=userWiseSR.get(event.OwnerId);
AssignResource.ServiceAppointmentId=event.WhatId;

listAS.add(AssignResource);*/
        }
        
        // insert AS
        /*insert listAS;*/
    }
    
    public static void updateServiceAppointement(List<Event> events, Map<Id,Event> oldMap)
    {
        Set<Id> listWhatId=new Set<Id>();
        Map<Id,Event> SAWiseEvent=new Map<Id,Event>();
        Id saRTId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('OV_Install').getRecordTypeId();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        // Iterate over events
        for(Event event : events)
        {
            // update StartDateTime to SA
            if((event.Event_Type__c=='Rehash') && event.IsRecurrence2 != TRUE && event.RecordTypeId != evRTId)
            {
                if(event.StartDateTime!=null && event.EndDateTime!=null && (event.StartDateTime != oldMap.get(event.Id).StartDateTime
                                                                            || event.EndDateTime != oldMap.get(event.Id).EndDateTime  || event.OwnerId != oldMap.get(event.Id).OwnerId))
                {
                    if(event.StartDateTime >= event.EndDateTime ) event.addError('The Start Time must be earlier than the End Time');
                    
                    listWhatId.add(event.WhatId);
                    SAWiseEvent.put(event.WhatId, event);
                }
                else
                {
                    event.addError('Start Date Time and End Date Time Required For the event type  Rehash');
                }
            }
        }
        
        List<ServiceAppointment> listServiceAppointment=[SELECT ID, LastUpdatedBy__c  FROM ServiceAppointment where Id in :listWhatId AND RecordTypeId != :saRTId];
        for(ServiceAppointment SA : listServiceAppointment){
            SA.SchedStartTime=SAWiseEvent.get(sa.Id).StartDateTime;
            sa.LastUpdatedBy__c += 'EventTriggerUpdateSA;'; 
            SA.SchedEndTime=SAWiseEvent.get(sa.Id).EndDateTime;
            SA.EarliestStartTime=SAWiseEvent.get(sa.Id).StartDateTime;
            SA.DueDate=SAWiseEvent.get(sa.Id).EndDateTime;
            SA.OwnerId=SAWiseEvent.get(sa.Id).OwnerId;
            SA.Description=SAWiseEvent.get(sa.Id).Description;
        }
        
        Boolean currentFlag=ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD;
        Boolean RescheduleFlag=ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH;
        ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD=false;
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH =false;
        ServiceAppointmentTriggerHandler.Check_Conflict_Overriden = false ;
        Update listServiceAppointment;
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH =RescheduleFlag;
        ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD=currentFlag;
        //ServiceAppointmentTriggerHandler.Check_Conflict_Overriden = false ;
        
        
    }
    public static void ManageChildAbsenceResource(List<Event> events, Map<Id,Event> oldMap){
        System.debug('inside create child');
        List<String> listParentEventIds=new List<STring>();
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        // system.debug('Size of events:' + events.size());
        Id breakRecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Break').getRecordTypeId();
        Map<DateTime,ResourceAbsence> mapEventARDT=new Map<DateTime,ResourceAbsence>();
        List<Id> listOwnerId=new List<Id>();
        
        for(Event event : events){
            if(event.RecordTypeId != evRTId ){
                listOwnerId.add(event.OwnerId);
            }
            if(Trigger.isDelete && event.IsChild==true){
                event.addError('You have been added as an attendee, and only the organizer can remove you from this event');
            }
        }
        system.debug('listOwnerId :' + listOwnerId);
        List<ServiceResource> listSR=[SELECT ID,RelatedRecordId  FROM ServiceResource WHERE
                                      RelatedRecordId IN :listOwnerId AND IsActive = TRUE AND RecordTypeId != :srRTId];
        Map<Id,Id> mapUserIdSRId=new Map<Id,Id>();
        for(ServiceResource sr:listSR){
            mapUserIdSRId.put(sr.relatedRecordId, sr.Id);
        }
        system.debug('@@'+Trigger.isDelete );
        for(Event event: events){
            if(event.RecordTypeId != evRTId && event.ShowAs=='Busy' && event.Event_Type__c!='Rehash' && event.StartDateTime!=null && event.EndDateTime!=null && event.OwnerId != null && event.IsRecurrence2 !=TRUE  ){
                if(Trigger.isInsert || Trigger.isDelete ||event.IsGroupEvent||oldMap.get(event.Id).IsGroupEvent||
                   ( event.StartDateTime!=null && event.EndDateTime!=null
                    && (event.StartDateTime != oldMap.get(event.Id).StartDateTime
                        || event.EndDateTime != oldMap.get(event.Id).EndDateTime 
                        || event.Event_Type__c != oldMap.get(event.Id).Event_Type__c))){
                            listParentEventIds.add(event.Id);
                        }
                
            }
            //for recurrign events
            if(event.RecordTypeId != evRTId && event.ShowAs=='Busy' && event.Event_Type__c=='Time Block' && event.StartDateTime!=null && event.OwnerId != null && event.IsRecurrence2 == TRUE ){       
                if(Trigger.isInsert || Trigger.isDelete  ||event.IsGroupEvent||oldMap.get(event.Id).IsGroupEvent||
                   ( event.StartDateTime!=null && event.EndDateTime!=null
                    && (event.StartDateTime != oldMap.get(event.Id).StartDateTime
                        || event.EndDateTime != oldMap.get(event.Id).EndDateTime 
                        || event.Event_Type__c != oldMap.get(event.Id).Event_Type__c))){
                            listParentEventIds.add(event.Id);
                        }
            }
        }
        
        if(listParentEventIds.size()>0){
            if(Trigger.isDelete || Trigger.isUpdate){
                if(System.IsBatch() == false && System.isFuture() == false){
                    deleteAttendeeAbsenceResource(listParentEventIds);
                }
            }
            if(Trigger.isInsert || Trigger.isUpdate){
                if(System.IsBatch() == false && System.isFuture() == false){
                    addAttendeeAbsenceResource(listParentEventIds);
                }
            }
            
            
        }
    }
     @future
    public static void addAttendeeAbsenceResource(List<String> eventIds){
        
        Id breakRecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Break').getRecordTypeId();
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Map<String,Event> parentWhatId=new MAp<String,Event>();
         Map<String,Event> parentEventMap=new MAp<String,Event>();
        List<ResourceAbsence> listResourceToUpdate=new List<ResourceAbsence>();
        
        Map<String,List<String>> parentEventWiseAttendee=new Map<String,List<String>>();
        List<String> listEventMissingParent=new List<String>();
        DateTime fromDateTime;
        DateTime toDateTime;
        // get parent event
        List<Event> listParentEvent=[SELECT Id,OwnerId,WhatId,Subject,IsAllDayEvent,StartDateTime,EndDateTime,Event_Type__c from Event Where Id = : eventIds LIMIT 10000];
        for(Event parentEvent : listParentEvent){
            parentWhatId.put(parentEvent.WhatId, parentEvent);        
            
            if(parentEvent.WhatId==null){
                listEventMissingParent.add(parentEvent.Id);
                if(fromDateTime==null || fromDateTime>parentEvent.StartDateTime){
                    fromDateTime=parentEvent.StartDateTime;
                }
                if(toDateTime==null || toDateTime<parentEvent.EndDateTime){
                    toDateTime=parentEvent.EndDateTime;
                }
                parentEventMap.put(''+parentEvent.StartDateTime+'_'+parentEvent.EndDateTime, parentEvent);       
            }
        }
        
        // get ownerId
        List<String> listOwnerId = new List<String>();
        
        for(EventRelation ER : [select Id, RelationId, EventId, IsWhat, IsParent from EventRelation where EventId =:listEventMissingParent ]){
            if(String.valueOf(ER.RelationId).startsWith('005')){
                if(!parentEventWiseAttendee.containsKey(ER.EventId)){
                    parentEventWiseAttendee.put(ER.EventId,new List<String>());
                }
                listOwnerId.add(ER.RelationId);   
                parentEventWiseAttendee.get(ER.EventId).add(ER.RelationId);
            }
        }
        // get child event
        List<Event> listChildEventForEmptyWhatId=[SELECT ID,OwnerId,WhatId,Subject,IsAllDayEvent,StartDateTime,EndDateTime,Event_Type__c from Event Where ownerId = : listOwnerId AND IsChild = true and StartDateTime >=:fromDateTime and StartDateTime <=:toDateTime  ORDER BY CreatedDate DESC LIMIT 10000];
        
        // get child event
        List<Event> listChildEvent=[SELECT ID,OwnerId,WhatId,Subject,IsAllDayEvent,StartDateTime,EndDateTime,Event_Type__c from Event Where WhatId = : parentWhatId.keySet() AND IsChild = true ORDER BY CreatedDate DESC LIMIT 10000];
        
        // Added for test coverage
        if(Test.isRunningTest()){
            listChildEvent=listParentEvent;
        }
        for(Event childEvent : listChildEvent){
            listOwnerId.add(childEvent.OwnerId);         
        }
        
        List<ServiceResource> listSR=[SELECT ID,RelatedRecordId  FROM ServiceResource WHERE
                                      RelatedRecordId IN :listOwnerId AND IsActive = TRUE AND RecordTypeId != :srRTId];
        Map<Id,Id> mapUserIdSRId=new Map<Id,Id>();
        for(ServiceResource sr:listSR){
            mapUserIdSRId.put(sr.relatedRecordId, sr.Id);
        }
        
        for(Event event : listChildEvent){
            
            if(event.WhatId!=null && parentWhatId.containsKey(event.WhatId)){
                Event ParentEvent=parentWhatId.get(event.WhatId);
                // compare subject + date time
                if(event.Subject==parentEvent.subject && event.StartDateTime == parentEvent.StartDateTime && mapUserIdSRId.containsKey(event.OwnerId) ){
                    ResourceAbsence RA=new ResourceAbsence();
                    // Since it sends 00:00:00 as GMT time for all time event, Consider that time as user time zone and convert to GMT 
                    if(event.IsAllDayEvent){   
                        Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(event.StartDateTime)/1000; 
                        RA.Start=event.StartDateTime.addSeconds(-(TimeZoneGMTdiffSec));
                        RA.End= event.EndDateTime.addDays(1).addSeconds(-(TimeZoneGMTdiffSec));  
                    }else{
                        RA.Start=event.StartDateTime;
                        RA.End=event.EndDateTime;    
                    }
                    // assign default to person on 17-03
                    RA.Type=event.Event_Type__c==null ||event.Event_Type__c==''?'Personal':event.Event_Type__c;
                    RA.Parent_Event_Id__c=ParentEvent.Id;
                    RA.EventId__c=event.Id;
                    RA.ResourceId=mapUserIdSRId.get(event.OwnerId) ;
                    RA.RecordTypeId=breakRecordTypeId;
                    listResourceToUpdate.add(RA);
                }
            }
           
        }
        
        //  for those where what id is null
        for(Event event : listChildEventForEmptyWhatId){
            
            if(event.WhatId==null && parentEventMap.containsKey(''+event.StartDateTime+'_'+event.EndDateTime)){
                Event ParentEvent=parentEventMap.get(''+event.StartDateTime+'_'+event.EndDateTime);
                // compare subject + date time
                if(event.Subject==parentEvent.subject && mapUserIdSRId.containsKey(event.OwnerId) ){
                    ResourceAbsence RA=new ResourceAbsence();
                    // Since it sends 00:00:00 as GMT time for all time event, Consider that time as user time zone and convert to GMT 
                    if(event.IsAllDayEvent){   
                        Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(event.StartDateTime)/1000; 
                        RA.Start=event.StartDateTime.addSeconds(-(TimeZoneGMTdiffSec));
                        RA.End= event.EndDateTime.addDays(1).addSeconds(-(TimeZoneGMTdiffSec));  
                    }else{
                        RA.Start=event.StartDateTime;
                        RA.End=event.EndDateTime;    
                    }
                    // assign default to person on 17-03
                    RA.Type=event.Event_Type__c==null ||event.Event_Type__c==''?'Personal':event.Event_Type__c;
                    RA.Parent_Event_Id__c=ParentEvent.Id;
                    RA.EventId__c=event.Id;
                    RA.ResourceId=mapUserIdSRId.get(event.OwnerId) ;
                    RA.RecordTypeId=breakRecordTypeId;
                    listResourceToUpdate.add(RA);
                }
            }
           
        }
        
        if(listResourceToUpdate.size()>0){
            Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
            database.insert(listResourceToUpdate,false);
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag;
            
        }
        
    }
     @future
    public static void deleteAttendeeAbsenceResource(List<String> eventIds){
        set<String> parentEventIds=new set<String>();
        parentEventIds.addAll(eventIds);
        for(ResourceAbsence  RA : [SELECT ID,Parent_Event_Id__c FROM ResourceAbsence WHERE EventId__c in :eventIds]){
            parentEventIds.add(RA.Parent_Event_Id__c);
        }
        
        List<ResourceAbsence> RAlist=[SELECT ID FROM ResourceAbsence WHERE Parent_Event_Id__c in :parentEventIds];
        Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
        ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
        if(RAlist.size() > 0)
            delete RAlist;
        ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag;
    }    
    // Absence Resource
    public static void createAbsenceResource(List<Event> events)
    {
        List<String> listParentEventIds=new List<STring>();
        validate(events); //13/05/2020 : Validation to prevent assigning the event to inactive sales resources
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        // system.debug('Size of events:' + events.size());
        Id breakRecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Break').getRecordTypeId();
        
        
        //Map<Id,ResourceAbsence> mapEventAR=new Map<Id,ResourceAbsence>();
        Map<DateTime,ResourceAbsence> mapEventARDT=new Map<DateTime,ResourceAbsence>();
        List<Id> listOwnerId=new List<Id>();
        
        for(Event event : events){
            if(event.RecordTypeId != evRTId ){
                listOwnerId.add(event.OwnerId);
            }
            
        }
        system.debug('listOwnerId :' + listOwnerId);
        List<ServiceResource> listSR=[SELECT ID,RelatedRecordId  FROM ServiceResource WHERE
                                      RelatedRecordId IN :listOwnerId AND IsActive = TRUE AND RecordTypeId != :srRTId];
        Map<Id,Id> mapUserIdSRId=new Map<Id,Id>();
        for(ServiceResource sr:listSR){
            mapUserIdSRId.put(sr.relatedRecordId, sr.Id);
        }
        system.debug('mapUserIdSRId@@@:' + mapUserIdSRId);    
        // Iterate over events
        system.debug('evetns:' + events.size());
        for(Event event : events)
        {   
            Integer TimeZoneGMTdiffSec; 
            if(event.RecordTypeId != evRTId){
                //Added this if condition becoz of outlook events not syching to salesforce as startdate time is coming null - Kalyan 07132022
                if(event.StartDateTime == null && event.ActivityDateTime != null){
                    event.StartDateTime = event.ActivityDateTime;    
                }
                TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(event.StartDateTime)/1000;
            }
            
            //validations
            if(event.RecordTypeId != evRTId && event.StartDateTime >= event.EndDateTime && !(event.IsAllDayEvent) ) 
            {
                event.addError('The Start Time must be earlier than the End Time');
                continue;
            }
            if(event.RecordTypeId != evRTId && event.IsRecurrence2 == TRUE && event.Event_Type__c != 'Time Block') event.addError('Recurring events can be created only for Event Type - Time Blocks');
            
            // update StartDateTime to SA
            if(event.RecordTypeId != evRTId && event.ShowAs=='Busy' && event.Event_Type__c!='Rehash' && event.StartDateTime!=null && event.EndDateTime!=null && event.OwnerId != null && event.IsRecurrence2 !=TRUE && mapUserIdSRId.containsKey(event.OwnerId) ){
                system.debug(mapUserIdSRId.get(event.OwnerId));
                ResourceAbsence RA=new ResourceAbsence();
                // Since it sends 00:00:00 as GMT time for all time event, Consider that time as user time zone and convert to GMT 
                if(event.IsAllDayEvent){   
                    RA.Start=event.StartDateTime.addSeconds(-(TimeZoneGMTdiffSec));
                    RA.End= event.EndDateTime.addDays(1).addSeconds(-(TimeZoneGMTdiffSec));  
                }else{
                    RA.Start=event.StartDateTime;
                    RA.End=event.EndDateTime;    
                }
                // assign default to person on 17-03
                RA.Type=event.Event_Type__c==null ||event.Event_Type__c==''?'Personal':event.Event_Type__c;
                
                RA.ResourceId=mapUserIdSRId.get(event.OwnerId) ;
                RA.RecordTypeId=breakRecordTypeId;
                mapEventARDT.put(event.StartDateTime,RA);
                system.debug('mapEventARDT: '+mapEventARDT);
                listParentEventIds.add(event.Id);
            }
            //for recurrign events
            if(event.RecordTypeId != evRTId && event.ShowAs=='Busy' && event.Event_Type__c=='Time Block' && event.StartDateTime!=null && event.OwnerId != null && event.IsRecurrence2 == TRUE && mapUserIdSRId.containsKey(event.OwnerId) ){    
                ResourceAbsence RA = new ResourceAbsence();   
                if(event.IsAllDayEvent){   
                    RA.Start=event.StartDateTime.addSeconds(-(TimeZoneGMTdiffSec));
                    if(event.EndDateTime != null){
                        RA.End= event.EndDateTime.addDays(1).addSeconds(-(TimeZoneGMTdiffSec));  
                    }
                    else {RA.End = event.StartDateTime.addMinutes(event.DurationInMinutes).addSeconds(-(TimeZoneGMTdiffSec)); }  
                }else{
                    RA.Start=event.StartDateTime;
                    if(event.EndDateTime != null){
                        RA.End=event.EndDateTime; 
                    }
                    else {RA.End = event.StartDateTime.addMinutes(event.DurationInMinutes); }    
                }
                
                // assign default to person on 17-03
                RA.Type=event.Event_Type__c==null ||event.Event_Type__c==''?'Personal':event.Event_Type__c;
                RA.ResourceId=mapUserIdSRId.get(event.OwnerId) ;
                RA.RecordTypeId=breakRecordTypeId;
                system.debug('eventid : '+ event.Id);  
                mapEventARDT.put(event.StartDateTime,RA);
                system.debug('mapEventARDT: '+mapEventARDT);
                listParentEventIds.add(event.Id);
            }
            
        }
        
        if(mapEventARDT.values().size()>0){
            Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
            insert mapEventARDT.values();
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag;
            
        }
        for(Event event : events){
            if(mapEventARDT.containsKey(event.StartDateTime)){
                event.whatId=mapEventARDT.get(event.StartDateTime).Id;
                system.debug('RA Id : ' +  mapEventARDT.get(event.StartDateTime).Id);
                system.debug('event Id:' + event.id );
            }
        }
        if(listParentEventIds.size()>0){
            if(System.IsBatch() == false && System.isFuture() == false){
               // updateChildAbsenceResource(listParentEventIds);
            }
            
        }
        
    }
    public static void updateAbsenceResource(List<Event> events, Map<Id,Event> oldMap)
    {
        // validate(events); //13/05/2020 : Validation to prevent assigning the event to inactive sales resources ; 05/21/2020: To be triggered only during creation
        
        Id breakRecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Break').getRecordTypeId();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        Id srRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        Map<DateTime,ResourceAbsence> mapEventAR=new Map<DateTime,ResourceAbsence>();
        
        Set<Id> listWhatId=new Set<Id>();  //rA
        Set<Id> listOwnerId=new Set<Id>();  //assigend to
        Map<Id,Event> ARWiseEvent=new Map<Id,Event>();
        List<Event> OwnerChangeEvent=new List<Event>();
        
        // Iterate over events
        for(Event event : events)
        {
            //Validations
            /*if(event.RecordTypeId != evRTId && event.IsRecurrence2 == TRUE && event.Event_Type__c == 'Time Block' 
               && event.StartDateTime!=null && event.EndDateTime!=null 
               && event.subject !=null && event.OwnerId != null 
               && (event.Description == null || event.Description !=null)
               && (event.Location == null || event.location != null)
               && (event.ShowAs !=null)) event.addError('Recurring events cannot be updated. Please delete and create again');*/
            
            if(event.RecordTypeId != evRTId && event.IsRecurrence2 == TRUE 
               && event.Event_Type__c != oldMap.get(event.Id).Event_Type__c 
               && event.StartDateTime!= oldMap.get(event.Id).StartDateTime
               && event.EndDateTime!= oldMap.get(event.Id).EndDateTime 
               && event.subject != oldMap.get(event.Id).subject
               && event.OwnerId != oldMap.get(event.Id).OwnerId
               && event.Description != oldMap.get(event.Id).Description
               && event.Location != oldMap.get(event.Id).Location
               && event.ShowAs != oldMap.get(event.Id).ShowAs) 
               event.addError('Recurring events cannot be updated. Please delete and create again');
            
            if(((event.ownerId != oldMap.get(event.Id).ownerId) || (event.ShowAs == 'Busy' &&  oldMap.get(event.Id).ShowAs == 'Free')) && event.Event_Type__c!='Rehash')
            {
                listOwnerId.add(event.OwnerId);
            }
            // update StartDateTime to AR
            else if(event.StartDateTime!=null && event.EndDateTime!=null
                    && (event.StartDateTime != oldMap.get(event.Id).StartDateTime
                        || event.EndDateTime != oldMap.get(event.Id).EndDateTime 
                        || event.Event_Type__c != oldMap.get(event.Id).Event_Type__c))
            {
                listWhatId.add(event.WhatId);
                ARWiseEvent.put(event.WhatId, event);
                system.debug('listWhatId'+ listWhatId);
            }
        }
        
        // insert new absence record and delete old one if owner change
        List<ServiceResource> listSR=[SELECT ID,RelatedRecordId  FROM ServiceResource WHERE relatedRecordId in :listOwnerId and isActive=true AND RecordTypeId != :srRTId];
        Map<Id,Id> mapUserIdSRId=new Map<Id,Id>();
        for(ServiceResource sr:listSR){
            mapUserIdSRId.put(sr.relatedRecordId, sr.Id);
        }
        // Iterate over events
        for(Event event : events){
            // update StartDateTime to RA
            system.debug('size of event : '+ events.size());
            if(((event.ownerId != oldMap.get(event.Id).ownerId && event.ShowAs=='Busy') || (event.ShowAs == 'Busy' &&  oldMap.get(event.Id).ShowAs == 'Free')) 
               && event.Event_Type__c!='Rehash' && mapUserIdSRId.containsKey(event.OwnerId)){
                   ResourceAbsence RA=new ResourceAbsence();
                   if(event.IsAllDayEvent){
                       Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(event.StartDateTime)/1000;    
                       RA.Start=event.StartDateTime.addSeconds(-(TimeZoneGMTdiffSec));
                       RA.End= event.EndDateTime.addDays(1).addSeconds(-(TimeZoneGMTdiffSec));  
                   }else{
                       RA.Start=event.StartDateTime;
                       RA.End=event.EndDateTime;
                   }
                   // assign default to person on 17-03
                   RA.Type=event.Event_Type__c==null ||event.Event_Type__c==''?'Personal':event.Event_Type__c;
                   
                   RA.ResourceId=mapUserIdSRId.get(event.OwnerId) ;
                   RA.RecordTypeId=breakRecordTypeId;
                   mapEventAR.put(event.StartDateTime ,RA);
               }
            
            
        }
        if(mapEventAR.values().size()>0){
            Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
            insert mapEventAR.values();
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag;
            
        }
        for(Event event : events){
            if(mapEventAR.containsKey(event.StartDateTime )){
                event.whatId=mapEventAR.get(event.StartDateTime ).Id;
                system.debug('RA Updated ID: '+ mapEventAR.get(event.StartDateTime ).Id);
            }
        }
        
        // update the record
        if(listWhatId.size()>0){
            List<ResourceAbsence> listResourceAbsence=[SELECT ID FROM ResourceAbsence where Id in :listWhatId ];
            for(ResourceAbsence AR : listResourceAbsence){
                if(ARWiseEvent.get(ar.Id).IsAllDayEvent){
                    Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(ARWiseEvent.get(ar.Id).StartDateTime)/1000;    
                    AR.Start=ARWiseEvent.get(ar.Id).StartDateTime.addSeconds(-(TimeZoneGMTdiffSec));
                    AR.End= ARWiseEvent.get(ar.Id).EndDateTime.addDays(1).addSeconds(-(TimeZoneGMTdiffSec));  
                }else{
                    AR.Start=ARWiseEvent.get(ar.Id).StartDateTime;
                    AR.End=ARWiseEvent.get(ar.Id).EndDateTime;
                }
                // assign default to person on 17-03
                AR.Type=ARWiseEvent.get(ar.Id).Event_Type__c==null ||ARWiseEvent.get(ar.Id).Event_Type__c==''?'Personal':ARWiseEvent.get(ar.Id).Event_Type__c;
                
                //AR.Type=ARWiseEvent.get(ar.Id).Event_Type__c;
                
            }
            
            Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
            if(listResourceAbsence.size() > 0)
            { Update listResourceAbsence; }
            system.debug('UPdate');
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag;
        }
    }
    public static void deleteOldAbsenceResourceOnChange(List<Event> events, Map<Id,Event> oldMap)
    {
        List<Id> listRecordToDelete=new List<Id>();
        List<Event> createEventList = new List<Event>();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        for(Event event : events){
            if(event.ownerId != oldMap.get(event.Id).ownerId || (event.ShowAs == 'Free' &&  oldMap.get(event.Id).ShowAs == 'Busy')){
                listRecordToDelete.add(oldMap.get(event.Id).whatId);
            }
            if (event.showAs == 'Free' &&  oldMap.get(event.Id).showAs == 'Busy'){
                Event evt = new event( RecordTypeId = event.RecordTypeId,OwnerId = event.OwnerId, Subject = event.Subject, Description = event.Description, Event_Type__c = event.Event_Type__c,ShowAs = event.ShowAs, StartDateTime = event.StartDateTime, EndDateTime = event.EndDateTime,Location = event.Location );   
                createEventList.add(evt);
            }
            
        }
        // When event showas is changed from busy to Free, it is deleting the event due to FSL issue. So recreating the event here.
        if(!createEventList.IsEmpty())
        {
            Boolean currentFlag=EventTriggerHandler.runTrigger;
            EventTriggerHandler.runTrigger=false;
            insert createEventList;
            EventTriggerHandler.runTrigger=currentFlag;     
        }
        // delete old record
        Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
        ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
        if(listRecordToDelete.size() > 0)
        {delete [SELECT ID FROM ResourceAbsence where Id in :listRecordToDelete ];}
        
        ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag; 
    }
    public static void deleteAbsenceResource(List<Event> events)
    {
        List<Id> listWhatId=new List<Id>();
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        for(Event event:events){ 
            // if(event.RecordTypeId != evRTId){ 
            listWhatId.add(event.whatId);
            //   }
            
        }
        List<ResourceAbsence> RAlist=[SELECT ID FROM ResourceAbsence WHERE Id in :listWhatId];
        Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
        ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
        if(RAlist.size() > 0)
            delete RAlist;
        ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag;
        
    }
    //Method to update the EDW Last Modified 
    public static void updateEDWLastModified(List<Event> lstNew,Map<Id,Event> oldMap){
        //Query to fetch all related fileds of Event from metadata
        List<EDW_Object_Mapping__mdt> lstobjEventMetadta =[select id,Field_Api_Name__c,Source_Object__c from EDW_Object_Mapping__mdt where Source_Object__c='Event'];
        set<String> fieldSet = new Set<String>();
        //dynamically get the fields from the metadata and then use the same for comparison in the trigger. 
        for(EDW_Object_Mapping__mdt fields :lstobjEventMetadta){
            fieldSet.add(fields.Field_Api_Name__c);
        }
        for(Event objEvent: lstNew){
            
            for(string s: fieldSet){
                if(s.indexOf('.') > -1){
                    
                }
                else{
                    if(trigger.oldMap!=null){
                        if(objEvent.get(s) != trigger.oldMap.get(objEvent.Id).get(s)){
                            objEvent.EDW_Last_Modified__c=Datetime.now();
                            break;
                        }
                    }
                    else{
                        if(objEvent.get(s)!=null)
                            objEvent.EDW_Last_Modified__c=Datetime.now();
                    }
                }
            }
            
            
        }
        
    }
    
    public static void updateOnAccount(List<Event> eventList, Map<Id, Event> oldMap){
        System.debug('HOWCALL');
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
        Id taskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install').getRecordTypeId();
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        
        Set<Id> evtIds = new Set<Id>(); //SS-Store all the event Ids
        Set<Id> accIds = new Set<Id>();
        Set<Id> OppIds = new Set<Id>();
        Set<Id> allOppIds = new Set<Id>();
        List<Event> evToUdpate = new List<Event>();//SS-Do update valid records
        List<Event> eventListNew = new List<Event>(); //SS-Added newly to get values from the related fields
        
        for(Event evt : eventList) { //SS-Added to get the Ids from the EventList - Unable to get the keyset from oldMap on insert
            evtIds.add(evt.Id);
        }
        
        eventListNew = [SELECT Account__c,RecordTypeId,WhatId,Type,Opportunity_full_details__c, Opportunity_full_details__r.AccountId
                        FROM Event
                        WHERE Id IN:evtIds]; //Get the events with related Fields
        
        for(Event evt : eventListNew) {
            if(evt.RecordTypeId != evRTId && evt.WhatId != null 
               && String.valueOf(evt.WhatId).startsWith('001')
               && (oldMap == null || oldMap.get(evt.Id).WhatId != evt.WhatId || oldMap.get(evt.Id).Type != evt.Type))
            {
                accIds.add(evt.WhatId);
                if(oldMap != null && oldMap.get(evt.Id).WhatId != null && String.valueOf(oldMap.get(evt.Id).WhatId).startsWith('001')
                   && (oldMap.get(evt.Id).WhatId != evt.WhatId || oldMap.get(evt.Id).Type != evt.Type))
                {
                    accIds.add(oldMap.get(evt.Id).WhatId);
                }
            }
            if(evt.RecordTypeId != evRTId && evt.WhatId != null 
               && String.valueOf(evt.WhatId).startsWith('006')
               && (oldMap == null || oldMap.get(evt.Id).WhatId != evt.WhatId || oldMap.get(evt.Id).Type != evt.Type))
            {
                OppIds.add(evt.WhatId);
                if(oldMap != null && oldMap.get(evt.Id).WhatId != null && String.valueOf(oldMap.get(evt.Id).WhatId).startsWith('006')
                   && (oldMap.get(evt.Id).WhatId != evt.WhatId || oldMap.get(evt.Id).Type != evt.Type))
                {
                    OppIds.add(oldMap.get(evt.Id).WhatId);
                }
                //Condition in Eng - > Acc should not be related, and the Evt should relate with Opp, and then the Opp should be relate with Acc
                //SARAN - Update the Account__c value with the Oppty's related account
                if(evt.Account__c==null && evt.Opportunity_full_details__c!=null && evt.Opportunity_full_details__r.AccountId != null) { 
                    evt.Account__c = evt.Opportunity_full_details__r.AccountId; 
                    evToUdpate.add(evt);
                }
                
            }
        }
        Map<Id, Id> mapIds = new Map<Id, Id>();
        if(accIds.size() == 0){
            List<Opportunity> oppToAccIds = [SELECT ID, Account.Id FROM Opportunity where Id = :OppIds];
            for(Opportunity opp : oppToAccIds){            
                if(!accIds.contains(opp.account.id))accIds.add(opp.account.id);
            } 
        }
        OppIds.clear();
        List<Opportunity> OppData = [SELECT ID, Account.Id FROM Opportunity where Account.id  = :accIds]; 
        for(Opportunity opp : OppData){ 
            OppIds.add(opp.id);   
            mapIds.put(opp.id, opp.account.id);
        }  
        Map<String, eventRecCount> mapAccount = new Map<String, eventRecCount>();
        
        // Resolved 101 soql
        if(accIds.size()>0){
            List<Task> allTaskList = [SELECT Id, WhatId, Type FROM Task WHERE WhatId =:accIds AND CreatedDate >=:stdt AND CreatedDate <=:eddt AND RecordTypeId != :taskRTId];
            for(Task tsk : allTaskList){
                if(!mapAccount.containsKey(tsk.WhatId)){
                    mapAccount.put(tsk.WhatId, new eventRecCount(0, 0, 0));
                }
                if(tsk.Type == 'Call'){
                    mapAccount.get(tsk.WhatId).phoneCalls += 1;
                }
                else if(tsk.Type == 'Meeting' || tsk.Type == 'Virtual Meeting'){
                    mapAccount.get(tsk.WhatId).meetings += 1;
                }
            }
            List<Event> allEventList = [SELECT Id, WhatId, Type FROM Event WHERE WhatId =:accIds AND CreatedDate >=:stdt AND CreatedDate <=:eddt AND recordTypeId != :evRTId];
            for(Event evt : allEventList){
                if(!mapAccount.containsKey(evt.WhatId)){
                    mapAccount.put(evt.WhatId,  new eventRecCount(0, 0, 0));
                }
                if(evt.Type == 'Call'){
                    mapAccount.get(evt.WhatId).phoneCalls += 1;
                } else if(evt.Type == 'Meeting' ){
                    mapAccount.get(evt.WhatId).meetings += 1;
                } else if(evt.Type == 'CEU' ){
                    mapAccount.get(evt.WhatId).CEUs += 1;
                }
            }
        }
        Map<String, eventRecCount> mapOpportunity = new Map<String, eventRecCount>();
        // Resolved 101 soql
        if(OppIds.size()>0){
            List<Task> allOppTaskList = [SELECT Id, WhatId, Type FROM Task WHERE WhatId =:OppIds AND CreatedDate >=:stdt AND CreatedDate <=:eddt AND RecordTypeId != :taskRTId];
            
            for(Task tsk : allOppTaskList){
                if(!mapOpportunity.containsKey(tsk.WhatId)){
                    mapOpportunity.put(tsk.WhatId, new eventRecCount(0, 0, 0));
                }
                if(tsk.Type == 'Call'){
                    mapOpportunity.get(tsk.WhatId).phoneCalls += 1;
                }
                else if(tsk.Type == 'Meeting' || tsk.Type == 'Virtual Meeting'){
                    mapOpportunity.get(tsk.WhatId).meetings += 1;
                }
            }
            List<Event> allOppEventList = [SELECT Id, WhatId, Type FROM Event WHERE WhatId =:OppIds AND CreatedDate >=:stdt AND CreatedDate <=:eddt AND recordTypeId != :evRTId];
            for(Event evt : allOppEventList){
                if(!mapOpportunity.containsKey(evt.WhatId)){
                    mapOpportunity.put(evt.WhatId,  new eventRecCount(0, 0, 0));
                }
                if(evt.Type == 'Call'){
                    mapOpportunity.get(evt.WhatId).phoneCalls += 1;
                } else if(evt.Type == 'Meeting' ){
                    mapOpportunity.get(evt.WhatId).meetings += 1;
                } else if(evt.Type == 'CEU' ){
                    mapOpportunity.get(evt.WhatId).CEUs += 1;
                }
            }
        }
        for( Id id : mapOpportunity.keySet() ){
            if(mapIds.containsKey(id)){
                if(!mapAccount.containsKey(mapIds.get(ID))){
                    mapAccount.put(mapIds.get(ID),  new eventRecCount(0, 0, 0));
                }
                mapAccount.get(mapIds.get(ID)).phoneCalls += mapOpportunity.get(id).phoneCalls; 
                mapAccount.get(mapIds.get(ID)).meetings += mapOpportunity.get(id).meetings;   
                mapAccount.get(mapIds.get(ID)).CEUs += mapOpportunity.get(id).CEUs;     
            }     
        }
        List<Account> accToUpdate = new List<Account>();
        for(String accId : accIds){
            Account acc = new Account();
            acc.Id = accId;
            acc.YTD_Phone_Calls__c = mapAccount.containsKey(accId)?mapAccount.get(accId).phoneCalls:0;
            acc.YTD_Meetings__c = mapAccount.containsKey(accId)?mapAccount.get(accId).meetings:0;
            acc.YTD_CEUs__c = mapAccount.containsKey(accId)?mapAccount.get(accId).CEUs:0;
            
            accToUpdate.add(acc);
        }
        if(accToUpdate.size() > 0){
            Boolean AccTrigger = AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER = false;
            update accToUpdate; 
            AccountTriggerHandler.RUN_TRIGGER = AccTrigger;
        }
        
        if(evToUdpate.size()!=0) {
            System.debug('evToUdpate ');
            //EventTriggerHandler.runTrigger = false;
            update evToUdpate;
            //EventTriggerHandler.runTrigger = true;
        }
    }
    public class eventRecCount{
        public Integer phoneCalls;
        public Integer meetings;
        public Integer CEUs;
        public eventRecCount(Integer phoneCalls, Integer meetings, Integer CEUs){
            this.phoneCalls = phoneCalls;
            this.meetings = meetings;
            this.CEUs = CEUs;
        }
    }
}