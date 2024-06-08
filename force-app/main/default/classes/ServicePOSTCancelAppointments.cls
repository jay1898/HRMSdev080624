@RestResource(urlMapping='/CancelAppointments/*')
global without sharing class ServicePOSTCancelAppointments 
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

    @HttpPost
    global static Response cancelAppointments()
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
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTCancelAppointments','cancelAppointments',reqBody,JSON.serialize(res),e.getStackTraceString()));
            return res;
        }

        Set<String> types = new Set<String>{'Call Center', 'Showroom', 'Web'};
        if(String.isBlank(req.type) || !types.contains(req.type) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_REQUEST_TYPE';
             res.errorMessage = 'Please provide a valid Request Type (Call Center or Showroom)';
             return res;
        }

        if(String.isBlank(req.appointmentID) || !(req.appointmentID instanceof ID) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_APPOINTMENT_ID';
             res.errorMessage = 'Please provide a valid Service Appointment ID';
             return res;
        }


        try{
            ServiceAppointment sa = [   SELECT Id, Cancel_Reason__c, Cancel_Comment__c, Status, Opportunity__c, EarliestStartTime, DueDate, Opportunity__r.Zone__r.Lead_Receiver__c
                                        FROM ServiceAppointment WHERE ID = :req.appointmentID];
            System.debug('UAC: sa ' + sa );
            if(sa.Status == 'Canceled')
            {
                res.httpStatusCode = '400';
                res.status = 'INVALID_OPERATION';
                res.errorMessage = 'Appointment already Canceled ';
                return res; 
            }
            sa.Status = 'Canceled';
            //if(String.isNotBlank(sa.Opportunity__r.Zone__r.Lead_Receiver__c)) sa.OwnerId = sa.Opportunity__r.Zone__r.Lead_Receiver__c ;
            sa.Cancel_Reason__c = req.cancelReason ;
            sa.Cancel_Comment__c = req.comments ;
            sa.confirmed__c = false;        // Rekha Mogli appointment confirmation logic    
            ServiceAppointmentTriggerHandler.RUN_FOR_RTA_CANCEL_APPOINTMENT = true ;
            ServiceAppointmentTriggerHandler.Check_Conflict_Overriden = false ;
            update sa ;

            // if( String.isNotBlank(sa.Opportunity__c))
            // {
            // 	update new Opportunity(Id=sa.Opportunity__c, Status__c = 'Canceled');
            // }
        }   
        catch(DmlException de) {
            res.status = de.getDmlMessage(0);
            res.errorMessage = 'DML_OPERATION_FAILED';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTCancelAppointments','cancelAppointments',reqBody,JSON.serialize(res),de.getStackTraceString()));
            System.debug('UAC: Exception ' + de.getMessage());
            return res;
        }

        // Log a Apex Debug log information record 
        new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTCancelAppointments','cancelAppointments', JSON.serialize(res),reqBody,'Integration'));

        return res ;
    }

    public class Request
    {
        public String type ;
        public String appointmentID ;
        public String cancelReason ; 
        public String comments ;
    }
}