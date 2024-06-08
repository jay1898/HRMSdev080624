@RestResource(urlMapping='/PostVantageEmail/*')
global without sharing class ServicePOSTVantageEmail 
{    
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public String recordId;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    
    
    global class Request
    {
        public String opp_number;
        public String opportunity_id; 
        public String message; 
        public String sales_rep_id;
        public String appointment_id;
        public String customer_email;
        public links links;
    }
    
    public class links {
        public String sales_rep; 
        public String customer;       
    }
    
    @HttpPost
    global static Response postData()
    {
        RestRequest reqst = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        String reqBody ;
        
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_Vantage_Email_Integration__c) ) return res ;
        
        try{
            Request req;
            
            reqBody = reqst.requestBody.toString() ;
            
            // Try to deserialize REQUEST
            try{
                req = (Request)JSON.deserialize(reqBody,Request.class);
                Set<String> OpportunityNo= new Set<string>();
                OpportunityNo.add(req.opportunity_id);
                
                List<ServiceAppointment> listSA=[SELECT ID,OwnerId,Opportunity__c FROM ServiceAppointment  where id=:req.appointment_id];
                //List<Opportunity> listOpps = [SELECT Id, Legacy_Opportunity_Id__c,Account.Name,Legacy_Opportunity_CRM_Id__c FROM Opportunity where Legacy_Opportunity_Id__c IN: OpportunityNo  or Legacy_Opportunity_CRM_Id__c IN: OpportunityNo or Opportunity_No__c IN: OpportunityNo Or Id IN: OpportunityNo limit 1];
                //List<Opportunity> listOpps = [SELECT Id, Legacy_Opportunity_Id__c,ownerId,Account.Name,Legacy_Opportunity_CRM_Id__c,(select id,OwnerId from Appointments__r where id=:req.appointment_id) FROM Opportunity where Id =:req.opportunity_id limit 1];
                system.debug('@@listSA@@' + listSA);
                if(listSA.size()==0){ 
                    res.status = 'Appointment not found in system';
                    res.errorMessage = 'INVALID_INPUT_FORMAT:';
                    res.httpStatusCode = '400';
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTVantageEmail','postData',reqBody,JSON.serialize(res),'Opportunity not found in system','Integration'));
                    return res;
                }
                Vantage_Email__c VE = new Vantage_Email__c();
                VE.Opportunity_Number__c = req.opp_number;
                VE.Email__c = req.customer_email;
                VE.Message__c = req.message;
                VE.Customer_Reference_Link__c = req.links.customer;
                VE.Sales_rep_Reference_Link__c = req.links.sales_rep;
                VE.Sales_Rep_User__c = req.sales_rep_id;
                VE.appointment__c = req.appointment_id;
                if(listSA.size() > 0 ){
                    VE.Opportunity_Id__c = listSA[0].Opportunity__c;
                    //VE.ownerId = listSA[0].OwnerId;
                   
                }
                insert VE;
                if(listSA.size() > 0 ){
                    try{
                        SendEmail(VE);
                        //SendEmail(req.customer_email, req.links.customer,req.sales_rep_id,listOpps[0].Account.Name, listOpps[0].Id,req.message);
                    }catch(Exception e){
                        System.debug('Exception Message::'+e.getMessage());
                        System.debug('Exception Line::'+e.getLineNumber());
                    }
                   	
                }
                
                res.recordId=VE.Id;
            }catch (Exception e){
                res.status = e.getMessage();
                res.errorMessage = 'INVALID_INPUT_FORMAT:';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTVantageEmail','postData',reqBody,JSON.serialize(res),e.getStackTraceString(),'Integration'));
                return res;
            }
            
            restRes.responseBody = Blob.valueOf( JSON.serialize(res));
            restRes.headers.put('Content-Type','application/json');
            restRes.headers.put('Access-Control-Allow-Origin','*');
            
            new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTVantageEmail','postData',JSON.serialize(res),reqBody,'Integration'));
            
        }
        catch(Exception ex){
            System.debug('UAC: exception ' + ex.getMessage() );
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTVantageEmail','postData',reqst.requestBody.toString(),ex,'Integration'));
       		
        }
        return res; 
    }    
    
    //public static void SendEmail(String EmailId, String customerURL,String salesRepId,String customerName, String OppId,string message){
    public static void SendEmail(Vantage_Email__c VE){    
    // Send Mail
        OrgWideEmailAddress[] owea = [SELECT Id,Address FROM OrgWideEmailAddress WHERE displayName = :System.Label.Org_Wide_Communication_Email_Name];
        EmailTemplate ET = [SELECT Id,Name,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName ='Vantage_Email_Template'];
        List<Opportunity> listOpp=[SELECT ID,OwnerId,Owner.Email,Email_Email_Template__c FROM Opportunity where Id=:VE.Opportunity_Id__c];
        User salesRep=[SELECT ID,Name,Email,Phone FROM User Where Id=:VE.Sales_Rep_User__c];
        if(listOpp.size()>0){
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses =VE.Email__c.split('[\\s,;]+');
          
            mail.setToAddresses(toAddresses);
            if ( owea.size() > 0 ) {
                mail.setReplyTo(owea.get(0).Address);
            } 
            mail.setTargetObjectId([Select Id FROM Contact LIMIT 1].Id);
            mail.setTreatTargetObjectAsRecipient(false);
            
            mail.setSenderDisplayName(salesRep.Name);
            //mail.setSubject(ET.Subject);
            mail.setTemplateId(ET.Id);
            System.debug('VE Id::'+VE.Id);
            mail.setWhatId(VE.Id); 
            //mail.setHtmlBody(ET.Body);
            //mail.setPlainTextBody(ET.Body);
            //mail.setHtmlBody(ET.HtmlValue.replace('{{customerURL}}', customerURL).replace('{{customerName}}', customerName).replace('{{repName}}', salesRep.Name).replace('{{repEmail}}', salesRep.Email).replace('{{repPhone}}', salesRep.Phone));
            mail.setSaveAsActivity(false);
            
            emails.add(mail);
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            system.debug('@results@'+results);
        }
    }
}