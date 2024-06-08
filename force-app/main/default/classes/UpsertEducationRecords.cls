public class UpsertEducationRecords {
    public static void upsertEducationRecords(String jsonData) {
       
        List<Employee_Education__c> educationRecordsToInsert = new List<Employee_Education__c>();
        List<Employee_Education__c> educationRecordsToUpdate = new List<Employee_Education__c>();
        
        // Parse JSON data
        List<Object> jsonDataList = (List<Object>) JSON.deserializeUntyped(jsonData);
        for (Object obj : jsonDataList) {
            Map<String, Object> record = (Map<String, Object>) obj;
            Employee_Education__c educationRecord = new Employee_Education__c();
            
            // Populate fields from JSON data
            if (record.containsKey('Id')) {
                String recordId = String.valueOf(record.get('Id'));
                if (recordId != null && recordId.length() == 18) {
                    // ID is not null and has 18 characters (valid Salesforce ID)
                    educationRecord.Id = recordId;
           // Populate all fields from JSON data
                    if (record.containsKey('University_Name__c')) {
                        educationRecord.University_Name__c = String.valueOf(record.get('University_Name__c'));
                    }
                    if (record.containsKey('Degree_Name__c')) {
                        educationRecord.Degree_Name__c = String.valueOf(record.get('Degree_Name__c'));
                    }
                    if (record.containsKey('Start_Date__c')) {
                        educationRecord.Start_Date__c = Date.valueOf(String.valueOf(record.get('Start_Date__c')));
                    }
                    if (record.containsKey('End_Date__c')) {
                        educationRecord.End_Date__c = Date.valueOf(String.valueOf(record.get('End_Date__c')));
                    }
                     educationRecordsToUpdate.add(educationRecord);
                }
            }
            
            if (educationRecord.Id == null) {
                // ID is null, create a new record
                if (record.containsKey('Degree_Name__c')) {
                    educationRecord.Degree_Name__c = String.valueOf(record.get('Degree_Name__c'));
                }
                if (record.containsKey('University_Name__c')) {
                    educationRecord.University_Name__c = String.valueOf(record.get('University_Name__c'));
                }
                if (record.containsKey('Start_Date__c')) {
                    educationRecord.Start_Date__c = Date.valueOf(String.valueOf(record.get('Start_Date__c')));
                }
                if (record.containsKey('End_Date__c')) {
                    educationRecord.End_Date__c = Date.valueOf(String.valueOf(record.get('End_Date__c')));
                }
                if (record.containsKey('Employee__c ')) { // Corrected the field name here
                    educationRecord.Employee__c = String.valueOf(record.get('Employee__c '));
                }
                educationRecordsToInsert.add(educationRecord);
            }
        }
            system.debug('educationRecordsToUpdate'+educationRecordsToUpdate);
            system.debug('educationRecordsToInsert'+educationRecordsToInsert);

        // Update records
        if (!educationRecordsToUpdate.isEmpty()) {
            update educationRecordsToUpdate;
        }
        
        // Insert records
        if (!educationRecordsToInsert.isEmpty()) {
            insert educationRecordsToInsert;
        }
    }
}