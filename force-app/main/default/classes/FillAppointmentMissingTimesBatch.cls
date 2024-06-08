global class FillAppointmentMissingTimesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable
{
    public String query;
    public String saId ; 

    global FillAppointmentMissingTimesBatch(String saId) 
    {
        this.saId = saId ;
        this.query = 'SELECT Id, SchedStartTime, SchedEndTime, Start_Datetime__c, Status, End_Datetime__c, REscheduled__c, OwnerId ' + 
                     'FROM ServiceAppointment WHERE ((SchedStartTime = NULL AND Start_Datetime__c != NULL) OR Count_of_Assigned_Resource__c=0) '+
            		 ' AND RecordType.DeveloperName!=\'OV_Install\' AND Status not in (\'Canceled\',\'Completed\') and Opportunity_stage__c!=\'Closed\' and Start_Datetime__c >= today  and lastmodifieddate = LAST_N_Days : 7 ' ;
        if(String.isNotBlank(saId)) query += ' AND Id = \'' + saId + '\'' ;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query);
    }

    global void execute(System.SchedulableContext sc){
        Database.executeBatch(new FillAppointmentMissingTimesBatch(null), 1 );
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        List<ServiceAppointment> appointments = (List<ServiceAppointment>)scope;

        Set<Id> existingAssignedResourceSAIds = new Set<Id>();
        Map<Id,Id> userIdToServiceResourceId = new Map<Id,Id>();
        List<AssignedResource> assignedResourcesToInsert = new List<AssignedResource>();
        Map<Id,Id> saIdToOwnerId = new Map<Id,Id>();
        
        // Iterate over Service Appointments
        for(ServiceAppointment sa : appointments)
        {
            if(sa.SchedStartTime ==null &&  sa.Start_Datetime__c!=null){
                sa.SchedStartTime = sa.Start_Datetime__c ;
                sa.SchedEndTime = sa.End_Datetime__c ;
            }
            saIdToOwnerId.put(sa.Id, sa.OwnerId);
        }
        System.debug('UAC: saIdToOwnerId ' + saIdToOwnerId);

        // Go Back  
        if(saIdToOwnerId.size() == 0) return ;

        OpportunityTriggerHandler.RUN_TRIGGER = FALSE ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = FALSE ;
        AssignedResourceTriggerHandler.RUN_TRIGGER = FALSE ; 
        update appointments ; 

        // Get ServiceResource (Technician) information based on Opportunity.Lead_Receiver__c 
        for(ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId IN :saIdToOwnerId.values() AND ResourceType IN ('T','D') AND IsActive = TRUE ])
        {
            userIdToServiceResourceId.put(sr.RelatedRecordId, sr.Id);
        }
        System.debug('UAC: userIdToServiceResourceId ' + userIdToServiceResourceId);

        
        // Get AssignedResource related to Service Appointment 
        for(AssignedResource ar : [SELECT Id, ServiceAppointmentId, ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId IN :saIdToOwnerId.keySet() ])
        {
            existingAssignedResourceSAIds.add(ar.ServiceAppointmentId);
        }
        System.debug('UAC: existingAssignedResourceSAIds ' + existingAssignedResourceSAIds ); 

        
        for( Id saId : saIdToOwnerId.keySet() )
        {
            Id ownerId = saIdToOwnerId.get(saId);

            // When matching ServiceResource available for OwnerId 
            if(userIdToServiceResourceId.containsKey(ownerId) && !existingAssignedResourceSAIds.contains(saId) )
            {
                // Create new Assigned Resource under Service Appointment
                AssignedResource ar = new AssignedResource( ServiceAppointmentId = saId, ServiceResourceId = userIdToServiceResourceId.get(ownerId) );
                assignedResourcesToInsert.add(ar);
            }
        }

        System.debug('UAC: assignedResourcesToInsert ' + assignedResourcesToInsert );

        // Now insert correct AssignedResource 
        if(assignedResourcesToInsert.size() > 0 ) 
        {
            OpportunityTriggerHandler.RUN_TRIGGER = false ;
            ServiceAppointmentTriggerHandler.RUN_TRIGGER = false ; 
            AssignedResourceTriggerHandler.RUN_TRIGGER = false ;
            // changed on 19-05 instead of insert, we changed to database.insert
            Database.insert(assignedResourcesToInsert,false) ; 
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}