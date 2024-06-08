/*
*   Created By      : Subhash Panchani
*   Added on        : 14 July 2023
*   Purpose         : Method of this class is used for fetching data from Case_Quick_Text__c object
*   User Story      : Pella SCS-104 & SCS-674 Quick Texts Requirements 
*/
public with sharing class quickTextController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getQuickTexts() {
        List<Map<String, Object>> quickTextList = new List<Map<String, Object>>();
        Set<String> queueList = new Set<String>();
        Set<String> corporateList = new Set<String>();
        Map<String, Object> topLevelMap = new Map<String, Object>();
        Boolean isCorporate = false;
        
        for(Group queue : [Select id,Name from Group Where Type = 'queue' AND Id IN (Select GroupId From GroupMember Where UserOrGroupId =: UserInfo.getUserId())]){
            queueList.add(queue.Name);
        }
        
        List<QuickText_Corporate_Queue_List__mdt> mcsList = [SELECT MasterLabel FROM QuickText_Corporate_Queue_List__mdt];
        
        for(QuickText_Corporate_Queue_List__mdt mcs : mcsList){
            corporateList.add(mcs.MasterLabel);
            if(queueList.contains(mcs.MasterLabel)){
                isCorporate = true;
            }
        }
        if(isCorporate){
            queueList.addAll(corporateList);
        }
        
        List<Case_Quick_Text__c> quickTexts = [SELECT Id, Message__c, Name, Quick_Search_Key__c, OwnerId, Owner.Name, Queue_Name__c, Folder_Hierarchy_Level_1__c, Folder_Hierarchy_Level_2__c,Active__c FROM Case_Quick_Text__c WHERE Queue_Name__c IN : queueList AND Active__c = TRUE ORDER BY Queue_Name__c ASC];
        
        Set<String> existingQueueNames = new Set<String>();
        for (Case_Quick_Text__c quickText : quickTexts) {
            existingQueueNames.add(quickText.Queue_Name__c);
        }
        
        List<Case_Quick_Text__c> resultQuickTexts = new List<Case_Quick_Text__c>(quickTexts);
        
        for (String queueName : queueList) {
            if (!existingQueueNames.contains(queueName)) {
                // Create a placeholder record with the Queue_Name__c value
                Case_Quick_Text__c placeholder = new Case_Quick_Text__c(
                    Queue_Name__c = queueName,
                    Message__c = 'No record available',
                    Active__c = false
                    // You can set other default values as needed
                );
                resultQuickTexts.add(placeholder);
            }
        }
        
        
        for (Case_Quick_Text__c quickText : resultQuickTexts) {
            String folderLevel1 = quickText.Queue_Name__c;
            String folderLevel2 = quickText.Folder_Hierarchy_Level_1__c;
            String folderLevel3 = quickText.Folder_Hierarchy_Level_2__c;
            
            if(quickText.Message__c != null){
                if (folderLevel1 != null) {
                    if (!topLevelMap.containsKey(folderLevel1)) {
                        topLevelMap.put(folderLevel1, new Map<String, Object>());
                    }
                    
                    Map<String, Object> level1Map = (Map<String, Object>)topLevelMap.get(folderLevel1);
                    
                    if (folderLevel2 != null) {
                        if (!level1Map.containsKey(folderLevel2)) {
                            level1Map.put(folderLevel2, new Map<String, Object>());
                        }
                        
                        Map<String, Object> level2Map = (Map<String, Object>)level1Map.get(folderLevel2);
                        
                        if (folderLevel3 != null) {
                            if (!level2Map.containsKey(folderLevel3)) {
                                level2Map.put(folderLevel3, new Map<String, Object>());
                                level2Map.put('QuickText', new List<Map<String, Object>>());
                            }
                            
                            Map<String, Object> level3Map = (Map<String, Object>)level2Map.get(folderLevel3);
                            if(!level3Map.containsKey('QuickText')){
                                level3Map.put('QuickText', new List<Map<String, Object>>());
                            }
                            
                            List<Map<String, Object>> quickTextData = (List<Map<String, Object>>)level3Map.get('QuickText');
                            Map<String, Object> quickTextEntry = new Map<String, Object>();
                            quickTextEntry.put('TitleNames', quickText.Name);
                            quickTextEntry.put('Message', quickText.Message__c);
                            quickTextEntry.put('Id',quickText.Id);
                            quickTextEntry.put('QuickSearchKey',quickText.Quick_Search_Key__c);
                            quickTextData.add(quickTextEntry);
                        } else {
                            if (!level2Map.containsKey('QuickText')) {
                                level2Map.put('QuickText', new List<Map<String, Object>>());
                            }
                            
                            List<Map<String, Object>> quickTextData = (List<Map<String, Object>>)level2Map.get('QuickText');
                            Map<String, Object> quickTextEntry = new Map<String, Object>();
                            quickTextEntry.put('TitleNames', quickText.Name);
                            quickTextEntry.put('Message', quickText.Message__c);
                            quickTextEntry.put('Id',quickText.Id);
                            quickTextEntry.put('QuickSearchKey',quickText.Quick_Search_Key__c);
                            quickTextData.add(quickTextEntry);
                        }
                    } else {
                        if (!level1Map.containsKey('QuickText')) {
                            level1Map.put('QuickText', new List<Map<String, Object>>());
                        }
                        
                        List<Map<String, Object>> quickTextData = (List<Map<String, Object>>)level1Map.get('QuickText');
                        Map<String, Object> quickTextEntry = new Map<String, Object>();
                        quickTextEntry.put('TitleNames', quickText.Name);
                        quickTextEntry.put('Message', quickText.Message__c);
                        quickTextEntry.put('Id',quickText.Id);
                        quickTextEntry.put('Active',quickText.Active__c);
                        quickTextEntry.put('QuickSearchKey',quickText.Quick_Search_Key__c);
                        quickTextData.add(quickTextEntry);
                    }
                }
            }
        }
      /*  List<String> sortedKeys = new List<String>(topLevelMap.keySet());
        sortedKeys.sort();
        
        Map<String, Object> sortedMap = new Map<String, Object>();
        for (String key : sortedKeys) {
            sortedMap.put(key, topLevelMap.get(key));
        }*/

        quickTextList.add(topLevelMap);
        return quickTextList;   
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getMetadataRecords(String ownerId){
        try {
            String ownerName;
            List<Group> groupList = [SELECT Id,DeveloperName FROM Group WHERE Type = 'Queue' AND Id =: ownerId LIMIT 1];
            
            if(groupList.size() > 0){
                ownerName = groupList[0].DeveloperName;
            }
            List<QuickText_Corporate_Queue_List__mdt> mcsList = [SELECT Queue_Name__c FROM QuickText_Corporate_Queue_List__mdt WHERE Queue_Name__c =: ownerName];
            
            if(mcsList.size() > 0){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}