public class ServiceAppointmentAssignmentBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(System.Label.ServiceAppointmentQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<ServiceAppointment> listSA){
        ServiceAppointmentRecordShare.shareSARecordWithSTM(listSA);
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        ServiceAppointmentAssignmentBatch b = new ServiceAppointmentAssignmentBatch(); 
        database.executebatch(b,1);
    }
}