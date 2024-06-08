public without sharing class NAOpportunityUpdateBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(system.label.NAOpportunityUpdateQuery);
        
    }
    
    public void execute(Database.BatchableContext BC, List<quote> quotes){
        
        List<String> listOppIds=new List<String>();
        for(Quote q : quotes){
            
            listOppIds.add(q.opportunityId);
        }
        
        
        List<Opportunity> listOpptoUpdate=new List<Opportunity>();
        List<Opportunity> listOpp=[SELECT ID,StageName,Status__c,Project_Closed_Date__c,Book_Date_PQM__c,recordType.DeveloperName,Signed_Contract_Date__c,Quote_Date__c,Appointment_DateTime__c,Total_Price_Quote__c,Total_Invoice_Price_Quote__c,Total_BAC_Price_Quote__c,(SELECT Id,Forecasted__c,Status,BookDate__c,Signed_Contract_Date__c,Customer_Extended_Price__c,Total_BAC_Price__c,Total_Invoice_Price__c,OpportunityId,Createddate,lastmodifieddate,Ship_Complete_Date__c  FRom Quotes order by lastmodifieddate desc) 
                                   FROM Opportunity Where id in :listOppIds];
        // system.debug('@@'+listOpp.size());
        for(Opportunity Opp : listOpp){
            if(opp.recordType.DeveloperName=='Trade_Comm' || opp.recordType.DeveloperName=='Pro_Lowes'){
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
                    
                    // Update Opportunity stage name to Acquisition
                    if(Q.Status=='Contracted' && opp.StageName!='Closed Fulfillment' && opp.StageName!='Closed Won'){
                        opp.StageName='Acquisition';
                        opp.Status__c='Open';
                        isOppUpdate=true;
                    }// Update Opportunity stage name to Closed Fulfillment
                    else if((Q.Status=='Booked'  ) && opp.StageName!='Closed Won'){
                        opp.StageName='Closed Fulfillment';
                        opp.Status__c='Closed';
                        isOppUpdate=true;
                    } else if( opp.recordType.DeveloperName=='Pro_Lowes'  && opp.StageName!='Closed Won'
                              && (Q.Status=='Booked' || Q.Status=='Ordered' || Q.Status=='PendingBooked' || Q.Status=='PendingIntegration' || Q.Status=='Pending Order Ack' )){
                                  opp.StageName='Closed Fulfillment';
                                  opp.Status__c='Closed';
                                  isOppUpdate=true;
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
                
                
                
                if(isOppUpdate==true){
                    listOpptoUpdate.add(Opp);
                }
            }
        }
        system.debug(JSON.serialize(listOpptoUpdate));
        system.debug(listOpptoUpdate.size());
        
        
        if(listOpptoUpdate.size()>0){
            Boolean OppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
            OpportunityTriggerHandler.RUN_TRIGGER=false;
            update listOpptoUpdate; 
            OpportunityTriggerHandler.RUN_TRIGGER=OppTrigger;
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}