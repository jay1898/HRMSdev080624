public without sharing class validOpportunityOwnerController {
    @AuraEnabled
    public static String getValidOwnerList(String recordId) {
        List<OppOwnerWrapper> OppOwnerList=new List<OppOwnerWrapper>();
        String ZoneId;
        DateTime SAStartTime;
        DateTime SAEndTime;
        String appId;
        String saOwnerId;
        Boolean isVirtual=false;
        List<ServiceAppointment> listSA=[SELECT ID,OwnerId,Opportunity__r.Zone__c,SchedStartTime,SchedEndTime,Virtual_Appointment__c  FROM ServiceAppointment Where Id=:recordId or Opportunity__C =:recordId];
        for(ServiceAppointment sa : listSA){
            if(sa.Opportunity__r.zone__c!=null){
                ZoneId=sa.Opportunity__r.zone__c;
                SAStartTime=sa.SchedStartTime;
                SAEndTime=sa.SchedEndTime;
                appId=sa.Id;
                saOwnerId=sa.OwnerId;
                isVirtual=sa.Virtual_Appointment__c;
            }
        }
        if(ZoneId==null){
            throw new AuraHandledException('No Related Service Territory Found');
        }
        List<ServiceTerritoryMember> listSTM=[SELECT Id,ServiceTerritoryId,EffectiveStartDate,EffectiveEndDate,ServiceResourceId,
                                              ServiceResource.RelatedRecordId,ServiceResource.RelatedRecord.Name,
                                              ServiceResource.In_home_Eligible__c,ServiceResource.Virtual_Eligible__c
                                              FROM ServiceTerritoryMember 
                                              Where ServiceTerritoryId = : ZoneId
                                              and ServiceResource.isActive = true
                                              and EffectiveStartDate<=:SAStartTime 
                                              and (EffectiveEndDate=null or EffectiveEndDate>= :SAEndTime)
                                              and  ServiceResource.Replacement_Sales_Rep__c=true
                                              and  ServiceResource.RelatedRecordId != :saOwnerId
                                             ];
        set<Id> setSRIds=new set<Id>();
        for(ServiceTerritoryMember STM: listSTM){
            // Check Virtual and home eligibility
            if((isVirtual && STM.ServiceResource.Virtual_Eligible__c) || (!isVirtual && STM.ServiceResource.In_home_Eligible__c))
            {
                setSRIds.add(STM.ServiceResourceId);
            }
        }
        // Check ServiceTerritoryMember exist as primary
        List<ServiceTerritoryMember> listPrimarySTM=[SELECT Id,ServiceTerritoryId,EffectiveStartDate,EffectiveEndDate,ServiceResourceId,
                                                     ServiceResource.RelatedRecordId,ServiceResource.RelatedRecord.Name,
                                                     ServiceResource.Weekly_Max_Appts__c,ServiceResource.Daily_Max_Appts__c,
                                                     ServiceResource.Virtual_Eligible__c,ServiceResource.In_home_Eligible__c
                                                     FROM ServiceTerritoryMember 
                                                     Where ServiceResourceId = : setSRIds and TerritoryType='P' ];
        set<Id> setOwnerId=new set<Id>();
        set<Id> resourceIds=new set<Id>();
        for(ServiceTerritoryMember STM: listPrimarySTM){
            setOwnerId.add(STM.ServiceResource.RelatedRecordId);
            resourceIds.add(STM.ServiceResourceId);
        }
        
        
        List<ServiceAppointment> listSAList=[SELECT ID,AppointmentNumber,SchedStartTime,SchedEndTime,OwnerId FROM ServiceAppointment 
                                             Where OwnerId=:setOwnerId 
                                             and ((SchedStartTime<= :SAStartTime And SchedEndTime > :SAStartTime)
                                              OR (SchedStartTime< :SAEndTime AND SchedEndTime> :SAEndTime)
                                              OR ( SchedStartTime>= :SAStartTime AND SchedEndTime<= :SAEndTime ))
                                             and Id !=:appId order by SchedStartTime];
        Map<String,List<ServiceAppointment>> mapOwnerWiseSA=new Map<String,List<ServiceAppointment>>();
        for(ServiceAppointment SA : listSAList){
            if(!mapOwnerWiseSA.containsKey(SA.OwnerId)){
                mapOwnerWiseSA.put(SA.OwnerId,new List<ServiceAppointment>());
            }
            mapOwnerWiseSA.get(SA.OwnerId).add(SA);
        }
        List<ResourceAbsence> listRAList=[SELECT ID,AbsenceNumber,Start,End,ResourceId,Resource.RelatedRecordId FROM ResourceAbsence 
                                             Where Resource.RelatedRecordId=:setOwnerId 
                                             and ((Start<= :SAStartTime And End > :SAStartTime)
                                              OR (Start< :SAEndTime AND End> :SAEndTime)
                                              OR ( Start>= :SAStartTime AND End<= :SAEndTime ))
                                             and Id !=:appId order by Start];
        Map<String,List<ResourceAbsence>> mapUserWiseRA=new Map<String,List<ResourceAbsence>>();
        for(ResourceAbsence RA : listRAList){
            if(!mapUserWiseRA.containsKey(RA.Resource.RelatedRecordId)){
                mapUserWiseRA.put(RA.Resource.RelatedRecordId,new List<ResourceAbsence>());
            }
            mapUserWiseRA.get(RA.Resource.RelatedRecordId).add(RA);
        }
        
        // Get list of allocated resource 
        List<AssignedResource> assignedResources=[  SELECT Id,ServiceAppointment.Id,ServiceAppointment.SchedStartTime, ServiceAppointment.SchedEndTime,ServiceResourceId,ServiceResource.Daily_Max_Appts__c,ServiceResource.Weekly_Max_Appts__c 
                                                  FROM AssignedResource 
                                                  WHERE ServiceResourceId IN :resourceIds AND ServiceAppointment.SchedStartTime != NULL and ServiceAppointmentId !=:appId 
                                                  AND (
                                                      (ServiceAppointment.SchedStartTime>:SAStartTime.addDays(-1) AND ServiceAppointment.SchedStartTime<=:SAEndTime.addDays(7))
                                                      OR(ServiceAppointment.SchedEndTime=null OR (ServiceAppointment.SchedEndTime>=:SAStartTime.addDays(-1) AND ServiceAppointment.SchedEndTime<=:SAEndTime.addDays(7)))) ];
        
      
        Map<String,Integer> resourceWisePerDayCount = new Map<String,Integer>();
        Map<String,Integer> resourceWiseWeekCount = new Map<String,Integer>();
        for(AssignedResource AR : assignedResources)
        {
            Date d = Date.valueOf(AR.ServiceAppointment.SchedStartTime);
            String dat=d.year()+'-'+d.month()+'-'+d.day();
            
            if(!resourceWisePerDayCount.containsKey(AR.ServiceResourceId+'_'+dat)){
                resourceWisePerDayCount.put(AR.ServiceResourceId+'_'+dat,0);
            }
            resourceWisePerDayCount.put(AR.ServiceResourceId+'_'+dat,resourceWisePerDayCount.get(AR.ServiceResourceId+'_'+dat)+1);
        }
        
        System.debug('resourceWisePerDayCount : '+resourceWisePerDayCount);
        
        for(String resourceByDay : resourceWisePerDayCount.keySet())
        {
            String[] keys=resourceByDay.split('_');
            String[] dates=keys[1].split('-');
            
            Date da=Date.newInstance(Integer.valueOf(dates[0]),Integer.valueOf(dates[1]),Integer.valueOf( dates[2]));
            String resourceId=keys[0];
            
            Integer noOfCount=0;
            Integer tempCnt;
            for(integer k=0;k<7;k++ )
            {
                tempCnt=resourceWisePerDayCount.get(resourceId+'_'+da.year()+'-'+da.month()+'-'+da.day());
                noOfCount+=tempCnt==null?0:tempCnt;
                da=da.addDays(k);
            }
            resourceWiseWeekCount.put(resourceByDay,noOfCount);
        }
        
        System.debug('resourceWiseWeekCount : '+resourceWiseWeekCount);
        // get time slot of different days
        DateTime curr=SAStartTime;
        Date d=curr.date();
        String dayKey= d.year()+'-'+d.month()+'-'+d.day();
        System.debug('resourceWisePerDayCount ::  ' + resourceWisePerDayCount );
        
        
        for(ServiceTerritoryMember STM: listPrimarySTM){
            OppOwnerWrapper OppOwner=new OppOwnerWrapper();
            OppOwner.OwnerId=STM.ServiceResource.RelatedRecordId;
            OppOwner.OwnerName=STM.ServiceResource.RelatedRecord.Name;
            if(mapOwnerWiseSA.containsKey(OppOwner.OwnerId)){
                OppOwner.hasAppointment=true;
                OppOwner.listAppointment=mapOwnerWiseSA.get(OppOwner.OwnerId);
            }
            if(mapUserWiseRA.containsKey(OppOwner.OwnerId)){
                OppOwner.hasAppointment=true;
                OppOwner.listResourceAbsence=mapUserWiseRA.get(OppOwner.OwnerId);
            }
            
            
            // check if daily limit is less or equal to zero
            if(STM.ServiceResource.Daily_Max_Appts__c<=0){
                OppOwner.perDayCountExceed=true;
            }
            // check if week limit is less or equal to zero
            if(STM.ServiceResource.Weekly_Max_Appts__c<=0){
                OppOwner.perWeekCountExceed=true;
            }
            // check per day count
            if(resourceWisePerDayCount.containsKey(STM.ServiceResourceId+'_'+dayKey)){
                
                if(resourceWisePerDayCount.get(STM.ServiceResourceId+'_'+dayKey)>=STM.ServiceResource.Daily_Max_Appts__c){
                    // perday count excceed
                    OppOwner.perDayCountExceed=true;
                }
            }
            
            System.debug('week  1::  ' + resourceWiseWeekCount.get(STM.ServiceResourceId+'_'+dayKey) +' : '+STM.ServiceResource.Weekly_Max_Appts__c );
            
            // check week day count
            if(resourceWiseWeekCount.containsKey(STM.ServiceResourceId+'_'+dayKey) ){
                
                if(resourceWiseWeekCount.get(STM.ServiceResourceId+'_'+dayKey)>=STM.ServiceResource.Weekly_Max_Appts__c){
                    // per week count exceed
                    OppOwner.perWeekCountExceed=true;
                }
            } 
            
            OppOwnerList.add(OppOwner);
        }
        
        return JSON.serialize(OppOwnerList);
    }
    
    public class OppOwnerWrapper{
        public string OwnerId;
        public String OwnerName;
        public Boolean hasAppointment;
        public Boolean perDayCountExceed;
        public Boolean perWeekCountExceed;
        public List<ServiceAppointment> listAppointment;
        public List<ResourceAbsence> listResourceAbsence;
    }
    
}