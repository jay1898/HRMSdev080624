public class FlowSchedulerController {
    
    public class FlowSchedulerException extends Exception {}
    public static String defaultFieldName = 'Default_for_Flow_Scheduler__c';
    
    public static ServiceAppointment getAppointment(String serviceAppointmentId) {
        try{
            List<ServiceAppointment> appointments = [SELECT Id, ServiceTerritoryId FROM ServiceAppointment WHERE Id =: serviceAppointmentId];
            system.debug('appointments :'+ appointments);	
            return appointments[0]; 
        } catch(Exception Ex) { 
            system.debug('Service Appointments :' + Ex.getMessage());
            return new ServiceAppointment();
        }
    }
    
    public static FSL__Scheduling_Policy__c getPolicy(String schedulingPolicyId) {
        try{
            List<FSL__Scheduling_Policy__c> policies = new List<FSL__Scheduling_Policy__c>(); 
            
            policies = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Id =: schedulingPolicyId];
            system.debug('Policies :'+ policies);
            return policies[0];
        } catch(Exception ex) {
            system.debug('Scheduling Policies :' + Ex.getMessage());
            return new FSL__Scheduling_Policy__c();
        }
    }
    
    public static ServiceTerritory getTerritory(String serviceTerritoryId) {
        // If the ServiceAppointment has an associated ServiceTerritory, search for that record. If not, search for a default Service Territory
        try{
            List<ServiceTerritory> territories = new List<ServiceTerritory>(); 
            territories = [SELECT OperatingHoursId, OperatingHours.Timezone FROM ServiceTerritory WHERE Id =: serviceTerritoryId];        
            system.debug('Territories :'+ territories);
            return territories[0];
        } catch(Exception ex) {
            system.debug('Service Territories :' + Ex.getMessage());
            return new ServiceTerritory();
        }
    }
    
    public static DateTime changeTimeZone(DateTime dt, TimeZone tz) {
        Integer offset = tz.getOffset(dt);
        return DateTime.newInstance(dt.getTime() - offset);
    }
    
    public static DateTime getArrivalWindowTime(String timeString) {
        return DateTime.valueOfGmt(String.valueOf(JSON.deserialize('"'+ timeString +'"', Datetime.class)));
    }
}