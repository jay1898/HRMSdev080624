/**
* @description       : QuestionTemplateTrigger Question_Template__c Trigger
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
trigger QuestionTemplateTrigger on Question_Template__c (before insert, before update, before delete) {
    if(trigger.isbefore){
        //before record created or updated
        if(trigger.isInsert || trigger.isUpdate){
            QuestionTemplateTriggerHandler.questionIsFirstValidation(Trigger.new);
        }
        //before record delteted
        else if(trigger.isDelete){
            QuestionTemplateTriggerHandler.validateInBQJ(Trigger.old);
        }
    }
}