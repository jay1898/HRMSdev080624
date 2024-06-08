/*
Created By: Dhruv 
Created Date: 12/05/2022
Purpose: PQM Integartion callout from apex to send information/data.
------------------------------------------------------------------------------------------------
*/
public class PQMIntegrationCallout {
    
    @future(callout=true)
    public static void getLineItemDataPQMCallout(List<String> QuoteIds) {
        List<Quote> listQuote=[SELECT ID,Quote_Number_PQM__c,(select id from quoteLineItems) FROM Quote Where Id = :quoteIds];
        
        try{
            // Check Integration Switch settings, if disabled then go back 
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disbale_PQM_Integration__c) ) return;
            
            List<Endpoint_Configuration__mdt> pqmMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'PQM_Integration' ]; 
            for(Quote q : listQuote){
                if(q.Quote_Number_PQM__c!=null && q.quoteLineItems.size()==0)
                {
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(pqmMetaData[0].Endpoint__c+q.Quote_Number_PQM__c+'?callingsystem=Salesforce');
                    request.setMethod('POST');
                    request.setHeader('Authorization', 'Bearer '+pqmMetaData[0].Token__c);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Accept', 'application/json');
                    request.setTimeout(120000);
                    
                    request.setBody('{}');
                    
                    HttpResponse response = http.send(request);
                    
                    // Information Log
                    new ApexDebugLog().createLog(
                        new ApexDebugLog.Information(
                            'PQMIntegrationCallout',
                            'getLineItemDataPQMCallout',
                            'URL : '+pqmMetaData[0].Endpoint__c+q.Quote_Number_PQM__c+'?callingsystem=Salesforce,\n'
                            +'Method : POST,\n'
                            + 'Req Body : '+q.Quote_Number_PQM__c,
                            'getLineItemDataPQMCallout Request',
                            'Integration'
                        )
                    );
                    new ApexDebugLog().createLog(
                        new ApexDebugLog.Information(
                            'PQMIntegrationCallout',
                            'getLineItemDataPQMCallout',
                            'URL : '+pqmMetaData[0].Endpoint__c+q.Quote_Number_PQM__c+'?callingsystem=Salesforce,\n'
                            +'Response Body : ' + response.getBody(),
                            'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                            'Integration'
                        )
                    );
                    // Parse the JSON response
                    if (response.getStatusCode() != 200) {
                        System.debug('The status code returned was not expected: ' +
                                     response.getStatusCode() + ' ' + response.getStatus());
                        new ApexDebugLog().createLog(
                            new ApexDebugLog.Error(
                                'PQMIntegrationCallout',
                                'getLineItemDataPQMCallout',
                                'URL : '+pqmMetaData[0].Endpoint__c+q.Quote_Number_PQM__c+'?callingsystem=Salesforce,\n'
                                +'Method : POST,\n'
                                + 'Req Body : '+q.Quote_Number_PQM__c,
                                'The status code returned was not expected: ' + response.getStatusCode() + ': ' + response.getStatus() + ': ' + response.getBody(),
                                null,
                                'Integration'
                            )
                        );
                    } 
                }
            }
           
            
        }catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('PQMIntegrationCallout','getLineItemDataPQMCallout',JSON.serialize(QuoteIds),ex,'Integration'));
        }
        
        
    }//End of updateCustomerEBSData
    
}