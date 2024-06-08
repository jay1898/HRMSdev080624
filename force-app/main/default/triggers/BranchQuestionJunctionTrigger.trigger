/**
* @description       : BranchQuestionJunctionTrigger Branch_Question_Junction__c Trigger
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
trigger BranchQuestionJunctionTrigger on Branch_Question_Junction__c (before insert, before update, before delete) {
    if(trigger.isbefore){
        //before record created 
        if(trigger.isInsert){
            BranchQuestionJunctionTriggerHandler.validateQueCountAndOrder(Trigger.new, null);
        }
        //before record updated
        else if(trigger.isUpdate){
            BranchQuestionJunctionTriggerHandler.validateQueCountAndOrder(Trigger.new, Trigger.oldMap);
        }
        //before record delteted
        else if(trigger.isDelete){
            BranchQuestionJunctionTriggerHandler.validateEnableSMSFeature(Trigger.old, Trigger.oldMap);
        }
    }
}