/**
* @description       : BranchTriggerHandler Handler of Branch__c Trigger
* @author            : Mayank Srivastava | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   03-05-2022    Mayank Srivastava  Initial Version()
* 1.1   26-09-2022    Dhruv Javiya  put Validation
**/
public class BranchTriggerHandler {
    public static void shareBranchRecordWithETM(List<Branch__c> listBranch){
        List<String> listBranchNumber=new List<String>();
        for(Branch__c branch: listBranch){
            if(branch.branch_Number__c!=null){
                listBranchNumber.add(branch.branch_Number__c);
            }
        }
        //BranchRecordShare.shareBranchRecordWithAORUser(listBranch);
        BranchRecordShare.shareBranchRecordWithETMGroup(listBranchNumber);
    }
    public static void removeShareBranchRecordWithETM(List<Branch__c> listBranch){
        List<String> listBranchNumber=new List<String>();
        for(Branch__c branch: listBranch){
            if(branch.branch_Number__c!=null){
                listBranchNumber.add(branch.branch_Number__c);
            }
        }
       // BranchRecordShare.removeShareBranchRecordWithETM(listUser);
        BranchRecordShare.removeShareBranchRecordWithETMGroup(listBranchNumber);
    }
    
      /**
    *   @Method:        validateEnableSMSFeature
    *   @Purpose:       validate branch Enable SMS Featur  when Branch_Question_Junction record per branch is atleast one.
    *   @Author:        Dhruv (eVerge)
    *   @Date:          26-09-2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    public static void validateEnableSMSFeature(List<Branch__c> listBranch){
        Set<Id> setofEnableBranchId = new Set<Id>(); 
        for(Branch__c branch : listBranch){
            if(branch.Enable_SMS_Feature__c){
                setofEnableBranchId.add(branch.Id);
            }
        }
        
        if(setofEnableBranchId.size()>0){
            AggregateResult[] groupedResults = [SELECT Branch__c, count(Id) queCount  FROM Branch_Question_Junction__c WHERE Branch__c IN: setofEnableBranchId GROUP BY Branch__c];
            Map<string,Decimal> mapQueCountByBranch = new Map<string,Decimal>();
            for (AggregateResult ar : groupedResults)  {
                mapQueCountByBranch.put(string.valueOf(ar.get('Branch__c')),  (Decimal) ar.get('queCount'));
            }
            
            system.System.debug('@@mapQueCountByBranch: '+mapQueCountByBranch);
            for(Branch__c branch : listBranch){
                Decimal queCount = mapQueCountByBranch.containsKey(branch.Id) ? mapQueCountByBranch.get(branch.Id) : 0;
                system.System.debug('@@queCount: '+queCount);
                if(queCount < 1){ 
                    branch.addError( Label.EnableSMSError);
                }
            }
        }
    }
}