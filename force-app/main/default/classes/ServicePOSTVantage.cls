@RestResource(urlMapping='/PostVantage/*')
global without sharing class ServicePOSTVantage 
{    
    global class Response
    {
        public String status; 
        public String surveyId; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    
    
    global class Request
    {
        public String opportunity; 
        public String appointmentId; 
        public List<questions> questions;
        public financing financing;
    }
    
    public class questions {
        public String key;
        public String question_id;
        public String question_text; 
        public String answer_text; 
        public String notes; 
    }
    public class financing {
        public String payment_terms;
        public String down_payment;
        public String deposit; 
        public String total_discount; 
        public String total_price; 
        public String sale_total;
        public String total_install;
        public String tax_rate;
        
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
        if(cs != null && (cs.Disable_All__c || cs.Disable_Vantage_Integration__c) ) return res ; 
        
        try{
            Request req;
            
            reqBody = reqst.requestBody.toString() ;
            //System.debug('@@reqBody@@' + reqBody );
            
            // Try to deserialize REQUEST
            try{
                req = (Request)JSON.deserialize(reqBody,Request.class);
                
                if(req.appointmentId==null || req.appointmentId==''){
                    res.status = 'Appointment Id is blank.';
                    res.errorMessage = 'INVALID_INPUT_DATA:';
                    res.httpStatusCode = '400';
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTVantage','postData',reqBody,JSON.serialize(res),res.status,'Integration'));
                    return res;
                }
                List<ServiceAppointment> listSA=[SELECT Id,Opportunity__c,ownerId FROM ServiceAppointment where id=:req.appointmentId];
                if(listSA.size()==0){
                    res.status = 'Appointment Id not exist in system';
                    res.errorMessage = 'INVALID_INPUT_DATA:';
                    res.httpStatusCode = '400';
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTVantage','postData',reqBody,JSON.serialize(res),res.status,'Integration'));
                    return res;
                }else{
                    req.Opportunity=listSA[0].Opportunity__c;
                }
                
                List<Vantage_Config__mdt> VCmetadata = [SELECT Id, Question_Key__c, Question_API_FieldName__c, Notes_API_FieldName__c FROM Vantage_Config__mdt];
                map<String, String> QuestionMap = new map<String, String>();
                map<String, String> NoteMap = new map<String, String>();
                
                for(Vantage_Config__mdt VCM : VCmetadata){
                    QuestionMap.put(VCM.Question_Key__c, VCM.Question_API_FieldName__c);
                    NoteMap.put(VCM.Question_Key__c, VCM.Notes_API_FieldName__c);
                }
                system.debug('@QuestionMap@'+ QuestionMap);
                Set<String> objectFields = Schema.SObjectType.Vantage_Survey__c.fields.getMap().keySet();
                SObject VS = new Vantage_Survey__c();
                
                // Store Finance Information
                financing f=req.financing;
                
                VS.put('Finance_Payment_Terms__c',f.payment_terms);
                VS.put('Finance_Down_Payment__c',f.down_payment!=null?Decimal.valueOf(f.down_payment):null);
                VS.put('Finance_Deposit__c',f.deposit!=null?Decimal.valueOf(f.deposit):null);
                VS.put('Finance_Total_Discount__c',f.total_discount!=null?Decimal.valueOf(f.total_discount):null);
                VS.put('Finance_Total_Price__c',f.total_price!=null?Decimal.valueOf(f.total_price):null);
                VS.put('Finance_Sale_Total__c',f.sale_total!=null?Decimal.valueOf(f.sale_total):null);
                VS.put('Finance_Total_Install__c',f.total_install!=null?Decimal.valueOf(f.total_install):null);
                VS.put('Finance_Tax_Rate__c',f.tax_rate!=null?Decimal.valueOf(f.tax_rate):null);
                
                //VS.put('ownerId',listSA[0].OwnerId); 
                
                
                for(questions que : req.questions){
                    if(QuestionMap.containsKey(que.key)  && QuestionMap.get(que.key)!=null){
                        if(objectFields.contains((QuestionMap.get(que.key)).toLowerCase())){
                            VS.put(QuestionMap.get(que.key),que.answer_text);
                        }
                    }
                    if(NoteMap.containsKey(que.key) && NoteMap.get(que.key)!=null){
                        if(objectFields.contains((NoteMap.get(que.key)).toLowerCase())){
                            if(que.notes != null && que.notes != ''){
                                VS.put(NoteMap.get(que.key),que.notes);
                            }
                        }
                    }
                    VS.put('Opportunity__c',req.opportunity);
                    VS.put('Appointment__c',req.appointmentId);
                }
                insert VS;
                res.surveyId = VS.Id;
            }catch (Exception e){
                res.status = e.getMessage();
                res.errorMessage = 'INVALID_INPUT_FORMAT:';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTVantage','postData',reqBody,JSON.serialize(res),e.getStackTraceString(),'Integration'));
                return res;
            }
            
            restRes.responseBody = Blob.valueOf( JSON.serialize(res));
            restRes.headers.put('Content-Type','application/json');
            restRes.headers.put('Access-Control-Allow-Origin','*');
            
            new ApexDebugLog().createLog(new ApexDebugLog.Information('ServicePOSTVantage','postData',JSON.serialize(res),reqBody,'Integration'));
            
        }
        catch(Exception ex){
            System.debug('UAC: exception ' + ex.getMessage() );
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ServicePOSTVantage','postData',reqst.requestBody.toString(),ex,'Integration'));
        }
        return res;
    }    
}