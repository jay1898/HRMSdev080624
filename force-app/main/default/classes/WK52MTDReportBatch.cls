public class WK52MTDReportBatch {// implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
	
   /* Map<String,WK52ReportBatchHandler.ReportResult> mapReportResult=new Map<String,WK52ReportBatchHandler.ReportResult>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT ID FROM Opportunity ');
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> records){
        try{
            List<Id> OppIds=new List<Id>();
            for(Opportunity Opp :records ){
                OppIds.add(opp.Id);
            }
            Map<String,WK52ReportBatchHandler.ReportResult> mapRR=WK52ReportBatchHandler.getMTDResultData(OppIds);
            for(String branchName : mapRR.keySet()){
                if(!mapReportResult.containsKey(branchName)){
                    mapReportResult.put(branchName,mapRR.get(branchName));
                }else{
                    WK52ReportBatchHandler.ReportResult RR=mapReportResult.get(branchName);
                    WK52ReportBatchHandler.ReportResult RR1=mapRR.get(branchName);
                    for(integer i=0;i<RR.reports.size();i++){
                        RR.reports[i].actualYear+=RR1.reports[i].actualYear;
                        RR.reports[i].priorYear+=RR1.reports[i].priorYear;
                        RR.reports[i].ToPy+=RR1.reports[i].ToPy;
                    }
                    
                }
            }
        }
        catch(Exception ex){
          
        }
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('@@'+mapReportResult);
        
        List<WK52Report__c> WK52Report=new List<WK52Report__c>();
        for(String branchName : mapReportResult.keySet()){
            WK52ReportBatchHandler.ReportResult RR=mapReportResult.get(branchName);
            WK52Report__c WK52Rpt=new WK52Report__c();
            WK52Rpt.SBM__c=RR.SBM;
            WK52Rpt.Branch__c =RR.Branch;
            WK52Rpt.Report_Type__c='MTD';
            WK52Rpt.Unique_Key__c='MTD_'+RR.Branch;
            WK52Rpt.Reports__c=JSON.serialize(RR.reports);
            WK52Report.add(WK52Rpt);
        }
        upsert WK52Report Unique_Key__c;
    }
    public void execute(SchedulableContext sc) {
        WK52MTDReportBatch b = new WK52MTDReportBatch(); 
        database.executebatch(b,200);
    }*/
}