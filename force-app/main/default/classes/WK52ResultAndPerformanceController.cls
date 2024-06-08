public class WK52ResultAndPerformanceController {
   /* public final static Date baseDate=Date.newInstance(2019, 12, 1);
    
    @AuraEnabled
    public static String getResult() {
        List<ReportResult> listReportResult=getResultData();
        system.debug('@@jsonresult step 14@@:: '+DateTime.now());
        String jsonresult = JSON.serialize(listReportResult);
        system.debug('@@jsonresult step 15@@:: '+DateTime.now());
        return jsonresult;
    }
    
    @AuraEnabled
    public static String getMTDResult() {
        List<ReportResult> listReportResult=getMTDResultData();
        String jsonresult = JSON.serialize(listReportResult);
        return jsonresult;
    }
    @AuraEnabled
    public static String getCoachingReportResult() {
        List<ReportResult> listReportResult=getCoachingReportResultData();
        String jsonresult = JSON.serialize(listReportResult);
        return jsonresult;
    }
     public static List<ReportResult> getResultData(){
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=[SELECT ID,SBM__c,Branch__c,Reports__c FROM WK52Report__c Where Report_Type__c ='YTD' order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){
            ReportResult RR=new ReportResult();
            RR.SBM=WK52Rpt.SBM__c;
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        
        return listReportResult;
    }
    public static List<ReportResult> getMTDResultData(){
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=[SELECT ID,SBM__c,Branch__c,Reports__c FROM WK52Report__c Where Report_Type__c ='MTD' order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){
            ReportResult RR=new ReportResult();
            RR.SBM=WK52Rpt.SBM__c;
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        
        return listReportResult;
    }
    public static List<ReportResult> getCoachingReportResultData(){
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=[SELECT ID,SBM__c,Branch__c,Reports__c FROM WK52Report__c Where Report_Type__c ='CR' order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){
            ReportResult RR=new ReportResult();
            RR.SBM=WK52Rpt.SBM__c;
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        
        return listReportResult;
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
      /*  }
        return listResult;
    }
    public class ReportResult{
        public string SBM;
        public String Branch;
        public List<report> reports;
    }
    public class report{
        public string reportLabel;
        public Decimal actualYear;
        public Decimal priorYear;
        public Decimal ToPy;
        public boolean IsVisibleactualYear;
        public boolean IsVisiblepriorYear;
        public boolean IsVisibleToPy;
        public boolean IsCurrency;
        public boolean IsPYCurrency;
        public boolean markGreen;
        public report(){
            IsVisibleactualYear=false;
            IsVisiblepriorYear=false;
            IsVisibleToPy=false;
            IsCurrency=false;
            IsPYCurrency=false;
        }
    }*/
}