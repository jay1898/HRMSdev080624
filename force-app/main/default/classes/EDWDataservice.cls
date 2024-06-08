/*
Created By: Sachin Padhiyar
Created Date: 10/08/2020 
Purpose: EDWDataservice class used to expose the URL mapping to external system to fetch objects data.
------------------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-------------------------------------------------------------------------------------------------------
*/


//RestResource to use as URL mapping for External system
@RestResource(urlMapping='/EDWDataservice/*')
global class  EDWDataservice{
    // Annotation to use GET method 
    @HttpGet 
    global static void getRequestParameter() {
        Response resBody = new Response();
        
        // Intialization of list for ADL object
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            res.headers.put('Content-Type','application/json');
            res.headers.put('Access-Control-Allow-Origin','*');
            String validToD = RestContext.request.params.get('validTo');
            String validFromD = RestContext.request.params.get('validFrom');
            dateTime validTo;
            dateTime validFrom;
            system.debug('@@validToD'+validToD);
            // Try to deserialize REQUEST
            try{
                validTo= dateTime.ValueOf(validToD);
                validFrom= dateTime.ValueOf(validFromD);
                
                
                List<AsyncApexJob> listAA=[Select Id, Status,ApexClassId,ApexClass.Name, NumberOfErrors, 
                                           JobItemsProcessed,TotalJobItems, ExtendedStatus 
                                           From AsyncApexJob 
                                           Where ApexClass.Name in('DailyEDWOpportunityFeed','DailyEDWAccountFeed','DailyEDWQuoteFeed','DailyEDWUserFeed','DailyEDWServiceTerritoryFeed','DailyEDWTaskFeed')
                                           And Status in ('Holding','Processing','Queued','Preparing')];
                if(listAA.size()>0){
                    resBody.status = Label.EDWPrevRequestInProgress;
                    resBody.errorMessage = 'PREVIOUS_REQUEST_ALREADY_IN_PROCESS:';
                    resBody.httpStatusCode = '400';
                    res.statusCode=400;
                    res.responseBody =Blob.valueOf(JSON.serialize(resBody));
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('EDWDataservice','getRequestParameter','Request Body: ' + JSON.serialize(RestContext.request.params), JSON.serialize(resBody), 'Integration'));
                    return;
                }
                
                // Check Start date must be less then end date
                if(validFrom>validTo){
                    resBody.status = Label.EDWFromDateMustBeLessThenToDate;
                    resBody.errorMessage = 'INVALID_INPUT_FORMAT:';
                    resBody.httpStatusCode = '400';
                    res.statusCode=400;
                    res.responseBody =Blob.valueOf(JSON.serialize(resBody));
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('EDWDataservice','getRequestParameter','Request Body: ' + JSON.serialize(RestContext.request.params), JSON.serialize(resBody), 'Integration'));
                    return;
                }
                
                // Check Start date must be less then end date
                if(validFrom.Date().daysBetween(validTo.Date())> Integer.valueOf(Label.EDWMaxDayDiff)){
                    resBody.status =Label.EDWDateDifferenceMustWithinRange;
                    resBody.errorMessage = 'INVALID_INPUT_FORMAT:';
                    resBody.httpStatusCode = '400';
                    res.statusCode=400;
                    res.responseBody =Blob.valueOf(JSON.serialize(resBody));
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('EDWDataservice','getRequestParameter','Request Body: ' + JSON.serialize(RestContext.request.params), JSON.serialize(resBody), 'Integration'));
                    return;
                }
            }catch (Exception e){
                resBody.status = Label.EDWInvalidDateFormat	;
                resBody.errorMessage = 'INVALID_INPUT_FORMAT:';
                resBody.httpStatusCode = '400';
                res.statusCode=400;
                res.responseBody =Blob.valueOf(JSON.serialize(resBody));
                new ApexDebugLog().createLog(new ApexDebugLog.Error('EDWDataservice','getRequestParameter',JSON.serialize(resBody),'validFromD='+validFromD+' , '+'validToD='+validToD,e.getStackTraceString(),'Integration'));
            	return;
            }
            
            if(test.isRunningTest()){
                validTo=dateTime.now();
                validFrom=dateTime.now().addDays(-40);
            }
            
            
            // Intialization of ADL object to create a ADL record
            Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
            objApex.Opportunity__c=true;
            objApex.Apex_Class__c='EDWDataservice';
            objApex.Method__c='GET';
            insert objApex;
            
            //Query to fetch the ADL record ID for Opportunity
            //lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Opportunity__c=true ORDER BY Name DESC limit 1];
            objApex.EDW_Transaction_ID__c=objApex.id;
            //objApex.id=lstApexDebug[0].id;
            update objApex;
            
            string TxnId = objApex.id;//lstApexDebug[0].Id;
            //Calling OpportunityBatchprocess with parameters
            DailyEDWOpportunityFeed objExecuteProcess = new DailyEDWOpportunityFeed(validFrom,validTo,TxnId,false);
            Database.executeBatch( objExecuteProcess, Integer.valueOf(Label.EDW_Batch_Size));
            
            resBody.status = 'Success'	;
            resBody.Message = Label.EDWSuccessResponse +', TxnId-'+TxnId;
            resBody.httpStatusCode = '200';
            res.responseBody= Blob.valueOf(JSON.serialize(resBody)); 
            
        }
        catch(Exception e) {
            
        }
    } 
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public String Message ;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    

}