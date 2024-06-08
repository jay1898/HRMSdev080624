public class CallFlowHomeOwnerController {
    
    @AuraEnabled
    public static List<Section_Question_Junction__c> getSectionQuestion(){
        return [Select id,Section__r.Name,Section__r.Section_Order__c,Section__r.Active__c,Question__r.Active__c, Question__r.Question__c, Question__r.Type__c,Order__c  from Section_Question_Junction__c Where Section__r.Active__c = true and Question__r.Active__c = true order by Section__r.Section_Order__c,Order__c ];
    }

    @AuraEnabled
    public static List<Question__c> getAllSubQuestions(){
        return [Select Id, Question__c, Active__c, hasChildQuestions__c, Parent_Question_Answer__c, Sub_Question_Order__c, Type__c, Parent_Question__c from Question__c where RecordType.name='Sub Question' order by Parent_Question_Answer__c,Sub_Question_Order__c];
    }
    
    @AuraEnabled
    public static void storeAnswers(List<Answer__c> answerList){
        try {
            insert answerList;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Case_Assessment__c> getCaseAssessmentRecords(String caseId){
        return [Select Id,Case__c,CreatedBy.Name,CreatedDate  from Case_Assessment__c Where Case__c =: caseId Order by CreatedDate Desc];
    }
    
    @AuraEnabled
    public static List<Answer__c> getAnswerUsingCaseAssessment(String caseAssessmetnId){
        List<Answer__c> returnList= new List<Answer__c>();
        for(Answer__c ans: [Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Question__c,Question__r.Question__c, Answer__c, Section_Name__c, Case_Assessment__c, Order__c, Answer_Type__c,CreatedBy.Name from Answer__c Where Case_Assessment__c =: caseAssessmetnId Order By Order__c]){
            if(!(ans.Answer_Type__c == 'RadioButton' && String.isBlank(ans.Answer__c))){
                returnList.add(ans);
            }
        }
        return returnList;
    }
    // @AuraEnabled
    // public static List<Answer__c> getAnswerUsingCaseAssessment(String caseAssessmetnId){
    //     return [Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Question__c,Question__r.Question__c, Answer__c, Section_Name__c, Case_Assessment__c, Order__c, Answer_Type__c,CreatedBy.Name from Answer__c Where Case_Assessment__c =: caseAssessmetnId Order By Order__c];
    // }
 
}