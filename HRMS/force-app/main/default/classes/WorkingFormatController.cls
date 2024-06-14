public without sharing class WorkingFormatController {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getWorkingFormatChart(String employeeId) {
        
        // Check if today is Monday
        Boolean isMonday = Datetime.now().format('E') == 'Mon';

        List<Clock_In_Out__c> result;

        // Reset the map for the new week if today is Monday
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
            // Convert Date to DateTime and then format to get day of the week
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




/*  05/12/23
public without sharing class WorkingFormatController {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getWorkingFormatChart(String employeeId) {
        // Calculate the start date for the last 7 days
        Date last7DaysStartDate = Date.today();
        
        List<Clock_In_Out__c> result = [
            SELECT Daily_Hours__c, Clock_In_Time__c, Employee__r.Id
            FROM Clock_In_Out__c
            WHERE Employee__r.Id = :employeeId
            AND Clock_In_Time__c >= This_Week 
            And Daily_Hours__c != null
            ORDER BY Clock_In_Time__c
        ];
        
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
            
            // Convert Date to DateTime and then format to get day of the week
            // DateTime dateTime1 = DateTime.newInstance(dt.year(), dt.month(), dt.day());
            String dayOfWeek = dateTime1.format('E'); // Get the day of the week (e.g, Mon, Tue)
            
            // Skip data for Sunday
            if (!dayOfWeek.equals('Sun')) {
                if (dayOfWeekData.containsKey(dayOfWeek)) {
                    dayOfWeekData.put(dayOfWeek, totalHours); // before written //dayOfWeekData.get(Daily_Hours__c) +
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
*/

/*public without sharing class WorkingFormatController {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getWorkingFormatChart(String employeeId) {
        // Calculate the start date for the current week (starting from Monday)
        Date currentWeekStartDate = Date.today().toStartOfWeek();
        
        List<Clock_In_Out__c> result = [
            SELECT Daily_Hours__c, Clock_In_Time__c, Employee__r.Id
            FROM Clock_In_Out__c
            WHERE Employee__r.Id = :employeeId
            AND Clock_In_Time__c = :currentWeekStartDate
            AND Daily_Hours__c != null
            ORDER BY Clock_In_Time__c
        ];
        
        System.debug('Result WorkingFormatController--------------------->' + result);
        
        Map<String, Decimal> dayOfWeekData = new Map<String, Decimal>{
            'Mon' => 0,
            'Tue' => 0,
            'Wed' => 0,
            'Thu' => 0,
            'Fri' => 0,
            'Sat' => 0,
            'Sun' => 0
        };
        
        for (Clock_In_Out__c record : result) {
            Datetime dateTime1 = record.Clock_In_Time__c;
            Decimal totalHours = (Decimal)record.get('Daily_Hours__c');
            
            // Convert Date to DateTime and then format to get day of the week
            String dayOfWeek = dateTime1.format('E'); // Get the day of the week (e.g, Mon, Tue)
            
            if (dayOfWeekData.containsKey(dayOfWeek)) {
                dayOfWeekData.put(dayOfWeek, dayOfWeekData.get(dayOfWeek) + totalHours);
                system.debug('dayOfWeekData---------------->' + dayOfWeekData);
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
*/

/*public without sharing class WorkingFormatController {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getWorkingFormatChart(String employeeId) {
        // Calculate the start date for the last 7 days
        Date last7DaysStartDate = Date.today().addDays(-7);
        
        List<Clock_In_Out__c> result = [
            SELECT Daily_Hours__c, Date__c, Employee__r.Id
            FROM Clock_In_Out__c
            WHERE Employee__r.Id = :employeeId
            AND Date__c >= :last7DaysStartDate
            ORDER BY Date__c
        ];
        
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
            Date dt = (Date)record.get('Date__c');
            Decimal totalHours = (Decimal)record.get('Daily_Hours__c');
            
            // Convert Date to DateTime and then format to get day of the week
            DateTime dateTime1 = DateTime.newInstance(dt.year(), dt.month(), dt.day());
            String dayOfWeek = dateTime1.format('E'); // Get the day of the week (e.g, Mon, Tue)
            
            if (dayOfWeekData.containsKey(dayOfWeek)) {
                dayOfWeekData.put(dayOfWeek, dayOfWeekData.get(dayOfWeek)+ totalHours);
                system.debug('dayOfWeekData---------------->'+dayOfWeekData);
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
        public DataSet(String label, Decimal count){
            this.label = label;
            this.count = count;
        }
        
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Decimal count { get; set; }
    }
}
*/



/*public without sharing class WorkingFormatController {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getWorkingFormatChart(String employeeId) {
        //Employee__c employee = [SELECT Id FROM Employee__c WHERE Id = :employeeId];
        //System.debug('employeeId------>' + employeeId);
        
        // Calculate the start date for the last 7 days
        Date last7DaysStartDate = Date.today().addDays(-7);
        
        List<Clock_In_Out__c> result = [
            SELECT Daily_Hours__c, Date__c,Employee__r.Id
            FROM Clock_In_Out__c
            WHERE Employee__r.Id = :employeeId
            AND 
            Date__c >= :last7DaysStartDate
            ORDER BY Date__c
        ];
        
        System.debug('Result WorkingFormatController--------------------->' + result);
        
        List<DataSet> dataSet = new List<DataSet>();
        for (Clock_In_Out__c record : result) {
            Date dt = (Date)record.get('Date__c');
            Decimal totalHours = (Decimal)record.get('Daily_Hours__c');
            dataSet.add(new DataSet(String.valueOf(dt), totalHours));
        }
        System.debug('dataSet------->' + dataSet);
        return dataSet;
    }
    
    public class DataSet {
        public DataSet(String label, Decimal count){
            this.label = label;
            this.count = count;
        }
        
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Decimal count { get; set; }
    }
}
*/