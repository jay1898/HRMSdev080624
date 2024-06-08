public class OpportunityRecordShare {
  
    public static void shareOppRecordWithETMGroup(List<Id> opportunityIds){
        List<Opportunity> opportunities =
            [Select Id, AccountId,Account.Branch__r.T_C_Branch_Number__c, Territory2Id,Account_Branch_Profile__r.Branch__r.Branch_Number__c,Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c,Zone__r.ParentTerritory.Branch__r.Branch_Number__c,
             Zone__r.ParentTerritory.Branch__r.AOR__c,Zone__r.ParentTerritory.Branch__r.AOR__r.Name,CampaignId,RecordType.DeveloperName,Account.RecordType.DeveloperName 
             from Opportunity where Id IN :opportunityIds];
        List<String> BranchNumbers = new List<String>();
        List<String> TCBranchNumbers = new List<String>();
        List<String> listAORBranchName = new List<String>();
        // Create set of parent accountIds
        for(Opportunity opp:opportunities){
            if(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c != null){
                BranchNumbers.add(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c);
            }
            if(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name != null){
                listAORBranchName.add(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name);
            }
            // trade & commercial opportunity sharing
            if(opp.Account.Branch__r.T_C_Branch_Number__c!=null){
                TCBranchNumbers.add(opp.Account.Branch__r.T_C_Branch_Number__c);
            }
            // added on 07-11 trade & commercial opportunity sharing Person account
            if(opp.RecordType.DeveloperName=='trade_comm' && opp.Account.RecordType.DeveloperName=='PersonAccount' && opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c!=null){
                TCBranchNumbers.add(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c);
            }
        } 
         system.debug('@@TCBranchNumbers'+TCBranchNumbers);
        List<Territory2> listETM =[SELECT ID,Territory_Reference_Number__c,parentTerritory2.TCBranchNumber__c,TCBranchNumber__c,parentTerritory2Id,Territory_Type_Name__c FROM Territory2 Where Territory_Type_Name__c in ('Branch','Trade') and (Territory_Reference_Number__c in :BranchNumbers or TCBranchNumber__c in :TCBranchNumbers or parentTerritory2.TCBranchNumber__c in :TCBranchNumbers)];
        Map<String,List<Id>> branchNumberWiseETM=new Map<String,List<Id>>();
        Map<String,set<Id>> TCbranchNumberWiseETM=new Map<String,set<Id>>();
        Map<String,set<Id>> TCTradebranchNumberWiseETM=new Map<String,set<Id>>();
        Set<Id> setTerritoryIds=new set<Id>();
        for(Territory2 T : listETM){
            if(T.Territory_Type_Name__c=='Branch'){
                if(T.Territory_Reference_Number__c!=null){
                    branchNumberWiseETM.put(T.Territory_Reference_Number__c,new List<Id>());
                    branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.Id);
                    branchNumberWiseETM.get(T.Territory_Reference_Number__c).add(T.parentTerritory2Id);
                    
                    setTerritoryIds.add(T.Id);
                    setTerritoryIds.add(T.parentTerritory2Id);
                } 
                // for trade and commercial
                if(T.TCBranchNumber__c!=null){
                    if(!TCbranchNumberWiseETM.containsKey(T.TCBranchNumber__c)){
                        TCbranchNumberWiseETM.put(T.TCBranchNumber__c,new set<Id>());
                    }
                    
                    TCbranchNumberWiseETM.get(T.TCBranchNumber__c).add(T.Id);
                    TCbranchNumberWiseETM.get(T.TCBranchNumber__c).add(T.parentTerritory2Id);
                    setTerritoryIds.add(T.Id);
                    setTerritoryIds.add(T.parentTerritory2Id);
                }
            }
            else if(T.Territory_Type_Name__c=='Trade'){
                // for trade and commercial
                if(T.parentTerritory2.TCBranchNumber__c!=null){
                    if(!TCTradebranchNumberWiseETM.containsKey(T.parentTerritory2.TCBranchNumber__c)){
                        TCTradebranchNumberWiseETM.put(T.parentTerritory2.TCBranchNumber__c,new set<Id>());
                    }
                    TCTradebranchNumberWiseETM.get(T.parentTerritory2.TCBranchNumber__c).add(T.Id);
                    setTerritoryIds.add(T.Id);
                }
            }
        }
        
        Map<Id,Id> TerritoryWiseGroup=new Map<Id,Id>();
        List<Group> listGroup=[SELECT Id,RelatedId FROM Group Where Type='Territory' and RelatedId in :setTerritoryIds];
        for(Group g: listGroup){
            TerritoryWiseGroup.put(g.RelatedId,g.Id);
        }
        
        // get List Of AOR User
        List<User> listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c in :listAORBranchName];
        
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
            if(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c != null && branchNumberWiseETM.containsKey(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c)){
               for(String Tid : branchNumberWiseETM.get(opp.Zone__r.ParentTerritory.Branch__r.Branch_Number__c)){
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.OpportunityId = opp.Id; 
                    oppShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                    oppShare.OpportunityAccessLevel = 'Edit';
                    oppShare.RowCause = 'Manual';
                    listOppShare.add(oppShare);
                   
                   if(opp.CampaignId!=null){
                       CampaignShare campShare = new CampaignShare();
                       campShare.CampaignId = opp.CampaignId; 
                       campShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                       campShare.CampaignAccessLevel  = 'Read';
                       campShare.RowCause = 'Manual';
                       listCampShare.add(campShare);
                   }
                }
            }
            // for trade and commercial
            if(opp.Account.Branch__r.T_C_Branch_Number__c != null && TCbranchNumberWiseETM.containsKey(opp.Account.Branch__r.T_C_Branch_Number__c)){
                for(String Tid : TCbranchNumberWiseETM.get(opp.Account.Branch__r.T_C_Branch_Number__c)){
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.OpportunityId = opp.Id; 
                    oppShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                    oppShare.OpportunityAccessLevel = 'Edit';
                    oppShare.RowCause = 'Manual';
                    listOppShare.add(oppShare);
                    
                    if(opp.CampaignId!=null){
                        CampaignShare campShare = new CampaignShare();
                        campShare.CampaignId = opp.CampaignId; 
                        campShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                        campShare.CampaignAccessLevel  = 'Read';
                        campShare.RowCause = 'Manual';
                        listCampShare.add(campShare);
                    }
                }
            }
             // for trade and commercial sales rep
            if(opp.Account.Branch__r.T_C_Branch_Number__c != null && TCTradebranchNumberWiseETM.containsKey(opp.Account.Branch__r.T_C_Branch_Number__c)){
                for(String Tid : TCTradebranchNumberWiseETM.get(opp.Account.Branch__r.T_C_Branch_Number__c)){
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.OpportunityId = opp.Id; 
                    oppShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                    oppShare.OpportunityAccessLevel = 'Read';
                    oppShare.RowCause = 'Manual';
                    listOppShare.add(oppShare);
                    
                    if(opp.CampaignId!=null){
                        CampaignShare campShare = new CampaignShare();
                        campShare.CampaignId = opp.CampaignId; 
                        campShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                        campShare.CampaignAccessLevel  = 'Read';
                        campShare.RowCause = 'Manual';
                        listCampShare.add(campShare);
                    }
                }
            }
            // added on 07-11 share trade and commercial for person account
            if(opp.RecordType.DeveloperName=='trade_comm' && opp.Account.RecordType.DeveloperName=='PersonAccount' && opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c!=null){
                if(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c != null && TCbranchNumberWiseETM.containsKey(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c)){
                    for(String Tid : TCbranchNumberWiseETM.get(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c)){
                        OpportunityShare oppShare = new OpportunityShare();
                        oppShare.OpportunityId = opp.Id; 
                        oppShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                        oppShare.OpportunityAccessLevel = 'Edit';
                        oppShare.RowCause = 'Manual';
                        listOppShare.add(oppShare);
                        
                        if(opp.CampaignId!=null){
                            CampaignShare campShare = new CampaignShare();
                            campShare.CampaignId = opp.CampaignId; 
                            campShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                            campShare.CampaignAccessLevel  = 'Read';
                            campShare.RowCause = 'Manual';
                            listCampShare.add(campShare);
                        }
                    }
                }
                // for trade and commercial sales rep
                if(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c != null && TCTradebranchNumberWiseETM.containsKey(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c)){
                    for(String Tid : TCTradebranchNumberWiseETM.get(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c)){
                        OpportunityShare oppShare = new OpportunityShare();
                        oppShare.OpportunityId = opp.Id; 
                        oppShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                        oppShare.OpportunityAccessLevel = 'Read';
                        oppShare.RowCause = 'Manual';
                        listOppShare.add(oppShare);
                        
                        if(opp.CampaignId!=null){
                            CampaignShare campShare = new CampaignShare();
                            campShare.CampaignId = opp.CampaignId; 
                            campShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                            campShare.CampaignAccessLevel  = 'Read';
                            campShare.RowCause = 'Manual';
                            listCampShare.add(campShare);
                        }
                    }
                }
            }
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
    public static void removeShareOppWithETM(List<Id> opportunityIds){
        List<OpportunityShare> listOppShare=[SELECT ID from OpportunityShare where OpportunityId in :opportunityIds];
         Database.Delete(listOppShare, false);
    }
    
    public static void removeRecordShareWithAOR(Map<Id,Id> mapBranchWiseAOR){
        set<String> listAORBranchName=new set<String>();
        for(Branch_Grouping__c branch:[SELECT Id,Name from Branch_Grouping__c where Id in :mapBranchWiseAOR.values()]){
            listAORBranchName.add(branch.Name);
        }
        system.debug('@@'+listAORBranchName);
        // get List Of AOR User
        List<User> listAORUser=[SELECT ID,AOR__c FROM USER where AOR__c!=null and AOR__c in :listAORBranchName];
        List<string> listUserId=new List<String>();
        for(User u: listAORUser){
            listUserId.add(u.Id);
        }
        system.debug('@@listUserId :: '+listUserId);
        OpportunityRecordShareRemoveBatch b = new OpportunityRecordShareRemoveBatch(); 
        b.branchList=mapBranchWiseAOR.keySet();
        b.listUserIdsToRemoveShare=listUserId;
        database.executebatch(b,200);
    }
    
    
    public static void shareRecordWithAOR(Map<Id,Id> mapBranchWiseAOR){
        OpportunityRecordShareBatch b = new OpportunityRecordShareBatch(); 
        b.mapBranchWiseAOR=mapBranchWiseAOR;
        database.executebatch(b,200);
    }
    
    
    public static void shareOppsWithAORUser(List<String> userIds){
        List<User> listUser=[SELECT Id,AOR__C from User where Id in :userIds];
        Map<String,Set<Id>> listAORBranchName=new Map<String,Set<Id>>();
        for(User u: listUser){
            if(u.AOR__c!=null){
                if(!listAORBranchName.containsKey(u.AOR__c)){
                    listAORBranchName.put(u.AOR__c,new set<Id>());
                }
                listAORBranchName.get(u.AOR__c).add(u.Id);
            }
        }
        
        OpportunityRecordShareBatch b = new OpportunityRecordShareBatch(); 
        b.listAORBranchName=listAORBranchName.keySet();
        b.listAORUserIds=userIds;
        b.isUserAORChange=true;
        database.executebatch(b,200);
    }
   
    public static void removeShareOppsWithAORUser(List<String> userIds){
        OpportunityRecordShareRemoveBatch b = new OpportunityRecordShareRemoveBatch(); 
        b.isUserAORChange=true;
        b.listUserIdsToRemoveShare=userIds;
        database.executebatch(b,200);
 
    }
    public static void addRemoveShareOpportuniryWithAORUser(List<String> userIds,List<String> removeUserIds){
        if(removeUserIds.size()>0){
            removeShareOppsWithAORUser(removeUserIds);
        }
        if(userIds.size()>0){
            shareOppsWithAORUser(userIds);
        }
    }
    
    
    
}