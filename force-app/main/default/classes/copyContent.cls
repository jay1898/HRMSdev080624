public with sharing class copyContent {
    // @AuraEnabled
    // public static String copyRecords(String recordId) {
    //     // Query the record to get the values of Name and Code
    //     Recruitment_Campaign__c record = [SELECT Title__c, Job_Description__c FROM Recruitment_Campaign__c WHERE Id = :recordId LIMIT 1];
    //     String plainText = stripHtmlTags(record.Job_Description__c);
    //     // Create the copy format
    //    String copyText = 'Name: ' + record.Title__c + '\nDiscription: ' + plainText;
        
    //     return copyText;
    // }
    // private static String stripHtmlTags(String input) {
    //     return input.replaceAll('<[^>]*>', '');
    // }
}