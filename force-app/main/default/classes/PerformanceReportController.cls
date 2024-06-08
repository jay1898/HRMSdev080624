public class PerformanceReportController {
   public final static Date baseDate=Date.newInstance(2019, 12, 1);
    
    @AuraEnabled
    public static String getCurrentAndPreviousFiscalYear() {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        
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
        
        gen.writeDateField('FiscalCurrentYearStarDate', CurrentYearStarDate);
        gen.writeDateField('FiscalCurrentYearEndDate', CurrentYearEndDate);
        gen.writeDateField('FiscalPrevYearStarDate', PrevYearStarDate);
        gen.writeDateField('FiscalPrevYearEndDate', PrevYearEndDate);
        
        // Provide YOY comparisons
        CurrentYearEndDate=Date.today();
        PrevYearEndDate=PrevYearStarDate.addDays(CurrentYearStarDate.daysBetween(CurrentYearEndDate));
       
        
        
        
        gen.writeDateField('CurrentYearStarDate', CurrentYearStarDate);
        gen.writeDateField('CurrentYearEndDate', CurrentYearEndDate);
        gen.writeDateField('PrevYearStarDate', PrevYearStarDate);
        gen.writeDateField('PrevYearEndDate', PrevYearEndDate);
        
        gen.writeDateTimeField('LastExecutionDate',DAL_WK52Report.getWk52ReportLastUpdate('YTD')); 
        
        gen.writeEndObject();
        
        return gen.getAsString();
    }
    
    @AuraEnabled
    public static String getBranchRecords() {
        List<Branch__c> listBranches=[SELECT Id,NAME,Branch_Number__c from Branch__c order by Region__r.Name ];
        String jsonresult = JSON.serialize(listBranches);
        return jsonresult;
    }
    
     @AuraEnabled
    public static String getAllBranchRecords() {
        return DAL_WK52Report.getAllBranchRecords();
    }
     
    @AuraEnabled
    public static String getServiceResourceRecords() {
        List<ServiceResource> listServiceResource=[SELECT Id, Name, RelatedRecordId,RelatedRecord.FirstName,RelatedRecord.LastName,RelatedRecord.Username, ResourceType, IsActive FROM ServiceResource
                                                   Where  Replacement_Sales_Rep__c =true order by name];
        String jsonresult = JSON.serialize(listServiceResource);
        return jsonresult;
    }
    @AuraEnabled
    public static String getPublisReportResult() {
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=DAL_WK52Report.getWk52ReportByType('YTD');//[SELECT ID,SBM__c,Branch__c,Reports__c FROM WK52Report__c Where Report_Type__c ='YTD' order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){
            ReportResult RR=new ReportResult();
            RR.SBM=WK52Rpt.SBM__c;
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        
        return JSON.serialize(listReportResult);
    }
    
    @AuraEnabled
    public static String getYTDReportResult() {
        List<Branch__c> listBranches=[SELECT Id,NAME,Branch_Number__c from Branch__c where Branch_Number__c!=null  order by Region__r.Name];
        List<String> listBranchNumner=new List<String>();
        for(Branch__c b: listBranches){
            listBranchNumner.add(b.Branch_Number__c);
        }
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=DAL_WK52Report.getWk52ReportByTypeAndBranches('YTD',listBranchNumner);//[SELECT ID,SBM__c,Branch__c,Branch_Number__c,Reports__c FROM WK52Report__c Where Report_Type__c ='YTD' and Branch_Number__c = :listBranchNumner order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){
            ReportResult RR=new ReportResult();
            RR.SBM=WK52Rpt.SBM__c;
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        
        return JSON.serialize(listReportResult);
    }
    
    @AuraEnabled
    public static String getMTDReportResult() {
        List<Branch__c> listBranches=[SELECT Id,NAME,Branch_Number__c from Branch__c where Branch_Number__c!=null  order by Region__r.Name];
        List<String> listBranchNumner=new List<String>();
        for(Branch__c b: listBranches){
            listBranchNumner.add(b.Branch_Number__c);
        }
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=DAL_WK52Report.getWk52ReportByTypeAndBranches('MTD',listBranchNumner);//[SELECT ID,SBM__c,Branch__c,Branch_Number__c,Reports__c FROM WK52Report__c Where Report_Type__c ='MTD' and Branch_Number__c = :listBranchNumner order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){
            ReportResult RR=new ReportResult();
            RR.SBM=WK52Rpt.SBM__c;
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        
        return JSON.serialize(listReportResult);
    }
    
    @AuraEnabled
    public static String getCRReportResult() {
        List<ServiceResource> listBranches=[SELECT Id, Name, RelatedRecordId,RelatedRecord.FirstName,RelatedRecord.LastName,RelatedRecord.Username, ResourceType, IsActive FROM ServiceResource
                                                   Where  Replacement_Sales_Rep__c =true order by name];
        List<String> listSRIds=new List<String>();
        for(ServiceResource sr: listBranches){
            listSRIds.add(sr.RelatedRecordId);
        }
        Map<String,String> mapSR=DAL_WK52Report.getAllSalesResourceBranch();
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=DAL_WK52Report.getWk52ReportByTypeAndBranches('CR',listSRIds);//[SELECT ID,SBM__c,Branch__c,Branch_Number__c,Reports__c FROM WK52Report__c Where Report_Type__c ='CR' and Branch_Number__c = :listSRIds order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){ 
            ReportResult RR=new ReportResult();
            RR.SBM=mapSR.get(WK52Rpt.Branch_Number__c);
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        
        return JSON.serialize(listReportResult);
    }
    @AuraEnabled
    public static List<ReportResult> getResultDataWithDate(String branchIds,Date fromDate,Date toDate,Date priorFromDate,Date priorToDate,boolean isUserFilter,String appType){
        List<ReportResult> listReportResult=new List<ReportResult>();
        
        Date CurrentYearStarDate=fromDate;
        Date CurrentYearEndDate=toDate.addDays(1);
        Date PrevYearStarDate=priorFromDate;
        Date PrevYearEndDate=priorToDate.addDays(1);
        
        system.debug('@@getResultData step 1@@:: '+DateTime.now());
        system.debug('CurrentYearStarDate :: '+CurrentYearStarDate);
        system.debug('CurrentYearEndDate :: '+CurrentYearEndDate);
        system.debug('PrevYearStarDate :: '+PrevYearStarDate);
        system.debug('CurrentYearStarDate :: '+PrevYearEndDate);
        system.debug('branchIds  :: '+branchIds );
        
        Boolean hasData=false;
        
        String query='SELECT ID,Createddate,Account_Branch_Profile__c,Account_Branch_Profile__r.Branch__c,Appointment_to_Booking__c,ALT_Days_from_Create_to_Appointment__c,'
                            +' Account_Branch_Profile__r.Branch__r.Name,Account_Branch_Profile__r.Branch__r.Branch_Number__c,'
                            +' Zone__c,Zone__r.ParentTerritoryId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.Name,'
                             +' Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Response_Channel__c, Account.Customer_Type__c,'
                             +' Status__c,StageName,Appointment_DateTime__c,Book_Date_PQM__c,Total_BO_price_quotes__c,Total_BAC_Price_Quote__c,Signed_Contract_Date__c'
                             +' FROM Opportunity ';
        if(isUserFilter){               
            query +=' Where OwnerId = :branchIds  ';
        }else{
            query +=' Where Zone__r.ParentTerritory.Branch__c = :branchIds  ';
        }
        query +=' and RecordType.DeveloperName = \'Replacement\'  ';
        if(appType=='InHome'){
            query +=' and virtual_appointment__c = false  ';
        }else if(appType=='Virtual'){
            query +=' and virtual_appointment__c = true  ';
        }
        query +=' and( (Createddate>= :PrevYearStarDate AND Createddate<= :CurrentYearEndDate)'
            +'    OR '
            +'    (Signed_Contract_Date__c>= :PrevYearStarDate AND Signed_Contract_Date__c<= :CurrentYearEndDate)'
            +'    OR'
            +'    (Book_Date_PQM__c>= :PrevYearStarDate AND Book_Date_PQM__c<= :CurrentYearEndDate)'
            +'   )'
            +'order by Account_Branch_Profile__r.Branch__r.Region__r.Name';
            
        //Gross Opps
        List<Opportunity> listOpportunity;
        listOpportunity=Database.query(query);
       /* if(isUserFilter){
            listOpportunity=[SELECT ID,Createddate,Account_Branch_Profile__c,Account_Branch_Profile__r.Branch__c,Appointment_to_Booking__c,ALT_Days_from_Create_to_Appointment__c,
                             Account_Branch_Profile__r.Branch__r.Name,Account_Branch_Profile__r.Branch__r.Branch_Number__c,
                             Zone__c,Zone__r.ParentTerritoryId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.Name,
                             Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Response_Channel__c, Account.Customer_Type__c,
                             Status__c,StageName,Appointment_DateTime__c,Book_Date_PQM__c,Total_BO_price_quotes__c,Total_BAC_Price_Quote__c,Signed_Contract_Date__c
                             FROM Opportunity Where OwnerId = :branchIds  
                             and( (Createddate>= :PrevYearStarDate AND Createddate<= :CurrentYearEndDate)
                                 OR 
                                 (Signed_Contract_Date__c>= :PrevYearStarDate AND Signed_Contract_Date__c<= :CurrentYearEndDate)
                                 OR
                                 (Book_Date_PQM__c>= :PrevYearStarDate AND Book_Date_PQM__c<= :CurrentYearEndDate)
                                )
                             order by Account_Branch_Profile__r.Branch__r.Region__r.Name ];
        }else{
            listOpportunity=[SELECT ID,Createddate,Account_Branch_Profile__c,Account_Branch_Profile__r.Branch__c,Appointment_to_Booking__c,ALT_Days_from_Create_to_Appointment__c,
                             Account_Branch_Profile__r.Branch__r.Name,Account_Branch_Profile__r.Branch__r.Branch_Number__c,
                             Zone__c,Zone__r.ParentTerritoryId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.Name,
                             Zone__r.ParentTerritory.Branch__r.Branch_Number__c,Response_Channel__c, Account.Customer_Type__c,
                             Status__c,StageName,Appointment_DateTime__c,Book_Date_PQM__c,Total_BO_price_quotes__c,Total_BAC_Price_Quote__c,Signed_Contract_Date__c
                             FROM Opportunity Where Zone__r.ParentTerritory.Branch__c = :branchIds
                             and( (Createddate>= :PrevYearStarDate AND Createddate<= :CurrentYearEndDate)
                                 OR 
                                 (Signed_Contract_Date__c>= :PrevYearStarDate AND Signed_Contract_Date__c<= :CurrentYearEndDate)
                                 OR
                                 (Book_Date_PQM__c>= :PrevYearStarDate AND Book_Date_PQM__c<= :CurrentYearEndDate)
                                )
                             order by Account_Branch_Profile__r.Branch__r.Region__r.Name ];

        }*/
        system.debug('@@ query :: '+query);
        /*if(listOpportunity.size()==0){
            return listReportResult;
        }*/
        if(listOpportunity.size()>0){
            hasData=true;
        }
        
        
        Integer branchWiseThisYearOppCnt=0;
        Integer branchWisePrevYearOppCnt=0;
        
        Integer branchWiseThisYearAOROpps=0;
        Integer branchWisePrevYearAOROpps=0;
        
        Integer branchWiseThisYearBranchGen=0;
        Integer branchWisePrevYearBranchGen=0;
        
        Integer branchWiseThisYearSelfGen=0;
        Integer branchWisePrevYearSelfGen=0;
        
        Integer branchWiseThisYearNewProspects=0;
        Integer branchWisePrevYearNewProspects=0;
        
        Integer branchWiseThisYearCancelled=0;
        Integer branchWisePrevYearCancelled=0;
        
        Integer branchWiseThisYearTransferred=0;
        Integer branchWisePrevYearTransferred=0;
        
        Integer branchWiseThisYearInvCan=0;
        Integer branchWisePrevYearInvCan=0;
        
        Integer branchWiseThisYearInv=0;
        Integer branchWisePrevYearInv=0;      
        
        Integer branchWiseThisYearALT=0;
        Integer branchWisePrevYearALT=0;
        
        Integer branchWiseThisYearALTTotal=0;
        Integer branchWisePrevYearALTTotal=0;      
        
        Integer branchWiseThisYearAB=0;
        Integer branchWisePrevYearAB=0;
        
        Integer branchWiseThisYearABTotal=0;
        Integer branchWisePrevYearABTotal=0;      
        
        //Count Quote 
        Integer branchWiseThisYearQuoCnt=0;
        Integer branchWisePrevYearQuoCnt=0;
        
        Integer branchWiseThisYearContracted=0;
        Integer branchWisePrevYearContracted=0;
        
        Decimal branchWiseThisYearContractedTotalPrce=0;
        Decimal branchWisePrevYearContractedTotalPrce=0;
        
        Integer branchWiseThisYearBookQuoCnt=0;
        Integer branchWisePrevYearBookQuoCnt=0;
        
        Decimal branchWiseThisYearBranchBookings=0;
        Decimal branchWisePrevYearBranchBookings=0;
        
        Decimal branchWiseThisYearBACBookings=0;
        Decimal branchWisePrevYearBACBookings=0;
        
        Decimal branchWiseThisYearBACShipments=0;
        Decimal branchWisePrevYearBACShipments=0;
        
        
        Integer ThisYearR90GCBookOpp=0;
        Integer PrevYearR90GCBookOpp=0;
        
        Integer ThisYearR90GCTotalOpp=0;
        Integer PrevYearR90GCTotalOpp=0;  
        
        Integer ThisYearR90GCStageClosedWonTotalOpp=0;
        Integer PrevYearR90GCStageClosedWonTotalOpp=0;  
        
        Decimal ThisYearR90GCTotalPrice=0;
        Decimal PrevYearR90GCTotalPrice=0;  
        
        Integer ThisYearR12GCBookOpp=0;
        Integer PrevYearR12GCBookOpp=0;
        
        Integer ThisYearR12GCTotalOpp=0;
        Integer PrevYearR12GCTotalOpp=0; 
        
        Integer ThisYearR12GCStageClosedWonTotalOpp=0;
        Integer PrevYearR12GCStageClosedWonTotalOpp=0; 
        
        Decimal ThisYearR12GCTotalPrice=0;
        Decimal PrevYearR12GCTotalPrice=0;  
        
        Integer ThisYearR90GCFCCOpp=0;
        Integer PrevYearR90GCFCCOpp=0; 
        
        Integer ThisYearR90GCFCCTotalOpp=0;
        Integer PrevYearR90GCFCCTotalOpp=0; 
        
        Integer ThisYearGCBookOpp=0;
        Integer PrevYearGCBookOpp=0;
        
        Integer ThisYearGCTotalOpp=0;
        Integer PrevYearGCTotalOpp=0;  
        
        Integer ThisYearGCStageClosedWonTotalOpp=0;
        Integer PrevYearGCStageClosedWonTotalOpp=0;  
        
        Decimal ThisYearGCTotalPrice=0;
        Decimal PrevYearGCTotalPrice=0;  
        
        Integer ThisYearGCFCCOpp=0;
        Integer PrevYearGCFCCOpp=0; 
        
        Integer ThisYearGCFCCTotalOpp=0;
        Integer PrevYearGCFCCTotalOpp=0; 
        
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) Start
       
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                   Opportunity.virtual_appointment__c AppointmentType
                                   FROM Quote 
                                   WHERE (Opportunity.Zone__r.ParentTerritory.Branch__c= :branchIds or Opportunity.ownerId = :branchIds )and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                   and  (BookDate__c>= :priorFromDate AND BookDate__c<= :priorToDate)
                                   and Status in ('Booked', 'Ordered', 'PendingBooked')
                                   and Forecasted__c=true
                                   Group By  Opportunity.virtual_appointment__c]) 
        {
            if(appType=='InHome'){
                if(ar.get('AppointmentType')!=null && (Boolean)ar.get('AppointmentType') == false){
                    branchWisePrevYearBranchBookings=ar.get('TotalPricePQM')==null?0:(decimal)ar.get('TotalPricePQM');
                    branchWisePrevYearBACBookings=ar.get('TotalPriceBAC')==null?0:(decimal)ar.get('TotalPriceBAC');
                }
            }else if(appType=='Virtual'){
                if(ar.get('AppointmentType')!=null && (Boolean)ar.get('AppointmentType') == true){
                    branchWisePrevYearBranchBookings=ar.get('TotalPricePQM')==null?0:(decimal)ar.get('TotalPricePQM');
                    branchWisePrevYearBACBookings=ar.get('TotalPriceBAC')==null?0:(decimal)ar.get('TotalPriceBAC');
                }
            }else{
                branchWisePrevYearBranchBookings+=ar.get('TotalPricePQM')==null?0:(decimal)ar.get('TotalPricePQM');
                branchWisePrevYearBACBookings+=ar.get('TotalPriceBAC')==null?0:(decimal)ar.get('TotalPriceBAC');
            }
            hasData=true;
        }
        
        for (AggregateResult ar : [SELECT sum(Customer_Extended_Price__c) TotalPricePQM ,sum(Total_BAC_Price__c) TotalPriceBAC,
                                   Opportunity.virtual_appointment__c AppointmentType
                                   FROM Quote 
                                   WHERE (Opportunity.Zone__r.ParentTerritory.Branch__c= :branchIds or Opportunity.ownerId = :branchIds )and Opportunity.RecordType.DeveloperName = 'Replacement' 
                                   and  (BookDate__c>= :fromDate AND BookDate__c<= :toDate)
                                   and Status in ('Booked', 'Ordered', 'PendingBooked')
                                   and Forecasted__c=true
                                   Group By  Opportunity.virtual_appointment__c]) 
        {
            if(appType=='InHome'){
                if(ar.get('AppointmentType')!=null && (Boolean)ar.get('AppointmentType') == false){
                    branchWiseThisYearBranchBookings=ar.get('TotalPricePQM')==null?0:(decimal)ar.get('TotalPricePQM');
                    branchWiseThisYearBACBookings=ar.get('TotalPriceBAC')==null?0:(decimal)ar.get('TotalPriceBAC');
                }
            }else if(appType=='Virtual'){
                if(ar.get('AppointmentType')!=null && (Boolean)ar.get('AppointmentType') == true){
                    branchWiseThisYearBranchBookings=ar.get('TotalPricePQM')==null?0:(decimal)ar.get('TotalPricePQM');
                    branchWiseThisYearBACBookings=ar.get('TotalPriceBAC')==null?0:(decimal)ar.get('TotalPriceBAC');
                }
            }else{
                branchWiseThisYearBranchBookings+=ar.get('TotalPricePQM')==null?0:(decimal)ar.get('TotalPricePQM');
                branchWiseThisYearBACBookings+=ar.get('TotalPriceBAC')==null?0:(decimal)ar.get('TotalPriceBAC');
            }
            hasData=true;
        }
        
        //W-001249 : Changes realted to Quote Calculation (12-08-2022) End
        if(!hasData){
            return listReportResult;
        }
        
        for(Opportunity opp: listOpportunity){
            if(opp.Createddate>= PrevYearStarDate && opp.Createddate<= CurrentYearEndDate){
                
                // previous year Data
                if(Opp.Createddate<CurrentYearStarDate){
                    if( opp.Createddate<= PrevYearEndDate){
                        
                        branchWisePrevYearOppCnt++;
                        
                        //AOR Opps
                        if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                            branchWisePrevYearAOROpps++;
                        }else if(opp.Response_Channel__c=='Branch Gen'){
                            branchWisePrevYearBranchGen++;
                        }else if(opp.Response_Channel__c=='Self Gen'){
                            branchWisePrevYearSelfGen++;
                        }
                        if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                            branchWisePrevYearNewProspects++;
                        }
                        if(opp.Status__c=='Canceled'){
                            branchWisePrevYearCancelled++;
                        }
                        if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                            branchWisePrevYearTransferred++;
                        }
                        //if(opp.StageName=='Closed')
                        {
                            branchWisePrevYearInvCan++;
                            if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                                branchWisePrevYearInv++;
                            }                    
                        }
                        if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                             opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                           && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                               if(opp.Appointment_DateTime__c!=null){
                                   
                                   if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                       
                                       branchWisePrevYearALTTotal++;
                                       branchWisePrevYearALT+=Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c);
                                   } 
                               }
                           }
                        //Appointment to Book
                        if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                            if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                                
                                branchWisePrevYearABTotal++;
                                branchWisePrevYearAB+=Integer.valueOf(opp.Appointment_to_Booking__c);
                            }
                        }
                        
                        // New logic added on 22-04
                        PrevYearGCTotalOpp++;
                        
                        if(opp.StageName=='Closed Won'){
                                
                            if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c>= PrevYearStarDate && opp.Book_Date_PQM__c<= PrevYearEndDate)){
                                    
                                PrevYearGCTotalPrice+=((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c));
                                PrevYearGCStageClosedWonTotalOpp++;
                            
                                if(opp.Book_Date_PQM__c!=null){
                                    if(opp.Status__c=='First Call Close'){ 
                                        PrevYearGCFCCOpp++;
                                    }  
                                    PrevYearGCFCCTotalOpp++;
                                }
                                if(opp.Book_Date_PQM__c!=null){
                                    PrevYearGCBookOpp++;
                                }
                            }
                        }
                        // New logic added on 22-04 end
                    }
                }
                // current year data
                else{
                    
                    branchWiseThisYearOppCnt++;
                    
                    //AOR Opps
                    if(!(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen')){
                        branchWiseThisYearAOROpps++;
                    }else if(opp.Response_Channel__c=='Branch Gen'){
                        branchWiseThisYearBranchGen++;
                    }else if(opp.Response_Channel__c=='Self Gen'){
                        branchWiseThisYearSelfGen++;
                    }
                    if(opp.Response_Channel__c=='Self Gen' && opp.Account.Customer_Type__c=='New Prospect'){
                        branchWiseThisYearNewProspects++;
                    }
                    if(opp.Status__c=='Canceled'){
                        branchWiseThisYearCancelled++;
                    }
                    if(opp.StageName=='Closed' && (opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service') ){
                        branchWiseThisYearTransferred++;
                    }
                    //if(opp.StageName=='Closed')
                    {
                        branchWiseThisYearInvCan++;
                        if(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service'){
                            branchWiseThisYearInv++;
                        }     
                    }
                    if(!(opp.Status__c=='Canceled' || opp.Status__c=='Transferred to Commercial' || 
                         opp.Status__c=='Transferred to New Construction' || opp.Status__c=='Transferred to Service')
                       && !(opp.Response_Channel__c=='Branch Gen' || opp.Response_Channel__c=='Self Gen'))
                    {
                        if(opp.Appointment_DateTime__c!=null){
                            
                            if(Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c)>=0){
                                
                                branchWiseThisYearALTTotal++;
                                branchWiseThisYearALT+= Integer.valueOf(opp.ALT_Days_from_Create_to_Appointment__c);
                            } 
                        }
                        
                    }
                    //Appointment to Book
                    if(opp.Book_Date_PQM__c!=null && opp.Appointment_DateTime__c!=null){
                        if(Integer.valueOf(opp.Appointment_to_Booking__c)>=0){
                            
                            branchWiseThisYearABTotal++;
                            branchWiseThisYearAB+=Integer.valueOf(opp.Appointment_to_Booking__c);
                        }
                    }
                    
                    // New logic added on 22-04
                    ThisYearGCTotalOpp++;
                    
                    if(opp.StageName=='Closed Won'){
                        if(opp.Book_Date_PQM__c!=null && ( opp.Book_Date_PQM__c>=CurrentYearStarDate && opp.Book_Date_PQM__c<= CurrentYearEndDate)){
                            ThisYearGCTotalPrice+=((Opp.Total_BO_price_quotes__c==null?0:Opp.Total_BO_price_quotes__c));
                            ThisYearGCStageClosedWonTotalOpp++;
                        
                            if(opp.Book_Date_PQM__c!=null){
                                if(opp.Status__c=='First Call Close'){ 
                                    ThisYearGCFCCOpp++;
                                }
                                ThisYearGCFCCTotalOpp++;   
                            } 
                            if(opp.Book_Date_PQM__c!=null){
                                ThisYearGCBookOpp++;
                            }
                        }
                        
                    }
                }
            }
            
            // list Signed Contract Date
            if(opp.Status__c!='Canceled' && (opp.StageName =='Closed Won' || opp.StageName =='Contracted')){
                if(opp.Signed_Contract_Date__c !=null && opp.Signed_Contract_Date__c>= PrevYearStarDate && opp.Signed_Contract_Date__c<= CurrentYearEndDate){
                    
                    // previous year Data
                    if(opp.Signed_Contract_Date__c < CurrentYearStarDate){
                        if( opp.Signed_Contract_Date__c< PrevYearEndDate){
                            //Contracted
                            
                            branchWisePrevYearContracted++;
                            branchWisePrevYearContractedTotalPrce+=(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c);
                        }
                    } else{
                        
                        //Contracted
                        
                        branchWiseThisYearContracted++;
                        branchWiseThisYearContractedTotalPrce+=(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c);
                        
                    }
                }
            }
            //listBookDateQuote // Commented as new logic added as per new ticket W-001249
            /*if(opp.StageName=='Closed Won'){
                if(opp.Book_Date_PQM__c>= PrevYearStarDate && opp.Book_Date_PQM__c<= CurrentYearEndDate){
                    
                    // previous year Data
                    if(opp.Book_Date_PQM__c < CurrentYearStarDate){
                        if( opp.Book_Date_PQM__c< PrevYearEndDate){
                            //Contracted
                            if(opp.Total_BO_price_quotes__c != null){
                                branchWisePrevYearBranchBookings+=(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c);
                            }
                            
                            if(opp.Total_BAC_Price_Quote__c != null){
                                branchWisePrevYearBACBookings+=(opp.Total_BAC_Price_Quote__c==null?0:opp.Total_BAC_Price_Quote__c);
                            }
                        }
                    } else{
                        
                        if(opp.Total_BO_price_quotes__c != null){
                            branchWiseThisYearBranchBookings+=(opp.Total_BO_price_quotes__c==null?0:opp.Total_BO_price_quotes__c);
                        }
                        
                        if(opp.Total_BAC_Price_Quote__c != null){
                            branchWiseThisYearBACBookings+=(opp.Total_BAC_Price_Quote__c==null?0:opp.Total_BAC_Price_Quote__c);
                        }
                        
                    }
                }
            }*/
        }
        set<String> setBranchNames=new set<String>();
        Map<String,String> branchWiseRegionName=new Map<String,String>();
        if(isUserFilter){
            for(User u: [SELECT ID,Name FROM User where Id =:branchIds Order By Name ]){
                setBranchNames.add(u.Id);
                branchWiseRegionName.put(u.Id,u.Name);
            }
        }else{
            for(Branch__c branch: [SELECT ID,Branch_Number__c,Name,Region__c,Region__r.Name FROM Branch__c where Id =:branchIds Order By Region__r.Name ]){
                setBranchNames.add(branch.Branch_Number__c+'-'+branch.Name);
                branchWiseRegionName.put(branch.Branch_Number__c+'-'+branch.Name,branch.Region__r.Name);
            }
        }
        for(String branchName : setBranchNames){
            ReportResult RR=new ReportResult();
            if(isUserFilter){
                RR.Branch=branchWiseRegionName.get(branchName);
            }else{
                RR.Branch=branchName;
                RR.SBM=branchWiseRegionName.get(branchName);
            }
            
            RR.reports=new List<report>();
            
            //Gross Opps
            report rpt=new report();
            rpt.reportLabel='Gross Opps';
            rpt.actualYear=branchWiseThisYearOppCnt;
            rpt.priorYear =branchWisePrevYearOppCnt;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //AOR Opps
            rpt=new report();
            rpt.reportLabel='AOR Opps';
            rpt.actualYear=branchWiseThisYearAOROpps;
            rpt.priorYear =branchWisePrevYearAOROpps;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=false;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //Branch Opps
            rpt=new report();
            rpt.reportLabel='Branch Opps';
            rpt.actualYear=branchWiseThisYearBranchGen;
            rpt.priorYear =branchWisePrevYearBranchGen;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=false;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //Self Gen Opps
            rpt=new report();
            rpt.reportLabel='Self Gen Opps';
            rpt.actualYear=branchWiseThisYearSelfGen;
            rpt.priorYear =branchWisePrevYearSelfGen;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
             if(isUserFilter){
                 rpt.IsVisibleactualYear=true;
                 rpt.IsVisiblepriorYear=false;
                 rpt.IsVisibleToPy=true;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //New Prospects Opps
            rpt=new report();
            rpt.reportLabel='New Prospects Opps';
            rpt.actualYear=branchWiseThisYearNewProspects;
            rpt.priorYear =branchWisePrevYearNewProspects;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //Cancelled Opps
            rpt=new report();
            rpt.reportLabel='Canceled Opps';
            rpt.actualYear=branchWiseThisYearCancelled;
            rpt.priorYear =branchWisePrevYearCancelled;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=false;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            //display
            
            //Transferred Opps
            rpt=new report();
            rpt.reportLabel='Transferred Opps';
            rpt.actualYear=branchWiseThisYearTransferred;
            rpt.priorYear =branchWisePrevYearTransferred;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=false;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            //display
            
            //Inv/Can Opps
            rpt=new report();
            rpt.reportLabel='Transfer/Can Opps';
            
            rpt.actualYearData=branchWiseThisYearInv;
            rpt.actualYearDataTotal=branchWiseThisYearInvCan;
            
            if(branchWiseThisYearInvCan>0){
                rpt.actualYear=branchWiseThisYearInv/(decimal)branchWiseThisYearInvCan;
            }else{
                rpt.actualYear = 0;
            }
            
            rpt.priorYearData=branchWisePrevYearInv;
            rpt.priorYearDataTotal=branchWisePrevYearInvCan;
            
            if(branchWisePrevYearInvCan>0){
                rpt.priorYear =branchWisePrevYearInv/(decimal)branchWisePrevYearInvCan;
            }else{
                rpt.priorYear = 0;
            }
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            //ALT Opps
            rpt=new report();
            rpt.reportLabel='ALT';
            
            rpt.actualYearData=branchWiseThisYearALT;
            rpt.actualYearDataTotal=branchWiseThisYearALTTotal;
            
            if(branchWiseThisYearALTTotal>0){
                rpt.actualYear=branchWiseThisYearALT/(decimal)branchWiseThisYearALTTotal;
            }else{
                rpt.actualYear = 0;
            }
            
            rpt.priorYearData=branchWisePrevYearALT;
            rpt.priorYearDataTotal=branchWisePrevYearALTTotal;
            
            if( branchWisePrevYearALTTotal>0){
                rpt.priorYear =branchWisePrevYearALT/(decimal)branchWisePrevYearALTTotal;
            }else{
                rpt.priorYear = 0;
            }
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=false;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            
            //Appointment to Book Opps
            rpt=new report();
            rpt.reportLabel='Appointment to Book';
            
            rpt.actualYearData=branchWiseThisYearAB;
            rpt.actualYearDataTotal=branchWiseThisYearABTotal;
            
            if(branchWiseThisYearABTotal>0){
                rpt.actualYear=branchWiseThisYearAB/(decimal)branchWiseThisYearABTotal;
            }else{
                rpt.actualYear = 0;
            }
            
            rpt.priorYearData=branchWisePrevYearAB;
            rpt.priorYearDataTotal=branchWisePrevYearABTotal;
            
            if(branchWisePrevYearABTotal>0){
                rpt.priorYear =branchWisePrevYearAB/(decimal)branchWisePrevYearABTotal;
            }else{
                rpt.priorYear = 0;
            }
            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //Contracted
            rpt=new report();
            rpt.reportLabel='Contracted';
            rpt.actualYear=branchWiseThisYearContracted;
            rpt.priorYear =branchWisePrevYearContracted;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.markGreen=false;
            //display
            RR.reports.add(rpt);
            
            //$ Contracted 
            rpt=new report();
            rpt.reportLabel='$Contracted';
            rpt.actualYear=branchWiseThisYearContractedTotalPrce;
            rpt.priorYear =branchWisePrevYearContractedTotalPrce;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);  
            
            //Branch Bookings
            rpt=new report();
            rpt.reportLabel='Branch Bookings';
            rpt.actualYear=branchWiseThisYearBranchBookings;
            rpt.priorYear =branchWisePrevYearBranchBookings;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //BAC Bookings
            rpt=new report();
            rpt.reportLabel='BAC Bookings';
            rpt.actualYear=branchWiseThisYearBACBookings;
            rpt.priorYear =branchWisePrevYearBACBookings;            
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=false;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //BAC Shipments
            rpt=new report();
            rpt.reportLabel='BAC Shipments';
            rpt.actualYear=branchWiseThisYearBACShipments;
            rpt.priorYear =branchWisePrevYearBACShipments;   
            //rpt.ToPy=(rpt.actualYear-rpt.priorYear)/(rpt.priorYear==0?1:rpt.priorYear);
            rpt.IsVisibleactualYear=false;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=false;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.IsCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            //display
            
            //R90 Gross Close Ratio
           /* rpt=new report();
            rpt.reportLabel='R90 Gross Close Ratio';
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            //R90 Gross Yield
            rpt=new report();
            rpt.reportLabel='R90 Gross Yield';
            
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R90 Average Job Size';
            
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //R90 FCC %
            rpt=new report();
            rpt.reportLabel='R90 FCC %';
            
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            //R12 Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='R12 Gross Close Ratio';
            
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsPercentage=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //R12 Gross Yield
            rpt=new report();
            rpt.reportLabel='R12 Gross Yield';
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            //R90 Average Job Size
            rpt=new report();
            rpt.reportLabel='R12 Average Job Size';
            
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);*/
            
           
               // New logic added on 22-04
            //Gross Close Ratio
            rpt=new report();
            rpt.reportLabel='Gross Close Ratio';
            rpt.actualYearData=ThisYearGCBookOpp;
            rpt.actualYearDataTotal=ThisYearGCTotalOpp;
            if(ThisYearGCTotalOpp>0){
                rpt.actualYear=ThisYearGCBookOpp/(decimal)ThisYearGCTotalOpp;
            }else{
                rpt.actualYear = 0;
            }
            
            rpt.priorYearData=PrevYearGCBookOpp;
            rpt.priorYearDataTotal=PrevYearGCTotalOpp;
            
            if(PrevYearGCTotalOpp>0){
                rpt.priorYear =PrevYearGCBookOpp/(decimal)PrevYearGCTotalOpp;
            }else{
                rpt.priorYear = 0;
            }
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.markGreen=false;
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            //Gross Yield
            rpt=new report();
            rpt.reportLabel='Gross Yield';
            rpt.actualYearData=ThisYearGCTotalPrice;
            rpt.actualYearDataTotal=ThisYearGCTotalOpp;
            if(ThisYearGCTotalOpp>0){
                rpt.actualYear =ThisYearGCTotalPrice/(decimal)ThisYearGCTotalOpp;
            }else{
                rpt.actualYear = 0;
            }
            rpt.priorYearData=PrevYearGCTotalPrice;
            rpt.priorYearDataTotal=PrevYearGCTotalOpp;
            if(PrevYearGCTotalOpp>0){
                rpt.priorYear =PrevYearGCTotalPrice/(decimal)PrevYearGCTotalOpp;
            }else{
                rpt.priorYear = 0;
            }
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            // Average Job Size
            rpt=new report();
            rpt.reportLabel='Average Job Size';
            rpt.actualYearData=ThisYearGCTotalPrice;
            rpt.actualYearDataTotal=ThisYearGCStageClosedWonTotalOpp;
            if(ThisYearGCStageClosedWonTotalOpp>0){
                rpt.actualYear =ThisYearGCTotalPrice/(decimal)ThisYearGCStageClosedWonTotalOpp;
            }else{
                rpt.actualYear = 0;
            }
            rpt.priorYearData=PrevYearGCTotalPrice;
            rpt.priorYearDataTotal=PrevYearGCStageClosedWonTotalOpp;
            if(PrevYearGCStageClosedWonTotalOpp>0){
                rpt.priorYear =PrevYearGCTotalPrice/(decimal)PrevYearGCStageClosedWonTotalOpp;
            }else{
                rpt.priorYear = 0;
            }
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=true;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=true;
            }
            rpt.IsCurrency=true;
            rpt.IsPYCurrency=true;
            rpt.markGreen=false;
            RR.reports.add(rpt);
            
            // FCC %
            rpt=new report();
            rpt.reportLabel='FCC %';
            rpt.actualYearData=ThisYearGCFCCOpp;
            rpt.actualYearDataTotal=ThisYearGCFCCTotalOpp;
            if(ThisYearGCFCCTotalOpp>0){
                rpt.actualYear =ThisYearGCFCCOpp/(decimal)ThisYearGCFCCTotalOpp;
            }else{
                rpt.actualYear = 0;
            }
            rpt.priorYearData=PrevYearGCFCCOpp;
            rpt.priorYearDataTotal=PrevYearGCFCCTotalOpp;
            if(PrevYearGCFCCTotalOpp>0){
                rpt.priorYear =PrevYearGCFCCOpp/(decimal)PrevYearGCFCCTotalOpp;
            }else{
                rpt.priorYear = 0;
            }
            rpt.IsVisibleactualYear=true;
            rpt.IsVisiblepriorYear=false;
            rpt.IsVisibleToPy=false;
            if(isUserFilter){
                rpt.IsVisibleactualYear=true;
                rpt.IsVisiblepriorYear=false;
                rpt.IsVisibleToPy=false;
            }
            rpt.IsPercentage=true;
            RR.reports.add(rpt);
            
            listReportResult.add(RR);
        }
      
        return listReportResult;
    }
    @AuraEnabled
    public static Map<String,Object> getCRReportResultForRank() {
        Map<String,Object> returnResult=new Map<String,Object>();
        Integer FiscalMonth=0;
        for(Period P:[SELECT Id,Number,Type FROM Period WHERE Type ='MONTH' and StartDate <= TODAY AND EndDate >= TODAY]){
            FiscalMonth=P.Number;
        }
        if(FiscalMonth!=0){
            
            for(Monthly_Qualifiers_Config__mdt  MonthQualifiers :[SELECT ID,Opportunity_Count__c,Bookings__c FROM Monthly_Qualifiers_Config__mdt Where FiscalMonth__c=:FiscalMonth]){
                returnResult.put('OppCount',MonthQualifiers.Opportunity_Count__c);
                returnResult.put('Bookings',MonthQualifiers.Bookings__c);
            }
        }
        /*Map<String,String> mapSR=new Map<String,String>();
        List<ServiceResource> listBranches=[SELECT Id, Name, Primary_Replacement_Territory__r.Name,RelatedRecordId, IsActive FROM ServiceResource
                                            Where  Replacement_Sales_Rep__c =true order by name];
        List<String> listSRIds=new List<String>();
        for(ServiceResource sr: listBranches){
            mapSR.put(sr.RelatedRecordId,sr.Primary_Replacement_Territory__r.Name);
        }*/
        
        Map<String,String> mapSR=DAL_WK52Report.getAllSalesResourceBranch();
        
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=DAL_WK52Report.getWk52ReportByType('CR');//[SELECT ID,SBM__c,Branch__c,Branch_Number__c,Reports__c FROM WK52Report__c Where Report_Type__c ='CR' and Branch_Number__c = :listSRIds order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){ 
            ReportResult RR=new ReportResult();
            RR.SBM=mapSR.get(WK52Rpt.Branch_Number__c);
            RR.Branch=WK52Rpt.Branch__c;
            RR.reportsData=WK52Rpt.Reports__c;
            RR.IsCurrentUser=WK52Rpt.Branch_Number__c==UserInfo.getUserId();
            listReportResult.add(RR);
        }
        returnResult.put('Result',listReportResult);
        return returnResult;
    }
   
    public class ReportResult{
        @AuraEnabled
        public string SBM;
        @AuraEnabled
        public String Branch;
        @AuraEnabled
        public List<report> reports;
        @AuraEnabled
        public boolean IsCurrentUser;
        @AuraEnabled
        public String reportsData;
    }
    public class report{
        @AuraEnabled
        public string reportLabel;
        @AuraEnabled
        public Decimal actualYear;
        @AuraEnabled
        public  Decimal actualYearData;
        @AuraEnabled
        public  Decimal actualYearDataTotal;
       
        @AuraEnabled
        public Decimal priorYear;
        @AuraEnabled
        public  Decimal priorYearData;
        @AuraEnabled
        public  Decimal priorYearDataTotal;
       
        @AuraEnabled
        public Decimal ToPy;
        @AuraEnabled
        public boolean IsVisibleactualYear;
        @AuraEnabled
        public boolean IsVisiblepriorYear;
        @AuraEnabled
        public boolean IsVisibleToPy;
        @AuraEnabled
        public boolean IsCurrency;
        @AuraEnabled
        public boolean IsPYCurrency;
        @AuraEnabled
        public boolean markGreen;
        @AuraEnabled
        public boolean IsPercentage;
       
        
        public report(){
            IsVisibleactualYear=false;
            IsVisiblepriorYear=false;
            IsVisibleToPy=false;
            IsCurrency=false;
            IsPYCurrency=false;
            IsPercentage=false;
          
        }
    }
  
    
}