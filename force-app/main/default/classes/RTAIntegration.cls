public without sharing  class  RTAIntegration {
    public static Integer weeksShown=2; 
    public static Integer apptDurationMin=30;
    public static Integer apptLimitsPerWeek=16; 
    public static Integer apptLimitsPerDay=4;
    public static String InHomeAppointment='home';
    public static String VirtualAppointment='virtual';
    public static String getTimeSlotDetails(String postalCode,Boolean isVirtual){
        return getTimeSlotDetails(postalCode,'',isVirtual?VirtualAppointment:InHomeAppointment);
        //return getTimeSlotDetails(postalCode,'','');
    } 
    
    
    public static String getTimeSlotDetails(String postalCode,String sourceType,String appType)
    {
		        
        //Get Territory Related to Zipcode
        reponseWrapper res=new reponseWrapper();
        
        try{
            res.status='success';
            String canadianZipcode= !postalCode.isNumeric() && postalCode.length() > 3 ? postalCode.substring(0,3) + '%' : '' ;
            List<ServiceTerritory> STRec=[SELECT Id, ParentTerritoryId FROM ServiceTerritory WHERE RecordType.Name='Zipcode' and PostalCode!='' and (PostalCode=:postalCode or PostalCode Like :canadianZipcode ) Limit 1];
            if(STRec.size()>0)
            {    
                List<ServiceTerritory> STList=[SELECT Id,Name,RecordType.Name, Address, City, Country, PostalCode, Street, State, ParentTerritoryId,ParentTerritory.Territory_Type__c,
                                               Territory_Type__c,OperatingHoursId,OperatingHours.TimeZone,OperatingHours.Local_Time__c,OperatingHours.Name,ParentTerritory.Branch__c,
                                               ParentTerritory.Branch__r.Branch_Number__c ,Weeks_Shown_Web__c,ApptDurationMin__c,Web_Hrs_Roll__c,Call_Center_Hrs_Roll__c,Showroom_Hrs_Roll__c,
                                               Weeks_Shown_Call_Center__c,Weeks_Shown_Showroom__c,Lead_receiver__c,Virtual_Appt_Duration_Min__c,
                                               (select Id,ServiceResource.In_home_Eligible__c,ServiceResource.Virtual_Eligible__c,ServiceResourceId,ServiceResource.relatedRecordId,EffectiveStartDate,EffectiveEndDate,ServiceResource.Weekly_Max_Appts__c,ServiceResource.Daily_Max_Appts__c from ServiceResources where ServiceResource.IsActive = TRUE and ServiceResource.Replacement_Sales_Rep__c=true AND ServiceResource.RelatedRecordId != NULL)
                                               FROM ServiceTerritory WHERE Id=:STRec[0].ParentTerritoryId];
                if(STList.size()>0)
                {
                    ServiceTerritory ST=STList[0];
                    // Check if Territory is RT
                    //if(ST.ParentTerritoryId!=null && ST.ParentTerritory.Territory_Type__c =='Retail')
                    if(ST.RecordType.Name =='RT Zone')
                    {
                        System.debug('Zipcode In RT Zone');
                        res.TerritoryZone='RT';
                        // Get Territory Zone
                        System.debug('Territory Zone :: '+ ST.ParentTerritory.Territory_Type__c);
                        
                        // Get Branch Number
                        System.debug('BranchNumber :: '+ ST.ParentTerritory.Branch__r.Branch_Number__c);
                        res.BranchID=ST.ParentTerritory.Branch__r.Branch_Number__c;
                        
                        res.TimezoneInfo=new TimezoneInfo();
                        
                        // Get TimeZone Detail Of Current Territory
                        System.debug('UAC: ST OperatingHours Name '+ ST.OperatingHours.Name);
                        res.TimezoneInfo.Name=ST.OperatingHours.Name;
                        
                        // Get TimeZone Detail Of Current Territory
                        System.debug('TimeZone :: '+ ST.OperatingHours.TimeZone);
                        res.TimezoneInfo.TIMEZONE_CODE=ST.OperatingHours.TimeZone;
                        res.TimezoneInfo.STANDARD_TIME_SHORT_CODE=ST.OperatingHours.Local_Time__c;
                        
                        if(sourceType.equalsIgnoreCase('Lead Only')){
                            List<Campaign> lstCampaign = [SELECT Id, Name FROM Campaign WHERE Status = 'Active' AND Business_Segment__c = 'Replacement' AND ((Type = 'Branch' AND Branch_Name__c =: ST.ParentTerritory.Branch__c) OR Type ='Generic')];
                            if(lstCampaign.size() > 0){
                                List<campaignWrapper> CampaignNames = new List<campaignWrapper>();
                                for(Campaign cmp : lstCampaign){
                                    campaignWrapper cw = new campaignWrapper();
                                    cw.campaignName = cmp.Name;
                                    cw.campaignId = cmp.Id;
                                    CampaignNames.add(cw);
                                }
                                res.campaigns = CampaignNames;
                                
                            }
                            return JSON.serialize(res);
                        }
                        
                        // Get List Of Resource Id related to territory
                        Set<Id> resourceIds=new Set<Id>();
                        for(ServiceTerritoryMember STM : ST.ServiceResources){
                            
                            // If Consultation(appType) is In Home need to check resource eligible for in home or not
                            if(appType.equalsIgnoreCase(InHomeAppointment) && STM.ServiceResource.In_home_Eligible__c==false){
                                continue;
                            }
                            // If Consultation(appType) is In Virtual need to check resource eligible for virtual or not
                            else if(appType.equalsIgnoreCase(VirtualAppointment) && STM.ServiceResource.Virtual_Eligible__c==false){
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
                        
                        system.debug('@@resourceIds :: '+resourceIds.size());
                        // Get List of TimeBlocker Resource
                        //List<RTA_Timeblock__c> listOfTimeBlockRes=[SELECT ID,StartDate__c,EndDate__c,zipcode__c from RTA_Timeblock__c Where Zipcode__c =:postalCode];
                        // Changed on 09-06 to resolve duplicate issue
                        List<RTA_Timeblock__c> listOfTimeBlockRes=[SELECT ID,StartDate__c,EndDate__c,zipcode__c from RTA_Timeblock__c Where Zone__c =:ST.ParentTerritoryId];
                        
                        // List of resource related to that terriroty
                        //System.debug('UAC: resourceIds ' + resourceIds);
                        Integer noOfDays=7; 
                        if(sourceType.equalsIgnoreCase('Web')){
                            noOfDays= (ST.Weeks_Shown_Web__c == null ? weeksShown : Integer.valueOf(ST.Weeks_Shown_Web__c)*7);
                            
                        }else if(sourceType.equalsIgnoreCase('Call Center')){
                            noOfDays= (ST.Weeks_Shown_Call_Center__c == null ? weeksShown : Integer.valueOf(ST.Weeks_Shown_Call_Center__c)*7);
                        }
                        else if(sourceType.equalsIgnoreCase('Showroom')){
                            noOfDays= (ST.Weeks_Shown_Showroom__c == null ? weeksShown : Integer.valueOf(ST.Weeks_Shown_Showroom__c)*7);
                            
                        }else{
                            noOfDays= (ST.Weeks_Shown_Web__c == null ? weeksShown : Integer.valueOf(ST.Weeks_Shown_Web__c)*7);
                            Integer Temp= (ST.Weeks_Shown_Call_Center__c == null ? weeksShown : Integer.valueOf(ST.Weeks_Shown_Call_Center__c)*7);
                            if(temp>noOfDays){
                                noOfDays=temp;
                            }
                            Temp=  (ST.Weeks_Shown_Showroom__c == null ? weeksShown : Integer.valueOf(ST.Weeks_Shown_Showroom__c)*7);
                            if(temp>noOfDays){
                                noOfDays=temp;
                            }
                        } 
                        
                        //Change Date : 31/12/2019 - Added campaign in response where sourcetype = showroom
                        if(sourceType.equalsIgnoreCase('Showroom')){
                            List<Campaign> lstCampaign = [SELECT Id, Name FROM Campaign WHERE Status = 'Active' AND Business_Segment__c = 'Replacement' AND ((Type = 'Branch' AND Branch_Name__c =: ST.ParentTerritory.Branch__c) OR Type ='Generic') ];
                            if(lstCampaign.size() > 0){
                                List<campaignWrapper> CampaignNames = new List<campaignWrapper>();
                                for(Campaign cmp : lstCampaign){
                                    campaignWrapper cw = new campaignWrapper();
                                    cw.campaignName = cmp.Name;
                                    cw.campaignId = cmp.Id;
                                    CampaignNames.add(cw);
                                }
                                res.campaigns = CampaignNames;
                                
                            }
                        }
                        
                        Integer durationMin = ST.ApptDurationMin__c==null ? apptDurationMin : Integer.valueOf(ST.ApptDurationMin__c);
                        
                        // If Consultation(appType) is Virtual then use vitual field for duration
                        if(appType.equalsIgnoreCase(VirtualAppointment)){
                            durationMin = ST.Virtual_Appt_Duration_Min__c==null ? durationMin : Integer.valueOf(ST.Virtual_Appt_Duration_Min__c);
                        }
                        
                        Integer TimeZoneGMTdiffSec=Timezone.getTimeZone(res.TimezoneInfo.TIMEZONE_CODE).getOffset(DateTime.now())/1000;
                        
                        DateTime CurrentDateTime=DateTime.now().addSeconds(TimeZoneGMTdiffSec);
                        DateTime webHoursRoll = CurrentDateTime;
                        
                        if(sourceType.equalsIgnoreCase('Web')){
                            webHoursRoll=webHoursRoll.addHours(Integer.valueOf(ST.Web_Hrs_Roll__c==null?0:ST.Web_Hrs_Roll__c));
                        }else if(sourceType.equalsIgnoreCase('Call Center')){
                            webHoursRoll=webHoursRoll.addHours(Integer.valueOf(ST.Call_Center_Hrs_Roll__c==null?0:ST.Call_Center_Hrs_Roll__c));
                        }
                        else if(sourceType.equalsIgnoreCase('Showroom')){
                            webHoursRoll=webHoursRoll.addHours(Integer.valueOf(ST.Showroom_Hrs_Roll__c==null?0:ST.Showroom_Hrs_Roll__c));
                        }
                        
                        System.debug('@@ webHoursRoll :: '+webHoursRoll);
                        Map<DateTime,Integer> blockerResource=new Map<DateTime,Integer>();
                        // RTA TimeBlock Resource Count
                        for(RTA_Timeblock__c TMResource : listOfTimeBlockRes)
                        {
                            DateTime startDate=TMResource.StartDate__c.addMinutes(-(durationMin-30));
                            while(startDate<TMResource.EndDate__c){
                                if(!blockerResource.containsKey(startDate)){
                                    blockerResource.put(startDate,0);
                                }
                                blockerResource.put(startDate,blockerResource.get(startDate)+1);
                                startDate=startDate.addMinutes(30);
                            }
                        }
                        
                        // Get list of allocated resource 
                        List<AssignedResource> assignedResources=[  SELECT Id,ServiceAppointment.Id,ServiceAppointment.SchedStartTime, ServiceAppointment.SchedEndTime,ServiceResourceId,ServiceResource.Daily_Max_Appts__c,ServiceResource.Weekly_Max_Appts__c 
                                                                  FROM AssignedResource 
                                                                  WHERE ServiceResourceId IN :resourceIds AND ServiceAppointment.SchedStartTime != NULL
                                                                  AND (
                                                                      (ServiceAppointment.SchedStartTime>:CurrentDateTime.addHours(-apptDurationMin) AND ServiceAppointment.SchedStartTime<=:CurrentDateTime.addDays(noOfDays))
                                                                      OR(ServiceAppointment.SchedEndTime=null OR (ServiceAppointment.SchedEndTime>=:CurrentDateTime.addHours(-apptDurationMin) AND ServiceAppointment.SchedEndTime<=:CurrentDateTime.addDays(noOfDays)))) ];
                        
                        // Get list of allocated resource 
                        List<ResourceAbsence> absenceResources=[  SELECT Id,Start,End,ResourceId  
                                                                FROM ResourceAbsence 
                                                                WHERE ResourceId IN :resourceIds 
                                                                AND (
                                                                    (Start>:CurrentDateTime.addHours(-apptDurationMin) AND Start<=:CurrentDateTime.addDays(noOfDays))
                                                                    OR(End=null OR (End>=:CurrentDateTime.addHours(-apptDurationMin) AND End<=:CurrentDateTime.addDays(noOfDays)))
                                                                    OR ( Start<=:CurrentDateTime.addHours(-apptDurationMin) AND END>=:CurrentDateTime.addDays(noOfDays) ))];
                        
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
                        
                        //System.debug('resourceWisePerDayCount : '+resourceWisePerDayCount);
                        
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
                        Map<String,List<TimeSlot>> weekDayWiseTimeSlots=new Map<String,List<TimeSlot>>();
                        List<TimeSlot> timeSlots =[ SELECT Id,  TimeSlotNumber, OperatingHoursId, StartTime, EndTime, DayOfWeek, Type, FSL__Designated_Work_Boolean_Fields__c, FSL__Slot_Color__c 
                                                   FROM TimeSlot 
                                                   WHERE OperatingHoursId =:ST.OperatingHoursId
                                                   ORDER BY DayOfWeek,StartTime];
                        for(TimeSlot TS : timeSlots)
                        {
                            if(!weekDayWiseTimeSlots.containsKey(TS.dayOfWeek)){
                                weekDayWiseTimeSlots.put(TS.dayOfWeek,new List<TimeSlot>());
                            }
                            weekDayWiseTimeSlots.get(TS.dayOfWeek).add(TS);
                        }
                        //System.debug('UAC: weekDayWiseTimeSlots ' + weekDayWiseTimeSlots );
                        
                        List<TimeSlots> availableTimeSlots = new List<TimeSlots>();
                        
                        
                        // Get Today Date and dayOfWeek
                        Date d;
                        String dayOfWeek,dayKey;
                        DateTime curr;
                        Set<Id> alreadyAssignedDayorWeek;
                        Set<Id> alreadyAssigned;
                        Time currentTime,endTime;
                        DateTime START_DATE_TIME,END_DATE_TIME;
                        System.debug('UAC: noOfDays ' + noOfDays );
                        // Get time slot of next WeeksShown days
                        for(Integer i=0; i<noOfDays; i++)
                        {
                            // get time slot of different days
                            curr=CurrentDateTime.addDays(i);
                            d=curr.date();
                            dayOfWeek = curr.format('EEEE');
                            dayKey= d.year()+'-'+d.month()+'-'+d.day();
                            //System.debug('resourceWisePerDayCount ::  ' + resourceWisePerDayCount );
                            alreadyAssignedDayorWeek = new Set<Id>();
                            for(AssignedResource ar : assignedResources)
                            {
                                //System.debug('day 1::  ' + resourceWisePerDayCount.get(ar.ServiceResourceId+'_'+dayKey) +' : '+ar.ServiceResource.Daily_Max_Appts__c );
                                
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
                                        //System.debug('alreadyAssignedDayorWeek 2::  ' + alreadyAssignedDayorWeek );
                                    }
                                } */   
                            }
                            //System.debug('alreadyAssignedDayorWeek ::  ' + alreadyAssignedDayorWeek );
                            if(weekDayWiseTimeSlots.containsKey(dayOfWeek))
                            {
                                for(Timeslot TS : weekDayWiseTimeSlots.get(dayOfWeek))
                                {    
                                    currentTime = TS.StartTime;
                                    endTime = TS.EndTime.addMinutes(-durationMin);
                                    
                                    while(currentTime<=endTime)
                                    {
                                        TimeSlots timeslot=new TimeSlots();
                                        timeslot.START_DATE=DateTime.newInstanceGMT(d,currentTime);
                                        timeslot.END_DATE=DateTime.newInstanceGMT(d,currentTime.addMinutes(durationMin));
                                        
                                        currentTime=currentTime.addMinutes(30);
                                        
                                        // check hours
                                        if(timeslot.START_DATE<webHoursRoll){
                                            continue;
                                        } 
                                        
                                        timeslot.RESOURCE_ID = new Set<String>();
                                        alreadyAssigned = new Set<Id>();
                                        TimeZoneGMTdiffSec=Timezone.getTimeZone(res.TimezoneInfo.TIMEZONE_CODE).getOffset(timeslot.START_DATE)/1000;
                                        START_DATE_TIME=timeslot.START_DATE.addSeconds(TimeZoneGMTdiffSec*-1);
                                        END_DATE_TIME=timeslot.END_DATE.addSeconds(TimeZoneGMTdiffSec*-1);
                                        // remove absence Resources
                                        
                                        for(ResourceAbsence RA :absenceResources){
                                            if(alreadyAssigned.contains(RA.ResourceId) ){
                                                continue;
                                            }
                                            
                                            /*if(START_DATE_TIME>=RA.Start && START_DATE_TIME<RA.END){
                                                alreadyAssigned.add(RA.ResourceId);
                                            }*/
                                            // Changed on 19-03 To resolve avialblity issue
                                            if((START_DATE_TIME<=RA.Start && RA.Start<END_DATE_TIME)
                                               ||(START_DATE_TIME<RA.END && RA.END<END_DATE_TIME)
                                               ||( RA.Start<=START_DATE_TIME && END_DATE_TIME<=RA.END )){
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
                                            if((START_DATE_TIME<=ar.ServiceAppointment.SchedStartTime && ar.ServiceAppointment.SchedStartTime<END_DATE_TIME)
                                               ||(START_DATE_TIME<ar.ServiceAppointment.SchedEndTime && ar.ServiceAppointment.SchedEndTime<END_DATE_TIME)
                                               ||( ar.ServiceAppointment.SchedStartTime<=START_DATE_TIME && END_DATE_TIME<=ar.ServiceAppointment.SchedEndTime ) ){
                                                   alreadyAssigned.add(ar.serviceResourceId);
                                               }
                                            
                                        }
                                        Integer totalBlockerResource=0,k=0;
                                        if(blockerResource.containsKey(timeslot.START_DATE)){
                                            totalBlockerResource=blockerResource.get(timeslot.START_DATE);
                                            
                                        }
                                        for(Id resourceId : resourceIds)
                                        {
                                            if(!alreadyAssigned.contains(resourceId))
                                            {
                                                if(k<totalBlockerResource){
                                                    k++;
                                                    continue;
                                                }
                                                timeslot.RESOURCE_ID.add(resourceId);
                                            }
                                        }
                                        if(timeslot.RESOURCE_ID.size()>0){
                                            availableTimeSlots.add(timeslot);
                                        }
                                    }
                                }
                            }
                        }
                        res.Timeslots=availableTimeSlots;
                        /*for(TimeSlots TS : availableTimeSlots){
TS.STARTDATE=DateTime.valueOf(TS.START_DATE.format('yyyy-MM-dd HH:mm:ss',ST.OperatingHours.TimeZone));
TS.ENDDATE=DateTime.valueOf(TS.END_DATE.format('yyyy-MM-dd HH:mm:ss',ST.OperatingHours.TimeZone));
}*/
                        // Display Time Slot
                        System.debug('TimeSlots :: '+availableTimeSlots.size());
                    }
                    else{
                        // Not RT
                        System.debug('Zipcode Not In RT Zone');
                        res.TerritoryZone='NRT';
                        System.debug('BranchNumber :: '+ ST.ParentTerritory.Branch__r.Branch_Number__c);
                        res.BranchID=ST.ParentTerritory.Branch__r.Branch_Number__c;
                        res.TimezoneInfo=new TimezoneInfo();
                        
                        res.TimezoneInfo.Name=ST.OperatingHours.Name; 
                        
                        // Get TimeZone Detail Of Current Territory
                        System.debug('TimeZone :: '+ ST.OperatingHours.TimeZone);
                        res.TimezoneInfo.TIMEZONE_CODE=ST.OperatingHours.TimeZone;
                        res.TimezoneInfo.STANDARD_TIME_SHORT_CODE=ST.OperatingHours.Local_Time__c;
                        
                        
                    }
                }else{
                    res.status='failed';
                    res.errorMessage='RT Zone does not exist';
                }
            }else{
                res.status='failed';
                res.errorMessage='Zip code does not exist';
            }
            if(res.status=='failed')
            {
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'RTAIntegration',
                        'getTimeSlotDetails',
                        postalCode,
                        res.errorMessage,
                        null,
                        'Integration'
                    )
                );
            }
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('RTAIntegration','getTimeSlotDetails',postalCode,ex,'Integration'));
        }
        return JSON.serialize(res);
    }
    
    public class TimeSlots{
        public DateTime START_DATE;
        public DateTime END_DATE;
        public Set<String> RESOURCE_ID;
        // public DateTime STARTDATE;
        // public DateTime ENDDATE;
    }
    public class TimezoneInfo{
        public String TIMEZONE_CODE;
        public String NAME;
        public String STANDARD_TIME_SHORT_CODE;
    }    
    public class campaignWrapper{
        public String campaignName;
        public String campaignId;
    } 
    public class reponseWrapper{
        public List<campaignWrapper> campaigns;
        public String TerritoryZone;
        public String BranchID;
        public TimezoneInfo TimezoneInfo;
        public List<TimeSlots> Timeslots;
        public String status;
        public String errorMessage;
    }
}