/**
* @description       : BranchTrigger Branch__c Trigger
* @author            : Mayank Srivastava | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   03-05-2022    Mayank Srivastava  Initial Version()
* 1.1   26-09-2022    Dhruv Javiya  put Validation
**/
trigger BranchTrigger on Branch__c (after insert,after update, before insert, before update) {
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.Branch_Disable_Trigger__c ) ) return ;
    
    //After record created or updated
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        List<Branch__c> listBranch=new List<branch__c>();
        List<Branch__c> listBranchRemoveAccess=new List<branch__c>();
        Map<Id,Id> mapBranchWiseOldAOR=new Map<Id,Id>();
        Map<Id,Id> mapBranchWiseAOR=new Map<Id,Id>();
        for(Branch__c branch:trigger.New){
            if(Trigger.isInsert ){
                listBranch.add(branch);
            }   
            if(Trigger.isUpdate && branch.AOR__c!=trigger.oldMap.get(branch.id).AOR__c ){
                if(trigger.oldMap.get(branch.id).AOR__c!=null){
                    mapBranchWiseOldAOR.put(branch.Id,trigger.oldMap.get(branch.id).AOR__c);
                }
                if(branch.AOR__c!=null){
                    mapBranchWiseAOR.put(branch.Id,branch.AOR__c);
                }
                listBranchRemoveAccess.add(branch);
                listBranch.add(branch);
            }   
        }
        if(listBranchRemoveAccess.size()>0){
            // remove access of campaign records
            BranchTriggerHandler.removeShareBranchRecordWithETM(listBranchRemoveAccess);
            
        }
        if(listBranch.size()>0){
            // give access of campaign records
            BranchTriggerHandler.shareBranchRecordWithETM(listBranch);
        }
        
        // remove opportunity with AOR
        if(mapBranchWiseOldAOR.keySet().size()>0){
            OpportunityRecordShare.removeRecordShareWithAOR(mapBranchWiseOldAOR);
        }
        
        // share opportunity with AOR
        if(mapBranchWiseAOR.keySet().size()>0){
            OpportunityRecordShare.shareRecordWithAOR(mapBranchWiseAOR);
        }
    }
    //before record created or updated
    if(trigger.isbefore && (trigger.isInsert || trigger.isUpdate)){
        BranchTriggerHandler.validateEnableSMSFeature(trigger.New);
    }
}