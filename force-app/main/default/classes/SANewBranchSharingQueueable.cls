public class SANewBranchSharingQueueable implements Queueable{

    public Map<Id, Id> saAndCaseMap, caseAndRelatedOldBranchMap;

    public SANewBranchSharingQueueable(Map<Id, Id> saAndCaseMap, Map<Id, Id> caseAndRelatedOldBranchMap) {
        this.saAndCaseMap               = saAndCaseMap;
        this.caseAndRelatedOldBranchMap = caseAndRelatedOldBranchMap;
    }


    public void execute(QueueableContext context) {
        try{
            SharingUtility.createSharingRecords_v2(saAndCaseMap, 'ServiceAppointmentShare');    
        }catch(Exception e) {
            
        } 
        if(!Test.isRunningTest())
        System.enqueueJob(new CaseEscalationBranchSharingQueueable(caseAndRelatedOldBranchMap));
    }
    
}