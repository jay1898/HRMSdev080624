/**
 * @description       : POMSIntegrationDataLoadCtrl to make api call for quote line item 
 * @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
 * @group             : eVerge
 * History 	
 * Ver   Date         Author        Modification
 * 1.0   08-03-2022    Dhruv Javiya  Initial Version() 
**/
global class POMSIntegrationDataLoadCtrl {
        /**
    *   @Method:        getOrderDetails
    *   @Purpose:       fetch related Order details
    *   @Author:        Dhruv (eVerge)
    *   @Date:          03/08/2022
    *   @TaskSource:    
    
    *   @Updates:        
    */ 
    @AuraEnabled
    global static string getOrderDetails(String recordId){
        //String PONumn ='230MY0206';// '042MKR302A';//230MY0220';//'230MY0220'; 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_POMS_Integration__c) ) return '';
        List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'POMS_EndPoint' ];   
        WorkOrder woRecord = [select id,Quote__c,last_Sync_Date__c from WorkOrder where id = : recordId];
        if(!(woRecord.last_Sync_Date__c==null || woRecord.last_Sync_Date__c.addMinutes(Integer.valueOf(system.label.Work_Order_Sync_Interval_in_Minutes))< DateTime.now())){
            return '';
        }
        ID standardPricrbookId;
        if(Test.isRunningTest()){
            standardPricrbookId = Test.getStandardPricebookId();//[SELECT Id, IsStandard, IsArchived, IsActive, Name FROM Pricebook2][0].Id;
        }
        else{
            standardPricrbookId = [SELECT Id, IsStandard, IsArchived, IsActive, Name FROM Pricebook2 WHERE IsStandard=TRUE LIMIT 1 ][0].Id;
        }
        List<String> ListPONumn=new List<String>();
        List<quote> listQuoteRecords = [select id,QuoteNumber,status,Quote_Number_PQM__c,PO_Number__c from quote where Work_Order__c = :woRecord.Id ]; 
        Map<String,Quote> PONumberWiseMap=new Map<String,Quote>();
        Map<String, Product2> mapQuoteProduct = new Map<String, Product2>();
        Map<String, PricebookEntry> mapProductPriceBook = new Map<String, PricebookEntry>();
        for(Quote quoteRecord:listQuoteRecords){
           if(quoteRecord.status!='Active' && quoteRecord.status!='Contracted' && quoteRecord.PO_Number__c!=null){
               ListPONumn.add(quoteRecord.PO_Number__c);
               PONumberWiseMap.put(quoteRecord.PO_Number__c,quoteRecord);
               if(!mapQuoteProduct.containsKey(quoteRecord.Quote_Number_PQM__c)){
                   mapQuoteProduct.put(quoteRecord.Quote_Number_PQM__c,new Product2(name='Quote#' + quoteRecord.Quote_Number_PQM__c + 'Products',IsActive = true,Quote_Number_PQM__c=quoteRecord.Quote_Number_PQM__c));
               }
               
               if(!mapProductPriceBook.containsKey(quoteRecord.Quote_Number_PQM__c)){
                   mapProductPriceBook.put(quoteRecord.Quote_Number_PQM__c,new PricebookEntry(Pricebook2Id = standardPricrbookId,UnitPrice=1,IsActive=true,Product2 = mapQuoteProduct.get(quoteRecord.Quote_Number_PQM__c),Quote_Number_PQM__c=quoteRecord.Quote_Number_PQM__c));
               }
           } 
        }
        //String  PONumn=quoteRecord.PO_Number__c;
        if(ListPONumn.size()>0){
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+ebsMetaData[0].Token__c );
            request.setEndpoint(ebsMetaData[0].Endpoint__c);
            String req =   JSON.serialize(ListPONumn); //'["230MY0220", "230P58332A", "230L31580", "230F58387", "23058387A"]'; 
            request.setBody(req);
            HttpResponse res=new Http().send(request);
            system.debug('@@res.getbody()'+res.getbody());
            String response = res.getbody();
            // Information Log
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'POMSIntegrationDataLoadCtrl',
                    'getOrderDetails',
                    'URL : '+ebsMetaData[0].Endpoint__c+',\n'
                    +'Method : POST,\n'
                    + 'Req Body : '+req,
                    'getOrderDetails Request',
                    'Integration'
                )
            );
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'POMSIntegrationDataLoadCtrl',
                    'getOrderDetails',
                    'URL : '+ebsMetaData[0].Endpoint__c+',\n'
                    +'Response Body : ' + res.getBody(),
                    'The status code : ' + res.getStatusCode() + ' ' + res.getStatus(),
                    'Integration'
                )
            );
            
            if (res.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             res.getStatusCode() + ' ' + res.getStatus());
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'POMSIntegrationDataLoadCtrl',
                        'getOrderDetails',
                        'URL : '+ebsMetaData[0].Endpoint__c+',\n'
                        +'Method : POST,\n'
                        + 'Req Body : '+req,
                        'The status code returned was not expected: ' + res.getStatusCode() + ': ' + res.getStatus() + ': ' + res.getBody(),
                        null,
                        'Integration'
                    )
                );
                return '';
            }
            woRecord.last_Sync_Date__c=DateTime.now();
            update woRecord;
            
            List<QuoteLineItem> listQLI=new List<QuoteLineItem>();  
           
            List<wrapper> serializeResponse = (list<wrapper>)JSON.deserialize(response,List<wrapper>.class);
            
            system.debug('mapQuoteProduct'+mapQuoteProduct);
            system.debug('mapProductPriceBook'+mapProductPriceBook);
            
            List<String> listExistingExternaIds=new List<String>();
            for(QuoteLineItem QLI : [SELECT ID,ExternalId__c From QuoteLineItem where Quote.Work_Order__c = :woRecord.Id ]){
                listExistingExternaIds.add(QLI.ExternalId__c);
            }
            List<String> listQLIExternalId=New List<String>();
            for(wrapper data : serializeResponse){
                system.debug('@@PONumberWiseMap:::::::'+PONumberWiseMap);
                system.debug('@@OrderNumber:::::::'+data.OrderNumber);
                system.debug('@@LineNumber:::::::'+data.LineNumber);
                system.debug('@@PoLineNumber:::::::'+data.PoLineNumber);
                Quote quoteRecord=PONumberWiseMap.get(data.OrderNumber);
                system.debug('@@Quote_Number_PQM__c:::::::'+quoteRecord.Quote_Number_PQM__c);
                QuoteLineItem QLI=new QuoteLineItem();
                QLI.ExternalId__c =quoteRecord.Quote_Number_PQM__c+'-'+data.LineNumber + '-'+data.PoLineNumber;
                //QLI.Description = data.Description;
                
                if(!String.isBlank(data.LineNumber)){
                    QLI.Qte_Line__c = data.LineNumber;
                }
                if(!String.isBlank(data.PoLineNumber)){
                    QLI.PO_Line__c = Integer.valueOf(data.PoLineNumber);
                }
                if(QLI.PO_Line__c==null || QLI.PO_Line__c==0 || QLI.PO_Line__c==-1){
                    if(QLI.Description!=null && QLI.Description.indexOf('-')>0){
                        QLI.ExternalId__c=quoteRecord.Quote_Number_PQM__c +'-'+QLI.Qte_Line__c +'-'+QLI.Description.substring(0,QLI.Description.indexOf('-')-1);
                        listQLIExternalId.add(QLI.ExternalId__c);
                    }else{
                        QLI.ExternalId__c=quoteRecord.Quote_Number_PQM__c +'-'+QLI.Qte_Line__c +'-'+QLI.Description;
                        listQLIExternalId.add(QLI.ExternalId__c);
                    }
                }
                QLI.QuoteId = quoteRecord.Id;
                QLI.Product2= mapQuoteProduct.get(quoteRecord.Quote_Number_PQM__c);
                QLI.PricebookEntry = mapProductPriceBook.get(quoteRecord.Quote_Number_PQM__c);
                if(!listExistingExternaIds.contains(QLI.ExternalId__c)){
                    QLI.Customer_price__c=0;
                    QLI.UnitPrice = 0;
                    QLI.Description = data.Description;

                }
               
                QLI.QLI_Type__c = 'LineItem';
                if(String.isBlank(data.QuoteQuantity)){
                    QLI.Quantity = 1;  
                }else{
                    QLI.Quantity = Decimal.valueOf(data.QuoteQuantity);
                }
                QLI.LIA_STATUS_RECEIVED__c = data.ReceivedStatus;
                if(formatDate(data.ReceiptDate)!=null)
                    QLI.Receipt_Date__c = formatDate(data.ReceiptDate);
                if(formatDate(data.DeliveryDate)!=null)
                    QLI.Delivery_Date__c = formatDate(data.DeliveryDate); 
                
                if(listQLIExternalId.contains(QLI.ExternalId__c)){
                    if(listExistingExternaIds.contains(QLI.ExternalId__c)){
                         listQLI.add(QLI);
                    }
                }else{
                    listQLI.add(QLI);
                }
                
            }
            upsert mapQuoteProduct.values() Quote_Number_PQM__c;
            for(String quoteNumber :mapProductPriceBook.keySet()){
                mapProductPriceBook.get(quoteNumber).Product2Id=mapQuoteProduct.get(quoteNumber).Id;
            }
            upsert mapProductPriceBook.values() Quote_Number_PQM__c;	
            for(QuoteLineItem QL :listQLI){
                
                QL.Product2Id=QL.Product2.Id;
                QL.PricebookEntryID= QL.PricebookEntry.Id;
            }    
            List<Database.upsertResult> results= database.upsert(listQLI,QuoteLineItem.ExternalId__c , false);
            system.debug('srList::'+results);
            return response ;
        }
        else{
            return '';
        }
        
    }
    
    public static Date formatDate(String dateValue){
        if(string.isBlank(dateValue))return null;
        List<String> DateValues=dateValue.split('-');
        system.debug('datevalues'+DateValues);
        String year = '20'+DateValues[2];
        return Date.newInstance(Integer.valueOf(year), getNumericMonth(DateValues[1]), Integer.valueOf(DateValues[0]));
    }
    public Static Integer getNumericMonth(String Month){
        switch on Month {
            when 'JAN' {
                return 01;
            }
            when 'FEB' {
                return 02;
            }
            when 'MAR' {
                return 03;
            }
            when 'APR' {
                return 04;
            }
            when 'MAY' {
                return 05;
            }
            when 'JUN' {
                return 06;
            }
            when 'JUL' {
                return 07;
            }when 'AUG' {	
                return 08;
            }when 'SEP' {
                return 09;
            }when 'OCT' {
                return 10;
            }when 'NOV' {
                return 11;
            }when 'DEC' {
                return 12;
            }
        }
        return 1;
    }
    
    public class wrapper{
        public String OrderNumber;
        public String LineNumber;
        public String PoLineNumber;
        public String Description;
        public String QuoteQuantity;
        public String ReceiptDate;
        public String DeliveryDate;
        public String ReceivedStatus;
    }
    
}