public without sharing class PositionOpeningController {
    
   @AuraEnabled(cacheable=true)
   public static List<Recruitment_Campaign__c> getRecruitData(){
    return[select id, name,Skills__c, Job_Type__c,Title__c,Qualification__c ,Job_Description__c,Job_Exp__c,Job_Title__c,Req_Experience_Skills_qualification__c, Responsibilities_and_Duties__c from Recruitment_Campaign__c where Is_Active__c = true order by CreatedDate DESC ];
   }

   @AuraEnabled
    public static String copyRecords(String recordId) {
        // Query the record to get the values of Name and Code
        Recruitment_Campaign__c record = [SELECT Name,Title__c, Job_Description__c FROM Recruitment_Campaign__c WHERE Id = :recordId LIMIT 1];
        String plainText = stripHtmlTags(record.Job_Description__c);
        // Create the copy format
    //    String copyText = 'Name111: ' + record.Title__c + '\n Description: ' + plainText ;
       String copyText = 'Name: ' + record.Name + '\nDescription: ' + plainText ;
        
        return copyText;
    }
    private static String stripHtmlTags(String input) {
        return input.replaceAll('<[^>]*>', '');
    }
}