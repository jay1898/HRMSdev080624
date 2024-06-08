trigger LeadOnEmailMessage on EmailMessage (after insert) {
    
    
    if(Trigger.isAfter){
        if (Trigger.isInsert){
            Set<Id> taskIds = new Set<Id>();
            Set<Id> taskIdsOpen = new Set<Id>();
            
            for (EmailMessage email : Trigger.new) {
                if (email.ActivityId != null && email.ActivityId.getSObjectType() == Task.sObjectType) {
                    taskIds.add(email.ActivityId);
                    /*if (email.IsOpened) {
taskIdsOpen.add(email.ActivityId);
}*/
                }
            }
            
            if (!taskIds.isEmpty()) 
            {

                Map<Id, Task> taskMap = new Map<Id, Task>([ SELECT Id, WhoId FROM Task WHERE Id IN :taskIds ]);
                
                Map<Id, EmailMessage> latestEmailMessages = new Map<Id, EmailMessage>();
                
                Map<String,EmailMessage> latestEmail = new Map<String,EmailMessage>();
                for(EmailMessage EM: [SELECT Id, LastOpenedDate, FirstOpenedDate,ActivityId, MessageDate FROM EmailMessage]){
                    latestEmail.put(EM.ActivityId,EM);
                }	
                
                for (AggregateResult result : [ SELECT ActivityId, MAX(CreatedDate) maxDate FROM EmailMessage WHERE ActivityId IN :taskIds GROUP BY ActivityId ]) {
                    Id taskId = (Id) result.get('ActivityId');
                    
                    if(latestEmail.ContainsKey(taskId)){
                        latestEmailMessages.put(taskMap.get(taskId).WhoId, latestEmail.get(taskId));
                    } 
                }
                
                List<Lead> leadsToUpdate = new List<Lead>();
                
                for (Id leadId : latestEmailMessages.keySet()) {
                    EmailMessage latestEmailss = latestEmailMessages.get(leadId);
                    Lead lead = new Lead(Id = leadId);
                    lead.Last_sent_date_time__c = latestEmailss.MessageDate;
                    
                    /* if (taskIdsOpen.contains(latestEmailss.ActivityId)) {
lead.Last_opened_date_time__c = latestEmailss.FirstOpenedDate;
}*/
                    
                    leadsToUpdate.add(lead);
                }
                
                if (!leadsToUpdate.isEmpty()) {
                    update leadsToUpdate;
                }
            }
        }
    }
}