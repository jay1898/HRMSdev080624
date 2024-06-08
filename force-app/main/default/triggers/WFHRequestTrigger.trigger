trigger WFHRequestTrigger on Work_From_Home__c (after Update) {
    
 
 // Update the status for Approval Process  Cancell to Pending
    Set<Id> recordIds1 = new Set<Id>();
    for (Work_From_Home__c obj : Trigger.new) {
        
        if(obj.Status__c=='Cancelled' ){
            recordIds1.add(obj.Id);
              system.debug('as---->> 1');
        }
    }
    if(recordIds1 != null){
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest> ();
        
        system.debug('as---->> 2');
        
        Map<ID, Work_From_Home__c> opps = New Map<ID,Work_From_Home__c>([Select Id from Work_From_Home__c where ID IN:recordIds1]);
        
        //Get ProcessInstance Items
        
        Map<ID,ProcessInstance> piMap = New Map<ID,ProcessInstance>([Select Id from ProcessInstance where TargetObjectId IN :opps.keySet()]);
        
        for(ProcessInstanceWorkItem pp : [Select Id from ProcessInstanceWorkItem where ProcessInstanceId IN :piMap.keySet() ]){
            
            // if there's a work item, set the action to 'removed' and execute
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            
            req2.setAction('Removed');
            
            req2.setWorkitemId(pp.Id);
            
            requests.add(req2);  
        }
        Approval.ProcessResult[] processResults = null;
        
        processResults = Approval.process(requests, true);
        
    } 

}