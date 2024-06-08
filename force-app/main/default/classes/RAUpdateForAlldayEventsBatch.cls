/**
*   @Author:        Kalyan Adham
*   @Date:          09/11/2020
*   @TaskSource:    
*   @Purpose:       Apex Class to update the RA's records for the all day events created before Jul 10th 2020. A fix has been 
provided on July 10th and all day events/RA are getting created fine. 

*   @Updates:       
*/
public class RAUpdateForAlldayEventsBatch implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('listWhatId'); 
        return Database.getQueryLocator(System.Label.ReProcessAlldayeventsQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Event> events){
        system.debug('events'); 
        Set<Id> listWhatId=new Set<Id>();  //rA
        Map<Id,Event> ARWiseEvent=new Map<Id,Event>();
        for(Event event : events){  
            listWhatId.add(event.WhatId);
            ARWiseEvent.put(event.WhatId, event);
            system.debug('listWhatId'+ listWhatId);
            system.debug('listWhatId'+ listWhatId.size());
        }
        
        // update the record
        if(listWhatId.size()>0){
            List<ResourceAbsence> listResourceAbsence=[SELECT ID FROM ResourceAbsence where Id in :listWhatId ];
            for(ResourceAbsence AR : listResourceAbsence){ 
                Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(ARWiseEvent.get(ar.Id).StartDateTime)/1000; 
                AR.Start=ARWiseEvent.get(ar.Id).StartDateTime.addSeconds(-(TimeZoneGMTdiffSec));
                AR.End= ARWiseEvent.get(ar.Id).EndDateTime.addDays(1).addSeconds(-(TimeZoneGMTdiffSec));    
                AR.Type=ARWiseEvent.get(ar.Id).Event_Type__c==null ||ARWiseEvent.get(ar.Id).Event_Type__c==''?'Personal':ARWiseEvent.get(ar.Id).Event_Type__c;  
            }
            
            Boolean currentFlag=ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT;
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=false;
            system.debug('listResourceAbsence' + listResourceAbsence.size());
            if(listResourceAbsence.size() > 0)
            { Update listResourceAbsence; }
            ResourceAbsenceTriggerHandler.CREATE_UPADTE_EVENT=currentFlag;
        }   
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        RAUpdateForAlldayEventsBatch b = new RAUpdateForAlldayEventsBatch(); 
        database.executebatch(b,1);
    }
}