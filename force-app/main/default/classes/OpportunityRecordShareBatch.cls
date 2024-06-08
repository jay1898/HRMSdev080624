public without sharing class OpportunityRecordShareBatch implements Database.Batchable<sObject>,Schedulable {
    
    public Map<Id,Id> mapBranchWiseAOR=new Map<Id,Id>();
    public Map<Id,Id> removeMapBranchWiseAOR=new Map<Id,Id>();
    public set<String> listAORBranchName=new set<String>();
    public List<String> listAORUserIds=new List<String>();
    public Boolean isUserAORChange=false;
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(isUserAORChange){
            return Database.getQueryLocator([Select ID,CampaignId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.AOR__c,Zone__r.ParentTerritory.Branch__r.AOR__r.Name from Opportunity where Zone__r.ParentTerritory.Branch__r.AOR__r.Name in :listAORBranchName  ]);
        }else{
            return Database.getQueryLocator([SELECT ID,CampaignId,Zone__r.ParentTerritory.Branch__c,Zone__r.ParentTerritory.Branch__r.AOR__c,Zone__r.ParentTerritory.Branch__r.AOR__r.Name FROM Opportunity 
                                             where Zone__r.ParentTerritory.Branch__c in :mapBranchWiseAOR.keySet()
                                             and Zone__r.ParentTerritory.Branch__r.AOR__c in :mapBranchWiseAOR.values() ]);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunities){
        
        set<String> listAORBranchName=new set<String>();
        for(Opportunity opp:opportunities){
            if(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name!=null){
                listAORBranchName.add(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name);
            }
            
        }
        // get List Of AOR User
        List<User> listAORUser;
        if(isUserAORChange){
            listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c!=null and AOR__c in :listAORBranchName and Id in :listAORUserIds];
        }else{
            listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c!=null and AOR__c in :listAORBranchName];
        }        
        
        
        // AOR Wise User List for share with all the related AOR
        Map<String,set<Id>> AORWiseUserlist=new Map<String,set<Id>>();
        for(User u:listAORUser){
            if(!AORWiseUserlist.containsKey(u.AOR__c)){
                AORWiseUserlist.put(u.AOR__c,new set<Id>());
            }
            AORWiseUserlist.get(u.AOR__c).add(u.Id);
        }
        List<CampaignShare> listCampShare=new List<CampaignShare>(); 
        List<OpportunityShare> listOppShare=new List<OpportunityShare>(); 
        for(Opportunity opp: opportunities){
            if(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name != null && AORWiseUserlist.containsKey(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name))
            {
                for(String UId: AORWiseUserlist.get(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name)){
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.OpportunityId = opp.Id; 
                    oppShare.UserOrGroupId = UId; 
                    oppShare.OpportunityAccessLevel  = 'Read';
                    oppShare.RowCause = 'Manual';
                    listOppShare.add(oppShare);
                    
                    if(opp.CampaignId!=null){
                        CampaignShare campShare = new CampaignShare();
                        campShare.CampaignId = opp.CampaignId; 
                        campShare.UserOrGroupId = UId; 
                        campShare.CampaignAccessLevel  = 'Read';
                        campShare.RowCause = 'Manual';
                        listCampShare.add(campShare);
                    }
                }
                
            }
        } 
        if(listOppShare.size()>0)
            Database.Insert(listOppShare, false);
        if(listCampShare.size()>0)
            Database.Insert(listCampShare, false);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        OpportunityRecordShareBatch b = new OpportunityRecordShareBatch(); 
        database.executebatch(b,200);
    }
}