global class POMSLineItemController {
    
    @AuraEnabled
    global static Map<String,String> getQuoteDetails(String recordId){
        //return [SELECT Id,Name ,PO_Number__c FROM Quote Where Work_Order__c= : recordId ];
        Map<String,String> dataMap=new  Map<String,String>();
        dataMap.put('Quotes',JSON.serialize([SELECT Id,Name ,PO_Number__c,Work_Order__r.Quote__c,Recovery__c,Work_Order__r.Branch__r.Automated_Installer_Payout__c  FROM Quote Where Work_Order__c= : recordId ]));
        dataMap.put('WorkOrderLines',JSON.serialize([SELECT Id,Quote__c,Subject,Display_Name__c,Lock_Payout_Transaction__c,WorkType.Schedule_Type__c,WorkOrder.Branch__r.Automated_Installer_Payout__c FROM WorkOrderLineItem Where WorkorderId= : recordId  ]));
        return dataMap;
    }
    
    @AuraEnabled
    global static List<QuoteLineItem> getLineItemDetails(String recordId){
        List<WorkOrder> listWorkOrder=[SELECT ID,Quote__c FROM WorkOrder Where id=:recordId];
        if(listWorkOrder.size()>0){
            return [SELECT id,Qte_Line__c, Description,Status__c,Work_Order_Line_Item__c,Psi_Resource_Labor__c, PO_Line__c, Quantity,Receipt_Date__c, Delivery_Date__c FROM QuoteLineItem Where QuoteId= : listWorkOrder[0].Quote__c and QLI_Type__c='LineItem' order by Qte_Line__c,PO_Line__c ];
        }
        return null;
    }
    @AuraEnabled
    global static Map<String,String> getQuoteLineItemDetailsWithWOLI(String recordId){
        Map<String,String> dataMap=new  Map<String,String>();
        //dataMap.put('QuoteLines', null);
        //dataMap.put('WorkOrderLines', null);
        //List<WorkOrder> listWorkOrder=[SELECT ID,Quote__c FROM WorkOrder Where id=:recordId];
        //if(listWorkOrder.size()>0){
            dataMap.put('QuoteLines',JSON.serialize([SELECT id,Qte_Line__c,Work_Order_Line_Item__c,Quote.Work_Order__r.Branch__r.Automated_Installer_Payout__c,Psi_Resource_Labor__c, Description,Status__c, PO_Line__c, Quantity,Receipt_Date__c, Delivery_Date__c FROM QuoteLineItem Where QuoteId= : recordId and QLI_Type__c='LineItem' order by Qte_Line__c,Sort_Number__c,PO_Line__c ]));
           // dataMap.put('WorkOrderLines',JSON.serialize([SELECT Id,Subject,Display_Name__c,Lock_Payout_Transaction__c FROM WorkOrderLineItem Where WorkorderId= : recordId and WorkType.Schedule_Type__c='Install' ]));
       // }
        return dataMap;
    }
    @AuraEnabled
    global static void updateQuoteLineItemDetailsWithWOLI(String QuoteWOLIMap,String QuoteId,String WOLIId,String removeQuoteRefWOLIID){
        
        if(removeQuoteRefWOLIID!=null && removeQuoteRefWOLIID!=''){
            WorkOrderLineItem WOLI=new WorkOrderLineItem();
            WOLI.Id=removeQuoteRefWOLIID;
            WOLI.Quote__c=null;
            Update WOLI;
            
            WOLI=new WorkOrderLineItem();
            WOLI.Id=WOLIId;
            WOLI.Quote__c=null;
            Update WOLI;
            
            List<QuoteLineItem> listQLI=[SELECT ID,Work_Order_Line_Item__c From QuoteLineItem where Work_Order_Line_Item__c=:removeQuoteRefWOLIID or Work_Order_Line_Item__c=:WOLIId ];
            for(QuoteLineItem QLI : listQLI){
                QLI.Work_Order_Line_Item__c=null;
            }
            update listQLI;
        }
        
        List<QuoteLineItem> QuoteLineListToUpdate=new List<QuoteLineItem>();
        Map<String,Object> QuoteWOLI=(Map<String,Object>)JSON.deserializeUntyped(QuoteWOLIMap);
        Set<String> setWoliIds=new Set<String>();
        for(String QLIId : QuoteWOLI.keySet()) {
            setWoliIds.add(String.valueOf(QuoteWOLI.get(QLIId)));
        }
        set<String> setWOLIToUpdate=new Set<String>();
        Map<String,String> woliWiseHistoryUpdate=new Map<String,String>();
        
        Map<Id,String> mapWOLIWiseNumber=new Map<Id,String>();
        for(WorkOrderLineItem WOLI : [SELECT ID,LineItemNumber FROM WorkOrderLineItem where Id = :setWoliIds]){
            mapWOLIWiseNumber.put(WOLI.Id,WOLI.LineItemNumber);
        }
        Map<String,QuoteLineItem> QuoteLineMap=new Map<String,QuoteLineItem>();
        for(QuoteLineItem QL : [SELECT Id,Work_Order_Line_Item__c,Work_Order_Line_Item__r.LineItemNumber,PO_Line__c ,Qte_Line__c FROM QuoteLineItem where Id= :QuoteWOLI.keySet()]){
            if(QL.Work_Order_Line_Item__c!=null ){
                setWOLIToUpdate.add(QL.Work_Order_Line_Item__c);
                if(!mapWOLIWiseNumber.containsKey(QL.Work_Order_Line_Item__c)){
                    mapWOLIWiseNumber.put(QL.Work_Order_Line_Item__c,QL.Work_Order_Line_Item__r.LineItemNumber);
                }
                if(!woliWiseHistoryUpdate.containsKey(QL.Work_Order_Line_Item__c)){
                    woliWiseHistoryUpdate.put(QL.Work_Order_Line_Item__c,'');
                }
                if(QuoteWOLI.containsKey(QL.Id) && QuoteWOLI.get(QL.Id)!=''){
                    woliWiseHistoryUpdate.put(QL.Work_Order_Line_Item__c,woliWiseHistoryUpdate.get(QL.Work_Order_Line_Item__c) + ' Line Item#'+QL.Qte_Line__c+'('+QL.PO_Line__c +')'+' moved from WOLI#'+mapWOLIWiseNumber.get(QL.Work_Order_Line_Item__c)+' to WOLI#'+mapWOLIWiseNumber.get(String.valueOf(QuoteWOLI.get(QL.Id))) + ',');
                }else{
                    woliWiseHistoryUpdate.put(QL.Work_Order_Line_Item__c,woliWiseHistoryUpdate.get(QL.Work_Order_Line_Item__c) + ' Line Item#'+QL.Qte_Line__c+'('+QL.PO_Line__c +')'+' removed from WOLI#'+mapWOLIWiseNumber.get(QL.Work_Order_Line_Item__c)+',');
                }
            }
            QuoteLineMap.put(QL.Id,QL);
        }
        for(String quotelineId :QuoteWOLI.keySet()){
            QuoteLineItem QuoteLine=new QuoteLineItem();
            QuoteLine.Id=quotelineId;
            QuoteLine.Work_Order_Line_Item__c=String.valueOf(QuoteWOLI.get(quotelineId))==''?null:String.valueOf(QuoteWOLI.get(quotelineId));
            if(QuoteLine.Work_Order_Line_Item__c!=null ){
                setWOLIToUpdate.add(QuoteLine.Work_Order_Line_Item__c);
                
                QuoteLineItem QL=QuoteLineMap.get(quotelineId);
                if(!woliWiseHistoryUpdate.containsKey(QuoteLine.Work_Order_Line_Item__c)){ 
                    woliWiseHistoryUpdate.put(QuoteLine.Work_Order_Line_Item__c,'');
                }
                if(QL.Work_Order_Line_Item__c!=null){
                    woliWiseHistoryUpdate.put(QuoteLine.Work_Order_Line_Item__c,woliWiseHistoryUpdate.get(QuoteLine.Work_Order_Line_Item__c) + ' Line Item#'+QL.Qte_Line__c+'('+QL.PO_Line__c +')'+' moved from WOLI#'+mapWOLIWiseNumber.get(QL.Work_Order_Line_Item__c)+' to WOLI#'+mapWOLIWiseNumber.get(QuoteLine.Work_Order_Line_Item__c) + ',');
                }else{
                    woliWiseHistoryUpdate.put(QuoteLine.Work_Order_Line_Item__c,woliWiseHistoryUpdate.get(QuoteLine.Work_Order_Line_Item__c) + ' Line Item#'+QL.Qte_Line__c+'('+QL.PO_Line__c +')'+' added to WOLI#'+mapWOLIWiseNumber.get(QuoteLine.Work_Order_Line_Item__c) + ',');
                    
                }
                 
            }
            QuoteLineListToUpdate.add(QuoteLine);
        }
       
        update QuoteLineListToUpdate;
        List<WorkOrderLineItem> listWOLIToUpdate=new List<WorkOrderLineItem>();
        for(String WOLIIds : setWOLIToUpdate){
            if(WOLIId!=null && WOLIId!='' && WOLIId==WOLIIds){
                
            }else{
                WorkOrderLineItem WOLI=new WorkOrderLineItem();
                WOLI.Id=WOLIIds;
                WOLI.Quote__c=QuoteId;
                listWOLIToUpdate.add(WOLI);
            }
        }
        if(listWOLIToUpdate.size()>0)update listWOLIToUpdate;
        
        if(WOLIId!=null && WOLIId!=''){
            WorkOrderLineItem WOLI=new WorkOrderLineItem();
            WOLI.Id=WOLIId;
            WOLI.Quote__c=QuoteId;
            Update WOLI;
        }
        
        List<WorkOrderLineItem> listWoliHistoryToUpdate=new List<WorkOrderLineItem>();
        for(WorkOrderLineItem WL :[SELECT Id,QLI_migration__c FROM WorkOrderLineItem Where id = :woliWiseHistoryUpdate.keySet()]){
            WL.QLI_migration__c=WL.QLI_migration__c==null?woliWiseHistoryUpdate.get(WL.Id):WL.QLI_migration__c+woliWiseHistoryUpdate.get(WL.Id);
            listWoliHistoryToUpdate.add(WL);
        }
        update listWoliHistoryToUpdate;
        
        system.debug('@@setWOLIToUpdate'+setWOLIToUpdate);
        reCalculateInstallerPayout(setWOLIToUpdate);
    }
    
    public static void reCalculateInstallerPayout(set<String> workOrderItemIds) {
        Map<String, String> mapOFQuoteIdwithProductCode = new Map<String, String>();
        Map<String, Installer_Payout__c> mapOFPartNumberwithTierAmount = new Map<String, Installer_Payout__c>();
        
        List<Installer_Payout_Amount__c> createdIPARecordsList = new List<Installer_Payout_Amount__c>();
        // fetch Installer Payout Amount Records.
        List<Installer_Payout_Amount__c> installerPayoutAmountRecs = [SELECT Id,Work_Order_Line_Item__c, Name, PQM_Line__c, Description__c, Quantity__c, Payout_Amount__c, Source__c
                                                                      FROM Installer_Payout_Amount__c
                                                                      WHERE Work_Order_Line_Item__c =: workOrderItemIds and Work_Order_Line_Item__r.WorkType.Schedule_Type__c='Install'];
        set<String> listWOLIToGeneratePayout=new set<String>();
        for(Installer_Payout_Amount__c IP : installerPayoutAmountRecs){
            listWOLIToGeneratePayout.add(IP.Work_Order_Line_Item__c);
        }
        if(!installerPayoutAmountRecs.isEmpty()){
            delete installerPayoutAmountRecs;
        }
        // create Installer Payout Amount Records If not Exist.
        //if(installerPayoutAmountRecs.isEmpty()){
        List<WorkOrderLineItem> workOrderLineItemList = [SELECT Id, WorkOrder.Quote__c,WorkOrder.ownerId,Primary_Installer__c,Primary_Installer__r.Tier__c  
                                                         FROM WorkOrderLineItem
                                                         WHERE Id =: listWOLIToGeneratePayout
                                                         and WorkType.Schedule_Type__c='Install'];
        List<String> listPrimaryInstaller=new List<String>();
        List<String> listQuotes=new List<String>();
        for(WorkOrderLineItem WOLI : workOrderLineItemList){
            listPrimaryInstaller.add(WOLI.Primary_Installer__c);
            listQuotes.add(WOLI.WorkOrder.Quote__c);
        }
        Map<String,String> userWiseTier=new Map<String,String>();
        // iterate over service resource
        for(ServiceResource SR : [SELECT Id,RelatedRecordId,Tier__c FROM ServiceResource where Id = :listPrimaryInstaller]){
            userWiseTier.put(SR.Id, SR.Tier__c);
        }
        
        List<QuoteLineItem> quoteLineItemRecs = [SELECT Id,Work_Order_Line_Item__r.Primary_Installer__c,LineNumber,Qte_line__c,Work_Order_Line_Item__c, Psi_Resource_Labor__c, QuoteId, Quantity, Description, PO_Line__c, QLI_Type__c,Unit_Type__c, Customer_price__c, Product_Code__c 
                                                 FROM QuoteLineItem
                                                 WHERE Work_Order_Line_Item__c =: workOrderLineItemList and QLI_Type__c = 'LineItem' and Psi_Resource_Labor__c = true];
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
            
            for(QuoteLineItem quoteLine :quoteLineItemRecs){
                Installer_Payout_Amount__c ipa = new Installer_Payout_Amount__c();
                ipa.Work_Order_Line_Item__c = quoteLine.Work_Order_Line_Item__c;
                ipa.PQM_Line__c = quoteLine.Qte_line__c;
                ipa.Description__c = quoteLine.Description;
                ipa.Quantity__c = quoteLine.Quantity;
                if(mapOFQuoteIdwithProductCode.containsKey(quoteLine.Id)){
                    if(mapOFPartNumberwithTierAmount.containsKey(mapOFQuoteIdwithProductCode.get(quoteLine.Id))){
                        String Tier=userWiseTier.get(quoteLine.Work_Order_Line_Item__r.Primary_Installer__c);
                        if(Tier!=null){
                            if(Tier=='1') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier1__c * ipa.Quantity__c;
                            if(Tier=='2') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier2__c * ipa.Quantity__c;
                            if(Tier=='3') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier3__c * ipa.Quantity__c;
                            if(Tier=='4') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier4__c * ipa.Quantity__c;
                            if(Tier=='5') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier5__c * ipa.Quantity__c;
                            if(Tier=='6') ipa.Payout_Amount__c = mapOFPartNumberwithTierAmount.get(mapOFQuoteIdwithProductCode.get(quoteLine.Id)).Tier6__c * ipa.Quantity__c;
                            ipa.Source__c = 'Salesforce';
                            
                        } else{
                            ipa.Payout_Amount__c = quoteLine.Customer_price__c;
                            ipa.Source__c = 'PQM';
                        }
                    }
                    else{
                        ipa.Payout_Amount__c = quoteLine.Customer_price__c;
                        ipa.Source__c = 'PQM';
                    }
                }else{
                    ipa.Payout_Amount__c = quoteLine.Customer_price__c;
                    ipa.Source__c = 'PQM';
                }
                createdIPARecordsList.add(ipa);
                
            }
            
            if(!createdIPARecordsList.isEmpty()){
                insert createdIPARecordsList;
            }
        }
        
    }
    
}