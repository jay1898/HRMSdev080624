/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PQMQuoteInboundBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<AsyncApexJob> listAA=[Select Id, Status,ApexClassId,ApexClass.Name, NumberOfErrors, 
                                   JobItemsProcessed,TotalJobItems, ExtendedStatus 
                                   From AsyncApexJob 
                                   Where ApexClass.Name='PQMQuoteInboundBatch'
                                   And Status in ('Holding','Processing')];
        if(listAA.size()>0){
            return Database.getQueryLocator([SELECT Id, Apex_Debug_Log__c,order__c,salesrepusername__c,/*PQM_Data__c, PQM_Data_2__c, PQM_Data_3__c, PQM_Data_4__c, PQM_Data_5__c, PQM_Data_6__c, PQM_Data_7__c, PQM_Data_8__c,*/orgContactId__c,contactName__c, Is_Executed__c,Exception__c,Opportunity__c,Opportunity__r.AccountId, Quote_Number__c FROM PQM_Quote__c Where Is_Executed__c= false limit 0]); 
        }
        return Database.getQueryLocator([SELECT Id, Apex_Debug_Log__c,order__c,salesrepusername__c,orgContactId__c,contactName__c,/*PQM_Data__c, PQM_Data_2__c, PQM_Data_3__c, PQM_Data_4__c, PQM_Data_5__c, PQM_Data_6__c, PQM_Data_7__c, PQM_Data_8__c,*/ Is_Executed__c,Exception__c,Opportunity__c,Opportunity__r.AccountId, Quote_Number__c FROM PQM_Quote__c Where Is_Executed__c= false order by createddate asc ]);
    }
    
    public void execute(Database.BatchableContext BC, List<PQM_Quote__c> listPQMQuote){
        try{
            //Get Standard PricebookId
            ID standardPricrbookId;
            if(Test.isRunningTest()){
                standardPricrbookId = Test.getStandardPricebookId();//[SELECT Id, IsStandard, IsArchived, IsActive, Name FROM Pricebook2][0].Id;
            }
            else{
                standardPricrbookId = [SELECT Id, IsStandard, IsArchived, IsActive, Name FROM Pricebook2 WHERE IsStandard=TRUE LIMIT 1 ][0].Id;
            }
            
            List<String> PQMIdLst = new List<String>();
            // get List of PQM Salesrep External Username
            Set<String> setUserName= new Set<string>();
            Set<String> setContactIds= new Set<string>();
            Set<String> setContactNames= new Set<string>();
            Set<String> setOpps= new Set<string>();
            Set<String> setOrders= new Set<string>();
            Set<String> setAccIds= new Set<string>();
            for(PQM_Quote__c PQM:listPQMQuote){
                setUserName.add(PQM.salesrepusername__c);
                if(PQM.orgContactId__c!=null){
                    setContactIds.add(PQM.orgContactId__c);
                }
                if(PQM.contactName__c!=null){
                    setContactNames.add(PQM.contactName__c);
                }
                if(PQM.Opportunity__c!=null){
                    setOpps.add(PQM.Opportunity__c);
                }
                if(PQM.order__c!=null){
                    setOrders.add(PQM.order__c);
                }
                if(PQM.Opportunity__r.AccountId!=null){
                    setAccIds.add(PQM.Opportunity__r.AccountId);
                }
                 PQMIdLst.add(PQM.Id);
            }
            
            // Added for national account
            Map<String,String> mapContactIdByOrgId=new Map<String,String>();
            Map<String,String> mapOppConRole=new Map<String,String>();
            List<Contact> listContacts=new List<Contact>();
            if(setContactIds.size()>0){
                List<Contact> listContact=[SELECT ID,Org_Contact_ID__c FROM Contact Where Org_Contact_ID__c!=null and  Org_Contact_ID__c=:setContactIds];
                for(Contact con: listContact){
                    mapContactIdByOrgId.put(con.Org_Contact_ID__c,con.Id);
                }
            
                //Opp contact role
                List<OpportunityContactRole> listContactRoles=[SELECT ID,OpportunityId,ContactId FROM OpportunityContactRole Where OpportunityId= :setOpps];
                for(OpportunityContactRole oppcon: listContactRoles){
                    mapOppConRole.put(oppcon.OpportunityId+'_'+oppcon.ContactId,oppcon.Id);
                }
                
                //Opp contact role
                listContacts=[SELECT ID,Name,AccountId FROM Contact Where AccountId= :setAccIds];
                
            
            }
            
            // Get List of User From External name
            List<User> listOwnerUser = [SELECT Id, EBS_UserName__c FROM user where EBS_UserName__c in :setUserName];
            Map<String, String> mapUser = new Map<String, String>();
            for(User usr : listOwnerUser){ 
                mapUser.put(usr.EBS_UserName__c,usr.Id);
            }
            
            Map<String,Quote> quoteMap = new Map<String,Quote>();
            Map<String,Order> orderMap = new Map<String,Order>();
            Map<String, Product2> mapQuoteProduct = new Map<String, Product2>();
            Map<String, PricebookEntry> mapProductPriceBook = new Map<String, PricebookEntry>();
            List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
            Map<String,QuoteLineItem> MapQuoteLineItemUpsert = new Map<String,QuoteLineItem>();
            List<OrderItem> listOrderLineItem = new List<OrderItem>();
            List<OpportunityContactRole> listOppConRole=new List<OpportunityContactRole>();
            List<String> listPQMQuoteNo=new List<String>();
            //List<String> PQMIdLst = new List<String>();
            Map<String, String> quoteNumberVSJSON = new Map<String, String>();
            
            /*for(PQM_Quote__c PQM : listPQMQuote){
                PQMIdLst.add(PQM.Id);
            }*/
            List<Attachment> attachmentLst = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE ParentId =: PQMIdLst];
            for(Attachment att : attachmentLst){
                String attchmentName = att.Name;
                attchmentName = attchmentName.remove('.txt');
                quoteNumberVSJSON.put(attchmentName, (att.Body).toString());
            }
            
            system.debug('@@quoteNumberVSJSON@@'+ quoteNumberVSJSON);
            
            for(PQM_Quote__c PQM:listPQMQuote){
                PQM.Is_Executed__c=true;
                try{
                    //Get Standard PricebookId
                    string PQMData = '';
                    if(quoteNumberVSJSON.containsKey(PQM.Quote_Number__c)){
                         PQMData = quoteNumberVSJSON.get(PQM.Quote_Number__c);                            
                    }
					system.debug('@PQMData@'+ PQMData);
                    //string PQMData = //PQM.PQM_Data__c + PQM.PQM_Data_2__c + PQM.PQM_Data_3__c + PQM.PQM_Data_4__c + PQM.PQM_Data_5__c + PQM.PQM_Data_6__c + PQM.PQM_Data_7__c + PQM.PQM_Data_8__c;
                    PQMQuoteWrapper.Request req = (PQMQuoteWrapper.Request)JSON.deserialize(PQMData,PQMQuoteWrapper.Request.class);
                    
                    // add PQM quote in list 
                    listPQMQuoteNo.add(req.quotenumber);
                    
                    if(!mapQuoteProduct.containsKey(req.quotenumber)){
                        mapQuoteProduct.put(req.quotenumber,new Product2(name='Quote#' + req.quotenumber + 'Products',IsActive = true,Quote_Number_PQM__c=req.quotenumber));
                    }
                    if(!mapProductPriceBook.containsKey(req.quotenumber)){
                        mapProductPriceBook.put(req.quotenumber,new PricebookEntry(Pricebook2Id = standardPricrbookId,UnitPrice=1,IsActive=true,Product2 = mapQuoteProduct.get(req.quotenumber),Quote_Number_PQM__c=req.quotenumber));
                    }
                    
                    if(PQM.Order__c!=null){
                        // Create Order and Order Line Item
                        Order newOrder = new Order();
                        newOrder.Id=PQM.Order__c;
                        newOrder.Pricebook2Id=standardPricrbookId;
                        newOrder.OrderReferenceNumber = req.quotenumber;
                        newOrder.PQM_Quote_ID__c=req.quoteid;
                        if(String.isNotBlank(req.businessSegment)){ 
                            newOrder.Business_Segment__c=req.businessSegment.equalsIgnoreCase('Retail')?'Replacement':req.businessSegment;
                            
                        }
                        
                        if(req.OrderType!=null && String.isNotBlank(req.OrderType)){
                            newOrder.Order_Type__c=req.OrderType;
                        }
                        
                        newOrder.Name = (req.quotename==null || String.isBlank(req.quotename))?'Quote Name : BLANK':req.quotename;
                        newOrder.Earliest_LRD_Date__c = (!String.isBlank(req.earliestLRD))?Date.parse(req.earliestLRD.replace('-','/')) : null;
                        
                        if(mapUser.containsKey(req.salesrepusername)){
                            newOrder.OwnerId = mapUser.get(req.salesrepusername);
                        }
                        newOrder.Status = req.status;
                        if(!String.isBlank(req.bookdate)){
                            newOrder.EffectiveDate =Date.parse(req.bookdate.replace('-','/'));
                        }
                        newOrder.ActivatedDate =  (!String.isBlank(req.signedContractdate))?Date.parse(req.signedContractdate.replace('-','/')) : null;
                        
                        newOrder.PQM_Quote_Date__c = (!String.isBlank(req.PQMQuoteDate))?Date.parse(req.PQMQuoteDate.replace('-','/')) : null;
                        newOrder.PQM_Link_Date__c = (!String.isBlank(req.PQMLinkDate))?Date.parse(req.PQMLinkDate.replace('-','/')) : null;
                        newOrder.PQM_List_Price__c = req.PQMListPrice==null?0:decimal.valueOf(req.PQMListPrice);
                        newOrder.PQM_Quote_Discount__c = req.PQMQuoteDiscount==null?0:decimal.valueOf(req.PQMQuoteDiscount);
                        newOrder.PQM_Quote_Discount_Percentage__c = req.PQMQuoteDiscountPercent==null?0:decimal.valueOf(req.PQMQuoteDiscountPercent)*100;
                        
                        newOrder.PoNumber = req.ponumber;
                        newOrder.PQMQuoteType__c = req.QuoteType;
                        // If (req.QuoteType == 'COPY' || req.QuoteType == 'ALT' )
                        //     newQuote.Forecasted__c = false; //Boolean.valueOf(req.forecast);
                        newOrder.OpportunityId = PQM.Opportunity__c;
                        newOrder.Total_BAC_Price__c=decimal.valueOf(req.totalBACprice);
                        newOrder.Customer_Extended_Price__c=decimal.valueOf(req.customerextendedprice);
                        
                        orderMap.put(newOrder.Id,newOrder);
                        
                        // Get Set of unique Brand Name
                        Set<String> setBrandName = new Set<String>();
                        Decimal TotalInvoicePrice=0;
                        for(PQMQuoteWrapper.brandcount brandObj : req.brandcount){
                            for(PQMQuoteWrapper.productCount productObj : brandObj.productCount){
                                if(decimal.valueOf(productObj.count)==0
                                  && (productObj.orderQuantity==null || String.isBlank(productObj.orderQuantity) || decimal.valueOf(productObj.orderQuantity)==0))
                                    continue;
                                //Create Quote Line Item
                                OrderItem OLI = new OrderItem();
                                OLI.Product_Type__c = productObj.producttype;
                                OLI.Quantity = decimal.valueOf(productObj.count)==0?decimal.valueOf(productObj.orderQuantity):decimal.valueOf(productObj.count);
                                if(decimal.valueOf(productObj.count)!=0){
                                    OLI.UnitPrice =decimal.valueOf(productObj.customerextendedprice )/decimal.valueOf(productObj.count);
                                }else if(decimal.valueOf(productObj.orderQuantity)!=0){
                                    OLI.UnitPrice =decimal.valueOf(productObj.customerextendedprice )/decimal.valueOf(productObj.orderQuantity);
                                }else{
                                    OLI.UnitPrice=0;
                                }                                
                                OLI.Brand__c = brandObj.brand;
                                OLI.Total_BAC_Price__c=productObj.totalBACprice==null?0:decimal.valueOf(productObj.totalBACprice);
                                OLI.Total_Invoice_Price__c=productObj.totalinvoiceprice==null?0:decimal.valueOf(productObj.totalinvoiceprice);
                                OLI.Order=orderMap.get(newOrder.Id);
                                OLI.OrderId=newOrder.Id;
                                OLI.Product2=mapQuoteProduct.get(newOrder.OrderReferenceNumber);
                                OLI.PricebookEntry= mapProductPriceBook.get(newOrder.OrderReferenceNumber);
                                
                                listOrderLineItem.add(OLI);
                            }
                            TotalInvoicePrice+= (brandObj.totalinvoiceprice==null?0:decimal.valueOf(brandObj.totalinvoiceprice));
                        }
                        String brandName = '';
                        for(String temp : setBrandName){
                            brandName += temp + ',';
                        }
                        newOrder.Brand__c = brandName.length()>0? brandName.substring(0, (brandName.length()-1)):'';
                        //newQuote.Total_Invoice_Price__c=TotalInvoicePrice;
                        newOrder.Total_Invoice_Price__c=(req.totalinvoiceprice==null?0:decimal.valueOf(req.totalinvoiceprice));
                        // Update Flag
                    }
                    if(PQM.Opportunity__c!=null){
                        // Create Quote
                        Quote newQuote = new Quote();
                        newQuote.Quote_Number_PQM__c = req.quotenumber;
                        newQuote.PQM_Quote_ID__c=req.quoteid;
                        if(String.isNotBlank(req.businessSegment)){ 
                            newQuote.Business_Segment__c=req.businessSegment.equalsIgnoreCase('Retail')?'Replacement':req.businessSegment;
                        }
                        // added on 15-03-2022
                        if(String.isNotBlank(req.marketSegment)){ 
                            newQuote.Market_Segment__c =req.marketSegment;
                        }
                        // End 
                        // National Account
                        if(req.orgContactId!=null && String.isNotBlank(req.orgContactId) ){ 
                            if(mapContactIdByOrgId.containsKey(req.orgContactId) ){
                                newQuote.contactId=mapContactIdByOrgId.get(req.orgContactId);
                            }else {
                                for(contact con:listContacts){
                                    if(con.AccountId==PQM.Opportunity__r.AccountId &&  con.Name.equalsIgnoreCase(req.contactName) ){
                                        newQuote.contactId=con.Id;
                                    }
                                }
                            }
                            
                            if(newQuote.contactId!=null){
                                OpportunityContactRole OppCon=new OpportunityContactRole();
                                OppCon.ContactId=newQuote.contactId;
                                OppCon.OpportunityId=PQM.Opportunity__c;
                                OppCon.Role='Pella Certified Contractor';
                                if(mapOppConRole.containsKey(OppCon.OpportunityId+'_'+OppCon.ContactId)){
                                    OppCon.Id=mapOppConRole.get(OppCon.OpportunityId+'_'+OppCon.ContactId);
                                }
                                listOppConRole.add(OppCon);
                            }
                        }
                        
                        if(req.OrderType!=null && String.isNotBlank(req.OrderType)){
                            newQuote.Order_Type__c=req.OrderType;
                        }
                        
                        newQuote.Name = (req.quotename==null || String.isBlank(req.quotename))?'Quote Name : BLANK':req.quotename;
                        newQuote.Earliest_LRD_Date__c = (!String.isBlank(req.earliestLRD))?Date.parse(req.earliestLRD.replace('-','/')) : null;
                        
                        if(mapUser.containsKey(req.salesrepusername)){
                            newQuote.OwnerId = mapUser.get(req.salesrepusername);
                        }
                        newQuote.Status = req.status;
                          
                        // set Forcasted to false
                        /*IF(newQuote.Status=='Active' || newQuote.Status=='Engineering'){
                            newQuote.Forecasted__c = false;
                        }*/
                        IF(newQuote.Status=='Cancelled' || newQuote.Status=='Canceled'){
                            newQuote.Forecasted__c = false;
                        }

                        
                        newQuote.BookDate__c = (!String.isBlank(req.bookdate))?Date.parse(req.bookdate.replace('-','/')) : null;
                        newQuote.Signed_Contract_Date__c =  (!String.isBlank(req.signedContractdate))?Date.parse(req.signedContractdate.replace('-','/')) : null;
                        
                        newQuote.PQM_Quote_Date__c = (!String.isBlank(req.PQMQuoteDate))?Date.parse(req.PQMQuoteDate.replace('-','/')) : null;
                        newQuote.PQM_Link_Date__c = (!String.isBlank(req.PQMLinkDate))?Date.parse(req.PQMLinkDate.replace('-','/')) : null;
                        newQuote.PQM_List_Price__c = req.PQMListPrice==null?0:decimal.valueOf(req.PQMListPrice);
                        newQuote.PQM_Quote_Discount__c = req.PQMQuoteDiscount==null?0:decimal.valueOf(req.PQMQuoteDiscount);
                        newQuote.PreparedBy__c =req.preparedBy;
                        newQuote.PQM_Quote_Discount_Percentage__c = req.PQMQuoteDiscountPercent==null?0:decimal.valueOf(req.PQMQuoteDiscountPercent)*100;
                        newQuote.BAC_Quote_Discount_percent__c = req.PQMBACDiscount==null?0:decimal.valueOf(req.PQMBACDiscount)*100;
                        if(req.customer!=null){
                            newQuote.Customer_Street__c = ((!String.isBlank(req.customer.jobaddress))?req.customer.jobaddress : '')+((!String.isBlank(req.customer.jobAddress2))?req.customer.jobAddress2 : '');
 							newQuote.Customer_City__c = ((!String.isBlank(req.customer.jobcity))?req.customer.jobcity : '');
                            newQuote.Customer_State__c = ((!String.isBlank(req.customer.jobstate))?req.customer.jobstate : '');
                            newQuote.Customer_Zip__c = ((!String.isBlank(req.customer.jobzip))?req.customer.jobzip : '');
                            newQuote.Customer_Country__c = ((!String.isBlank(req.customer.jobCountry))?req.customer.jobCountry : '');
 
                        }
                        if(req.projectOwner!=null){
                            newQuote.ProjectOwner_Street__c = ((!String.isBlank(req.projectOwner.jobaddress))?req.projectOwner.jobaddress : '')+((!String.isBlank(req.projectOwner.jobAddress2))?req.projectOwner.jobAddress2 : '');
                            newQuote.ProjectOwner_City__c = ((!String.isBlank(req.projectOwner.jobcity))?req.projectOwner.jobcity : '');
                            newQuote.ProjectOwner_State__c = ((!String.isBlank(req.projectOwner.jobstate))?req.projectOwner.jobstate : '');
                            newQuote.ProjectOwner_Zip__c = ((!String.isBlank(req.projectOwner.jobzip))?req.projectOwner.jobzip : '');
                            newQuote.ProjectOwner_Country__c = ((!String.isBlank(req.projectOwner.jobCountry))?req.projectOwner.jobCountry : '');
                        }
                        newQuote.Recovery__c = ((!String.isBlank(req.recoveryQuote) && req.recoveryQuote.equalsIgnoreCase('true'))?true:false);
                        
                        newQuote.PO_Number__c = req.ponumber;
                        newQuote.PQMQuoteType__c = req.QuoteType;
                        // If (req.QuoteType == 'COPY' || req.QuoteType == 'ALT' )
                        //     newQuote.Forecasted__c = false; //Boolean.valueOf(req.forecast);
                        newQuote.OpportunityId = PQM.Opportunity__c;
                        newQuote.Pricebook2Id = standardPricrbookId;
                        newQuote.Total_BAC_Price__c=decimal.valueOf(req.totalBACprice);
                        newQuote.Customer_Extended_Price__c=decimal.valueOf(req.customerextendedprice);
                        
                        quoteMap.put(newQuote.Quote_Number_PQM__c,newQuote);
                        
                        // Get Set of unique Brand Name
                        Set<String> setBrandName = new Set<String>();
                        Decimal TotalInvoicePrice=0;
                        for(PQMQuoteWrapper.brandcount brandObj : req.brandcount){
                            for(PQMQuoteWrapper.productCount productObj : brandObj.productCount){
                                if(decimal.valueOf(productObj.count)==0)
                                    continue;
                                //Create Quote Line Item
                                QuoteLineItem QL = new QuoteLineItem();
                                QL.Product_Type__c = productObj.producttype;
                                QL.Quantity = decimal.valueOf(productObj.count) == null?1:decimal.valueOf(productObj.count);
                                QL.UnitPrice =decimal.valueOf(productObj.count)==0?0:decimal.valueOf(productObj.customerextendedprice )/decimal.valueOf(productObj.count);
                                QL.Brand__c = brandObj.brand;
                                QL.Total_BAC_Price__c=productObj.totalBACprice==null?0:decimal.valueOf(productObj.totalBACprice);
                                QL.Total_Invoice_Price__c=productObj.totalinvoiceprice==null?0:decimal.valueOf(productObj.totalinvoiceprice);
                                QL.Quote=quoteMap.get(newQuote.Quote_Number_PQM__c);
                                QL.Product2=mapQuoteProduct.get(newQuote.Quote_Number_PQM__c);
                                QL.PricebookEntry= mapProductPriceBook.get(newQuote.Quote_Number_PQM__c);
                                QL.QLI_Type__c='Aggregated';
                                listQuoteLineItem.add(QL);
                            }
                            TotalInvoicePrice+= (brandObj.totalinvoiceprice==null?0:decimal.valueOf(brandObj.totalinvoiceprice));
                        }
                        system.debug('@@'+JSON.serialize(req.lineitems));
                        for(PQMQuoteWrapper.lineitem lineitems : req.lineitems){
                             //Create Quote Line Item
                            QuoteLineItem QL = new QuoteLineItem();
                           /* QL.Product_Type__c = productObj.producttype;
                            QL.Quantity = decimal.valueOf(productObj.count);
                            QL.UnitPrice =decimal.valueOf(productObj.count)==0?0:decimal.valueOf(productObj.customerextendedprice )/decimal.valueOf(productObj.count);
                            QL.Brand__c = brandObj.brand;
                            QL.Total_BAC_Price__c=productObj.totalBACprice==null?0:decimal.valueOf(productObj.totalBACprice);
                            QL.Total_Invoice_Price__c=productObj.totalinvoiceprice==null?0:decimal.valueOf(productObj.totalinvoiceprice);*/
                            QL.Brand__c = lineitems.BR;
                            QL.Product_Type__c = lineitems.PT;
                            QL.Qte_Line__c = lineitems.QL;
                            QL.PO_Line__c = (lineitems.PL==null?null:Decimal.valueOf(lineitems.PL));
                            QL.Unit_Type__c = lineitems.UT;
                            QL.Room_Location__c = lineitems.RL;
                            QL.Order_Quantity__c = (lineitems.OQ==null?null:Decimal.valueOf(lineitems.OQ));
                            QL.Quantity = ((lineitems.QQ==null || Integer.valueOf(lineitems.QQ)==0)?1:Decimal.valueOf(lineitems.QQ));
                            QL.Total_BAC_Price__c=(lineitems.DP==null || lineitems.DP=='')?0:decimal.valueOf(lineitems.DP)*QL.Quantity;
                            QL.Unit_BAC_Price__c=(lineitems.DP==null || lineitems.DP=='')?0:decimal.valueOf(lineitems.DP);
                            
                            if(lineitems.UT=='MANUAL' || lineitems.UT=='BRCat' || lineitems.UT=='ValueAdd'){
                                 QL.Total_BAC_Price__c=(lineitems.CC==null || lineitems.CC=='')?0:decimal.valueOf(lineitems.CC)*QL.Quantity;
                                 QL.Unit_BAC_Price__c=(lineitems.CC==null || lineitems.CC=='')?0:decimal.valueOf(lineitems.CC);
                            }
                               
                            QL.Description = (lineitems.DE!=null && lineitems.DE.length() > 254? lineitems.DE.substring(0,254):lineitems.DE);
                            QL.Product_Code__c = lineitems.PC;
                            QL.Psi_Resource_Labor__c = (lineitems.PS==null?null: Boolean.valueOf(lineitems.PS));
                            QL.Frame_Width__c = lineitems.FW;
                            QL.Frame_Height__c = lineitems.FH;
                            QL.Customer_price__c = ((lineitems.CC==null || lineitems.CC=='')?0.0: Decimal.valueOf(lineitems.CC));  
                            QL.Exterior_Color__c = lineitems.EC;
                            QL.Assembly_Type__c = lineitems.AT;
                            QL.Interior_Finish__c= lineitems.FN;
                            QL.Shippable__c= (lineitems.SF!=null && lineitems.SF=='1');
                            QL.Hardware_Style__c = lineitems.HS;
                            QL.Grille_Pattern__c = lineitems.GP;
                            QL.Overall_Rough_Opening_Width__c = (lineitems.OW==null?null: Decimal.valueOf(lineitems.OW));  
                            QL.Overall_Rough_Opening_Height__c =(lineitems.OH==null?null: Decimal.valueOf(lineitems.OH)); 
                            QL.Screen_Option__c = lineitems.SO;
                            QL.Screen_Shipping_Option__c = lineitems.SS;
                            QL.Operating_Hardware_Shipping_Option__c= lineitems.OS;
                            QL.Operation_Venting__c = lineitems.OV;
                            QL.UnitPrice =  ((lineitems.CP==null || lineitems.CP=='')?0.0: Decimal.valueOf(lineitems.CP));
                            QL.Quote=quoteMap.get(newQuote.Quote_Number_PQM__c);
                            QL.Product2=mapQuoteProduct.get(newQuote.Quote_Number_PQM__c);
                            QL.PricebookEntry= mapProductPriceBook.get(newQuote.Quote_Number_PQM__c);
                            QL.QLI_Type__c='LineItem';
                            QL.ExternalId__c=newQuote.Quote_Number_PQM__c +'-'+QL.Qte_Line__c +'-'+QL.PO_Line__c;
                            if(QL.PO_Line__c==null || QL.PO_Line__c==0 || QL.PO_Line__c==-1){
                                if(QL.Description!=null && QL.Description.indexOf('-')>0){
                                     QL.ExternalId__c=newQuote.Quote_Number_PQM__c +'-'+QL.Qte_Line__c +'-'+QL.Description.substring(0,QL.Description.indexOf('-')-1);
                                }else{
                                    QL.ExternalId__c=newQuote.Quote_Number_PQM__c +'-'+QL.Qte_Line__c +'-'+(QL.Description.length() > 240?QL.Description.substring(0,240):QL.Description);
                                }
                            }

                            //listQuoteLineItem.add(QL);
                            //MapQuoteLineItemUpsert.put(QL.ExternalId__c,QL);
                             // purge quote line if status is Cancelled
                             If(!( newQuote.Status == 'Cancelled' || newQuote.Status == 'Canceled')){
                                
                                //listQuoteLineItem.add(QL);
                                MapQuoteLineItemUpsert.put(QL.ExternalId__c,QL);
                            }
                        }
                        String brandName = '';
                        for(String temp : setBrandName){
                            brandName += temp + ',';
                        }
                        newQuote.Brand__c = brandName.length()>0? brandName.substring(0, (brandName.length()-1)):'';
                        //newQuote.Total_Invoice_Price__c=TotalInvoicePrice;
                        newQuote.Total_Invoice_Price__c=(req.totalinvoiceprice==null?0:decimal.valueOf(req.totalinvoiceprice));
                        // Update Flag
                        
                    }
                    
                }catch (Exception e){
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('PQMQuoteInbound','postData','PQM ID: ' + PQM.Id,e.getMessage(), e.getStackTraceString(),'Integration'));
                    PQM.Exception__c=e.getMessage();
                    PQM.hasError__c=true;
                }
                
                
            }
            // If Quote
            if(quoteMap.size()>0){
                // get Existing Quote
                Map<String,Quote> quoteNoWiseQuote=new Map<String,Quote>();
                
                List<Quote> listQuote=[SELECT ID,Quote_Number_PQM__c,OpportunityId,Total_Invoice_Price__c,Total_BAC_Price__c,OwnerId, Forecasted__c FROM Quote Where Quote_Number_PQM__c in :listPQMQuoteNo];
                for(Quote q: listQuote){
                    quoteNoWiseQuote.put(q.Quote_Number_PQM__c,q);
                }
                system.debug('@@quoteNoWiseQuote :: '+JSON.serialize(quoteNoWiseQuote));
                List<Quote> listQuoteToDelete=new List<Quote>();
                List<String> listQuoteNoDelete=new List<String>();
                List<BAC_History__c> listBACHistory=new List<BAC_History__c>();
                // compare Total BAC Price
                for(Quote Q : quoteMap.values()){
                    if(quoteNoWiseQuote.containsKey(q.Quote_Number_PQM__c)){
                        // User to change Flag
                        Q.Forecasted__c=quoteNoWiseQuote.get(q.Quote_Number_PQM__c).Forecasted__c;
                        
                        if(Q.Total_BAC_Price__c!=quoteNoWiseQuote.get(q.Quote_Number_PQM__c).Total_BAC_Price__c){
                            // Create BAC Booking Record With differnce Amount
                            BAC_History__c BACHistory=new BAC_History__c();
                            BACHistory.Quote__r=Q;
                            BACHistory.Price__c=Q.Total_BAC_Price__c-quoteNoWiseQuote.get(q.Quote_Number_PQM__c).Total_BAC_Price__c;
                            BACHistory.Type__c='BAC Booking';
                            listBACHistory.add(BACHistory);
                        }
                        if(Q.Total_Invoice_Price__c!=quoteNoWiseQuote.get(q.Quote_Number_PQM__c).Total_Invoice_Price__c){
                            system.debug('@@'+quoteNoWiseQuote.get(q.Quote_Number_PQM__c).Total_Invoice_Price__c);
                            system.debug('@@'+Q.Total_Invoice_Price__c);
                            // Create BAC Booking Record With differnce Amount
                            BAC_History__c BACHistory=new BAC_History__c();
                            BACHistory.Quote__r=Q;
                            BACHistory.Price__c=(Q.Total_Invoice_Price__c == null?0:Q.Total_Invoice_Price__c)-(quoteNoWiseQuote.get(q.Quote_Number_PQM__c).Total_Invoice_Price__c==null?0:quoteNoWiseQuote.get(q.Quote_Number_PQM__c).Total_Invoice_Price__c);
                            BACHistory.Type__c='BAC Invoice';
                            listBACHistory.add(BACHistory);
                        }
                        
                        // check Quote ParentId Change
                        if(Q.OpportunityId!=quoteNoWiseQuote.get(q.Quote_Number_PQM__c).OpportunityId){
                            listQuoteToDelete.add(quoteNoWiseQuote.get(q.Quote_Number_PQM__c));
                            listQuoteNoDelete.add(q.Quote_Number_PQM__c);
                        }
                        If( Q.Status == 'Contracted' || Q.Status == 'Booked' || Q.Status == 'PendingBooked' || Q.Status == 'PendingIntegration' || Q.Status == 'Ordered' )
                            Q.Forecasted__c = true; //Boolean.valueOf(req.forecast); 
                      
                        //set oldowner
                        Q.OwnerId=quoteNoWiseQuote.get(q.Quote_Number_PQM__c).OwnerId;
                    }else{
                        // Create BAC Booking Record
                        BAC_History__c BACHistory=new BAC_History__c();
                        BACHistory.Quote__r=Q;
                        BACHistory.Price__c=Q.Total_BAC_Price__c;
                        BACHistory.Type__c='BAC Booking';
                        listBACHistory.add(BACHistory);
                        
                        // Create BAC Invoice Record
                        BAC_History__c BACInvHistory=new BAC_History__c();
                        BACInvHistory.Quote__r=Q;
                        BACInvHistory.Price__c=Q.Total_Invoice_Price__c;
                        BACInvHistory.Type__c='BAC Invoice';
                        listBACHistory.add(BACInvHistory);
                        // Added to handle scenario
                        if(Q.Status == 'Active'){
                            q.Forecasted__c = true;
                       }
                        //Set Forecasted Flag as false for COPY and ALT quotes
                        If((q.PQMQuoteType__c=='COPY' || q.PQMQuoteType__c=='ALT') && !(Q.Status == 'Contracted' || Q.Status == 'Booked' || Q.Status == 'PendingBooked' || Q.Status == 'PendingIntegration' || Q.Status == 'Ordered'))
                            q.Forecasted__c = false; //Boolean.valueOf(req.forecast);
                    }
                }
                system.debug('@@dfquoteMap :: '+JSON.serialize(quoteMap));
                List<BAC_History__c> listBACHToReParent=new List<BAC_History__c>();
                if(listQuoteNoDelete.size()>0){
                    // get History List , this need in case of Quote Re-Parent
                    listBACHToReParent=[SELECT ID,Quote__C,Quote__r.Quote_Number_PQM__c FROM BAC_History__c Where Quote__r.Quote_Number_PQM__c in :listQuoteNoDelete];
                }            
                
                //Delete Existing Quote LineItem // added line item filter criteria 
                delete [SELECT ID,PricebookEntryId,QuoteId,Product2Id FROM QuoteLineItem Where Quote.Quote_Number_PQM__c in :listPQMQuoteNo and QLI_Type__c !='LineItem'];
                
                
                delete listQuoteToDelete;
                //delete [SELECT ID FROM Quote Where Quote_Number_PQM__c in :listPQMQuoteNo];
                
                // upsert Quote Based on Quote Number
                upsert quoteMap.values() Quote_Number_PQM__c;
                
                upsert mapQuoteProduct.values() Quote_Number_PQM__c;
                
                // Set Quote Record Id bases on insert
                for(BAC_History__c BACHistory :listBACHistory){
                    BACHistory.Quote__c=BACHistory.Quote__r.Id;
                }
                insert listBACHistory;
                
                // Re-Parent BAC in case of Quote Delete
                if(listBACHToReParent.size()>0){
                    for(BAC_History__c BAC: listBACHToReParent){
                        BAC.Quote__c=quoteMap.get(BAC.Quote__r.Quote_Number_PQM__c).Id;
                    }
                    update listBACHToReParent;
                }
                
                for(String quoteNumber :mapProductPriceBook.keySet()){
                    mapProductPriceBook.get(quoteNumber).Product2Id=mapQuoteProduct.get(quoteNumber).Id;
                }
                
                upsert mapProductPriceBook.values() Quote_Number_PQM__c;	
                
                // New Logic of Purge
                List<QuoteLineItem> ListQLIToInsert=new List<QuoteLineItem>();
                for(QuoteLineItem QL :listQuoteLineItem){
                    QL.QuoteId=QL.Quote.Id;
                    QL.Product2Id=mapQuoteProduct.get(QL.Quote.Quote_Number_PQM__c).Id;
                    QL.PricebookEntryID= mapProductPriceBook.get(QL.Quote.Quote_Number_PQM__c).Id;

                    if(QL.Quote.Forecasted__c!=false){
                        ListQLIToInsert.add(QL);
                    }

                    if(QL.QuoteId!=null) QL.Quote=null;

                   
                    
                }
                // insert Quote Line Item
                //insert listQuoteLineItem;
                insert ListQLIToInsert;
                
                //Delete Existing Quote LineItem // added line item filter criteria 
                delete [SELECT ID,PricebookEntryId,QuoteId,Product2Id FROM QuoteLineItem Where Quote.Quote_Number_PQM__c in :listPQMQuoteNo  and ExternalId__c not in :MapQuoteLineItemUpsert.keyset() and QLI_Type__c ='LineItem'];
                ListQLIToInsert=new List<QuoteLineItem>();
                for(String QLKey :MapQuoteLineItemUpsert.keySet()){
                    QuoteLineItem QL=MapQuoteLineItemUpsert.get(QLKey);
                    QL.QuoteId=QL.Quote.Id;
                    QL.Product2Id=mapQuoteProduct.get(QL.Quote.Quote_Number_PQM__c).Id;
                    QL.PricebookEntryID= mapProductPriceBook.get(QL.Quote.Quote_Number_PQM__c).Id;

                    if(QL.Quote.Forecasted__c!=false){
                        ListQLIToInsert.add(QL);
                    }
                    if(QL.QuoteId!=null) QL.Quote=null;
                    
                    
                }
                // insert Quote Line Item
                //upsert MapQuoteLineItemUpsert.values() ExternalId__c;
                upsert ListQLIToInsert ExternalId__c;
                
                update listPQMQuote;
                
                // National Account insert opp Role
                Database.upsert(listOppConRole,false);
            }
            // if order
            if(orderMap.size()>0){
                
                /*List<Order> listActiveOrder=[SELECT Id FROM Order where id =:orderMap.keySet() and Status in('Active','Activated')];
                for(Order Ord : listActiveOrder){
                    Ord.Status='Draft';
                }
                update listActiveOrder;*/
                
                //Delete Existing Quote LineItem
                delete [SELECT ID FROM OrderItem Where OrderId in :orderMap.keySet()];
                
                upsert mapQuoteProduct.values() Quote_Number_PQM__c;
                
                for(String quoteNumber :mapProductPriceBook.keySet()){
                    mapProductPriceBook.get(quoteNumber).Product2Id=mapQuoteProduct.get(quoteNumber).Id;
                }
                
                upsert mapProductPriceBook.values() Quote_Number_PQM__c;	
                
                for(OrderItem OI :listOrderLineItem){
                    OI.Product2Id=mapQuoteProduct.get(OI.Order.OrderReferenceNumber).Id;
                    OI.PricebookEntryID= mapProductPriceBook.get(OI.Order.OrderReferenceNumber).Id;
                }
                // insert Quote Line Item
                insert listOrderLineItem;
                
                 // upsert Quote Based on Quote Number
                update orderMap.values();
                
                update listPQMQuote;
               
            }
        }catch(Exception e){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('PQMQuoteInbound','postData','PQM : ' + JSON.serialize(listPQMQuote),'Exception :: '+e.getMessage(), e.getStackTraceString(),'Integration'));
            //throw e;
            for(PQM_Quote__c PQM:listPQMQuote){
                PQM.Is_Executed__c=true;
                PQM.hasError__c=true;
                PQM.Exception__c=e.getMessage();
            }
            update listPQMQuote;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        PQMQuoteInboundBatch b = new PQMQuoteInboundBatch(); 
        database.executebatch(b,1);
    }
}