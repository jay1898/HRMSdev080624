public without sharing class AttendanceController {
   
    @AuraEnabled
    public static String getAttendanceData(Integer month, Integer year, String employeeId) {
        try {
            if (!(String.valueOf(month) == null || String.valueOf(year) == null) && String.isNotBlank(employeeId) && String.isNotEmpty(employeeId)) {
                final String timezoneId = 'Asia/Kolkata';
                DateTime firstDate = DateTime.newInstance(year, month, 1, 5, 30, 0);
                DateTime lastDate = firstDate.addMonths(1).addDays(-1).addHours(23).addMinutes(59).addSeconds(59);
                
                Map<String, AttendanceData> result = new Map<String, AttendanceData>();

                List<Attendance__c> attendanceList = [SELECT Id, First_Clock_In_Time__c, Last_Clock_Out_Time__c,  Total_Clock_In_Out_time__c, Present_Absent__c, Override_Absent__c, On_Time_Arrival__c FROM Attendance__c 
                                                        WHERE First_Clock_In_Time__c >= :firstDate 
                                                        AND First_Clock_In_Time__c <= :lastDate
                                                        AND Employee__c =: employeeId
                                                        AND First_Clock_In_Time__c != null 
                                                        AND Last_Clock_Out_Time__c != null
                                                        ORDER BY First_Clock_In_Time__c];

                if (attendanceList.size() > 0) {
                    for (Attendance__c att : attendanceList) {
                        AttendanceData a = new AttendanceData();
                        a.clockIn = att.First_Clock_In_Time__c.format('yyyy-MM-dd HH:mm:ss', timezoneId);
                        a.clockOut = att.Last_Clock_Out_Time__c.format('yyyy-MM-dd HH:mm:ss', timezoneId);
                        a.totalTimeSpan = att.Total_Clock_In_Out_time__c;
                        a.presentStatus = att.Present_Absent__c;
                        a.manualPresentStatus = att.Override_Absent__c;
                        a.onTimeArrivalStatus = att.On_Time_Arrival__c;
                        result.put(String.valueOf(att.First_Clock_In_Time__c.date()), a);
                    }
                    return JSON.serialize(result);
                }
                else {
                    return null;
                }
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getHolidaysByMonth(Integer month, Integer year){
        try {
            if (!(String.valueOf(month) == null || String.valueOf(year) == null)) {
                Date firstDate = date.newInstance(year, month, 1);
                Date lastDate = firstDate.addMonths(1).addDays(-1);

                Set<String> holidaysInQuery = new Set<String>{'1st Saturday OFF', '3rd Saturday OFF', 'Sunday OFF'};

                Map<String, String> resultHoliday = new Map<String, String>();

                List<holiday> holidaylist = [SELECT Id, ActivityDate, Name FROM holiday     
                                            WHERE ActivityDate>=:firstDate 
                                            AND ActivityDate<=:lastDate 
                                            AND Name NOT IN :holidaysInQuery];

                List<Date> nonBusinessHoliday = getHolidaysRecurring(month, year);

                // System.debug('query'+holidaylist);
                // System.debug('noBus'+nonBusinessHoliday);
                // System.debug('holidaylist '+resultHoliday);

                if (nonBusinessHoliday.size() > 0) {
                    for (Date d : nonBusinessHoliday) {
                        DateTime dt = d;
                        if (dt.format('EEEE') == 'Sunday' || dt.format('EEEE') == 'Saturday' && ((d.day() <= 7) || (d.day() >=15 && d.day() <= 21))) {
                            resultHoliday.put(String.valueOf(d), 'WO');
                        }
                        else{
                            resultHoliday.put(String.valueOf(d), 'FO');                            
                        }
                    }
                }

                if (holidaylist.size() > 0) {
                    for (Holiday hd : holidaylist) {
                        Date d = hd.ActivityDate;
                        resultHoliday.put(String.valueOf(d), hd.Name);
                    }
                }

                return resultHoliday;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<Date> getHolidaysRecurring(Integer month, Integer year){
        try { 
            if(!(String.valueOf(month) == null || String.valueOf(year) == null)) {
                Date firstDate = date.newInstance(year, month, 1);
                Date lastDate = firstDate.addMonths(1).addDays(-1);

                BusinessHours bHour = [SELECT Id FROM BusinessHours WHERE IsDefault = true];

                List<Date> listDates = new List<Date>();

                while(firstDate <= lastDate){
                    if(!BusinessHours.isWithin(bHour.Id, firstDate)){
                        listDates.add(firstDate);
                    }
                    firstDate = firstDate.addDays(1);
                }

            return listDates; 
            }
            else {
                return null;
            }  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getFirstClockInDate(String employeeId){
        try {
            if (String.isNotBlank(employeeId) && String.isNotEmpty(employeeId)) {
                Map<String, String> result = new Map<String, String>();
                List<Clock_In_Out__c> firstClockInRecord = [SELECT Id, Clock_In_Time__c FROM Clock_In_Out__c WHERE Employee__c =: employeeId ORDER BY Clock_In_Time__c LIMIT 1];
                if (firstClockInRecord.size() > 0) {
                    result.put('date', String.valueOf(firstClockInRecord[0].Clock_In_Time__c.date()));
                    result.put('month', String.valueOf(firstClockInRecord[0].Clock_In_Time__c.month()));
                    result.put('year', String.valueOf(firstClockInRecord[0].Clock_In_Time__c.year()));
                    return result;
                }
                else{
                    return null;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getCurrentDayClockIn(String employeeId){
        try {
            if (String.isNotBlank(employeeId) && String.isNotEmpty(employeeId)) {

                Map<String, String> result = new Map<String, String>();

                List<Attendance__c> currentDayClockInRecord = [SELECT Id, First_Clock_In_Time__c FROM Attendance__c 
                                                                WHERE Employee__r.Id =: employeeId AND First_Clock_In_Time__c  = TODAY LIMIT 1];
                                                               
                if (currentDayClockInRecord.size() > 0) {
                    result.put('time', String.valueOf(currentDayClockInRecord[0].First_Clock_In_Time__c.format('hh:mm')));
                    return result;
                }
                else{
                    return null;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class AttendanceData {
        public String clockIn;
        public String clockOut;
        public String totalTimeSpan;
        public String presentStatus;
        public String manualPresentStatus;
        public Boolean onTimeArrivalStatus;
    }
}