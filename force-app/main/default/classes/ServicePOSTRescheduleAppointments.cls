/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          12/29/2019
*   @TaskSource:    Jira
*   @Purpose:       Exposed a public webservice to Re-Schedule service appointment 

                    Sandbox : https://pelladev-pellacorp.cs28.force.com/services/apexrest/RescheduleAppointments
                    Production : /services/apexrest/RescheduleAppointments
*   @Updates:       
*/
@RestResource(urlMapping='/RescheduleAppointments/*')
global without sharing class ServicePOSTRescheduleAppointments 
{
    //Response class
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    } 
    public class Request
    {
        public String type ;
        public String appointmentID ;
        public String start ; 
        public String comments ;
    }
    
    @HttpPost
    global static Response rescheduleAppointments()
    { 
        
        RestRequest reqst = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;

        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) return res ;
        
        Request req;
        
        String reqBody = reqst.requestBody.toString() ;
        System.debug('UAC: reqBody ' + reqBody );

        // Try to deserialize REQUEST
        try{
            req = (Request)JSON.deserialize(reqBody,Request.class);
            System.debug('UAC: req ' + req );
        }catch (Exception e){
            res.status = e.getMessage();
            res.errorMessage = 'INVALID_REQUEST_BODY:';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTRescheduleAppointments','rescheduleAppointments',reqBody,JSON.serialize(res),e.getStackTraceString()));
            return res;
        }

        Set<String> types = new Set<String>{'Web', 'Call Center', 'Showroom'};
        if(String.isBlank(req.type) || !types.contains(req.type) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_REQUEST_TYPE';
             res.errorMessage = 'Please provide a valid Request Type (Web, Call Center or Showroom)';
             return res;
        }

        if(String.isBlank(req.appointmentID) || !(req.appointmentID instanceof ID) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_APPOINTMENT_ID';
             res.errorMessage = 'Please provide a valid Service Appointment ID';
             return res;
        }

        if(String.isBlank(req.start) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_START_DATETIME';
             res.errorMessage = 'Please provide a valid Appointment Start Datetime ';
             return res;
        }

        DateTime startDate ;
        DateTime startDateEmail ;
        DateTime endDate ; 
        if(String.isNotBlank(req.start)) startDate = DateTime.valueOf(req.start.replace('T', ' ').replace('Z', '')) ;
        System.debug('UAC: startDate ' + startDate );
        startDateEmail = startDate;

        try{
            ServiceAppointment sa = [   SELECT Id, SchedStartTime, SchedEndTime, Reschedule_Comment__c, Status, Opportunity__r.Zone__r.ApptDurationMin__c,Opportunity__r.Zone__r.Virtual_Appt_Duration_Min__c, 
                                                Opportunity__r.Opportunity_no__c,Opportunity__r.Zone__r.OperatingHours.TimeZone, Opportunity__c, Rescheduled__c ,Opportunity__r.Virtual_Appointment__c
                                        FROM ServiceAppointment WHERE ID = :req.appointmentID];

            endDate = sa.Opportunity__r.Zone__r.ApptDurationMin__c == null ? startDate.addMinutes(1) : startDate.addMinutes(Integer.valueOf(sa.Opportunity__r.Zone__r.ApptDurationMin__c)) ;
			
            // Added on 02-06 related to virtual appointment change
            if(sa.Opportunity__r.Virtual_Appointment__c){
                 endDate = sa.Opportunity__r.Zone__r.Virtual_Appt_Duration_Min__c == null ? endDate : startDate.addMinutes(Integer.valueOf(sa.Opportunity__r.Zone__r.Virtual_Appt_Duration_Min__c)) ;
			}
            
            if(!String.isBlank(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone) && startDate != null ){
                TimeZone tz = TimeZone.getTimeZone(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone);
                System.debug('UAC: tz ' + tz );
                startDate=startDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
                endDate=endDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
            }
            System.debug('UAC: startDate ' + startDate );

            
            // Added on 08-06 release Timeslot 
            List<RTA_Timeblock__c> timeBlocks  =[SELECT ID FROM RTA_Timeblock__c WHERE Opportunity_No__c = :sa.Opportunity__r.Opportunity_no__c ];
            if(timeBlocks.size() > 0) delete timeBlocks ;
            // if appointment date time is within 24 hours then update opp datetime to blank and update it, to fire before 24 hours WF
            // Logic moved to ServiceAppointmentTriggerHandler line # 369 
            /*if(sa.SchedStartTime.addhours(-24)<Datetime.now())
            {
				Opportunity opp=new Opportunity();
                opp.Id=sa.Opportunity__c;
                opp.Appointment_DateTime__c=null;
                OpportunityTriggerHandler.RUN_TRIGGER=false;
                update opp;
                OpportunityTriggerHandler.RUN_TRIGGER=true;
            } */
            
            // if already re-scheduled then uncheck it and update it, to fire workflow in after this DML where it is getting TRUE again
            if(sa.Rescheduled__c)
            {
                sa.Rescheduled__c = false ;
                update sa ;
            } 

            // Set Appointement Time as it is in GMT format 
            if(String.isNotBlank(sa.Opportunity__c)) update new Opportunity(Id = sa.Opportunity__c, Appointment_DateTime_Email__c = startDateEmail);

            sa.SchedStartTime = startDate ;
            sa.Start_Datetime__c = startDate ;
            sa.SchedEndTime = endDate ;  
            sa.End_Datetime__c = endDate ;
            sa.EarliestStartTime = startDate ;
            sa.DueDate = endDate ;
            sa.Reschedule_Comment__c = req.comments ;
            sa.Status = 'Soft Assigned';
            sa.Rescheduled__c = true ;
            sa.confirmed__c = false;        // Rekha Mogli appointment confirmation logic  
            ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = true ;
            update sa ;
        }   
        catch(DmlException de) {
            res.status = de.getDmlMessage(0);
            res.errorMessage = 'DML_OPERATION_FAILED:';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTRescheduleAppointments','rescheduleAppointments',reqBody,JSON.serialize(res),de.getStackTraceString()));
            return res;
        }

        // Log a Apex Debug log information record 
        new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTRescheduleAppointments','rescheduleAppointments', JSON.serialize(res),reqBody,'Integration'));

        return res ;
    }
}