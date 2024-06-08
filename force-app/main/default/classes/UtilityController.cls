public class UtilityController {

    @AuraEnabled
    public static string getAllPicklistValues(){
        Map<String,Object> returnMap=new Map<string,Object>();
        returnMap.put('Gender',picklistValues('Employee__c','Gender__c'));
        returnMap.put('BloodGroup',picklistValues('Employee__c','Blood_Group__c'));
        returnMap.put('Nationality',picklistValues('Employee__c','Nationality__c'));
        system.debug('returnMap: ' + returnMap);
        return JSON.serialize(returnMap);
    }



    public static Map<String, String> picklistValues(String objectName, String fieldName) {
        system.debug('objectName: ' + objectName);
        system.debug('fieldName: ' + fieldName);
        Map<String, String> values = new Map<String, String>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        system.debug('values: ' + values);
        return values;
    }
}