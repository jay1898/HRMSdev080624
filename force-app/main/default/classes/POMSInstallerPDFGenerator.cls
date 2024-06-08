/**
 * @description       : POMSInstallerPDFGenerator tovgenerate POMS Installer PDF
 * @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
 * @group             : eVerge
 * History 	
 * Ver   Date         Author        Modification
 * 1.0   08-03-2022    Dhruv Javiya  Initial Version()
**/
public without sharing class POMSInstallerPDFGenerator {
     /**
    *   @Method:        PDFGenerator
    *   @Purpose:       Generate PDF 
    *   @Author:        Dhruv (eVerge)
    *   @Date:          03/08/2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    @future(callout=true)
    public static void PDFGenerator(List<String> woliIds,String networkId){
        
        String pdfContent = ''; String fileName='Installer Payout ';
        Map<String,ContentVersion> mapCVList=new Map<String,ContentVersion>();
        Map<String,String> WOLIWiseWOMap=new Map<String,String>();
        try{
            List<WorkOrderLineItem> listWOLI=[SELECT ID,WO_Quote_Number__c,Sales_Rep__c,Project_Coordinator__c,PC_Comments__c,Display_Name__c,WorkOrder.WorkOrderNumber,Quote__c,Primary_Installer__r.Name,Quote__r.PO_Number__c,Quote__r.Quote_Number_PQM__c,Quote_PO_Number__c,PQM_Quote_Number__c,WorkOrderId,Customer__c,Sub_Contracted_Installation_Company__c,Install_At__c,Phone__c,Order_Number__c,
                                              Email__c,Installation_Date_Time__c,Branch_Name__c,Address,Install_Duration_Minutes__c,Installer_Comments__c
                                              FROM WorkOrderLineItem 
                                              Where id = :woliIds];
            Map<String,List<Installer_Payout_Amount__c>> WOLIWiseQuote=new Map<String,List<Installer_Payout_Amount__c>>();
            pdfContent='';
            for(Installer_Payout_Amount__c qli :[SELECT id, PQM_Line__c,Description__c,Quantity__c, Payout_Amount__c,Work_Order_Line_Item__c
                                          FROM Installer_Payout_Amount__c Where 
                                          Work_Order_Line_Item__c= : woliIds ]){
                                              if(!WOLIWiseQuote.containsKey(qli.Work_Order_Line_Item__c)){
                                                  WOLIWiseQuote.put(qli.Work_Order_Line_Item__c,new List<Installer_Payout_Amount__c>());
                                              }
                                              WOLIWiseQuote.get(qli.Work_Order_Line_Item__c).add(qli);
                                          }
            // generate Content version to related woli
            for(WorkOrderLineItem WOLIItem: listWOLI){
                WOLIWiseWOMap.put(WOLIItem.Id,WOLIItem.WorkOrderId);
                PageReference reportPage = Page.POMSPDFGenerator;
                reportPage.getParameters().put('id', WOLIItem.Id);
                Blob content ;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                }else{
                    content = reportPage.getContentAsPDF(); 
                }
               
                fileName='Installer Payout - '+WOLIItem.Primary_Installer__r.Name+'-'+WOLIItem.Quote__r.PO_Number__c+'-'+DateTime.now();
                ContentVersion conVer =  new ContentVersion();
                conVer.Title = fileName ;
                conVer.PathOnClient =fileName+'.'+'pdf';
                conVer.VersionData =  content;
                conVer.Origin = 'H';
                conVer.NetworkId=networkId;
                mapCVList.put(WOLIItem.Id,conVer);
            }
            
            insert mapCVList.values();
            Map<string,string> listCVWiseWOLIIds=new  Map<string,string>();
            for(String WOLIId :mapCVList.keySet() ){
                listCVWiseWOLIIds.put(mapCVList.get(WOLIId).Id,WOLIId);
            }
            //generate COntent Document link to related CV 
            Map<String,ContentVersion> ContentWiseDocId=new Map<String,ContentVersion>();
            List<ContentVersion> conDocList = [SELECT  Id,ContentDocumentId FROM ContentVersion WHERE Id =:listCVWiseWOLIIds.keySet()]; 
            List<ContentDocumentLink> listCDL=new List<ContentDocumentLink>();    
            for(ContentVersion CV: conDocList){
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = CV.ContentDocumentId;
                cDe.LinkedEntityId = listCVWiseWOLIIds.get(CV.Id);//WOLIWiseWOMap.get(listCVWiseWOLIIds.get(CV.Id)) ;
                cDe.ShareType = 'I';
                cDe.Visibility = 'AllUsers';	
                listCDL.add(cDe);
            }
            
            insert listCDL ;
        }
        catch(exception e){
           throw e;
        }
    }
}