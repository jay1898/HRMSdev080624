public class PIESTimeZoneConversion {
    //invoked from flow to convert the SA schedule time to its territory's operation hours time zone.
    
    @InvocableMethod(label='Timezone conversion')
    public static List<FlowOutputs> timezoneconversion(List<FlowInputs> request){
        
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs fOut = new FlowOutputs();
        String strConvertSchdStTime = null;
        String extendedBusinessHrs = 'No' ;
        
        for(FlowInputs flin : request){
            if(flin.saId != null){
                ServiceAppointment sa = [SELECT Id , SchedStartTime, ServiceTerritory.OperatingHours.TimeZone,
                                         ServiceTerritory.OperatingHoursId FROM
                                         ServiceAppointment where Id =: flin.saId ]; 
                
                //get ST's Operaitng hours timezone
                String stTz = sa.ServiceTerritory.OperatingHours.TimeZone ;
                system.debug('sa.ServiceTerritory.OperatingHours.TimeZone : ' + sa.ServiceTerritory.OperatingHours.TimeZone);
                
                //Get the wokring hours from timelost
                List<TimeSlot> tslot = [SELECT Id, StartTime, EndTime FROM TimeSlot where 
                                        OperatingHoursId =: sa.ServiceTerritory.OperatingHoursId LIMIT 1]; 
                if(tslot.size() > 0){
                    Time startTime = tslot[0].StartTime;
                    Time endTime = tslot[0].EndTime;
                    String strConvertStTime = string.valueOf(startTime);
                    String strConvertEndTime = string.valueOf(endTime);
                    system.debug('strConvertEndTime : ' + strConvertEndTime + '@@@' + 'strConvertStTime : ' + strConvertStTime);
                    
                    //get the time when status was updated to Scheduled/EnRoute/OnSite/Cancelled/Completed and convert it to ST's--> OH's timezone
                    strConvertSchdStTime = system.now().format('HH:mm a', stTz );
                    system.debug('strConvertSchdStTime :' + strConvertSchdStTime);
                    
                    //if converteddate is outside working hours ( < 8 AM or > 5 PM) 
                    if(strConvertSchdStTime < strConvertStTime || strConvertSchdStTime > strConvertEndTime){
                        
                        extendedBusinessHrs = 'Yes';
                        fout.outsideWorkingHours = extendedBusinessHrs ;
                        System.debug('Update Status date :' + fout.outsideWorkingHours);
                        
                        results.add(fout); 
                    }
                    
                }
                
            }
            
            //if SA is scheduled within working hours
            if(flin.saId != null && extendedBusinessHrs == 'No'){
                
                ServiceAppointment sa = [SELECT Id , SchedStartTime,ServiceTerritory.OperatingHours.TimeZone FROM
                                         ServiceAppointment where Id =: flin.saId ]; 
                
                String stTz = sa.ServiceTerritory.OperatingHours.TimeZone ;
                system.debug('sa.ServiceTerritory.OperatingHours.TimeZone : ' + sa.ServiceTerritory.OperatingHours.TimeZone);
                if(sa.SchedStartTime != null){
                    String strConvertedDate = sa.SchedStartTime.format('MM/dd/yyyy HH:mm a', stTz );
                    system.debug('Time – ' + strConvertedDate);
                    
                    fout.stTZdate = strConvertedDate ;
                    results.add(fout); 
                }
            }//end of if
        }
        List<FlowOutputs> listRes = new List<FlowOutputs>(results);  
        system.debug('results in list :' + listRes);
        return listRes ;
        
        //return results ;
        
    }
    
    public class FlowInputs{
        @InvocableVariable
        public String saId;
    }
    public class FlowOutputs{
        @InvocableVariable
        public string stTZdate ;
        
        /*@InvocableVariable
public string schedStatusTZdate ; */
        
        @InvocableVariable
        public string outsideWorkingHours ; 
        
    }
}