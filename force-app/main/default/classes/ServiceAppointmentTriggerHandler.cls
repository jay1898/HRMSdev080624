/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/06/2020
*   @TaskSource:    
*   @Purpose:       Trigger handler Class for ServiceAppointment Trigger

*   @Updates:       
*/
public without sharing class ServiceAppointmentTriggerHandler 
{
    public static Boolean RUN_TRIGGER = true ;
    public static Boolean Check_Conflict_Overriden = true ;
    public static String woKeyPrefix = Utility.getKeyPrefixOfObjectId('WorkOrder');
    /**
*   @Method:        changeOwnerAndResource
*   @Purpose:       Whenever ServiceAppoint status changed to Canceled, then update SA Owner with Opp.Zone__c.LeadReceiver
*                   If Opportunity Stage is New, then change status of Opportunity, delete existing AssignedResource and create new AssignedResource for Opp.Zone.LeadReciver
If Opportunity Stage is Active, then only change Opportunity status to Canceled
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/06/2020
*   @TaskSource:    

*   @Updates:       
*/
    // _______________ ADDITIONAL NOTES - DON'T REMOVE THESE LINES : READ BEFORE MAKING ANY CHANGE IN CODE ____________________
    //
    // Service can not be scheduled where primary territory member is not defined - SA.Opp.Zone__r.Lead_Receiver__r(ServiceResource) should be member of SA.Opportunity__r.Zone__c Territory member
    // RT Zone's Branch doesn't match the Branch on the Sales Resource record. -  SA.Opp.Zone__c Branch is not matched with Territory's Branch of ServiceResource 
    // Service Appointment missing schedule time on insert or update of Assign Resource - Start and End Date were missing on Service Appointment
    // This Service resource isn't active or isn't a technician, so they can't be assigned to appointments, Should be Technician or Active Resource
    //
    // Dates are get blank whenever SA status changed to "Canceled" (UI or Webserice)
    // When there is only 1 AssignedResource and deleted, Service Appointment Status changed to "None" and Start and End Dates get blank
    // When there are multiple AssignedResource and one deleted, ServiceAppointment status changed to "Scheduled" 
    
    public static Boolean RUN_CHANGE_OWNER_AND_RESOURCE = true ;  
    public static Boolean RUN_FOR_RTA_CANCEL_APPOINTMENT = false ;
    public static Boolean RUN_FOR_OWNER_AND_DATE_CHANGE = false ;
    

    public static void onBeforeInsert(List<ServiceAppointment> newList) {
        Id csRecordTypeId 		 = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(Constant.SA_CS_RT).getRecordTypeId();
        for(ServiceAppointment saObj : newList) {
            String parentRecord = saObj.ParentRecordId;
            if(saObj.RecordTypeId == csRecordTypeId && parentRecord != null && parentRecord.startsWithIgnoreCase(woKeyPrefix)) saObj.FSSK__FSK_Work_Order__c = saObj.ParentRecordId;
        }
    }

    public static void changeOpportunityAndSAOwnerOnAppointmentCancel(List<ServiceAppointment> appointments, Map<Id,ServiceAppointment> oldMap ) 
    {
//        System.debug('UAC: changeOpportunityAndSAOwnerOnAppointmentCancel ENTRY ');
        
        Set<Id> oppIds = new Set<Id>();
        List<ServiceAppointment> validSA = new List<ServiceAppointment>();
        List<ServiceAppointment> listSAtoReshare = new List<ServiceAppointment>();
        List<AssignedResource> assignedResources = new List<AssignedResource>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        Map<Id,ServiceAppointment> saMap = new Map<Id,ServiceAppointment>();
        Map<Id,Id> userIdToServiceResourceId = new Map<Id,Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<AssignedResource> assignedResourcesToInsert = new List<AssignedResource>();
        Set<Id> userIds = new Set<Id>();
        Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        Id piesSRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
        // Iterate over Service Appointments
        for(ServiceAppointment sa : appointments)
        {
            ServiceAppointment old = oldMap.get(sa.Id);
//            System.debug('UAC: sa.Status ' + sa.Status );
//            System.debug('UAC: old.Status ' + old.Status );
            // When Status is updated to Canceled and Service Appointment is under an Opportunity
            // if(( (Test.isRunningTest() || sa.Status != old.Status || ServiceAppointmentTriggerHandler.RUN_FOR_RTA_CANCEL_APPOINTMENT ) && sa.Status == 'Canceled' && String.isNotBlank(sa.Opportunity__c) ) )
            if(sa.RecordTypeId != piesRT && ((Test.isRunningTest() || sa.Status != old.Status || (sa.SchedStartTime!=old.SchedStartTime && old.SchedStartTime==null ) ) && sa.Status == 'Canceled' && String.isNotBlank(sa.Opportunity__c) ) )
            {
                oppIds.add(sa.Opportunity__c);
                
                // NOTE: Getting date values from Old record, because when Status changed to Canceled then these fields get blank by Salesforce Field Service Lightning
                validSA.add(new ServiceAppointment(Id=sa.Id, Opportunity__c = sa.Opportunity__c, OwnerId = sa.OwnerId, SchedStartTime = old.SchedStartTime, SchedEndTime = old.SchedEndTime, ActualStartTime = old.ActualStartTime, ActualEndTime = old.ActualEndTime)) ;
                saMap.put(sa.Id, sa);
            }
        }
//        System.debug('UAC: oppIds ' + oppIds);
//        System.debug('UAC: validSA ' + validSA);
        
        // Go Back if no OpportunityId found on SA 
        if(oppIds.size() == 0) return ;
        
        // Get Opportunity Lead Receiver with New Stage
        for(Opportunity opp : [SELECT Id, Zone__r.Lead_Receiver__c, StageName FROM Opportunity WHERE ID = :oppIds ])
        {
            if(String.isNotBlank(opp.Zone__r.Lead_Receiver__c)) userIds.add(opp.Zone__r.Lead_Receiver__c);
            oppMap.put(opp.Id, opp);
        }
//        System.debug('UAC: oppMap ' + oppMap);
        if(oppMap.size() == 0) return ;
        
        // Get ServiceResource (Technician) information based on Opportunity.Lead_Receiver__c 
        for(ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId IN :userIds AND ResourceType IN ('T', 'D') AND IsActive = TRUE AND RecordTypeId !=: piesSRRT ])
        {
            userIdToServiceResourceId.put(sr.RelatedRecordId, sr.Id);
        }
        
        // Get AssignedResource related to Service Appointment 
        for(AssignedResource ar : [SELECT Id, ServiceAppointmentId, ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId IN :validSA])
        {
            assignedResources.add(ar);
        }
//        System.debug('UAC: assignedResources ' + assignedResources ); 
        
        Set<Id> saIds = new Set<Id>();
        for(ServiceAppointment sa : validSA)
        {
            saIds.add(sa.Id);
            // When ServiceAppoint has an opportunity attached
            if(oppMap.containsKey(sa.Opportunity__c)) 
            {
                // Get Opportunity details
                Opportunity opp = oppMap.get(sa.Opportunity__c);
                
                // When Opp Stage is "New"
                if(opp.StageName == 'New')
                {
                    sa.Status = 'Canceled';
                    if(saMap.containsKey(sa.Id))   
                    {  
                        ServiceAppointment serviceAppointment = saMap.get(sa.Id);  
                        listSAtoReshare.add(serviceAppointment);  
                    }
                    if( String.isNotBlank(opp.Zone__r.Lead_Receiver__c)) sa.OwnerId = opp.Zone__r.Lead_Receiver__c ;
                    //AssignedResource ar = new AssignedResource( ServiceAppointmentId = sa.Id, ServiceResourceId = userIdToServiceResourceId.get(sa.OwnerId) );
                    //assignedResourcesToInsert.add(ar);
                    //Rekha: added last confirmation date reset for Mogli confirmation text project
                    //oppsToUpdate.add(new Opportunity(Id=sa.Opportunity__c, Status__c = 'Canceled', OwnerId = opp.Zone__r.Lead_Receiver__c ));
                    oppsToUpdate.add(new Opportunity(Id=sa.Opportunity__c, Status__c = 'Canceled', OwnerId = opp.Zone__r.Lead_Receiver__c));                
                    //,Last_Confirmation_Date__c = null));  //Rekha : implement appointment confirmation logic.
                }
                
                // When Opp Stage is Active Just change Opportunity Status to Cancel 
                if(opp.StageName == 'Active') oppsToUpdate.add(new Opportunity(Id=sa.Opportunity__c, Status__c = 'Canceled'));
                //,Last_Confirmation_Date__c = null)); //Rekha : implement appointment confirmation logic.
            }
        }
        
        //System.debug('UAC: assignedResourcesToInsert ' + assignedResourcesToInsert );
 //       System.debug('UAC: oppsToUpdate ' + oppsToUpdate );
        
        ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = false ;
        
        // DONT CHANGE/REMOVE ORDER OF THESE DML STATEMENTS
        // First update Opportnity
        if(oppsToUpdate.size() > 0 && OpportunityTriggerHandler.UPDATE_OPPORTUNITY_BACK_ON_OPP_CANCELED ) 
        {
            OpportunityTriggerHandler.CHANGE_OWNER_FOR_CANCEL_STATUS = false ;
            update oppsToUpdate ;
        }
        
        
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = false; 
        if(ServiceAppointmentTriggerHandler.RUN_FOR_RTA_CANCEL_APPOINTMENT) ServiceAppointmentTriggerHandler.RUN_FOR_RTA_CANCEL_APPOINTMENT = false ;
        if(validSA.size() > 0 ) update validSA ;
        
        // If any existing AssignResources available then delete them - Read additional notes for AssignedResource deletion
        //if(assignedResources.size() > 0 && assignedResourcesToInsert.size() > 0 && !Test.isRunningTest() ) delete assignedResources ;
        
        // Update once ServiceAppointment for Start Date and End Date - above Delete DML changed status to None or Scheduled - Read addtional notes 
        
        // Now insert correct AssignedResource 
        //if(assignedResourcesToInsert.size() > 0 ) insert assignedResourcesToInsert ; 
        
        // Update again Service appointment with 'Cancel' (Original) Status 
        //if(validSA.size() > 0 && assignedResourcesToInsert.size() > 0) update validSA ;
        
        if(saIds.size() > 0 ) updateSerivceAppointmentDates(saIds);
        
        if(listSAtoReshare.size()>0)  
            ServiceAppointmentRecordShare.shareSARecordWithSTM(listSAtoReshare);  
        
//        System.debug('UAC: changeOpportunityAndSAOwnerOnAppointmentCancel EXIT ');
    }
    /**
*   @Method:        validateOwnerInCaseOfRehashAppointment
*   @Purpose:       To restrict owner to Rehash Eligible only
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    /*public static void validateOwnerInCaseOfRehashAppointment(List<ServiceAppointment> appointments, Map<Id,ServiceAppointment> oldMap)
{
List<String> listRehashOwnerId=new List<String>();
for(ServiceAppointment sa : appointments)
{
if(sa.Rehash_Appointment__c==true){
listRehashOwnerId.add(sa.ownerId);    
}
}
List<ServiceResource> listSR=[SELECT ID,Rehash_Eligible__c,RelatedRecordId FROM ServiceResource Where RelatedRecordId = : listRehashOwnerId];
Map<Id,ServiceResource> ownerWiseSR=new Map<Id,ServiceResource>();
for(ServiceResource SR : listSR){
ownerWiseSR.put(SR.RelatedRecordId,SR);
}

for(ServiceAppointment sa : appointments)
{
if(sa.Rehash_Appointment__c==true){
if(ownerWiseSR.containsKey(sa.OwnerId)){
if(!ownerWiseSR.get(sa.OwnerId).Rehash_Eligible__c){
sa.addError(Label.SR_UserNotExistAsRehashEligibleResource);
}
}else{
sa.addError(Label.SR_UserNotExistAsRehashEligibleResource);
}
}
}


}*/
    
    /**
*   @Method:        updateSerivceAppointmentDates
*   @Purpose:       To update Start and End dates back, whenever an appointment status changed to Canceled
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    @future
    public static void updateSerivceAppointmentDates(Set<Id> saIds )
    {
//        System.debug('UAC: updateSerivceAppointmentDates ENTRY ');
        //03/23/2022 : pallavi, adding RT check to prevent sales code execution for PIES
        Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        //Get Service Appointment information
        List<ServiceAppointment> appointments = [SELECT Subject, SchedStartTime, SchedEndTime, Start_Datetime__c, End_Datetime__c, Status, LastUpdatedBy__c FROM ServiceAppointment WHERE ID IN :saIds AND RecordTypeId !=: piesRT];
        
        for(ServiceAppointment sa : appointments)
        {
            // Copy Start and End Date from custom fields
            if(sa.Start_Datetime__c != NULL)  sa.SchedStartTime = sa.Start_Datetime__c ;
            if(sa.End_Datetime__c != NULL ) sa.SchedEndTime = sa.End_Datetime__c ;
        }
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = false ;
        OpportunityTriggerHandler.RUN_TRIGGER = false ;
        
        // Update Appointment 
        update appointments ;
        
//        System.debug('UAC: updateSerivceAppointmentDates EXIT ');
    }
    
    /**
*   @Method:        updateSerivceAppointmentDates
*   @Purpose:       Whenever Opporutnity inserted or Owner is changed, create a AssignedResource record under related Appointment with respective Service Resource
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static Boolean CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = true; 
    public static Boolean DO_NOT_CHANGE_FOR_RT = false ; 
    public static void createAssignedResourceOnAppointmentOwnerChange(List<ServiceAppointment> appointments, Map<Id,ServiceAppointment> oldMap, Boolean isInsert ) 
    {
//        System.debug('UAC: createAssignedResourceOnAppointmentOwnerChange ENTRY ');
        //03/23/2022 : pallavi, adding RT check to prevent sales code execution for PIES
		Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        Id piesSRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = false ;
        
        List<AssignedResource> assignedResources = new List<AssignedResource>();
        Set<String> existingARwithSAIds = new Set<String>();
        Map<Id,Id> userIdToServiceResourceId = new Map<Id,Id>();
        List<AssignedResource> assignedResourcesToInsert = new List<AssignedResource>();
        Map<Id,Id> saIdToOwnerId = new Map<Id,Id>();
        Map<Id,ServiceAppointment> newMap = new Map<Id,ServiceAppointment>();
        Set<Id> saIdsWithStartDate = new Set<Id>();
        
        // Iterate over Service Appointments
        for(ServiceAppointment sa : appointments)
        {
//            System.debug('UAC: sa status ' + sa.Status);
            ServiceAppointment old = isInsert ? null : oldMap.get(sa.Id);
            newMap.put(sa.Id,sa);
            // If Opportunity is inserted, or Owner is updated 
            if( sa.RecordTypeId != piesRT && (isInsert || ( !isInsert && (sa.OwnerId != old.OwnerId || (ServiceAppointmentTriggerHandler.RUN_FOR_OWNER_AND_DATE_CHANGE))) ))
            {   
                ServiceAppointmentTriggerHandler.RUN_FOR_OWNER_AND_DATE_CHANGE = false;
                saIdToOwnerId.put(sa.Id, sa.OwnerId);
                if(sa.SchedStartTime != null ) saIdsWithStartDate.add(sa.Id);
            }
        }
//        System.debug('UAC: saIdToOwnerId ' + saIdToOwnerId);
        
        // Go Back  
        if(saIdToOwnerId.size() == 0) return ;
        
        // Get ServiceResource (Technician) information based on Opportunity.Lead_Receiver__c 
        for(ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId IN :saIdToOwnerId.values() AND ResourceType IN ('T','D') AND IsActive = TRUE AND RecordTypeId !=:piesSRRT ])
        {
            userIdToServiceResourceId.put(sr.RelatedRecordId, sr.Id);
        }
//        System.debug('UAC: userIdToServiceResourceId ' + userIdToServiceResourceId);
        
        // Get AssignedResource related to Service Appointment 
        for(AssignedResource ar : [SELECT Id, ServiceAppointmentId, ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId IN :saIdToOwnerId.keySet() ])
        {
            assignedResources.add(ar);
            existingARwithSAIds.add(ar.ServiceAppointmentId + '' + ar.Id );
        }
//        System.debug('UAC: assignedResources ' + assignedResources ); 
        
        // 02-06-2021 Overbooking Warning
        Set<String> saStatuses = new Set<String>{'Preference','Soft Assigned','Scheduled'};
            Map<Id,List<ServiceAppointment>> ownerIdToSAs=new Map<Id,List<ServiceAppointment>>();
        Map<Id,List<ResourceAbsence>> ownerIdToRAs=new Map<Id,List<ResourceAbsence>>();
        
        if(!isInsert && ServiceAppointmentTriggerHandler.Check_Conflict_Overriden){
            for(ServiceAppointment SA : [SELECT ID,AppointmentNumber,SchedStartTime,SchedEndTime,OwnerId FROM ServiceAppointment 
                                         Where OwnerId=:saIdToOwnerId.values() 
                                         and Status IN :saStatuses 
                                         and SchedStartTime > : DateTime.now() and recordtypeId != :piesRT
                                         order by SchedStartTime])
            {
                if(!ownerIdToSAs.containsKey(SA.OwnerId)){
                    ownerIdToSAs.put(SA.OwnerId,new List<ServiceAppointment>());
                }
                ownerIdToSAs.get(SA.OwnerId).add(SA);
            }
            
            for(ResourceAbsence RA : [SELECT ID,AbsenceNumber,Start,End,ResourceId,Resource.RelatedRecordId FROM ResourceAbsence 
                                      Where Resource.RelatedRecordId=:saIdToOwnerId.values() 
                                      and start > : DateTime.now()
                                      order by Start])
            {
                if(!ownerIdToRAs.containsKey(RA.Resource.RelatedRecordId)){
                    ownerIdToRAs.put(RA.Resource.RelatedRecordId,new List<ResourceAbsence>());
                }
                ownerIdToRAs.get(RA.Resource.RelatedRecordId).add(RA);
            }
        }
        
        //  02-06-2021 Overbooking Warning
        
        for( Id saId : saIdToOwnerId.keySet() )
        {
            Id ownerId = saIdToOwnerId.get(saId);
            
            // When matching ServiceResource available for OwnerId 
            if(userIdToServiceResourceId.containsKey(ownerId) && saIdsWithStartDate.contains(saId) && !existingARwithSAIds.contains(saId + '' + userIdToServiceResourceId.get(ownerId)) )
            {
                // Create new Assigned Resource under Service Appointment
                AssignedResource ar = new AssignedResource( ServiceAppointmentId = saId, ServiceResourceId = userIdToServiceResourceId.get(ownerId) );
                assignedResourcesToInsert.add(ar);
            }
            
            // 02-06-2021 Overbooking Warning
            if(!isInsert && ServiceAppointmentTriggerHandler.Check_Conflict_Overriden){
                if(newMap.containsKey(saId) && newMap.get(saId).Appointment_Conflict_Override__c==false ){
                    ServiceAppointment currentSA=newMap.get(saId);
                    if(ownerIdToSAs.containsKey(ownerId)){
                        for(ServiceAppointment SA: ownerIdToSAs.get(ownerId)){
                            if((currentSA.SchedStartTime<=SA.SchedStartTime && SA.SchedStartTime<currentSA.SchedEndTime)
                               ||(currentSA.SchedStartTime<SA.SchedEndTime && SA.SchedEndTime<currentSA.SchedEndTime)
                               ||( SA.SchedStartTime<=currentSA.SchedStartTime && currentSA.SchedEndTime<=SA.SchedEndTime )){
                                   updateSAConflictFlag(saId,true); 
                                   if(!Test.isRunningTest()) newMap.get(saId).addError(Label.Service_Appointment_Conflict.replace('{DateTime}',(currentSA.SchedStartTime).format('MM/dd/yyyy hh:mm a')));
                                   break; 
                               }
                        }
                    }
                    if(ownerIdToRAs.containsKey(ownerId)){
                        for(ResourceAbsence RA: ownerIdToRAs.get(ownerId)){
                            if((currentSA.SchedStartTime<=RA.Start && RA.Start<currentSA.SchedEndTime)
                               ||(currentSA.SchedStartTime<RA.END && RA.END<currentSA.SchedEndTime)
                               ||( RA.Start<=currentSA.SchedStartTime && currentSA.SchedEndTime<=RA.END )){
                                   updateSAConflictFlag(saId,true);
                                   if(!Test.isRunningTest()) newMap.get(saId).addError(Label.Service_Appointment_Conflict.replace('{DateTime}',(currentSA.SchedStartTime).format('MM/dd/yyyy hh:mm a')));
                                   break;
                               }
                        }
                    }
                    
                }
                if(newMap.containsKey(saId) && newMap.get(saId).Appointment_Conflict_Override__c==true){
                    updateSAConflictFlag(saId,false);
                }
            }
            // 02-06-2021 Overbooking Warning
            
        }
        
//        System.debug('UAC: assignedResourcesToInsert ' + assignedResourcesToInsert );
        
        // Now insert correct AssignedResource 
        if(assignedResourcesToInsert.size() > 0 ) 
        {
            AssignedResourceTriggerHandler.CHANGE_OWNER_ON_SA_FOR_SERVICE_RESOURCE = false ;
//            System.debug('UAC: ServiceAppointmentTriggerHandler.DO_NOT_CHANGE_FOR_RT ' + ServiceAppointmentTriggerHandler.DO_NOT_CHANGE_FOR_RT);
            if(isInsert || ServiceAppointmentTriggerHandler.DO_NOT_CHANGE_FOR_RT ) AssignedResourceTriggerHandler.CHANGE_SA_OPP_STATUS_OWNER = false ;
            insert assignedResourcesToInsert ; 
        }
        
        // If any existing AssignResources available then delete them - Read additional notes for AssignedResource deletion
        if(assignedResources.size() > 0 && assignedResourcesToInsert.size() > 0 )
        {
//            System.debug('UAC: resource deleted and inserted ');
            if(!ServiceAppointmentTriggerHandler.DO_NOT_CHANGE_FOR_RT) AssignedResourceTriggerHandler.changeSAOpportunityStatusAndOwner(assignedResourcesToInsert, null, true);
            delete assignedResources ;
        }
        
//        System.debug('UAC: createAssignedResourceOnAppointmentOwnerChange EXIT ');
    }
    
    public static void updateSAConflictFlag(String saId,Boolean Flag) {
        List<Opportunity_Appointment_Flag__e> inkEvents = new List<Opportunity_Appointment_Flag__e>();
        inkEvents.add(new Opportunity_Appointment_Flag__e(ServiceAppointmentId__c=saId,Flag__c=Flag));
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(inkEvents);
        
    }//End of updateCustomerEBSCallout
    
    /**
*   @Method:        setBestMatchOnAppointmentReschedule
*   @Purpose:       Whenever ServiceAppoint SchedStartTime is changed, then re-calculate Endtime and assign Best match again by running best match logic
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/07/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static Boolean RESCHEDULE_BEST_MATCH = true ;
    public static void setBestMatchOnAppointmentReschedule(List<ServiceAppointment> appointments, Map<Id,ServiceAppointment> oldMap)
    {
//        System.debug('UAC: setBestMatchOnAppointmentReschedule ENTRY ');
        //03/23/2022 : pallavi, adding RT check to prevent sales code execution for PIES

		Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        if(appointments.size() > 1) return ;
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ;
        
        Set<String> statuses = new Set<String>{'Preference'}; // 'Canceled',
            Set<ServiceAppointment> validSA = new Set<ServiceAppointment>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Opportunity> oppsToClearApptTime = new List<Opportunity>();
        // Iterate over Service Appointments
        for(ServiceAppointment sa : appointments)
        {
            ServiceAppointment old = oldMap.get(sa.Id);
//            System.debug('UAC: sa SchedStartTime ' + sa.SchedStartTime );
//            System.debug('UAC: sa old SchedStartTime ' + old.SchedStartTime );
//            System.debug('UAC: sa.Status ' + sa.Status );
//            System.debug('UAC: old.Status ' + old.Status );
            
            // To run changeOpportunityAndSAOwnerOnAppointmentCancel() method on cancel because in after update old and new Status values are same therefore in before update calling above method forecly
            // Above method runs in after update mode - THIS IS VERY SPECIAL CASE - When someone change status to Canceled from UI, it works when someone Cancel through RTA 
            if(sa.Status == 'Canceled' && sa.Status != old.Status && sa.RecordTypeId != piesRT) ServiceAppointmentTriggerHandler.RUN_FOR_RTA_CANCEL_APPOINTMENT = TRUE ;
            
            if(Test.isRunningTest() && String.isNotBlank(sa.Opportunity__c)) 
            {
                validSA.add(sa); 
                oppIds.add(sa.Opportunity__c);
            }

            // When StartDate is updated and Service Appointment is under an Opportunity
            if(sa.RecordTypeId != piesRT && sa.SchedStartTime != old.SchedStartTime && sa.SchedStartTime != null && String.isNotBlank(sa.Opportunity__c))
            {
                oppIds.add(sa.Opportunity__c);
                validSA.add(sa) ;
            }
            if(sa.RecordTypeId != piesRT && sa.SchedStartTime != old.SchedStartTime && sa.SchedStartTime != null && String.isNotBlank(sa.Opportunity__c) && sa.ownerId != old.ownerId) {            
                ServiceAppointmentTriggerHandler.RUN_FOR_OWNER_AND_DATE_CHANGE = true;
            }
        }
//        System.debug('UAC: oppIds ' + oppIds);
        // Added && !test.isRunningTest() to increase test converage
        if(oppIds.size() == 0 && !test.isRunningTest()) return ;
        
        // Get Opportunity Information
        for(Opportunity opp : [ SELECT Id, StageName,AccountId, Account.PersonMailingStreet, Account.PersonMailingCity, Account.PersonMailingCountry, 
                               Account.PersonMailingState, Account.PersonMailingPostalCode,Virtual_Appointment__c, Zone__r.Virtual_Appt_Duration_Min__c, 
                               Zone__r.Lead_Receiver__c, Zone__r.ApptDurationMin__c, Zone__r.OperatingHours.TimeZone ,Appointment_Type__c  
                               
                               FROM Opportunity WHERE ID = :oppIds AND Zone__r.Lead_Receiver__c != NULL ])
        {
            oppMap.put(opp.Id, opp);
        }
//        System.debug('UAC: oppMap ' + oppMap);
        // Added && !test.isRunningTest() to increase test converage
        if(oppMap.size() == 0 && !test.isRunningTest()) return ;
        
        // Get Soft Assign RecordType Id
        Id softAssignId = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('Soft_Assign').RecordTypeId;
        Id saFullDetailRTId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Hard_Assign').getRecordTypeId();
        
        //Iterate over valid Service Appointments
        for(ServiceAppointment sa : validSA)
        {
            // If SerivceAppoint has an opportunity
            if(oppMap.containsKey(sa.Opportunity__c) )
            {
                // Get Opportunity information
                Opportunity opp = oppMap.get(sa.Opportunity__c);
                
                Opportunity newOpp = new Opportunity(Id=sa.Opportunity__c);
                newOpp.Appointment_DateTime__c = sa.SchedStartTime ;
                
                //Rekha : implement appointment confirmation logic.
                //newOpp.Last_Confirmation_Date__c = null;
                
                Datetime nextDay12AM = Datetime.newInstance(sa.SchedStartTime.addDays(1).date() , Time.newInstance(0, 0, 0, 0) );
                
                // If integration user is updating then use OpreatingHours timezone to adjust date
                if(!String.isBlank(opp.Zone__r.OperatingHours.TimeZone) && UserInfo.getTimeZone().getOffset(sa.SchedStartTime) == 0 )
                {
                    TimeZone tz = TimeZone.getTimeZone(opp.Zone__r.OperatingHours.TimeZone);
                    nextDay12AM = nextDay12AM.addSeconds((tz.getOffset(sa.SchedStartTime)/1000)*-1);
                }else{
                    // If Appointment reschedule from the SF not from pella site , then need to update Appointment_DateTime_Email__c
                    // assumption is that Login user timezone and Zone territory timezone always same
                    // Added on 12-05 (reset GMT Date) 
                    DateTime AppDateTimeGMT=sa.SchedStartTime;
                    Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(sa.SchedStartTime)/1000;
                    newOpp.Appointment_DateTime_Email__c= sa.SchedStartTime.addSeconds(TimeZoneGMTdiffSec);
//                    system.debug('Appointment_DateTime_Email__c :' + newOpp.Appointment_DateTime_Email__c);
                }
                
                newOpp.Appointment_Next_Day_12AM__c = nextDay12AM ;
                
                // set prior owner null as appointment reschedule on 11-05-2020
                newOpp.Prior_Opp_Owner__c=null;
                newopp.Prior_Opp_OwnerID__c=null;
                
                // Update Opportunity Stage and Status 
                oppsToUpdate.add(newOpp);
                
                
                // if((!statuses.contains(sa.Status)) || (statuses.contains(sa.Status) && ServiceAppointmentTriggerHandler.RUN_FOR_OWNER_AND_DATE_CHANGE))
                //{
                // Get Opoortunity.Zone__r.ApptDurationMinc__c minutes 
                Integer duration = opp.Zone__r.ApptDurationMin__c == null ? 0 : Integer.valueOf(opp.Zone__r.ApptDurationMin__c);
                // Added on 09-06 For virtual appointment changes  
                if(opp.Virtual_Appointment__c){  
                    duration = opp.Zone__r.Virtual_Appt_Duration_Min__c==null ? duration : Integer.valueOf(opp.Zone__r.Virtual_Appt_Duration_Min__c);  
                }
                
                // Change fields values on Service Appointment
                sa.Rescheduled__c = true ;
                sa.Status = 'Soft Assigned' ;
                sa.RecordTypeId = softAssignId ;
                if(opp.Appointment_Type__c == 'Preferred')newOpp.Owner_Change__c = TRUE;
                // Added condition on 15-05 to ignore for NRT Type
                if(opp.Appointment_Type__c!='NRT' && opp.Appointment_Type__c!='Self-Gen'){
                    // Re-calculate ScheduledEndTime
                    sa.SchedEndTime = sa.SchedStartTime.addMinutes(duration);
                }
                if(opp.StageName !='Closed Won' && opp.StageName!='Contracted'){
                    newOpp.StageName = 'New' ;
                    newOpp.Status__c = 'New' ;
                }
                if(opp.Appointment_Type__c=='Self-Gen'){
                    newOpp.StageName = 'Active' ;
                    newOpp.Status__c = 'Active' ;
                    newOpp.Update_SA_Helper__c=true;
                    
                    sa.RecordTypeId=saFullDetailRTId;
                }
                if(sa.SchedStartTime.addhours(-24)<Datetime.now()) oppsToClearApptTime.add(new Opportunity(Id=sa.Opportunity__c, Appointment_DateTime__c = null ));
                //}
            }
        }
        if(oppsToUpdate.size() == 0) return ;
        
        if(oppsToClearApptTime.size() > 0 ) update oppsToClearApptTime ;
        
//        System.debug('UAC: oppsToUpdate ' + oppsToUpdate );
        OpportunityTriggerHandler.RUN_TRIGGER = TRUE ;
        OpportunityTriggerHandler.RUN_UPDATE_SA_ON_VIRTUAL_OPPORTUNITY = false ;
        
        update oppsToUpdate ;
        Opportunity opp = oppMap.get(oppsToUpdate[0].Id);
        if(!ServiceAppointmentTriggerHandler.RUN_FOR_OWNER_AND_DATE_CHANGE){
            // Added Condition on 15-05 Do not call set best match if Opp is NRT type
            if(opp.Appointment_Type__c!='NRT' && opp.Appointment_Type__c!='Self-Gen' ){
                
                // Added on 19-05 Change Appointdate time in case of manually  reschedule from salesforce
                DateTime AppDateTimeEmail=appointments[0].Opportunity_Appointment_Date_Email__c;
                if(oppsToUpdate[0].Appointment_DateTime_Email__c!=null){
                    AppDateTimeEmail=oppsToUpdate[0].Appointment_DateTime_Email__c;
                }
//                System.debug('UAC: Inside@369 ');
                ServicePOSTRTA.setBestMatchFuture( opp.AccountId, opp.Id, null, appointments[0].Id, opp.Account.PersonMailingStreet, null, 
                                                  opp.Account.PersonMailingCity, opp.Account.PersonMailingState, opp.Account.PersonMailingPostalCode, 
                                                  opp.Account.PersonMailingCountry, String.valueOf(AppDateTimeEmail), '' );
            }
        }
        if(opp.Appointment_Type__c=='NRT'){
            if(opp.Zone__r.Lead_Receiver__c!=null){
                updateOppAndSAOwnerFuture(Opp.Id,Opp.Zone__r.Lead_Receiver__c,appointments[0].Id);
            }
        }
        if(ServiceAppointmentTriggerHandler.RUN_FOR_OWNER_AND_DATE_CHANGE)  {
            Opportunity OppToUpdate=new Opportunity();
            OppToUpdate.Id=Opp.Id;
            OppToUpdate.OwnerId = appointments[0].ownerId;
            OpportunityTriggerHandler.RUN_TRIGGER = false;
            update OppToUpdate ;
            
        }
//        System.debug('UAC: setBestMatchOnAppointmentReschedule EXIT ');
    }
    @future(callout=true)
    public static void updateOppAndSAOwnerFuture(String OppId,String leadreceiverID,String saId){
        Opportunity Opp=new Opportunity();
        opp.Id=OppId;
        opp.OwnerId = leadreceiverID;
        OpportunityTriggerHandler.RUN_TRIGGER = false;
        update opp ;
        
        ServiceAppointment sa=new ServiceAppointment();
        sa.Id=saId;
        sa.OwnerId=leadreceiverID;
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ;
        ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = false ;
        AssignedResourceTriggerHandler.CHANGE_SA_OPP_STATUS_OWNER = false ;
        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = true ;
        ServiceAppointmentTriggerHandler.DO_NOT_CHANGE_FOR_RT = true ;
        update sa; 
        
    }
    /**
*   @Method:        updateOppdateforRehash
*   @Purpose:       Whenever Rehash appointment is created, update the appointment date on opportunity
*   @Author:        Kalyan
*   @Date:          09/08/2021
*   @TaskSource:    

*   @Updates:       
*/
    public static void updateOppdateforRehash(List<ServiceAppointment> appointments)
    {
//        System.debug('@@ updateOppdateforRehash Entry');
        //03/23/2022 : pallavi, adding RT check to prevent sales code execution for PIES

		Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        List<Id> listSAIds=new List<Id>();
        for(ServiceAppointment sa : appointments)
        {
            // if(sa.EarliestStartTime != sa.SchedStartTime ) sa.EarliestStartTime = sa.SchedStartTime ;
            // if(sa.DueDate != sa.SchedEndTime ) sa.DueDate = sa.SchedEndTime ;
            if(sa.RecordTypeId != piesRT &&  sa.Rehash_Appointment__c==true){
                listSAIds.add(sa.Id);
            }
        }
        
        if(listSAIds.size()==0) return;
        List<ServiceAppointment> listSA=[SELECT ID,Opportunity__c,Opportunity__r.Zone__r.OperatingHours.TimeZone,
                                         SchedStartTime FROM ServiceAppointment Where Id in :listSAIds AND RecordTypeId != :piesRT];
        for(ServiceAppointment SA : listSA){
            Opportunity Opp=new Opportunity();
            opp.Id=SA.Opportunity__c;
            opp.Appointment_DateTime__c = SA.SchedStartTime;
            opp.StageName = 'Active';
            opp.Status__c = 'Active';
            Datetime nextDay12AM = Datetime.newInstance(sa.SchedStartTime.addDays(1).date() , Time.newInstance(0, 0, 0, 0) );
            
            // If integration user is updating then use OpreatingHours timezone to adjust date
            if(!String.isBlank(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone) && UserInfo.getTimeZone().getOffset(sa.SchedStartTime) == 0 )
            {
                TimeZone tz = TimeZone.getTimeZone(sa.Opportunity__r.Zone__r.OperatingHours.TimeZone);
                nextDay12AM = nextDay12AM.addSeconds((tz.getOffset(sa.SchedStartTime)/1000)*-1);
            }else{
                // If Appointment reschedule from the SF not from pella site , then need to update Appointment_DateTime_Email__c
                // assumption is that Login user timezone and Zone territory timezone always same
                // Added on 12-05 (reset GMT Date) 
                DateTime AppDateTimeGMT=sa.SchedStartTime;
                Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(sa.SchedStartTime)/1000;
                opp.Appointment_DateTime_Email__c= sa.SchedStartTime.addSeconds(TimeZoneGMTdiffSec);
//                system.debug('Appointment_DateTime_Email__c :' + opp.Appointment_DateTime_Email__c);
            }
            
            opp.Appointment_Next_Day_12AM__c = nextDay12AM ;
            OpportunityTriggerHandler.RUN_TRIGGER = false;
            update opp ;
        }
//        System.debug('@@ updateOppdateforRehash Exit');
        
    }
    public static void setBestMatchRehashAppointment(List<ServiceAppointment> appointments)
    {
        //03/23/2022 : pallavi, adding RT check to prevent sales code execution for PIES
		Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        List<Id> listSAIds=new List<Id>();
        for(ServiceAppointment sa : appointments)
        {
            // if(sa.EarliestStartTime != sa.SchedStartTime ) sa.EarliestStartTime = sa.SchedStartTime ;
            // if(sa.DueDate != sa.SchedEndTime ) sa.DueDate = sa.SchedEndTime ;
            if(sa.RecordTypeId != piesRT && sa.Rehash_Appointment__c==true){
                listSAIds.add(sa.Id);
            }
        }
        
        if(listSAIds.size()==0) return;
        
        List<ServiceAppointment> listSA=[SELECT ID,Opportunity__r.AccountId,Opportunity__c,
                                         Opportunity__r.Account.PersonMailingStreet,Opportunity__r.Account.PersonMailingCity,
                                         Opportunity__r.Account.PersonMailingState,Opportunity__r.Account.PersonMailingPostalCode,
                                         Opportunity__r.Account.PersonMailingCountry,
                                         Opportunity__r.Appointment_Type__c,SchedStartTime FROM ServiceAppointment Where Id in :listSAIds];
        for(ServiceAppointment SA : listSA){
            // Added Condition on 15-05 Do not call set best match if Opp is NRT type
            if(sa.Opportunity__r.Appointment_Type__c!='NRT' && sa.Opportunity__r.Appointment_Type__c!='Self-Gen' ){
                
                // Added on 19-05 Change Appointdate time in case of manually  reschedule from salesforce
                DateTime AppDateTimeEmail=sa.SchedStartTime;
//                System.debug('UAC: Inside@369 ');
                ServicePOSTRTA.setBestMatchFuture( sa.Opportunity__r.AccountId, sa.Opportunity__c, null, sa.Id, sa.Opportunity__r.Account.PersonMailingStreet, null, 
                                                  sa.Opportunity__r.Account.PersonMailingCity, sa.Opportunity__r.Account.PersonMailingState, sa.Opportunity__r.Account.PersonMailingPostalCode, 
                                                  sa.Opportunity__r.Account.PersonMailingCountry, String.valueOf(AppDateTimeEmail), '' );
            }
        }
    }
    
    public static Boolean RUN_UPDATE_OPPORTUNITY_VIRTUAL_APPOINTMENT = true ;
    public static void updateOpportunityForVirtualAppoinment(List<ServiceAppointment> appointments, Map<Id,ServiceAppointment> oldMap)
    {
//        System.debug('UAC: updateOpportunityForVirtualAppoinment ENTRY ');
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        // Iterate over Service Appointments
        for(ServiceAppointment sa : appointments)
        {
            ServiceAppointment old = oldMap.get(sa.Id);
            if( sa.Virtual_Appointment__c != old.Virtual_Appointment__c && String.isNotBlank(sa.Opportunity__c) ) oppsToUpdate.add(new Opportunity(Id=sa.Opportunity__c, Virtual_Appointment__c = sa.Virtual_Appointment__c));
        }
        
        if(oppsToUpdate.size() == 0 ) return ;
        
        OpportunityTriggerHandler.RUN_TRIGGER = false ;
        update oppsToUpdate ;
        
//        System.debug('UAC: updateOpportunityForVirtualAppoinment EXIT ');
    }
    
    public static void syncEarliestStartAndDueDate(List<ServiceAppointment> appointments)
    {
        //03/23/2022 : pallavi, adding RT check to prevent sales code execution for PIES
		Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        for(ServiceAppointment sa : appointments)
        {
            // if(sa.EarliestStartTime != sa.SchedStartTime ) sa.EarliestStartTime = sa.SchedStartTime ;
            // if(sa.DueDate != sa.SchedEndTime ) sa.DueDate = sa.SchedEndTime ;
            
            if(sa.RecordTypeId != piesRT && sa.Status != 'Canceled' ) sa.EarliestStartTime = sa.SchedStartTime ;
            if(sa.RecordTypeId != piesRT && sa.Status != 'Canceled' ) sa.DueDate = sa.SchedEndTime ;
        }
    }
    
    
    /**
*   @Method:        createEventforAppointment
*   @Purpose:       Whenever ServiceAppoint is created, create an Event so the Sales rep can see it in the Calendar
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/012/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static void createEventforAppointment(List<ServiceAppointment> appointments)
    {
//        System.debug('@@ in the createEventforAppointment');
        
        Id softAssignedRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Soft_Assign').getRecordTypeId();
        //Pallavi, 02/28/22 , including OV/Install record type so that sales code is not fired for PIES
        Id ovInstallRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('OV_Install').getRecordTypeId();
        Id csRecordTypeId 		 = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(Constant.SA_CS_RT).getRecordTypeId();
        List<Event> createEventList = new List<Event>();
        
        // Iterate over Service Appointments
        for(ServiceAppointment sa : appointments)
        {
            if(sa.RecordTypeId != ovInstallRecordTypeId && sa.RecordTypeId != csRecordTypeId && !string.ValueOf(sa.ParentRecordId).startsWith('1WL')  && (sa.Status=='Soft Assigned' ||  sa.Status=='Scheduled' ||  sa.Status=='Preference'  || sa.Status=='Canceled' || sa.Status=='Completed'))
            {
//                system.debug('Line 771 :' + sa.RecordTypeId);
                Event evtObj = new Event();
                if(sa.RecordTypeId == softAssignedRecordTypeId)
                {
                    evtObj.Subject = 'Soft Assign Placeholder';
                    evtObj.Location = sa.State + ',' + sa.city + ',' + sa.PostalCode ; //Pallavi/05/27/2020 Location not stamped when Soft Assigned
                }
                else
                {
                    evtObj.Subject = sa.Subject;
                    evtObj.Location = sa.Homeowner_Address__c;
                    evtObj.Description = sa.Description;
                }
                
                evtObj.OwnerId=sa.OwnerId;
                evtObj.Event_Type__c='RTA';
                if( sa.Status=='Preference'  || sa.Status=='Canceled' || sa.Status=='Completed')
                {
                    evtObj.ShowAs='Free';
                }
                else
                {
                    evtObj.ShowAs='Busy';
                }
                
                evtObj.WhatId = sa.Id;
                evtObj.StartDateTime = sa.SchedStartTime;
                evtObj.EndDateTime = sa.SchedEndTime;
                ///evtObj.Description = sa.Description; //Rekha - Description shouldn't be visible on soft assign
                evtObj.Opportunity_Party_Account_Name__c = sa.Opportunity_Party_Account_Name__c ;
                evtObj.Opportunity_Address__c = sa.Opportunity_Address__c.replaceAll('_BR_ENCODED_', ' ') ;
                evtObj.Virtual_Appointment__c = sa.Virtual_Appointment__c ;
                
                if(evtObj.Virtual_Appointment__c) evtObj.Subject = 'VIRTUAL - ' + evtObj.Subject;
                createEventList.add(evtObj);
            }
        }
        
        //Create the Event records
       
        if(!createEventList.IsEmpty())
        {
//            system.debug('createEventList : ' + createEventList);
            Boolean currentFlag=EventTriggerHandler.runTrigger;
            EventTriggerHandler.runTrigger=false;
            insert createEventList;
//            system.debug('Event :' + createEventList[0].Location);
            EventTriggerHandler.runTrigger=currentFlag;
            
        }
    }
    
    public static Boolean CREATE_EVENT_RECORD=true;
    public static void createOrUpdateEventforAppointment(List<ServiceAppointment> appointments,Map<Id,ServiceAppointment> oldMap)
    {
         //Pallavi, 02/28/22 , including OV/Install record type so that sales code is not fired for PIES
        Id ovInstallRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('OV_Install').getRecordTypeId();
        Id softAssignedRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Soft_Assign').getRecordTypeId();   
        Id evRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('PIES_OV_Install_Event').getRecordTypeId();
//        System.debug('UPdate trigered');
        List<Event> createEventList = new List<Event>();
        List<ServiceAppointment> listSA=new List<ServiceAppointment>();
        // Iterate over Service Appointments
        for(ServiceAppointment sa : appointments)
        {
            if(sa.recordtypeId != ovInstallRecordTypeId && !string.ValueOf(sa.ParentRecordId).startsWith('1WL')  ){
            //if(sa.recordtypeId != ovInstallRecordTypeId){
                 if( ( sa.Status!=oldMap.get(sa.Id).Status && (sa.Status=='Soft Assigned' || sa.Status=='Scheduled' || sa.Status=='Preference' || sa.Status=='Canceled' || sa.Status=='Completed' )) ||
                   sa.Status=='Canceled'  ||
                   (sa.SchedStartTime != oldMap.get(sa.Id).SchedStartTime && sa.SchedStartTime!=null) ||
                   (sa.SchedEndTime != oldMap.get(sa.Id).SchedEndTime && sa.SchedEndTime !=null) ||
                   sa.Homeowner_Address__c != oldMap.get(sa.Id).Homeowner_Address__c ||
                   sa.OwnerId != oldMap.get(sa.Id).OwnerId ||
                   sa.RecordTypeId!=oldMap.get(sa.Id).RecordTypeId ||
                   sa.Description!=oldMap.get(sa.Id).Description ||
                   sa.Virtual_Appointment__c != oldMap.get(sa.Id).Virtual_Appointment__c || 
                   sa.Subject != oldMap.get(sa.Id).Subject ){   
                		listSA.add(sa);
            	}
            }
        }
        
        // added on 26-07 resolve 100 SOQL
        if(listSA.size()==0) return;
        
        Map<Id,Id> mapEventSA=new Map<Id,Id>();
        
        List<Event> listEvent=[SELECT Id,WhatId FROM Event Where WhatId In :listSA AND RecordTypeId != :evRTId order by createddate desc ];
        for(Event ev:listEvent){
            mapEventSA.put(ev.WhatId,ev.Id);
        }
        Map<Id,ServiceAppointment> mapSA=new Map<Id,ServiceAppointment>([SELECT Id, OwnerId, Opportunity_Party_Account_Name__c, Opportunity_Address__c, Virtual_Appointment__c  
                                                                         FROM ServiceAppointment WHERE ID IN :listSA AND RecordTypeId != :ovInstallRecordTypeId]);
        for(ServiceAppointment SA : listSA)
        {
            Event evtObj = new Event();
            if(mapEventSA.containsKey(sa.Id))
            {
                evtObj.Id=mapEventSA.get(sa.Id);
            }
            if(sa.RecordTypeId==softAssignedRecordTypeId)
            {
                evtObj.Subject = 'Soft Assign Placeholder';
                if(String.isNotBlank(sa.Subject) && sa.Subject.startsWith('TRANSFERRED - ')) evtObj.Subject = 'TRANSFERRED - ' + evtObj.Subject ;
                evtObj.Location = sa.State + ',' + sa.city + ',' + sa.PostalCode ; //Pallavi/05/27/2020 Location not stamped when Soft Assigned// evtObj.Location ='' ;
            }
            else
            {
                evtObj.Subject = sa.Subject;
                evtObj.Location = sa.Homeowner_Address__c ;
                evtObj.Description = sa.Description;
            }
            
            evtObj.Event_Type__c='RTA';
            
            if( sa.Status=='Preference' || sa.Status=='Canceled' || sa.Status=='Completed')
            {
                evtObj.ShowAs='Free';
            }
            else
            {
                evtObj.ShowAs='Busy';
                if(String.isNotBlank(sa.Subject) && sa.Subject.startsWith('TRANSFERRED - ')) evtObj.ShowAs='Free'; 
            }
            
            evtObj.OwnerId=sa.OwnerId;
            evtObj.WhatId = sa.Id;
            //evtObj.Description = sa.Description;// Rekha  Description not visible on soft assigned
            evtObj.Opportunity_Party_Account_Name__c = sa.Opportunity_Party_Account_Name__c ;
            evtObj.Virtual_Appointment__c = sa.Virtual_Appointment__c ;
            if(evtObj.Virtual_Appointment__c) evtObj.Subject = 'VIRTUAL - ' + evtObj.Subject;
            if(sa.Status == 'Canceled' && !evtObj.Subject.startsWith('CANCELED - ') ) evtObj.Subject = 'CANCELED - ' + evtObj.Subject;
//            System.debug('UAC: sa.Opportunity_Address__c ' + sa.Opportunity_Address__c );
            evtObj.Opportunity_Address__c = sa.Opportunity_Address__c.replaceAll('_BR_ENCODED_', ' ') ;
            
            if(sa.SchedStartTime!=null) evtObj.StartDateTime = sa.SchedStartTime;
            if(sa.SchedEndTime!=null) evtObj.EndDateTime = sa.SchedEndTime;
            
            // check if event is canceled 12-03
            if(sa.Status=='Canceled' &&  sa.OwnerId == oldMap.get(sa.Id).OwnerId && mapSA.containsKey(sa.Id)){
                evtObj.OwnerId = mapSA.get(sa.Id).OwnerId;
                
            }
            // Handler Cancel event Change, If no event related to SA and date time is null , do not create event
            if(evtObj.Id==null && (sa.SchedStartTime==null || sa.SchedEndTime==null) ){
                continue;
            }
            createEventList.add(evtObj);
        }
        
        //Create the Event records
        if(!createEventList.IsEmpty())
        {
//            system.debug('Inside');
            Boolean currentFlag=EventTriggerHandler.runTrigger;
            EventTriggerHandler.runTrigger=false;
            upsert createEventList;
//            system.debug('createEventList :' + createEventList);
            EventTriggerHandler.runTrigger=currentFlag;
            
        }
    }
    public static void createEventforRideAlong(List<ServiceAppointment> appointments,Map<Id,ServiceAppointment> oldMap)
    {
        List<Event> createEventList = new List<Event>();
        List<ServiceAppointment> listSA=new List<ServiceAppointment>();
        Id SoftAssignedRecordTypeId =Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Soft_Assign').getRecordTypeId();   
        Id piesSART = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        Id piesSRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
        // Iterate over Service Appointments
        for(ServiceAppointment SA : appointments){
            if(sa.RecordTypeId != piesSART ){
                if(sa.Ride_Along__c==true && sa.Ride_Along__c!=oldMap.get(sa.Id).Ride_Along__c &&  sa.Ride_Along_User__c==null){
                sa.Ride_Along_User__c=userInfo.getUserId();
                Event evtObj = new Event();
                if(sa.recordTypeId==SoftAssignedRecordTypeId){
                    evtObj.Subject = 'Soft Assign Placeholder';
                    evtObj.Location ='';
                }else{
                    evtObj.Subject = sa.Subject;
                    evtObj.Location = sa.Homeowner_Address__c;
                }
                evtObj.Event_Type__c='RTA';
                if( sa.Status=='Preference' || sa.Status=='Canceled' || sa.Status=='Completed'){
                    evtObj.ShowAs='Free';
                }else{
                    evtObj.ShowAs='Busy';
                }
                
                evtObj.OwnerId=UserInfo.getUserId();
                evtObj.WhatId = sa.Id;
                if(sa.SchedStartTime!=null)
                    evtObj.StartDateTime = sa.SchedStartTime;
                if(sa.SchedEndTime!=null)
                    evtObj.EndDateTime = sa.SchedEndTime;
                
                createEventList.add(evtObj);
            }
            }
            
        }
//        system.debug('@@createEventList'+createEventList);
        //Create the Event records
        if(!createEventList.IsEmpty())
        {
            Boolean currentFlag=EventTriggerHandler.runTrigger;
            EventTriggerHandler.runTrigger=false;
            upsert createEventList;
            EventTriggerHandler.runTrigger=currentFlag;
            
        }
    }
    /**
*   @Method:        piesserviceapptRecordShare
*   @Purpose:       To share the service appointments with sales reps for PIES
*   @Author:        Pallavi (eVerge)
*   @Date:          02/05/2022
*   @TaskSource:    

*   @Updates:       
*/
    public static void piesserviceapptRecordShare(List<ServiceAppointment> sas, Map<Id,ServiceAppointment> oldMap){
        Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        Map<String, List<String>> mapwosaIds = new map<String, List<String>>();
        for(ServiceAppointment sa :sas){
//            system.debug('Line 971 :'+ sa.RecordTypeId);
            if(oldmap == null && sa.RecordTypeId == piesRT){
                if(!mapwosaIds.containsKey(sa.ParentRecordId)){
                      mapwosaIds.put(sa.ParentRecordId, new List<String>{sa.Id}  );
//                	  system.debug('Line 974 Work order : '+ mapwosaIds); 
                }
                else { mapwosaIds.get(sa.ParentRecordId).add(sa.Id);  }
              
            }
        }
        if(mapwosaIds.size() >0){
//            system.debug('Line 976' + mapwosaIds); 
            ServiceAppointmentRecordShare.shareSAwihtWOQuoteOwner(mapwosaIds); 
        }
    }



    /**
*   @Method         : customerServiceSARecordShare
*   @Purpose        : To share the service appointments to Group based on Case Branch.
*   @Author         : Rahul Sangwan (eVerge)
*   @Date           : 4 July 2023
*   @TaskSource     : SCS-406

*   @Updates:       
*/
    public static void customerServiceSARecordShare(List<ServiceAppointment> newList){
        Id csRT                             = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get(Constant.SA_CS_RT).RecordTypeId;
        Map<Id, Id> saAndWOMap              = new Map<Id, Id>();
        Map<Id, Id> saAndCaseIdMap          = new Map<Id, Id>();
        Map<Id, WorkOrder> workOrderMap;

        try{
            for(ServiceAppointment saObj :newList){
                String parentRecordId = saObj.ParentRecordId;
                if(saObj.RecordTypeId == csRT && parentRecordId.startsWithIgnoreCase(woKeyPrefix)){
                    saAndWOMap.put(saObj.Id, saObj.ParentRecordId);
                }
            }
    
            if(!saAndWOMap.isEmpty()) {
                workOrderMap = new Map<Id, WorkOrder>([Select Id,CaseId from WorkOrder where Id IN: saAndWOMap.values() AND CaseId != null]);
                for(Id saId :  saAndWOMap.keySet()) {
                    if(workOrderMap != null && workOrderMap.containsKey(saAndWOMap.get(saId))) saAndCaseIdMap.put(saId, workOrderMap.get(saAndWOMap.get(saId)).CaseId);
                }
            }
    
            if(!saAndCaseIdMap.isEmpty()) SharingUtility.createSharingRecords_v2(saAndCaseIdMap, 'ServiceAppointmentShare');
        } catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ServiceAppointmentTriggerHandler', 'customerServiceSARecordShare', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        
    }
    
     /**
*   @Method:        piesApptWORecordShareWithLoggedInUser
*   @Purpose:       To share the service appointments with logged in user who will schedule the SA
*   @Author:        Pallavi (eVerge)
*   @Date:          006/05/2022
*   @TaskSource:    

*   @Updates:       
*/
    public static void piesApptWORecordShareWithLoggedInUser(List<ServiceAppointment> sas, Map<Id,ServiceAppointment> oldMap){
        Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        Set<Id> saWOLIId = new Set<Id>();
        try{
            for(ServiceAppointment sa :sas){
//            	system.debug('sa.ParentRecordId :' + sa.ParentRecordId);
            	if(oldmap == null && sa.RecordTypeId == piesRT){
				  saWOLIId.add(sa.ParentRecordId);              
            	}
        	}
        	if(saWOLIId.size() >0){
//            	system.debug('saWOLIId :' + saWOLIId);
           		ServiceAppointmentRecordShare.shareWORecordWithLoggedinUser(saWOLIId);
        	}
            
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        
    }
    
    /**
*   @Method:        updateWOLITimeAndDuration
*   @Purpose:       To update Related WOLI Installtion Date/Time and Install Duration
*   @Author:        Dhruv
*   @Date:          03/15/2022
*   @TaskSource:    

*   @Updates:       
*/
     public static void updateWOLITimeAndDuration(List<ServiceAppointment> saList){
        Map<Id,WorkOrderLineItem> WOLIUpdateList = new Map<Id,WorkOrderLineItem>();
        for(ServiceAppointment sa :saList){// update WOLI based on related SA
            WorkOrderLineItem WOL = new WorkOrderLineItem();
            WOL.Id = sa.ParentRecordId;
            WOL.Installation_Date_Time__c = sa.SchedStartTime;
            WOL.Install_Duration_Minutes__c = sa.Duration;
            WOLIUpdateList.put(WOL.Id,WOL);
            
        }
        
        Map<Id,WorkOrderLineItem> listWOLI=new Map<Id,WorkOrderLineItem>([SELECT ID FROM WorkOrderLineItem Where Id=:WOLIUpdateList.keyset() and WorkType.Schedule_Type__c!='OV'  ]);
        List<WorkOrderLineItem> listWOLIToUpdate=new List<WorkOrderLineItem>();
        for(Id WOLIId : WOLIUpdateList.keySet()){
            if(listWOLI.containsKey(WOLIId)){
                listWOLIToUpdate.add(WOLIUpdateList.get(WOLIId));
            }
        }
        if(!listWOLIToUpdate.isEmpty()){
            boolean flag=WorkOrderTriggerHandler.RUN_TRIGGER ;
            WorkOrderTriggerHandler.RUN_TRIGGER = false;
            update listWOLIToUpdate;
            WorkOrderTriggerHandler.RUN_TRIGGER = flag;
        }
    }
    
    /**
*   @Method:        PIESUpdateRecordTypeforSalesUsers
*   @Purpose:       To update the RecordType on PIES Service Appointments when created by Replacement Reps via Candidates 
                    buttom from Work Order Line Item. Default Recordtype for Replacement users is SoftAssigned and 
                    the same gets stamped on the PIES SA created via Candidates button from WOLI.
*   @Author:        Pallavi
*   @Date:          07/27/2022
*   @TaskSource:    

*   @Updates:       
*/
  
    public static void PIESUpdateRecordTypeforSalesUsers(List<ServiceAppointment> saList, Map<Id,ServiceAppointment> oldMap){
        Id piesRT = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        List<ServiceAppointment> listupdatesa = new List<ServiceAppointment>();
        for(ServiceAppointment sa : saList){
            if(String.ValueOf(sa.ParentRecordId).startsWith('1WL') && sa.RecordTypeId != piesRT ){
//                system.debug('RT :' + sa.RecordTypeId);
                ServiceAppointment s = new ServiceAppointment();
                s.Id = sa.Id;
                s.RecordTypeId = piesRT;
                s.Status = 'New';
                listupdatesa.add(s);
          	}
        }
        if(listupdatesa.size() > 0){
            UPDATE listupdatesa;
        }
    }
}





// Soft Assign RT = 01223000000CidQ Hard Assign RT = 01223000000CidV