/*trigger LeaveRequestTrigger on Leave_Request__c (before insert, before Update , after Update) {
    
   /* for (Leave_Request__c leaveRequest : Trigger.new) {
        if (leaveRequest.From_Date__c != null && leaveRequest.To_Date__c != null) {
            // Instantiate CalcBusinessDays class
            CalcBusinessDays businessDaysCalculator = new CalcBusinessDays();
            
            // Calculate number of business days between From Date and To Date
            Date fromDate = leaveRequest.From_Date__c;
            Date toDate = leaveRequest.To_Date__c;
            Integer businessDays = businessDaysCalculator.getNoOfNonBusinessDaysBetweenDates(fromDate, toDate);

            // Update Number of Days field
            leaveRequest.Number_of_Days__c = businessDays;
        }
    }
*/
/*for (Leave_Request__c leaveRequest : Trigger.new) {
        if (leaveRequest.From_Date__c != null && leaveRequest.To_Date__c != null) {
            // Instantiate CalcBusinessDays class
            CalcBusinessDays businessDaysCalculator = new CalcBusinessDays();
            
            // Calculate non-business days between From Date and To Date
            Date fromDate = leaveRequest.From_Date__c;
            Date toDate = leaveRequest.To_Date__c;
            List<Date> nonBusinessDays = businessDaysCalculator.getNonBusinessDaysBetweenDates(fromDate, toDate);

            // Set the count of non-business days
            leaveRequest.Number_of_Days__c  = Decimal.valueOf(nonBusinessDays.size());
        }
    }*/
//}*/
//

trigger LeaveRequestTrigger on Leave_Request__c (after Update) {
 // Update the status for Approval Process  Cancell to Pending
    Set<Id> recordIds1 = new Set<Id>();
    for (Leave_Request__c obj : Trigger.new) {
        
        if(obj.Status__c=='Cancelled' ){
            recordIds1.add(obj.Id);
              system.debug('as---->> 1');
        }
    }
    if(recordIds1 != null){
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest> ();
        
        system.debug('as---->> 2');
        
        Map<ID, Leave_Request__c> opps = New Map<ID,Leave_Request__c>([Select Id from Leave_Request__c where ID IN:recordIds1]);
        
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