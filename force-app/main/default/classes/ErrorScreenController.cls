public without sharing class ErrorScreenController {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getMessageData(List<Id> recordsIdList) {
        Map<String, String> prefixAndObjectNameMap = new Map<String, String>();
        Map<String, List<String>> objAndRelatedRecIdMap = new Map<String, List<String>>();
        Map<String, List<String>> objAndErrorsMap = new Map<String, List<String>>();
        Boolean isPersonAccount = false;

        if(!recordsIdList.isEmpty() && String.valueOf(recordsIdList[0].getSObjectType()) == 'Case') {
            Case caseObj = [Select Id, AccountId, ContactId from Case where Id =: recordsIdList[0]];
            Id caseId = recordsIdList[0];
            recordsIdList.clear();
            if(caseObj.AccountId != null) recordsIdList.add(caseObj.AccountId);
            if(caseObj.ContactId != null) recordsIdList.add(caseObj.ContactId);
            recordsIdList.add(caseId);
        }

        if(!recordsIdList.isEmpty() && String.valueOf(recordsIdList[0].getSObjectType()) == 'Contact') {
            Contact conObj = [Select Id, AccountId from Contact where Id =: recordsIdList[0]];
            Id contactId = recordsIdList[0];
            recordsIdList.clear();
            if(conObj.AccountId != null) {
                recordsIdList.add(conObj.AccountId);
            }
            recordsIdList.add(contactId);
        }

        for(Id recId : recordsIdList) {
            String idPrefix = String.valueOf(recId).substring(0,3);
            if(!prefixAndObjectNameMap.containsKey(idPrefix)) {
                String objectName = String.valueOf(recId.getSObjectType());
                if(objectName == 'Account') {
                    Account accObj = [Select Id, IsPersonAccount from Account where Id =: recId];
                    isPersonAccount = accObj.IsPersonAccount ? true : false;
                }
                prefixAndObjectNameMap.put(idPrefix, objectName);
            }
            if(objAndRelatedRecIdMap.containsKey(idPrefix)) objAndRelatedRecIdMap.get(idPrefix).add(recId);
            else objAndRelatedRecIdMap.put(idPrefix, new List<String>{recId});
        }
        for(String prefix : prefixAndObjectNameMap.keySet()) {
            String fields = null;
            List<String> idList = objAndRelatedRecIdMap.get(prefix);
            try{
                fields = Object_Error_Fields_Mapping__mdt.getInstance(prefixAndObjectNameMap.get(prefix)).Error_Fields__c;
            } catch(NullPointerException e) {
                throw new CustomException('No Mapping found for Object : '+ prefixAndObjectNameMap.get(prefix));
            }            
            for(sObject obj : Database.query('SELECT Id, '+ fields +' FROM ' + prefixAndObjectNameMap.get(prefix) +' WHERE Id IN: idList')) {
                for(String field : fields.split(',')) {
                    if(obj.get(field) != null) {
                        String objName = prefixAndObjectNameMap.get(prefix);
                        if(isPersonAccount && prefixAndObjectNameMap.get(prefix) == 'Account'){
                            objName = 'Person_Account';
                        }
                        if(objAndErrorsMap.containsKey(objName)){
                            objAndErrorsMap.get(objName).add(String.valueOf(obj.get(field)));
                        } else {
                            objAndErrorsMap.put(objName, new List<String>{String.valueOf(obj.get(field))});
                        }
                    }                    
                }                
            }
        }
        System.debug(objAndErrorsMap);
        return objAndErrorsMap;
    }
}