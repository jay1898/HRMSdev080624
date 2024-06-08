public class FlowSchedulerGetSlots {

    final public static boolean useExactAppointment = false;
    public class FlowSchedulerGetSlotsException extends Exception {}

    @InvocableMethod(label='Get Booking Slots')
    public static List<Response> getSlots(List<Request> requests) {
        try {
            Request request = requests[0];

            ServiceAppointment appointment = FlowSchedulerController.getAppointment(request.serviceAppointmentId);
            ServiceTerritory territory = FlowSchedulerController.getTerritory(appointment.serviceTerritoryId);
            OperatingHours operatingHours = [SELECT Id, TimeZone FROM OperatingHours WHERE Id = : territory.OperatingHoursId];
            FSL__Scheduling_Policy__c policy = FlowSchedulerController.getPolicy(request.schedulingPolicyId);
            TimeZone tz = TimeZone.getTimeZone(operatingHours.TimeZone);
            
            List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.getSlots(request.serviceAppointmentId, policy.Id, operatingHours.Id, tz, false);
            system.debug('slots :' + slots);
           system.debug('request.serviceAppointmentId :' + request.serviceAppointmentId + 'policy Id :' + policy.Id + 'operatingHours :' + operatingHours.Id + 'Timezone :' + tz );
          List<BookingSlot> returnSlots = new List<BookingSlot>();        
            
            for (FSL.AppointmentBookingSlot slot : slots) {
                system.debug('Slot :' + slot);
                BookingSlot newResponseSlot = new BookingSlot();
                newResponseSlot.grade = slot.grade;
                newResponseSlot.start = FlowSchedulerController.changeTimeZone(slot.interval.start, tz);            
                newResponseSlot.finish = FlowSchedulerController.changeTimeZone(slot.interval.finish, tz);
                returnSlots.add(newResponseSlot);
            }
            Response response = new Response(returnSlots);
            response.slotsize = returnSlots.size() ;
            system.debug('size of returnSlots : ' + returnSlots.size());
            return new List<Response>{response};
        } catch (FlowSchedulerController.FlowSchedulerException e) {
            Response response = new Response(e.getMessage());
            return new List<Response>{response};
        }
    }
    
    public class Request {
        @InvocableVariable (label='1. Service Appointment ID' required=true)
        public String serviceAppointmentId;

        @InvocableVariable (label='2. (optional) Scheduling Policy ID' description='Provide a specific Scheduling Policy, or make sure you have a Scheduling Policy set to default for self-scheduling')
        public String schedulingPolicyId;
    }

    public class Response {
        @InvocableVariable(label='Matching Slots') 
        public List<BookingSlot> slots;

        @InvocableVariable(label='Error message')
        public String error;
        
        @InvocableVariable(label='Slot Size')
        public Integer slotsize;

        public Response(List<BookingSlot> slots) {
            this.slots = slots;
            system.debug(this.slots.size() );
        }

        public Response(String error) {
            this.error = error;
        }

    }
}