public with sharing class piesWoliQuickActionController {
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWoRecord(Id workorderId){
        return [SELECT id,ServiceTerritoryId 
                FROM WorkOrder 
                WHERE id = :workorderId
                WITH SECURITY_ENFORCED
        ];
    }
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> updateWoRecord(Id workorderId, Id territory){
        List<WorkOrder> newWoRecord = new List<WorkOrder>();
        newWoRecord = [SELECT id,ServiceTerritoryId 
                    FROM WorkOrder 
                    WHERE id = :workorderId
                    WITH SECURITY_ENFORCED];
        for(WorkOrder wo: newWoRecord){
            wo.ServiceTerritoryId = territory;
        }
        update newWoRecord;
        return newWoRecord;
    }
}