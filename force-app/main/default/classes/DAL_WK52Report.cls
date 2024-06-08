public without sharing class DAL_WK52Report {
    
    public static List<WK52Report__c> getWk52ReportByType(String reportType) {
        return [SELECT ID,SBM__c,Branch__c,Branch_Number__c,Reports__c FROM WK52Report__c Where Report_Type__c = :reportType and Branch_Number__c!='998' order by SBM__c];
    }
     public static DateTime getWk52ReportLastUpdate(String reportType) {
         List<WK52Report__c> listWK52=[SELECT ID,SBM__c,Branch__c,Branch_Number__c,Reports__c,lastModifiedDate FROM WK52Report__c Where Report_Type__c = :reportType and Branch_Number__c!='998' order by lastModifiedDate asc limit 1];
         if(listWK52.size()>0){
             return listWK52[0].lastModifiedDate;
         }
         return null;
    }
    
    public static List<WK52Report__c> getWk52ReportByTypeAndBranches(String reportType,List<String> listBranchNumner) {
        return [SELECT ID,SBM__c,Branch__c,Branch_Number__c,Reports__c FROM WK52Report__c Where Report_Type__c = :reportType and Branch_Number__c = :listBranchNumner and Branch_Number__c!='998' order by SBM__c];
    }
    
    public static String getAllBranchRecords() {
        List<Branch__c> listBranches=[SELECT Id,NAME,Branch_Number__c from Branch__c where   Branch_Number__c!='998' order by Region__r.Name,Branch_Number__c]; 
        String jsonresult = JSON.serialize(listBranches);
        return jsonresult;
    }
    
    public static Map<String,String> getAllSalesResourceBranch() {
        Map<String,String> mapSR=new Map<String,String>();
        List<ServiceResource> listBranches=[SELECT Id, Name, Primary_Replacement_Territory__r.Name,RelatedRecordId, IsActive FROM ServiceResource
                                            Where  Replacement_Sales_Rep__c =true order by name];
        List<String> listSRIds=new List<String>();
        for(ServiceResource sr: listBranches){
            mapSR.put(sr.RelatedRecordId,sr.Primary_Replacement_Territory__r.Name);
        }
        
        return mapSR;
    }
    
}