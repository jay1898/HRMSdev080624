public class UpdateAddressAssignmentBatch implements Database.Batchable<sObject>,Schedulable {

 public Database.QueryLocator start(Database.BatchableContext BC){       
        return Database.getQueryLocator('Select Id, Address_City__c, Address_Country__c, Address_State__c, Address_Street__c, Address_Zip__c, Address__r.City__c, Address__r.Country__c, Address__r.State__c, Address__r.Street__c, Address__r.Zipcode__c from Address_Assignment__c where Address__c != null');
    }
    
    public void execute(Database.BatchableContext BC, List<Address_Assignment__c> listAddRecs){
       for(Address_Assignment__c addObj : listAddRecs) {
         /*  addObj.Address_City__c       = addObj.Address__r.City__c;
           addObj.Address_Country__c    = addObj.Address__r.Country__c;
           addObj.Address_State__c      = addObj.Address__r.State__c;
           addObj.Address_Street__c     = addObj.Address__r.Street__c;
           addObj.Address_Zip__c        = addObj.Address__r.Zipcode__c;*/
       }
       Database.update(listAddRecs, false);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        UpdateAddressAssignmentBatch b = new UpdateAddressAssignmentBatch(); 
        database.executebatch(b,200);
    }
}