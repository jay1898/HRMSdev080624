public class ServiceTerritoryExportController {
    @AuraEnabled
    public static void runServiceTerritoryExportBatch() {
        
        ServiceTerritoryExportBatch b = new ServiceTerritoryExportBatch(); 
        Id batchprocessid = database.executebatch(b,200);
		System.debug('@@JOBId : '+batchprocessid);        
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                            FROM AsyncApexJob WHERE ID =: batchprocessid ];
    }
}