public class ResourceWorkzoneTriggerHandlerService implements ITriggerService{
    
    
    public static void prepareDataBeforeEvent(List<Resource_Workzone__c> newList) {
    }
    
    
    public static void prepareDataAfterEvent(List<Resource_Workzone__c> newList) {
        
    }
    
    
    public static void createWZZipCodeCoverageRecords(List<Resource_Workzone__c> newList) {
        Set<Id> wzIdSet										= new Set<Id>();
        Map<Id, List<Id>> wzAndZipMap 						= new Map<Id, List<Id>>();
        List<WorkZone_ZipCode_Coverage__c> zipCoverageList 	= new List<WorkZone_ZipCode_Coverage__c>();
        
        for(Resource_Workzone__c resWZ : newList) {
            if(resWZ.Workzone__c != null) wzIdSet.add(resWZ.Workzone__c);
        }
        
        for(WorkZone_ZipCode__c wzZipObj : [Select Id, Workzone__c from WorkZone_ZipCode__c where Workzone__c IN: wzIdSet]) {
            if(wzAndZipMap.containsKey(wzZipObj.Workzone__c)) wzAndZipMap.get(wzZipObj.Workzone__c).add(wzZipObj.Id);
            else wzAndZipMap.put(wzZipObj.Workzone__c, new List<Id>{wzZipObj.Id});
        }
        
        for(Resource_Workzone__c resWZ : newList) {
            for(Id wzZipId : wzAndZipMap.get(resWZ.Workzone__c)) {
                zipCoverageList.add(new WorkZone_ZipCode_Coverage__c(WorkZone_ZipCode__c = wzZipId, ServiceResource__c = resWZ.Resource__c));
            }
        }
        
        if(!zipCoverageList.isEmpty()) insert zipCoverageList;
    }
    
    
    public static void deleteRelatedZipCodeCoverage(List<Resource_Workzone__c> oldList) {
        Set<Id> wzIdSet		= new Set<Id>();
        for(Resource_Workzone__c resWZ : oldList) {
            if(resWZ.Workzone__c != null) wzIdSet.add(resWZ.Workzone__c);
        }
        
        try{
            delete [Select Id from WorkZone_ZipCode_Coverage__c where WorkZone_ZipCode__r.Workzone__c IN: wzIdSet];
        } catch(Exception e) {}
    }

}