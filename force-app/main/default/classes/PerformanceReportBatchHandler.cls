public class PerformanceReportBatchHandler { 
       
	public final static Date baseDate=Date.newInstance(2019, 12, 1);
    
	public static Map<String,ReportResult> getResultData(List<Id> listOppIds){
        Date CurrentYearStarDate=baseDate.addDays(364*(baseDate.daysBetween(Date.today())/364));
        Date CurrentYearEndDate=CurrentYearStarDate.addDays(363);
        dateTime d=DateTime.newInstance(Date.valueOf(CurrentYearEndDate).year(), 11, 30);
        String dayOfWeek = d.format('EEEE');
        if(dayOfWeek=='Saturday'){
            CurrentYearStarDate=CurrentYearStarDate.addDays(-7);
        }
        Date PrevYearStarDate=CurrentYearStarDate.addDays(-364);
        Date PrevYearEndDate=CurrentYearStarDate.addDays(-1);
        d=DateTime.newInstance(Date.valueOf(PrevYearEndDate).year(), 11, 30);
        dayOfWeek = d.format('EEEE');
        if(dayOfWeek=='Saturday'){
            PrevYearStarDate=PrevYearStarDate.addDays(-7);
        } 
        
        // Provide YOY comparisons
        CurrentYearEndDate=Date.today();
        PrevYearEndDate=PrevYearStarDate.addDays(CurrentYearStarDate.daysBetween(CurrentYearEndDate));
        CurrentYearEndDate=Date.today().addDays(1);
        
        Date TodayMinus90Days=Date.today().addDays(-90) ;
        DateTime TodayDate=DateTime.newInstance(Date.today(),Time.newInstance(0,0,0,0));
        
        Date TodayMinus454Days=Date.today().addDays(-455);
        DateTime TodayMinus364Days=DateTime.newInstance(Date.today().addDays(-364),Time.newInstance(23,59,59,0));
        
        Date TodayMinus12Months=Date.today().addDays(-365) ;
        Date TodayMinus24Months=Date.today().addDays(-730);
        
        system.debug('@@getResultData step 1@@:: '+DateTime.now());
        system.debug('CurrentYearStarDate :: '+CurrentYearStarDate);
        system.debug('CurrentYearEndDate :: '+CurrentYearEndDate);
        system.debug('PrevYearStarDate :: '+PrevYearStarDate);
        system.debug('CurrentYearStarDate :: '+PrevYearEndDate);
        
        //Gross Opps
        List<Opportunity> listOpportunity=[SELECT ID,Createddate,Account_Branch_Profile__c,Account_Branch_Profile__r.Branch__c,Appointment_to_Booking__c,ALT_Days_from_Create_to_Appointment__c,
                                           Account_Branch_Profile__r.Branch__r.Name,Account_Branch_Profile__r.Branch__r.Branch_Number__c,
                                           Zone__c,Zone__r.ParentTerritoryId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.Name,
                                           Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Response_Channel__c, Account.Customer_Type__c,
                                           Status__c,StageName,Appointment_DateTime__c,Book_Date_PQM__c,Total_BO_price_quotes__c,Total_BAC_Price_Quote__c,Signed_Contract_Date__c
                                           FROM Opportunity Where Id = :listOppIds 
                                           and RecordType.DeveloperName = 'Replacement'
                                           and( (Createddate>= :PrevYearStarDate AND Createddate<= :CurrentYearEndDate)
                                               OR 
                                               ((Createddate> :TodayMinus90Days AND Createddate<= :TodayDate) OR ( Createddate> :TodayMinus454Days AND Createddate<= :TodayMinus364Days))
                                               OR 
                                               (Signed_Contract_Date__c>= :PrevYearStarDate AND Signed_Contract_Date__c<= :CurrentYearEndDate)
                                               OR
                                               (Book_Date_PQM__c>= :PrevYearStarDate AND Book_Date_PQM__c<= :CurrentYearEndDate)
                                               OR
                                               ((Createddate> :TodayMinus12Months AND Createddate<= :TodayDate) OR ( Createddate> :TodayMinus24Months AND Createddate<= :TodayMinus12Months))
                                           )
                                           order by Zone__r.ParentTerritory.Branch__r.Branch_Number__c ];
        
        /*Map<String,List<Opportunity>> branchWiseThisYearOpp=new Map<String,List<Opportunity>>();
Map<String,List<Opportunity>> branchWisePrevYearOpp=new Map<String,List<Opportunity>>();*/
        Map<String,Integer> branchWiseThisYearOppCnt=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearOppCnt=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearAOROpps=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearAOROpps=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearBranchGen=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearBranchGen=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearSelfGen=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearSelfGen=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearNewProspects=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearNewProspects=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearCancelled=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearCancelled=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearTransferred=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearTransferred=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearInvCan=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearInvCan=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearInv=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearInv=new Map<String,Integer>();      
        
        Map<String,Integer> branchWiseThisYearALT=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearALT=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearALTTotal=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearALTTotal=new Map<String,Integer>();      
        
        Map<String,Integer> branchWiseThisYearAB=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearAB=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearABTotal=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearABTotal=new Map<String,Integer>();      
        
        //Count Quote 
        Map<String,Integer> branchWiseThisYearQuoCnt=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearQuoCnt=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearContracted=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearContracted=new Map<String,Integer>();
        
        Map<String,Decimal> branchWiseThisYearContractedTotalPrce=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearContractedTotalPrce=new Map<String,Decimal>();
        
        Map<String,Integer> branchWiseThisYearBookQuoCnt=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearBookQuoCnt=new Map<String,Integer>();
        
        Map<String,Decimal> branchWiseThisYearBranchBookings=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearBranchBookings=new Map<String,Decimal>();
        
        Map<String,Decimal> branchWiseThisYearBACBookings=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearBACBookings=new Map<String,Decimal>();
        
        Map<String,Decimal> branchWiseThisYearBACShipments=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearBACShipments=new Map<String,Decimal>();
        
        
        Map<String,Integer> ThisYearR90GCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearR90GCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCTotalOpp=new Map<String,Integer>();  
        
        Map<String,Integer> ThisYearR90GCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCStageClosedWonTotalOpp=new Map<String,Integer>();  
        
        Map<String,Decimal> ThisYearR90GCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearR90GCTotalPrice=new Map<String,Decimal>();  
        
        
        
        Map<String,Integer> ThisYearR12GCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearR12GCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCTotalOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearR12GCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCStageClosedWonTotalOpp=new Map<String,Integer>(); 
        
        Map<String,Decimal> ThisYearR12GCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearR12GCTotalPrice=new Map<String,Decimal>();  
        
        Map<String,Integer> ThisYearR90GCFCCOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCFCCOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearR90GCFCCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCFCCTotalOpp=new Map<String,Integer>(); 
        
        
        Map<String,Integer> ThisYearGCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearGCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCTotalOpp=new Map<String,Integer>();  
        
        Map<String,Integer> ThisYearGCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCStageClosedWonTotalOpp=new Map<String,Integer>();  
        
        Map<String,Decimal> ThisYearGCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearGCTotalPrice=new Map<String,Decimal>();  
        
        Map<String,Integer> ThisYearGCFCCOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCFCCOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearGCFCCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCFCCTotalOpp=new Map<String,Integer>(); 
        
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) Start
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                           Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c BranchNumber,
                                           Opportunity.Zone__r.ParentTerritory.Branch__r.Name BranchName
                                           FROM Quote 
                                           WHERE OpportunityId = :listOppIds and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                           and  (BookDate__c>= :PrevYearStarDate AND BookDate__c<= :PrevYearEndDate)
                                           and Status in ('Booked', 'Ordered', 'PendingBooked')
                                           and Forecasted__c=true
                                           Group By Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Opportunity.Zone__r.ParentTerritory.Branch__r.Name]) 
        {
            branchWisePrevYearBranchBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPricePQM')==null?0:(Decimal) ar.get('TotalPricePQM'));
            branchWisePrevYearBACBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPriceBAC')==null?0:(Decimal) ar.get('TotalPriceBAC'));
        }
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                   Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c BranchNumber,
                                   Opportunity.Zone__r.ParentTerritory.Branch__r.Name BranchName
                                   FROM Quote 
                                   WHERE OpportunityId = :listOppIds and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                   and  (BookDate__c>= :CurrentYearStarDate AND BookDate__c<= :CurrentYearEndDate)
                                   and Status in ('Booked', 'Ordered', 'PendingBooked')
                                   and Forecasted__c=true
                                   Group By Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Opportunity.Zone__r.ParentTerritory.Branch__r.Name]) 
        {
            branchWiseThisYearBranchBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPricePQM')==null?0:(Decimal) ar.get('TotalPricePQM'));
            branchWiseThisYearBACBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPriceBAC')==null?0:(Decimal) ar.get('TotalPriceBAC'));
        }
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) End
        
        for(Opportunity opp: listOpportunity){
        
            if(opp.Createddate>= PrevYearStarDate && opp.Createddate<= CurrentYearEndDate){
                String branchName='';
                if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                    branchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                }
                
                // previous year Data
                if(Opp.Createddate<CurrentYearStarDate){
                    if( opp.Createddate<= PrevYearEndDate){
                        if(!branchWisePrevYearOppCnt.containsKey(branchName)){
                            branchWisePrevYearOppCnt.put(branchName,0);
                        }
                        branchWisePrevYearOppCnt.put(branchName,branchWisePrevYearOppCnt.get(branchName)+1);
                        
                        //AOR Opps
                        if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                            if(!branchWisePrevYearAOROpps.containsKey(branchName)){
                                branchWisePrevYearAOROpps.put(branchName,0);
                            }
                            branchWisePrevYearAOROpps.put(branchName,branchWisePrevYearAOROpps.get(branchName)+1);
                        }else if(opp.Response_Channel__c=='Branch Gen'){
                            if(!branchWisePrevYearBranchGen.containsKey(branchName)){
                                branchWisePrevYearBranchGen.put(branchName,0);
                            }
                            branchWisePrevYearBranchGen.put(branchName,branchWisePrevYearBranchGen.get(branchName)+1);
                        }else if(opp.Response_Channel__c=='Self Gen'){
                            if(!branchWisePrevYearSelfGen.containsKey(branchName)){
                                branchWisePrevYearSelfGen.put(branchName,0);
                            }
                            branchWisePrevYearSelfGen.put(branchName,branchWisePrevYearSelfGen.get(branchName)+1);
                        }
                        if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                            if(!branchWisePrevYearNewProspects.containsKey(branchName)){
                                branchWisePrevYearNewProspects.put(branchName,0);
                            }
                            branchWisePrevYearNewProspects.put(branchName,branchWisePrevYearNewProspects.get(branchName)+1);
                        }
                        if(opp.Status__c=='Canceled'){
                            if(!branchWisePrevYearCancelled.containsKey(branchName)){
                                branchWisePrevYearCancelled.put(branchName,0);
                            }
                            branchWisePrevYearCancelled.put(branchName,branchWisePrevYearCancelled.get(branchName)+1);
                        }
                        if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                            if(!branchWisePrevYearTransferred.containsKey(branchName)){
                                branchWisePrevYearTransferred.put(branchName,0);
                            }
                            branchWisePrevYearTransferred.put(branchName,branchWisePrevYearTransferred.get(branchName)+1);
                        }
                        //if(opp.StageName=='Closed')
                        {
                            if(!branchWisePrevYearInvCan.containsKey(branchName)){
                                branchWisePrevYearInvCan.put(branchName,0);
                            }
                            branchWisePrevYearInvCan.put(branchName,branchWisePrevYearInvCan.get(branchName)+1);
                            if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                                if(!branchWisePrevYearInv.containsKey(branchName)){
                                    branchWisePrevYearInv.put(branchName,0);
                                }
                                branchWisePrevYearInv.put(branchName,branchWisePrevYearInv.get(branchName)+1);
                            }                    
                        }
                        if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                              opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                           && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                               if(opp.Appointment_DateTime__c!=null){
                                   
                                   if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                       
                                       if(!branchWisePrevYearALTTotal.containsKey(branchName)){
                                           branchWisePrevYearALTTotal.put(branchName,0);
                                       }
                                       branchWisePrevYearALTTotal.put(branchName,branchWisePrevYearALTTotal.get(branchName)+1);
                                       if(!branchWisePrevYearALT.containsKey(branchName)){
                                           branchWisePrevYearALT.put(branchName,0);
                                       }
                                       branchWisePrevYearALT.put(branchName,branchWisePrevYearALT.get(branchName)+Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c));
                                   } 
                               }
                           }
                        //Appointment to Book
                        if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                            if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                                
                                if(!branchWisePrevYearABTotal.containsKey(branchName)){
                                    branchWisePrevYearABTotal.put(branchName,0);
                                }
                                branchWisePrevYearABTotal.put(branchName,branchWisePrevYearABTotal.get(branchName)+1);
                                if(!branchWisePrevYearAB.containsKey(branchName)){
                                    branchWisePrevYearAB.put(branchName,0);
                                }
                                branchWisePrevYearAB.put(branchName,branchWisePrevYearAB.get(branchName)+Integer.valueOf(opp.Appointment_to_Booking__c));
                            }
                        }
                        
                        // New logic added on 22-04
                        if(!PrevYearGCTotalOpp.containsKey(branchName)){
                            PrevYearGCTotalOpp.put(branchName,0);
                        }     
                        PrevYearGCTotalOpp.put(branchName,PrevYearGCTotalOpp.get(branchName)+1);
                        
                        if(opp.StageName=='Closed Won'){
                             if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c>= PrevYearStarDate && opp.Book_Date_PQM__c<= PrevYearEndDate)){
                                if(!PrevYearGCTotalPrice.containsKey(branchName)){
                                    PrevYearGCTotalPrice.put(branchName,0);
                                }     
                                 PrevYearGCTotalPrice.put(branchName,PrevYearGCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                                 if(!PrevYearGCStageClosedWonTotalOpp.containsKey(branchName)){
                                     PrevYearGCStageClosedWonTotalOpp.put(branchName,0);
                                 }     
                                 PrevYearGCStageClosedWonTotalOpp.put(branchName,PrevYearGCStageClosedWonTotalOpp.get(branchName)+1);
                                 
                                if(opp.Book_Date_PQM__c!=null){
                                    if(opp.Status__c=='First Call Close'){ 
                                        if(!PrevYearGCFCCOpp.containsKey(branchName)){
                                            PrevYearGCFCCOpp.put(branchName,0);
                                        }     
                                        PrevYearGCFCCOpp.put(branchName,PrevYearGCFCCOpp.get(branchName)+1);
                                    }
                                    if(!PrevYearGCFCCTotalOpp.containsKey(branchName)){
                                        PrevYearGCFCCTotalOpp.put(branchName,0);
                                    }     
                                    PrevYearGCFCCTotalOpp.put(branchName,PrevYearGCFCCTotalOpp.get(branchName)+1);
                                }
                                if(opp.Book_Date_PQM__c!=null){
                                    if(!PrevYearGCBookOpp.containsKey(branchName)){
                                        PrevYearGCBookOpp.put(branchName,0);
                                    }     
                                    PrevYearGCBookOpp.put(branchName,PrevYearGCBookOpp.get(branchName)+1);
                                }
                            }
                        }
                        // New logic added on 22-04 end
                    }
                }
                // current year data
                else{
                    
                    if(!branchWiseThisYearOppCnt.containsKey(branchName)){
                        branchWiseThisYearOppCnt.put(branchName,0);
                    }
                    branchWiseThisYearOppCnt.put(branchName,branchWiseThisYearOppCnt.get(branchName)+1);
                    
                    //AOR Opps
                    if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                        if(!branchWiseThisYearAOROpps.containsKey(branchName)){
                            branchWiseThisYearAOROpps.put(branchName,0);
                        }
                        branchWiseThisYearAOROpps.put(branchName,branchWiseThisYearAOROpps.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Branch Gen'){
                        if(!branchWiseThisYearBranchGen.containsKey(branchName)){
                            branchWiseThisYearBranchGen.put(branchName,0);
                        }
                        branchWiseThisYearBranchGen.put(branchName,branchWiseThisYearBranchGen.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Self Gen'){
                        if(!branchWiseThisYearSelfGen.containsKey(branchName)){
                            branchWiseThisYearSelfGen.put(branchName,0);
                        }
                        branchWiseThisYearSelfGen.put(branchName,branchWiseThisYearSelfGen.get(branchName)+1);
                    }
                    if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                        if(!branchWiseThisYearNewProspects.containsKey(branchName)){
                            branchWiseThisYearNewProspects.put(branchName,0);
                        }
                        branchWiseThisYearNewProspects.put(branchName,branchWiseThisYearNewProspects.get(branchName)+1);
                    }
                    if(opp.Status__c=='Canceled'){
                        if(!branchWiseThisYearCancelled.containsKey(branchName)){
                            branchWiseThisYearCancelled.put(branchName,0);
                        }
                        branchWiseThisYearCancelled.put(branchName,branchWiseThisYearCancelled.get(branchName)+1);
                    }
                    if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                        if(!branchWiseThisYearTransferred.containsKey(branchName)){
                            branchWiseThisYearTransferred.put(branchName,0);
                        }
                        branchWiseThisYearTransferred.put(branchName,branchWiseThisYearTransferred.get(branchName)+1);
                    }
                    //if(opp.StageName=='Closed')
                    {
                        if(!branchWiseThisYearInvCan.containsKey(branchName)){
                            branchWiseThisYearInvCan.put(branchName,0);
                        }
                        branchWiseThisYearInvCan.put(branchName,branchWiseThisYearInvCan.get(branchName)+1);
                        if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                            if(!branchWiseThisYearInv.containsKey(branchName)){
                                branchWiseThisYearInv.put(branchName,0);
                            }
                            branchWiseThisYearInv.put(branchName,branchWiseThisYearInv.get(branchName)+1);
                        }     
                    }
                    if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                         opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                       && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen'))
                    {
                        if(opp.Appointment_DateTime__c!=null){
                            
                            if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                
                                if(!branchWiseThisYearALTTotal.containsKey(branchName)){
                                    branchWiseThisYearALTTotal.put(branchName,0);
                                }
                                branchWiseThisYearALTTotal.put(branchName,branchWiseThisYearALTTotal.get(branchName)+1);
                                if(!branchWiseThisYearALT.containsKey(branchName)){
                                    branchWiseThisYearALT.put(branchName,0);
                                }
                                branchWiseThisYearALT.put(branchName,branchWiseThisYearALT.get(branchName)+ Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c));
                            } 
                        }
                        
                    }
                    //Appointment to Book
                    if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                        if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                            
                            if(!branchWiseThisYearABTotal.containsKey(branchName)){
                                branchWiseThisYearABTotal.put(branchName,0);
                            }
                            branchWiseThisYearABTotal.put(branchName,branchWiseThisYearABTotal.get(branchName)+1);
                            if(!branchWiseThisYearAB.containsKey(branchName)){
                                branchWiseThisYearAB.put(branchName,0);
                            }
                            branchWiseThisYearAB.put(branchName,branchWiseThisYearAB.get(branchName)+Integer.valueOf(opp.Appointment_to_Booking__c));
                        }
                    }
                    
                    // New logic added on 22-04
                    if(!ThisYearGCTotalOpp.containsKey(branchName)){
                        ThisYearGCTotalOpp.put(branchName,0);
                    }     
                    ThisYearGCTotalOpp.put(branchName,ThisYearGCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c>=CurrentYearStarDate && opp.Book_Date_PQM__c<= CurrentYearEndDate)){
                            if(!ThisYearGCTotalPrice.containsKey(branchName)){
                                ThisYearGCTotalPrice.put(branchName,0);
                            }     
                            ThisYearGCTotalPrice.put(branchName,ThisYearGCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!ThisYearGCStageClosedWonTotalOpp.containsKey(branchName)){
                                ThisYearGCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            ThisYearGCStageClosedWonTotalOpp.put(branchName,ThisYearGCStageClosedWonTotalOpp.get(branchName)+1);
                            
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!ThisYearGCFCCOpp.containsKey(branchName)){
                                        ThisYearGCFCCOpp.put(branchName,0);
                                    }     
                                    ThisYearGCFCCOpp.put(branchName,ThisYearGCFCCOpp.get(branchName)+1);
                                }
                                if(!ThisYearGCFCCTotalOpp.containsKey(branchName)){
                                    ThisYearGCFCCTotalOpp.put(branchName,0);
                                }     
                                ThisYearGCFCCTotalOpp.put(branchName,ThisYearGCFCCTotalOpp.get(branchName)+1);   
                            } 
                            if(opp.Book_Date_PQM__c!=null){
                                if(!ThisYearGCBookOpp.containsKey(branchName)){
                                    ThisYearGCBookOpp.put(branchName,0);
                                }     
                                ThisYearGCBookOpp.put(branchName,ThisYearGCBookOpp.get(branchName)+1);
                            }
                        }
                        
                    }
                    
                }
            }
            
            // last 90 days logic
            if((opp.Createddate> TodayMinus90Days && opp.Createddate<= TodayDate) || ( opp.Createddate> TodayMinus454Days && opp.Createddate<= TodayMinus364Days)){
                String branchName='';
                if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                    branchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                }
                // previous year Data
                if(Opp.Createddate<TodayMinus90Days){
                    if(!PrevYearR90GCTotalOpp.containsKey(branchName)){
                        PrevYearR90GCTotalOpp.put(branchName,0);
                    }     
                    PrevYearR90GCTotalOpp.put(branchName,PrevYearR90GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus454Days && opp.Book_Date_PQM__c<= TodayMinus364Days)){
                            if(!PrevYearR90GCTotalPrice.containsKey(branchName)){
                                PrevYearR90GCTotalPrice.put(branchName,0);
                            }     
                            PrevYearR90GCTotalPrice.put(branchName,PrevYearR90GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName)){
                                PrevYearR90GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            PrevYearR90GCStageClosedWonTotalOpp.put(branchName,PrevYearR90GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!PrevYearR90GCFCCOpp.containsKey(branchName)){
                                        PrevYearR90GCFCCOpp.put(branchName,0);
                                    }     
                                    PrevYearR90GCFCCOpp.put(branchName,PrevYearR90GCFCCOpp.get(branchName)+1);
                                }
                                if(!PrevYearR90GCFCCTotalOpp.containsKey(branchName)){
                                    PrevYearR90GCFCCTotalOpp.put(branchName,0);
                                }     
                                PrevYearR90GCFCCTotalOpp.put(branchName,PrevYearR90GCFCCTotalOpp.get(branchName)+1);
                            }
                            if(opp.Book_Date_PQM__c!=null){
                                if(!PrevYearR90GCBookOpp.containsKey(branchName)){
                                    PrevYearR90GCBookOpp.put(branchName,0);
                                }     
                                PrevYearR90GCBookOpp.put(branchName,PrevYearR90GCBookOpp.get(branchName)+1);
                            }
                        }
                    }
                    
                    
                }else{
                    
                    if(!ThisYearR90GCTotalOpp.containsKey(branchName)){
                        ThisYearR90GCTotalOpp.put(branchName,0);
                    }     
                    ThisYearR90GCTotalOpp.put(branchName,ThisYearR90GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus90Days && opp.Book_Date_PQM__c<= TodayDate)){
                            if(!ThisYearR90GCTotalPrice.containsKey(branchName)){
                                ThisYearR90GCTotalPrice.put(branchName,0);
                            }     
                            ThisYearR90GCTotalPrice.put(branchName,ThisYearR90GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName)){
                                ThisYearR90GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            ThisYearR90GCStageClosedWonTotalOpp.put(branchName,ThisYearR90GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!ThisYearR90GCFCCOpp.containsKey(branchName)){
                                        ThisYearR90GCFCCOpp.put(branchName,0);
                                    }     
                                    ThisYearR90GCFCCOpp.put(branchName,ThisYearR90GCFCCOpp.get(branchName)+1);
                                }
                                if(!ThisYearR90GCFCCTotalOpp.containsKey(branchName)){
                                    ThisYearR90GCFCCTotalOpp.put(branchName,0);
                                }     
                                ThisYearR90GCFCCTotalOpp.put(branchName,ThisYearR90GCFCCTotalOpp.get(branchName)+1);   
                            } 
                            if(opp.Book_Date_PQM__c!=null){
                                if(!ThisYearR90GCBookOpp.containsKey(branchName)){
                                    ThisYearR90GCBookOpp.put(branchName,0);
                                }     
                                ThisYearR90GCBookOpp.put(branchName,ThisYearR90GCBookOpp.get(branchName)+1);
                            }
                        }

                    }
                    
                   
                }
                
            }
            
            // last 12 Month logic
                    
           if((opp.Createddate>TodayMinus12Months && opp.Createddate<= TodayDate) || ( opp.Createddate> TodayMinus24Months && opp.Createddate<= TodayMinus12Months)){
                
                String branchName='';
                if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                    branchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                }
                // previous year Data
                if(Opp.Createddate<TodayMinus12Months){
                    if(!PrevYearR12GCTotalOpp.containsKey(branchName)){
                        PrevYearR12GCTotalOpp.put(branchName,0);
                    }     
                    PrevYearR12GCTotalOpp.put(branchName,PrevYearR12GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus24Months && opp.Book_Date_PQM__c<= TodayMinus12Months)){
                            if(!PrevYearR12GCTotalPrice.containsKey(branchName)){
                                PrevYearR12GCTotalPrice.put(branchName,0);
                            }     
                            PrevYearR12GCTotalPrice.put(branchName,PrevYearR12GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName)){
                                PrevYearR12GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            PrevYearR12GCStageClosedWonTotalOpp.put(branchName,PrevYearR12GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(!PrevYearR12GCBookOpp.containsKey(branchName)){
                                    PrevYearR12GCBookOpp.put(branchName,0);
                                }     
                                PrevYearR12GCBookOpp.put(branchName,PrevYearR12GCBookOpp.get(branchName)+1);
                            }
                        }
                        
                    }
                    
                    
                    
                }else{
                    if(!ThisYearR12GCTotalOpp.containsKey(branchName)){
                        ThisYearR12GCTotalOpp.put(branchName,0);
                    }     
                    ThisYearR12GCTotalOpp.put(branchName,ThisYearR12GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus12Months && opp.Book_Date_PQM__c<= TodayDate)){
                            if(!ThisYearR12GCTotalPrice.containsKey(branchName)){
                                ThisYearR12GCTotalPrice.put(branchName,0);
                            }     
                            ThisYearR12GCTotalPrice.put(branchName,ThisYearR12GCTotalPrice.get(branchName)+(Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c));
                            if(!ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName)){
                                ThisYearR12GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            ThisYearR12GCStageClosedWonTotalOpp.put(branchName,ThisYearR12GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(!ThisYearR12GCBookOpp.containsKey(branchName)){
                                    ThisYearR12GCBookOpp.put(branchName,0);
                                }     
                                ThisYearR12GCBookOpp.put(branchName,ThisYearR12GCBookOpp.get(branchName)+1);
                            }
                        }
                      
                    }
                    
                }
                
            }
            
            // list Signed Contract Date
            if(opp.Status__c!='Canceled' && (opp.StageName =='Closed Won' || opp.StageName =='Contracted')){
                if(opp.Signed_Contract_Date__c !=null && opp.Signed_Contract_Date__c>= PrevYearStarDate && opp.Signed_Contract_Date__c<= CurrentYearEndDate){
                    String quobranchName='';
                    if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                        quobranchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                    }
                    // previous year Data
                    if(opp.Signed_Contract_Date__c < CurrentYearStarDate){
                        if( opp.Signed_Contract_Date__c<= PrevYearEndDate){
                            //Contracted
                            
                            if(!branchWisePrevYearContracted.containsKey(quobranchName)){
                                branchWisePrevYearContracted.put(quobranchName,0);
                            }
                            branchWisePrevYearContracted.put(quobranchName,branchWisePrevYearContracted.get(quobranchName)+1);
                            if(!branchWisePrevYearContractedTotalPrce.containsKey(quobranchName)){
                                branchWisePrevYearContractedTotalPrce.put(quobranchName,0);
                            }
                            branchWisePrevYearContractedTotalPrce.put(quobranchName,branchWisePrevYearContractedTotalPrce.get(quobranchName)+(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c));
                        }
                    } else{
                        
                        //Contracted
                        
                        if(!branchWiseThisYearContracted.containsKey(quobranchName)){
                            branchWiseThisYearContracted.put(quobranchName,0);
                        }
                        branchWiseThisYearContracted.put(quobranchName,branchWiseThisYearContracted.get(quobranchName)+1);
                        if(!branchWiseThisYearContractedTotalPrce.containsKey(quobranchName)){
                            branchWiseThisYearContractedTotalPrce.put(quobranchName,0);
                        }
                        branchWiseThisYearContractedTotalPrce.put(quobranchName,branchWiseThisYearContractedTotalPrce.get(quobranchName)+(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c));
                        
                    }
                }
            }
            //listBookDateQuote // Commented as new logic added as per new ticket W-001249
            /*if(opp.StageName=='Closed Won'){
                if(opp.Book_Date_PQM__c>= PrevYearStarDate && opp.Book_Date_PQM__c<= CurrentYearEndDate){
                    String quobranchName='';
                    if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                        quobranchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                    }
                    // previous year Data
                    if(opp.Book_Date_PQM__c < CurrentYearStarDate){
                        if( opp.Book_Date_PQM__c<= PrevYearEndDate){
                            //Contracted
                            if(!branchWisePrevYearBranchBookings.containsKey(quobranchName)){
                                branchWisePrevYearBranchBookings.put(quobranchName,0);
                            }
                            if(opp.Total_BO_price_quotes__c != null){
                                branchWisePrevYearBranchBookings.put(quobranchName,branchWisePrevYearBranchBookings.get(quobranchName)+(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c));
                            }
                            
                            if(!branchWisePrevYearBACBookings.containsKey(quobranchName)){
                                branchWisePrevYearBACBookings.put(quobranchName,0);
                            }
                            if(opp.Total_BAC_Price_Quote__c != null){
                                branchWisePrevYearBACBookings.put(quobranchName,branchWisePrevYearBACBookings.get(quobranchName)+(opp.Total_BAC_Price_Quote__c==null?0:opp.Total_BAC_Price_Quote__c));
                            }
                        }
                    } else{
                        
                        if(!branchWiseThisYearBranchBookings.containsKey(quobranchName)){
                            branchWiseThisYearBranchBookings.put(quobranchName,0);
                        }
                        if(opp.Total_BO_price_quotes__c != null){
                            branchWiseThisYearBranchBookings.put(quobranchName,branchWiseThisYearBranchBookings.get(quobranchName)+(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c));
                        }
                        
                        if(!branchWiseThisYearBACBookings.containsKey(quobranchName)){
                            branchWiseThisYearBACBookings.put(quobranchName,0);
                        }
                        if(opp.Total_BAC_Price_Quote__c != null){
                            branchWiseThisYearBACBookings.put(quobranchName,branchWiseThisYearBACBookings.get(quobranchName)+(opp.Total_BAC_Price_Quote__c==null?0:opp.Total_BAC_Price_Quote__c));
                        }
                        
                    }
                }
            }*/
        }

        set<String> setBranchNames=new Set<String>();
        setBranchNames.addAll(branchWisePrevYearOppCnt.keySet());
        setBranchNames.addAll(branchWiseThisYearOppCnt.keySet());
        
        setBranchNames.addAll(branchWiseThisYearBranchBookings.keySet());
        setBranchNames.addAll(branchWiseThisYearBACBookings.keySet());
        setBranchNames.addAll(branchWisePrevYearBACBookings.keySet());
        setBranchNames.addAll(branchWisePrevYearBranchBookings.keySet());
        
        setBranchNames.addAll(branchWisePrevYearContracted.keySet());
        setBranchNames.addAll(branchWiseThisYearContracted.keySet());
        
        setBranchNames.addAll(ThisYearR12GCTotalOpp.keySet());
        setBranchNames.addAll(PrevYearR12GCTotalOpp.keySet());
        setBranchNames.addAll(ThisYearR90GCTotalOpp.keySet());
        setBranchNames.addAll(PrevYearR90GCTotalOpp.keySet());

        setBranchNames.addAll(branchWiseThisYearContracted.keySet());
        setBranchNames.addAll(branchWisePrevYearContracted.keySet());
        
        setBranchNames.remove('');
        Map<String,String> branchWiseRegionName=new Map<String,String>();
        for(Branch__c branch: [SELECT ID,Branch_Number__c,Name,Region__c,Region__r.Name FROM Branch__c Order By Region__r.Name ]){
            // setBranchNames.add(branch.Branch_Number__c+'-'+branch.Name);
            branchWiseRegionName.put(branch.Branch_Number__c+'-'+branch.Name,branch.Region__r.Name);
        }
        /*setBranchNames.addAll(branchWisePrevYearOpp.keySet());
setBranchNames.addAll(branchWiseThisYearOpp.keySet());*/
        // setBranchNames.addAll(branchWisePrevYearOppCnt.keySet());
        // setBranchNames.addAll(branchWiseThisYearOppCnt.keySet());
        
        system.debug('@@getResultData step 9@@:: '+DateTime.now());
        
        Map<String, Boolean> mapSortAscDesc = new Map<String, Boolean>();
        List<ReportResult> listReportResult=new List<ReportResult>();
        Map<String,ReportResult> mapReportResult=new Map<String,ReportResult>();
        
        
        system.debug('@@getResultData step 10@@:: '+DateTime.now());
        
        Map<String, Set<decimal>> mapReportWiseAmount = new Map<String, Set<decimal>>();
        for(String branchName : setBranchNames){
            ReportResult RR=new ReportResult();
            RR.Branch=branchName;
            RR.SBM=branchWiseRegionName.get(branchName);
            RR.reports=new List<report>();
            
            //Gross Opps
            report rpt=new report();
            rpt.reportLabel='Gross Opps';
            rpt.actualYear=(branchWiseThisYearOppCnt.containsKey(branchName)?branchWiseThisYearOppCnt.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearOppCnt.containsKey(branchName)?branchWisePrevYearOppCnt.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //AOR Opps
            rpt=new report();
            rpt.reportLabel='AOR Opps';
            rpt.actualYear=(branchWiseThisYearAOROpps.containsKey(branchName)?branchWiseThisYearAOROpps.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearAOROpps.containsKey(branchName)?branchWisePrevYearAOROpps.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Branch Opps
            rpt=new report();
            rpt.reportLabel='Branch Opps';
            rpt.actualYear=(branchWiseThisYearBranchGen.containsKey(branchName)?branchWiseThisYearBranchGen.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBranchGen.containsKey(branchName)?branchWisePrevYearBranchGen.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Self Gen Opps
            rpt=new report();
            rpt.reportLabel='Self Gen Opps';
            rpt.actualYear=(branchWiseThisYearSelfGen.containsKey(branchName)?branchWiseThisYearSelfGen.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearSelfGen.containsKey(branchName)?branchWisePrevYearSelfGen.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //New Prospects Opps
            rpt=new report();
            rpt.reportLabel='New Prospects Opps';
            rpt.actualYear=(branchWiseThisYearNewProspects.containsKey(branchName)?branchWiseThisYearNewProspects.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearNewProspects.containsKey(branchName)?branchWisePrevYearNewProspects.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Cancelled Opps
            rpt=new report();
            rpt.reportLabel='Canceled Opps';
            rpt.actualYear=(branchWiseThisYearCancelled.containsKey(branchName)?branchWiseThisYearCancelled.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearCancelled.containsKey(branchName)?branchWisePrevYearCancelled.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            //display
            
            //Transferred Opps
            rpt=new report();
            rpt.reportLabel='Transferred Opps';
            rpt.actualYear=(branchWiseThisYearTransferred.containsKey(branchName)?branchWiseThisYearTransferred.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearTransferred.containsKey(branchName)?branchWisePrevYearTransferred.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            //display
            
            //Inv/Can Opps
            rpt=new report();
            rpt.reportLabel='Transfer/Can Opps';
            system.debug('@@branchName'+branchName);
            system.debug('@@'+branchWiseThisYearInv.get(branchName));
            system.debug('@@'+branchWiseThisYearInvCan.get(branchName));
            
            rpt.actualYearData=(branchWiseThisYearInv.containsKey(branchName)?branchWiseThisYearInv.get(branchName):0);
            rpt.actualYearDataTotal=(branchWiseThisYearInvCan.containsKey(branchName)?branchWiseThisYearInvCan.get(branchName):0);
                
            /*if(branchWiseThisYearInv.containsKey(branchName) && branchWiseThisYearInvCan.containsKey(branchName) && branchWiseThisYearInvCan.get(branchName)>0){
                rpt.actualYear=branchWiseThisYearInv.get(branchName)/(decimal)branchWiseThisYearInvCan.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            
            rpt.priorYearData=(branchWisePrevYearInv.containsKey(branchName)?branchWisePrevYearInv.get(branchName):0);
            rpt.priorYearDataTotal=(branchWisePrevYearInvCan.containsKey(branchName)?branchWisePrevYearInvCan.get(branchName):0);
            
            
            /*if(branchWisePrevYearInv.containsKey(branchName) && branchWisePrevYearInvCan.containsKey(branchName) && branchWisePrevYearInvCan.get(branchName)>0){
                rpt.priorYear =branchWisePrevYearInv.get(branchName)/(decimal)branchWisePrevYearInvCan.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //ALT Opps
            rpt=new report();
            rpt.reportLabel='ALT';
            
            rpt.actualYearData=(branchWiseThisYearALT.containsKey(branchName)?branchWiseThisYearALT.get(branchName):0);
            rpt.actualYearDataTotal=(branchWiseThisYearALTTotal.containsKey(branchName)?branchWiseThisYearALTTotal.get(branchName):0);
            
            /*if(branchWiseThisYearALT.containsKey(branchName) && branchWiseThisYearALTTotal.containsKey(branchName) && branchWiseThisYearALTTotal.get(branchName)>0){
                rpt.actualYear=branchWiseThisYearALT.get(branchName)/(decimal)branchWiseThisYearALTTotal.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(branchWisePrevYearALT.containsKey(branchName)?branchWisePrevYearALT.get(branchName):0);
            rpt.priorYearDataTotal=(branchWisePrevYearALTTotal.containsKey(branchName)?branchWisePrevYearALTTotal.get(branchName):0);
            
            
            /*if(branchWisePrevYearALT.containsKey(branchName) && branchWisePrevYearALTTotal.containsKey(branchName) && branchWisePrevYearALTTotal.get(branchName)>0){
                rpt.priorYear =branchWisePrevYearALT.get(branchName)/(decimal)branchWisePrevYearALTTotal.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            
            //Appointment to Book Opps
            rpt=new report();
            rpt.reportLabel='Appointment to Book';
            
            rpt.actualYearData=(branchWiseThisYearAB.containsKey(branchName)?branchWiseThisYearAB.get(branchName):0);
            rpt.actualYearDataTotal=(branchWiseThisYearABTotal.containsKey(branchName)?branchWiseThisYearABTotal.get(branchName):0);
            
            /*if(branchWiseThisYearAB.containsKey(branchName) && branchWiseThisYearABTotal.containsKey(branchName) && branchWiseThisYearABTotal.get(branchName)>0){
                rpt.actualYear=branchWiseThisYearAB.get(branchName)/(decimal)branchWiseThisYearABTotal.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(branchWisePrevYearAB.containsKey(branchName)?branchWisePrevYearAB.get(branchName):0);
            rpt.priorYearDataTotal=(branchWisePrevYearABTotal.containsKey(branchName)?branchWisePrevYearABTotal.get(branchName):0);
            
            
            /*if(branchWisePrevYearAB.containsKey(branchName) && branchWisePrevYearABTotal.containsKey(branchName) && branchWisePrevYearABTotal.get(branchName)>0){
                rpt.priorYear =branchWisePrevYearAB.get(branchName)/(decimal)branchWisePrevYearABTotal.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Contracted
            rpt=new report();
            rpt.reportLabel='Contracted';
            rpt.actualYear=(branchWiseThisYearContracted.containsKey(branchName)?branchWiseThisYearContracted.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearContracted.containsKey(branchName)?branchWisePrevYearContracted.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            //display
            RR.reports.add(rpt);
            
            //$ Contracted 
            rpt=new report();
            rpt.reportLabel='$Contracted';
            rpt.actualYear=(branchWiseThisYearContractedTotalPrce.containsKey(branchName)?branchWiseThisYearContractedTotalPrce.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearContractedTotalPrce.containsKey(branchName)?branchWisePrevYearContractedTotalPrce.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);  
            
            //Branch Bookings
            rpt=new report();
            rpt.reportLabel='Branch Bookings';
            rpt.actualYear=(branchWiseThisYearBranchBookings.containsKey(branchName)?branchWiseThisYearBranchBookings.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBranchBookings.containsKey(branchName)?branchWisePrevYearBranchBookings.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //BAC Bookings
            rpt=new report();
            rpt.reportLabel='BAC Bookings';
            rpt.actualYear=(branchWiseThisYearBACBookings.containsKey(branchName)?branchWiseThisYearBACBookings.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBACBookings.containsKey(branchName)?branchWisePrevYearBACBookings.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //BAC Shipments
            rpt=new report();
            rpt.reportLabel='BAC Shipments';
            rpt.actualYear=(branchWiseThisYearBACShipments.containsKey(branchName)?branchWiseThisYearBACShipments.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBACShipments.containsKey(branchName)?branchWisePrevYearBACShipments.get(branchName):0);   
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            //display
            
            //R90 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='R90 Gross Close Ratio';
            
            
            rpt.actualYearData=(ThisYearR90GCBookOpp.containsKey(branchName)?ThisYearR90GCBookOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCTotalOpp.containsKey(branchName)?ThisYearR90GCTotalOpp.get(branchName):0);
            
            /*if(ThisYearR90GCBookOpp.containsKey(branchName) && ThisYearR90GCTotalOpp.containsKey(branchName) && ThisYearR90GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCBookOpp.get(branchName)/(decimal)ThisYearR90GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR90GCBookOpp.containsKey(branchName)?PrevYearR90GCBookOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCTotalOpp.containsKey(branchName)?PrevYearR90GCTotalOpp.get(branchName):0);
            
            /*if(PrevYearR90GCBookOpp.containsKey(branchName) && PrevYearR90GCTotalOpp.containsKey(branchName) && PrevYearR90GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCBookOpp.get(branchName)/(decimal)PrevYearR90GCTotalOpp.get(branchName);
            }else{ 
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Gross Yield
            rpt=new report();
            rpt.reportLabel='R90 Gross Yield';
            
            rpt.actualYearData=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCTotalOpp.containsKey(branchName)?ThisYearR90GCTotalOpp.get(branchName):0);
           
            rpt.priorYearData=(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCTotalOpp.containsKey(branchName)?PrevYearR90GCTotalOpp.get(branchName):0);
            
            
            //rpt.actualYear=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            //rpt.priorYear =(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R90 Average Job Size';
            
            rpt.actualYearData=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName)?ThisYearR90GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(ThisYearR90GCTotalPrice.containsKey(branchName) && ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName) && ThisYearR90GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCTotalPrice.get(branchName)/(decimal)ThisYearR90GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName)?PrevYearR90GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(PrevYearR90GCTotalPrice.containsKey(branchName) && PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName) && PrevYearR90GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCTotalPrice.get(branchName)/(decimal)PrevYearR90GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 FCC %
            rpt=new report();
            rpt.reportLabel='R90 FCC %';
            
            rpt.actualYearData=(ThisYearR90GCFCCOpp.containsKey(branchName)?ThisYearR90GCFCCOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCFCCTotalOpp.containsKey(branchName)?ThisYearR90GCFCCTotalOpp.get(branchName):0);
            
            /*if(ThisYearR90GCFCCOpp.containsKey(branchName) && ThisYearR90GCFCCTotalOpp.containsKey(branchName) && ThisYearR90GCFCCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCFCCOpp.get(branchName)/(decimal)ThisYearR90GCFCCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR90GCFCCOpp.containsKey(branchName)?PrevYearR90GCFCCOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCFCCTotalOpp.containsKey(branchName)?PrevYearR90GCFCCTotalOpp.get(branchName):0);
            
            /*if(PrevYearR90GCFCCOpp.containsKey(branchName) && PrevYearR90GCFCCTotalOpp.containsKey(branchName) && PrevYearR90GCFCCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCFCCOpp.get(branchName)/(decimal)PrevYearR90GCFCCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            //R12 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='R12 Gross Close Ratio';
            
            rpt.actualYearData=(ThisYearR12GCBookOpp.containsKey(branchName)?ThisYearR12GCBookOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR12GCTotalOpp.containsKey(branchName)?ThisYearR12GCTotalOpp.get(branchName):0);
            
            /*if(ThisYearR12GCBookOpp.containsKey(branchName) && ThisYearR12GCTotalOpp.containsKey(branchName) && ThisYearR12GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR12GCBookOpp.get(branchName)/(decimal)ThisYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            
            rpt.priorYearData=(PrevYearR12GCBookOpp.containsKey(branchName)?PrevYearR12GCBookOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR12GCTotalOpp.containsKey(branchName)?PrevYearR12GCTotalOpp.get(branchName):0);
            
            /*if(PrevYearR12GCBookOpp.containsKey(branchName) && PrevYearR12GCTotalOpp.containsKey(branchName) && PrevYearR12GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR12GCBookOpp.get(branchName)/(decimal)PrevYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R12 Gross Yield
            rpt=new report();
            rpt.reportLabel='R12 Gross Yield';
            
            rpt.actualYearData=(ThisYearR12GCTotalPrice.containsKey(branchName)?ThisYearR12GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR12GCTotalOpp.containsKey(branchName)?ThisYearR12GCTotalOpp.get(branchName):0);
            
            rpt.priorYearData=(PrevYearR12GCTotalPrice.containsKey(branchName)?PrevYearR12GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR12GCTotalOpp.containsKey(branchName)?PrevYearR12GCTotalOpp.get(branchName):0);
            
            //rpt.actualYear=(ThisYearR12GCTotalPrice.containsKey(branchName)?ThisYearR12GCTotalPrice.get(branchName):0);
            //rpt.priorYear =(PrevYearR12GCTotalPrice.containsKey(branchName)?PrevYearR12GCTotalPrice.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R12 Average Job Size';
            
            rpt.actualYearData=(ThisYearR12GCTotalPrice.containsKey(branchName)?ThisYearR12GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName)?ThisYearR12GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(ThisYearR12GCTotalPrice.containsKey(branchName) && ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName) && ThisYearR12GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR12GCTotalPrice.get(branchName)/(decimal)ThisYearR12GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR12GCTotalPrice.containsKey(branchName)?PrevYearR12GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName)?PrevYearR12GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(PrevYearR12GCTotalPrice.containsKey(branchName) && PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName) && PrevYearR12GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR12GCTotalPrice.get(branchName)/(decimal)PrevYearR12GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
             mapReportResult.put(branchName,RR);
            
            
             // New logic added on 22-04
            //Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='Gross Close Ratio';
            rpt.actualYearData=(ThisYearGCBookOpp.containsKey(branchName)?ThisYearGCBookOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearGCTotalOpp.containsKey(branchName)?ThisYearGCTotalOpp.get(branchName):0);
            rpt.priorYearData=(PrevYearGCBookOpp.containsKey(branchName)?PrevYearGCBookOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearGCTotalOpp.containsKey(branchName)?PrevYearGCTotalOpp.get(branchName):0);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //Gross Yield
            rpt=new report();
            rpt.reportLabel='Gross Yield';
            rpt.actualYearData=(ThisYearGCTotalPrice.containsKey(branchName)?ThisYearGCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearGCTotalOpp.containsKey(branchName)?ThisYearGCTotalOpp.get(branchName):0);
            rpt.priorYearData=(PrevYearGCTotalPrice.containsKey(branchName)?PrevYearGCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearGCTotalOpp.containsKey(branchName)?PrevYearGCTotalOpp.get(branchName):0);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            // Average Job Size
            rpt=new report();
            rpt.reportLabel='Average Job Size';
            rpt.actualYearData=(ThisYearGCTotalPrice.containsKey(branchName)?ThisYearGCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearGCStageClosedWonTotalOpp.containsKey(branchName)?ThisYearGCStageClosedWonTotalOpp.get(branchName):0);
            rpt.priorYearData=(PrevYearGCTotalPrice.containsKey(branchName)?PrevYearGCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearGCStageClosedWonTotalOpp.containsKey(branchName)?PrevYearGCStageClosedWonTotalOpp.get(branchName):0);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            // FCC %
            rpt=new report();
            rpt.reportLabel='FCC %';
            rpt.actualYearData=(ThisYearGCFCCOpp.containsKey(branchName)?ThisYearGCFCCOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearGCFCCTotalOpp.containsKey(branchName)?ThisYearGCFCCTotalOpp.get(branchName):0);
            rpt.priorYearData=(PrevYearGCFCCOpp.containsKey(branchName)?PrevYearGCFCCOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearGCFCCTotalOpp.containsKey(branchName)?PrevYearGCFCCTotalOpp.get(branchName):0);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
         
            listReportResult.add(RR);
        }
        
        system.debug('@@getResultData step 11@@:: '+DateTime.now());
         
        // Sorting of Report Amount
       /* for(String rptLabel : mapSortAscDesc.keySet()){
            if(mapReportWiseAmount.containsKey(rptLabel)){
                Boolean flag = mapSortAscDesc.get(rptLabel);
                Set<decimal> values = new Set<decimal>();
                values.addAll(mapReportWiseAmount.get(rptLabel));
                mapReportWiseAmount.put(rptLabel,sorting(flag,values));
            }
        }
        system.debug('@@getResultData step 12@@:: '+DateTime.now());
        
        // Highlight Background of First 5 Min/Max Amount
        for(ReportResult RR : listReportResult){
            for(report rpt : RR.reports){
                if(mapReportWiseAmount.containsKey(rpt.reportLabel)){
                    if(rpt.IsVisibleactualYear && mapReportWiseAmount.get(rpt.reportLabel).contains(rpt.actualYear)){
                        rpt.markGreen=true;
                    }
                    else if(rpt.IsVisiblepriorYear && mapReportWiseAmount.get(rpt.reportLabel).contains(rpt.priorYear)){
                        rpt.markGreen=true;
                    }
                    else if(rpt.IsVisibleToPy && mapReportWiseAmount.get(rpt.reportLabel).contains(rpt.ToPy)){
                        rpt.markGreen=true;
                    }
                }
            }
        }
        system.debug('@@getResultData step 13@@:: '+DateTime.now());
*/        
        return mapReportResult;
    }
    public static Map<String,ReportResult> getMTDResultData(List<Id> listOppIds){
        Date PrevYearStarDate,PrevYearEndDate;
        Date CurrentYearStarDate,CurrentYearEndDate;
        CurrentYearStarDate = Date.today().toStartOfMonth();
        CurrentYearEndDate = Date.today();
        PrevYearStarDate = CurrentYearStarDate.addYears(-1);
        PrevYearEndDate = CurrentYearEndDate.addYears(-1);
        
        
        Date TodayMinus90Days=Date.today().addDays(-90) ;
        DateTime TodayDate=DateTime.newInstance(Date.today(),Time.newInstance(23,59,59,0));
        
        Date TodayMinus454Days=Date.today().addDays(-455);
        DateTime TodayMinus364Days=DateTime.newInstance(Date.today().addDays(-364),Time.newInstance(23,59,59,0));
        
        Date TodayMinus12Months=Date.today().addDays(-365) ;
        Date TodayMinus24Months=Date.today().addDays(-730);
        
        
        
        system.debug('@@getResultData step 1@@:: '+DateTime.now());
        system.debug('CurrentYearStarDate :: '+CurrentYearStarDate);
        system.debug('CurrentYearEndDate :: '+CurrentYearEndDate);
        system.debug('PrevYearStarDate :: '+PrevYearStarDate);
        system.debug('PrevYearEndDate :: '+PrevYearEndDate); 
        
        //Gross Opps
        List<Opportunity> listOpportunity=[SELECT ID,Createddate,Account_Branch_Profile__c,Account_Branch_Profile__r.Branch__c,Appointment_to_Booking__c,ALT_Days_from_Create_to_Appointment__c,
                                           Account_Branch_Profile__r.Branch__r.Name,Account_Branch_Profile__r.Branch__r.Branch_Number__c,
                                           Zone__c,Zone__r.ParentTerritoryId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.Name,
                                           Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Response_Channel__c, Account.Customer_Type__c,
                                           Status__c,StageName,Appointment_DateTime__c,Book_Date_PQM__c,Total_BO_price_quotes__c,Total_BAC_Price_Quote__c,Signed_Contract_Date__c
                                           FROM Opportunity  
                                           Where Id = :listOppIds 
                                           and RecordType.DeveloperName = 'Replacement'
                                           and ( ((Createddate>=: CurrentYearStarDate AND Createddate<=: CurrentYearEndDate) OR (Createddate>=: PrevYearStarDate AND Createddate<=: PrevYearEndDate))
                                                OR 
                                                ((Createddate> :TodayMinus90Days AND Createddate<= :TodayDate) OR ( Createddate> :TodayMinus454Days AND Createddate<= :TodayMinus364Days))
                                                OR 
                                               (Signed_Contract_Date__c>= :PrevYearStarDate AND Signed_Contract_Date__c<= :CurrentYearEndDate)
                                                OR
                                               (Book_Date_PQM__c>= :PrevYearStarDate AND Book_Date_PQM__c<= :CurrentYearEndDate)
                                                OR ((Createddate> :TodayMinus12Months AND Createddate<= :TodayDate) OR ( Createddate> :TodayMinus12Months AND Createddate<= :TodayMinus24Months))
                                           )
                                           order by Account_Branch_Profile__r.Branch__r.Region__r.Name ];
        
        
        
        
        /*Map<String,List<Opportunity>> branchWiseThisYearOpp=new Map<String,List<Opportunity>>();
Map<String,List<Opportunity>> branchWisePrevYearOpp=new Map<String,List<Opportunity>>();*/
        Map<String,Integer> branchWiseThisYearOppCnt=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearOppCnt=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearAOROpps=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearAOROpps=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearBranchGen=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearBranchGen=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearSelfGen=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearSelfGen=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearNewProspects=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearNewProspects=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearCancelled=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearCancelled=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearTransferred=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearTransferred=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearInvCan=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearInvCan=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearInv=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearInv=new Map<String,Integer>();      
        
        Map<String,Integer> branchWiseThisYearALT=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearALT=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearALTTotal=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearALTTotal=new Map<String,Integer>();      
        
        Map<String,Integer> branchWiseThisYearAB=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearAB=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearABTotal=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearABTotal=new Map<String,Integer>();      
        
        //Count Quote 
        Map<String,Integer> branchWiseThisYearQuoCnt=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearQuoCnt=new Map<String,Integer>();
        
        Map<String,Integer> branchWiseThisYearContracted=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearContracted=new Map<String,Integer>();
        
        Map<String,Decimal> branchWiseThisYearContractedTotalPrce=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearContractedTotalPrce=new Map<String,Decimal>();
        
        Map<String,Integer> branchWiseThisYearBookQuoCnt=new Map<String,Integer>();
        Map<String,Integer> branchWisePrevYearBookQuoCnt=new Map<String,Integer>();
        
        Map<String,Decimal> branchWiseThisYearBranchBookings=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearBranchBookings=new Map<String,Decimal>();
        
        Map<String,Decimal> branchWiseThisYearBACBookings=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearBACBookings=new Map<String,Decimal>();
        
        Map<String,Decimal> branchWiseThisYearBACShipments=new Map<String,Decimal>();
        Map<String,Decimal> branchWisePrevYearBACShipments=new Map<String,Decimal>();
        
        system.debug('@@getResultData step 3@@:: '+DateTime.now());
        
         Map<String,Integer> ThisYearR90GCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearR90GCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCTotalOpp=new Map<String,Integer>();  
        
        Map<String,Integer> ThisYearR90GCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCStageClosedWonTotalOpp=new Map<String,Integer>();  
        
        Map<String,Decimal> ThisYearR90GCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearR90GCTotalPrice=new Map<String,Decimal>();  
        
        
        
        
        Map<String,Integer> ThisYearR12GCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearR12GCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCTotalOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearR12GCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCStageClosedWonTotalOpp=new Map<String,Integer>(); 
        
        Map<String,Decimal> ThisYearR12GCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearR12GCTotalPrice=new Map<String,Decimal>();  
        
        Map<String,Integer> ThisYearR90GCFCCOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCFCCOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearR90GCFCCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCFCCTotalOpp=new Map<String,Integer>(); 
        
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) Start
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                           Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c BranchNumber,
                                           Opportunity.Zone__r.ParentTerritory.Branch__r.Name BranchName
                                           FROM Quote 
                                           WHERE OpportunityId = :listOppIds and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                           and  (BookDate__c>= :PrevYearStarDate AND BookDate__c<= :PrevYearEndDate)
                                           and Status in ('Booked', 'Ordered', 'PendingBooked')
                                           and Forecasted__c=true
                                           Group By Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Opportunity.Zone__r.ParentTerritory.Branch__r.Name]) 
        {
            branchWisePrevYearBranchBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPricePQM')==null?0:(Decimal) ar.get('TotalPricePQM'));
            branchWisePrevYearBACBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPriceBAC')==null?0:(Decimal) ar.get('TotalPriceBAC'));
        }
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                   Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c BranchNumber,
                                   Opportunity.Zone__r.ParentTerritory.Branch__r.Name BranchName
                                   FROM Quote 
                                   WHERE OpportunityId = :listOppIds and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                   and  (BookDate__c>= :CurrentYearStarDate AND BookDate__c<= :CurrentYearEndDate)
                                   and Status in ('Booked', 'Ordered', 'PendingBooked')
                                   and Forecasted__c=true
                                   Group By Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Opportunity.Zone__r.ParentTerritory.Branch__r.Name]) 
        {
            branchWiseThisYearBranchBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPricePQM')==null?0:(Decimal) ar.get('TotalPricePQM'));
            branchWiseThisYearBACBookings.put((String)ar.get('BranchNumber')+'-'+(String)ar.get('BranchName'),ar.get('TotalPriceBAC')==null?0:(Decimal) ar.get('TotalPriceBAC'));
        }
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) End
        
        for(Opportunity opp: listOpportunity){
            if((opp.Createddate>=CurrentYearStarDate && opp.Createddate<= CurrentYearEndDate) || (opp.Createddate>= PrevYearStarDate && opp.Createddate<= PrevYearEndDate)){
                
                String branchName='';
                if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                    branchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                }
                
                // previous year Data
                if(Opp.Createddate<CurrentYearStarDate){
                    
                    if(!branchWisePrevYearOppCnt.containsKey(branchName)){
                        branchWisePrevYearOppCnt.put(branchName,0);
                    }
                    branchWisePrevYearOppCnt.put(branchName,branchWisePrevYearOppCnt.get(branchName)+1);
                    
                    //AOR Opps
                    if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                        if(!branchWisePrevYearAOROpps.containsKey(branchName)){
                            branchWisePrevYearAOROpps.put(branchName,0);
                        }
                        branchWisePrevYearAOROpps.put(branchName,branchWisePrevYearAOROpps.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Branch Gen'){
                        if(!branchWisePrevYearBranchGen.containsKey(branchName)){
                            branchWisePrevYearBranchGen.put(branchName,0);
                        }
                        branchWisePrevYearBranchGen.put(branchName,branchWisePrevYearBranchGen.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Self Gen'){
                        if(!branchWisePrevYearSelfGen.containsKey(branchName)){
                            branchWisePrevYearSelfGen.put(branchName,0);
                        }
                        branchWisePrevYearSelfGen.put(branchName,branchWisePrevYearSelfGen.get(branchName)+1);
                    }
                    if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                        if(!branchWisePrevYearNewProspects.containsKey(branchName)){
                            branchWisePrevYearNewProspects.put(branchName,0);
                        }
                        branchWisePrevYearNewProspects.put(branchName,branchWisePrevYearNewProspects.get(branchName)+1);
                    }
                    if(opp.Status__c=='Canceled'){
                        if(!branchWisePrevYearCancelled.containsKey(branchName)){
                            branchWisePrevYearCancelled.put(branchName,0);
                        }
                        branchWisePrevYearCancelled.put(branchName,branchWisePrevYearCancelled.get(branchName)+1);
                    }
                    if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                        if(!branchWisePrevYearTransferred.containsKey(branchName)){
                            branchWisePrevYearTransferred.put(branchName,0);
                        }
                        branchWisePrevYearTransferred.put(branchName,branchWisePrevYearTransferred.get(branchName)+1);
                    }
                    //if(opp.StageName=='Closed')
                    {
                        if(!branchWisePrevYearInvCan.containsKey(branchName)){
                            branchWisePrevYearInvCan.put(branchName,0);
                        }
                        branchWisePrevYearInvCan.put(branchName,branchWisePrevYearInvCan.get(branchName)+1);
                        if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                            if(!branchWisePrevYearInv.containsKey(branchName)){
                                branchWisePrevYearInv.put(branchName,0);
                            }
                            branchWisePrevYearInv.put(branchName,branchWisePrevYearInv.get(branchName)+1);
                        }                    
                    }
                    if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                          opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                       && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                           if(opp.Appointment_DateTime__c!=null){
                               
                               if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                   if(!branchWisePrevYearALTTotal.containsKey(branchName)){
                                       branchWisePrevYearALTTotal.put(branchName,0);
                                   }
                                   branchWisePrevYearALTTotal.put(branchName,branchWisePrevYearALTTotal.get(branchName)+1);
                                   if(!branchWisePrevYearALT.containsKey(branchName)){
                                       branchWisePrevYearALT.put(branchName,0);
                                   }
                                   //branchWisePrevYearALT.put(branchName,branchWisePrevYearALT.get(branchName)+Math.abs((Date.valueOf(opp.Appointment_DateTime__c).daysBetween(Date.valueOf(opp.Createddate)))));
                                   branchWisePrevYearALT.put(branchName,branchWisePrevYearALT.get(branchName)+Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c));
                               } 
                           }
                       }
                    //Appointment to Book
                    if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                        if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                            if(!branchWisePrevYearABTotal.containsKey(branchName)){
                                branchWisePrevYearABTotal.put(branchName,0);
                            }
                            branchWisePrevYearABTotal.put(branchName,branchWisePrevYearABTotal.get(branchName)+1);
                            if(!branchWisePrevYearAB.containsKey(branchName)){
                                branchWisePrevYearAB.put(branchName,0);
                            }
                            //branchWisePrevYearAB.put(branchName,branchWisePrevYearAB.get(branchName)+Math.abs((Date.valueOf(opp.Appointment_DateTime__c).daysBetween(Date.valueOf(opp.Book_Date_PQM__c)))));
                            branchWisePrevYearAB.put(branchName,branchWisePrevYearAB.get(branchName)+Integer.valueOf(opp.Appointment_to_Booking__c));
                        }
                    }
                }
                // current year data
                else{
                    if(!branchWiseThisYearOppCnt.containsKey(branchName)){
                        branchWiseThisYearOppCnt.put(branchName,0);
                    }
                    branchWiseThisYearOppCnt.put(branchName,branchWiseThisYearOppCnt.get(branchName)+1);
                    
                    //AOR Opps
                    if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                        if(!branchWiseThisYearAOROpps.containsKey(branchName)){
                            branchWiseThisYearAOROpps.put(branchName,0);
                        }
                        branchWiseThisYearAOROpps.put(branchName,branchWiseThisYearAOROpps.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Branch Gen'){
                        if(!branchWiseThisYearBranchGen.containsKey(branchName)){
                            branchWiseThisYearBranchGen.put(branchName,0);
                        }
                        branchWiseThisYearBranchGen.put(branchName,branchWiseThisYearBranchGen.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Self Gen'){
                        if(!branchWiseThisYearSelfGen.containsKey(branchName)){
                            branchWiseThisYearSelfGen.put(branchName,0);
                        }
                        branchWiseThisYearSelfGen.put(branchName,branchWiseThisYearSelfGen.get(branchName)+1);
                    }
                    if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                        if(!branchWiseThisYearNewProspects.containsKey(branchName)){
                            branchWiseThisYearNewProspects.put(branchName,0);
                        }
                        branchWiseThisYearNewProspects.put(branchName,branchWiseThisYearNewProspects.get(branchName)+1);
                    }
                    if(opp.Status__c=='Canceled'){
                        if(!branchWiseThisYearCancelled.containsKey(branchName)){
                            branchWiseThisYearCancelled.put(branchName,0);
                        }
                        branchWiseThisYearCancelled.put(branchName,branchWiseThisYearCancelled.get(branchName)+1);
                    }
                    if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                        if(!branchWiseThisYearTransferred.containsKey(branchName)){
                            branchWiseThisYearTransferred.put(branchName,0);
                        }
                        branchWiseThisYearTransferred.put(branchName,branchWiseThisYearTransferred.get(branchName)+1);
                    }
                    //if(opp.StageName=='Closed')
                    {
                        if(!branchWiseThisYearInvCan.containsKey(branchName)){
                            branchWiseThisYearInvCan.put(branchName,0);
                        }
                        branchWiseThisYearInvCan.put(branchName,branchWiseThisYearInvCan.get(branchName)+1);
                        if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                            if(!branchWiseThisYearInv.containsKey(branchName)){
                                branchWiseThisYearInv.put(branchName,0);
                            }
                            branchWiseThisYearInv.put(branchName,branchWiseThisYearInv.get(branchName)+1);
                        }     
                    }
                    if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                          opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                       && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen'))
                    {
                        if(opp.Appointment_DateTime__c!=null){
                            
                            if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                if(!branchWiseThisYearALTTotal.containsKey(branchName)){
                                    branchWiseThisYearALTTotal.put(branchName,0);
                                }
                                branchWiseThisYearALTTotal.put(branchName,branchWiseThisYearALTTotal.get(branchName)+1);
                                if(!branchWiseThisYearALT.containsKey(branchName)){
                                    branchWiseThisYearALT.put(branchName,0);
                                }
                                // branchWiseThisYearALT.put(branchName,branchWiseThisYearALT.get(branchName)+ Math.abs((Date.valueOf(opp.Createddate).daysBetween(Date.valueOf(opp.Appointment_DateTime__c)))));
                                branchWiseThisYearALT.put(branchName,branchWiseThisYearALT.get(branchName)+Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c));
                            } 
                        }
                    }
                    //Appointment to Book
                    if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                        if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                            
                            if(!branchWiseThisYearABTotal.containsKey(branchName)){
                                branchWiseThisYearABTotal.put(branchName,0);
                            }
                            branchWiseThisYearABTotal.put(branchName,branchWiseThisYearABTotal.get(branchName)+1);
                            if(!branchWiseThisYearAB.containsKey(branchName)){
                                branchWiseThisYearAB.put(branchName,0);
                            }
                            //branchWiseThisYearAB.put(branchName,branchWiseThisYearAB.get(branchName)+ Math.abs((Date.valueOf(opp.Appointment_DateTime__c).daysBetween(Date.valueOf(opp.Book_Date_PQM__c)))));
                            branchWiseThisYearAB.put(branchName,branchWiseThisYearAB.get(branchName)+ Integer.valueOf(opp.Appointment_to_Booking__c));
                        }
                    }
                }
            }
            
            // last 90 days logic
            if( (opp.Createddate> TodayMinus90Days && opp.Createddate<= TodayDate) || ( opp.Createddate> TodayMinus454Days && opp.Createddate<= TodayMinus364Days)){
                String branchName='';
                if(Opp.Account_Branch_Profile__c!=null && Opp.Account_Branch_Profile__r.Branch__c!=null){
                    branchName=Opp.Account_Branch_Profile__r.Branch__r.Branch_Number__c+'-'+Opp.Account_Branch_Profile__r.Branch__r.Name;
                }
                else if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                    branchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                }
                // previous year Data
                if(Opp.Createddate<TodayMinus90Days){
                    if(!PrevYearR90GCTotalOpp.containsKey(branchName)){
                        PrevYearR90GCTotalOpp.put(branchName,0);
                    }     
                    PrevYearR90GCTotalOpp.put(branchName,PrevYearR90GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        if(!PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName)){
                            PrevYearR90GCStageClosedWonTotalOpp.put(branchName,0);
                        }     
                        PrevYearR90GCStageClosedWonTotalOpp.put(branchName,PrevYearR90GCStageClosedWonTotalOpp.get(branchName)+1);
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus454Days && opp.Book_Date_PQM__c<= TodayMinus364Days)){
                            if(!PrevYearR90GCTotalPrice.containsKey(branchName)){
                                PrevYearR90GCTotalPrice.put(branchName,0);
                            }     
                            PrevYearR90GCTotalPrice.put(branchName,PrevYearR90GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!PrevYearR90GCFCCOpp.containsKey(branchName)){
                                        PrevYearR90GCFCCOpp.put(branchName,0);
                                    }     
                                    PrevYearR90GCFCCOpp.put(branchName,PrevYearR90GCFCCOpp.get(branchName)+1);
                                }
                                if(!PrevYearR90GCFCCTotalOpp.containsKey(branchName)){
                                    PrevYearR90GCFCCTotalOpp.put(branchName,0);
                                }     
                                PrevYearR90GCFCCTotalOpp.put(branchName,PrevYearR90GCFCCTotalOpp.get(branchName)+1);
                            }
                        }
                    }
                    if(opp.Book_Date_PQM__c!=null){
                        if(!PrevYearR90GCBookOpp.containsKey(branchName)){
                            PrevYearR90GCBookOpp.put(branchName,0);
                        }     
                        PrevYearR90GCBookOpp.put(branchName,PrevYearR90GCBookOpp.get(branchName)+1);
                    }
                    
                }else{
                    if(!ThisYearR90GCTotalOpp.containsKey(branchName)){
                        ThisYearR90GCTotalOpp.put(branchName,0);
                    }     
                    ThisYearR90GCTotalOpp.put(branchName,ThisYearR90GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        if(!ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName)){
                            ThisYearR90GCStageClosedWonTotalOpp.put(branchName,0);
                        }     
                        ThisYearR90GCStageClosedWonTotalOpp.put(branchName,ThisYearR90GCStageClosedWonTotalOpp.get(branchName)+1);
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus90Days && opp.Book_Date_PQM__c<= TodayDate)){
                            
                            if(!ThisYearR90GCTotalPrice.containsKey(branchName)){
                                ThisYearR90GCTotalPrice.put(branchName,0);
                            }     
                            ThisYearR90GCTotalPrice.put(branchName,ThisYearR90GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!ThisYearR90GCFCCOpp.containsKey(branchName)){
                                        ThisYearR90GCFCCOpp.put(branchName,0);
                                    }     
                                    ThisYearR90GCFCCOpp.put(branchName,ThisYearR90GCFCCOpp.get(branchName)+1);
                                }
                                if(!ThisYearR90GCFCCTotalOpp.containsKey(branchName)){
                                    ThisYearR90GCFCCTotalOpp.put(branchName,0);
                                }     
                                ThisYearR90GCFCCTotalOpp.put(branchName,ThisYearR90GCFCCTotalOpp.get(branchName)+1);   
                            }   
                        }
                    }
                    
                    if(opp.Book_Date_PQM__c!=null){
                        if(!ThisYearR90GCBookOpp.containsKey(branchName)){
                            ThisYearR90GCBookOpp.put(branchName,0);
                        }     
                        ThisYearR90GCBookOpp.put(branchName,ThisYearR90GCBookOpp.get(branchName)+1);
                    }
                }
                
                
            }
            // last 12 Month logic
            if((opp.Createddate> TodayMinus12Months && opp.Createddate<= TodayDate) || ( opp.Createddate> TodayMinus24Months && opp.Createddate<= TodayMinus12Months)){
                
                String branchName='';
                if(Opp.Account_Branch_Profile__c!=null && Opp.Account_Branch_Profile__r.Branch__c!=null){
                    branchName=Opp.Account_Branch_Profile__r.Branch__r.Branch_Number__c+'-'+Opp.Account_Branch_Profile__r.Branch__r.Name;
                }
                else if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                    branchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                }
                
                // previous year Data
                if(Opp.Createddate<TodayMinus12Months){
                    if(!PrevYearR12GCTotalOpp.containsKey(branchName)){
                        PrevYearR12GCTotalOpp.put(branchName,0);
                    }     
                    PrevYearR12GCTotalOpp.put(branchName,PrevYearR12GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        if(!PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName)){
                            PrevYearR12GCStageClosedWonTotalOpp.put(branchName,0);
                        }     
                        PrevYearR12GCStageClosedWonTotalOpp.put(branchName,PrevYearR12GCStageClosedWonTotalOpp.get(branchName)+1);
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus24Months && opp.Book_Date_PQM__c<= TodayMinus12Months)){
                            
                            if(!PrevYearR12GCTotalPrice.containsKey(branchName)){
                                PrevYearR12GCTotalPrice.put(branchName,0);
                            }     
                            PrevYearR12GCTotalPrice.put(branchName,PrevYearR12GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                        }
                        
                      
                    }
                    if(opp.Book_Date_PQM__c!=null){
                        if(!PrevYearR12GCBookOpp.containsKey(branchName)){
                            PrevYearR12GCBookOpp.put(branchName,0);
                        }     
                        PrevYearR12GCBookOpp.put(branchName,PrevYearR12GCBookOpp.get(branchName)+1);
                    }
                    
                    
                }else{
                    if(!ThisYearR12GCTotalOpp.containsKey(branchName)){
                        ThisYearR12GCTotalOpp.put(branchName,0);
                    }     
                    ThisYearR12GCTotalOpp.put(branchName,ThisYearR12GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        if(!ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName)){
                            ThisYearR12GCStageClosedWonTotalOpp.put(branchName,0);
                        }     
                        ThisYearR12GCStageClosedWonTotalOpp.put(branchName,ThisYearR12GCStageClosedWonTotalOpp.get(branchName)+1);
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus12Months && opp.Book_Date_PQM__c<= TodayDate)){
                            
                            if(!ThisYearR12GCTotalPrice.containsKey(branchName)){
                                ThisYearR12GCTotalPrice.put(branchName,0);
                            }     
                            ThisYearR12GCTotalPrice.put(branchName,ThisYearR12GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                        }
                       
                    }
                    if(opp.Book_Date_PQM__c!=null){
                        if(!ThisYearR12GCBookOpp.containsKey(branchName)){
                            ThisYearR12GCBookOpp.put(branchName,0);
                        }     
                        ThisYearR12GCBookOpp.put(branchName,ThisYearR12GCBookOpp.get(branchName)+1);
                    }
                }
                
            }
            
            // list Signed Contract Date
            if(opp.Status__c!='Canceled'){
                if(opp.Signed_Contract_Date__c>= PrevYearStarDate && opp.Signed_Contract_Date__c<= CurrentYearEndDate){
                    String quobranchName='';
                    if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                        quobranchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                    }
                    // previous year Data
                    if(opp.Signed_Contract_Date__c < CurrentYearStarDate){
                        
                        //Contracted
                        
                        if(!branchWisePrevYearContracted.containsKey(quobranchName)){
                            branchWisePrevYearContracted.put(quobranchName,0);
                        }
                        branchWisePrevYearContracted.put(quobranchName,branchWisePrevYearContracted.get(quobranchName)+1);
                        if(!branchWisePrevYearContractedTotalPrce.containsKey(quobranchName)){
                            branchWisePrevYearContractedTotalPrce.put(quobranchName,0);
                        }
                        if(opp.Total_BO_price_quotes__c != null){
                            
                            branchWisePrevYearContractedTotalPrce.put(quobranchName,branchWisePrevYearContractedTotalPrce.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                        }
                        
                    } else{
                        
                        //Contracted
                        
                        if(!branchWiseThisYearContracted.containsKey(quobranchName)){
                            branchWiseThisYearContracted.put(quobranchName,0);
                        }
                        branchWiseThisYearContracted.put(quobranchName,branchWiseThisYearContracted.get(quobranchName)+1);
                        if(!branchWiseThisYearContractedTotalPrce.containsKey(quobranchName)){
                            branchWiseThisYearContractedTotalPrce.put(quobranchName,0);
                        }
                        if(opp.Total_BO_price_quotes__c != null){
                            
                            branchWiseThisYearContractedTotalPrce.put(quobranchName,branchWiseThisYearContractedTotalPrce.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                        }
                        
                    }
                }
            }
            //listBookDateQuote // Commented as new logic added as per new ticket W-001249
            /*if(opp.StageName=='Closed Won'){
                if(opp.Book_Date_PQM__c>= PrevYearStarDate && opp.Book_Date_PQM__c<= CurrentYearEndDate){
                    String quobranchName='';
                    if(Opp.Zone__c!=null && Opp.Zone__r.ParentTerritoryId!=null && opp.Zone__r.ParentTerritory.Branch__c!=null){
                        quobranchName=Opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c+'-'+Opp.Zone__r.ParentTerritory.Branch__r.Name;
                    }
                    // previous year Data
                    if(opp.Book_Date_PQM__c < CurrentYearStarDate){
                        
                        //Contracted
                        if(!branchWisePrevYearBranchBookings.containsKey(quobranchName)){
                            branchWisePrevYearBranchBookings.put(quobranchName,0);
                        }
                        if(opp.Total_BO_price_quotes__c != null){
                            branchWisePrevYearBranchBookings.put(quobranchName,branchWisePrevYearBranchBookings.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                        }
                        
                        if(!branchWisePrevYearBACBookings.containsKey(quobranchName)){
                            branchWisePrevYearBACBookings.put(quobranchName,0);
                        }
                        if(opp.Total_BAC_Price_Quote__c != null){
                            branchWisePrevYearBACBookings.put(quobranchName,branchWisePrevYearBACBookings.get(quobranchName)+(opp.Total_BAC_Price_Quote__c));
                        }
                    } else{
                        
                        if(!branchWiseThisYearBranchBookings.containsKey(quobranchName)){
                            branchWiseThisYearBranchBookings.put(quobranchName,0);
                        }
                        if(opp.Total_BO_price_quotes__c != null){
                            branchWiseThisYearBranchBookings.put(quobranchName,branchWiseThisYearBranchBookings.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                        }
                        
                        if(!branchWiseThisYearBACBookings.containsKey(quobranchName)){
                            branchWiseThisYearBACBookings.put(quobranchName,0);
                        }
                        if(opp.Total_BAC_Price_Quote__c != null){
                            branchWiseThisYearBACBookings.put(quobranchName,branchWiseThisYearBACBookings.get(quobranchName)+(opp.Total_BAC_Price_Quote__c));
                        }
                        
                    }
                }
            }*/
        }
        system.debug('@@getResultData step 6@@:: '+DateTime.now());
        
       
        
        system.debug('@@getResultData step 7@@:: '+DateTime.now());
        
        system.debug('@@getResultData step 8@@:: '+DateTime.now());
        
        set<String> setBranchNames=new Set<String>();
        setBranchNames.addAll(branchWisePrevYearOppCnt.keySet());
        setBranchNames.addAll(branchWiseThisYearOppCnt.keySet());
        
        setBranchNames.addAll(branchWiseThisYearBranchBookings.keySet());
        setBranchNames.addAll(branchWiseThisYearBACBookings.keySet());
        setBranchNames.addAll(branchWisePrevYearBACBookings.keySet());
        setBranchNames.addAll(branchWiseThisYearBranchBookings.keySet());
        
        setBranchNames.addAll(branchWisePrevYearContracted.keySet());
        setBranchNames.addAll(branchWiseThisYearContracted.keySet());
        
        setBranchNames.remove('');
        Map<String,String> branchWiseRegionName=new Map<String,String>();
        for(Branch__c branch: [SELECT ID,Branch_Number__c,Name,Region__c,Region__r.Name FROM Branch__c Order By Region__r.Name ]){
            // setBranchNames.add(branch.Branch_Number__c+'-'+branch.Name);
            branchWiseRegionName.put(branch.Branch_Number__c+'-'+branch.Name,branch.Region__r.Name);
        }
        /*setBranchNames.addAll(branchWisePrevYearOpp.keySet());
setBranchNames.addAll(branchWiseThisYearOpp.keySet());*/
        // setBranchNames.addAll(branchWisePrevYearOppCnt.keySet());
        // setBranchNames.addAll(branchWiseThisYearOppCnt.keySet());
        
        system.debug('@@getResultData step 9@@:: '+DateTime.now());
        
        Map<String, Boolean> mapSortAscDesc = new Map<String, Boolean>();
        Map<String,ReportResult> mapReportResult=new Map<String,ReportResult>();
        List<ReportResult> listReportResult=new List<ReportResult>();
        for(String branchName : setBranchNames){
            ReportResult RR=new ReportResult();
            RR.Branch=branchName;
            RR.SBM=branchWiseRegionName.get(branchName);
            RR.reports=new List<report>();
            
            //Gross Opps
            report rpt=new report();
            rpt.reportLabel='Gross Opps';
            rpt.actualYear=(branchWiseThisYearOppCnt.containsKey(branchName)?branchWiseThisYearOppCnt.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearOppCnt.containsKey(branchName)?branchWisePrevYearOppCnt.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //AOR Opps
            rpt=new report();
            rpt.reportLabel='AOR Opps';
            rpt.actualYear=(branchWiseThisYearAOROpps.containsKey(branchName)?branchWiseThisYearAOROpps.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearAOROpps.containsKey(branchName)?branchWisePrevYearAOROpps.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Branch Opps
            rpt=new report();
            rpt.reportLabel='Branch Opps';
            rpt.actualYear=(branchWiseThisYearBranchGen.containsKey(branchName)?branchWiseThisYearBranchGen.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBranchGen.containsKey(branchName)?branchWisePrevYearBranchGen.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Self Gen Opps
            rpt=new report();
            rpt.reportLabel='Self Gen Opps';
            rpt.actualYear=(branchWiseThisYearSelfGen.containsKey(branchName)?branchWiseThisYearSelfGen.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearSelfGen.containsKey(branchName)?branchWisePrevYearSelfGen.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //New Prospects Opps
            rpt=new report();
            rpt.reportLabel='New Prospects Opps';
            rpt.actualYear=(branchWiseThisYearNewProspects.containsKey(branchName)?branchWiseThisYearNewProspects.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearNewProspects.containsKey(branchName)?branchWisePrevYearNewProspects.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Cancelled Opps
            rpt=new report();
            rpt.reportLabel='Canceled Opps';
            rpt.actualYear=(branchWiseThisYearCancelled.containsKey(branchName)?branchWiseThisYearCancelled.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearCancelled.containsKey(branchName)?branchWisePrevYearCancelled.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            //display
            
            //Transferred Opps
            rpt=new report();
            rpt.reportLabel='Transferred Opps';
            rpt.actualYear=(branchWiseThisYearTransferred.containsKey(branchName)?branchWiseThisYearTransferred.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearTransferred.containsKey(branchName)?branchWisePrevYearTransferred.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            //display
            
            //Inv/Can Opps
            rpt=new report();
            rpt.reportLabel='Transfer/Can Opps';
            system.debug('@@branchName'+branchName);
            system.debug('@@'+branchWiseThisYearInv.get(branchName));
            system.debug('@@'+branchWiseThisYearInvCan.get(branchName));
            
            rpt.actualYearData=(branchWiseThisYearInv.containsKey(branchName)?branchWiseThisYearInv.get(branchName):0);
            rpt.actualYearDataTotal=(branchWiseThisYearInvCan.containsKey(branchName)?branchWiseThisYearInvCan.get(branchName):0);
                
            /*if(branchWiseThisYearInv.containsKey(branchName) && branchWiseThisYearInvCan.containsKey(branchName) && branchWiseThisYearInvCan.get(branchName)>0){
                rpt.actualYear=branchWiseThisYearInv.get(branchName)/(decimal)branchWiseThisYearInvCan.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            
            rpt.priorYearData=(branchWisePrevYearInv.containsKey(branchName)?branchWisePrevYearInv.get(branchName):0);
            rpt.priorYearDataTotal=(branchWisePrevYearInvCan.containsKey(branchName)?branchWisePrevYearInvCan.get(branchName):0);
            
            
            /*if(branchWisePrevYearInv.containsKey(branchName) && branchWisePrevYearInvCan.containsKey(branchName) && branchWisePrevYearInvCan.get(branchName)>0){
                rpt.priorYear =branchWisePrevYearInv.get(branchName)/(decimal)branchWisePrevYearInvCan.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //ALT Opps
            rpt=new report();
            rpt.reportLabel='ALT';
            
            rpt.actualYearData=(branchWiseThisYearALT.containsKey(branchName)?branchWiseThisYearALT.get(branchName):0);
            rpt.actualYearDataTotal=(branchWiseThisYearALTTotal.containsKey(branchName)?branchWiseThisYearALTTotal.get(branchName):0);
            
            /*if(branchWiseThisYearALT.containsKey(branchName) && branchWiseThisYearALTTotal.containsKey(branchName) && branchWiseThisYearALTTotal.get(branchName)>0){
                rpt.actualYear=branchWiseThisYearALT.get(branchName)/(decimal)branchWiseThisYearALTTotal.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(branchWisePrevYearALT.containsKey(branchName)?branchWisePrevYearALT.get(branchName):0);
            rpt.priorYearDataTotal=(branchWisePrevYearALTTotal.containsKey(branchName)?branchWisePrevYearALTTotal.get(branchName):0);
            
            
            /*if(branchWisePrevYearALT.containsKey(branchName) && branchWisePrevYearALTTotal.containsKey(branchName) && branchWisePrevYearALTTotal.get(branchName)>0){
                rpt.priorYear =branchWisePrevYearALT.get(branchName)/(decimal)branchWisePrevYearALTTotal.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            
            //Appointment to Book Opps
            rpt=new report();
            rpt.reportLabel='Appointment to Book';
            
            rpt.actualYearData=(branchWiseThisYearAB.containsKey(branchName)?branchWiseThisYearAB.get(branchName):0);
            rpt.actualYearDataTotal=(branchWiseThisYearABTotal.containsKey(branchName)?branchWiseThisYearABTotal.get(branchName):0);
            
            /*if(branchWiseThisYearAB.containsKey(branchName) && branchWiseThisYearABTotal.containsKey(branchName) && branchWiseThisYearABTotal.get(branchName)>0){
                rpt.actualYear=branchWiseThisYearAB.get(branchName)/(decimal)branchWiseThisYearABTotal.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(branchWisePrevYearAB.containsKey(branchName)?branchWisePrevYearAB.get(branchName):0);
            rpt.priorYearDataTotal=(branchWisePrevYearABTotal.containsKey(branchName)?branchWisePrevYearABTotal.get(branchName):0);
            
            
            /*if(branchWisePrevYearAB.containsKey(branchName) && branchWisePrevYearABTotal.containsKey(branchName) && branchWisePrevYearABTotal.get(branchName)>0){
                rpt.priorYear =branchWisePrevYearAB.get(branchName)/(decimal)branchWisePrevYearABTotal.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Contracted
            rpt=new report();
            rpt.reportLabel='Contracted';
            rpt.actualYear=(branchWiseThisYearContracted.containsKey(branchName)?branchWiseThisYearContracted.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearContracted.containsKey(branchName)?branchWisePrevYearContracted.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            //display
            RR.reports.add(rpt);
            
            //$ Contracted 
            rpt=new report();
            rpt.reportLabel='$Contracted';
            rpt.actualYear=(branchWiseThisYearContractedTotalPrce.containsKey(branchName)?branchWiseThisYearContractedTotalPrce.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearContractedTotalPrce.containsKey(branchName)?branchWisePrevYearContractedTotalPrce.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);  
            
            //Branch Bookings
            rpt=new report();
            rpt.reportLabel='Branch Bookings';
            rpt.actualYear=(branchWiseThisYearBranchBookings.containsKey(branchName)?branchWiseThisYearBranchBookings.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBranchBookings.containsKey(branchName)?branchWisePrevYearBranchBookings.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //BAC Bookings
            rpt=new report();
            rpt.reportLabel='BAC Bookings';
            rpt.actualYear=(branchWiseThisYearBACBookings.containsKey(branchName)?branchWiseThisYearBACBookings.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBACBookings.containsKey(branchName)?branchWisePrevYearBACBookings.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //BAC Shipments
            rpt=new report();
            rpt.reportLabel='BAC Shipments';
            rpt.actualYear=(branchWiseThisYearBACShipments.containsKey(branchName)?branchWiseThisYearBACShipments.get(branchName):0);
            rpt.priorYear =(branchWisePrevYearBACShipments.containsKey(branchName)?branchWisePrevYearBACShipments.get(branchName):0);   
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            //display
            
            //R90 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='R90 Gross Close Ratio';
            
            
            rpt.actualYearData=(ThisYearR90GCBookOpp.containsKey(branchName)?ThisYearR90GCBookOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCTotalOpp.containsKey(branchName)?ThisYearR90GCTotalOpp.get(branchName):0);
            
            /*if(ThisYearR90GCBookOpp.containsKey(branchName) && ThisYearR90GCTotalOpp.containsKey(branchName) && ThisYearR90GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCBookOpp.get(branchName)/(decimal)ThisYearR90GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR90GCBookOpp.containsKey(branchName)?PrevYearR90GCBookOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCTotalOpp.containsKey(branchName)?PrevYearR90GCTotalOpp.get(branchName):0);
            
            /*if(PrevYearR90GCBookOpp.containsKey(branchName) && PrevYearR90GCTotalOpp.containsKey(branchName) && PrevYearR90GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCBookOpp.get(branchName)/(decimal)PrevYearR90GCTotalOpp.get(branchName);
            }else{ 
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Gross Yield
            rpt=new report();
            rpt.reportLabel='R90 Gross Yield';
            
            rpt.actualYearData=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCTotalOpp.containsKey(branchName)?ThisYearR90GCTotalOpp.get(branchName):0);
           
            rpt.priorYearData=(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCTotalOpp.containsKey(branchName)?PrevYearR90GCTotalOpp.get(branchName):0);
            
            //rpt.actualYear=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            //rpt.priorYear =(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R90 Average Job Size';
            
            rpt.actualYearData=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName)?ThisYearR90GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(ThisYearR90GCTotalPrice.containsKey(branchName) && ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName) && ThisYearR90GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCTotalPrice.get(branchName)/(decimal)ThisYearR90GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName)?PrevYearR90GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(PrevYearR90GCTotalPrice.containsKey(branchName) && PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName) && PrevYearR90GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCTotalPrice.get(branchName)/(decimal)PrevYearR90GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 FCC %
            rpt=new report();
            rpt.reportLabel='R90 FCC %';
            
            rpt.actualYearData=(ThisYearR90GCFCCOpp.containsKey(branchName)?ThisYearR90GCFCCOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR90GCFCCTotalOpp.containsKey(branchName)?ThisYearR90GCFCCTotalOpp.get(branchName):0);
            
            /*if(ThisYearR90GCFCCOpp.containsKey(branchName) && ThisYearR90GCFCCTotalOpp.containsKey(branchName) && ThisYearR90GCFCCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCFCCOpp.get(branchName)/(decimal)ThisYearR90GCFCCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR90GCFCCOpp.containsKey(branchName)?PrevYearR90GCFCCOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR90GCFCCTotalOpp.containsKey(branchName)?PrevYearR90GCFCCTotalOpp.get(branchName):0);
            
            /*if(PrevYearR90GCFCCOpp.containsKey(branchName) && PrevYearR90GCFCCTotalOpp.containsKey(branchName) && PrevYearR90GCFCCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCFCCOpp.get(branchName)/(decimal)PrevYearR90GCFCCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            //R12 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='R12 Gross Close Ratio';
            
            rpt.actualYearData=(ThisYearR12GCBookOpp.containsKey(branchName)?ThisYearR12GCBookOpp.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR12GCTotalOpp.containsKey(branchName)?ThisYearR12GCTotalOpp.get(branchName):0);
            
            /*if(ThisYearR12GCBookOpp.containsKey(branchName) && ThisYearR12GCTotalOpp.containsKey(branchName) && ThisYearR12GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR12GCBookOpp.get(branchName)/(decimal)ThisYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            
            rpt.priorYearData=(PrevYearR12GCBookOpp.containsKey(branchName)?PrevYearR12GCBookOpp.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR12GCTotalOpp.containsKey(branchName)?PrevYearR12GCTotalOpp.get(branchName):0);
            
            /*if(PrevYearR12GCBookOpp.containsKey(branchName) && PrevYearR12GCTotalOpp.containsKey(branchName) && PrevYearR12GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR12GCBookOpp.get(branchName)/(decimal)PrevYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsPercentage=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R12 Gross Yield
            rpt=new report();
            rpt.reportLabel='R12 Gross Yield';
            
            rpt.actualYearData=(ThisYearR12GCTotalPrice.containsKey(branchName)?ThisYearR12GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR12GCTotalOpp.containsKey(branchName)?ThisYearR12GCTotalOpp.get(branchName):0);
            
            rpt.priorYearData=(PrevYearR12GCTotalPrice.containsKey(branchName)?PrevYearR12GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR12GCTotalOpp.containsKey(branchName)?PrevYearR12GCTotalOpp.get(branchName):0);
            
            //rpt.actualYear=(ThisYearR12GCTotalPrice.containsKey(branchName)?ThisYearR12GCTotalPrice.get(branchName):0);
            //rpt.priorYear =(PrevYearR12GCTotalPrice.containsKey(branchName)?PrevYearR12GCTotalPrice.get(branchName):0);            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R12 Average Job Size';
            
            rpt.actualYearData=(ThisYearR12GCTotalPrice.containsKey(branchName)?ThisYearR12GCTotalPrice.get(branchName):0);
            rpt.actualYearDataTotal=(ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName)?ThisYearR12GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(ThisYearR12GCTotalPrice.containsKey(branchName) && ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName) && ThisYearR12GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR12GCTotalPrice.get(branchName)/(decimal)ThisYearR12GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }*/
            rpt.priorYearData=(PrevYearR12GCTotalPrice.containsKey(branchName)?PrevYearR12GCTotalPrice.get(branchName):0);
            rpt.priorYearDataTotal=(PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName)?PrevYearR12GCStageClosedWonTotalOpp.get(branchName):0);
            
            /*if(PrevYearR12GCTotalPrice.containsKey(branchName) && PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName) && PrevYearR12GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR12GCTotalPrice.get(branchName)/(decimal)PrevYearR12GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }*/
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
             mapReportResult.put(branchName,RR);
            listReportResult.add(RR);
        }
        
        system.debug('@@getResultData step 10@@:: '+DateTime.now());
        
        return mapReportResult;
    }
    public static Map<String,ReportResult> getCoachingReportResultData(List<Id> userId){
        /*Date PrevYearStarDate,PrevYearEndDate;
        Date CurrentYearStarDate,CurrentYearEndDate;
        CurrentYearStarDate=baseDate.addDays(364*(baseDate.daysBetween(Date.today())/364));
        CurrentYearEndDate=CurrentYearStarDate.addDays(363);
        PrevYearStarDate=CurrentYearStarDate.addDays(-363);
        PrevYearEndDate=CurrentYearStarDate.addDays(-1);
        
        system.debug('@@getResultData step 1@@:: '+DateTime.now());
        system.debug('CurrentYearStarDate :: '+CurrentYearStarDate);
        system.debug('CurrentYearEndDate :: '+CurrentYearEndDate);
        system.debug('PrevYearStarDate :: '+PrevYearStarDate);
    system.debug('CurrentYearStarDate :: '+PrevYearEndDate);*/
         
         List<ReportResult> listReportResult=new List<ReportResult>();
         Date CurrentYearStarDate=baseDate.addDays(364*(baseDate.daysBetween(Date.today())/364));
         Date CurrentYearEndDate=CurrentYearStarDate.addDays(363);
         dateTime d=DateTime.newInstance(Date.valueOf(CurrentYearEndDate).year(), 11, 30);
         String dayOfWeek = d.format('EEEE');
         if(dayOfWeek=='Saturday'){
             CurrentYearStarDate=CurrentYearStarDate.addDays(-7);
         }
         Date PrevYearStarDate=CurrentYearStarDate.addDays(-364);
         Date PrevYearEndDate=CurrentYearStarDate.addDays(-1);
         d=DateTime.newInstance(Date.valueOf(PrevYearEndDate).year(), 11, 30);
         dayOfWeek = d.format('EEEE');
         if(dayOfWeek=='Saturday'){
             PrevYearStarDate=PrevYearStarDate.addDays(-7);
         }
        
        // Provide YOY comparisons
        CurrentYearEndDate=Date.today();
        PrevYearEndDate=PrevYearStarDate.addDays(CurrentYearStarDate.daysBetween(CurrentYearEndDate));
        CurrentYearEndDate=Date.today().addDays(1);
        
         system.debug('CurrentYearStarDate :: '+CurrentYearStarDate);
         system.debug('CurrentYearEndDate :: '+CurrentYearEndDate);
         system.debug('PrevYearStarDate :: '+PrevYearStarDate);
         system.debug('PrevYearEndDate :: '+PrevYearEndDate);
         
         Date TodayMinus90Days=Date.today().addDays(-90) ;
         DateTime TodayDate=DateTime.newInstance(Date.today(),Time.newInstance(0,0,0,0));
         
         Date TodayMinus454Days=Date.today().addDays(-455);
         DateTime TodayMinus364Days=DateTime.newInstance(Date.today().addDays(-364),Time.newInstance(23,59,59,0));
         
        Date TodayMinus12Months=Date.today().addDays(-365) ;
        Date TodayMinus24Months=Date.today().addDays(-730);
        
         
       
         
        //Gross Opps
        List<Opportunity> listOpportunity=[SELECT ID,Createddate,Account_Branch_Profile__c,Account_Branch_Profile__r.Branch__c,Appointment_to_Booking__c,ALT_Days_from_Create_to_Appointment__c,
                                           Account_Branch_Profile__r.Branch__r.Name,Account_Branch_Profile__r.Branch__r.Branch_Number__c,
                                           Zone__c,Zone__r.ParentTerritoryId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.Name,
                                           Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Response_Channel__c, Account.Customer_Type__c,
                                           Status__c,StageName,Appointment_DateTime__c,Book_Date_PQM__c,Total_BO_price_quotes__c,Total_BAC_Price_Quote__c,Signed_Contract_Date__c,OwnerId
                                           FROM Opportunity Where ownerId = :userId 
                                           and RecordType.DeveloperName = 'Replacement'
                                           and( (Createddate>= :PrevYearStarDate AND Createddate<= :CurrentYearEndDate)
                                               OR 
                                               ((Createddate> :TodayMinus90Days AND Createddate<= :TodayDate) OR ( Createddate> :TodayMinus454Days AND Createddate<= :TodayMinus364Days))
                                               OR 
                                               (Signed_Contract_Date__c>= :PrevYearStarDate AND Signed_Contract_Date__c<= :CurrentYearEndDate)
                                               OR
                                               (Book_Date_PQM__c>= :PrevYearStarDate AND Book_Date_PQM__c<= :CurrentYearEndDate)
                                               OR
                                               ((Createddate> :TodayMinus12Months AND Createddate<= :TodayDate) OR ( Createddate> :TodayMinus24Months AND Createddate<= :TodayMinus12Months))
                                           )
                                           order by Account_Branch_Profile__r.Branch__r.Region__r.Name ];
        
        /*List<Quote> listSignedContractDateQuote = [SELECT ID,Status,Signed_Contract_Date__c,BookDate__c, Opportunity.Account_Branch_Profile__c, Opportunity.Zone__c,opportunity.OwnerId,
                                                   Opportunity.Zone__r.ParentTerritoryId,Opportunity.Zone__r.ParentTerritory.Branch__c,Opportunity.Zone__r.ParentTerritory.Branch__r.Name,
                                                   Opportunity.Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Opportunity.Account_Branch_Profile__r.Branch__c,Opportunity.Total_BO_price_quotes__c,
                                                   Opportunity.Account_Branch_Profile__r.Branch__r.Name,Opportunity.Account_Branch_Profile__r.Branch__r.Branch_Number__c,TotalPrice,Total_BAC_Price__c
                                                   From Quote Where OpportunityId in :listOpportunity  
                                                   and ( 
                                                          (Signed_Contract_Date__c>= :PrevYearStarDate AND Signed_Contract_Date__c<= :CurrentYearEndDate)
                                                          OR
                                                           (BookDate__c>= :PrevYearStarDate AND BookDate__c<= :CurrentYearEndDate)
                                                   )];*/
 
        system.debug('@@getResultData step 2@@:: '+DateTime.now());
        
        /*Map<String,List<Opportunity>> ownerWiseThisYearOpp=new Map<String,List<Opportunity>>();
Map<String,List<Opportunity>> ownerWisePrevYearOpp=new Map<String,List<Opportunity>>();*/
        Map<String,Integer> ownerWiseThisYearOppCnt=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearOppCnt=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearAOROpps=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearAOROpps=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearBranchGen=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearBranchGen=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearSelfGen=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearSelfGen=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearNewProspects=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearNewProspects=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearCancelled=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearCancelled=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearTransferred=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearTransferred=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearInvCan=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearInvCan=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearInv=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearInv=new Map<String,Integer>();      
        
        Map<String,Integer> ownerWiseThisYearALT=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearALT=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearALTTotal=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearALTTotal=new Map<String,Integer>();      
        
        Map<String,Integer> ownerWiseThisYearAB=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearAB=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearABTotal=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearABTotal=new Map<String,Integer>();      
        
        //Count Quote 
        Map<String,Integer> ownerWiseThisYearQuoCnt=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearQuoCnt=new Map<String,Integer>();
        
        Map<String,Integer> ownerWiseThisYearContracted=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearContracted=new Map<String,Integer>();
        
        Map<String,Decimal> ownerWiseThisYearContractedTotalPrce=new Map<String,Decimal>();
        Map<String,Decimal> ownerWisePrevYearContractedTotalPrce=new Map<String,Decimal>();
        
        Map<String,Integer> ownerWiseThisYearBookQuoCnt=new Map<String,Integer>();
        Map<String,Integer> ownerWisePrevYearBookQuoCnt=new Map<String,Integer>();
        
        Map<String,Decimal> ownerWiseThisYearBranchBookings=new Map<String,Decimal>();
        Map<String,Decimal> ownerWisePrevYearBranchBookings=new Map<String,Decimal>();
        
        Map<String,Decimal> ownerWiseThisYearBACBookings=new Map<String,Decimal>();
        Map<String,Decimal> ownerWisePrevYearBACBookings=new Map<String,Decimal>();
        
        Map<String,Decimal> ownerWiseThisYearBACShipments=new Map<String,Decimal>();
        Map<String,Decimal> ownerWisePrevYearBACShipments=new Map<String,Decimal>();
        
        system.debug('@@getResultData step 3@@:: '+DateTime.now());
         
         Map<String,Integer> ThisYearR90GCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearR90GCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCTotalOpp=new Map<String,Integer>();  
        
        Map<String,Integer> ThisYearR90GCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCStageClosedWonTotalOpp=new Map<String,Integer>();  
        
        Map<String,Decimal> ThisYearR90GCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearR90GCTotalPrice=new Map<String,Decimal>();  
        
        Map<String,Integer> ThisYearR12GCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearR12GCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCTotalOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearR12GCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR12GCStageClosedWonTotalOpp=new Map<String,Integer>(); 
        
        Map<String,Decimal> ThisYearR12GCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearR12GCTotalPrice=new Map<String,Decimal>();  
        
        Map<String,Decimal> ThisYearR12GCSelfGen=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearR12GCSelfGen=new Map<String,Decimal>();  
        
        Map<String,Integer> ThisYearR90GCFCCOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCFCCOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearR90GCFCCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearR90GCFCCTotalOpp=new Map<String,Integer>(); 
        
        
        Map<String,Integer> ThisYearGCBookOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCBookOpp=new Map<String,Integer>();
        
        Map<String,Integer> ThisYearGCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCTotalOpp=new Map<String,Integer>();  
        
        Map<String,Integer> ThisYearGCStageClosedWonTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCStageClosedWonTotalOpp=new Map<String,Integer>();  
        
        Map<String,Decimal> ThisYearGCTotalPrice=new Map<String,Decimal>();
        Map<String,Decimal> PrevYearGCTotalPrice=new Map<String,Decimal>();  
        
        Map<String,Integer> ThisYearGCFCCOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCFCCOpp=new Map<String,Integer>(); 
        
        Map<String,Integer> ThisYearGCFCCTotalOpp=new Map<String,Integer>();
        Map<String,Integer> PrevYearGCFCCTotalOpp=new Map<String,Integer>(); 
        
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) Start
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                           Opportunity.ownerId ownerId
                                           FROM Quote 
                                           WHERE Opportunity.ownerId = :userId  and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                           and  (BookDate__c>= :PrevYearStarDate AND BookDate__c< :CurrentYearStarDate)
                                           and Status in ('Booked', 'Ordered', 'PendingBooked')
                                           and Forecasted__c=true
                                           Group By Opportunity.ownerId]) 
        {
            ownerWisePrevYearBranchBookings.put((String)ar.get('ownerId'),ar.get('TotalPricePQM')==null?0:(Decimal) ar.get('TotalPricePQM'));
            ownerWisePrevYearBACBookings.put((String)ar.get('ownerId'),ar.get('TotalPriceBAC')==null?0:(Decimal) ar.get('TotalPriceBAC'));
        }
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                   Opportunity.ownerId ownerId
                                   FROM Quote 
                                   WHERE Opportunity.ownerId = :userId and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                   and  (BookDate__c>= :CurrentYearStarDate AND BookDate__c<= :CurrentYearEndDate)
                                   and Status in ('Booked', 'Ordered', 'PendingBooked')
                                   and Forecasted__c=true
                                   Group By Opportunity.ownerId]) 
        {
            ownerWiseThisYearBranchBookings.put((String)ar.get('ownerId'),ar.get('TotalPricePQM')==null?0:(Decimal) ar.get('TotalPricePQM'));
            ownerWiseThisYearBACBookings.put((String)ar.get('ownerId'),ar.get('TotalPriceBAC')==null?0:(Decimal) ar.get('TotalPriceBAC'));
        }
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) End
        
        
         //listSignedContractDateQuote
        /* for(Quote quo : listSignedContractDateQuote){
             if(quo.Signed_Contract_Date__c>= PrevYearStarDate && quo.Signed_Contract_Date__c<= CurrentYearEndDate){
                 
                 String quobranchName='';
                 if(quo.Opportunity.OwnerId!=null){
                     quobranchName=quo.Opportunity.OwnerId;
                 }
                 
                 // previous year Data
                 if(quo.Signed_Contract_Date__c < CurrentYearStarDate){
                     //Contracted
                     if(!ownerWisePrevYearContracted.containsKey(quobranchName)){
                         ownerWisePrevYearContracted.put(quobranchName,0);
                     }
                     ownerWisePrevYearContracted.put(quobranchName,ownerWisePrevYearContracted.get(quobranchName)+1);
                     if(!ownerWisePrevYearContractedTotalPrce.containsKey(quobranchName)){
                         ownerWisePrevYearContractedTotalPrce.put(quobranchName,0);
                     }
                     ownerWisePrevYearContractedTotalPrce.put(quobranchName,ownerWisePrevYearContractedTotalPrce.get(quobranchName)+(quo.TotalPrice));
                     
                 } else{
                     if(!ownerWiseThisYearContracted.containsKey(quobranchName)){
                         ownerWiseThisYearContracted.put(quobranchName,0);
                     }
                     ownerWiseThisYearContracted.put(quobranchName,ownerWiseThisYearContracted.get(quobranchName)+1);
                     if(!ownerWiseThisYearContractedTotalPrce.containsKey(quobranchName)){
                         ownerWiseThisYearContractedTotalPrce.put(quobranchName,0);
                     }
                     ownerWiseThisYearContractedTotalPrce.put(quobranchName,ownerWiseThisYearContractedTotalPrce.get(quobranchName)+(quo.TotalPrice));
                     
                 }
             }
             //listBookDateQuote 
             if(quo.BookDate__c>= PrevYearStarDate && quo.BookDate__c<= CurrentYearEndDate){
                 String quobranchName='';
                 if(quo.Opportunity.OwnerId!=null){
                     quobranchName=quo.Opportunity.OwnerId;
                 }
                 
                 // previous year Data
                 if(quo.BookDate__c < CurrentYearStarDate){
                     
                     //Contracted
                     if(!ownerWisePrevYearBranchBookings.containsKey(quobranchName)){
                         ownerWisePrevYearBranchBookings.put(quobranchName,0);
                     }
                     if(quo.TotalPrice != null){
                         ownerWisePrevYearBranchBookings.put(quobranchName,ownerWisePrevYearBranchBookings.get(quobranchName)+(quo.TotalPrice));
                     }
                     
                     if(!ownerWisePrevYearBACBookings.containsKey(quobranchName)){
                         ownerWisePrevYearBACBookings.put(quobranchName,0);
                     }
                     if(quo.Total_BAC_Price__c != null){
                         ownerWisePrevYearBACBookings.put(quobranchName,ownerWisePrevYearBACBookings.get(quobranchName)+(quo.Total_BAC_Price__c));
                     }
                     
                 } else{
                     
                     if(!ownerWiseThisYearBranchBookings.containsKey(quobranchName)){
                         ownerWiseThisYearBranchBookings.put(quobranchName,0);
                     }
                     if(quo.TotalPrice != null){
                         ownerWiseThisYearBranchBookings.put(quobranchName,ownerWiseThisYearBranchBookings.get(quobranchName)+(quo.TotalPrice));
                     }
                     
                     if(!ownerWiseThisYearBACBookings.containsKey(quobranchName)){
                         ownerWiseThisYearBACBookings.put(quobranchName,0);
                     }
                     if(quo.Total_BAC_Price__c != null){
                         ownerWiseThisYearBACBookings.put(quobranchName,ownerWiseThisYearBACBookings.get(quobranchName)+(quo.Total_BAC_Price__c));
                     }
                     
                 }
             }
         }*/
        
        for(Opportunity opp: listOpportunity){
            if(opp.Createddate>= PrevYearStarDate && opp.Createddate<= CurrentYearEndDate){
                String branchName='';
                if(Opp.OwnerId!=null){
                    branchName=Opp.OwnerId;
                }
                
                
                // previous year Data
                if(Opp.Createddate<CurrentYearStarDate){
                    if( opp.Createddate<= PrevYearEndDate){
                        if(!ownerWisePrevYearOppCnt.containsKey(branchName)){
                            ownerWisePrevYearOppCnt.put(branchName,0);
                        }
                        ownerWisePrevYearOppCnt.put(branchName,ownerWisePrevYearOppCnt.get(branchName)+1);
                        
                        //AOR Opps
                        if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                            if(!ownerWisePrevYearAOROpps.containsKey(branchName)){
                                ownerWisePrevYearAOROpps.put(branchName,0);
                            }
                            ownerWisePrevYearAOROpps.put(branchName,ownerWisePrevYearAOROpps.get(branchName)+1);
                        }else if(opp.Response_Channel__c=='Branch Gen'){
                            if(!ownerWisePrevYearBranchGen.containsKey(branchName)){
                                ownerWisePrevYearBranchGen.put(branchName,0);
                            }
                            ownerWisePrevYearBranchGen.put(branchName,ownerWisePrevYearBranchGen.get(branchName)+1);
                        }else if(opp.Response_Channel__c=='Self Gen'){
                            if(!ownerWisePrevYearSelfGen.containsKey(branchName)){
                                ownerWisePrevYearSelfGen.put(branchName,0);
                            }
                            ownerWisePrevYearSelfGen.put(branchName,ownerWisePrevYearSelfGen.get(branchName)+1);
                        }
                        if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                            if(!ownerWisePrevYearNewProspects.containsKey(branchName)){
                                ownerWisePrevYearNewProspects.put(branchName,0);
                            }
                            ownerWisePrevYearNewProspects.put(branchName,ownerWisePrevYearNewProspects.get(branchName)+1);
                        }
                        if(opp.Status__c=='Canceled'){
                            if(!ownerWisePrevYearCancelled.containsKey(branchName)){
                                ownerWisePrevYearCancelled.put(branchName,0);
                            }
                            ownerWisePrevYearCancelled.put(branchName,ownerWisePrevYearCancelled.get(branchName)+1);
                        }
                        if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                            if(!ownerWisePrevYearTransferred.containsKey(branchName)){
                                ownerWisePrevYearTransferred.put(branchName,0);
                            }
                            ownerWisePrevYearTransferred.put(branchName,ownerWisePrevYearTransferred.get(branchName)+1);
                        }
                        //if(opp.StageName=='Closed')
                        {
                            if(!ownerWisePrevYearInvCan.containsKey(branchName)){
                                ownerWisePrevYearInvCan.put(branchName,0);
                            }
                            ownerWisePrevYearInvCan.put(branchName,ownerWisePrevYearInvCan.get(branchName)+1);
                            if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                                if(!ownerWisePrevYearInv.containsKey(branchName)){
                                    ownerWisePrevYearInv.put(branchName,0);
                                }
                                ownerWisePrevYearInv.put(branchName,ownerWisePrevYearInv.get(branchName)+1);
                            }                    
                        }
                        if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                             opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                           && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                               if(opp.Appointment_DateTime__c!=null){
                                   if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                       
                                       if(!ownerWisePrevYearALTTotal.containsKey(branchName)){
                                           ownerWisePrevYearALTTotal.put(branchName,0);
                                       }
                                       ownerWisePrevYearALTTotal.put(branchName,ownerWisePrevYearALTTotal.get(branchName)+1);
                                       if(!ownerWisePrevYearALT.containsKey(branchName)){
                                           ownerWisePrevYearALT.put(branchName,0);
                                       }
                                       ownerWisePrevYearALT.put(branchName,ownerWisePrevYearALT.get(branchName)+Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c));
                                   } 
                               }
                           }
                        //Appointment to Book
                        if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                            if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                                
                                if(!ownerWisePrevYearABTotal.containsKey(branchName)){
                                    ownerWisePrevYearABTotal.put(branchName,0);
                                }
                                ownerWisePrevYearABTotal.put(branchName,ownerWisePrevYearABTotal.get(branchName)+1);
                                if(!ownerWisePrevYearAB.containsKey(branchName)){
                                    ownerWisePrevYearAB.put(branchName,0);
                                }
                                ownerWisePrevYearAB.put(branchName,ownerWisePrevYearAB.get(branchName)+Integer.valueOf(opp.Appointment_to_Booking__c));
                            }
                        }
                        
                        // New logic added on 22-04
                        if(!PrevYearGCTotalOpp.containsKey(branchName)){
                            PrevYearGCTotalOpp.put(branchName,0);
                        }     
                        PrevYearGCTotalOpp.put(branchName,PrevYearGCTotalOpp.get(branchName)+1);
                        
                        if(opp.StageName=='Closed Won'){
                            
                            if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c>= PrevYearStarDate && opp.Book_Date_PQM__c<= PrevYearEndDate)){
                                if(!PrevYearGCTotalPrice.containsKey(branchName)){
                                    PrevYearGCTotalPrice.put(branchName,0);
                                }     
                                PrevYearGCTotalPrice.put(branchName,PrevYearGCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                                if(!PrevYearGCStageClosedWonTotalOpp.containsKey(branchName)){
                                    PrevYearGCStageClosedWonTotalOpp.put(branchName,0);
                                }     
                                PrevYearGCStageClosedWonTotalOpp.put(branchName,PrevYearGCStageClosedWonTotalOpp.get(branchName)+1);
                                if(opp.Book_Date_PQM__c!=null){
                                    if(opp.Status__c=='First Call Close'){ 
                                        if(!PrevYearGCFCCOpp.containsKey(branchName)){
                                            PrevYearGCFCCOpp.put(branchName,0);
                                        }     
                                        PrevYearGCFCCOpp.put(branchName,PrevYearGCFCCOpp.get(branchName)+1);
                                    }
                                    if(!PrevYearGCFCCTotalOpp.containsKey(branchName)){
                                        PrevYearGCFCCTotalOpp.put(branchName,0);
                                    }     
                                    PrevYearGCFCCTotalOpp.put(branchName,PrevYearGCFCCTotalOpp.get(branchName)+1);
                                }
                                if(opp.Book_Date_PQM__c!=null){
                                    if(!PrevYearGCBookOpp.containsKey(branchName)){
                                        PrevYearGCBookOpp.put(branchName,0);
                                    }     
                                    PrevYearGCBookOpp.put(branchName,PrevYearGCBookOpp.get(branchName)+1);
                                }
                            }
                        }
                        // New logic added on 22-04 end
                    }
                }
                // current year data
                else{
                    if(!ownerWiseThisYearOppCnt.containsKey(branchName)){
                        ownerWiseThisYearOppCnt.put(branchName,0);
                    }
                    ownerWiseThisYearOppCnt.put(branchName,ownerWiseThisYearOppCnt.get(branchName)+1);
                    
                    //AOR Opps
                    if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                        if(!ownerWiseThisYearAOROpps.containsKey(branchName)){
                            ownerWiseThisYearAOROpps.put(branchName,0);
                        }
                        ownerWiseThisYearAOROpps.put(branchName,ownerWiseThisYearAOROpps.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Branch Gen'){
                        if(!ownerWiseThisYearBranchGen.containsKey(branchName)){
                            ownerWiseThisYearBranchGen.put(branchName,0);
                        }
                        ownerWiseThisYearBranchGen.put(branchName,ownerWiseThisYearBranchGen.get(branchName)+1);
                    }else if(opp.Response_Channel__c=='Self Gen'){
                        if(!ownerWiseThisYearSelfGen.containsKey(branchName)){
                            ownerWiseThisYearSelfGen.put(branchName,0);
                        }
                        ownerWiseThisYearSelfGen.put(branchName,ownerWiseThisYearSelfGen.get(branchName)+1);
                    }
                    if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                        if(!ownerWiseThisYearNewProspects.containsKey(branchName)){
                            ownerWiseThisYearNewProspects.put(branchName,0);
                        }
                        ownerWiseThisYearNewProspects.put(branchName,ownerWiseThisYearNewProspects.get(branchName)+1);
                    }
                    if(opp.Status__c=='Canceled'){
                        if(!ownerWiseThisYearCancelled.containsKey(branchName)){
                            ownerWiseThisYearCancelled.put(branchName,0);
                        }
                        ownerWiseThisYearCancelled.put(branchName,ownerWiseThisYearCancelled.get(branchName)+1);
                    }
                    if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                        if(!ownerWiseThisYearTransferred.containsKey(branchName)){
                            ownerWiseThisYearTransferred.put(branchName,0);
                        }
                        ownerWiseThisYearTransferred.put(branchName,ownerWiseThisYearTransferred.get(branchName)+1);
                    }
                    //if(opp.StageName=='Closed')
                    {
                        if(!ownerWiseThisYearInvCan.containsKey(branchName)){
                            ownerWiseThisYearInvCan.put(branchName,0);
                        }
                        ownerWiseThisYearInvCan.put(branchName,ownerWiseThisYearInvCan.get(branchName)+1);
                        if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                            if(!ownerWiseThisYearInv.containsKey(branchName)){
                                ownerWiseThisYearInv.put(branchName,0);
                            }
                            ownerWiseThisYearInv.put(branchName,ownerWiseThisYearInv.get(branchName)+1);
                        }     
                    }
                    if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                         opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                       && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen'))
                    {
                        if(opp.Appointment_DateTime__c!=null){
                            
                            if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                
                                if(!ownerWiseThisYearALTTotal.containsKey(branchName)){
                                    ownerWiseThisYearALTTotal.put(branchName,0);
                                }
                                ownerWiseThisYearALTTotal.put(branchName,ownerWiseThisYearALTTotal.get(branchName)+1);
                                if(!ownerWiseThisYearALT.containsKey(branchName)){
                                    ownerWiseThisYearALT.put(branchName,0);
                                }
                                ownerWiseThisYearALT.put(branchName,ownerWiseThisYearALT.get(branchName)+ Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c));
                            } 
                        }
                    }
                    //Appointment to Book
                    if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                        if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                            
                            if(!ownerWiseThisYearABTotal.containsKey(branchName)){
                                ownerWiseThisYearABTotal.put(branchName,0);
                            }
                            ownerWiseThisYearABTotal.put(branchName,ownerWiseThisYearABTotal.get(branchName)+1);
                            if(!ownerWiseThisYearAB.containsKey(branchName)){
                                ownerWiseThisYearAB.put(branchName,0);
                            }
                            ownerWiseThisYearAB.put(branchName,ownerWiseThisYearAB.get(branchName)+Integer.valueOf(opp.Appointment_to_Booking__c));
                        }
                    }
                    
                    // New logic added on 22-04
                    if(!ThisYearGCTotalOpp.containsKey(branchName)){
                        ThisYearGCTotalOpp.put(branchName,0);
                    }     
                    ThisYearGCTotalOpp.put(branchName,ThisYearGCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c>=CurrentYearStarDate && opp.Book_Date_PQM__c<= CurrentYearEndDate)){
                            if(!ThisYearGCTotalPrice.containsKey(branchName)){
                                ThisYearGCTotalPrice.put(branchName,0);
                            }     
                            ThisYearGCTotalPrice.put(branchName,ThisYearGCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!ThisYearGCStageClosedWonTotalOpp.containsKey(branchName)){
                                ThisYearGCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            ThisYearGCStageClosedWonTotalOpp.put(branchName,ThisYearGCStageClosedWonTotalOpp.get(branchName)+1);
                            
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!ThisYearGCFCCOpp.containsKey(branchName)){
                                        ThisYearGCFCCOpp.put(branchName,0);
                                    }     
                                    ThisYearGCFCCOpp.put(branchName,ThisYearGCFCCOpp.get(branchName)+1);
                                }
                                if(!ThisYearGCFCCTotalOpp.containsKey(branchName)){
                                    ThisYearGCFCCTotalOpp.put(branchName,0);
                                }     
                                ThisYearGCFCCTotalOpp.put(branchName,ThisYearGCFCCTotalOpp.get(branchName)+1);   
                            } 
                            if(opp.Book_Date_PQM__c!=null){
                                if(!ThisYearGCBookOpp.containsKey(branchName)){
                                    ThisYearGCBookOpp.put(branchName,0);
                                }     
                                ThisYearGCBookOpp.put(branchName,ThisYearGCBookOpp.get(branchName)+1);
                            }
                        }
                        
                    }
                }
            }
            // last 90 days logic
            if((opp.Createddate> TodayMinus90Days && opp.Createddate<= TodayDate) || ( opp.Createddate> TodayMinus454Days && opp.Createddate<= TodayMinus364Days)){
                String branchName='';
                if(Opp.OwnerId!=null){
                    branchName=Opp.OwnerId;
                }
                
                // previous year Data
                if(Opp.Createddate<Date.today().addDays(-90)){
                    if(!PrevYearR90GCTotalOpp.containsKey(branchName)){
                        PrevYearR90GCTotalOpp.put(branchName,0);
                    }     
                    PrevYearR90GCTotalOpp.put(branchName,PrevYearR90GCTotalOpp.get(branchName)+1);
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus454Days && opp.Book_Date_PQM__c<= TodayMinus364Days)){
                            
                            if(!PrevYearR90GCTotalPrice.containsKey(branchName)){
                                PrevYearR90GCTotalPrice.put(branchName,0);
                            }     
                            PrevYearR90GCTotalPrice.put(branchName,PrevYearR90GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName)){
                                PrevYearR90GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            PrevYearR90GCStageClosedWonTotalOpp.put(branchName,PrevYearR90GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!PrevYearR90GCFCCOpp.containsKey(branchName)){
                                        PrevYearR90GCFCCOpp.put(branchName,0);
                                    }     
                                    PrevYearR90GCFCCOpp.put(branchName,PrevYearR90GCFCCOpp.get(branchName)+1);
                                }
                                if(!PrevYearR90GCFCCTotalOpp.containsKey(branchName)){
                                    PrevYearR90GCFCCTotalOpp.put(branchName,0);
                                }     
                                PrevYearR90GCFCCTotalOpp.put(branchName,PrevYearR90GCFCCTotalOpp.get(branchName)+1);
                            }
                            if(opp.Book_Date_PQM__c!=null){
                                if(!PrevYearR90GCBookOpp.containsKey(branchName)){
                                    PrevYearR90GCBookOpp.put(branchName,0);
                                }     
                                PrevYearR90GCBookOpp.put(branchName,PrevYearR90GCBookOpp.get(branchName)+1);
                            }
                        }
                        
                    }
                    
                    
                }else{
                    if(!ThisYearR90GCTotalOpp.containsKey(branchName)){
                        ThisYearR90GCTotalOpp.put(branchName,0);
                    }     
                    ThisYearR90GCTotalOpp.put(branchName,ThisYearR90GCTotalOpp.get(branchName)+1);
                    
                    
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus90Days && opp.Book_Date_PQM__c<= TodayDate)){
                            
                            if(!ThisYearR90GCTotalPrice.containsKey(branchName)){
                                ThisYearR90GCTotalPrice.put(branchName,0);
                            }     
                            ThisYearR90GCTotalPrice.put(branchName,ThisYearR90GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName)){
                                ThisYearR90GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            ThisYearR90GCStageClosedWonTotalOpp.put(branchName,ThisYearR90GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    if(!ThisYearR90GCFCCOpp.containsKey(branchName)){
                                        ThisYearR90GCFCCOpp.put(branchName,0);
                                    }     
                                    ThisYearR90GCFCCOpp.put(branchName,ThisYearR90GCFCCOpp.get(branchName)+1);
                                }
                                if(!ThisYearR90GCFCCTotalOpp.containsKey(branchName)){
                                    ThisYearR90GCFCCTotalOpp.put(branchName,0);
                                }     
                                ThisYearR90GCFCCTotalOpp.put(branchName,ThisYearR90GCFCCTotalOpp.get(branchName)+1);   
                            }  
                            if(opp.Book_Date_PQM__c!=null){
                                if(!ThisYearR90GCBookOpp.containsKey(branchName)){
                                    ThisYearR90GCBookOpp.put(branchName,0);
                                }     
                                ThisYearR90GCBookOpp.put(branchName,ThisYearR90GCBookOpp.get(branchName)+1);
                            }
                        }
                    }
                    
                    
                }
                
            }
                // last 12 Month logic
            if((opp.Createddate>TodayMinus12Months && opp.Createddate<= TodayDate) || ( opp.Createddate> TodayMinus24Months && opp.Createddate<= TodayMinus12Months)){
                
                String branchName='';
                if(Opp.OwnerId!=null){
                    branchName=Opp.OwnerId;
                }
                
                
                // previous year Data
                if(Opp.Createddate<Date.today().addMonths(-12)){
                    if(!PrevYearR12GCTotalOpp.containsKey(branchName)){
                        PrevYearR12GCTotalOpp.put(branchName,0);
                    }     
                    PrevYearR12GCTotalOpp.put(branchName,PrevYearR12GCTotalOpp.get(branchName)+1);
                    if(opp.Response_Channel__c=='Self Gen'){
                        if(!PrevYearR12GCSelfGen.containsKey(branchName)){
                            PrevYearR12GCSelfGen.put(branchName,0);
                        }
                        PrevYearR12GCSelfGen.put(branchName,PrevYearR12GCSelfGen.get(branchName)+1);
                    }
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus24Months && opp.Book_Date_PQM__c<= TodayMinus12Months)){
                            
                            if(!PrevYearR12GCTotalPrice.containsKey(branchName)){
                                PrevYearR12GCTotalPrice.put(branchName,0);
                            }     
                            PrevYearR12GCTotalPrice.put(branchName,PrevYearR12GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName)){
                                PrevYearR12GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            PrevYearR12GCStageClosedWonTotalOpp.put(branchName,PrevYearR12GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(!PrevYearR12GCBookOpp.containsKey(branchName)){
                                    PrevYearR12GCBookOpp.put(branchName,0);
                                }     
                                PrevYearR12GCBookOpp.put(branchName,PrevYearR12GCBookOpp.get(branchName)+1);
                            }
                        }
                        
                    }
                  
                    
                    
                }else{
                    if(!ThisYearR12GCTotalOpp.containsKey(branchName)){
                        ThisYearR12GCTotalOpp.put(branchName,0);
                    }     
                    ThisYearR12GCTotalOpp.put(branchName,ThisYearR12GCTotalOpp.get(branchName)+1);
                    if(opp.Response_Channel__c=='Self Gen'){
                        if(!ThisYearR12GCSelfGen.containsKey(branchName)){
                            ThisYearR12GCSelfGen.put(branchName,0);
                        }
                        ThisYearR12GCSelfGen.put(branchName,ThisYearR12GCSelfGen.get(branchName)+1);
                    }
                    if(opp.StageName=='Closed Won'){
                        
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c> TodayMinus12Months && opp.Book_Date_PQM__c<= TodayDate)){
                            
                            if(!ThisYearR12GCTotalPrice.containsKey(branchName)){
                                ThisYearR12GCTotalPrice.put(branchName,0);
                            }     
                            ThisYearR12GCTotalPrice.put(branchName,ThisYearR12GCTotalPrice.get(branchName)+((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c)));
                            if(!ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName)){
                                ThisYearR12GCStageClosedWonTotalOpp.put(branchName,0);
                            }     
                            ThisYearR12GCStageClosedWonTotalOpp.put(branchName,ThisYearR12GCStageClosedWonTotalOpp.get(branchName)+1);
                            if(opp.Book_Date_PQM__c!=null){
                                if(!ThisYearR12GCBookOpp.containsKey(branchName)){
                                    ThisYearR12GCBookOpp.put(branchName,0);
                                }     
                                ThisYearR12GCBookOpp.put(branchName,ThisYearR12GCBookOpp.get(branchName)+1);
                            }
                        }
                       
                    }
                   
                }
                
            }
            
            // list Signed Contract Date
            if(opp.Status__c!='Canceled' && (opp.StageName =='Closed Won' || opp.StageName =='Contracted')){
                if(opp.Signed_Contract_Date__c !=null && opp.Signed_Contract_Date__c>= PrevYearStarDate && opp.Signed_Contract_Date__c<= CurrentYearEndDate){
                     
                     String quobranchName='';
                     if(opp.OwnerId!=null){
                         quobranchName=opp.OwnerId;
                     }
                     
                     // previous year Data
                     if(opp.Signed_Contract_Date__c < CurrentYearStarDate){
                         if( opp.Signed_Contract_Date__c<= PrevYearEndDate){
                             
                             //Contracted
                             if(!ownerWisePrevYearContracted.containsKey(quobranchName)){
                                 ownerWisePrevYearContracted.put(quobranchName,0);
                             }
                             ownerWisePrevYearContracted.put(quobranchName,ownerWisePrevYearContracted.get(quobranchName)+1);
                             if(!ownerWisePrevYearContractedTotalPrce.containsKey(quobranchName)){
                                 ownerWisePrevYearContractedTotalPrce.put(quobranchName,0);
                             }
                             if(opp.Total_BO_price_quotes__c != null){
                                 
                                 ownerWisePrevYearContractedTotalPrce.put(quobranchName,ownerWisePrevYearContractedTotalPrce.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                             }
                         }
                         
                     } else{
                         if(!ownerWiseThisYearContracted.containsKey(quobranchName)){
                             ownerWiseThisYearContracted.put(quobranchName,0);
                         }
                         ownerWiseThisYearContracted.put(quobranchName,ownerWiseThisYearContracted.get(quobranchName)+1);
                         if(!ownerWiseThisYearContractedTotalPrce.containsKey(quobranchName)){
                             ownerWiseThisYearContractedTotalPrce.put(quobranchName,0);
                         }
                         if(opp.Total_BO_price_quotes__c != null){
                             
                             ownerWiseThisYearContractedTotalPrce.put(quobranchName,ownerWiseThisYearContractedTotalPrce.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                         }
                         
                     }
                 }
            }
            //listBookDateQuote // Commented as new logic added as per new ticket W-001249
            /*if(opp.StageName=='Closed Won'){
                if(opp.Book_Date_PQM__c>= PrevYearStarDate && opp.Book_Date_PQM__c<= CurrentYearEndDate){
                     String quobranchName='';
                     if(opp.OwnerId!=null){
                         quobranchName=opp.OwnerId;
                     }
                     
                     // previous year Data
                     if(opp.Book_Date_PQM__c < CurrentYearStarDate){
                         if( opp.Book_Date_PQM__c<= PrevYearEndDate){
                             
                             //Contracted
                             if(!ownerWisePrevYearBranchBookings.containsKey(quobranchName)){
                                 ownerWisePrevYearBranchBookings.put(quobranchName,0);
                             }
                             if(opp.Total_BO_price_quotes__c != null){
                                 ownerWisePrevYearBranchBookings.put(quobranchName,ownerWisePrevYearBranchBookings.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                             }
                             
                             if(!ownerWisePrevYearBACBookings.containsKey(quobranchName)){
                                 ownerWisePrevYearBACBookings.put(quobranchName,0);
                             }
                             if(opp.Total_BAC_Price_Quote__c != null){
                                 ownerWisePrevYearBACBookings.put(quobranchName,ownerWisePrevYearBACBookings.get(quobranchName)+(opp.Total_BAC_Price_Quote__c));
                             }
                         }
                         
                     } else{
                         
                         if(!ownerWiseThisYearBranchBookings.containsKey(quobranchName)){
                             ownerWiseThisYearBranchBookings.put(quobranchName,0);
                         }
                         if(opp.Total_BO_price_quotes__c != null){
                             ownerWiseThisYearBranchBookings.put(quobranchName,ownerWiseThisYearBranchBookings.get(quobranchName)+(opp.Total_BO_price_quotes__c));
                         }
                         
                         if(!ownerWiseThisYearBACBookings.containsKey(quobranchName)){
                             ownerWiseThisYearBACBookings.put(quobranchName,0);
                         }
                         if(opp.Total_BAC_Price_Quote__c != null){
                             ownerWiseThisYearBACBookings.put(quobranchName,ownerWiseThisYearBACBookings.get(quobranchName)+(opp.Total_BAC_Price_Quote__c));
                         }
                         
                     }
                }
            }*/
        }
         
        system.debug('@@getResultData step 8@@:: '+DateTime.now());
        
        set<String> setBranchNames=new Set<String>();
        /*setBranchNames.addAll(ownerWisePrevYearOppCnt.keySet());
        setBranchNames.addAll(ownerWiseThisYearOppCnt.keySet());
        
        setBranchNames.addAll(ownerWiseThisYearBranchBookings.keySet());
        setBranchNames.addAll(ownerWiseThisYearBACBookings.keySet());
        setBranchNames.addAll(ownerWisePrevYearBACBookings.keySet());
        setBranchNames.addAll(ownerWiseThisYearBranchBookings.keySet());
        
        setBranchNames.addAll(ownerWisePrevYearContracted.keySet());
        setBranchNames.addAll(ownerWiseThisYearContracted.keySet());
        
        setBranchNames.remove('');
         */
         List<User> listUser=[SELECT ID,Name FROM User Where Id = :userId];
         Map<Id,String> IdWiseUserName=new Map<Id,String>();
         for(User u:listUser){
             setBranchNames.add(u.Id);
             IdWiseUserName.put(u.Id,u.Name);
         }
       
        /*setBranchNames.addAll(ownerWisePrevYearOpp.keySet());
setBranchNames.addAll(ownerWiseThisYearOpp.keySet());*/
        // setBranchNames.addAll(ownerWisePrevYearOppCnt.keySet());
        // setBranchNames.addAll(ownerWiseThisYearOppCnt.keySet());
        
        system.debug('@@getResultData step 9@@:: '+DateTime.now());
        
        Map<String, Boolean> mapSortAscDesc = new Map<String, Boolean>();
        Map<String,ReportResult> mapReportResult=new Map<String,ReportResult>();
        for(String branchName : setBranchNames){
            ReportResult RR=new ReportResult();
            RR.Branch=IdWiseUserName.get(branchName);
            //RR.SBM=branchWiseRegionName.get(branchName);
            RR.reports=new List<report>();
            
            //Gross Opps
            report rpt=new report();
            rpt.reportLabel='Gross Opps';
            rpt.actualYear=(ownerWiseThisYearOppCnt.containsKey(branchName)?ownerWiseThisYearOppCnt.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearOppCnt.containsKey(branchName)?ownerWisePrevYearOppCnt.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //AOR Opps
            rpt=new report();
            rpt.reportLabel='AOR Opps';
            rpt.actualYear=(ownerWiseThisYearAOROpps.containsKey(branchName)?ownerWiseThisYearAOROpps.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearAOROpps.containsKey(branchName)?ownerWisePrevYearAOROpps.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Branch Opps
            rpt=new report();
            rpt.reportLabel='Branch Opps';
            rpt.actualYear=(ownerWiseThisYearBranchGen.containsKey(branchName)?ownerWiseThisYearBranchGen.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearBranchGen.containsKey(branchName)?ownerWisePrevYearBranchGen.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Self Gen Opps
            rpt=new report();
            rpt.reportLabel='Self Gen Opps';
            rpt.actualYear=(ownerWiseThisYearSelfGen.containsKey(branchName)?ownerWiseThisYearSelfGen.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearSelfGen.containsKey(branchName)?ownerWisePrevYearSelfGen.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //New Prospects Opps
            rpt=new report();
            rpt.reportLabel='New Prospects Opps';
            rpt.actualYear=(ownerWiseThisYearNewProspects.containsKey(branchName)?ownerWiseThisYearNewProspects.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearNewProspects.containsKey(branchName)?ownerWisePrevYearNewProspects.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Cancelled Opps
            rpt=new report();
            rpt.reportLabel='Canceled Opps';
            rpt.actualYear=(ownerWiseThisYearCancelled.containsKey(branchName)?ownerWiseThisYearCancelled.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearCancelled.containsKey(branchName)?ownerWisePrevYearCancelled.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            //display
            
            //Transferred Opps
            rpt=new report();
            rpt.reportLabel='Transferred Opps';
            rpt.actualYear=(ownerWiseThisYearTransferred.containsKey(branchName)?ownerWiseThisYearTransferred.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearTransferred.containsKey(branchName)?ownerWisePrevYearTransferred.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            //display
            
            //Inv/Can Opps
            rpt=new report();
            rpt.reportLabel='Transfer/Can Opps';
            system.debug('@@branchName'+branchName);
            system.debug('@@'+ownerWiseThisYearInv.get(branchName));
            system.debug('@@'+ownerWiseThisYearInvCan.get(branchName));
            if(ownerWiseThisYearInv.containsKey(branchName) && ownerWiseThisYearInvCan.containsKey(branchName) && ownerWiseThisYearInvCan.get(branchName)>0){
                rpt.actualYear=ownerWiseThisYearInv.get(branchName)/(decimal)ownerWiseThisYearInvCan.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(ownerWisePrevYearInv.containsKey(branchName) && ownerWisePrevYearInvCan.containsKey(branchName) && ownerWisePrevYearInvCan.get(branchName)>0){
                rpt.priorYear =ownerWisePrevYearInv.get(branchName)/(decimal)ownerWisePrevYearInvCan.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
             rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //ALT Opps
            rpt=new report();
            rpt.reportLabel='ALT';
            if(ownerWiseThisYearALT.containsKey(branchName) && ownerWiseThisYearALTTotal.containsKey(branchName) && ownerWiseThisYearALTTotal.get(branchName)>0){
                rpt.actualYear=ownerWiseThisYearALT.get(branchName)/(decimal)ownerWiseThisYearALTTotal.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(ownerWisePrevYearALT.containsKey(branchName) && ownerWisePrevYearALTTotal.containsKey(branchName) && ownerWisePrevYearALTTotal.get(branchName)>0){
                rpt.priorYear =ownerWisePrevYearALT.get(branchName)/(decimal)ownerWisePrevYearALTTotal.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            
            //Appointment to Book Opps
            rpt=new report();
            rpt.reportLabel='Appointment to Book';
            if(ownerWiseThisYearAB.containsKey(branchName) && ownerWiseThisYearABTotal.containsKey(branchName) && ownerWiseThisYearABTotal.get(branchName)>0){
                rpt.actualYear=ownerWiseThisYearAB.get(branchName)/(decimal)ownerWiseThisYearABTotal.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(ownerWisePrevYearAB.containsKey(branchName) && ownerWisePrevYearABTotal.containsKey(branchName) && ownerWisePrevYearABTotal.get(branchName)>0){
                rpt.priorYear =ownerWisePrevYearAB.get(branchName)/(decimal)ownerWisePrevYearABTotal.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //Contracted
            rpt=new report();
            rpt.reportLabel='Contracted';
            rpt.actualYear=(ownerWiseThisYearContracted.containsKey(branchName)?ownerWiseThisYearContracted.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearContracted.containsKey(branchName)?ownerWisePrevYearContracted.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            //display
            RR.reports.add(rpt);
            
            //$ Contracted 
            rpt=new report();
            rpt.reportLabel='$Contracted';
            rpt.actualYear=(ownerWiseThisYearContractedTotalPrce.containsKey(branchName)?ownerWiseThisYearContractedTotalPrce.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearContractedTotalPrce.containsKey(branchName)?ownerWisePrevYearContractedTotalPrce.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);  
            
            //Branch Bookings
            rpt=new report();
            rpt.reportLabel='Branch Bookings';
            rpt.actualYear=(ownerWiseThisYearBranchBookings.containsKey(branchName)?ownerWiseThisYearBranchBookings.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearBranchBookings.containsKey(branchName)?ownerWisePrevYearBranchBookings.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,false);
            RR.reports.add(rpt);
            
            //BAC Bookings
            rpt=new report();
            rpt.reportLabel='BAC Bookings';
            rpt.actualYear=(ownerWiseThisYearBACBookings.containsKey(branchName)?ownerWiseThisYearBACBookings.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearBACBookings.containsKey(branchName)?ownerWisePrevYearBACBookings.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //BAC Shipments
            rpt=new report();
            rpt.reportLabel='BAC Shipments';
            rpt.actualYear=(ownerWiseThisYearBACShipments.containsKey(branchName)?ownerWiseThisYearBACShipments.get(branchName):0);
            rpt.priorYear =(ownerWisePrevYearBACShipments.containsKey(branchName)?ownerWisePrevYearBACShipments.get(branchName):0); 
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            //display
            
            //R90 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='R90 Gross Close Ratio';
            if(ThisYearR90GCBookOpp.containsKey(branchName) && ThisYearR90GCTotalOpp.containsKey(branchName) && ThisYearR90GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCBookOpp.get(branchName)/(decimal)ThisYearR90GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearR90GCBookOpp.containsKey(branchName) && PrevYearR90GCTotalOpp.containsKey(branchName) && PrevYearR90GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCBookOpp.get(branchName)/(decimal)PrevYearR90GCTotalOpp.get(branchName);
            }else{ 
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
             rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Gross Yield
            rpt=new report();
            rpt.reportLabel='R90 Gross Yield';
            
            if(ThisYearR90GCTotalPrice.containsKey(branchName) && ThisYearR90GCTotalOpp.containsKey(branchName) && ThisYearR90GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCTotalPrice.get(branchName)/(decimal)ThisYearR90GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearR90GCTotalPrice.containsKey(branchName) && PrevYearR90GCTotalOpp.containsKey(branchName) && PrevYearR90GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCTotalPrice.get(branchName)/(decimal)PrevYearR90GCTotalOpp.get(branchName);
            }else{ 
                rpt.priorYear = 0;
            }
            
            //rpt.actualYear=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            //rpt.priorYear =(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R90 Average Job Size';
            if(ThisYearR90GCTotalPrice.containsKey(branchName) && ThisYearR90GCStageClosedWonTotalOpp.containsKey(branchName) && ThisYearR90GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCTotalPrice.get(branchName)/(decimal)ThisYearR90GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearR90GCTotalPrice.containsKey(branchName) && PrevYearR90GCStageClosedWonTotalOpp.containsKey(branchName) && PrevYearR90GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCTotalPrice.get(branchName)/(decimal)PrevYearR90GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 FCC %
            rpt=new report();
            rpt.reportLabel='R90 FCC %';
            if(ThisYearR90GCFCCOpp.containsKey(branchName) && ThisYearR90GCFCCTotalOpp.containsKey(branchName) && ThisYearR90GCFCCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR90GCFCCOpp.get(branchName)/(decimal)ThisYearR90GCFCCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearR90GCFCCOpp.containsKey(branchName) && PrevYearR90GCFCCTotalOpp.containsKey(branchName) && PrevYearR90GCFCCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR90GCFCCOpp.get(branchName)/(decimal)PrevYearR90GCFCCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
             rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            //R12 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='R12 Gross Close Ratio';
            if(ThisYearR12GCBookOpp.containsKey(branchName) && ThisYearR12GCTotalOpp.containsKey(branchName) && ThisYearR12GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR12GCBookOpp.get(branchName)/(decimal)ThisYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearR12GCBookOpp.containsKey(branchName) && PrevYearR12GCTotalOpp.containsKey(branchName) && PrevYearR12GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR12GCBookOpp.get(branchName)/(decimal)PrevYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
           //R12 SelfGen
            rpt=new report();
            rpt.reportLabel='R12 Self Gen';
            rpt.actualYear=(ThisYearR12GCSelfGen.containsKey(branchName)?ThisYearR12GCSelfGen.get(branchName):0);
            rpt.priorYear =(PrevYearR12GCSelfGen.containsKey(branchName)?PrevYearR12GCSelfGen.get(branchName):0); 
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R12 Gross Yield
            rpt=new report();
            rpt.reportLabel='R12 Gross Yield';
            if(ThisYearR12GCTotalPrice.containsKey(branchName) && ThisYearR12GCTotalOpp.containsKey(branchName) && ThisYearR12GCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR12GCTotalPrice.get(branchName)/(decimal)ThisYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearR12GCTotalPrice.containsKey(branchName) && PrevYearR12GCTotalOpp.containsKey(branchName) && PrevYearR12GCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR12GCTotalPrice.get(branchName)/(decimal)PrevYearR12GCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            //rpt.actualYear=(ThisYearR12GCTotalPrice.containsKey(branchName)?ThisYearR12GCTotalPrice.get(branchName):0);
            //rpt.priorYear =(PrevYearR12GCTotalPrice.containsKey(branchName)?PrevYearR12GCTotalPrice.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R12 Average Job Size';
            if(ThisYearR12GCTotalPrice.containsKey(branchName) && ThisYearR12GCStageClosedWonTotalOpp.containsKey(branchName) && ThisYearR12GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearR12GCTotalPrice.get(branchName)/(decimal)ThisYearR12GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearR12GCTotalPrice.containsKey(branchName) && PrevYearR12GCStageClosedWonTotalOpp.containsKey(branchName) && PrevYearR12GCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearR12GCTotalPrice.get(branchName)/(decimal)PrevYearR12GCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            mapReportResult.put(branchName,RR);
            listReportResult.add(RR);
            
            // New logic added on 22-04
            //R90 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='Gross Close Ratio';
            if(ThisYearGCBookOpp.containsKey(branchName) && ThisYearGCTotalOpp.containsKey(branchName) && ThisYearGCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearGCBookOpp.get(branchName)/(decimal)ThisYearGCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearGCBookOpp.containsKey(branchName) && PrevYearGCTotalOpp.containsKey(branchName) && PrevYearGCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearGCBookOpp.get(branchName)/(decimal)PrevYearGCTotalOpp.get(branchName);
            }else{ 
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Gross Yield
            rpt=new report();
            rpt.reportLabel='Gross Yield';
            
            if(ThisYearGCTotalPrice.containsKey(branchName) && ThisYearGCTotalOpp.containsKey(branchName) && ThisYearGCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearGCTotalPrice.get(branchName)/(decimal)ThisYearGCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearGCTotalPrice.containsKey(branchName) && PrevYearGCTotalOpp.containsKey(branchName) && PrevYearGCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearGCTotalPrice.get(branchName)/(decimal)PrevYearGCTotalOpp.get(branchName);
            }else{ 
                rpt.priorYear = 0;
            }
            
            //rpt.actualYear=(ThisYearR90GCTotalPrice.containsKey(branchName)?ThisYearR90GCTotalPrice.get(branchName):0);
            //rpt.priorYear =(PrevYearR90GCTotalPrice.containsKey(branchName)?PrevYearR90GCTotalPrice.get(branchName):0);            
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='Average Job Size';
            if(ThisYearGCTotalPrice.containsKey(branchName) && ThisYearGCStageClosedWonTotalOpp.containsKey(branchName) && ThisYearGCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearGCTotalPrice.get(branchName)/(decimal)ThisYearGCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearGCTotalPrice.containsKey(branchName) && PrevYearGCStageClosedWonTotalOpp.containsKey(branchName) && PrevYearGCStageClosedWonTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearGCTotalPrice.get(branchName)/(decimal)PrevYearGCStageClosedWonTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            mapSortAscDesc.put(rpt.reportLabel,true);
            RR.reports.add(rpt);
            
            //R90 FCC %
            rpt=new report();
            rpt.reportLabel='FCC %'; 
            if(ThisYearGCFCCOpp.containsKey(branchName) && ThisYearGCFCCTotalOpp.containsKey(branchName) && ThisYearGCFCCTotalOpp.get(branchName)>0){
                rpt.actualYear=ThisYearGCFCCOpp.get(branchName)/(decimal)ThisYearGCFCCTotalOpp.get(branchName);
            }else{
                rpt.actualYear = 0;
            }
            if(PrevYearGCFCCOpp.containsKey(branchName) && PrevYearGCFCCTotalOpp.containsKey(branchName) && PrevYearGCFCCTotalOpp.get(branchName)>0){
                rpt.priorYear =PrevYearGCFCCOpp.get(branchName)/(decimal)PrevYearGCFCCTotalOpp.get(branchName);
            }else{
                rpt.priorYear = 0;
            }
            rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
        }
        
        system.debug('@@getResultData step 10@@:: '+DateTime.now());
        
        
        return mapReportResult;
    }
   
    public static Set<decimal> sorting(Boolean flag, Set<decimal> values){
        List<decimal> listValues = new List<decimal>(values);
        List<decimal> reverseValues = new List<decimal>();
        Set<decimal> listResult = new Set<decimal>();
        
        if(!flag){
            listValues.sort();
            integer counter = 0;
            while(counter<5 && counter<listValues.size()) {
                listResult.add(listValues[counter]);
                counter++;
            }
        }
        else{
            listValues.sort();
            integer counter = 0;
            for(Integer i = listValues.size() - 1; i >= 0; i--){
                if(counter<5){
                    listResult.add(listValues[i]);
                    counter++;
                }else{
                    break;
                }
                //reverseValues.add(listValues[i]);
            }
            
            /* while(counter<5 && counter<reverseValues.size()) {
listResult.add(reverseValues[counter]);
counter++;
}*/
       }
        return listResult;
    }
    
    
    public class ReportResult{
        public  string SBM {get;set;}
        public  String Branch{get;set;}
        public  List<report> reports{get;set;}
    }
    public class report{
        public  string reportLabel{get;set;}
        public  Decimal actualYear{get;set;}
        public  Decimal actualYearData{get;set;}
        public  Decimal actualYearDataTotal{get;set;}
        
        public  boolean IsVisibleactualYear{get;set;}
        
        public  Decimal priorYear{get;set;}
        public  Decimal priorYearData{get;set;}
        public  Decimal priorYearDataTotal{get;set;}
        
        public  boolean IsVisiblepriorYear{get;set;}
        public  Decimal ToPy{get;set;}
        public  boolean IsVisibleToPy{get;set;}
        public  boolean IsCurrency{get;set;}
        public  boolean IsPYCurrency{get;set;}
        public  boolean markGreen{get;set;}
        
        public  boolean IsPercentage{get;set;}
        report(){
            IsPercentage=false;
        }
    }
}