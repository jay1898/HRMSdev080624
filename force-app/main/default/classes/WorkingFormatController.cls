public without sharing class WorkingFormatController {
    
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getWorkingFormatChart(String employeeId) {
        
        Boolean isMonday = Datetime.now().format('E') == '';
        
        List<Clock_In_Out__c> result;
        
        if (isMonday) {
            result = new List<Clock_In_Out__c>();
            system.debug('result-->%%%%%%%%%%&&&&&'+result);
        } else {
            result = [
                SELECT Daily_Hours__c, Clock_In_Time__c, Clock_Out_Time__c,Employee__r.Id,Attendance__r.Total_Clock_In_Hours__c,Total_Clock_In_Hours__c
                FROM Clock_In_Out__c
                WHERE Employee__r.Id = :employeeId
                AND Clock_In_Time__c = This_Week 
                AND Daily_Hours__c != null
                ORDER BY Clock_In_Time__c
            ];
        }
        
        System.debug('Result WorkingFormatController--------------------->' + result);
        
        Map<String, Decimal> dayOfWeekData = new Map<String, Decimal>{
            'Sun' => 0,
                'Mon' => 0,
                'Tue' => 0,
                'Wed' => 0,
                'Thu' => 0,
                'Fri' => 0,
                'Sat' => 0
                };
                    
                    for (Clock_In_Out__c record : result) {
                        Datetime dateTime1 = record.Clock_In_Time__c;
                        Decimal totalHours = (Decimal)record.get('Daily_Hours__c');
                        String dayOfWeek = dateTime1.format('E'); // Get the day of the week (e.g, Mon, Tue)
                        
                        // Skip data for Sunday
                        if (!dayOfWeek.equals('Sun')) {
                            if (dayOfWeekData.containsKey(dayOfWeek)) {
                                dayOfWeekData.put(dayOfWeek,dayOfWeekData.get(dayOfWeek)+totalHours);
                                system.debug('dayOfWeekData---------------->' + dayOfWeekData);
                            }
                        }
                    }
        
        List<DataSet> dataSet = new List<DataSet>();
        for (String day : dayOfWeekData.keySet()) {
            dataSet.add(new DataSet(day, dayOfWeekData.get(day)));
        }
        
        System.debug('dataSet------->' + dataSet);
        return dataSet;
    }
    
    public class DataSet {
        public DataSet(String label, Decimal count) {
            this.label = label;
            this.count = count;
        }
        
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Decimal count { get; set; }
    }
}