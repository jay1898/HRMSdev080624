trigger AttendanceTrigger on Attendance__c (before insert,before update) {
    if(Trigger.isBefore){
        try{
            AttendanceTriggerHandler.updateHolidayField(Trigger.new,Trigger.oldMap);
        }catch(Exception e){}
        
    }
}