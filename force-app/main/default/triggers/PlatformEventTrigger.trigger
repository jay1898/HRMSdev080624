trigger PlatformEventTrigger on ToUpdateValidationHitCount__e (after insert) {
    
    //To Check: Where this record fall under validation viloation
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('Inside After Insert Trigger on ToUpdateValidationHitCount__e');
        PlatformEventTriggerHandler.updateValidationHitCount(Trigger.New);
    }
}