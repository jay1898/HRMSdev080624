public with sharing class P_CreateCSVFileBatch implements Database.Batchable<P_ReportControllerHelper.OpportunityWrapper>{
    
    public List<P_ReportControllerHelper.OpportunityWrapper> objList = new List<P_ReportControllerHelper.OpportunityWrapper>();
    public string reportName = null;
    public P_CreateCSVFileBatch(List<P_ReportControllerHelper.OpportunityWrapper> objList, String reportName){
        this.objList = objList;
        this.reportName = reportName;
    }
    
    public Iterable<P_ReportControllerHelper.OpportunityWrapper> start(Database.BatchableContext BC) {
        List<P_ReportControllerHelper.OpportunityWrapper> lessList = new List<P_ReportControllerHelper.OpportunityWrapper>();
        if(Test.isRunningTest()) {
            lessList.add(objList[0]);
            lessList.add(objList[1]);
            return lessList;
        }
        return objList;
    }
    public void execute(Database.BatchableContext BC, List<P_ReportControllerHelper.OpportunityWrapper> scope){
        //List<Custom_object__c> customobjList = new List<Custom_Object__c>();
        List<P_ReportControllerHelper.OpportunityWrapper> csvRowList = new List<P_ReportControllerHelper.OpportunityWrapper>();
        
        
        for(P_ReportControllerHelper.OpportunityWrapper o: objList){
            csvRowList.add(o);
        }
        P_ReportControllerHelper.createCSV(P_ReportController.HEADERS, P_ReportController.HEADERS_API_NAME, csvRowList, reportName);
        // DML operation
    }
    public void finish(Database.BatchableContext BC) {
    }
}