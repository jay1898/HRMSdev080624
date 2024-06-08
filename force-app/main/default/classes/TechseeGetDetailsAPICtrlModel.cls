public class TechseeGetDetailsAPICtrlModel {
    
    public static Case getCaseDetails(Id caseId) {
        return [Select Id, Origin, TechSee_Request_Id__c
                from Case 
                where Id =: caseId];
    }
}