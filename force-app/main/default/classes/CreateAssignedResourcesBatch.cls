global without sharing class CreateAssignedResourcesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable
{   
    global String query ; 
    global CreateAssignedResourcesBatch() {
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([   SELECT Id, OwnerId FROM ServiceAppointment 
                                            WHERE Status != 'Canceled' AND Count_of_Assigned_Resource__c = 0 AND SchedStartTime != NULL ]);
    }

    global void execute(System.SchedulableContext sc){
        Database.executeBatch(new CreateAssignedResourcesBatch(), 1 );
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        List<AssignedResource> assignedResourcesToInsert = new List<AssignedResource>();
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,Id> userIdToServiceResourceId = new Map<Id,Id>();

        for(ServiceAppointment sa : (List<ServiceAppointment>)scope )
        {
            ownerIds.add(sa.OwnerId);
        }
        System.debug('UAC: ownerIds ' + ownerIds );

        // Get ServiceResource (Technician) information based on Opportunity.Lead_Receiver__c 
        for(ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId IN :ownerIds AND ResourceType IN ('T','D') AND IsActive = TRUE ])
        {
            userIdToServiceResourceId.put(sr.RelatedRecordId, sr.Id);
        }
        System.debug('UAC: userIdToServiceResourceId ' + userIdToServiceResourceId);

        for(ServiceAppointment sa : (List<ServiceAppointment>)scope )
        {
            if(userIdToServiceResourceId.containsKey(sa.OwnerId)) assignedResourcesToInsert.add(new AssignedResource( ServiceAppointmentId = sa.Id, ServiceResourceId = userIdToServiceResourceId.get(sa.OwnerId) ));
        }

        System.debug('UAC: assignedResourcesToInsert ' + assignedResourcesToInsert );
        if(assignedResourcesToInsert.size() > 0 ) 
        {
            AssignedResourceTriggerHandler.RUN_TRIGGER = false ;
            ServiceAppointmentTriggerHandler.RUN_TRIGGER = false ; 
            OpportunityTriggerHandler.RUN_TRIGGER = false ;
            Database.insert(assignedResourcesToInsert, false) ; 
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}