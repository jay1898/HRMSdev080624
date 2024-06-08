/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          12/22/2019
*   @TaskSource:    Jira
*   @Purpose:       Exposed a public webservice which will return Scheduled service appointment based on Opportunity No or Email

                    Sandbox : https://pelladev-pellacorp.cs28.force.com/services/apexrest/getRescheduleAppointments
                    Production : /services/apexrest/getRescheduleAppointments
*   @Updates:       
*/
@RestResource(urlMapping='/SearchAppointments/*')
global without sharing class ServiceGETAppointments
{
    //Response class
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public List<Appointment> appointments = new List<Appointment>() ;

        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    } 

    // Appointment class to return appointment data
    global class Appointment
    {
        public Id appointmentId ;
        public String firstName ;
        public String lastName ;
        public String address ;
        public String street = '' ;
        public String city = '' ;
        public String state = '' ;
        public String zipcode = '' ;
        public String country = '' ;
        public String email = '';
        public String phoneLabel = '';
        public String phoneValue = '';
        public String oppNo = '';
        public String type = '';
        public Boolean confirmed = false;
        //public String timezoneCode = '' ; 
        public Datetime appointmentDatetime ;
    }

    global class Request
    {
        public String type ;
        public String oppNo ;
        public String email ;
        public String lastName ; 
        public String phoneNumber ; 
        public String zipcode ;
        //public String TimeZone_Code; 
    }

    @HttpPost
    global static Response getAppointments()
    {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        Response res = new Response();

        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');

        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) return res ;
        
        Request req;
            
        String reqBody = restReq.requestBody.toString() ;
        System.debug('UAC: reqBody ' + reqBody );
        // Try to deserialize REQUEST
        try{
            req = (Request)JSON.deserialize(reqBody,Request.class);
            System.debug('UAC: req ' + req );
        }catch (Exception e){
            res.status = e.getMessage();
            res.errorMessage = 'INVALID_INPUT_FORMAT:';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServiceGETAppointments','getAppointments',reqBody,JSON.serialize(res),e.getStackTraceString()));
            return res;
        }

        // Get all parameters 
        String type = req.type;
        String oppNo = req.oppNo;
        String email = req.email;
        String lastName = req.lastName;
        String phoneNumber = req.phoneNumber;
        String zipcode = req.zipcode;

        Set<String> types = new Set<String>{'Web', 'Call Center', 'Showroom'};
        if(String.isBlank(req.type) || !types.contains(req.type) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_REQUEST_TYPE';
             res.errorMessage = 'Please provide a valid Request Type (Web, Call Center or Showroom)';
             return res;
        }

        Set<String> validStatuses = new Set<String>{'Completed', 'Scheduled'};                                      

        Date fiveDaysBack = Date.today().addDays(-5);
        // Make query for scheduled Service Appointments
        String query =  ' SELECT Id, SchedStartTime, SchedEndTime, Opportunity__r.Account.FirstName, Opportunity__r.Account.LastName, ' + 
                                'Opportunity__r.Zone__r.ApptDurationMin__c, Opportunity__r.Account.PersonMailingStreet,  Opportunity__r.Account.PersonMailingCity, ' + 
                                'Opportunity__r.Account.PersonMailingState, Opportunity__r.Account.PersonMailingPostalCode, Opportunity__r.Account.PersonMailingCountry, ' + 
                                'Opportunity__r.Account.PersonEmail, Opportunity__r.Account.PersonHomePhone, Opportunity__r.Account.PersonMobilePhone, ' + 
                                'Opportunity__r.Account.PersonOtherPhone, Opportunity__r.Account.PersonAssistantPhone, ' + 
                                'Opportunity__r.Zone__r.OperatingHours.TimeZone, Opportunity__r.Address__c, PostalCode,Opportunity__r.opportunity_no__c,Opportunity__r.Virtual_Appointment__c ' + 
                        ' FROM ServiceAppointment ' + 
                        ' WHERE ( StatusCategory IN :validStatuses AND SchedStartTime >= :fiveDaysBack '  ;
        
        String whereClause = '' ;
        if(!req.type.equalsIgnoreCase('Showroom')) whereClause += ' AND Status != \'Preference\'';
        // Filter for Opportunity Number
        if(String.isNotBlank(oppNo)) whereClause += ' AND Opportunity__r.Opportunity_No__c = :oppNo ' ;

        // Filter for Email 
        if(String.isNotBlank(email)) whereClause += ' AND Opportunity__r.Account.PersonEmail = :email ';
        
        // Close bracket of where clause (Staring bracket is on after WHERE keyword )
        whereClause += ') ' ;

        // When LastName, Zipcode or PhoneNumber specified
        if(String.isNotBlank(lastName) || String.isNotBlank(zipcode) || String.isNotBlank(phoneNumber) )
        {

            // When OppNo and Email not specified then use AND otherwise use OR condition
            whereClause += (String.isBlank(oppNo) && String.isBlank(email)) ? 'AND ( ' : ' OR ( ' ;

            // Filter for LastName 
            if(String.isNotBlank(lastName)) whereClause += ' Opportunity__r.Account.LastName = :lastName AND ';

            // Filter for Zipcode
            if(String.isNotBlank(zipcode)) whereClause += ' Opportunity__r.Account.PersonMailingPostalCode = :zipcode AND ' ;

            // Filter for PhoneNumber
            if(String.isNotBlank(phoneNumber))
            {
                whereClause += ' ( Opportunity__r.Account.PersonHomePhone = :phoneNumber OR Opportunity__r.Account.PersonMobilePhone = :phoneNumber ' ;
                whereClause += '        OR Opportunity__r.Account.PersonOtherPhone = :phoneNumber OR Opportunity__r.Account.PersonAssistantPhone = :phoneNumber ) AND ' ;
            }

            // Remove Last AND keyword and close bracket
            if(whereClause.right(4) == 'AND ') whereClause = whereClause.left(whereClause.length()-4) + ' )';
            System.debug('UAC: whereClause lastname zipcode ' + whereClause );
        }

            
        System.debug('UAC: whereClause ' + whereClause);
        query += whereClause ;
        System.debug('UAC: query ' + query);
        
        List<ServiceAppointment> listSA = Database.query(query);

        // Get Appointments and populate list in response
        for(ServiceAppointment sa :  listSA)
        {
            Appointment ap = new Appointment();
            ap.appointmentId = sa.Id ;
            ap.firstName = ServiceUtil.checkNull(sa.Opportunity__r.Account.FirstName) ;
            ap.lastName = ServiceUtil.checkNull(sa.Opportunity__r.Account.LastName) ;
            ap.address = ServiceUtil.checkNull(sa.Opportunity__r.Address__c).replaceAll('<br>', ' ') ; 
            ap.street = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingStreet);
            ap.city = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingCity);
            ap.state = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingState);
            ap.zipcode = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingPostalCode);
            ap.country = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingCountry);
            ap.email = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonEmail);
            ap.oppNo = ServiceUtil.checkNull(sa.Opportunity__r.opportunity_no__c);
            ap.type=sa.Opportunity__r.Virtual_Appointment__c?RTAIntegration.VirtualAppointment:RTAIntegration.InHomeAppointment;
            //ap.timezoneCode = ServiceUtil.checkNull(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone);

            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
            Boolean isPhoneFound = false; 
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonHomePhone) && !isPhoneFound ) 
            {
                ap.phoneLabel = fieldMap.get('PersonHomePhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonHomePhone) ;
            }
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonMobilePhone) && !isPhoneFound ) 
            {
                ap.phoneLabel = fieldMap.get('PersonMobilePhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonMobilePhone) ;
            }
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonOtherPhone) && !isPhoneFound ) 
            {   
                ap.phoneLabel = fieldMap.get('PersonOtherPhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonOtherPhone) ;   
            }
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonAssistantPhone) && !isPhoneFound ) 
            {
                ap.phoneLabel = fieldMap.get('PersonAssistantPhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonAssistantPhone) ;   
            }

            ap.appointmentDatetime = sa.SchedStartTime ;
            if(!String.isBlank(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone) && ap.appointmentDatetime != null ){
                TimeZone tz = TimeZone.getTimeZone(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone);
                System.debug('UAC: tz ' + tz );
                ap.appointmentDatetime=ap.appointmentDatetime.addSeconds((tz.getOffset(ap.appointmentDatetime)/1000));
            }
            System.debug('UAC: ap.appointmentDatetime ' + ap.appointmentDatetime );

            res.appointments.add(ap);
        }
    
        return res;
    }
        @HttpGet
    global static Response getOppAppointments()
    {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        Response res = new Response();

        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');

        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) return res ;
        
        Request req;
            
        String reqBody = restReq.requestBody.toString() ;
        System.debug('UAC: reqBody ' + reqBody );
     /*   // Try to deserialize REQUEST
        try{
            req = (Request)JSON.deserialize(reqBody,Request.class);
            System.debug('UAC: req ' + req );
        }catch (Exception e){
            res.status = e.getMessage();
            res.errorMessage = 'INVALID_INPUT_FORMAT:';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServiceGETAppointments','getAppointments',reqBody,JSON.serialize(res),e.getStackTraceString()));
            return res;
        }

        // Get all parameters 
        String type = req.type;
        String oppNo = req.oppNo;
        String email = req.email;
        String lastName = req.lastName;
        String phoneNumber = req.phoneNumber;
        String zipcode = req.zipcode;*/
        
        String OppId =  restReq.requestURI.substring(restReq.requestURI.lastIndexOf('/')+1); //restReq.params.get('opportunityId'); //
        
         System.debug('UAC: OpportunityId ' + OppId);
        System.debug('UAC: restReq.requestURI ' + restReq.requestURI);

       /* Set<String> types = new Set<String>{'Web', 'Call Center', 'Showroom'};
        if(String.isBlank(req.type) || !types.contains(req.type) )
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_REQUEST_TYPE';
             res.errorMessage = 'Please provide a valid Request Type (Web, Call Center or Showroom)';
             return res;
        }
*/
        
          if(String.isBlank(OppId) || OppId =='')
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_PARAMETER';
             res.errorMessage = 'Please provide a valid ID';
             return res;
        }
        Set<String> validStatuses = new Set<String>{'Completed', 'Scheduled', 'InProgress'};                                      

        Date fiveDaysBack = Date.today().addDays(-5);
        // Make query for scheduled Service Appointments
     /*   String query =  ' SELECT Id, SchedStartTime, SchedEndTime, Opportunity__r.Account.FirstName, Opportunity__r.Account.LastName, ' + 
                                'Opportunity__r.Zone__r.ApptDurationMin__c, Opportunity__r.Account.PersonMailingStreet,  Opportunity__r.Account.PersonMailingCity, ' + 
                                'Opportunity__r.Account.PersonMailingState, Opportunity__r.Account.PersonMailingPostalCode, Opportunity__r.Account.PersonMailingCountry, ' + 
                                'Opportunity__r.Account.PersonEmail, Opportunity__r.Account.PersonHomePhone, Opportunity__r.Account.PersonMobilePhone, ' + 
                                'Opportunity__r.Account.PersonOtherPhone, Opportunity__r.Account.PersonAssistantPhone, ' + 
                                'Opportunity__r.Zone__r.OperatingHours.TimeZone, Opportunity__r.Address__c, PostalCode,Opportunity__r.opportunity_no__c,Opportunity__r.Virtual_Appointment__c ' + 
                        ' FROM ServiceAppointment ' + 
                        ' WHERE ( StatusCategory IN :validStatuses AND SchedStartTime >= :fiveDaysBack ' +
                        ' AND Status != \'Preference\'' +
                        ' AND Opportunity__r.Id = :oppId )';
        
       
        System.debug('UAC: query ' + query);*/
        
        List<ServiceAppointment> listSA = [SELECT Id,Confirmed__c, SchedStartTime, SchedEndTime, Opportunity__r.Account.FirstName, Opportunity__r.Account.LastName,  
                                Opportunity__r.Zone__r.ApptDurationMin__c, Opportunity__r.Account.PersonMailingStreet,  Opportunity__r.Account.PersonMailingCity, 
                                Opportunity__r.Account.PersonMailingState, Opportunity__r.Account.PersonMailingPostalCode, Opportunity__r.Account.PersonMailingCountry, 
                                Opportunity__r.Account.PersonEmail, Opportunity__r.Account.PersonHomePhone, Opportunity__r.Account.PersonMobilePhone,  
                                Opportunity__r.Account.PersonOtherPhone, Opportunity__r.Account.PersonAssistantPhone,  
                                Opportunity__r.Zone__r.OperatingHours.TimeZone, Opportunity__r.Address__c, PostalCode,Opportunity__r.opportunity_no__c,Opportunity__r.Virtual_Appointment__c  
                         FROM ServiceAppointment   
                         WHERE ( 
                             StatusCategory IN :validStatuses AND SchedStartTime >= :fiveDaysBack  
                         AND Status != 'Preference' 
                         AND Opportunity__r.Id = :oppId )];

        // Get Appointments and populate list in response
        for(ServiceAppointment sa :  listSA)
        {
            Appointment ap = new Appointment();
            ap.appointmentId = sa.Id ;
            ap.firstName = ServiceUtil.checkNull(sa.Opportunity__r.Account.FirstName) ;
            ap.lastName = ServiceUtil.checkNull(sa.Opportunity__r.Account.LastName) ;
            ap.address = ServiceUtil.checkNull(sa.Opportunity__r.Address__c).replaceAll('<br>', ' ') ; 
            ap.street = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingStreet);
            ap.city = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingCity);
            ap.state = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingState);
            ap.zipcode = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingPostalCode);
            ap.country = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonMailingCountry);
            ap.email = ServiceUtil.checkNull(sa.Opportunity__r.Account.PersonEmail);
            ap.oppNo = ServiceUtil.checkNull(sa.Opportunity__r.opportunity_no__c);
            ap.confirmed = sa.Confirmed__c;
            ap.type=sa.Opportunity__r.Virtual_Appointment__c?RTAIntegration.VirtualAppointment:RTAIntegration.InHomeAppointment;
            //ap.timezoneCode = ServiceUtil.checkNull(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone);

            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
            Boolean isPhoneFound = false; 
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonHomePhone) && !isPhoneFound ) 
            {
                ap.phoneLabel = fieldMap.get('PersonHomePhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonHomePhone) ;
            }
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonMobilePhone) && !isPhoneFound ) 
            {
                ap.phoneLabel = fieldMap.get('PersonMobilePhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonMobilePhone) ;
            }
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonOtherPhone) && !isPhoneFound ) 
            {   
                ap.phoneLabel = fieldMap.get('PersonOtherPhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonOtherPhone) ;   
            }
            if(String.isNotBlank(sa.Opportunity__r.Account.PersonAssistantPhone) && !isPhoneFound ) 
            {
                ap.phoneLabel = fieldMap.get('PersonAssistantPhone').getDescribe().getLabel();
                ap.phoneValue = ServiceUtil.formatPhone(sa.Opportunity__r.Account.PersonAssistantPhone) ;   
            }

            ap.appointmentDatetime = sa.SchedStartTime ;
            if(!String.isBlank(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone) && ap.appointmentDatetime != null ){
                TimeZone tz = TimeZone.getTimeZone(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone);
                System.debug('UAC: tz ' + tz );
                ap.appointmentDatetime=ap.appointmentDatetime.addSeconds((tz.getOffset(ap.appointmentDatetime)/1000));
            }
            System.debug('UAC: ap.appointmentDatetime ' + ap.appointmentDatetime );

            res.appointments.add(ap);
        }
    
        return res;
    }
}