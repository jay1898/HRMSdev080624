public class DisplayTimesheetController {

    @AuraEnabled
    public static List<Timesheet__c> getTimesheetDetails(){
        List<Timesheet__c> listTimeSheetRecords=[select id,Date__c, Task_Type__c, Ticket_No__c, Task_Description__c, Actual_Hours__c,Project__r.name from Timesheet__c order by Date__c desc nulls last limit 5];
        return listTimeSheetRecords;
    }
}