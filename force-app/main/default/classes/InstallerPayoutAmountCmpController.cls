/**
* @description       : InstallerPayoutAmountCmpController create Installer Payout records
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   08-03-2022    Dhruv Javiya  Initial Version()
**/
public with sharing class InstallerPayoutAmountCmpController {
    /**
    *   @Method:        fetchExistingInstallerPayoutData
    *   @Purpose:       fetch related Installer payout records
    *   @Author:        Dhruv (eVerge)
    *   @Date:          03/08/2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    @AuraEnabled
    public static List<Installer_Payout_Amount__c> fetchExistingInstallerPayoutData(String workOrderItemId) {
        Map<String, String> mapOFQuoteIdwithProductCode = new Map<String, String>();
        Map<String, Installer_Payout__c> mapOFPartNumberwithTierAmount = new Map<String, Installer_Payout__c>();
        // check if related quote status is Ordered and other condition and throws error
        List<WorkOrderLineItem> WOLRecs = [Select Id,Lock_Payout_Transaction__c,WorkOrder.Market_Segment__c, WorkOrder.Quote__r.Status,WorkType.Schedule_Type__c,WorkOrder.Branch__r.Automated_Installer_Payout__c From WorkOrderLineItem Where  Id =:workOrderItemId];
        /*if(WOLRecs.size()>0  && WOLRecs[0].WorkOrder.Quote__r.Status != 'Ordered' )
            throw new AuraHandledException(system.Label.If_Quote_Status_Not_Ordered);
        */
        /*if(WOLRecs.size()>0 && WOLRecs[0].WorkOrder.Branch__r.Automated_Installer_Payout__c==false){
            throw new AuraHandledException(system.Label.If_Branch_Automated_Installer_Payout);
        }
        if(WOLRecs.size()>0 && WOLRecs[0].WorkOrder.Market_Segment__c=='Retail'){
            throw new AuraHandledException(system.Label.WO_Market_Segment);
        }*/
        if(WOLRecs.size()>0 && WOLRecs[0].Lock_Payout_Transaction__c==true){
            throw new AuraHandledException(system.Label.WOLI_Lock_Payment);
        }
        
        List<WorkOrderLineItem> WOLInstaller3PartyRec = [Select Id, Primary_Installer__r.Installer_Third_Party__c From WorkOrderLineItem Where Id =:workOrderItemId and Primary_Installer__r.Installer_Third_Party__c != true];
        if(!WOLInstaller3PartyRec.isEmpty())
            throw new AuraHandledException(system.Label.If_not_Primary_Installer_Third_Party);
        
        List<QuoteLineItem> quoteLineItemRecs = [SELECT Id, LineNumber,Qte_line__c, Psi_Resource_Labor__c, QuoteId, Quantity, Description, PO_Line__c, QLI_Type__c,Unit_Type__c, Customer_price__c, Product_Code__c 
                                                 FROM QuoteLineItem
                                                 WHERE Work_Order_Line_Item__c =: workOrderItemId and QLI_Type__c = 'LineItem' and Psi_Resource_Labor__c = true];
        if(quoteLineItemRecs.isEmpty()){
             throw new AuraHandledException(system.Label.Installer_Payout_NO_WOLI);
        }
           
        List<Installer_Payout_Amount__c> createdIPARecordsList = new List<Installer_Payout_Amount__c>();
        // fetch Installer Payout Amount Records.
        List<Installer_Payout_Amount__c> installerPayoutAmountRecs = [SELECT Id, Name, PQM_Line__c, Description__c, Quantity__c, Payout_Amount__c, Source__c
                                                                      FROM Installer_Payout_Amount__c
                                                                      WHERE Work_Order_Line_Item__c =: workOrderItemId];
        if(!installerPayoutAmountRecs.isEmpty()){
            throw new AuraHandledException(system.Label.If_Exist_Payout_Records);
        }
        return fetchInstallerPayoutDataRecords(workOrderItemId);
    }
    /**
    *   @Method:        fetchInstallerPayoutData
    *   @Purpose:       fetch related payout details
    *   @Author:        Dhruv (eVerge)
    *   @Date:          03/08/2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    @AuraEnabled
    public static List<Installer_Payout_Amount__c> fetchInstallerPayoutData(String workOrderItemId) {
        return fetchInstallerPayoutDataRecords(workOrderItemId);
    }
    
    public static List<Installer_Payout_Amount__c> fetchInstallerPayoutDataRecords(String workOrderItemId) {
        Map<String, String> mapOFQuoteIdwithProductCode = new Map<String, String>();
        Map<String, Installer_Payout__c> mapOFPartNumberwithTierAmount = new Map<String, Installer_Payout__c>();
        
        List<Installer_Payout_Amount__c> createdIPARecordsList = new List<Installer_Payout_Amount__c>();
        // fetch Installer Payout Amount Records.
        List<Installer_Payout_Amount__c> installerPayoutAmountRecs = [SELECT Id, Name, PQM_Line__c, Description__c, Quantity__c, Payout_Amount__c, Source__c
                                                                      FROM Installer_Payout_Amount__c
                                                                      WHERE Work_Order_Line_Item__c =: workOrderItemId];
        
        if(!installerPayoutAmountRecs.isEmpty()){// delete payout if exist
            delete installerPayoutAmountRecs;
        }
        // create Installer Payout Amount Records If not Exist.
        //if(installerPayoutAmountRecs.isEmpty()){
        WorkOrderLineItem workOrderLineItemRec = [SELECT Id, WorkOrder.Quote__c,WorkOrder.ownerId,Primary_Installer__c,Primary_Installer__r.Tier__c  
                                                  FROM WorkOrderLineItem
                                                  WHERE Id =: workOrderItemId  and WorkType.Schedule_Type__c='Install' limit 1];
        Map<String,String> userWiseTier=new Map<String,String>();
        // iterate over service resource
        for(ServiceResource SR : [SELECT Id,RelatedRecordId,Tier__c FROM ServiceResource where Id = :workOrderLineItemRec.Primary_Installer__c]){
            userWiseTier.put(SR.Id, SR.Tier__c);
        }
        List<QuoteLineItem> quoteLineItemRecs = [SELECT Id, LineNumber,Qte_line__c, Psi_Resource_Labor__c, QuoteId, Quantity, Description, PO_Line__c, QLI_Type__c,Unit_Type__c, Customer_price__c, Product_Code__c 
                                                 FROM QuoteLineItem
                                                 WHERE Work_Order_Line_Item__c =: workOrderItemId and QLI_Type__c = 'LineItem' and Psi_Resource_Labor__c = true];
        if(!quoteLineItemRecs.isEmpty()){
            for(QuoteLineItem quoteLine :quoteLineItemRecs){
                if(string.isNotBlank(quoteLine.Product_Code__c))
                    mapOFQuoteIdwithProductCode.put(quoteLine.Id,quoteLine.Product_Code__c);
            }
            List<Installer_Payout__c> installerPayoutRecs = [SELECT Id, Name, Part_Number__c, Description__c, Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c
                                                             FROM Installer_Payout__c WHERE Part_Number__c IN :mapOFQuoteIdwithProductCode.values()];
            if(!installerPayoutRecs.isEmpty()){
                for(Installer_Payout__c installerPayout :installerPayoutRecs){
                    mapOFPartNumberwithTierAmount.put(installerPayout.Part_Number__c,installerPayout);
                }
            }
            // create installer payout based on Quote Line Item
            for(QuoteLineItem quoteLine :quoteLineItemRecs){
                Installer_Payout_Amount__c ipa = new Installer_Payout_Amount__c();
                ipa.Work_Order_Line_Item__c = workOrderItemId;
                ipa.PQM_Line__c = quoteLine.Qte_line__c;
                ipa.Description__c = quoteLine.Description;
                ipa.Quantity__c = quoteLine.Quantity;
                if(mapOFQuoteIdwithProductCode.containsKey(quoteLine.Id)){
                    if(mapOFPartNumberwithTierAmount.containsKey(mapOFQuoteIdwithProductCode.get(quoteLine.Id))){
                        String Tier=userWiseTier.get(workOrderLineItemRec.Primary_Installer__c);
                        
                        if(Tier!=null){
                            if(Tier=='1') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier1__c * ipa.Quantity__c;
                            if(Tier=='2') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier2__c * ipa.Quantity__c;
                            if(Tier=='3') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier3__c * ipa.Quantity__c;
                            if(Tier=='4') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier4__c * ipa.Quantity__c;
                            if(Tier=='5') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier5__c * ipa.Quantity__c;
                            if(Tier=='6') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier6__c * ipa.Quantity__c;
                            ipa.Source__c = 'Salesforce';
                            
                        } else{
                            ipa.Payout_Amount__c = quoteLine.Customer_price__c * ipa.Quantity__c;
                            ipa.Source__c = 'PQM';
                        }
                    }
                    else{
                        ipa.Payout_Amount__c = quoteLine.Customer_price__c * ipa.Quantity__c;
                        ipa.Source__c = 'PQM';
                    }
                }else{
                    ipa.Payout_Amount__c = quoteLine.Customer_price__c * ipa.Quantity__c;
                    ipa.Source__c = 'PQM';
                }
                createdIPARecordsList.add(ipa);
                
            }
            
            if(!createdIPARecordsList.isEmpty()){
                insert createdIPARecordsList;
            }
        }
        
        //}
        return  [SELECT Id, Name, PQM_Line__c, Description__c, Quantity__c, Payout_Amount__c, Source__c
                 FROM Installer_Payout_Amount__c
                 WHERE Id =: createdIPARecordsList];
    }
}