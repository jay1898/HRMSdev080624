@RestResource(urlMapping='/ConvertLead/*')
global without sharing class ServicePOSTLeadConvert {
    global class Response{
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response(){
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    
    
    global class Request{
        public String oppno ; 
        public String start ; 
        public String end_z ; 
        public String leadid;
        public string comments;
        public Boolean virtualapptmt ; 
    }
    
    global class RequestRTA{
        public String recid ; 
        public String firstname ; 
        public String lastname ; 
        public String address ; 
        public String address2 ; 
        public String country ; 
        public String city ; 
        public String state ; 
        public String zip ; 
        public String dayphone ; 
        public String phonetype ; 
        public String evephone ;
        public String evephonetype ;
        public String email ; 
        public String urlstring ; 
        public String apptsource ; 
        public String comments ; 
        public String destination ; 
        public String branchID ; 
        public String start ; 
        public String end_z ; 
        public String resource ; 
        public String notifyemail ; 
        public String consentcall ; 
        public String consentsms ; 
        public string consenttomail;
        public string consenttophone;
        public String apptreqtype ; 
        public String appttype ; 
        public String storename ; 
        public Integer noOfDoors ;
        public Integer noOfWindows ;
        public String oppNo ;
        // added for timezone handle
        public String TimeZone_Code;
        public String callerId ;
        public String callcenteruid ;
        public String leadsource ;
        public String marketingsource ;
        public String showroomreqtype ;
         public Boolean virtualapptmt ; 
        
    }
    
    @HttpPost
    global static Response postData()
    {
        RestRequest reqst = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');

        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTA_Integration__c ) ) return res ;
        
        try{
            Request req;
            String reqBody = reqst.requestBody.toString() ;
            reqBody = reqBody.replaceAll('"end"', '"end_z"');
            System.debug('reqBody ' + reqBody );
            
            try{
                req = (Request)JSON.deserialize(reqBody,Request.class);
                System.debug('req ' + req );
                
                if(String.isNotBlank(req.oppNo) && String.isNotBlank(req.leadid)){
                       Lead leadObj = new Lead();
                       if(String.isNotBlank(req.start) && String.isNotBlank(req.end_z)){
                            DateTime StartDateTime = DateTime.valueOf(req.start.replace('T', ' ').replace('Z', ''));
                            DateTime EndDateTime = DateTime.valueOf(req.end_z.replace('T', ' ').replace('Z', ''));
                           leadObj.Scheduled_Start__c = StartDateTime;
                           leadObj.Scheduled_End__c = EndDateTime;
                       }
                       
                       leadObj.Opportunity_No__c = req.oppNo;
                       leadObj.Id = req.leadid;
                       leadObj.Virtual_Appointment__c =req.virtualapptmt==null?false:req.virtualapptmt;
                       
                       leadObj.Conversion_Comments__c = req.comments;
                       update leadObj;
                       
                       leadObj = [SELECT ID, Opportunity_No__c, FirstName, LastName, Street, Country, City, State, PostalCode, HomePhone__c,Response_Channel__c,
                   			      HasOptedOutOfFax,HasOptedOutOfEmail,Text_Opt_Out__c,PersonHasOptedOutofMail__c,PersonAutoCall__c,DoNotCall,
                                  MobilePhone__c, Phone,AsstPhone__c, Email, Conversion_Comments__c, Scheduled_Start__c,
                                  Scheduled_End__c, No_of_Windows__c,Virtual_Appointment__c, No_of_Doors__c, Showroom_Request_Type__c, Campaign__c,Zone__r.ParentTerritory.Branch__r.Branch_Number__c
                                  FROM Lead WHERE Id =:req.leadid];
                       
                       /*JSONGenerator gen = JSON.createGenerator(false);
                       gen.writeStartObject();
                       gen.writeStringField('oppNo',String.isBlank(leadObj.Opportunity_No__c) ? '' : leadObj.Opportunity_No__c);
                       gen.writeStringField('firstname', String.isBlank(leadObj.FirstName) ? '' : leadObj.FirstName);
                       gen.writeStringField('lastname', String.isBlank(leadObj.LastName) ? '' : leadObj.LastName);
                       gen.writeStringField('address', String.isBlank(leadObj.Street) ? '' : leadObj.Street);
                       gen.writeStringField('address2', String.isBlank(leadObj.Street) ? '' : leadObj.Street);
                       gen.writeStringField('country', String.isBlank(leadObj.Country) ? '' : leadObj.Country);
                       gen.writeStringField('city', String.isBlank(leadObj.City) ? '' : leadObj.City);
                       gen.writeStringField('state', String.isBlank(leadObj.State) ? '' : leadObj.State);
                       gen.writeStringField('zip', String.isBlank(leadObj.PostalCode) ? '' : leadObj.PostalCode);
                       
                       String dayPhone = String.isBlank(String.valueOf(leadObj.HomePhone__c)) ? String.isBlank(String.valueOf(leadObj.MobilePhone__c))? String.isBlank(String.valueOf(leadObj.Phone))? '' : String.valueOf(leadObj.Phone): String.valueOf(leadObj.MobilePhone__c): String.valueOf(leadObj.HomePhone__c);
                       String phonetype = String.isBlank(String.valueOf(leadObj.HomePhone__c)) ? String.isBlank(String.valueOf(leadObj.MobilePhone__c))? String.isBlank(String.valueOf(leadObj.Phone))? '' : 'Work': 'Mobile': 'Home';
                       gen.writeStringField('dayphone', dayPhone);
                       gen.writeStringField('phonetype', phonetype);
                       gen.writeStringField('evephone', String.isBlank(leadObj.AsstPhone__c) ? '' : leadObj.AsstPhone__c);
                       
                       gen.writeStringField('email', String.isBlank(leadObj.Email) ? '' : leadObj.Email);
                       gen.writeStringField('comments', String.isBlank(leadObj.Conversion_Comments__c) ? '' : leadObj.Conversion_Comments__c);
                       gen.writeStringField('branchID', '');
                       gen.writeStringField('start', String.isBlank(String.valueOf(leadObj.Scheduled_Start__c)) ? '' : String.valueOf(leadObj.Scheduled_Start__c));
                       gen.writeStringField('end_z', String.isBlank(String.valueOf(leadObj.Scheduled_End__c)) ? '' : String.valueOf(leadObj.Scheduled_End__c));
                       gen.writeStringField('notifyemail', '');
                       gen.writeStringField('noOfWindows', String.isBlank(String.valueOf(leadObj.No_of_Windows__c)) ? '' : String.valueOf(leadObj.No_of_Windows__c));
                       gen.writeStringField('noOfDoors', String.isBlank(String.valueOf(leadObj.No_of_Doors__c)) ? '' : String.valueOf(leadObj.No_of_Doors__c));
                       
                       gen.writeStringField('appttype', 'RT');
                       gen.writeStringField('apptsource', 'Showroom');
                       gen.writeStringField('showroomreqtype', String.isBlank(leadObj.Showroom_Request_Type__c) ? '' : leadObj.Showroom_Request_Type__c);
                       gen.writeStringField('leadsource', '');
                       gen.writeStringField('marketingsource', String.isBlank(leadObj.Campaign__c) ? '' : leadObj.Campaign__c);
                       
                       //Extra
                       gen.writeStringField('recid', '');
                       gen.writeStringField('evephonetype', '');
                       gen.writeStringField('urlstring', '');
                       gen.writeStringField('destination', '');
                       gen.writeStringField('resource', '');
                       gen.writeStringField('consentcall', '');
                       gen.writeStringField('consentsms', '');
                       gen.writeStringField('apptreqtype', '');
                       gen.writeStringField('storename', '');
                       gen.writeStringField('TimeZone_Code', '');
                       gen.writeStringField('callerId', '');
                       gen.writeStringField('callcenteruid', '');
                       gen.writeEndObject();
                       
                       String JSONString = gen.getAsString();*/
                       RestRequest reqst1 = Restcontext.request;
                       RequestRTA rtaReq =  makeRequestForRTA(leadObj);
                       if(String.isNotBlank(req.start) && String.isNotBlank(req.end_z)){
                           DateTime StartDateTime = DateTime.valueOf(req.start.replace('T', ' ').replace('Z', ''));
                           DateTime EndDateTime = DateTime.valueOf(req.end_z.replace('T', ' ').replace('Z', ''));
                           rtaReq.start=String.valueOf(StartDateTime);
                           rtaReq.end_z=String.valueOf(EndDateTime);
                       }else{
                           rtaReq.appttype='Preferred';
                       }
                       String JSONString = JSON.serialize(rtaReq);
                       reqst1.requestBody = Blob.valueOf(JSONString) ;
                       
                       ServicePOSTRTA.Response res1 = ServicePOSTRTA.postData();
                       // Attach Oppo with lead if lead exist
                       List<Opportunity> listOpportunity=[SELECT ID,AccountId From Opportunity Where Opportunity_No__c =:req.oppNo];
                       if(listOpportunity.size()>0){
                           leadObj.ConvertedOpportunityId__c=listOpportunity[0].Id;
                       }       
                       
                       leadObj.Status = 'Converted';
                       //leadObj.IsConverted = true;
                        update leadObj;
                        System.debug('@@JSON : '+JSONString);
                        
                        new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTLeadConvert','postData',reqBody,JSON.serialize(res),'Integration'));
                        
                   }
                else{
                    res.status = 'Failed';
                    res.errorMessage = 'OpportunityNo, ScheduleStartDate, ScheduleEnddate, LeadId and ConversionComments field must be required ';
                    res.httpStatusCode = '400';
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTLeadConvert','postData',reqBody,JSON.serialize(res),'Integration'));
                }
            }
            catch (Exception e){
                res.status = e.getMessage();
                res.errorMessage = 'INVALID_INPUT_FORMAT:';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTLeadConvert','postData',reqBody,JSON.serialize(res),e.getStackTraceString(),'Integration'));
                return res;
            }
            restRes.responseBody =Blob.valueOf( JSON.serialize(res));
        }
        catch(Exception ex){
            System.debug('exception ' + ex.getMessage() );
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTLeadConvert','postData',reqst.requestBody.toString(),ex,'Integration'));
        }
        return res;
    }
    
    public static RequestRTA makeRequestForRTA(Lead leadObj)
    {
        RequestRTA reqRTA = new RequestRTA();
        // Make efficient Request Attributes by checking null values 
        reqRTA.oppNo = String.isBlank(leadObj.Opportunity_No__c) ? '' : leadObj.Opportunity_No__c;
        reqRTA.firstname = String.isBlank(leadObj.FirstName) ? '' : leadObj.FirstName;
        reqRTA.lastname = String.isBlank(leadObj.LastName) ? '' : leadObj.LastName;
        reqRTA.address = String.isBlank(leadObj.Street) ? '' : leadObj.Street;
        reqRTA.country = String.isBlank(leadObj.Country) ? '' : leadObj.Country;
        if(reqRTA.country.length() == 3) reqRTA.country = reqRTA.country.left(2);
        reqRTA.city = String.isBlank(leadObj.City) ? '' : leadObj.City;
        reqRTA.state = String.isBlank(leadObj.State) ? '' : leadObj.State;
        if(reqRTA.state.length() == 3) reqRTA.state = reqRTA.state.left(2);
        reqRTA.zip =  String.isBlank(leadObj.PostalCode) ? '' : leadObj.PostalCode;
        
        String dayPhone = String.isBlank(String.valueOf(leadObj.HomePhone__c)) ? String.isBlank(String.valueOf(leadObj.MobilePhone__c))? String.isBlank(String.valueOf(leadObj.Phone))? '' : String.valueOf(leadObj.Phone): String.valueOf(leadObj.MobilePhone__c): String.valueOf(leadObj.HomePhone__c);
        String phonetype = String.isBlank(String.valueOf(leadObj.HomePhone__c)) ? String.isBlank(String.valueOf(leadObj.MobilePhone__c))? String.isBlank(String.valueOf(leadObj.Phone))? '' : 'Work': 'Mobile': 'Home';
        reqRTA.dayphone = dayPhone;
        reqRTA.phonetype = phonetype ;
        reqRTA.email = String.isBlank(leadObj.Email) ? '' : leadObj.Email;
        reqRTA.evephone = String.isBlank(leadObj.AsstPhone__c) ? '' : leadObj.AsstPhone__c;
        reqRTA.urlstring = '';
        reqRTA.branchID = leadObj.Zone__r.ParentTerritory.Branch__r.Branch_Number__c;
        //reqRTA.apptsource = string.isBlank(leadObj.Response_Channel__c)?'Showroom': leadObj.Response_Channel__c;
        reqRTA.apptsource = 'Showroom' ;
        reqRTA.comments = String.isBlank(leadObj.Conversion_Comments__c) ? '' : leadObj.Conversion_Comments__c;
        reqRTA.destination = '' ;
        reqRTA.start = String.isBlank(String.valueOf(leadObj.Scheduled_Start__c)) ? '' : String.valueOf(leadObj.Scheduled_Start__c);
        reqRTA.end_z = String.isBlank(String.valueOf(leadObj.Scheduled_End__c)) ? '' : String.valueOf(leadObj.Scheduled_End__c);
        reqRTA.noOfWindows = leadObj.No_of_Windows__c == null ? 0 : Integer.valueOf(leadObj.No_of_Windows__c);
        reqRTA.noOfDoors = leadObj.No_of_Doors__c == null ? 0 : Integer.valueOf(leadObj.No_of_Doors__c);
        reqRTA.resource = '';
        reqRTA.notifyemail = leadObj.PersonHasOptedOutofMail__c?'N':'Y';
        reqRTA.consentsms = leadObj.Text_Opt_Out__c?'N':'Y';
        reqRTA.consentcall = leadObj.PersonAutoCall__c?'N':'Y';
        reqRTA.consenttophone = leadObj.DoNotCall?'N':'Y';
        reqRTA.consenttomail = leadObj.HasOptedOutOfEmail?'N':'Y';
        
        reqRTA.apptreqtype = '';
        reqRTA.appttype = 'RT';
        reqRTA.storename = '';
        reqRTA.callerId = '';
        reqRTA.callcenteruid = '';
        reqRTA.showroomreqtype = String.isBlank(leadObj.Showroom_Request_Type__c) ? '' : leadObj.Showroom_Request_Type__c;
        if(!String.isBlank(leadObj.Campaign__c)){
             reqRTA.marketingsource = leadObj.Campaign__c;
        }
        reqRTA.virtualapptmt=leadObj.Virtual_Appointment__c;
        
        return reqRTA ;
    }
}