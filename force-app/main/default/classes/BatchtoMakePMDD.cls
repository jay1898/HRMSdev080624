global class BatchtoMakePMDD implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to fetch records from Project_Name__c where Daily_PMDD_On__c is true
        return Database.getQueryLocator([
            SELECT Id, Name, Daily_PMDD_On__c
            FROM Project_Name__c
            WHERE Daily_PMDD_On__c = true
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Project_Name__c> scope) {
        List<Project_Alloted_Hour__c> projectAllotedHoursToCreate = new List<Project_Alloted_Hour__c>();

        // Iterate through each Project_Name__c record in the batch
        for (Project_Name__c project : scope) {
            // Create a new Project_Alloted_Hour__c record
            Project_Alloted_Hour__c newProjectAllotedHour = new Project_Alloted_Hour__c(
              //  Name = 'YourDefaultValue', // Set your default value for Name
                Alloted_Hours__c = 0, // Set default values for other fields
                Date__c = Date.today(),
                No_of_Dev_QA_s__c=0,
                PM_Billable_Hours__c = 0,
                Project__c = project.Id // Set the Project__c field with the fetched Project's Id
           
                
            );

            // Add the newly created Project_Alloted_Hour__c record to the list
            projectAllotedHoursToCreate.add(newProjectAllotedHour);
        }

        // Insert the list of Project_Alloted_Hour__c records
        insert projectAllotedHoursToCreate;
    }

    global void finish(Database.BatchableContext BC) {
        // You can add finishing logic here if needed
    }
}