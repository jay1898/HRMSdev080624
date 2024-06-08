//Test class : ServiceTerritoryAssignmentBatchTest
public class ServiceTerritoryAssignmentBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ID,Territory_Reference_Number__c,Territory_Type_Name__c FROM Territory2 where Territory_Type_Name__c  in ('Branch_Family','Branch')  ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Territory2> listTerritory2){
        List<String> listBranchNumber=new List<String>();
        List<String> listBranchFamilyNumber=new List<String>();
        for(Territory2 T : listTerritory2){
            if(T.Territory_Reference_Number__c!=null ){
                if(T.Territory_Type_Name__c=='Branch'  ){
                    listBranchNumber.add(T.Territory_Reference_Number__c);
                }
                else if(T.Territory_Type_Name__c=='Branch_Family' ){
                    listBranchFamilyNumber.add(T.Territory_Reference_Number__c);
                }
            }
        } 
        if(listBranchNumber.size()>0 || listBranchFamilyNumber.size()>0){
            List<ServiceTerritory> listSTFromBranch=[SELECT ID FROM ServiceTerritory 
                                                     Where Branch__r.Branch_Number__c = :listBranchNumber
                                                     OR Branch__r.Branch_Family__r.Branch_Family_Number__c = :listBranchFamilyNumber];
            List<String> listSTIds=new List<String>();
            for(ServiceTerritory ST: listSTFromBranch){
                listSTIds.add(ST.Id);
            }
            system.debug('@@listSTIds :: '+listSTIds);
            if(listSTIds.size()>0){
                ServiceTerritoryRecordShare.shareSTRecordWithETM(listSTIds);
            }
           
        }
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        ServiceTerritoryAssignmentBatch b = new ServiceTerritoryAssignmentBatch(); 
        database.executebatch(b,1);
    }
}