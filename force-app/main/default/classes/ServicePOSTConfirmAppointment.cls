@RestResource(urlMapping='/ConfirmAppointment/*')
global without sharing class ServicePOSTConfirmAppointment 
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
    global static Response confirmAppointment()
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
        
//        String reqBody = reqst.requestBody.toString() ;
//        System.debug('UAC: reqBody ' + reqBody );
/*
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

        Set<String> types = new Set<String>{'Call Center', 'Showroom'};
        if(String.isBlank(req.type) || !types.contains(req.type) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_REQUEST_TYPE';
             res.errorMessage = 'Please provide a valid Request Type (Call Center or Showroom)';
             return res;
        }
*/
        String appointmentID = reqst.requestURI.substring(reqst.requestURI.lastIndexOf('/')+1);
        
        if(String.isBlank(appointmentID) || !(appointmentID instanceof ID) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_APPOINTMENT_ID';
             res.errorMessage = 'Please provide a valid Service Appointment ID';
             return res;
        }


        try{
            ServiceAppointment sa = [   SELECT Id, Cancel_Reason__c, Cancel_Comment__c, Status, Opportunity__c, EarliestStartTime, DueDate, Opportunity__r.Zone__r.Lead_Receiver__c
                                        FROM ServiceAppointment WHERE ID = :appointmentID];
            System.debug('UAC: sa ' + sa );
            if(sa.Status == 'Canceled')
            {
                res.httpStatusCode = '400';
                res.status = 'INVALID_OPERATION';
                res.errorMessage = 'Appointment already Canceled and can\'t be confirmed ';
                return res; 
            }
            sa.Confirmed__c = true ;
            sa.Last_Confirmation_Date__c = System.now();
            sa.Last_Confirmation_Source__c = 'Mail';
            //sa.Status = 'Canceled';
            //if(String.isNotBlank(sa.Opportunity__r.Zone__r.Lead_Receiver__c)) sa.OwnerId = sa.Opportunity__r.Zone__r.Lead_Receiver__c ;
            //sa.Cancel_Reason__c = req.cancelReason ;
            
            //sa.Cancel_Comment__c = req.comments ;
            //ServiceAppointmentTriggerHandler.RUN_FOR_RTA_CANCEL_APPOINTMENT = true ;
            ServiceAppointmentTriggerHandler.Check_Conflict_Overriden = false ;
            update sa ;

           /* if( String.isNotBlank(sa.Opportunity__c))
             {
             	update new Opportunity(Id=sa.Opportunity__c, Last_Confirmation_Date__c = System.Now());
            }*/
        }   
        catch(DmlException de) {
            res.status = de.getDmlMessage(0);
            res.errorMessage = 'DML_OPERATION_FAILED';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTConfirmAppointment','confirmAppointment',reqst.requestURI,reqst.requestURI,de.getStackTraceString()));
            System.debug('UAC: Exception ' + de.getMessage());
            return res;
        }

        // Log a Apex Debug log information record 
        new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTConfirmAppointment','confirmAppointment', reqst.requestURI,reqst.requestURI,'Integration'));

        return res ;
    }

}