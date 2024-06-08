/**
* @description       : QuestionTemplateTriggerHandler  Handler class of Question_Template__c Trigger
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History 	
* Ver   Date         Author        Modification
* 1.0   26-09-2022    Dhruv Javiya  Initial Version()
**/
public class QuestionTemplateTriggerHandler {
    /**
    *   @Method:        questionIsFirstValidation
    *   @Purpose:       validate only one Question Template selected as a First Question and Last Question
    *   @Author:        Dhruv (eVerge)
    *   @Date:          26-09-2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    public static void questionIsFirstValidation(List<Question_Template__c> listQT){
        Id FirstQuestionId,LastQuestionId;
        for(Question_Template__c QT : [SELECT Id,isFirstQuestion__c,isLastQuestion__c FROM Question_Template__c WHERE isFirstQuestion__c=True or isLastQuestion__c=true]){
            if(QT.isFirstQuestion__c==true){
                FirstQuestionId=QT.Id;
            }
            if(QT.isLastQuestion__c==true){
                LastQuestionId=QT.Id;
            }
        }
        
        List<String> listFirstQuestionList=new List<String>();
        List<String> listLastQuestionList=new List<String>();
        for(Question_Template__c qt : listQT){
            if(qt.isFirstQuestion__c && qt.Id!=FirstQuestionId ){
                listFirstQuestionList.add(qt.Id);
            }
            if(qt.isLastQuestion__c && qt.Id!=LastQuestionId){
                listLastQuestionList.add(qt.Id);
            }
            
            if(qt.Id==FirstQuestionId && qt.isFirstQuestion__c==false){
                FirstQuestionId=null;
            }
            if(qt.Id==LastQuestionId && qt.isLastQuestion__c==false){
                LastQuestionId=null;
            }
        }
        
        for(Question_Template__c qt : listQT){
            if(qt.isFirstQuestion__c && (((FirstQuestionId!=null && listFirstQuestionList.size()>0)) || (FirstQuestionId==null && listFirstQuestionList.size()>1))){
                qt.addError( Label.ValidateQuoteTemplateFirstQueError);
            }
            if(qt.isLastQuestion__c && (((LastQuestionId!=null && listLastQuestionList.size()>0)) || (LastQuestionId==null && listLastQuestionList.size()>1))){
                qt.addError( Label.ValidateQuoteTemplateLastQueError); 
            }
        }
        
        
    }
     /**
    *   @Method:        validateInBQJ
    *   @Purpose:       validate Question Template is not use in Branch Question Junction
    *   @Author:        Dhruv (eVerge)
    *   @Date:          26-09-2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    public static void validateInBQJ(List<Question_Template__c> listQT){
        Set<Id> setofBranchId = new Set<Id>();  
        for(Question_Template__c qt : listQT){
            setofBranchId.add(qt.Id);
        }
        Map<Id, List<Branch_Question_Junction__c>> mapBranchQueListbyBranch = new Map<Id, List<Branch_Question_Junction__c>>();
        List<Branch_Question_Junction__c> lstBranchQueJunction = [SELECT Question_Templates__c, Id, Order__c FROM Branch_Question_Junction__c WHERE Question_Templates__c IN: setofBranchId ];
        if(lstBranchQueJunction.size()>0){
            for (Branch_Question_Junction__c lst : lstBranchQueJunction)  {
                if(!mapBranchQueListbyBranch.containsKey(lst.Question_Templates__c)){
                    mapBranchQueListbyBranch.put(lst.Question_Templates__c,new List<Branch_Question_Junction__c>());
                }
                mapBranchQueListbyBranch.get(lst.Question_Templates__c).add(lst);
            }
        }
        
        for(Question_Template__c qt : listQT){
            List<Branch_Question_Junction__c> lstBQjbyTemplate = mapBranchQueListbyBranch.containsKey(qt.Id)  ? mapBranchQueListbyBranch.get(qt.Id) : Null;
            if(lstBQjbyTemplate != Null && lstBQjbyTemplate.size()>0){
            	qt.addError( Label.ValidateBQJOnQueTempDeleteError);    
            }
        }
    }
}