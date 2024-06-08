public class CaseEscNewBranchSharingQueueable  implements Queueable{

    Map<Id, Id> ceAndCaseMap, caseAndRelatedOldBranchMap;

    public CaseEscNewBranchSharingQueueable(Map<Id, Id> ceAndCaseMap, Map<Id, Id> caseAndRelatedOldBranchMap) {
        this.ceAndCaseMap               = ceAndCaseMap;
        this.caseAndRelatedOldBranchMap = caseAndRelatedOldBranchMap;
    }


    public void execute(QueueableContext context) {
        try{
        //    SharingUtility.createSharingRecords(ceAndCaseMap, 'Case_Escalation__share');    
        }catch(Exception e) {
            
        }        
    }
}