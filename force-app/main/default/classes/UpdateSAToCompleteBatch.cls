global class UpdateSAToCompleteBatch implements Database.Batchable<sObject>,Database.Stateful
{ 
       
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime currentTime = DateTime.now();
        String query = 'SELECT Id, Status FROM ServiceAppointment where Status !=\'Completed\' and  Status !=\'Preference\' and Status !=\'Canceled\' and SchedEndTime < :currentTime  ';
        return Database.getQueryLocator(query);       
    }
    
    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        for(ServiceAppointment SA : scope){
            SA.Status='Completed';
        }
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=false;
        Database.update(scope,false) ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER=true;
    }
    
    global void finish(Database.BatchableContext bc){    
        System.debug('::UpdateSAToCompleteBatch Completed::');
    }    
}