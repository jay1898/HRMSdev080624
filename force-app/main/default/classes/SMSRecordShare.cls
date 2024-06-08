public class SMSRecordShare {
  
         /**
*   @Method:        shareSMSRecordWithETMGroup
*   @Purpose:       To share the Salesforce SMS only within the Branch
*   @Author:        Heena (eVerge)
*   @Date:          09/07/2022
*   Testclass :SMSRecordShareBatchTest   

*   @Updates:       
*/
  public static void shareSMSRecordWithETMGroup(List<Id> smsIds){
       List<TwilioMessage__c> tMessage =
            [Select Id, Opportunity__c,Opportunity__r.OwnerId,Branch__r.AOR__r.Name, Branch__r.Branch_Number__c from TwilioMessage__c where Id IN :smsIds];
      
      List<String> BranchNumbers = new List<String>();
        List<String> listAORBranchName = new List<String>();
      
      // Create set of parent accountIds
        for(TwilioMessage__c msg:tMessage){
            if(msg.Branch__r.Branch_Number__c != null){
                BranchNumbers.add(msg.Branch__r.Branch_Number__c);
            }
            if(msg.Branch__r.AOR__r.Name != null){
                listAORBranchName.add(msg.Branch__r.AOR__r.Name);
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
      
      List<TwilioMessage__Share> listSmsShare=new List<TwilioMessage__Share>();
        for(TwilioMessage__c msg:tMessage){
            if(msg.Branch__r.Branch_Number__c != null && branchNumberWiseETM.containsKey(msg.Branch__r.Branch_Number__c)){
                for(String Tid : branchNumberWiseETM.get(msg.Branch__r.Branch_Number__c)){
                    TwilioMessage__Share smsShare = new TwilioMessage__Share();
                    smsShare.ParentId = msg.Id; 
                    smsShare.UserOrGroupId = TerritoryWiseGroup.get(Tid); 
                    smsShare.AccessLevel = 'Edit';
                    smsShare.RowCause = 'Manual';
                    listSmsShare.add(smsShare);
                }
            }
            // AOR Base Sharing
            if(msg.Branch__r.AOR__r.Name != null && AORWiseUserlist.containsKey(msg.Branch__r.AOR__r.Name)){
                for(String UId: AORWiseUserlist.get(msg.Branch__r.AOR__r.Name)){
                    TwilioMessage__Share smsShare = new TwilioMessage__Share();
                    smsShare.ParentId = msg.Id; 
                    smsShare.UserOrGroupId =UId; 
                    smsShare.AccessLevel = 'Read';
                    smsShare.RowCause = 'Manual';
                    listSmsShare.add(smsShare);
                }
            }
            // Opportunity Owner Sharing
            if(msg.Opportunity__c!=null){
                TwilioMessage__Share smsShare = new TwilioMessage__Share();
                smsShare.ParentId = msg.Id; 
                smsShare.UserOrGroupId =msg.Opportunity__r.OwnerId; 
                smsShare.AccessLevel = 'Read';
                smsShare.RowCause = 'Manual';
                listSmsShare.add(smsShare);
            }
            
        } 
        if(listSmsShare.size()>0)
            Database.Insert(listSmsShare, false);
  } 
    
    public static void shareSMSRecordWithOppOwner(List<Id> oppIds){
        List<TwilioMessage__c> tMessage =
            [Select Id, Opportunity__c,Opportunity__r.OwnerId,Branch__r.AOR__r.Name, Branch__r.Branch_Number__c from TwilioMessage__c where Opportunity__c IN :oppIds];
        
        List<TwilioMessage__Share> listSmsShare=new List<TwilioMessage__Share>();
        
        for(TwilioMessage__c msg:tMessage){
            // Opportunity Owner Sharing
            if(msg.Opportunity__c!=null){
                TwilioMessage__Share smsShare = new TwilioMessage__Share();
                smsShare.ParentId = msg.Id; 
                smsShare.UserOrGroupId =msg.Opportunity__r.OwnerId; 
                smsShare.AccessLevel = 'Edit';
                smsShare.RowCause = 'Manual';
                listSmsShare.add(smsShare);
            }
        }
        
        if(listSmsShare.size()>0)
            Database.Insert(listSmsShare, false);
    } 
     
}