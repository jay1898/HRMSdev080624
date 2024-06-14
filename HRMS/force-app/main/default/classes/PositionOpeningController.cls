public without sharing class PositionOpeningController {
    
   @AuraEnabled(cacheable=true)
   public static List<Recruitment_Campaign__c> getRecruitData(){
    return[select id, name,Skills__c, Job_Type__c,Title__c, Qualification__c ,Salary__c,Job_Description__c, Job_Experience__c, Job_Exp__c,Req_Experience_Skills_qualification__c, Responsibilities_and_Duties__c from Recruitment_Campaign__c where Is_Active__c = true];
   }
}