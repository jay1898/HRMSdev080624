/**
*   @Author:        Pallavi Patil (eVerge)
*   @Date:          01/30/2020
*   @TaskSource:    Jira
*   @Purpose:       Based on the EbsAppointmentId from Source, event will be updated or created in Salesforce 
*                   To Access this webservice for testing use these URLs, since it is public webservice therefore don't need any authentication
                    For Create/Update - Sandbox : https://pelladev-pellacorp.cs28.force.com/services/apexrest/ServicePSIEvent/
                                        Production : /services/apexrest/ServicePSIEvent
					For Delete - Sandbox : https://pelladev-pellacorp.cs28.force.com/services/apexrest/ServicePSIEvent/EbsAppointmentId
                                 Production : /services/apexrest/ServicePSIEvent/EbsAppointmentId
*   @Updates:       
*/
@RestResource(urlMapping='/ServicePSIEvent/*')
global without sharing class ServicePSIEvent 
{

    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String Message ;
        public String EventId ;
        public Response(){
          	status = 'FAIL';
            httpStatusCode = '400' ;
        }
    }  
    
    global class Request
    {
        public String WhatId;   //PQM Quote#
        public String OwnerId;  
        public String Subject;
        public String Description ;
        public String Event_Type_c ;    
        public String StartDateTime ;
        public String EndDateTime;
        public String ShowAs ;    
        public String EbsAppointmentId ;  
        public String TimeZone_Code;
        public String Location;
        public String UserTimeZone;
     }
    
    @HttpDelete
    global static Response deleteEvent()
    {
        RestRequest request = RestContext.request;
        Response deleteRes = new Response();
        try{
               String delEventId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
               system.debug('@@@delEventId :' + request.requestURI);
                List<Event> thisEvent = [SELECT Id FROM Event WHERE Legacy_Event_Id__c = :delEventId];
                if(thisEvent.size()>0){
                    delete thisEvent;
                    deleteRes.Status = 'SUCCESS';
                    deleteRes.httpStatusCode = '200';
                    deleteRes.Message = 'Record deleted successfully'; 
                    new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePostEvent','deleteEvent',request.requestURI,JSON.serialize(deleteRes),'Integration'));
                    
                }
                else{
                     deleteRes.Status = 'FAIL';
                     deleteRes.httpStatusCode = '400';
                     deleteRes.Message = 'Record not found'; 
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostEvent','deleteEvent',request.requestURI,JSON.serialize(deleteRes),'Integration'));
                    
                }
              }
        catch(Exception e){
                System.debug('exception ' + e.getMessage() ); 
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServiceDeleteEvent','PostData',request.requestURI,e,'Integration'));
        }
        return deleteRes;
    }
    
    @HttpPost 
    global static Response postData()
    {
        RestRequest reqst = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        
        try{
                Request req;
                string	errMsg ;
            
                String reqBody = reqst.requestBody.toString() ;
                reqBody = reqBody.replaceAll('"Event_Type__c"', '"Event_Type_c"');
                //reqBody = reqBody.replaceAll('"EbsAppointmentId"', '"Legacy_Event_Id"');
                System.debug('reqBody ' + reqBody );
               
                try{
                    req = (Request)JSON.deserialize(reqBody,Request.class);
                    System.debug('@@@req :' + req );
                }
                catch (Exception e){
                    res.status = e.getMessage();
                    res.Message = 'INVALID_INPUT_FORMAT:';
                   // res.httpStatusCode = '400';
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostEvent','postData',reqBody,JSON.serialize(res),e.getStackTraceString(),'Integration'));
                    return res;
                }
                //Check the request for null values
                req = checkRequestForNullValues(req);
            
              //get the Opportunity using the PQM Quote #
 				 if(req.WhatId != null)
                 {
                     List<Quote> oppid = [SELECT OpportunityId , Opportunity.OwnerId, Opportunity.Address__c FROM Quote WHERE Quote_Number_PQM__c =: req.WhatId ];
                     if(oppid.size() > 0){
                         req.WhatId = oppid[0].OpportunityId ;
                         req.OwnerId = oppid[0].Opportunity.OwnerId;
                         req.Location = oppid[0].Opportunity.Address__c ;
                         if(req.OwnerId != null)
                         {
                            List<User> UserTZ = [SELECT TimeZoneSidKey FROM User where Id =: req.OwnerId ]; 
                            req.UserTimeZone = UserTZ[0].TimeZoneSidKey ;
                         }
                     }
                    else{
                             res.Message  = 'PQM Quote Number is not valid for this request';
                             new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostEvent','postData',reqBody,JSON.serialize(res),'Integration'));
                         	 return res;
                         }
					 
                 }
            
                //formatting Date fields
                DateTime startDate ;
                DateTime endDate ;
            	if((String.isNotBlank(req.StartDateTime)) && (String.isNotBlank(req.EndDateTime)))
                {   
                    startDate = DateTime.valueOf(req.StartDateTime.replace('T', ' ').replace('Z', '')) ;
            	    endDate = DateTime.valueOf(req.EndDateTime.replace('T', ' ').replace('Z', '')) ;
                }
                //converting to opp owners timezone 03/11/202
               // Changes for timezone issue-- removing conversion -- Rekha
            	/*if(!String.isBlank(req.UserTimeZone) && startDate != null )
                {
                TimeZone tz = TimeZone.getTimeZone(req.UserTimeZone);
	            startDate=startDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
                endDate=endDate.addSeconds((tz.getOffset(endDate)/1000)*-1);
                 system.debug('startDate' + startDate);}*/
              
             
               //Verify the event type and Startdate < Enddate
                errMsg = ((String.isBlank(req.StartDateTime)) && (String.isBlank(req.EndDateTime))) ? 'Start Date and End date are blank' : startDate > endDate ? 'Start Date is greated than End date' : 
                          ((req.Event_Type_c != 'Installation') &&(req.Event_Type_c != 'Order Verification') &&(req.Event_Type_c !='Scheduled Recovery') && (req.Event_Type_c != 'Same Day Recovery') && (req.Event_Type_c != 'Manual Installation')) ? 'Event Type is not valid for this request' : '' ;
 
                //If all the above condition satisfy and there is no error then check for EbsAppointmentId
 				if(string.isBlank(errMsg))
                 {
                     //EbsAppointmentId!= null then update the record if found else create new event and 
                     //EbsAppointmentd = null then send error message in response
                     if(!string.isBlank(req.EbsAppointmentId))
                     {
                        //check and update event 	 
                        Event upEvent = updateEvent(req,reqst,startDate, endDate);
                        system.debug('@@@@res.EventId' + upEvent);
                        res.EventId = '';
                  		if(upEvent != null){res.EventId = upEvent.id;}
                         
                        if(!string.isBlank(res.EventId)){
                           system.debug('@@@record found');
                           res.status = 'SUCCESS';
                    	   res.httpStatusCode = '200';
                           res.Message = 'Record updated successfully'; 
						}
                        else
                        {
                            //if record not found then create event
                            Event evt = createEvent(req, reqst,startDate, endDate);
                    		res.EventId = evt.Id;
                        	res.status = 'SUCCESS';
                    		res.httpStatusCode = '200';
                            res.Message = 'Record created successfully';
                        }
                  	}
                    else{res.Message = 'EBS Appointment Id is null';} 
                 }
                 //send error message in response if any of the validations fail.
            	 else
                 {
                     res.status = 'Fail';
                     res.Message  = errMsg;
                     res.httpStatusCode = '400';
                     new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostEvent','postData',reqBody,JSON.serialize(res),null,'Integration'));
                 }
            	 new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePostEvent','postData',reqBody,JSON.serialize(res),'Integration'));
                             
            }
            catch(Exception ex){ 
                System.debug('exception ' + ex.getMessage() ); 
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePostEvent','postData',reqst.requestBody.toString(),ex,'Integration'));
            }
           
           return res ;
        }
        public static Request checkRequestForNullValues(Request req)
        {
            req.WhatId = String.isBlank(req.WhatId) ? '' : req.WhatId ;
            req.OwnerId = String.isBlank(req.OwnerId) ? '' : req.OwnerId ;
            req.Subject = String.isBlank(req.Subject) ? '' : req.Subject ;
            req.Description = String.isBlank(req.Description) ? '' : req.Description ;
            req.Event_Type_c = String.isBlank(req.Event_Type_c) ? '' : req.Event_Type_c ;
            req.ShowAs = String.isBlank(req.ShowAs) ? '' : req.ShowAs ;
            req.EndDateTime = String.isBlank(req.EndDateTime) ? '' : req.EndDateTime ;
            req.StartDateTime = String.isBlank(req.StartDateTime) ? '' : req.StartDateTime ;
            req.EbsAppointmentId = String.isBlank(req.EbsAppointmentId) ? '' : req.EbsAppointmentId;
            return req ;
        }
    
        //Create New Event
        public static Event createEvent(Request req, RestRequest reqst, DateTime startDate, DateTime endDate )
        {
          	Event evt = new event(WhatId = req.WhatId, OwnerId = req.OwnerId, Subject = req.Subject, Description = req.Description, Location = req.Location, Event_Type__c = req.Event_Type_c,ShowAs = req.ShowAs, StartDateTime = startDate, EndDateTime = endDate, Legacy_Event_Id__c = req.EbsAppointmentId);   
            insert evt;
            return evt;
        }
        
        //Check and update event if found
    	public static Event updateEvent(Request req, RestRequest reqst, DateTime startDate, DateTime endDate )
        {
            system.debug('@@@inside update' + 'startDate: '+ startDate + ' ' + 'endDate :' + endDate );
         
            List<Event>  upevnt = [SELECT Id, Event_Type__c, Subject, Description, Location , StartDateTime, EndDateTime,ShowAs,WhatId,OwnerId FROM Event Where Legacy_Event_Id__c =: req.EbsAppointmentId];    
            system.debug('@@inside try');
            if(upevnt.size() > 0)
            {
               if(upevnt[0].Event_Type__c != req.Event_Type_c)upevnt[0].Event_Type__c = req.Event_Type_c;
               if(upevnt[0].Subject != req.Subject)upevnt[0].Subject = req.Subject;
               if(upevnt[0].Description != req.Description)upevnt[0].Description = req.Description;
               if(upevnt[0].Location != req.Location)upevnt[0].Location = req.Location; 
               if(upevnt[0].StartDateTime != startDate)upevnt[0].StartDateTime = startDate; 
               if(upevnt[0].StartDateTime != endDate)upevnt[0].StartDateTime = endDate;
               if(upevnt[0].ShowAs != req.ShowAs)upevnt[0].ShowAs = req.ShowAs;
               if(upevnt[0].WhatId != req.WhatId)upevnt[0].WhatId = req.WhatId; 
               if(upevnt[0].OwnerId != req.OwnerId)upevnt[0].OwnerId = req.OwnerId; 
               update  upevnt ;
               system.debug('@@Retun' + upevnt);
               return upevnt[0];
              
            }
            system.debug('@@Retun001' + upevnt);
            return null;
        }
        
      
}