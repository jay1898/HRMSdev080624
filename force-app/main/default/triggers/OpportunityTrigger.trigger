trigger OpportunityTrigger on Opportunity(before insert, after insert, before update, after update) 
{
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Opportunity_Disable_Trigger__c ) ) return ;

    // Opportunity Sharing Added before run trigger as it's always need to be execute
    if(Trigger.isAfter) {
        OpportunityTriggerHandler.oppRecordShare(Trigger.new, Trigger.oldMap);
    }
        
    if(!OpportunityTriggerHandler.RUN_TRIGGER) return ;
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        OpportunityTriggerHandler.updateCommunicationStage(Trigger.new, Trigger.oldMap);
        OpportunityTriggerHandler.createOrUpdateABP(Trigger.new, Trigger.oldMap);
        // Method to update the EDW Last Modified
        OpportunityTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.oldMap, Trigger.newMap);
        if(OpportunityTriggerHandler.CHANGE_OWNER_FOR_CANCEL_STATUS) OpportunityTriggerHandler.changeOpportunityOwnerForCanceledStatus(Trigger.new, Trigger.oldMap);
        OpportunityTriggerHandler.updateOppOwnerWithRehashAppointmentOnOppClose(Trigger.new, Trigger.oldMap);
      
    }

    if(Trigger.isAfter && Trigger.isUpdate)
        //&& OpportunityTriggerHandler.RUN_AFTER_UPDATE)
    {
        if( !cs.Disbale_PQM_Integration__c ) OpportunityTriggerHandler.postShellQuoteToPQM(Trigger.new, Trigger.oldMap);
        if( !cs.Disbale_PQM_Integration__c ) OpportunityTriggerHandler.postClosedOppOnPQM(Trigger.new, Trigger.oldMap);
        OpportunityTriggerHandler.createSA_AssignedResourceForOppOwnerChange(Trigger.new,Trigger.oldMap);
        OpportunityTriggerHandler.opportunityCommunication(Trigger.new, Trigger.oldMap);   
        if(OpportunityTriggerHandler.RUN_UPDATE_SA_ON_VIRTUAL_OPPORTUNITY) OpportunityTriggerHandler.updateSAonVirtualOpportunity(Trigger.new, Trigger.oldMap);

        // Added on 27-03 to update SA
        OpportunityTriggerHandler.updateSAonUpdate_SA_HelperChange(Trigger.new, Trigger.oldMap);
        //Added to update Geo Codes
        OpportunityTriggerHandler.updateGeoCodes(Trigger.new, Trigger.oldMap, Trigger.newMap);
        
        //Pallavi, to create a clone of Replacement Opp for TC
        OpportunityTriggerHandler.updateOppOwnerforTC(Trigger.new, Trigger.oldMap);
         //Pallavi, to add the sales rep to Opp Team Member when approved
        System.debug('41 TRIGGER Number of Queries used in this apex code so far: ' + Limits.getQueries());
        OpportunityTriggerHandler.createOppTeamMember(Trigger.new, Trigger.oldMap);//SELF GEN RECORD CREATION METHOD
        System.debug('43 TRIGGER Number of Queries used in this apex code so far: ' + Limits.getQueries());
        // To retain the credit added by the previous opp owner
        OpportunityTriggerHandler.createOppSplit(Trigger.new,Trigger.oldMap);
        
        OpportunityTriggerHandler.updateYTDonAccount(Trigger.new,Trigger.oldMap);
        OpportunityTriggerHandler.updatePYTDonAccount(Trigger.new, Trigger.oldMap);
        OpportunityTriggerHandler.RUN_AFTER_UPDATE = false; //SARAN ADDED THIS ATTRIBUTE TO STOP THE RECURSIVE
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        //Added to update Geo Codes
        OpportunityTriggerHandler.updateGeoCodes(Trigger.new, null, Trigger.newMap);
        
    }
    if(Trigger.isBefore && Trigger.isInsert){
        //Added to update Geo Codes
        OpportunityTriggerHandler.createOrUpdateABP(Trigger.new,Trigger.oldMap);
        // Method to update the EDW Last Modified
        OpportunityTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    /*if(Trigger.isAfter && OpportunityTriggerHandler.RUN_UPDATE_CAMPAIGN) { //SARAN- W-000994
        if(Trigger.isInsert) {
            OpportunityTriggerHandler.updateCampaignForAllRecords(Trigger.new, null, false);
            //OpportunityTriggerHandler.createAccountCampaignMember(Trigger.new);
        } else {
            OpportunityTriggerHandler.updateCampaignForAllRecords(Trigger.new, Trigger.oldMap, true);
        }
    }*/
}