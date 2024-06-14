//UserMonthlyHourWiseChartController
public without sharing class MonthlyHourWiseChartController {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getMonthlyHourWiseChart(String employeeId) {
        Employee__c Employee = [SELECT Id from Employee__c where Id =:employeeId];
        system.debug('employeeId------>'+employeeId);
        List<AggregateResult> result = [
            SELECT CALENDAR_MONTH(Date__c) month, CALENDAR_YEAR(Date__c) year, SUM(Total_Hours__c) totalHours
            FROM Timesheet__c
            WHERE Employee__c = :Employee.Id
            GROUP BY CALENDAR_MONTH(Date__c), CALENDAR_YEAR(Date__c)
        ];
        
        system.debug('Result MonthlyHourWiseChartController--------------------->'+result);
        
        Map<Integer, String> monthMap = new Map<Integer, String>{
            	1 => 'January',
                2 => 'February',
                3 => 'March',
                4 => 'April',
                5 => 'May',
                6 => 'June',
                7 => 'July',
                8 => 'August',
                9 => 'September',
                10 => 'October',
                11 => 'November',
                12 => 'December'
                };
                    
        List<DataSet> dataSet = new List<DataSet>();
        for (AggregateResult ar : result) {
            Integer monthNumber = (Integer)ar.get('month');
            Integer year = (Integer)ar.get('year');
            Decimal totalHours = (Decimal)ar.get('totalHours');
            if(monthMap.get(monthNumber) != null)
            {
                String monthName = monthMap.get(monthNumber);
                String label = monthName + ' ' + year;
                
                system.debug('MonthName--------->'+monthName);
                dataSet.add(new DataSet(label, totalHours));
            }
        }
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