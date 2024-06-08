/**
* @description       : BranchQuestionJunctionTriggerHandler Handler of Question_Template__c Trigger
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
public class BranchQuestionJunctionTriggerHandler {
      /**
    *   @Method:        validateQueCountAndOrder
    *   @Purpose:       validate Branch Question Junction order is in correct manner and it's not more than 6 per branch.
    *   @Author:        Dhruv (eVerge)
    *   @Date:          26-09-2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    public static void validateQueCountAndOrder(List<Branch_Question_Junction__c> listBQJ,  Map<Id, Branch_Question_Junction__c> oldMap){
        Set<Id> setofBranchId = new Set<Id>();
        for(Branch_Question_Junction__c bqj : listBQJ){
            Branch_Question_Junction__c bqjOld = oldMap!=null && oldMap.containsKey(bqj.Id) ? oldMap.get(bqj.Id) : null;
            if(bqjOld==null || (bqjOld!=null && (bqjOld.Order__c != bqj.Order__c || bqjOld.Branch__c != bqjOld.Branch__c))){
                setofBranchId.add(bqj.Branch__c);
            }
        }
        if(setofBranchId.size()>0){
            AggregateResult[] groupedResults = [SELECT Branch__c, count(Id) queCount  FROM Branch_Question_Junction__c WHERE Branch__c IN: setofBranchId GROUP BY Branch__c];
            Map<string,Decimal> mapQueCountByBranch = new Map<string,Decimal>();
            Map<Id, List<Branch_Question_Junction__c>> mapBranchQueListbyBranch = new Map<Id, List<Branch_Question_Junction__c>>();
            List<Branch_Question_Junction__c> lstBranchQueJunction = [SELECT Branch__c, Id, Order__c FROM Branch_Question_Junction__c WHERE Branch__c IN: setofBranchId ];
            if(lstBranchQueJunction.size()>0){
                for (Branch_Question_Junction__c lst : lstBranchQueJunction)  {
                    if(!mapBranchQueListbyBranch.containsKey(lst.Branch__c)){
                        mapBranchQueListbyBranch.put(lst.Branch__c,new List<Branch_Question_Junction__c>());
                    }
                    mapBranchQueListbyBranch.get(lst.Branch__c).add(lst);
                }
            }
            for (AggregateResult ar : groupedResults)  {
                mapQueCountByBranch.put(string.valueOf(ar.get('Branch__c')),  (Decimal) ar.get('queCount'));
            }
            for(Branch_Question_Junction__c bqj : listBQJ){
                Decimal queCount = mapQueCountByBranch.containsKey(bqj.Branch__c) ? mapQueCountByBranch.get(bqj.Branch__c) : 0;
                Branch_Question_Junction__c bqjOld = oldMap!=null && oldMap.containsKey(bqj.Id) ? oldMap.get(bqj.Id) : null;
               if(bqjOld==null && queCount >= 6){
                    bqj.addError( Label.StopInsertmorethanSixQueError);
                }
                else{
                    List<Branch_Question_Junction__c> lstBQj = mapBranchQueListbyBranch.containsKey(bqj.Branch__c)  ? mapBranchQueListbyBranch.get(bqj.Branch__c) : Null;
                    boolean isInValid = false;
                    if(lstBQj!=null && lstBQj.size()>0){
                        for(Branch_Question_Junction__c objbqj : lstBQj){
                            if(objbqj.Order__c == bqj.Order__c){
                                isInValid = true;
                                break;
                            }
                        }
                    }
                    if(isInValid){
                        bqj.addError( Label.ValidateOrderError);
                    }
                }
            }
        }
    }
      /**
    *   @Method:        validateQueCountAndOrder
    *   @Purpose:       validate on delete of Branch Question Junction order related Branch's SMS Feature is not Enabled.
    *   @Author:        Dhruv (eVerge)
    *   @Date:          26-09-2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    public static void validateEnableSMSFeature(List<Branch_Question_Junction__c> listBQJ,  Map<Id, Branch_Question_Junction__c> oldMap){
        Set<Id> setofBranchId = new Set<Id>();
        for(Branch_Question_Junction__c bqj : listBQJ){
               setofBranchId.add(bqj.Branch__c);
        }
        if(setofBranchId.size()>0){
            Map<Id, Branch__c> mapBranch = new Map<Id, Branch__c>([SELECT Id, Name, Enable_SMS_Feature__c FROM Branch__c WHERE Id IN: setofBranchId AND Enable_SMS_Feature__c=true]);
            if(mapBranch != null){
                for(Branch_Question_Junction__c bqj : listBQJ){
                    if(mapBranch.containsKey(bqj.Branch__c)){
                        bqj.addError( Label.ValidateSMSOnDeleteBQJError);
                    }
                }
            }
        }
    }
}