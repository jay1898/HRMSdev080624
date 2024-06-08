public class WK52ResultAndPerformanceMTDVFController {
    /*public final static Date baseDate=Date.newInstance(2019, 12, 1);
    public List<ReportResult> listReportResults {get;set;}
    public string xmlheader {get;set;}
    public string endfile {get;set;}
    public WK52ResultAndPerformanceMTDVFController(){
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
        listReportResults= getResultData();
    }
    public static List<ReportResult> getResultData(){
        List<ReportResult> listReportResult=new List<ReportResult>();
        List<WK52Report__c> WK52Report=[SELECT ID,SBM__c,Branch__c,Reports__c FROM WK52Report__c Where report_type__c='MTD' order by SBM__c];
        for(WK52Report__c WK52Rpt : WK52Report){
            ReportResult RR=new ReportResult();
            RR.SBM=WK52Rpt.SBM__c;
            RR.Branch=WK52Rpt.Branch__c;
            RR.Reports=(List<report>)JSON.deserialize(WK52Rpt.Reports__c,List<report>.class);
            listReportResult.add(RR);
        }
        Map<String, Boolean> mapSortAscDesc = new Map<String, Boolean>();
        
        Map<String,Map<String,report>> Region=new Map<String,Map<String,report>>();
        Map<String,report> grandTotal=new Map<String,report>();
        Set<String> listReportLabel=new Set<String> ();
        for(ReportResult res : listReportResult){
            for(Report rpt : res.reports){
                
                if(rpt.toPY!=null)
                    rpt.toPY=rpt.toPY/100;	
                if(!Region.containsKey(res.SBM)){
                    Region.put(res.SBM,new Map<String,Report>());
                }
                if(!Region.get(res.SBM).containsKey(rpt.reportLabel)){
                    Report reportData=new Report();
                    reportData.actualYear=0;
                    reportData.priorYear=0;
                    Region.get(res.SBM).put(rpt.reportLabel,reportData);
                }
                Region.get(res.SBM).get(rpt.reportLabel).actualYear+=rpt.actualYear;
                Region.get(res.SBM).get(rpt.reportLabel).priorYear+=rpt.priorYear;
                Region.get(res.SBM).get(rpt.reportLabel).IsVisibleactualYear=rpt.IsVisibleactualYear;
                Region.get(res.SBM).get(rpt.reportLabel).IsVisiblepriorYear=rpt.IsVisiblepriorYear;
                Region.get(res.SBM).get(rpt.reportLabel).IsVisibleToPy=rpt.IsVisibleToPy;
                Region.get(res.SBM).get(rpt.reportLabel).IsCurrency=rpt.IsCurrency;
                Region.get(res.SBM).get(rpt.reportLabel).IsPYCurrency=rpt.IsPYCurrency;
                
                if(!grandTotal.containsKey(rpt.reportLabel)){
                    Report reportData=new Report();
                    reportData.actualYear=0;
                    reportData.priorYear=0;
                    grandTotal.put(rpt.reportLabel,reportData);
                }
                grandTotal.get(rpt.reportLabel).actualYear+=rpt.actualYear;
                grandTotal.get(rpt.reportLabel).priorYear+=rpt.priorYear;
                grandTotal.get(rpt.reportLabel).IsVisibleactualYear=rpt.IsVisibleactualYear;
                grandTotal.get(rpt.reportLabel).IsVisiblepriorYear=rpt.IsVisiblepriorYear;
                grandTotal.get(rpt.reportLabel).IsVisibleToPy=rpt.IsVisibleToPy;
                grandTotal.get(rpt.reportLabel).IsCurrency=rpt.IsCurrency;
                grandTotal.get(rpt.reportLabel).IsPYCurrency=rpt.IsPYCurrency;
                listReportLabel.add(rpt.reportLabel);
            }
        }
           
        
        List<ReportResult> listReportResultNew=new List<ReportResult>();
        
        
        ReportResult totalRow=new ReportResult();
        totalRow.SBM='Grand Total';
        totalRow.Branch='';
        totalRow.reports=new List<Report>();
        for(String rptLabel : listReportLabel){
            Report reportData=new Report();
            reportData.reportLabel=rptLabel;
            reportData.actualYear=grandTotal.containsKey(rptLabel)?grandTotal.get(rptLabel).actualYear:0;
            reportData.priorYear=grandTotal.containsKey(rptLabel)?grandTotal.get(rptLabel).priorYear:0;
            reportData.ToPy=((reportData.actualYear-reportData.priorYear)/(reportData.priorYear==0?1:reportData.priorYear))/100;
            reportData.IsVisibleactualYear=grandTotal.containsKey(rptLabel)?grandTotal.get(rptLabel).IsVisibleactualYear:false;
            reportData.IsVisiblepriorYear=grandTotal.containsKey(rptLabel)?grandTotal.get(rptLabel).IsVisiblepriorYear:false;
            reportData.IsVisibleToPy=grandTotal.containsKey(rptLabel)?grandTotal.get(rptLabel).IsVisibleToPy:false;
            reportData.IsCurrency=grandTotal.containsKey(rptLabel)?grandTotal.get(rptLabel).IsCurrency:false;
            reportData.IsPYCurrency=grandTotal.containsKey(rptLabel)?grandTotal.get(rptLabel).IsPYCurrency:false;
            totalRow.reports.add(reportData);
        }
        listReportResultNew.add(totalRow);
        
        String prevSBM='';
        for(ReportResult RR : listReportResult){
            
            if(RR.SBM!=prevSBM && prevSBM!=''){
                
                totalRow=new ReportResult();
                totalRow.SBM=prevSBM+' Total';
                totalRow.Branch='';
                totalRow.reports=new List<Report>();
                for(String rptLabel : listReportLabel){
                    Report reportData=new Report();
                    reportData.reportLabel=rptLabel;
                    reportData.actualYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).actualYear:0):0;
                    reportData.priorYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).priorYear:0):0;
                    reportData.ToPy=((reportData.actualYear-reportData.priorYear)/(reportData.priorYear==0?1:reportData.priorYear))/100;
                    reportData.IsVisibleactualYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsVisibleactualYear:false):false;
                    reportData.IsVisiblepriorYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsVisiblepriorYear:false):false;
                    reportData.IsVisibleToPy=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsVisibleToPy:false):false;
                    reportData.IsCurrency=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsCurrency:false):false;
                    reportData.IsPYCurrency=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsPYCurrency:false):false;
                    totalRow.reports.add(reportData);
                }
                listReportResultNew.add(totalRow);
            }
            prevSBM=RR.SBM;
            listReportResultNew.add(RR);
        }
        if(prevSBM!=''){
            totalRow=new ReportResult();
            totalRow.SBM=prevSBM+' Total';
            totalRow.Branch='';
            totalRow.reports=new List<Report>();
            for(String rptLabel : listReportLabel){
                Report reportData=new Report();
                reportData.reportLabel=rptLabel;
                reportData.actualYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).actualYear:0):0;
                reportData.priorYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).priorYear:0):0;
                reportData.ToPy=((reportData.actualYear-reportData.priorYear)/(reportData.priorYear==0?1:reportData.priorYear))/100;
                reportData.IsVisibleactualYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsVisibleactualYear:false):false;
                reportData.IsVisiblepriorYear=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsVisiblepriorYear:false):false;
                reportData.IsVisibleToPy=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsVisibleToPy:false):false;
                reportData.IsCurrency=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsCurrency:false):false;
                reportData.IsPYCurrency=Region.containsKey(prevSBM)?(Region.get(prevSBM).containsKey(rptLabel)?Region.get(prevSBM).get(rptLabel).IsPYCurrency:false):false;
                totalRow.reports.add(reportData);
            }
            listReportResultNew.add(totalRow);
        }
        
        Map<String, Set<decimal>> mapReportWiseAmount = new Map<String, Set<decimal>>();
        for(ReportResult RR : listReportResult){
            for(report rpt : RR.reports){
                system.debug('@@'+rpt);
                if(rpt.IsVisibleactualYear){
                    if(!mapReportWiseAmount.containsKey(rpt.reportLabel)){
                        mapReportWiseAmount.put(rpt.reportLabel, new Set<decimal>());
                    }
                    else{
                        if(rpt.actualYear != 0){
                            mapReportWiseAmount.get(rpt.reportLabel).add(rpt.actualYear);
                        }
                    }
                }else if(rpt.IsVisiblepriorYear){
                    if(!mapReportWiseAmount.containsKey(rpt.reportLabel)){
                        mapReportWiseAmount.put(rpt.reportLabel, new Set<decimal>());
                    }
                    else{
                        if(rpt.priorYear != 0){
                            mapReportWiseAmount.get(rpt.reportLabel).add(rpt.priorYear);
                        }
                    }
                }else if(rpt.IsVisibleToPy){
                    if(!mapReportWiseAmount.containsKey(rpt.reportLabel)){
                        mapReportWiseAmount.put(rpt.reportLabel, new Set<decimal>());
                    }
                    else{
                        if(rpt.ToPy != 0){
                            mapReportWiseAmount.get(rpt.reportLabel).add(rpt.ToPy);
                        }                        
                    }
                }    
            }
        }
        
        // Sorting of Report Amount
        for(String rptLabel : mapSortAscDesc.keySet()){
            if(mapReportWiseAmount.containsKey(rptLabel)){
                Boolean flag = mapSortAscDesc.get(rptLabel);
                Set<decimal> values = new Set<decimal>();
                values.addAll(mapReportWiseAmount.get(rptLabel));
                mapReportWiseAmount.put(rptLabel,sorting(flag,values));
            }
        }
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
        
        return listReportResultNew; 
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
        public string SBM {get;set;}
        public String Branch{get;set;}
        public List<report> reports{get;set;}
    }
    public class report{
        public string reportLabel{get;set;}
        public Decimal actualYear{get;set;}
        public boolean IsVisibleactualYear{get;set;}
        public Decimal priorYear{get;set;}
        public boolean IsVisiblepriorYear{get;set;}
        public Decimal ToPy{get;set;}
        public boolean IsVisibleToPy{get;set;}
        public boolean IsCurrency{get;set;}
        public boolean IsPYCurrency{get;set;}
        public boolean markGreen{get;set;}
    }*/
}