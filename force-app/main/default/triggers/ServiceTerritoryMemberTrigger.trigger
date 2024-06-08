trigger ServiceTerritoryMemberTrigger on ServiceTerritoryMember (before insert,before update) {
    // Validate If Service Resouce not exist as primary
    ServiceTerritoryMemberTriggerHandler.checkIfResourceExistAsPrimary(Trigger.new,Trigger.oldMap);
    
}