public without sharing class OpportunityRecordShareRemoveBatch implements Database.Batchable<sObject>,Schedulable {
    
    public set<Id> branchList=new set<Id>();
    public Boolean isUserAORChange=false;
    public list<String> listUserIdsToRemoveShare=new List<string>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(isUserAORChange){
            return Database.getQueryLocator([SELECT ID,Opportunity.CampaignId from OpportunityShare where UserOrGroupId in :listUserIdsToRemoveShare]);
        }else{
            return Database.getQueryLocator([SELECT ID,Opportunity.CampaignId from OpportunityShare where Opportunity.Zone__r.ParentTerritory.Branch__c in :branchList and UserOrGroupId in :listUserIdsToRemoveShare ]);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<OpportunityShare> listOppsShare){
        
        List<Id> listCampaignId=new List<Id>();
        
        for(OpportunityShare OppShare : listOppsShare){
            listCampaignId.add(OppShare.Opportunity.CampaignId);
        }
        List<CampaignShare> listCampShare=[SELECT Id FROM CampaignShare where CampaignId in :listCampaignId and UserOrGroupId in :listUserIdsToRemoveShare ]; 
        
        Database.Delete(listCampShare, false);
        
        Database.delete(listOppsShare, false);
        
        
       
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        OpportunityRecordShareRemoveBatch b = new OpportunityRecordShareRemoveBatch(); 
        database.executebatch(b,200);
    }
}