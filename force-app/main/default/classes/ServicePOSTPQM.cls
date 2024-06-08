@RestResource(urlMapping='/postPQMData/*')
global without sharing class ServicePOSTPQM 
{
    @HttpPost
    global static PQMQuoteWrapper.Response postData()
    {   
        RestRequest reqst = Restcontext.request;
        PQMQuoteWrapper.Response res = new PQMQuoteWrapper.Response();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        
        List<PQMQuoteWrapper.Request> reqList;
         
        // Check Integration Switch settings, if disabled then go back  
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disbale_PQM_Integration__c ) ) return res ;
        
        String reqBody = reqst.requestBody.toString() ;
        
        // Try to Deserialize REQUEST
        try{
            String recordId =new ApexDebugLog().createLog(new ApexDebugLog.Information('PQMInbound','postData','The original PQM request is attached on the related tab', 'postData: Received Request','Integration'));
            Attachment reqAttachment=new Attachment();
            reqAttachment.Body=Blob.valueOf(reqBody);                            
            reqAttachment.Name=  'Request Body.txt';
            reqAttachment.parentId=recordId;
            insert reqAttachment;
            string errorMessage = 'Payload size is too large for Salesforce to process as it exceeds 131,072 characters';
            //Boolean isPQMCreated = true;
            reqList = (List<PQMQuoteWrapper.Request>)JSON.deserialize(reqBody,List<PQMQuoteWrapper.Request>.class);
            List<String> QuoteNo= new List<string>();
            for(PQMQuoteWrapper.Request req : reqList){
                if(req.quotenumber!=null && req.quotenumber!=''){
                    QuoteNo.add(req.quotenumber);
                     
                }
            }
            
            /*if(JSON.serialize(reqList).length() > 1048576){
                recordId=new ApexDebugLog().createLog(new ApexDebugLog.Information('PQMInbound','DATA_TOO_LARGE','Request Body: ' + errorMessage + ' Quote No: ' + String.join(QuoteNo,','), 'postData: Received Request','Error'));
                //isPQMCreated = false;
                res.status = 'Payload size is too large for Salesforce to process as it exceeds 131,072 characters';
                res.errorMessage = 'DATA_TOO_LARGE';
                res.httpStatusCode = '400';
                return res;
            } */ 
            /*else
                recordId=new ApexDebugLog().createLog(new ApexDebugLog.Information('PQMInbound','postData','Request Body: ' + reqBody, 'postData: Received Request','Integration'));*/
            
            Set<String> OpportunityNo= new Set<string>();
            Set<String> OpportunityNoSF= new Set<string>();
            for(PQMQuoteWrapper.Request req : reqList){
                if(req.opportunity!=null && req.opportunity!=''){
                    OpportunityNo.add(req.opportunity);
                    if(req.opportunity!=null && req.opportunity!='' && !req.opportunity.isNumeric()){
                        OpportunityNoSF.add(req.opportunity);
                    }
                }
            }
            
            List<Opportunity> listOpps = [SELECT Id, Legacy_Opportunity_Id__c,Legacy_Opportunity_CRM_Id__c FROM Opportunity where Legacy_Opportunity_Id__c in :OpportunityNo  or Legacy_Opportunity_CRM_Id__c in :OpportunityNo  Or Id IN :OpportunityNo];
            Map<String, String> mapOpportunity = new Map<String, String>();
            List<String> listOppsIds=new List<String>();
            for(Opportunity opp : listOpps){ 
                if(opp.Legacy_Opportunity_Id__c!=null){
                    mapOpportunity.put(opp.Legacy_Opportunity_Id__c,opp.Id);
                }
                if(opp.Legacy_Opportunity_CRM_Id__c!=null){
                    mapOpportunity.put(opp.Legacy_Opportunity_CRM_Id__c,opp.Id);
                }
                listOppsIds.add(opp.Id);
            }
            
            List<Opportunity> listOppRecs=[SELECT Id, Legacy_Opportunity_Id__c,Legacy_Opportunity_CRM_Id__c FROM Opportunity where Id IN :OpportunityNoSF];
            Map<String,Opportunity> mapOppsWithSFIds=new Map<String,Opportunity>();
            for(Opportunity Opp : listOppRecs){
                mapOppsWithSFIds.put(Opp.Id,Opp);
            } 
            
            /*List<Order> listOrderRecs=[SELECT Id FROM Order where Id IN :OpportunityNoSF];
            Map<String,Order> mapOrderWithSFIds=new Map<String,Order>();
            for(Order ord : listOrderRecs){
            mapOrderWithSFIds.put(ord.Id,ord);
            }*/
            
            List<PQM_Quote__c> quoteList = new List<PQM_Quote__c>();
            List<String> setFailOppNumber=new List<String>();
            Map<String, String> quoteNumberVSJSON = new Map<String, String>();
            
            String OppNo;
            for(PQMQuoteWrapper.Request req : reqList){
                if(req.opportunity!=null && req.opportunity!=''){
                    OppNo=req.Opportunity;
                    if(mapOpportunity.containsKey(req.Opportunity)){
                        OppNo=mapOpportunity.get(req.Opportunity);
                    }else if(listOppsIds.contains(req.Opportunity)){
                        OppNo=req.Opportunity;
                    }else if(mapOppsWithSFIds.containsKey(req.Opportunity)){
                        OppNo=mapOppsWithSFIds.get(req.Opportunity).Id;
                    }/*else if(mapOrderWithSFIds.containsKey(req.Opportunity)){
                        OppNo=mapOrderWithSFIds.get(req.Opportunity).Id;
                    }*/else{
                        setFailOppNumber.add(req.Opportunity);
                        continue;   
                    }
                    
                    PQM_Quote__c PQ=new PQM_Quote__c();
                    PQ.Apex_Debug_Log__c=string.isNotBlank(recordId)?recordId:null;
                    /*if(OppNo.startsWith('801')){
                    PQ.Order__c=OppNo;
                    }else{*/ 
                    PQ.Opportunity__c=OppNo;
                    // }
                    PQ.contactName__c=req.contactname;
                    PQ.orgContactId__c=req.orgContactId; 
                    system.debug('JSON ::::::::::::'+JSON.serialize(req));
                    system.debug('Length ::::::::::::'+JSON.serialize(req).length());
                    PQ.Quote_Number__c = req.quotenumber;
                    quoteNumberVSJSON.put(req.quotenumber, JSON.serialize(req));
                    system.debug('@quoteNumberVSJSON@'+ quoteNumberVSJSON);
                    
                    /*if(JSON.serialize(req).length() > 131072){
                        PQ.PQM_Data__c=JSON.serialize(req).substring(0,131072);
                        if(JSON.serialize(req).substring(131072, JSON.serialize(req).length()).length() > 131072 ){
                            PQ.PQM_Data_2__c = JSON.serialize(req).substring(131072, 262144);
                            if(JSON.serialize(req).substring(262144, JSON.serialize(req).length()).length() > 131072){
                                PQ.PQM_Data_3__c = JSON.serialize(req).substring(262144, 393216);
                                if(JSON.serialize(req).substring(393216, JSON.serialize(req).length()).length() > 131072 ){
                                    PQ.PQM_Data_4__c = JSON.serialize(req).substring(393216, 524288);
                                    if(JSON.serialize(req).substring(524288, JSON.serialize(req).length()).length() > 131072 ){
                                        PQ.PQM_Data_5__c = JSON.serialize(req).substring(524288, 655360);
                                        if(JSON.serialize(req).substring(655360, JSON.serialize(req).length()).length() > 131072 ){
                                            PQ.PQM_Data_6__c = JSON.serialize(req).substring(655360, 786432);
                                            if(JSON.serialize(req).substring(786432, JSON.serialize(req).length()).length() > 131072 ){
                                                PQ.PQM_Data_7__c = JSON.serialize(req).substring(786432, 917504);
                                                if(JSON.serialize(req).substring(917504, JSON.serialize(req).length()).length() > 131072 ){
                                                    PQ.PQM_Data_8__c = JSON.serialize(req).substring(917504, 1048576);
                                                }
                                                else{
                                                    PQ.PQM_Data_8__c = JSON.serialize(req).substring(917504, JSON.serialize(req).length());
                                                }
                                            }
                                            else{
                                                PQ.PQM_Data_7__c = JSON.serialize(req).substring(786432, JSON.serialize(req).length());
                                            }
                                        }
                                        else{
                                            PQ.PQM_Data_6__c = JSON.serialize(req).substring(655360, JSON.serialize(req).length());
                                        }
                                    }
                                    else{
                                        PQ.PQM_Data_5__c = JSON.serialize(req).substring(524288, JSON.serialize(req).length());
                                    }
                                }
                                else{
                                    PQ.PQM_Data_4__c = JSON.serialize(req).substring(393216, JSON.serialize(req).length());
                                }
                            }
                            else{
                                PQ.PQM_Data_3__c = JSON.serialize(req).substring(262144, JSON.serialize(req).length());
                            }
                        }
                        else{
                            PQ.PQM_Data_2__c = JSON.serialize(req).substring(131072, JSON.serialize(req).length());
                        }
                    }
                    else
                        PQ.PQM_Data__c=JSON.serialize(req);*/
                    PQ.salesrepusername__c=req.salesrepusername;
                    quoteList.add(PQ);
                }
            }
            //if(isPQMCreated)
                insert quoteList; 
            
            if(!quoteList.isEmpty()){
                List<Attachment> attachmentLst = new List<Attachment>();
                for(PQM_Quote__c PQM : quoteList){
                    Attachment att=new Attachment();
                    if(!quoteNumberVSJSON.isEmpty()){
                        if(quoteNumberVSJSON.containsKey(PQM.Quote_Number__c)){
                            att.Body=Blob.valueOf(quoteNumberVSJSON.get(PQM.Quote_Number__c));                            
                        }
                        att.Name= PQM.Quote_Number__c + '.txt';
                        att.parentId=PQM.id;
                        attachmentLst.add(att);
                    }
                }
                if(!attachmentLst.isEmpty()){
                    insert attachmentLst;
                }
                system.debug('@attachmentLst@'+ attachmentLst);
            }
            
            if(setFailOppNumber.size()==reqList.size()){
                res.status = 'All Opportunity are incorrect :'+JSON.serialize(setFailOppNumber);
                res.errorMessage = 'INVALID_DATA';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('PQMInbound','postData','Request Body: ' + reqBody, JSON.serialize(res), 'Integration'));
                
            }else if(setFailOppNumber.size()>0){
                res.status = 'Some Of Opportunity are incorrect :'+JSON.serialize(setFailOppNumber);
                res.errorMessage = 'INVALID_DATA';
                res.httpStatusCode = '400';
                new ApexDebugLog().createLog(new ApexDebugLog.Error('PQMInbound','postData','Request Body: ' + reqBody, JSON.serialize(res), 'Integration'));
            }
        }catch (Exception e){
            system.debug('Error Message::::::::::::'+e.getMessage());
            system.debug('Error Message Line:::::::'+e.getLineNumber());
            res.status = e.getMessage();
            res.errorMessage = 'INVALID_INPUT_FORMAT:';
            res.httpStatusCode = '400';
            new ApexDebugLog().createLog(new ApexDebugLog.Error('PQMInbound','postData','Request Body: ' + reqBody, JSON.serialize(res), e.getStackTraceString(),'Integration'));
            return res;
        }
        new ApexDebugLog().createLog(new ApexDebugLog.Information('PQMInbound','postData','Response Body: ' + JSON.serialize(res), 'postData: Generated Response','Integration'));
        return res;  
    }
}