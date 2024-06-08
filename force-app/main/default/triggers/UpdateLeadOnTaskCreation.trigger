trigger UpdateLeadOnTaskCreation on Task (after insert) {
    // Collect Lead IDs associated with the newly created Tasks
    // 
    if (Trigger.isInsert && Trigger.isAfter){
        Set<Id> leadIdsToUpdate = new Set<Id>();
        for (Task newTask : Trigger.new) {
            if (newTask.WhoId != null && newTask.WhoId.getSObjectType() == Lead.sObjectType) {
                leadIdsToUpdate.add(newTask.WhoId);
            }
        }
        
        // Query for the last created Task for each Lead
        Map<Id, Task> lastTasks = new Map<Id, Task>();
        for (Task task : [ SELECT Id, WhoId, CreatedDate FROM Task WHERE WhoId IN :leadIdsToUpdate AND  Status = 'Email Response' ORDER BY CreatedDate DESC ]) {
            if (!lastTasks.containsKey(task.WhoId)) {
                lastTasks.put(task.WhoId, task);
            }
        }
        
        // Update Lead records with the last Task creation date
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Id leadId : leadIdsToUpdate) {
            if (lastTasks.containsKey(leadId)) {
                Task lastTask = lastTasks.get(leadId);
                Lead lead = new Lead(Id = leadId,Last_reply_date_time__c = lastTask.CreatedDate);
                leadsToUpdate.add(lead);
            }
        }
        
        // Perform the lead updates
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
            System.debug('leadsToUpdate' + leadsToUpdate);
        }
    }
}