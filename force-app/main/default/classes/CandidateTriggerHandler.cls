//  don't use

public class CandidateTriggerHandler {
    
    public static void countValidationHit(List<Candidate__c> newRecList, Map<Id, Candidate__c> oldMap){
        
        //List of platform event
        List<ToUpdateValidationHitCount__e> eventList = new List<ToUpdateValidationHitCount__e>();
        
        for(Candidate__c c: newRecList){
            Candidate__c priorValue = oldMap.get(c.Id);
            
            //Check For Validation 
            if(priorValue.Status__c == 'At iTechCloud') {
                //c.IncludeInAfterUpdateTrigger__c = true;
                //c.ValidationHitCountBackend__c = c.ValidationHitCountBackend__c + 1.0;
                //c.Status__c = priorValue.Status__c;
                System.debug('Incremented Count To: ' + c.ValidationHitCountBackend__c);
                
                ToUpdateValidationHitCount__e mEvent = new ToUpdateValidationHitCount__e( RecordIdToUpdate__c= c.Id);
                eventList.add(mEvent);
                
                //Publish the event
                List<Database.SaveResult> results = EventBus.publish(eventList);
                System.debug('Evant Publish Result::: ' + results);
                
                //Print Result
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' + err.getStatusCode() );
                        }
                    }
                }
                
                c.Status__c.addError('Cannot move the status of application once candidate is at iTechCloud');
                
            } else if((priorValue.Status__c == 'Selected') && (c.Status__c == 'New Application' || c.Status__c == 'Under HR Review' || c.Status__c == 'Pre-screening & Interview Setup')) {
                //c.IncludeInAfterUpdateTrigger__c = true;
                //c.ValidationHitCountBackend__c = c.ValidationHitCountBackend__c + 1.0;
                //c.Status__c = priorValue.Status__c;
                System.debug('Incremented Count To: ' + c.ValidationHitCountBackend__c);
                
                ToUpdateValidationHitCount__e mEvent = new ToUpdateValidationHitCount__e( RecordIdToUpdate__c= c.Id);
                eventList.add(mEvent);
                
                //Publish the event
                List<Database.SaveResult> results = EventBus.publish(eventList);
                System.debug('Event Publish Result::: ' + results);
                
                //Print Result
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' + err.getStatusCode() );
                        }
                    }
                }

                c.Status__c.addError('Cannot move the application to New Application, Under HR Review and Pre-screening & Interview Setup');
                
            } else {
                //Do Nothing.
                c.IncludeInAfterUpdateTrigger__c = false;
                System.debug('Doing Nothing');
            }
        }
    }
}