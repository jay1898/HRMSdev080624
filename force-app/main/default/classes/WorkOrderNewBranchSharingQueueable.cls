public class WorkOrderNewBranchSharingQueueable implements Queueable{
    
    Map<Id, Id> woAndCaseMap, caseAndRelatedOldBranchMap;

    public WorkOrderNewBranchSharingQueueable(Map<Id, Id> woAndCaseMap, Map<Id, Id> caseAndRelatedOldBranchMap) {
        this.woAndCaseMap               = woAndCaseMap;
        this.caseAndRelatedOldBranchMap = caseAndRelatedOldBranchMap;
    }

    public void execute(QueueableContext context) {
        try{
            SharingUtility.createSharingRecords_v2(woAndCaseMap, 'WorkOrderShare');    
        }catch(Exception e) {
            
        }
        if(!Test.isRunningTest())
        System.enqueueJob(new SABranchSharingQueueable(caseAndRelatedOldBranchMap));
    }
}