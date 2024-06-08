public class PicklistSearchFilterController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objectApiName,String fieldApiName) {
        List<Map<String, String>> values = new List<Map<String, String>>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectApiName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldApiName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    Map<String, String> valueMap = new Map<String, String>();
                    valueMap.put('label', entry.getLabel());
                    valueMap.put('value', entry.getValue());
                    values.add(valueMap);
                }
            }
        }
        return values;
    }

}