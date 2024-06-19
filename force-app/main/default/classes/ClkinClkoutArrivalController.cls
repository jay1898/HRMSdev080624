public without sharing class ClkinClkoutArrivalController {

  	//For fetching data of On_Time_Arrival__c (LATE or ON TIME)
    @AuraEnabled
    public static List<Attendance__c> getAttendanceOnTimeArrival(Id employeeId) {
        List<Attendance__c> OnTimeArrivalLst = [SELECT Id, On_Time_Arrival__c, First_Clock_In_Time__c, Last_Clock_Out_Time__c, 
                                                Employee__r.Id, Employee__r.Name 
                                                FROM Attendance__c 
                                                WHERE First_Clock_In_Time__c = TODAY AND Employee__r.Id = :employeeId];
        System.debug('OnTimeArrivalLst---------->'+OnTimeArrivalLst);
        return OnTimeArrivalLst;
    }
    
    //Count of Rabbit and tortoise 
    @AuraEnabled
    public static Map<String, Integer> getontimeArrival(Id employeeId) {
        List<AggregateResult> totalCounts = [SELECT COUNT(Id) counts, On_Time_Arrival__c FROM Attendance__c WHERE Employee__r.Id = :employeeId AND First_Clock_In_Time__c != null GROUP BY On_Time_Arrival__c ORDER BY On_Time_Arrival__c];
        Map<String, Integer> totalValues = new Map<String, Integer>();
        
        if (!totalCounts.isEmpty()) {
            for(AggregateResult ar: totalCounts) {
                if(Boolean.valueOf(ar.get('On_Time_Arrival__c'))) {
                	totalValues.put('OnTimeArrivals', Integer.valueOf(ar.get('counts')));    
                }
                else {
                   	totalValues.put('lateArrivals', Integer.valueOf(ar.get('counts'))); 
                }
            }
        }
        System.debug('totalValues--------->'+totalValues);
        return totalValues;
    }
}