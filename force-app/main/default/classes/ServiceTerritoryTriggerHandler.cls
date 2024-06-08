public class ServiceTerritoryTriggerHandler {
    
     public void BeforeInsert(List<ServiceTerritory> newItems) {
         Id recordTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();
         set<String> listZipCode=new set<String>();
         // check zipcode already exist
         for(ServiceTerritory ST : newItems){
             if(ST.postalCode!=null && ST.RecordTypeId==recordTypeId){
                 listZipCode.add(ST.postalCode);
             }
         }
         
         // check zip code exist in the system
         Map<String,ServiceTerritory> ExistingZipCode=new Map<String,ServiceTerritory>();
         List<ServiceTerritory> listServiceTerritory=[select id,postalCode,Name,ParentTerritoryId,ParentTerritory.Parent_Branch__c from ServiceTerritory where postalCode in  :listZipCode and recordTypeId = :recordTypeId];
         for(ServiceTerritory ST :listServiceTerritory){
            ExistingZipCode.put(ST.postalCode,ST); 
         }
         
         for(ServiceTerritory ST : newItems){
             if(ST.postalCode!=null &&  ST.RecordTypeId==recordTypeId){
                 if(ExistingZipCode.containsKey(ST.PostalCode)){
                     String error=System.Label.Duplicate_ZipCode.replace(':Param1',ExistingZipCode.get(ST.PostalCode).Name);
                     error= error.replace(':Param2',ExistingZipCode.get(ST.PostalCode).ParentTerritoryId!=null?ExistingZipCode.get(ST.PostalCode).ParentTerritory.Parent_Branch__c:'');
                     ST.addError(error,false);
                 }else{
                    ExistingZipCode.put(ST.postalCode,ST);
                 }
             }
         }
     }
     public void BeforeUpdate(List<ServiceTerritory> newItems,Map<Id, ServiceTerritory> newItemMap, Map<Id, ServiceTerritory> oldItems){
        
         Id recordTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();
         set<String> listZipCode=new set<String>();
         set<Id> zipCodeSTIds=new set<Id>();
         // check zipcode already exist
         for(ServiceTerritory ST : newItems){
             if(ST.postalCode!=null &&  ST.RecordTypeId==recordTypeId && ST.postalCode!=oldItems.get(ST.Id).postalCode){
                 listZipCode.add(ST.postalCode);
                 zipCodeSTIds.add(ST.Id);
             }
         }
         // check zip code exist in the system
         Map<String,ServiceTerritory> ExistingZipCode=new Map<String,ServiceTerritory>();
         List<ServiceTerritory> listServiceTerritory=[select id,postalCode,Name,ParentTerritoryId,ParentTerritory.Parent_Branch__c from ServiceTerritory where postalCode in  :listZipCode and Id not in :zipCodeSTIds and recordTypeId=:recordTypeId];
         for(ServiceTerritory ST :listServiceTerritory){
             ExistingZipCode.put(ST.postalCode,ST);
         }
         for(ServiceTerritory ST : newItems){
             if(ST.postalCode!=null &&  ST.RecordTypeId==recordTypeId && ST.postalCode!=oldItems.get(ST.Id).postalCode){
                 if(ExistingZipCode.containsKey(ST.PostalCode)){
                      String error=System.Label.Duplicate_ZipCode.replace(':Param1',ExistingZipCode.get(ST.PostalCode).Name);
                     error= error.replace(':Param2',ExistingZipCode.get(ST.PostalCode).ParentTerritory!=null?ExistingZipCode.get(ST.PostalCode).ParentTerritory.Parent_Branch__c:'');
                     ST.addError(error,false);
                 }else{
                    ExistingZipCode.put(ST.postalCode,ST);
                 }
             }
         }
         
     }
     public void BeforeDelete(Map<Id, SObject> oldItems) {}
     public void AfterInsert(List<ServiceTerritory> newItems) {
         List<Id> listSTIds=new List<Id>();
         for(ServiceTerritory ST : newItems){
             listSTIds.add(ST.Id);
         }
         ServiceTerritoryRecordShare.shareSTRecordWithETM(listSTIds);
     }
     public void AfterUpdate(List<ServiceTerritory> newItems,Map<Id, ServiceTerritory> newItemMap, Map<Id, ServiceTerritory> oldItems) {
         List<Id> listSTIds=new List<Id>();
         Id recordTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();
         for(ServiceTerritory ST : newItems){
             if((ST.Branch__c!=oldItems.get(ST.Id).Branch__c) || (ST.RecordTypeId==recordTypeId && ST.ParentTerritoryId !=oldItems.get(ST.Id).ParentTerritoryId)){
                 listSTIds.add(ST.Id);
             }
         }
         if(listSTIds.size()>0){
             ServiceTerritoryRecordShare.removeShareSTRecordWithETM(listSTIds);
             ServiceTerritoryRecordShare.shareSTRecordWithETM(listSTIds);
         }
         
     }
     public void AfterDelete(Map<Id, SObject> oldItems) {}
     public void AfterUndelete(Map<Id, SObject> oldItems) {}

}