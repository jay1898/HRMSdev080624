trigger CandidateTrigger on Candidate__c (before update) {

    //To Check: Where this record fall under validation viloation
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('Inside Before Update');
        CandidateTriggerHandler.countValidationHit(Trigger.New, Trigger.oldMap);
    }
    
    //To Throw Error: for those recrod who falls under validation viloation
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('Inside After Update');
        CandidateTriggerHandler.throwValidationError(Trigger.New, Trigger.oldMap);
    }
}