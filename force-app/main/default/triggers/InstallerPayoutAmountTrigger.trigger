/**
* @description       : InstallerPayoutAmountTrigger to manage payout records
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   08-03-2022    Dhruv Javiya  Initial Version()
**/
trigger InstallerPayoutAmountTrigger on Installer_Payout_Amount__c (before insert,after insert,before update, after update, after delete) {
    
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.IPA_Disable_Trigger__c ) ) return ;
    
    
    set<String> WOLIIds = new set<String>();
    // for update Source field based on edit payment Manually
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        
        if(Trigger.isUpdate){
            for(Installer_Payout_Amount__c IPA : trigger.new){
                // update payout source if quantity is updated 
                Installer_Payout_Amount__c oldIPA = trigger.oldMap.get(IPA.Id);
                if(IPA.Amount__c != null && (oldIPA.Amount__c != IPA.Amount__c || oldIPA.Quantity__c != IPA.Quantity__c)){
                    
                    IPA.Source__c = 'Manual';
                    // Added to handle Multiple of Qty Amount
                    IPA.Payout_Amount__c=IPA.Amount__c*IPA.Quantity__c;
                }
            }
        }
        if(Trigger.isInsert){
            for(Installer_Payout_Amount__c IPA : trigger.new){
                if(IPA.Source__c == 'Manual'){
                    // Added to handle Multiple of Qty Amount 
                    IPA.Payout_Amount__c=(IPA.Amount__c==null?0:IPA.Amount__c)*IPA.Quantity__c;
                }
                if(IPA.Amount__c==null && IPA.Payout_Amount__c!=null){
                     IPA.Amount__c=IPA.Payout_Amount__c/(IPA.Quantity__c==null?1:IPA.Quantity__c);
                }
            }
        }
    }
    
    // on Insert or update rollup Payout Amount ON WOLI
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
        for(Installer_Payout_Amount__c IPA : trigger.new){
            if((trigger.oldMap==null || trigger.oldMap.get(IPA.Id).Payout_Amount__c != IPA.Payout_Amount__c) && (IPA.Payout_Amount__c != null && IPA.Work_Order_Line_Item__c != null)){
                WOLIIds.add(IPA.Work_Order_Line_Item__c);
                //IPAListToRollUpTotalPayout.add(IPA);
            }            
        }
        if(!WOLIIds.isEmpty())
            InstallerPayoutAmountTriggerHandler.updateWOLITotalPayout(WOLIIds);
    }
    // on delete rollup Payout Amount ON WOLI
    if(Trigger.isDelete){
        for(Installer_Payout_Amount__c IPA : trigger.old){
            if(IPA.Payout_Amount__c != null && IPA.Work_Order_Line_Item__c != null){// && oldIPA.Payout_Amount__c != IPA.Payout_Amount__c
                WOLIIds.add(IPA.Work_Order_Line_Item__c);
                //IPAListToRollUpTotalPayout.add(IPA);
            }            
        }
        if(!WOLIIds.isEmpty())
            InstallerPayoutAmountTriggerHandler.updateWOLITotalPayout(WOLIIds);
    }
    
    
}