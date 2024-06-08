public without sharing class LeadRecordShare {
    
    public static void shareLeadRecordWithETMGroup(List<Id> leadIds){
        List<Lead> leads =
            [Select Id,Zone__r.ParentTerritory.Branch__r.Branch_Number__c,
             Zone__r.ParentTerritory.Branch__r.AOR__c,Zone__r.ParentTerritory.Branch__r.AOR__r.Name 
             from Lead where Id IN :leadIds];
        List<String> BranchNumbers = new List<String>();
        List<String> listAORBranchName = new List<String>();
        // Create set of parent accountIds
        for(Lead lead:leads){
            if(lead.Zone__r.ParentTerritory.Branch__r.Branch_Number__c != null){
                BranchNumbers.add(lead.Zone__r.ParentTerritory.Branch__r.Branch_Number__c);
            }
            if(lead.Zone__r.ParentTerritory.Branch__r.AOR__r.Name != null){
                listAORBranchName.add(lead.Zone__r.ParentTerritory.Branch__r.AOR__r.Name);
            }
        }
        
        List<Territory2> listETM =[SELECT ID,Territory_Reference_Number__c,parentTerritory2Id,Territory_Type_Name__c FROM Territory2 Where Territory_Type_Name__c='Branch' and Territory_Reference_Number__c in :BranchNumbers];
        Map<String,List<Id>> branchNumberWiseETM=new Map<String,List<Id>>();
        Set<Id> setTerritoryIds=new set<Id>();
        for(Territory2 T : listETM){
            if(T.Territory_Reference_Number__c!=null){
                branchNumberWiseETM.put(T.Territory_Reference_Number__c,new List<Id>());
                branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.Id);
                branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.parentTerritory2Id);
                
                setTerritoryIds.add(T.Id);
                setTerritoryIds.add(T.parentTerritory2Id);
            }
        }
        
        Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :setTerritoryIds];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.RelatedId,g.Id);
        }
        
        
        List<LeadShare> listLeadShare=new List<LeadShare>(); 
        for(Lead lead: leads){
            if(lead.Zone__r.ParentTerritory.Branch__r.Branch_Number__c != null && branchNumberWiseETM.containsKey(lead.Zone__r.ParentTerritory.Branch__r.Branch_Number__c)){
                for(String Tid : branchNumberWiseETM.get(lead.Zone__r.ParentTerritory.Branch__r.Branch_Number__c)){
                    LeadShare leadShare = new LeadShare();
                    leadShare.LeadId = lead.Id; 
                    leadShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                    leadShare.LeadAccessLevel = 'Edit';
                    leadShare.RowCause = 'Manual';
                    listLeadShare.add(leadShare);
                }
            }
        } 
        if(listLeadShare.size()>0)
            Database.Insert(listLeadShare, false);
              
    }
    
	 public static void removeShareLeadWithETM(List<Id> leadIds){
        List<LeadShare> listLeadShare=[SELECT ID from LeadShare where LeadId in :leadIds];
         Database.Delete(listLeadShare, false);
    } 
}