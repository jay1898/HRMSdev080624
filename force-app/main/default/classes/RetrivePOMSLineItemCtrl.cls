/**
 * @description       : RetrivePOMSLineItemCtrl to fetch POMSLineItem
 * @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
 * @group             : eVerge
 * History 	
 * Ver   Date         Author        Modification
 * 1.0   08-03-2022    Dhruv Javiya  Initial Version()
**/
public without sharing class RetrivePOMSLineItemCtrl {
    @AuraEnabled
    public static Map<String,String> getQuoteDetails(String recordId){
        //return [SELECT Id,Name ,PO_Number__c FROM Quote Where Work_Order__c= : recordId ];
        Map<String,String> dataMap=new  Map<String,String>();
        if(recordId!=null && recordId.startsWith('1WL')){
            List<WorkOrderLineItem> listWOLI=[SELECT ID,Quote__c FROM WorkOrderLineItem Where Id = :recordId];
            dataMap.put('Quotes',JSON.serialize([SELECT Id,Name ,PO_Number__c,Work_Order__r.Quote__c,Recovery__c  FROM Quote Where Id= : listWOLI[0].Quote__c ]));
        }else{
            dataMap.put('Quotes',JSON.serialize([SELECT Id,Name ,PO_Number__c,Work_Order__r.Quote__c,Recovery__c  FROM Quote Where Work_Order__c= : recordId ]));
        }
        return dataMap;
    }
    @AuraEnabled
    public static String getPOMSLineItemDetails(String recordId){
        system.debug('@@'+recordId);
        //String PONumn ='230MY0206';// '042MKR302A';//230MY0220';//'230MY0220'; 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_POMS_Integration__c) ) return '';
        List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'POMS_EndPoint' ];   
     
        List<Quote> listQuoteRecords = [select id,QuoteNumber,status,Quote_Number_PQM__c,PO_Number__c from Quote where Id = :recordId and PO_Number__c!=null]; 
       
        if(listQuoteRecords.size()>0){
            List<String> ListPONumn=new List<String>();
            ListPONumn.add(listQuoteRecords[0].PO_Number__c);
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+ebsMetaData[0].Token__c );
            request.setEndpoint(ebsMetaData[0].Endpoint__c);
            String req =   JSON.serialize(ListPONumn); //'["230MY0220", "230P58332A", "230L31580", "230F58387", "23058387A"]'; 
            request.setBody(req);
            HttpResponse res=new Http().send(request);
            String response = res.getbody();
            return response;
        }
       
        return '';
    }
}