trigger ServiceAppointmentTrigger on ServiceAppointment(before insert ,before update, after update,after insert) 
{
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Service_Appointment_Disable_Trigger__c) ) return ;
    
    // 5th July 2023, Rahul Sangwan , To update the FSSK__FSK_Work_Order__c on SA, if SA is linked to Work Order.
    if(Trigger.isInsert && Trigger.isBefore) {
        ServiceAppointmentTriggerHandler.onBeforeInsert(Trigger.new);
    }

    // 02/25/2022, Pallavi , Share the PIES SA with retail/trade Sales reps
    if(Trigger.isAfter && Trigger.isInsert) {
        ServiceAppointmentTriggerHandler.PIESUpdateRecordTypeforSalesUsers(Trigger.new,Trigger.oldMap); //Pallavi Patil :uncomment only after Pella Approves
        ServiceAppointmentTriggerHandler.piesserviceapptRecordShare(Trigger.new, Trigger.oldMap);
        ServiceAppointmentTriggerHandler.piesApptWORecordShareWithLoggedInUser(Trigger.New, Trigger.oldMap);
        ServiceAppointmentTriggerHandler.customerServiceSARecordShare(Trigger.new);
    }
    
    // TO Disable All Triggers 
    if(!ServiceAppointmentTriggerHandler.RUN_TRIGGER) return ;
   
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        //ServiceAppointmentTriggerHandler.syncEarliestStartAndDueDate(Trigger.new);
        if(ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH) ServiceAppointmentTriggerHandler.setBestMatchOnAppointmentReschedule(Trigger.new, Trigger.oldMap);   
        ServiceAppointmentTriggerHandler.createEventforRideAlong(Trigger.new,Trigger.oldMap);
    }

    //Create an Event on Appointment creation
    if(Trigger.isAfter && Trigger.isInsert)
    {
        if(ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD) ServiceAppointmentTriggerHandler.createEventforAppointment(Trigger.new);   
        ServiceAppointmentRecordShare.shareSARecordWithSTM(Trigger.New); 
        //ServiceAppointmentRecordShare.shareWORecordWithLoggedinUser(Trigger.New);
    }

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
      
        if(ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE) ServiceAppointmentTriggerHandler.createAssignedResourceOnAppointmentOwnerChange(Trigger.new, Trigger.oldMap, Trigger.isInsert);
        ServiceAppointmentTriggerHandler.updateOppdateforRehash(Trigger.New);   
    }

    if(Trigger.isAfter && Trigger.isUpdate)
    {
       
        if(ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE) ServiceAppointmentTriggerHandler.changeOpportunityAndSAOwnerOnAppointmentCancel(Trigger.new, Trigger.oldMap);
        if(ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD) ServiceAppointmentTriggerHandler.createOrUpdateEventforAppointment(Trigger.new,Trigger.oldMap);
        if(ServiceAppointmentTriggerHandler.RUN_UPDATE_OPPORTUNITY_VIRTUAL_APPOINTMENT) ServiceAppointmentTriggerHandler.updateOpportunityForVirtualAppoinment(Trigger.new, Trigger.oldMap);

        // 05-03 If owner change need to reshare with territory
        List<ServiceAppointment> listSAtoReshare=new list<ServiceAppointment>();
        for(ServiceAppointment sa: Trigger.new){
            if(sa.ownerId != Trigger.oldMap.get(sa.Id).OwnerId){
                listSAtoReshare.add(sa);
            }
        }
        if(listSAtoReshare.size()>0){
            ServiceAppointmentRecordShare.shareSARecordWithSTM(listSAtoReshare);
}
    }  
    // added on 03-15-2022 for synce related WOLI Installation Date/Time and Install Duration Field bas on SA
    List<ServiceAppointment> saList = new List<ServiceAppointment>();
    if( trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        for(ServiceAppointment sa : trigger.new){
            if(String.valueOf(sa.ParentRecordId).startsWith('1WL') && sa.SchedStartTime!=null &&  (Trigger.isInsert || sa.SchedStartTime!= trigger.oldMap.get(sa.id).SchedStartTime)){
                saList.add(sa);
            }
        }
        if(!saList.isEmpty()){
            system.debug('saList :' + saList);
            ServiceAppointmentTriggerHandler.updateWOLITimeAndDuration(saList);
        }
            
    }
    
}