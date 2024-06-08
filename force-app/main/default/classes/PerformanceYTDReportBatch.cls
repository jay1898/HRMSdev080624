public class PerformanceYTDReportBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
	
    public Map<String,PerformanceReportBatchHandler.ReportResult> mapReportResult=new Map<String,PerformanceReportBatchHandler.ReportResult>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
       // return Database.getQueryLocator('SELECT ID FROM Opportunity ');
       Date prevYearDate=Date.today().addMonths(-24);
        return Database.getQueryLocator('SELECT ID FROM Opportunity where Createddate>= :prevYearDate and RecordType.DeveloperName = \'Replacement\' order by branch_number__c ');
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> records){
        try{
            List<Id> OppIds=new List<Id>();
            for(Opportunity Opp :records ){
                OppIds.add(opp.Id);
            }
            Map<String,PerformanceReportBatchHandler.ReportResult> mapRR=PerformanceReportBatchHandler.getResultData(OppIds);
            for(String branchName : mapRR.keySet()){
                if(!mapReportResult.containsKey(branchName)){
                    mapReportResult.put(branchName,mapRR.get(branchName));
                }else{
                    PerformanceReportBatchHandler.ReportResult RR=mapReportResult.get(branchName);
                    PerformanceReportBatchHandler.ReportResult RR1=mapRR.get(branchName);
                    for(integer i=0;i<RR.reports.size();i++){
                        
                        if(RR1.reports[i].actualYear==null){
                            RR.reports[i].actualYearData+=RR1.reports[i].actualYearData;
                            RR.reports[i].actualYearDataTotal+=RR1.reports[i].actualYearDataTotal;
                            RR.reports[i].priorYearData+=RR1.reports[i].priorYearData;
                            RR.reports[i].priorYearDataTotal+=RR1.reports[i].priorYearDataTotal;
                            
                            if(RR.reports[i].actualYearDataTotal>0){
                                RR.reports[i].actualYear=RR.reports[i].actualYearData/(decimal)RR.reports[i].actualYearDataTotal;
                            }else{
                                RR.reports[i].actualYear = 0;
                            }
                            
                            if(RR.reports[i].priorYearDataTotal>0){
                                RR.reports[i].priorYear =RR.reports[i].priorYearData/(decimal)RR.reports[i].priorYearDataTotal;
                            }else{
                                RR.reports[i].priorYear = 0;
                            }
                        }else{
                            RR.reports[i].actualYear+=RR1.reports[i].actualYear;
                            RR.reports[i].priorYear+=RR1.reports[i].priorYear;
                        }
                        RR.reports[i].ToPy=(RR.reports[i].actualYear-RR.reports[i].priorYear)/(RR.reports[i].priorYear==0?1:RR.reports[i].priorYear);
                    }
                    
                }
            }
        }
        catch(Exception ex){
          throw ex;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('@@'+mapReportResult);
        
        delete [SELECT ID FROM WK52Report__c Where Report_Type__c='YTD'];
        List<WK52Report__c> WK52Report=new List<WK52Report__c>();
        for(String branchName : mapReportResult.keySet()){
            PerformanceReportBatchHandler.ReportResult RR=mapReportResult.get(branchName);
            WK52Report__c WK52Rpt=new WK52Report__c();
            WK52Rpt.SBM__c=RR.SBM;
            WK52Rpt.Branch__c =RR.Branch;
            if(branchName!=null && branchName.split('-').size()>0){
                WK52Rpt.Branch_Number__c =branchName.split('-')[0];
            }
            WK52Rpt.Report_Type__c='YTD';
            WK52Rpt.Unique_Key__c='YTD_'+RR.Branch;
            WK52Rpt.Reports__c=JSON.serialize(RR.reports);
            WK52Report.add(WK52Rpt);
        }
        upsert WK52Report Unique_Key__c;
    }
    public void execute(SchedulableContext sc) {
        PerformanceYTDReportBatch b = new PerformanceYTDReportBatch(); 
        database.executebatch(b,200);
    }
}