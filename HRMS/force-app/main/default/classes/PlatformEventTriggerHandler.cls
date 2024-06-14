public class PlatformEventTriggerHandler {
    
    public static void updateValidationHitCount(List<ToUpdateValidationHitCount__e> newRecordList){
        
        for(ToUpdateValidationHitCount__e mEvent : newRecordList){
            system.debug('mEvent:: ' + mEvent.RecordIdToUpdate__c);
            Id recId = mEvent.RecordIdToUpdate__c;
            
            //query the candidate record and update it;
            Candidate__c mCandidate = [Select Id, ValidationHitCountBackend__c from Candidate__c where Id = :recId Limit 1];
            if(mCandidate != null){
                Candidate__c c = new Candidate__c(Id = mCandidate.Id);
                c.ValidationHitCountBackend__c = mCandidate.ValidationHitCountBackend__c + 1.0;
                System.debug('Incremented Count To from - ToUpdateValidationHitCount__e: ' + c.ValidationHitCountBackend__c);
                update c;
            }
        }
    }
}