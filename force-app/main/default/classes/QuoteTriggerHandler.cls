public class QuoteTriggerHandler {
    public static List<String> listOrderStatus=new List<String>{'booked','pending order ack','pendingintegration','ordered','pendingbooked'};
        public static Boolean isRecursive = False;
    
    public static void updatePCCOpportunityName(List<Quote> listQuote){
        List<Id> listOppIds=new list<Id>();
        Map<Id,Quote> mapQuote=new Map<Id,Quote>();
        for(Quote Q: listQuote){
            listOppIds.add(Q.OpportunityId);
            mapQuote.put(Q.OpportunityId,Q);
        }
        List<Opportunity> listOpportunity=[SELECT Id,Name,Is_Created_Using_PCC__c FROM Opportunity Where Id =:listOppIds and Count_of_Quotes__c=0 and Is_Created_Using_PCC__c=true];
        if(listOpportunity.size()>0){
            for(Opportunity opp : listOpportunity){
                opp.Name=opp.Name + ' '+ mapQuote.get(opp.Id).Name;
                if(opp.Name.length() > 120){
                    opp.Name =  opp.Name.substring(0,120);
                }
            }
            Boolean OppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
            OpportunityTriggerHandler.RUN_TRIGGER=false;
            update listOpportunity; 
            OpportunityTriggerHandler.RUN_TRIGGER=OppTrigger;
            
        }
    }
     
    public static void updateOpportunityTotalPriceQuote(List<Quote> listQuote,Map<Id,Quote> oldMap){
        list<Id> listOppIds=new list<Id>();
        List<String> listEDWOppIds = new List<String>();
        List<Quote> QuotesToUpdate = new List<Quote>();
        List<String> listQuoteIdForPurge=new List<String>();
       List<String> listQuoteIdToReupdate=new List<String>();
        for(Quote q : listQuote){
            if(oldMap==null){
                listOppIds.add(Q.OpportunityId);
                listEDWOppIds.add(Q.OpportunityId); // Rekha.. EDW date update when new quote is created
            }else //Changed If to include EDW columns oppid, pqm id and estimated book date -Rekha (01/13/2021)
            {
                if( Q.Forecasted__c !=  OldMap.get(Q.Id).Forecasted__c 
                   || Q.Customer_Extended_Price__c != OldMap.get(Q.Id).Customer_Extended_Price__c
                   || Q.Total_BAC_Price__c != OldMap.get(Q.Id).Total_BAC_Price__c
                   || Q.Total_Invoice_Price__c != OldMap.get(Q.Id).Total_Invoice_Price__c
                   || Q.Status != OldMap.get(Q.Id).Status
                   || Q.Signed_Contract_Date__c != OldMap.get(Q.Id).Signed_Contract_Date__c
                   || Q.BookDate__c != OldMap.get(Q.Id).BookDate__c
                   || Q.Ship_Complete_Date__c  != OldMap.get(Q.Id).Ship_Complete_Date__c 
                  )
                {
                    listOppIds.add(Q.OpportunityId);
                }
                //EDW Update -- Rekha
                if (   Q.Forecasted__c !=  OldMap.get(Q.Id).Forecasted__c                  
                    || Q.opportunityID  != OldMap.get(Q.Id).opportunityID 
                    || Q.pqm_quote_id__c  != OldMap.get(Q.Id).pqm_quote_id__c 
                    || Q.Estimated_Book_Date__c  != OldMap.get(Q.Id).Estimated_Book_Date__c
                    || Q.status  != OldMap.get(Q.Id).status)
                    // if(Q.PO_Number__c != OldMap.get(Q.Id).PO_Number__c || Q.Status != OldMap.get(Q.Id).Status) 
                {
                    listEDWOppIds.add(Q.OpportunityId);
                    listOppIds.add(Q.OpportunityId);
                }
                // Data Purge Process
                if(Q.Forecasted__c !=  OldMap.get(Q.Id).Forecasted__c  && Q.Forecasted__c==false ){
                    listQuoteIdForPurge.add(Q.Id);
                }
                 // Re Create
                if(Q.Forecasted__c !=  OldMap.get(Q.Id).Forecasted__c  && Q.Forecasted__c==true ){
                    listQuoteIdToReupdate.add(Q.Id);
                }
            }
            /*If(Q.Status== 'Canceled' && Q.Forecasted__c == true)
{  
Quote CanceledQ = Q;
CanceledQ.Forecasted__c = false;
QuotesToUpdate.add(CanceledQ);
}*/
        }
        //purge Line Item
        if(listQuoteIdForPurge.size()>0){
            delete [SELECT ID FROM QuotelineItem Where QuoteId=:listQuoteIdForPurge]; 
        }
        // getLineItemData
        if(listQuoteIdToReupdate.size()>0){
            if(!system.isFuture() && !System.IsBatch())
            {
                PQMIntegrationCallout.getLineItemDataPQMCallout(listQuoteIdToReupdate);
            }
        }
        if(listOppIds.size()>0){
            QuoteTriggerHandler.updateOpportunityTotalPriceQuote(listOppIds, listEDWOppIds);  
        }
        // Update QuotesToUpdate;
    }
    
    
    public static void updateOpportunityTotalPriceQuote(List<Id> listOppIds, List<String> listEDWOppIds){
        
        List<Opportunity> listOpptoUpdate=new List<Opportunity>();
        List<Opportunity> listOpp=[SELECT ID,StageName,Status__c,Project_Closed_Date__c,Book_Date_PQM__c,recordType.DeveloperName,Signed_Contract_Date__c,Quote_Date__c,Appointment_DateTime__c,Total_Price_Quote__c,Total_Invoice_Price_Quote__c,Total_BAC_Price_Quote__c,(SELECT Id,Forecasted__c,Status,BookDate__c,Signed_Contract_Date__c,Customer_Extended_Price__c,Total_BAC_Price__c,Total_Invoice_Price__c,OpportunityId,Createddate,lastmodifieddate,Ship_Complete_Date__c  FRom Quotes order by lastmodifieddate desc) 
                                   FROM Opportunity Where id in :listOppIds];
         // system.debug('@@'+listOpp.size());
        for(Opportunity Opp : listOpp){
            if( opp.recordType.DeveloperName=='Replacement') // && opp.StageName!='Closed') 
            {
                Decimal totalOppAmount=0;
                Decimal totalBACOppAmount=0;
                Decimal totalInvoiceOppAmount=0;
                String StageName,Status;
                Date bookDate,SignedContractDate;
                Quote contractedQuote,closeWon,FirstCallClose,ActiveQuote,CancelQuote;
                Boolean isOppUpdate=false;
                
                
                for(Quote Q: Opp.Quotes){
                    // check for cancel
                    if(CancelQuote==null && Q.Status.equalsIgnoreCase('Canceled')){
                        CancelQuote=Q;
                    }                    
                    if(Q.Forecasted__c){
                        
                        if(opp.Quote_Date__c==null){
                            opp.Quote_Date__c=Date.valueOf(Q.CreatedDate);
                        }
                        
                        // Set Status Based On Quote
                        // Quote Status is Contracted
                        if(contractedQuote == null && (Q.Status.equalsIgnoreCase('Contracted') || ( Q.Status.equalsIgnoreCase('Engineering') && Opp.StageName.equalsIgnoreCase('Contracted')))){
                            contractedQuote=Q;
                        }
                        
                        // Check for close won
                        if(closeWon == null && ( opp.Appointment_DateTime__c==null || (Date.newInstance(opp.Appointment_DateTime__c.year(),opp.Appointment_DateTime__c.month(),opp.Appointment_DateTime__c.day())!=q.Signed_Contract_Date__c  ) )
                           && listOrderStatus.contains(Q.Status.toLowerCase())){
                               closeWon=Q;
                           }// Check for close won First Call
                        else if(FirstCallClose == null && ( opp.Appointment_DateTime__c!=null && (Date.newInstance(opp.Appointment_DateTime__c.year(),opp.Appointment_DateTime__c.month(),opp.Appointment_DateTime__c.day())==q.Signed_Contract_Date__c ) )
                                && listOrderStatus.contains(Q.Status.toLowerCase())){
                                    FirstCallClose=Q;
                                }
                        // Quote Status is Active
                        if(ActiveQuote == null && (Q.Status.equalsIgnoreCase('Active') || ( Q.Status.equalsIgnoreCase('Engineering') && !Opp.StageName.equalsIgnoreCase('Contracted')))){
                            ActiveQuote=Q;
                        }
                        
                        // check for cancel
                        /* if(CancelQuote==null && Q.Status.equalsIgnoreCase('Canceled')){
CancelQuote=Q;
}*/// Moving this logic out of forecasted Flag -- Rekha
                        
                        
                        totalOppAmount+=Q.Customer_Extended_Price__c==null?0:Q.Customer_Extended_Price__c;
                        totalBACOppAmount+=Q.Total_BAC_Price__c==null?0:Q.Total_BAC_Price__c;
                        totalInvoiceOppAmount+=Q.Total_Invoice_Price__c==null?0:Q.Total_Invoice_Price__c;
                    }
                }
                if(Opp.Total_Price_Quote__c!=totalOppAmount){
                    opp.Total_Price_Quote__c=totalOppAmount;
                    isOppUpdate=true;
                }
                if(Opp.Total_BAC_Price_Quote__c==null || Opp.Total_BAC_Price_Quote__c!=totalBACOppAmount){
                    opp.Total_BAC_Price_Quote__c=totalBACOppAmount;
                    isOppUpdate=true;
                }
                if(Opp.Total_Invoice_Price_Quote__c==null || Opp.Total_Invoice_Price_Quote__c!=totalInvoiceOppAmount){
                    opp.Total_Invoice_Price_Quote__c=totalInvoiceOppAmount;
                    isOppUpdate=true;
                }
                /*system.debug('@@'+CancelQuote);
system.debug('@@FirstCallClose '+FirstCallClose);
system.debug('@@closeWon '+closeWon);
system.debug('@@ActiveQuote '+ActiveQuote);
system.debug('@@contractedQuote '+contractedQuote);*/
                Quote FinalQuoteToUpdate;
                
                // Update Opp Status Based on condition
                if(FirstCallClose!=null && closeWon!=null ){
                    if(FirstCallClose.lastmodifieddate>closeWon.lastmodifieddate){
                        Opp.StageName='Closed Won';
                        Opp.Status__c='First Call Close';
                        if(opp.Book_Date_PQM__c==null)opp.Book_Date_PQM__c=FirstCallClose.BookDate__c;
                        if(opp.Signed_Contract_Date__c==null)opp.Signed_Contract_Date__c=FirstCallClose.Signed_Contract_Date__c;
                        isOppUpdate=true;
                        
                    }else{
                        Opp.StageName='Closed Won';
                        Opp.Status__c='Won';
                        if(opp.Book_Date_PQM__c==null)opp.Book_Date_PQM__c=closeWon.BookDate__c;
                        if(opp.Signed_Contract_Date__c==null)opp.Signed_Contract_Date__c=closeWon.Signed_Contract_Date__c;
                        isOppUpdate=true;
                        
                    }
                }else if(closeWon!=null ){
                    Opp.StageName='Closed Won';
                    Opp.Status__c='Won';
                    if(opp.Book_Date_PQM__c==null)opp.Book_Date_PQM__c=closeWon.BookDate__c;
                    if(opp.Signed_Contract_Date__c==null)opp.Signed_Contract_Date__c=closeWon.Signed_Contract_Date__c;
                    isOppUpdate=true;
                }else if(FirstCallClose!=null){
                    Opp.StageName='Closed Won';
                    Opp.Status__c='First Call Close';
                    if(opp.Book_Date_PQM__c==null)opp.Book_Date_PQM__c=FirstCallClose.BookDate__c;
                    if(opp.Signed_Contract_Date__c==null)opp.Signed_Contract_Date__c=FirstCallClose.Signed_Contract_Date__c;
                    isOppUpdate=true;
                    
                }else if(contractedQuote!=null ){
                    Opp.StageName='Contracted';
                    Opp.Status__c='Contracted';
                    if(opp.Signed_Contract_Date__c==null)opp.Signed_Contract_Date__c=contractedQuote.Signed_Contract_Date__c;
                    if(contractedQuote.BookDate__c!=null){
                        opp.Book_Date_PQM__c=contractedQuote.BookDate__c;
                    }
                    isOppUpdate=true;
                    
                }else if(ActiveQuote!=null){
                    if( opp.StageName!='New' &&  opp.StageName!='Active' && opp.StageName!='Follow-Up' ){
                        Opp.StageName='Follow-Up';
                        Opp.Status__c='Follow Up';
                        Opp.Active_Date_PQM__c=Date.today();
                        opp.Set_by_Active_Quote_Note_in_PB__c=true;
                        if(opp.Book_Date_PQM__c==null)opp.Book_Date_PQM__c=ActiveQuote.BookDate__c;
                        if(opp.Signed_Contract_Date__c==null)opp.Signed_Contract_Date__c=ActiveQuote.Signed_Contract_Date__c;
                        
                        isOppUpdate=true;
                    }
                    else if( opp.StageName!='Active' && opp.StageName!='Follow-Up' ){
                        Opp.StageName='Active';
                        Opp.Status__c='Active';
                        Opp.Active_Date_PQM__c=Date.today();
                        opp.Set_by_Active_Quote_Note_in_PB__c=true;
                        isOppUpdate=true;
                    }
                }else if(CancelQuote!=null ){
                    Opp.StageName='Follow-Up';
                    Opp.Status__c='Follow Up';
                    if(opp.Book_Date_PQM__c==null)opp.Book_Date_PQM__c=CancelQuote.BookDate__c;
                    if(opp.Signed_Contract_Date__c==null)opp.Signed_Contract_Date__c=CancelQuote.Signed_Contract_Date__c;
                    
                    isOppUpdate=true;
                }
                
                //EDW Update -- Rekha
                
                if( listEDWOppIds.contains(opp.id))
                {
                    opp.EDW_Last_Modified__c = system.now();
                    //system.debug('@@EDW Update:'+opp.id);
                    // system.debug('@@EDW Update:'+opp.EDW_Last_Modified__c);  
                    isOppUpdate = true;
                }
                
                
                if(isOppUpdate==true){
                    listOpptoUpdate.add(Opp);
                }
                
                /*Trade Commercial Logic
Updated by: Dhruv Javiya
Updated on: 11/03
Reason: Inclusion of Trade Commercial Record Type

*/
            }
            else if(opp.recordType.DeveloperName=='Trade_Comm' || opp.recordType.DeveloperName=='Pro_Lowes'){
                Decimal totalOppAmount=0;
                Decimal totalBACOppAmount=0;
                Decimal totalInvoiceOppAmount=0;
                Boolean isOppUpdate=false;
                Date bookDate,signedcontractdate;
                Integer totalShipped=0,AllQuote=0, totalCanceled = 0, totalBooked = 0;
                for(Quote Q: Opp.Quotes){                   
                    if (Q.Status == 'Canceled')
                        totalCanceled++;      
                    if(Q.Forecasted__c){
                        /* if (Q.Status == 'Canceled')
totalCanceled++;   */// Moving Cancelled Logic ouside Forecasted                     
                        if(Q.Ship_Complete_Date__c!=null){
                            totalShipped++;
                        }
                        if (Q.Status != 'Canceled' && Q.Status != 'Active'&& Q.Status != 'Engineering' && Q.Status != 'Contracted')
                            totalBooked++;     
                        AllQuote++;
                        totalOppAmount+=Q.Customer_Extended_Price__c==null?0:Q.Customer_Extended_Price__c;
                        totalBACOppAmount+=Q.Total_BAC_Price__c==null?0:Q.Total_BAC_Price__c;
                        totalInvoiceOppAmount+=Q.Total_Invoice_Price__c==null?0:Q.Total_Invoice_Price__c;
                        if(bookDate==null)bookDate=Q.BookDate__c;
                        if(signedcontractdate==null)signedcontractdate=Q.Signed_Contract_Date__c;
                        
                        if(opp.Quote_Date__c==null){
                            opp.Quote_Date__c=Date.valueOf(Q.CreatedDate);
                        }
                    }
                }
                // Check all linked quoted Canceled
                if((AllQuote==0||totalBooked==0) && totalcanceled > 0 ) {
                    if(opp.StageName=='Closed Fulfillment'||opp.StageName=='Closed Won'||opp.StageName=='Closed'){
                        opp.StageName='Acquisition';
                        opp.Status__c='Open';
                        isOppUpdate=true;
                    }
                }                
                // Check all linked quoted ship completed
                if(AllQuote!=0 && AllQuote==totalShipped){
                    if(opp.StageName!='Closed Won'){
                        opp.StageName='Closed Won';
                        opp.Status__c='Closed';
                        opp.Project_Closed_Date__c=Date.today();
                        isOppUpdate=true;
                    }
                }
                if(Opp.Total_Price_Quote__c!=totalOppAmount){
                    opp.Total_Price_Quote__c=totalOppAmount;
                    isOppUpdate=true;
                }
                if(Opp.Total_BAC_Price_Quote__c==null || Opp.Total_BAC_Price_Quote__c!=totalBACOppAmount){
                    opp.Total_BAC_Price_Quote__c=totalBACOppAmount;
                    isOppUpdate=true;
                }
                if(Opp.Total_Invoice_Price_Quote__c==null || Opp.Total_Invoice_Price_Quote__c!=totalInvoiceOppAmount){
                    opp.Total_Invoice_Price_Quote__c=totalInvoiceOppAmount;
                    isOppUpdate=true;
                }
                if(signedcontractdate!=null){
                    opp.Signed_Contract_Date__c=signedcontractdate;
                    isOppUpdate=true;
                }
                if(bookDate!=null){
                    opp.Book_Date_PQM__c=bookDate;
                    isOppUpdate=true;
                }
                
                //EDW Update -- Rekha
                
                if (listEDWOppIds.contains(opp.id))
                {
                    opp.EDW_Last_Modified__c = system.now();
                    // system.debug('@@EDW Update:'+opp.id);
                    // system.debug('@@EDW Update:'+opp.EDW_Last_Modified__c);   
                    isOppUpdate = true;
                }              
                
                if(isOppUpdate==true){
                    listOpptoUpdate.add(Opp);
                }
            }
            
           
        }
        if(listOpptoUpdate.size()>0){
            Boolean OppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
            OpportunityTriggerHandler.RUN_TRIGGER=false;
            update listOpptoUpdate; 
            OpportunityTriggerHandler.RUN_TRIGGER=OppTrigger;
        }
       
    }
    
    public static void resetFieldOnQuoteCancel(List<Quote> listQuote){
        for(Quote Q: listQuote){
            
            if(Q.Status=='Canceled' || Q.Status=='Cancelled'){
                Q.BookDate__c=null;
                Q.Signed_Contract_Date__c=null;
                Q.Total_Invoice_Price__c=0;
                Q.Total_BAC_Price__c=0;
                Q.Customer_Extended_Price__c=0;
                Q.Forecasted__c = false;
            }
        }
    }
    public static void tradeCommercialDataUpdate(List<Quote> quotes, Map<Id,Quote> oldMap)
    {
        List<Id> oppIds = new List<Id>();
        
        for(Quote q : quotes)
        {
            if(oldMap==null){
                oppIds.add(Q.OpportunityId);
            }else if( Q.Forecasted__c !=  OldMap.get(Q.Id).Forecasted__c || Q.Status != OldMap.get(Q.Id).Status){
                oppIds.add(Q.OpportunityId);
            }
        }
        System.debug('UAC: oppIds ' + oppIds);
        
        if(oppIds.size()>0){
            
            Map<Id,Opportunity> mapOpps=new Map<Id,Opportunity>([SELECT ID,StageName,Status__c,Book_Date_PQM__c,recordType.DeveloperName,Signed_Contract_Date__c,Quote_Date__c,
                                                                 Appointment_DateTime__c,Total_Price_Quote__c,Total_Invoice_Price_Quote__c,Total_BAC_Price_Quote__c,closeDate 
                                                                 FROM Opportunity Where id in :oppIds]);
            Opportunity opp;
            List<Opportunity> listOpptoUpdate=new List<Opportunity>();
            for(Quote q : quotes){
                
                if(mapOpps.containsKey(Q.OpportunityId)){
                    opp=mapOpps.get(Q.OpportunityId);
                    //Added 'Pro_Lowes' check on a critical issue reported-05/07/2021 by Satheesh.
                    if(opp.recordType.DeveloperName=='Trade_Comm' || opp.recordType.DeveloperName=='Pro_Lowes'){
                        
                        // Set Estimated Book Date On Quote Create
                        if(oldMap==null){
                            q.Estimated_Book_Date__c=opp.closeDate;
                        }
                        
                        // Update Opportunity stage name to Acquisition
                        if(Q.Status=='Contracted' && opp.StageName!='Closed Fulfillment' && opp.StageName!='Closed Won'){
                            Opportunity OppRec=new Opportunity();
                            OppRec.Id=Q.OpportunityId;
                            OppRec.StageName='Acquisition';
                            OppRec.Status__c='Open';
                            listOpptoUpdate.add(OppRec);
                        }// Update Opportunity stage name to Closed Fulfillment
                        else if(Q.Status=='Booked' && opp.StageName!='Closed Won'){
                            Opportunity OppRec=new Opportunity();
                            OppRec.Id=Q.OpportunityId;
                            OppRec.StageName='Closed Fulfillment';
                            OppRec.Status__c='Closed';
                            listOpptoUpdate.add(OppRec);
                        }
                        else if( opp.recordType.DeveloperName=='Pro_Lowes'  && opp.StageName!='Closed Won'
                                && (Q.Status=='Booked' || Q.Status=='Ordered' || Q.Status=='PendingBooked' || Q.Status=='PendingIntegration' || Q.Status=='Pending Order Ack' )){
                                    Opportunity OppRec=new Opportunity();
                                    OppRec.Id=Q.OpportunityId;
                                    OppRec.StageName='Closed Fulfillment';
                                    OppRec.Status__c='Closed';
                                    listOpptoUpdate.add(OppRec);
                                }
                    }
                }
            }
            
            if(listOpptoUpdate.size()>0){
                Boolean OppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
                OpportunityTriggerHandler.RUN_TRIGGER=false;
                update listOpptoUpdate; 
                OpportunityTriggerHandler.RUN_TRIGGER=OppTrigger;
            }
        }
    }
    
    //pallavi to update the YTD Sales when bookedDate is within current fiscal year
    public static void updateYTDonAccount(List<Quote> listQuote,Map<Id,Quote> oldMap){
        //get the current fiscal year details
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        
        Set<String> qtAccId = new Set<String>();
        Set<String> qtOppId = new Set<String>();
        Set<String> associateAccId = new Set<String>();
        Set<String> associateOppId = new Set<String>();
        for(Quote qt : listQuote){
            if(qt.AccountId != null && 
               (oldMap == null || oldMap.get(qt.Id).AccountId != qt.AccountId 
                || oldMap.get(qt.Id).Customer_Extended_Price__c != qt.Customer_Extended_Price__c
                || oldMap.get(qt.Id).BookDate__c != qt.BookDate__c || oldMap.get(qt.Id).status != qt.status))
            {
                qtAccId.add(qt.AccountId);
                if(oldMap != null && oldMap.get(qt.Id).AccountId != null && oldMap.get(qt.Id).AccountId != qt.AccountId){
                    qtAccId.add(oldMap.get(qt.Id).AccountId);
                }
            }
            
            if(qt.OpportunityId != null && 
               (oldMap == null || oldMap.get(qt.Id).OpportunityId != qt.OpportunityId 
                || oldMap.get(qt.Id).Customer_Extended_Price__c != qt.Customer_Extended_Price__c
                || oldMap.get(qt.Id).BookDate__c != qt.BookDate__c))
            {
                qtOppId.add(qt.OpportunityId);
                if(oldMap != null && oldMap.get(qt.Id).OpportunityId != null && oldMap.get(qt.Id).OpportunityId != qt.OpportunityId){
                    qtOppId.add(oldMap.get(qt.Id).OpportunityId);
                    
                }
                if(qt.Opportunity_AccountId__c != null){
                    qtAccId.add(qt.Opportunity_AccountId__c);
                }
            }
        }
        System.debug('@@qtAccIdQT : '+qtAccId);
        // System.debug('@@qtOppIdQT : '+qtOppId);
        //Associate account from Opportunity
        List<Associated_Account__c> associateAccs = [SELECT Id, Associated_Account_Name__c, Opportunity__c FROM Associated_Account__c
                                                     WHERE Opportunity__c =:qtOppId];
        for(Associated_Account__c AA : associateAccs){
            if(AA.Associated_Account_Name__c != null){
                associateAccId.add(AA.Associated_Account_Name__c);
            }
        }
        //get all opportunity related to Associate account
        List<Associated_Account__c> associateAccList = [SELECT Id, Associated_Account_Name__c, Opportunity__c FROM Associated_Account__c
                                                        WHERE Associated_Account_Name__c =:associateAccId AND Associated_Account_Name__r.RecordType.Name != 'Pella Account'];
        Map<String, Set<String>> mapAccOpp = new Map<String, Set<String>>();
        for(Associated_Account__c AA : associateAccList){
            if(AA.Opportunity__c != null){
                associateOppId.add(AA.Opportunity__c);
            }
            if(AA.Associated_Account_Name__c != null){
                if(!mapAccOpp.containsKey(AA.Associated_Account_Name__c)){
                    mapAccOpp.put(AA.Associated_Account_Name__c, new Set<String>());
                }
                mapAccOpp.get(AA.Associated_Account_Name__c).add(AA.Opportunity__c);
            }
            
        }
        //System.debug('@@mapAccOppQT : '+mapAccOpp);
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE (AccountId =:qtAccId OR OpportunityId =:associateOppId)
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name = 'Branch Account'
                                 AND status in ('Booked', 'Ordered')
                                 AND BookDate__c >=: stdt AND BookDate__c <=: eddt];
        //System.debug('@@quoteListQT : '+quoteList.size());
        
        /*Map<String, Integer> mapAccQuoteCount = new Map<String, Integer>();
Integer totalQuote = 0;
List<Quote> allQuoteList = [SELECT Id, AccountId FROM Quote WHERE AccountId =:qtAccId];
for(Quote qt : allQuoteList){
if(!mapAccQuoteCount.containsKey(qt.AccountId)){
mapAccQuoteCount.put(qt.AccountId, 0);
}
totalQuote = mapAccQuoteCount.get(qt.AccountId) + 1;
mapAccQuoteCount.put(qt.AccountId, totalQuote);
}*/
        
        Decimal totalAcc = 0;
        Decimal totalOpp = 0;
        Map<String, Decimal> mapAcct = new Map<String, Decimal>();
        Map<String, Decimal> mapOpp = new Map<String, Decimal>();
        
        for(Quote qt : quoteList){
            if(qtAccId.contains(qt.AccountId)){
                if(!mapAcct.containsKey(qt.AccountId)){
                    mapAcct.put(qt.AccountId, 0);
                }
                totalAcc = mapAcct.get(qt.AccountId) + (qt.Customer_Extended_Price__c == null ? 0 : qt.Customer_Extended_Price__c);
                mapAcct.put(qt.AccountId, totalAcc);
            }
            if(associateOppId.contains(qt.OpportunityId)){
                if(!mapOpp.containsKey(qt.OpportunityId)){
                    mapOpp.put(qt.OpportunityId, 0);
                }
                totalOpp = mapOpp.get(qt.OpportunityId) + (qt.Customer_Extended_Price__c == null ? 0 : qt.Customer_Extended_Price__c);
                mapOpp.put(qt.OpportunityId, totalOpp);
            }
            
        }
        //System.debug('@@mapAcctQT : '+mapAcct);
        //System.debug('@@mapOppQT : '+mapOpp);
        
        List<Account> accList = new List<Account>();
        for(String accId : qtAccId){
            Account acc = new Account();
            acc.Id = accId;
            if(mapAcct.containsKey(accId)){
                acc.YTD_Sales__c = mapAcct.get(accId);
                
            }else{
                acc.YTD_Sales__c = 0;
            }
            
            accList.add(acc);
            //System.debug('@@accYTDQT : '+acc);
            
        }
        if(accList.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update accList; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
        
        accList = new List<Account>();
        for(String accId : mapAccOpp.keySet()){
            Decimal totalYTDAssociate = 0;
            
            
            for(String oppId : mapAccOpp.get(accId)){
                //System.debug('@@oppIdQT : '+oppId);
                // System.debug('@@mapAccOpp.get(accId)QT : '+mapAccOpp.get(accId).size());
                if(mapOpp.containsKey(oppId)){
                    totalYTDAssociate += mapOpp.get(oppId);
                }
            }
            Account acc = new Account();
            acc.Id = accId;
            acc.YTD_Associated_Sales__c = totalYTDAssociate;
            accList.add(acc);
        }
        if(accList.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update accList; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
        
        /*accList = new List<Account>();
for(String accId : qtAccId){
Account acc = new Account();
acc.Id = accId;
acc.YTD_Quotes__c = mapAccQuoteCount.containsKey(accId) ? mapAccQuoteCount.get(accId) : 0; 
accList.add(acc);

}
if(accList.size() > 0){
Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
AccountTriggerHandler.RUN_TRIGGER=false;
update accList; 
AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
}*/
    }
    
    /**
*   @Method:        createSWORecord
*   @Purpose:       Create Service Work Order records
*   @Author:        Dhruv (eVerge)
*   @Date:          03/08/2022
*   @TaskSource:    

*   @Updates:       
*/     
    public static void createSWORecord(List<Quote> listQuote,Map<Id,Quote> oldMap){
        Set<Id> listCreatedQuoteIds=new set<Id>(); // created Quote Ids set
        Set<Id> listOppIds=new set<Id>(); // opportunityIds set 
        set<Id> setBranchFamilyIds=new set<Id>(); // Branch Family Id set
        set<Id> setBranchIds=new set<Id>();// Branch Ids set 
        set<Id> setAvailbleBranchIds=new set<Id>();// available for sWO Branch Ids set
        List<String> opportunityIds =new List<String>(); 
        Map<String,Opportunity> oppIdWiseAccount =new Map<String,Opportunity>();
        
        Set<Id> listQuoteOwnerIds=new set<Id>(); // created Quote Ids set
        for(Quote q : listQuote){// create SWO if order type is 'INSTALLED_SALES' and Status is 'Contracted' 
            if((oldMap==null || (oldMap!=null && oldMap.get(q.Id).Status!=q.Status)) && (q.Status=='Contracted' || q.Status=='Engineering' || q.Status=='Booked' || q.Status=='PendingBooked' || q.Status=='PendingIntegration' || q.Status=='Ordered' || q.Status == 'Pending Order Ack')
               && q.Order_Type__c=='INSTALLED_SALES'){
                listCreatedQuoteIds.add(q.Id);
                listOppIds.add(q.OpportunityId);
            }
            system.debug('Brnach Family:::::::::::'+q.Branch_Family__c);
            system.debug('Brnach :::::::::::'+q.Branch__c);
            // get Branch Family Id from quote
            if(string.isNotBlank(q.Branch_Family__c))
                setBranchFamilyIds.add(q.Branch_Family__c);
            // get Branch Id from quote
            if(string.isNotBlank(q.Branch__c))
                setBranchIds.add(q.Branch__c);
            if( q.OpportunityId!=null)
                opportunityIds.add(q.OpportunityId);
            
            listQuoteOwnerIds.add(q.OwnerId);
        }
        if(listCreatedQuoteIds.size()==0) return;
        
         Map<String,Branch__c> branchMap=new Map<String,Branch__c>();
        // check if branch is available for sWO or not
        for(Branch__c branchList : [Select Id, Name, Is_Available_for_Work_Order__c,Advance_PC_WO_Assignment__c,Default_Retail_PC_receiver__r.RelatedRecordId,Default_Trade_PC_Receiver__r.RelatedRecordId From Branch__c Where Id IN :setBranchIds]){
            if(branchList.Is_Available_for_Work_Order__c){
                 setAvailbleBranchIds.add(String.valueOf(branchList.Id).substring(0,15));
            }
            branchMap.put(String.valueOf(branchList.Id).substring(0,15),branchList);
        }

        map<String, List<String>> BranchFamilyWiseSRMap = new map<String, List<String>>();
        map<Id, ServiceResource> mapUserwiseSR = new map<Id, ServiceResource>();
        Set<Id> setOfUserIds = new Set<Id>();
        map<String, String> mapOfSRwithUser = new map<String, String>();
        
        for(Opportunity opp :[SELECT Id, AccountId,Account.Name,Account.RecordType.DeveloperName,Account.personContactId, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry FROM Opportunity WHERE Id IN :opportunityIds]){
            oppIdWiseAccount.put(opp.Id, opp);
        }
        Map<String,string> salesResorceWisePiesResource=new Map<String,string>();
        //fetch Owner Id Wise Resource
        for(ServiceResource serviceResourceRecs : [SELECT Id, Name,RelatedRecordId,Business_Segment__c,Mapped_Retail_PC__r.RelatedRecordId FROM ServiceResource WHERE IsActive=true and RelatedRecordId =:listQuoteOwnerIds and Mapped_Retail_PC__c!=null ]){
            salesResorceWisePiesResource.put(serviceResourceRecs.RelatedRecordId,serviceResourceRecs.Mapped_Retail_PC__r.RelatedRecordId);
        }
        
        //fetch related Quote Branch and Branch Family which has record type 'Install_OV' Service Resource and Project Cordinator is set to true 
        for(ServiceResource serviceResourceRecs : [SELECT Id, Name,RelatedRecordId,Business_Segment__c, Primary_Branch_Family__c, Branch__r.Branch_Family__c, Project_Coordinator__c FROM  ServiceResource WHERE IsActive=true and  (Primary_Branch_Family__c IN :setBranchFamilyIds or Branch__c IN :setBranchIds) and Project_Coordinator__c = true and RecordType.DeveloperName = 'Install_OV']){
            if(serviceResourceRecs.Primary_Branch_Family__c != null ){
                if(!BranchFamilyWiseSRMap.containsKey(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15))){
                    BranchFamilyWiseSRMap.put(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15),new List<String>());
                }
                BranchFamilyWiseSRMap.get(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15)).add(serviceResourceRecs.RelatedRecordId);
            }else{
                if(!BranchFamilyWiseSRMap.containsKey(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15))){
                    BranchFamilyWiseSRMap.put(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15),new List<String>());
                }
                BranchFamilyWiseSRMap.get(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15)).add(serviceResourceRecs.RelatedRecordId);
                
            }
            mapUserwiseSR.put(serviceResourceRecs.RelatedRecordId, serviceResourceRecs);
            setOfUserIds.add(serviceResourceRecs.RelatedRecordId);
            mapOfSRwithUser.put(serviceResourceRecs.Id,serviceResourceRecs.RelatedRecordId);
        }
        system.debug('setOfUserIds : '+ setOfUserIds);
        //work order count by owner
        Map<String, Decimal> mapCountOfWorkOrderByOwner = new Map<String, Decimal>();
        AggregateResult[] lstWorkOrderByUserCnt = [SELECT count(Id) cntWorkOrder, OwnerId FROM WorkOrder 
                                                   WHERE OwnerId IN : setOfUserIds AND OwnerId != NULL
                                                   GROUP BY OwnerId 
                                                   ORDER BY COUNT(Id) ASC];
        
        system.debug('lstWorkOrderByUserCnt: '+lstWorkOrderByUserCnt);
        List<WorkOrderByUserWrapper> lstWrap = new List<WorkOrderByUserWrapper>();
        set<String> setUserIdCountFound=new set<String>();
        // User's related Work ORder Count 
        for(AggregateResult aggResult : lstWorkOrderByUserCnt)
        {
            WorkOrderByUserWrapper obj = new WorkOrderByUserWrapper();
            obj.UserId = (String)aggResult.get('OwnerId');
            obj.WorkOrderCnt = (Integer)aggResult.get('cntWorkOrder');
            lstWrap.add(obj);
            setUserIdCountFound.add( (String)aggResult.get('OwnerId'));
            //mapCountOfWorkOrderByOwner.put((String)aggResult.get('OwnerId'), (Decimal)aggResult.get('cntWorkOrder'));
        }
        // process for not found count
        for(String userId : setOfUserIds){
            if(!setUserIdCountFound.contains(userId)){
                WorkOrderByUserWrapper obj = new WorkOrderByUserWrapper();
                obj.UserId = userId;
                obj.WorkOrderCnt = 0;
                lstWrap.add(obj);
            }
        }
        system.debug('lstWrap: '+lstWrap);
        
        // Need to  add sorting logic
        
        
        Map<String,String> QuoteWiseSWO=new Map<String,String>(); 
        Map<String,String> OpportunityWiseSWO=new Map<String,String>(); 
        // added logic on 15-03-2022 fetch all Work Type 
        Map<String,String> WOTypeNamewiseId=new Map<String,String>(); 
        for(WorkType WOType :[SELECT Id, Name FROM WorkType]){
            WOTypeNamewiseId.put(WOType.Name, WOType.Id);
        }
        // check existing SWO
        for(WorkOrder WO : [SELECT Id,Quote__c FROM WorkOrder where Quote__c in :listCreatedQuoteIds]){
            QuoteWiseSWO.put(WO.Quote__c,WO.Id);
        }
        Map<String,Opportunity> listSWOWithQuoteBlank=new Map<String,Opportunity>();
        // check existing SWO
        for(Opportunity opp : [SELECT Id,Work_Order__c,Work_Order__r.Quote__c,Work_Order__r.Quote_Number__c FROM Opportunity where Id in :listOppIds]){
            if(opp.Work_Order__c!=null){
                OpportunityWiseSWO.put(opp.Id,opp.Work_Order__c);
                if(opp.Work_Order__r.Quote__c==null){
                    listSWOWithQuoteBlank.put(opp.Work_Order__r.Quote_Number__c,opp);
                }
            }
        }
        // create work Order  if quote status is contracted and  order type is Install OV
        Map<String,WorkOrder> QuoteWiseSWOToCreate=new Map<String,WorkOrder>();
        for(Quote q : listQuote){
            if((oldMap==null || (oldMap!=null && oldMap.get(q.Id).Status!=q.Status)) && (q.Status=='Contracted' || q.Status=='Engineering' || q.Status=='Booked' || q.Status=='PendingBooked' || q.Status=='PendingIntegration' || q.Status=='Ordered' || q.Status == 'Pending Order Ack') && q.Order_Type__c=='INSTALLED_SALES' && !OpportunityWiseSWO.containsKey(q.OpportunityID) && setAvailbleBranchIds.contains(Q.Branch__c) ){
                WorkOrder WO=new WorkOrder();
                WO.Branch__c=Q.Branch__c;
                WO.Quote__c=Q.Id;
                
                WO.Subject=Q.Business_Segment__c+'-'+Q.Name;
                //WO.Business_Segment__c=Q.Business_Segment__c;
                if(oppIdWiseAccount.containsKey(q.opportunityId)){
                    WO.AccountId=oppIdWiseAccount.get(q.opportunityId).AccountId;
                    WO.Subject=Q.PO_Number__c+'-'+oppIdWiseAccount.get(q.opportunityId).Account.Name;
                    if(oppIdWiseAccount.get(q.opportunityId).Account.RecordType.DeveloperName=='PersonAccount'){
                        WO.ContactId=oppIdWiseAccount.get(q.opportunityId).Account.PersonContactId;
                    }
                }
                WO.City = q.ProjectOwner_City__c;
                WO.Country = q.ProjectOwner_Country__c;
                WO.State = q.ProjectOwner_State__c;
                WO.Street = q.ProjectOwner_Street__c;
                WO.PostalCode = q.ProjectOwner_Zip__c;
                
                WO.Status='New';
                // added on 15-03-2022 for update Work Type
                if(q.Business_Segment__c == 'Trade' && (q.Market_Segment__c == 'S0' || q.Market_Segment__c == 'S1A' || q.Market_Segment__c == 'S1B' || q.Market_Segment__c == 'S1C' || q.Market_Segment__c == 'S2' || q.Market_Segment__c == 'S3' )){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('New Construction')?WOTypeNamewiseId.get('New Construction'):null;
                }else if(q.Business_Segment__c == 'Trade' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Trade R/R')?WOTypeNamewiseId.get('Trade R/R'):null;
                }else if(q.Business_Segment__c == 'Retail' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Retail')?WOTypeNamewiseId.get('Retail'):null;
                }else if(q.Business_Segment__c == 'Replacement' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Retail')?WOTypeNamewiseId.get('Retail'):null;
                }else if(q.Business_Segment__c == 'Commercial' && (q.Market_Segment__c == 'MF' || q.Market_Segment__c == 'MR' || q.Market_Segment__c == 'N2' || q.Market_Segment__c == 'NR')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Commercial')?WOTypeNamewiseId.get('Commercial'):null;
                }
                lstWrap.sort();
                
                
                // Check If Branch Has Advance Logic
                if(branchMap.ContainsKey(Q.Branch__c) && branchMap.get(Q.Branch__c).Advance_PC_WO_Assignment__c == true){
                     // check business segment
                    if(q.Business_Segment__c == 'Replacement' || q.Business_Segment__c == 'Retail' ){
                        //Assign the WO to the PC mapped to Quote’s Owner as per the setup in #3 above
                        if(salesResorceWisePiesResource.containsKey(q.OwnerId)){
                            WO.OwnerId=salesResorceWisePiesResource.get(q.OwnerId);
                            system.debug('@@PC mapped to Quote’s Owner '+ q.OwnerId);
                        }
                    }
                        
                    // get Resource who has business Segment same
                    if(WO.OwnerId == null && BranchFamilyWiseSRMap.containsKey(Q.Branch_Family__c)){
                        for(WorkOrderByUserWrapper wou : lstWrap){
                            system.debug('@@wou.userId :: '+wou.userId);
                            if(BranchFamilyWiseSRMap.get(Q.Branch_Family__c).contains(wou.userId) && mapUserwiseSR.containsKey(wou.userId) && mapUserwiseSR.get(wou.userId).Business_Segment__c == q.Business_Segment__c ){
                                WO.OwnerId=wou.userId;
                                wou.WorkOrderCnt++;
                                 system.debug('@@ business Segment same '+ q.OwnerId);
                                break;
                            }
                        }
                    }
                    // If still not found the take default PC User
                    if( WO.OwnerId == null ){
                        
                        //If there are still no matches, use Branch’s ‘Default Replacement PC Receiver’ (lookup on branch)
                        if(q.Business_Segment__c == 'Replacement' || q.Business_Segment__c == 'Retail' ){
                            WO.OwnerId=branchMap.get(Q.Branch__c).Default_Retail_PC_receiver__r.RelatedRecordId;
                             system.debug('@@ default replacement '+ q.OwnerId);
                        }
                        
                        //If there are no matches, use Branch’s ‘Default Trade PC Receiver’ (lookup on branch)
                        if(q.Business_Segment__c == 'Trade' ){
                            WO.OwnerId=branchMap.get(Q.Branch__c).Default_Trade_PC_Receiver__r.RelatedRecordId;
                            system.debug('@@ default trade '+ q.OwnerId);
                        }
                    }
                    
                }else{
                    // Owner Logic need to implement
                    if(BranchFamilyWiseSRMap.containsKey(Q.Branch_Family__c)){
                        for(WorkOrderByUserWrapper wou : lstWrap){
                            system.debug('@@condition::::::::::'+BranchFamilyWiseSRMap.get(Q.Branch_Family__c).contains(wou.userId));
                            if(BranchFamilyWiseSRMap.get(Q.Branch_Family__c).contains(wou.userId)){
                                WO.OwnerId=wou.userId;
                                wou.WorkOrderCnt++;
                                
                                break;
                            }
                        }
                        if( WO.OwnerId == null ){
                            WO.OwnerId=BranchFamilyWiseSRMap.get(Q.Branch_Family__c)[0];
                        }
                    }
                }
                QuoteWiseSWOToCreate.put(q.OpportunityId,WO);
            }
        }
        insert QuoteWiseSWOToCreate.values();
        
        Map<String,WorkOrder> mapWOToUpdate=new Map<String,WorkOrder>();
        // update created Work order in opportunity and quote
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        for(Quote qId : listQuote){
            if( QuoteWiseSWOToCreate.containsKey(qId.OpportunityId)){
                Opportunity opp = new Opportunity();
                opp.Id = qId.OpportunityId;
                opp.Work_Order__c = QuoteWiseSWOToCreate.get(qId.OpportunityId).Id;
                qId.Work_Order__c= QuoteWiseSWOToCreate.get(qId.OpportunityId).Id;
                qId.Primary__c=true;
                oppUpdateList.add(opp);
            }
            else if(OpportunityWiseSWO.containsKey(qId.OpportunityId)){
                qId.Work_Order__c= OpportunityWiseSWO.get(qId.OpportunityId);
                
                if(qId.Quote_Number_PQM__c!=null && listSWOWithQuoteBlank.containsKey(qId.Quote_Number_PQM__c)){
                    WorkOrder WO=new WorkOrder();
                    WO.Id=listSWOWithQuoteBlank.get(qId.Quote_Number_PQM__c).Work_Order__c;
                    WO.Quote__c=qId.Id;
                    qId.Primary__c=true;
                    WO.Subject=QId.PO_Number__c+'-'+oppIdWiseAccount.get(qId.opportunityId).Account.Name;
                    mapWOToUpdate.put(WO.Id,WO);
                }
                //qId.Primary__c=true;
            }
            
        }
        // update workorder Id on Opportunity 
        update  oppUpdateList;
        
        if(mapWOToUpdate.size()>0){
            boolean flag=WorkOrderTriggerHandler.RUN_TRIGGER;
            WorkOrderTriggerHandler.RUN_TRIGGER=false;
            update mapWOToUpdate.values();
            WorkOrderTriggerHandler.RUN_TRIGGER=flag;
        }
        // Update QuotesToUpdate;
    }
          
          
    /**
    *   @Method:        updateSWOPrimaryQuote
    *   @Purpose:       To update Work Order Primary Quote
    *   @Author:        Dhruv (eVerge)
    *   @Date:          03/08/2022
    *   @TaskSource:    
    
    *   @Updates:       
    */     
    public static void updateSWOPrimaryQuote(List<Quote> listQuote,Map<Id,Quote> oldMap){
        Map<String,WorkOrder> mapQuoteWiseWO=new Map<String,WorkOrder>();
        for(Quote q : listQuote){// update related WO to Quote
            if((oldMap==null || (oldMap!=null && oldMap.get(q.Id).Status!=q.Status)) && q.Primary__c==true && q.Work_Order__c!=null && (q.Status=='Contracted' || q.Status=='Engineering' || q.Status=='Booked' || q.Status=='PendingBooked' || q.Status=='PendingIntegration' || q.Status=='Ordered' || q.Status == 'Pending Order Ack') && q.Order_Type__c=='INSTALLED_SALES'){
                WorkOrder WO=new WorkOrder();
                WO.Id=q.Work_Order__c;
                WO.Quote__c=Q.Id;
                mapQuoteWiseWO.put(WO.Id,WO);
            }
        }
        update mapQuoteWiseWO.values();
    }
    
    public static void createSalesQuotaAssociationForQuote(List<Quote> quoteList, Map<Id, Quote> oldMap) {
        List<Sales_Quota_Associated_Quote__c> newAssociations = new List<Sales_Quota_Associated_Quote__c>(); 

        for(Quote quote : quoteList) {
            Opportunity opportunity = [SELECT Id, CloseDate, OwnerId FROM Opportunity WHERE Id =: quote.OpportunityId];
			
            List<Sales_Quota__c> salesQuotas = quote.Status=='Booked' || quote.Status=='Ordered' ? 
                [SELECT Id FROM Sales_Quota__c WHERE Sales_Plan__r.OwnerId =: opportunity.OwnerId AND Quota_Period_Start_Date__c <=: quote.BookDate__c AND Quota_Period_End_Date__c >=: quote.BookDate__c]
                : [SELECT Id FROM Sales_Quota__c WHERE Sales_Plan__r.OwnerId =: opportunity.OwnerId AND Quota_Period_Start_Date__c <=: opportunity.CloseDate AND Quota_Period_End_Date__c >=: opportunity.CloseDate];
    
			if (salesQuotas.size() > 0) {
				Sales_Quota_Associated_Quote__c newAssociation = new Sales_Quota_Associated_Quote__c (
                	name = 'Associated Quote #' + quote.Quote_Number_PQM__c,
                    Quote__c = quote.Id,
                    Sales_Quota__c = salesQuotas[0].Id
                );
    
                newAssociations.add(newAssociation);
            }
        }

        if (newAssociations.size() > 0) {
            insert newAssociations;
        }
    }
    
    public static void updateSalesQuotaAssociationForQuote(List<Quote> quoteList, Map<Id, Quote> oldMap) {
        List<Sales_Quota_Associated_Quote__c> updatedAssociations = new List<Sales_Quota_Associated_Quote__c>();
		List<Sales_Quota_Associated_Quote__c> newAssociations = new List<Sales_Quota_Associated_Quote__c>(); 

        for(Quote quote : quoteList) {
            Opportunity opportunity = [SELECT Id, CloseDate, OwnerId FROM Opportunity WHERE Id =: quote.OpportunityId];

            if(oldMap != null && (oldMap.get(quote.Id).Status != quote.Status || oldMap.get(quote.Id).BookDate__c != quote.BookDate__c || oldMap.get(quote.Id).Estimated_Book_Date__c != quote.Estimated_Book_Date__c)) {
                List<Sales_Quota_Associated_Quote__c> existingAssociations = [SELECT Id, Sales_Quota__r.Id, Quote__c FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quote.Id];
                List<Sales_Quota__c> salesQuotas = (quote.Status =='Booked' || quote.Status =='Ordered') ? 
                    [SELECT Id FROM Sales_Quota__c WHERE Sales_Plan__r.OwnerId =: opportunity.OwnerId AND Quota_Period_Start_Date__c <=: quote.BookDate__c AND Quota_Period_End_Date__c >=: quote.BookDate__c]
                    : [SELECT Id FROM Sales_Quota__c WHERE Sales_Plan__r.OwnerId =: opportunity.OwnerId AND Quota_Period_Start_Date__c <=: opportunity.CloseDate AND Quota_Period_End_Date__c >=: opportunity.CloseDate];

                if (existingAssociations.size() > 0 && salesQuotas.size() > 0 && salesQuotas[0].Id != existingAssociations[0].Sales_Quota__r.Id) {
                    existingAssociations[0].Sales_Quota__c = salesQuotas[0].Id;
    
                    updatedAssociations.add(existingAssociations[0]);
                } else if (existingAssociations.size() <= 0 && salesQuotas.size() > 0) {
                    Sales_Quota_Associated_Quote__c newAssociation = new Sales_Quota_Associated_Quote__c (
                        name = 'Associated Quote #' + quote.Quote_Number_PQM__c,
                        Quote__c = quote.Id,
                        Sales_Quota__c = salesQuotas[0].Id
                    );
        
                    newAssociations.add(newAssociation);
                }
            }
        }

        if (updatedAssociations.size() > 0) {
            update updatedAssociations;
        }
        
         if (newAssociations.size() > 0) {
            insert newAssociations;
        }
    }
    
    public static void updatePYTDonAccount(List<Quote> quoteList,Map<Id,Quote> oldMap){
        Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date previousYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        Date previousYearEndDate = system.today().addYears(-1);

        Set<String> quoteAccountIdSet = new Set<String>();

        for(Quote quote : quoteList){
            Boolean quoteFieldsChanged = (oldMap == null 
                || oldMap.get(quote.Id).AccountId != quote.AccountId 
                || oldMap.get(quote.Id).Customer_Extended_Price__c != quote.Customer_Extended_Price__c 
                || oldMap.get(quote.Id).BookDate__c != quote.BookDate__c 
                || oldMap.get(quote.Id).status != quote.status);

            if(quote.AccountId != null && quoteFieldsChanged)
            {
                quoteAccountIdSet.add(quote.AccountId);
                if(oldMap != null && oldMap.get(quote.Id).AccountId != null && oldMap.get(quote.Id).AccountId != quote.AccountId){
                    quoteAccountIdSet.add(oldMap.get(quote.Id).AccountId);
                }
            }
        }
        
        List<Quote> quotesTiedToAccountsList = [
            SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId 
            FROM Quote
            WHERE AccountId =: quoteAccountIdSet
            AND BookDate__c >=: previousYearStartDate 
            AND BookDate__c <=: previousYearEndDate
            AND Opportunity.RecordType.Name = 'Trade_Comm'
            AND Account.RecordType.Name = 'Branch Account'
            AND Status in ('Booked', 'Ordered')
        ];

        Decimal priorYearSalesTotal = 0;
 		Map<String, Decimal> accountTotalMap = new Map<String, Decimal>();

        for(Quote quote : quotesTiedToAccountsList){
            if(!accountTotalMap.containsKey(quote.AccountId)){
                accountTotalMap.put(quote.AccountId, 0);
            }               
            priorYearSalesTotal = accountTotalMap.get(quote.AccountId) + (quote.Customer_Extended_Price__c == null ? 0 : quote.Customer_Extended_Price__c);
            
            accountTotalMap.put(quote.AccountId, priorYearSalesTotal);         
        }
        
        List<Account> updatedAccountList = new List<Account>();
        for(String accountId : quoteAccountIdSet){
            Account newAccount = new Account();
            newAccount.Id = accountId;
            newAccount.PYTD_Sales__c = accountTotalMap.containsKey(accountId) ? accountTotalMap.get(accountId) : 0;
                        
            updatedAccountList.add(newAccount);            
        }

        if(updatedAccountList.size() > 0){
            Boolean RunAccountTriggerEnabled = AccountTriggerHandler.RUN_TRIGGER;

            AccountTriggerHandler.RUN_TRIGGER = false;
            update updatedAccountList; 
            AccountTriggerHandler.RUN_TRIGGER = RunAccountTriggerEnabled;
        }
    }

    public static void removeSalesQuotaAssociations(List<Quote> quoteList, Map<Id,Quote> oldMap){
        Set<Id> quoteIdSet = new Set<Id>();
        for (Quote quote : quoteList) {
            quoteIdSet.add(quote.Id);
        }
        system.debug('quoteIdSet: ' + quoteIdSet);
        List<Sales_Quota_Associated_Quote__c> quotaAssociationsToDelete = [SELECT Id FROM Sales_Quota_Associated_Quote__c WHERE Quote__r.Id =: quoteIdSet];
        system.debug('quotaAssociationsToDelete: ' + quotaAssociationsToDelete);
        if (quotaAssociationsToDelete.size() > 0) {
            delete quotaAssociationsToDelete;
        }
    }
    
    Public Class WorkOrderByUserWrapper implements Comparable{
        public String UserId;
        Public Integer WorkOrderCnt;
        
        public Integer compareTo(Object objToCompare) {
            WorkOrderByUserWrapper compareToEmp = (WorkOrderByUserWrapper)objToCompare;
            if (WorkOrderCnt == compareToEmp.WorkOrderCnt) return 0;
            if (WorkOrderCnt > compareToEmp.WorkOrderCnt) return 1;
            return -1;     
        }
    }
}