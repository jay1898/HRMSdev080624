@RestResource(urlMapping='/ServicePOSTTimeblock/*')
global without sharing class ServicePOSTTimeblock 
{
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    

    global class Request
    {
        public String oppNo ; 
        public String start ; 
        public String end_z ; 
        public String zipcode;
        public string type;
        public string appType;
       
    }

    @HttpPost
    global static Response postData()
    {
        RestRequest reqst = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');

        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) return res ;
        
        try{
            Request req;
            
            String reqBody = reqst.requestBody.toString() ;
            reqBody = reqBody.replaceAll('"end"', '"end_z"');
            System.debug('reqBody ' + reqBody );
            // Try to deserialize REQUEST
            try{
                req = (Request)JSON.deserialize(reqBody,Request.class);
                req.appType=req.appType==null?'':req.appType;
                // Trim zip code if needed 
                req.zipcode = ServiceUtil.trimZipCode(req.zipcode);
                System.debug('req ' + req );
                
                if(String.isNotBlank(req.oppNo) && String.isNotBlank(req.start) && String.isNotBlank(req.end_z)
                   && String.isNotBlank(req.zipcode) && String.isNotBlank(req.type)){
                       
                       DateTime StartDateTime=DateTime.valueOf(req.start.replace('T', ' ').replace('Z', ''));
                       DateTime EndDateTime  =DateTime.valueOf(req.end_z.replace('T', ' ').replace('Z', ''));
					   Map<String,String> timeSlotResult=new Map<String,String>();
                       // check resource available
                       if(req.type.equalsIgnoreCase('Block') || req.type.equalsIgnoreCase('Both')){
                           timeSlotResult=getAvaialbleResourceCount(req.zipcode, StartDateTime, EndDateTime,req.oppNo,req.appType);
                           if(timeSlotResult.get('noOfResource')=='0'){ 
                               res.status = 'Failed';
                               res.errorMessage = 'RESOURCE NOT AVAILABLE:';
                               res.httpStatusCode = '400';
                               new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTTimeblock','postData',reqBody,'RESOURCE NOT AVAILABLE','Integration'));
                               return res;
                           }
                       }
                       
                       // Insert new record If type is Block
                       if(req.type.equalsIgnoreCase('Block')){
                           RTA_Timeblock__c TB=new RTA_Timeblock__c();
                           TB.Opportunity_No__c=req.oppNo;
                           TB.StartDate__c=StartDateTime;
                           TB.EndDate__c=EndDateTime ;
                           TB.Zipcode__c=req.zipcode;
                           if(timeSlotResult.containsKey('RTZoneId')){
                               TB.Zone__c=timeSlotResult.get('RTZoneId');
                           }
                           //TB.Type__c='Block';
                           Upsert TB Opportunity_No__c;
                       }
                       // Delete record if type is unblock
                       else if(req.type.equalsIgnoreCase('Unblock')){
                           delete [SELECT Id FROM RTA_Timeblock__c Where Zipcode__c=:req.zipcode and Opportunity_No__c= :req.oppNo];
                       }
                       // Update record if type is Both
                       else if(req.type.equalsIgnoreCase('Both')){
                           RTA_Timeblock__c TB=new RTA_Timeblock__c();
                           TB.Opportunity_No__c=req.oppNo;
                           TB.StartDate__c=StartDateTime;
                           TB.EndDate__c=EndDateTime;
                           TB.Zipcode__c=req.zipcode;
                           if(timeSlotResult.containsKey('RTZoneId')){
                               TB.Zone__c=timeSlotResult.get('RTZoneId');
                           }
                           //TB.Type__c='Both';
                           Upsert TB Opportunity_No__c;
                       }
                }else{
                    res.status = 'Failed';
                    res.errorMessage = 'Opportunity No,StartDate,Enddate,Zipcode and Type field must be required ';
                    res.httpStatusCode = '400';
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTTimeblock','postData',reqBody,JSON.serialize(res),'Integration'));
                }
            }catch (Exception e){
                res.status = e.getMessage();
                res.errorMessage = 'INVALID_INPUT_FORMAT:';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTTimeblock','postData',reqBody,JSON.serialize(res),e.getStackTraceString(),'Integration'));
                return res;
            }
            restRes.responseBody =Blob.valueOf( JSON.serialize(res));
           
        }
        catch(Exception ex){
            System.debug('exception ' + ex.getMessage() );
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTTimeblock','postData',reqst.requestBody.toString(),ex,'Integration'));
        }

        return res;
    }
    
    public static Map<String,String>  getAvaialbleResourceCount(String postalCode,DateTime StartDateTime,DateTime EndDateTime,String oppNo,String appType)
    {
        Map<String,String> resultMap=new Map<String,String>();
        resultMap.put('noOfResource', '0'); 
        Integer noOfResource=0;
        try{
            String canadianZipcode= !postalCode.isNumeric() && postalCode.length() > 3 ? postalCode.substring(0,3) + '%' : '' ;
            List<ServiceTerritory> STRec=[SELECT Id, ParentTerritoryId,ParentTerritory.ParentTerritoryId FROM ServiceTerritory WHERE RecordType.Name='Zipcode' and PostalCode!='' and (PostalCode=:postalCode or PostalCode Like :canadianZipcode ) Limit 1];
            if(STRec.size()>0) 
            {    
                resultMap.put('RTZoneId', STRec[0].ParentTerritory.ParentTerritoryId);
                List<ServiceTerritory> STList=[SELECT Id,Name,RecordType.Name, Address, City, Country, PostalCode, Street, State, ParentTerritoryId,ParentTerritory.Territory_Type__c,
                                               Territory_Type__c,OperatingHoursId,OperatingHours.TimeZone,OperatingHours.Local_Time__c,OperatingHours.Name,ParentTerritory.Branch__c,
                                               ParentTerritory.Branch__r.Branch_Number__c ,Weeks_Shown_Web__c,ApptDurationMin__c,Web_Hrs_Roll__c,Call_Center_Hrs_Roll__c,Showroom_Hrs_Roll__c,
                                               Weeks_Shown_Call_Center__c,Weeks_Shown_Showroom__c,Lead_receiver__c,Virtual_Appt_Duration_Min__c,
                                               (select Id,ServiceResourceId,ServiceResource.In_home_Eligible__c,ServiceResource.Virtual_Eligible__c,ServiceResource.relatedRecordId,EffectiveStartDate,EffectiveEndDate,ServiceResource.Weekly_Max_Appts__c,ServiceResource.Daily_Max_Appts__c from ServiceResources where ServiceResource.IsActive = TRUE and ServiceResource.Replacement_Sales_Rep__c=true AND ServiceResource.RelatedRecordId != NULL)
                                               FROM ServiceTerritory WHERE Id=:STRec[0].ParentTerritoryId];
                if(STList.size()>0)
                {
                    ServiceTerritory ST=STList[0];
                    // Check if Territory is RT
                    //if(ST.ParentTerritoryId!=null && ST.ParentTerritory.Territory_Type__c =='Retail')
                    if(ST.RecordType.Name =='RT Zone')
                    {
                        
                        // Get List Of Resource Id related to territory
                        Set<Id> resourceIds=new Set<Id>();
                        for(ServiceTerritoryMember STM : ST.ServiceResources){
                            
                             // If Consultation(appType) is In Home need to check resource eligible for in home or not
                            if(appType.equalsIgnoreCase(RTAIntegration.InHomeAppointment) && STM.ServiceResource.In_home_Eligible__c==false){
                                continue;
                            }
                            // If Consultation(appType) is In Virtual need to check resource eligible for virtual or not
                            else if(appType.equalsIgnoreCase(RTAIntegration.VirtualAppointment) && STM.ServiceResource.Virtual_Eligible__c==false){
                                continue;
                            }
                            
                            // if it's lead receive , do not include in the time slot availability - changed on 19-02
                            if(ST.Lead_Receiver__c!=null && STM.ServiceResource.relatedRecordId==ST.Lead_Receiver__c) {
                                continue;
                            }
                            
                            // check if daily limit is less or equal to zero
                            if(STM.ServiceResource.Daily_Max_Appts__c<=0){
                                continue;
                            }
                            // check if week limit is less or equal to zero
                            if(STM.ServiceResource.Weekly_Max_Appts__c<=0){
                                continue;
                            }
                            
                            resourceIds.add(STM.ServiceResourceId); 
                        }
                        
                        
                        // Get List of TimeBlocker Resource
                        List<RTA_Timeblock__c> listOfTimeBlockRes=[SELECT ID,StartDate__c,EndDate__c,zipcode__c from RTA_Timeblock__c Where Zone__c =:STRec[0].ParentTerritory.ParentTerritoryId and Opportunity_No__c !=:oppNo];
                        
                        Integer TimeZoneGMTdiffSec=Timezone.getTimeZone(ST.OperatingHours.TimeZone).getOffset(DateTime.now())/1000;
                        
                        // List of resource related to that terriroty
                        System.debug('UAC: resourceIds ' + resourceIds);
                        // RTA TimeBlock Resource Count
                        Integer totalBlockerResource=0;
                            
                        for(RTA_Timeblock__c TMResource : listOfTimeBlockRes)
                        {
                            if((StartDateTime<=TMResource.StartDate__c && TMResource.StartDate__c<EndDateTime)
                               ||(StartDateTime<TMResource.EndDate__c && TMResource.EndDate__c<EndDateTime)
                               || ( TMResource.StartDate__c<=StartDateTime && EndDateTime<=TMResource.EndDate__c )){
                                   totalBlockerResource++;
                            }
                            
                        }
                        
                        // Get list of allocated resource 
                        List<AssignedResource> assignedResources=[  SELECT Id,ServiceAppointment.Id,ServiceAppointment.SchedStartTime, ServiceAppointment.SchedEndTime,ServiceResourceId,ServiceResource.Daily_Max_Appts__c,ServiceResource.Weekly_Max_Appts__c 
                                                                  FROM AssignedResource 
                                                                  WHERE ServiceResourceId IN :resourceIds AND ServiceAppointment.SchedStartTime != NULL
                                                                  AND (
                                                                      (ServiceAppointment.SchedStartTime>:StartDateTime.addDays(-1) AND ServiceAppointment.SchedStartTime<=:EndDateTime.addDays(1))
                                                                      OR(ServiceAppointment.SchedEndTime=null OR (ServiceAppointment.SchedEndTime>=:StartDateTime.addDays(-1) AND ServiceAppointment.SchedEndTime<=:EndDateTime.addDays(1)))) ];
                        
                        // Get list of allocated resource 
                        /*List<ResourceAbsence> absenceResources=[  SELECT Id,Start,End,ResourceId  
                                                                FROM ResourceAbsence 
                                                                WHERE ResourceId IN :resourceIds 
                                                                AND (
                                                                    (Start>:StartDateTime AND Start<=:EndDateTime)
                                                                    OR(End=null OR (End>=:StartDateTime AND End<=:EndDateTime)))];*/
                        //changed on 09-07-20 (availability issue)
                        List<ResourceAbsence> absenceResources=[  SELECT Id,Start,End,ResourceId  
                                                                FROM ResourceAbsence 
                                                                WHERE ResourceId IN :resourceIds 
                                                                AND ((Start>=:StartDateTime.addDays(-1) AND Start<:EndDateTime.addDays(1))
                                                                     OR(END>:StartDateTime.addDays(-1) AND END<:EndDateTime.addDays(1))
                                                                     OR( Start<=:StartDateTime.addDays(-1) AND END>=:EndDateTime.addDays(1) ))];
						
                        
                        Map<String,Integer> resourceWisePerDayCount = new Map<String,Integer>();
                        Map<String,Integer> resourceWiseWeekCount = new Map<String,Integer>();
                        for(AssignedResource AR : assignedResources)
                        {
                            Date d = Date.valueOf(AR.ServiceAppointment.SchedStartTime.addSeconds(TimeZoneGMTdiffSec));
                            String dat=d.year()+'-'+d.month()+'-'+d.day();
                            
                            if(!resourceWisePerDayCount.containsKey(AR.ServiceResourceId+'_'+dat)){
                                resourceWisePerDayCount.put(AR.ServiceResourceId+'_'+dat,0);
                            }
                            resourceWisePerDayCount.put(AR.ServiceResourceId+'_'+dat,resourceWisePerDayCount.get(AR.ServiceResourceId+'_'+dat)+1);
                        }
                        
                        System.debug('resourceWisePerDayCount : '+resourceWisePerDayCount);
                        
                        /*for(String resourceByDay : resourceWisePerDayCount.keySet())
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
                        }*/
                        
                        //System.debug('resourceWiseWeekCount : '+resourceWiseWeekCount);
                        
                        // Get Time slot
                       
                        
                        // Get Today Date and dayOfWeek
                        Date d;
                        String dayOfWeek;
                        // get time slot of different days
                        DateTime curr=StartDateTime;
                        d=curr.date();
                        dayOfWeek = curr.format('EEEE');
                        String dayKey= d.year()+'-'+d.month()+'-'+d.day();
                        System.debug('resourceWisePerDayCount ::  ' + resourceWisePerDayCount );
                        Set<Id> alreadyAssignedDayorWeek = new Set<Id>();
                        for(AssignedResource ar : assignedResources)
                        {
                            System.debug('day 1::  ' + resourceWisePerDayCount.get(ar.ServiceResourceId+'_'+dayKey) +' : '+ar.ServiceResource.Daily_Max_Appts__c );
                            
                            // check per day count
                            if(resourceWisePerDayCount.containsKey(ar.ServiceResourceId+'_'+dayKey)){
                                
                                if(resourceWisePerDayCount.get(ar.ServiceResourceId+'_'+dayKey)>=ar.ServiceResource.Daily_Max_Appts__c){
                                    alreadyAssignedDayorWeek.add(ar.serviceResourceId);
                                    continue;
                                }
                            }
                            
                            //System.debug('week  1::  ' + resourceWiseWeekCount.get(ar.ServiceResourceId+'_'+dayKey) +' : '+ar.ServiceResource.Weekly_Max_Appts__c );
                            
                            // check week day count
                            /*if(resourceWiseWeekCount.containsKey(ar.ServiceResourceId+'_'+dayKey) ){
                                
                                if(resourceWiseWeekCount.get(ar.ServiceResourceId+'_'+dayKey)>=ar.ServiceResource.Weekly_Max_Appts__c){
                                    alreadyAssignedDayorWeek.add(ar.serviceResourceId);
                                    System.debug('alreadyAssignedDayorWeek 2::  ' + alreadyAssignedDayorWeek );
                                }
                            } */   
                        }
                        System.debug('alreadyAssignedDayorWeek ::  ' + alreadyAssignedDayorWeek );
                        
                        Set<Id> alreadyAssigned = new Set<Id>();
                        TimeZoneGMTdiffSec=Timezone.getTimeZone(ST.OperatingHours.TimeZone).getOffset(StartDateTime)/1000;
                        // remove absence Resources
                        
                        for(ResourceAbsence RA :absenceResources){
                            if(alreadyAssigned.contains(RA.ResourceId) ){
                                continue;
                            }
                            
                            /*if(StartDateTime>=RA.Start.addSeconds(TimeZoneGMTdiffSec) && StartDateTime<RA.END.addSeconds(TimeZoneGMTdiffSec)){
                                alreadyAssigned.add(RA.ResourceId);
                            }*/
                            // Changed on 19-03 To resolve avialblity issue
                             if((StartDateTime<=RA.Start.addSeconds(TimeZoneGMTdiffSec) && RA.Start.addSeconds(TimeZoneGMTdiffSec)<EndDateTime)
                               ||(StartDateTime<RA.END.addSeconds(TimeZoneGMTdiffSec) && RA.END.addSeconds(TimeZoneGMTdiffSec)<EndDateTime)
                               || ( RA.Start.addSeconds(TimeZoneGMTdiffSec)<=StartDateTime && EndDateTime<=RA.END.addSeconds(TimeZoneGMTdiffSec) ) ){
                                   alreadyAssigned.add(RA.ResourceId);
                               }

                            
                        }
                        
                        for(AssignedResource ar : assignedResources)
                        {
                            
                            if(alreadyAssigned.contains(ar.ServiceResourceId)){
                                continue;
                            }
                            else if(alreadyAssignedDayorWeek.contains(ar.ServiceResourceId)){
                                alreadyAssigned.add(ar.serviceResourceId);
                                continue;
                            }
                            if((StartDateTime<=ar.ServiceAppointment.SchedStartTime.addSeconds(TimeZoneGMTdiffSec) && ar.ServiceAppointment.SchedStartTime.addSeconds(TimeZoneGMTdiffSec)<EndDateTime)
                               ||(StartDateTime<ar.ServiceAppointment.SchedEndTime.addSeconds(TimeZoneGMTdiffSec) && ar.ServiceAppointment.SchedEndTime.addSeconds(TimeZoneGMTdiffSec)<EndDateTime)
                               || ( ar.ServiceAppointment.SchedStartTime.addSeconds(TimeZoneGMTdiffSec)<=StartDateTime && EndDateTime<=ar.ServiceAppointment.SchedEndTime.addSeconds(TimeZoneGMTdiffSec) )){
                                   alreadyAssigned.add(ar.serviceResourceId);
                               }
                            
                        }
                        Integer k=0;
                        
                        set<String> setResourceIds=new set<String>();
                        for(Id resourceId : resourceIds)
                        {
                            if(!alreadyAssigned.contains(resourceId))
                            {
                                if(k<totalBlockerResource){
                                    k++;
                                    continue;
                                }
                                setResourceIds.add(resourceId);
                            }
                        }
                        
                        
                        noOfResource=	setResourceIds.size(); 
                        resultMap.put('noOfResource', ''+noOfResource);
                    }
                    else{
                        
                        // Not RT
                        new ApexDebugLog().createLog(
                            new ApexDebugLog.Error(
                                'ServicePOSTTimeblock',
                                'getTimeSlotDetails',
                                postalCode,
                                'Zipcode Not In RT Zone',
                                null,
                                'Integration'
                            )
                        );
                        
                    }
                }else{
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTTimeblock','getTimeSlotDetails',postalCode,'RT Zone does not exist',null,'Integration'));
                }
            }else{
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'ServicePOSTTimeblock',
                        'getTimeSlotDetails',
                        postalCode,
                        'Zip code does not exist',
                        null,
                        'Integration'
                    )
                );
            }
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('RTAIntegration','getTimeSlotDetails',postalCode,ex,'Integration'));
        }
        //return noOfResource;
        return resultMap;
    }
}