/**
    *   @Purpose:       Trigger handler class behind AssignedResource trigger 
    *   @Author:        Mayank Srivastava (eVerge)
    *   @Date:          01/10/2020
    *   @TaskSource:    

    *   @Updates:       
    */
public without sharing class AssignedResourceTriggerHandler 
{
    public static Boolean RUN_TRIGGER = true;
    
    /**
    *   @Method:        changeSAOpportunityStatusAndOwner
    *   @Purpose:       Change Opportunity Stage and Status to Active whenever a AssignedResource inserted or updated under Appointment 
    *   @Author:        Mayank Srivastava (eVerge)
    *   @Date:          01/04/2020
    *   @TaskSource:    

    *   @Updates:       
    */
    // Used - Opp method. createSA_AssingedResourceForOppOwnerChange()
    public static Boolean CHANGE_SA_OPP_STATUS_OWNER = true ;
    public static void changeSAOpportunityStatusAndOwner(List<AssignedResource> resources, Map<Id,AssignedResource> oldMap, Boolean isInsert) 
    {
    	System.debug('UAC: changeSAOpportunityStatusAndOwner ENTRY ');
        //03/23/2022 : pallavi, adding RT check to prevent sales code execution for PIES
        Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
		Id piesSRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
        AssignedResourceTriggerHandler.CHANGE_SA_OPP_STATUS_OWNER = false ;
        
    	List<Opportunity> oppsToUpdate = new List<Opportunity>();
    	Set<String> statuses = new Set<String>{'Preference','Soft Assigned','Scheduled'};
        Set<String> assignedResourceIds = new Set<String>();

        for(AssignedResource ar : resources )
        {
            AssignedResource old = isInsert ? null : oldMap.get(ar.Id);
			system.debug('ar.ServiceResource.recordTypeId :' + ar.ServiceResource.recordTypeId);
            // When AssignedResource inserted or ServiceResource is changed 
            if(isInsert || (!isInsert && ar.ServiceResourceId != old.ServiceResourceId)) assignedResourceIds.add(ar.Id);
        }

        // Get inserted/updated AssignedResources 
    	resources = [	SELECT 	ServiceAppointment.Status, ServiceAppointment.Opportunity__c, ServiceAppointment.RecordTypeId,
                                ServiceResource.RelatedRecordId, 
                                ServiceAppointment.Opportunity__r.CreatedDate, CreatedDate,ServiceResource.RecordTypeId
    					FROM AssignedResource 
                        WHERE ID IN : assignedResourceIds 
                                AND ServiceAppointment.Status IN :statuses
    						    AND ServiceResource.RelatedRecordId != NULL 
                                AND ServiceAppointment.Opportunity__c != NULL
                    			AND ServiceAppointment.RecordTypeId != :piesRT];

        // When no resources found then go back 
    	if(resources.size() == 0) return ; 
        System.debug('UAC: service appointment status ' + resources[0].ServiceAppointment.Status );
        //if( resources[0].ServiceAppointment.Opportunity__r.CreatedDate. ) return ;

        // Change Appointment's Opportunity Stage and Status to Active 
        for(AssignedResource ar : resources )
        {
        	oppsToUpdate.add(new Opportunity(Id=ar.ServiceAppointment.Opportunity__c, StageName = 'Active', Status__c = 'Active', OwnerId = ar.ServiceResource.RelatedRecordId ));
        }
        System.debug('UAC: oppsToUpdate ' + oppsToUpdate );
        OpportunityTriggerHandler.RUN_TRIGGER = false ;
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = false ;

        // Update Opportunity 
        if(oppsToUpdate.size() > 0 && !Test.isRunningTest() ) update oppsToUpdate ;
		ServiceAppointmentTriggerHandler.RUN_TRIGGER = true ;
        System.debug('UAC: changeSAOpportunityStatusAndOwner EXIT ');
    }

    /**
    *   @Method:        syncOwnerOnAppointmentForAssignedResource
    *   @Purpose:       Change Appointment Owner with Inserted/updated AssingedResource's ServiceResource matching User Id  
    *   @Author:        Mayank Srivastava (eVerge)
    *   @Date:          01/04/2020
    *   @TaskSource:    

    *   @Updates:       
    */
    public static Boolean CHANGE_OWNER_ON_SA_FOR_SERVICE_RESOURCE = true ; // Used in ServiceAppointmentTriggerHandler
    public static void syncOwnerOnAppointmentForAssignedResource(List<AssignedResource> resources, Map<Id,AssignedResource> oldMap, Boolean isInsert)
    {
        Map<Id,Id> saIdToSerivceResourceId = new Map<Id,Id>();
        Map<Id,Id> srIdToUserId = new Map<Id,Id>();
        List<ServiceAppointment> appointments = new List<ServiceAppointment>();
		Id OvInstallRTId = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
        for(AssignedResource ar : resources )
        {
            AssignedResource old = Trigger.isInsert ? null : oldMap.get(ar.Id);

            // When AssignedResource inserted or ServiceResource is changed 
            if(ar.serviceResource.RecordTypeId != OvInstallRTId && (isInsert || (!isInsert && ar.ServiceResourceId != old.ServiceResourceId))) saIdToSerivceResourceId.put(ar.ServiceAppointmentId, ar.ServiceResourceId);
        }
        System.debug('UAC: saIdToSerivceResourceId ' + saIdToSerivceResourceId );

        // Get ServiceResource (Technician) information 
        for(ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :saIdToSerivceResourceId.values() AND ResourceType IN ('T', 'D') AND IsActive = TRUE AND RecordTypeID != :OvInstallRTId])
        {
            srIdToUserId.put(sr.Id, sr.RelatedRecordId);
        }
        System.debug('UAC: srIdToUserId ' + srIdToUserId );

        for(Id saId : saIdToSerivceResourceId.keySet())
        {
            // Get Appointment's AssingedResource ID 
            Id srId = saIdToSerivceResourceId.get(saId);

            // Change Appointment Owner with ServiceResource's matching UserId
            if(srIdToUserId.containsKey(srId)) appointments.add(new ServiceAppointment(Id = saId, OwnerId = srIdToUserId.get(srId)));
        }

        // Update Appointment
        if(appointments.size() > 0)
        {
            ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH=false;
            ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE=false;
            ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE=false;
            ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD=true;
            
            // commented on 23-03-2020 as need to update SA-Event,Need to share record with Users,Need to update event owner
            //ServiceAppointmentTriggerHandler.RUN_TRIGGER = false ;
            update appointments ; 
            		
            // added as before appoinment it's false so safty reasone
            //ServiceAppointmentTriggerHandler.RUN_TRIGGER = false ;
           
            // commented on 23-03 as now all below logic process by SA trigger
            // Added on 17-03 To execute sharing on SA Owner Change
           /* try
            {
                List<String> saIds =new List<String>();
                for(ServiceAppointment sa: appointments){
                    saIds.add(sa.Id);
                }
                ServiceAppointmentRecordShare.shareSARecordWithSTMFuture(saIds);
                
                
                // Added on 21-03 To update event Owner
                Map<Id,Id> mapEventSA=new Map<Id,Id>();
       
                List<Event> listEvent = [SELECT Id, WhatId FROM Event WHERE WhatId IN :saIds ORDER BY CreatedDate DESC];
                for(Event ev:listEvent)
                {
                    mapEventSA.put(ev.WhatId,ev.Id);
                }
                List<Event> updateEventList=new List<Event>();
                for(ServiceAppointment sa: appointments){
                    if(mapEventSA.containsKey(sa.Id)){
                        Event evnt=new Event(id=mapEventSA.get(sa.Id),OwnerId=sa.ownerId);
                        updateEventList.add(evnt);
                    }
                }
                Boolean currentFlag=EventTriggerHandler.runTrigger;
                EventTriggerHandler.runTrigger=false;
                upsert updateEventList;
                EventTriggerHandler.runTrigger=currentFlag;
                
                // end
                
            }catch(Exception e){
                
            }*/
            
        }
    }
    /**
*   @Method:        piesserviceapptRecordShare
*   @Purpose:       To share the SA and WO with PIES Manager Contractors when SA is assigned to Installer/OV Contractors
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/
    //public static Boolean RUN_APEX_SHARING_RULES = true ; // Used in ServiceAppointmentTriggerHandler
    public static void piesSAWORecordShare(List<AssignedResource> ars, Map<Id,AssignedResource> oldMap){
        Map<String, String> mapSAARIds = new map<String, String>();
        Map<String, String> mapUpdateSAARIds = new map<String, String>();
        
        for(AssignedResource ar :ars){
           //for new assigned resources
           if(oldmap == null){
                mapSAARIds.put(ar.ServiceAppointmentId, ar.ServiceResourceId );
                system.debug('piesSAWORecordShare : '+ '::' + ar.ServiceAppointmentId+ '::' +ar.ServiceResourceId ); 
           }
           //when an Assigned resource is udpated 
           if(oldmap != null && ar.ServiceResourceId != oldMap.get(ar.Id).ServiceResourceId){
                mapUpdateSAARIds.put(ar.ServiceAppointmentId, ar.ServiceResourceId );
                system.debug('piesSAWORecordShare updated : '+ '::' + ar.ServiceAppointmentId+ '::' +ar.ServiceResourceId ); 
           }
       }
      if(mapSAARIds.size() >0){
           AssignedResourceRecordShare.shareSAWOwithPIESContractors(mapSAARIds); 
        }
      if(mapUpdateSAARIds.size() >0){
           AssignedResourceRecordShare.shareSAWOwithPIESContractors(mapUpdateSAARIds); 
        }
        
    }
    
	/**
*   @Method:        piesSAWORecordShareDelete
*   @Purpose:       When assigned resource(Installer/OV Contractors) is deleted then remove the shared SA and WO with PIES Manager Contractors.
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/  
    //public static Boolean RUN_APEX_SHARING_RULES_DELETE = true ;
    public static void piesSAWORecordShareDelete(List<AssignedResource> ars, Map<Id,AssignedResource> oldMap){
       Map<Id, Id> mapSAAResIds = new Map<Id, Id>();
       
       for(AssignedResource ar :ars){
           if(ar.ServiceResourceId != oldMap.get(ar.id).ServiceResourceId ){
                mapSAAResIds.put(ar.ServiceAppointmentId, oldMap.get(ar.Id).ServiceResourceId);
                system.debug('piesSAWORecordShareDelete '+ '::' + mapSAAResIds);  
           }
         }
       
         if(mapSAAResIds.size() >0){
             system.debug('piesSAWORecordShareDelete :' + mapSAAResIds.size());
           AssignedResourceRecordShare.shareSAWOwithPIESContractorsDelete(mapSAAResIds); 
        }
    }
    
    public static void piesSAWORecordShareDelete2(List<AssignedResource> ars){
       Map<Id, Id> mapSAAResIds = new Map<Id, Id>();
       
       for(AssignedResource ar :ars){
            	mapSAAResIds.put(ar.ServiceAppointmentId, ar.ServiceResourceId);
                system.debug('piesSAWORecordShareDelete '+ '::' + mapSAAResIds); 
		}
         if(mapSAAResIds.size() >0){
           AssignedResourceRecordShare.shareSAWOwithPIESContractorsDelete(mapSAAResIds); 
        }
    }
    
    public static void updateWOLPayoutInstaller(List<AssignedResource> resources, Map<Id,AssignedResource> oldMap, Boolean isInsert) 
    {
        System.debug('updateWOLPayoutInstaller ENTRY ');
        
        
        Set<String> assignedResourceIds = new Set<String>();
        
        for(AssignedResource ar : resources )
        {
            AssignedResource old = isInsert ? null : oldMap.get(ar.Id);
            
            // When AssignedResource inserted or ServiceResource is changed 
            if(isInsert || (!isInsert && ar.ServiceResourceId != old.ServiceResourceId) ) assignedResourceIds.add(ar.Id);
        }
        
        // Get inserted/updated AssignedResources 
        resources = [	SELECT 	ServiceAppointment.Status,ServiceAppointment.parentRecordId, ServiceAppointment.Opportunity__c,ServiceResourceId, ServiceResource.RelatedRecordId, 
                     ServiceAppointment.Opportunity__r.CreatedDate, CreatedDate
                     FROM AssignedResource 
                     WHERE ID IN : assignedResourceIds 
                     AND ServiceResource.RelatedRecordId != NULL 
                     AND ServiceAppointment.parentRecordId!=null];
        
        // When no resources found then go back 
        if(resources.size() == 0) return ; 
       
        Map<Id,WorkOrderLineItem> mapWOLIToUpdate = new Map<Id,WorkOrderLineItem>();
        // Change Appointment's Opportunity Stage and Status to Active 
        for(AssignedResource ar : resources )
        {
            if(String.valueOf(ar.ServiceAppointment.parentRecordId).startsWith('1WL')){
                mapWOLIToUpdate.put(ar.ServiceAppointment.parentRecordId,new WorkOrderLineItem(Id=ar.ServiceAppointment.parentRecordId, Primary_Installer__c= ar.ServiceResourceId ));
            }
        }
        List<WorkOrderLineItem> WOLIToUpdate=new List<WorkOrderLineItem>();
        //for(WorkOrderLineItem WOLI:[SELECT ID,Primary_Installer__c FROM WorkOrderLineItem Where Id in :mapWOLIToUpdate.keySet() and Primary_Installer__c=null and WorkType.Schedule_Type__c = 'Install']){
        //as per new change remove check on installer payout null
        for(WorkOrderLineItem WOLI:[SELECT ID,Primary_Installer__c FROM WorkOrderLineItem Where Id in :mapWOLIToUpdate.keySet() and WorkType.Schedule_Type__c in ('Install','Recovery')]){
            WOLIToUpdate.add(mapWOLIToUpdate.get(WOLI.Id));
        }
        
        System.debug('WOLIToUpdate ' + WOLIToUpdate );
        // Update Opportunity 
        if(WOLIToUpdate.size() > 0 && !Test.isRunningTest() ) update WOLIToUpdate ;
    }

}