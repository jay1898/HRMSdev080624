public class AttendanceTriggerHandler {
    public static void updateHolidayField(List<Attendance__c> attendanceList,Map<Id,Attendance__c> oldMap){
        Set<Date> attendanceDates=new set<Date>();
        for( Attendance__c attendanceRec: attendanceList){
            if(oldMap==null || (oldMap!=null && oldMap.get(attendanceRec.Id).Date__c != attendanceRec.Date__c)){
                attendanceDates.add(attendanceRec.Date__c);
            }
        }
        
        Map<Date,Boolean> dateWiseHolidayMap=new Map<Date,Boolean>();
        for(Date d :attendanceDates){
            dateWiseHolidayMap.put(d,false);
            if(d!=null){
                dateWiseHolidayMap.put(d,!(new CalcBusinessDays().isWorkingDay(d)));
            }
        }
        
        for( Attendance__c attendanceRec: attendanceList){
            if(oldMap==null || (oldMap!=null && oldMap.get(attendanceRec.Id).Date__c != attendanceRec.Date__c)){
                if(dateWiseHolidayMap.containsKey(attendanceRec.Date__c)){
                    attendanceRec.Is_Holiday__c=dateWiseHolidayMap.get(attendanceRec.Date__c);
                }
            }
        }
    }
}