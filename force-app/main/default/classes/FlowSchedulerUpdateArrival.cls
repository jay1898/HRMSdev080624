public class FlowSchedulerUpdateArrival {
    
     @InvocableMethod(label='Update Arrival on Appointment')
     public static void updateArrivalDateonAppointment(List<Request> requests){
         Request request = requests[0];
         ServiceAppointment appointment = FlowSchedulerController.getAppointment(request.serviceAppointmentId);
         appointment.ArrivalWindowStartTime = FlowSchedulerController.getArrivalWindowTime(request.startTimeString);
         system.debug('appointment.ArrivalWindowStartTime : '+ appointment.ArrivalWindowStartTime );
         appointment.ArrivalWindowEndTime = FlowSchedulerController.getArrivalWindowTime(request.endTimeString);
         system.debug('appointment.ArrivalWindowStartTime : '+ appointment.ArrivalWindowStartTime + '::' + 'appointment.ArrivalWindowEndTime :' + appointment.ArrivalWindowEndTime);
         update appointment;
         // string sa1 = ''; string sa2 = '';
         /* for(FSL__Time_Dependency__c sa : [SELECT Id, FSL__Service_Appointment_1__c,FSL__Service_Appointment_2__c FROM 
                                                FSL__Time_Dependency__c where FSL__Service_Appointment_1__c = :request.serviceAppointmentId ]){
                  sa1 = sa.FSL__Service_Appointment_1__c;
                  sa2 = sa.FSL__Service_Appointment_2__c;
           }
			List<ServiceAppointment> listUpdateSA = new List<ServiceAppointment>();
         if(sa1 != null && sa2 != null ){
             for(ServiceAppointment sap : [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment where (Id = :sa1 OR Id= :sa2)]){
                 sap.ArrivalWindowStartTime = FlowSchedulerController.getArrivalWindowTime(request.startTimeString);
         		 sap.ArrivalWindowEndTime = FlowSchedulerController.getArrivalWindowTime(request.endTimeString);
                 listUpdateSA.add(sap);
              }
         }
         else{
              	appointment.ArrivalWindowStartTime = FlowSchedulerController.getArrivalWindowTime(request.startTimeString);
         		appointment.ArrivalWindowEndTime = FlowSchedulerController.getArrivalWindowTime(request.endTimeString);
         		update appointment;
         }
         if(listUpdateSA.size()>0){
             UPDATE listUpdateSA ;
         }*/
        
    }
     public class Request {
        @InvocableVariable (label='1. Service Appointment ID' required=true)
        public String serviceAppointmentId;
        @InvocableVariable (label= '2. Arrival Window Start Time' description='Get from the output of the Display Booking Slots screen component' required=true)
        public String startTimeString;
        @InvocableVariable (label= '3. Arrival Window End Time' description='Get from the output of the Display Booking Slots screen component' required=true)
        public String endTimeString;
       
    }

}