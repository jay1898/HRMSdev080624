public with sharing class FieldSetController {
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldNames(String contextObjectType, String fieldSetName) {
        List<String> fieldNames = new List<String>();
        System.debug('contextObjectType:::' + contextObjectType);
        System.debug('fieldSetName:::' + fieldSetName);

       // Get all SObject types
       Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

       // Check if the contextObjectType exists in the global describe map
       if (globalDescribe.containsKey(contextObjectType)) {
           // Get the SObject describe for the contextObjectType
           Schema.DescribeSObjectResult sobjDescribe = globalDescribe.get(contextObjectType).getDescribe();

           // Get the field set by its name
           Schema.FieldSet fieldSet = sobjDescribe.fieldSets.getMap().get(fieldSetName);
           
           if (fieldSet != null) {
               // Add field names from the field set to the list
               for (Schema.FieldSetMember field : fieldSet.getFields()) {
                   fieldNames.add(field.getFieldPath());
               }
           }
       } else {
           // Handle the case where contextObjectType is invalid
           System.debug('Invalid SObject type: ' + contextObjectType);
       }
        return fieldNames;
    }
}