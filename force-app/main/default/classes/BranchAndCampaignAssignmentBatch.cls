//Test class : ServiceGETRTATest
public class BranchAndCampaignAssignmentBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ID,Territory_Reference_Number__c,Territory_Type_Name__c FROM Territory2 where Territory_Type_Name__c  in ('Branch')  ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Territory2> listTerritory2){
        List<String> listBranchNumber=new List<String>();
        List<String> listBranchFamilyNumber=new List<String>();
        for(Territory2 T : listTerritory2){
            if(T.Territory_Reference_Number__c!=null ){
                    listBranchNumber.add(T.Territory_Reference_Number__c);
            }
        } 
        if(listBranchNumber.size()>0 ){
            BranchRecordShare.shareBranchRecordWithETMGroup(listBranchNumber);
            CampaignRecordShare.shareCampaignRecordWithETMGroup(listBranchNumber);
        }
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        BranchAndCampaignAssignmentBatch b = new BranchAndCampaignAssignmentBatch(); 
        database.executebatch(b,1);
    }
}