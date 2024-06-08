public class PerformanceCRReportBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
	
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<ServiceResource> listSR=[SELECT Id,RelatedRecordId,RelatedRecord.isActive, Name FROM ServiceResource Where  Replacement_Sales_Rep__c =true and RelatedRecord.isActive=true ];
        List<String> listUniqueKey=new List<String>();
        for(ServiceResource SR:listSR){
            listUniqueKey.add('CR_'+SR.RelatedRecordId);
        }
        delete [SELECT ID,Unique_Key__c FROM WK52Report__c Where Report_Type__c='CR' and Unique_Key__c not in :listUniqueKey];
            
        return Database.getQueryLocator('SELECT Id,RelatedRecordId,RelatedRecord.isActive, Name FROM ServiceResource Where  Replacement_Sales_Rep__c =true and RelatedRecord.isActive=true order by name');
    }
    
    public void execute(Database.BatchableContext BC, List<ServiceResource> records){
        try{
            List<Id> SRIds=new List<Id>();
            for(ServiceResource sr :records ){
                SRIds.add(sr.RelatedRecordId);
            }
            Map<String,PerformanceReportBatchHandler.ReportResult> mapRR=PerformanceReportBatchHandler.getCoachingReportResultData(SRIds);
            List<WK52Report__c> WK52Report=new List<WK52Report__c>();
            List<String> listUniqueKey=new List<String>();
            for(String branchName : mapRR.keySet()){
                PerformanceReportBatchHandler.ReportResult RR=mapRR.get(branchName);
                WK52Report__c WK52Rpt=new WK52Report__c();
                WK52Rpt.SBM__c=RR.SBM;
                WK52Rpt.Branch__c =RR.Branch;
                WK52Rpt.Branch_Number__c=branchName;
                WK52Rpt.Report_Type__c='CR';
                WK52Rpt.Unique_Key__c='CR_'+branchName;
                WK52Rpt.Reports__c=JSON.serialize(RR.reports);
                WK52Report.add(WK52Rpt);
                listUniqueKey.add(WK52Rpt.Unique_Key__c);
            }
            
            upsert WK52Report Unique_Key__c;
          
        }
        catch(Exception ex){
          throw ex;
        }
    }
    
    public void finish(Database.BatchableContext BC){
    
    }
    public void execute(SchedulableContext sc) {
        PerformanceCRReportBatch b = new PerformanceCRReportBatch(); 
        database.executebatch(b,1);
    }
}