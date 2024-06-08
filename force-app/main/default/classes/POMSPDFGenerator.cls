public without sharing class POMSPDFGenerator {
    
   public static void PDFGenerator(String woliId){
        
        String pdfContent = ''; String poNumber = ''; String woid = ''; String wliid = '';
       
        try{
            system.debug('Line 23');
            List<WorkOrderLineItem> listWOLI=[SELECT ID,Quote__c,PQM_Quote_Number__c,Order_Number__c,WorkOrderId FROM WorkOrderLineItem Where id = :woliId];
            poNumber = listWOLI[0].Order_Number__c;
            String pqmNumber = listWOLI[0].PQM_Quote_Number__c;
            woid = listWOLI[0].WorkOrderId ;
            wliid = listWOLI[0].Id;
            map<String, QuoteLineItem> mapoli = new map<String, QuoteLineItem>();
            
            pdfContent = '<table border="1" style="border-collapse: collapse">';
            pdfContent = pdfContent+'<tr><th  colspan="7" bgcolor="#000" color="#fff">Line Item Records</th></tr>';
            pdfContent = pdfContent+'<tr><th colspan="4">PO Number: '+poNumber+' </th><th colspan="3" Style="text-align:right;">PQM Quote Number: '+pqmNumber+'</th></tr>';
            pdfContent = pdfContent+'<tr><th colspan="7">Product Details : </th></tr>';
            pdfContent = pdfContent+'<tr bgcolor="#888888" color="#282828"><th>Quote Line</th><th>Description</th><th>PO Line</th><th>Qty</th><th>Status</th><th>Receipt Date</th><th>Delivery Date</th></tr>';
            
            
            for(QuoteLineItem qli :[SELECT id, Qte_Line__c,Description,Status__c, PO_Line__c, 
                                                Quantity,Receipt_Date__c, Delivery_Date__c
                                                FROM QuoteLineItem Where 
                                                Work_Order_Line_Item__c= : listWOLI[0].Id AND QLI_Type__c = 'LineItem'
                                                order by Qte_Line__c,PO_Line__c]){
                                                    system.debug('Line 23');
                                                    String ql = qli.Qte_Line__c;
                                                    String descrip = qli.Description;
                                                    Decimal poline = qli.PO_Line__c;
                                                    Decimal Qty = qli.Quantity;
                                                    String sStatus = qli.Status__c;
                                                    Date RCdate = qli.Receipt_Date__c;
                                                    Date DeliveryDate = qli.Delivery_Date__c;
                                                    pdfContent +=  '<tr color="Gray" size="13px"><td>' + ql + '</td><td>' + descrip + '</td><td>' + poline + '</td><td>' + Qty + '</td><td>' + sStatus + '</td><td>' + RCdate + '</td><td>' + DeliveryDate + '</td></tr>';
            
            }
            pdfContent += '</table>';
            system.debug('Line 23');
        }
        catch(exception e){
            system.debug( e.getMessage() );
        }
        attachPDF(woId,pdfContent,poNumber, wliid);
    }
    public static void attachPDF(String woId, String pdfContent, String poNumber, String woliid){
        system.debug('Line 23');
        try{
            system.debug('Line 23');
            List<WorkOrderLineItem> updateWO = new List<WorkOrderLineItem>();
            String filename = 'POMS Order File'+'_'+ poNumber ;
            List<ContentDocument> listcd = [SELECT Id from ContentDocument where Title =:filename];
            if(listcd.size() > 0){
                DELETE listcd ;
            }
            
            
            ContentVersion conVer =  new ContentVersion();
            conVer.Title = 'POMS Order File'+'_'+ poNumber ;
            conVer.PathOnClient ='POMS Order File'+'_'+ poNumber +'.'+'pdf';
            conVer.VersionData =  Blob.toPDF(pdfContent);
            conVer.Origin = 'H';
            insert conVer;
            
            Id conDoc = [SELECT  ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId; 
            
            ContentDocumentLink cDe = new ContentDocumentLink();
			cDe.ContentDocumentId = conDoc;
         	cDe.LinkedEntityId = woId ;
            cDe.ShareType = 'I';
         	cDe.Visibility = 'AllUsers';	
     		
         	insert cDe ;
            
            List<WorkOrderLineItem> listWOLI = [SELECT Id, Generate_POMS_File__c FROM WorkOrderLineItem where Id =: woliid];
            for(WorkOrderLineItem w :listWOLI){
                w.Generate_POMS_File__c = FALSE;
                updateWO.add(w);
            }
            if(updateWO.size()> 0){
                UPDATE updateWO ;
            }
			
         }
        catch(exception e){
            system.debug('error occured'+e);
        }
    }
}