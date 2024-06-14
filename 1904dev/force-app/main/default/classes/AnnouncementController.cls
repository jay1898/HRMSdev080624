public without sharing class AnnouncementController {
    

    @AuraEnabled
    public static void saveAnnouncement(String announcementContent,String empId) {
        Notification__c announcement = new Notification__c();
        announcement.Content__c = announcementContent;
        announcement.Type__c = 'Announcement';
        announcement.Announced_by__c = empId;
        upsert announcement;
    }

    @AuraEnabled(cacheable=true)
    public static List<Notification__c> getAllAnnouncements() {
        return [SELECT Id, Content__c,Type__c,Announced_by__c,Announced_by__r.Name FROM Notification__c where Type__c = 'Announcement'  ORDER BY CreatedDate DESC];
    }

    @AuraEnabled
    public static void updateAnnouncement( String currentEditingId ,String editedContent ) {    
            // upsert announcement;
            Notification__c announcement = new Notification__c();
            announcement.Id = currentEditingId;
            announcement.Content__c = editedContent;
            upsert announcement;
        
    }

    @AuraEnabled
    public static void deleteAnnouncement(String currentDeletingId) {   
        try{
            if(currentDeletingId!= null){
                Id recorId = (Id) currentDeletingId;
                List<Notification__c> recordList = [SELECT Id FROM Notification__c LIMIT 1 ];
                if(recordList.size()>0){
                    Delete recordList;
                }
            }
        }catch (Exception e) {
            throw new AuraHandledException('Error while deleting Post data: ' + e.getMessage());
        } 
    }

	@AuraEnabled
    public static List<Map<String, Object>> fetchNotificationData(String recordType){
        List<Map<String, Object>> notificationDataList = new List<Map<String, Object>>();
        List<Notification__c> notificationList = new List<Notification__c>();

        Map<Id, String> ProfilePhotoMap = fetchProfileImg();
        System.debug('ProfilePhotoMap>>'+JSON.serialize(ProfilePhotoMap));
        if(recordType != null){
            notificationList = [SELECT Id,CreatedDate, Active__c, Description__c, Employee__c, Expiration_Date__c, Type__c, Content__c, Announced_by__c, Announced_by__r.Name 
								FROM Notification__c 
                                WHERE Type__c = :recordType  AND 
                                (Expiration_Date__c  = Null OR Expiration_Date__c > TODAY ) 
                                ORDER BY CreatedDate DESC];
        }
        System.debug('notificationList>>'+notificationList);

        if(notificationList.size()>0){
           // return notificationList;
           for(Notification__c obj: notificationList){
               Map<String, Object> returnMap = new Map<String, Object>();
               returnMap.put('Id', obj.Id);
               returnMap.put('CreatedDate', obj.CreatedDate);
               returnMap.put('Announced_by__c', obj.Announced_by__c);
               returnMap.put('Expiration_Date__c', obj.Expiration_Date__c);
               returnMap.put('Type__c', obj.Type__c);
               returnMap.put('Content__c', obj.Content__c);
               returnMap.put('Announced_by_Name', obj.Announced_by__r.Name);
                if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(obj.Announced_by__c)){
                    System.debug('ProfilePhotoMap.get(obj.Announced_by__c)>>'+ProfilePhotoMap.get(obj.Announced_by__c));
                    returnMap.put('Profile_Photo', ProfilePhotoMap.get(obj.Announced_by__c));
                }
                else{
                    returnMap.put('Profile_Photo', null);
                }
                notificationDataList.add(returnMap);
           }
        }
        System.debug('notificationDataList>>'+JSON.serialize(notificationDataList));
        if(notificationDataList.size()>0){
            return notificationDataList;
        }
        return null;
    }

    @AuraEnabled
	public static void insertNotificationData(String jsonData){
        try {
                List<Notification__c> insertNotifiList = new List<Notification__c>();
                List<Object> jsonDataList = (List<Object>) JSON.deserializeUntyped(jsonData);
                
                for (Object obj : jsonDataList) {
                    
                    Map<String, Object> record = (Map<String, Object>) obj;
                    Notification__c notiObj = new Notification__c();
                    system.debug('record>>'+record);    
                    if (record.containsKey('Position__c')) {
                        notiObj.Content__c = String.valueOf(record.get('Content__c'));
                    }
                    if (record.containsKey('Expiration_Date__c')) {
                        notiObj.Type__c = String.valueOf(record.get('Type__c'));
                    }
                    if (record.containsKey('Announced_by__c')) {
                        notiObj.Announced_by__c = (Id) record.get('Announced_by__c');
                        //notiObj.Employee__c = record.get('Announced_by__c');
                    }
                    if (record.containsKey('Expiration_Date__c')) {
                        notiObj.Expiration_Date__c = Date.valueOf(String.valueOf(record.get('Expiration_Date__c')));
                    }
                    //notiObj.Active__c = TRUE;

                    insertNotifiList.add(notiObj);
                }
                if(insertNotifiList.size()>0)
                {
                    Insert insertNotifiList;
                }
            
            } catch (Exception e) {
                throw new AuraHandledException('Error Insert Post data: ' + e.getMessage());
            }

    }

    @AuraEnabled
	public static void updateNotificationData(String jsonData){
        try {
                List<Notification__c> updateNotifiList = new List<Notification__c>();
                List<Object> jsonDataList = (List<Object>) JSON.deserializeUntyped(jsonData);
                
                for (Object obj : jsonDataList) {
                    
                    Map<String, Object> record = (Map<String, Object>) obj;
                    Notification__c notiObj = new Notification__c();
                    system.debug('record>>'+record);    
                    notiObj.Id = (Id) record.get('Id');
                    if (record.containsKey('Position__c')) {
                        notiObj.Content__c = String.valueOf(record.get('Content__c'));
                    }
                    if (record.containsKey('Expiration_Date__c')) {
                        notiObj.Type__c = String.valueOf(record.get('Type__c'));
                    }
                    if (record.containsKey('Announced_by__c')) {
                        notiObj.Announced_by__c = (Id) record.get('Announced_by__c');
                        //notiObj.Employee__c = record.get('Announced_by__c');
                    }
                    if (record.containsKey('Expiration_Date__c')) {
                        notiObj.Expiration_Date__c = Date.valueOf(String.valueOf(record.get('Expiration_Date__c')));
                    }
                    //notiObj.Active__c = TRUE;

                    updateNotifiList.add(notiObj);
                }
                if(updateNotifiList.size()>0)
                {
                    Update updateNotifiList;
                }
            
            } catch (Exception e) {
                throw new AuraHandledException('Error Insert Post data: ' + e.getMessage());
            }

    }

    @AuraEnabled
    public static String fetchImage(String fileName, String EmployeeId) {
        String base64Data = '';
        System.debug('fileName>>'+fileName);
        System.debug('EmployeeId>>'+EmployeeId);
        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId 
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :EmployeeId 
                                                   AND ContentDocument.Title = :fileName 
                                                   ORDER BY ContentDocument.CreatedDate DESC 
                                                   LIMIT 1];

        System.debug('documentLinks[0].ContentDocumentId>>'+documentLinks[0].ContentDocumentId);
        if (documentLinks.size()>0) {
            // Query ContentVersion using the ContentDocumentId from ContentDocumentLink
            List<ContentVersion> versionList = [SELECT Id,VersionData 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId = :documentLinks[0].ContentDocumentId 
                                             ORDER BY CreatedDate DESC 
                                             LIMIT 1];

            System.debug('versionList[0].VersionData>>'+versionList[0].VersionData);
            if (!versionList.isEmpty()) {
                base64Data = EncodingUtil.base64Encode(versionList[0].VersionData);
            }
        }
        System.debug('base64Data>>'+base64Data);
        return base64Data;
    }

    @AuraEnabled
    public static Map<Id, String> fetchProfileImg() {
       
        Set<Id> empIdSet = new Set<Id>();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        List<ContentVersion> versionList = new List<ContentVersion>();
        Map<Id, ContentDocumentLink> empIdToLatestLinkMap = new Map<Id, ContentDocumentLink>();
        Map<Id, String> empIdProfilePhotoDataMap = new Map<Id, String>();
        Map<Id,Id> contentDocumentIdToEmpMap = new Map<Id,Id>();

        for(Employee__c emp : [SELECT Id FROM Employee__c]) {
            empIdSet.add(emp.Id);
        }
        if(!empIdSet.isEmpty()){
            documentLinks = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, LinkedEntityId,ContentDocument.LatestPublishedVersionId
                                FROM ContentDocumentLink
                                WHERE LinkedEntityId IN :empIdSet
                                AND ContentDocument.Title = 'Employee Profile Photo'
                                ORDER BY LinkedEntityId, ContentDocument.CreatedDate DESC
                            ];
            // Iterate through query results to populate the temporary map with the most recent ContentDocumentLink per Employee__c Id
            for(ContentDocumentLink link : documentLinks) {
                if(!empIdToLatestLinkMap.containsKey(link.LinkedEntityId)) {
                    empIdToLatestLinkMap.put(link.LinkedEntityId, link);
                    contentDocumentIdToEmpMap.put(link.ContentDocumentId, link.LinkedEntityId);
                }
            }
            // Fetch the ContentDocuments associated with the most recent ContentDocumentLinks and populate the final map
            Set<Id> contentVersionIds = new Set<Id>();
            for(ContentDocumentLink link : empIdToLatestLinkMap.values()) {
                contentVersionIds.add(link.ContentDocument.LatestPublishedVersionId);
            }
            
            if(!contentVersionIds.isEmpty()) {
                versionList = [SELECT Id,VersionData,ContentDocumentId 
                                             FROM ContentVersion 
                                             WHERE Id IN :contentVersionIds];
                
                if(versionList.size()>0){
                    System.debug('FOR - versionList>>'+versionList);
                    for(ContentVersion version : versionList) {
                        String base64Data = EncodingUtil.base64Encode(version.VersionData);
                        empIdProfilePhotoDataMap.put(contentDocumentIdToEmpMap.get(version.ContentDocumentId), 'data:image/jpeg;base64,'+base64Data);
                    }
                }
            }
           
        }
        System.debug('empIdProfilePhotoDataMap>>'+empIdProfilePhotoDataMap);
        return empIdProfilePhotoDataMap;
    }
    
    //For Fetching Employees Birthdays
    @AuraEnabled(cacheable=true)
    public static BirthdayData getEmployeesBirthdays() {
        DateTime dt = DateTime.now();
        List<Employee__c> employees = [SELECT Id, Name, Date_of_Birth__c 
                                       FROM Employee__c
                                       WHERE CALENDAR_MONTH(Date_of_Birth__c) =:dt.month()];
        system.debug('dt.month()-->'+employees);
        
        if (employees.isEmpty()) {
            return null;
        }
        // For next 7 days Birthdays
        List<Employee__c> nextSevenDays = new List<Employee__c>();
        for (Employee__c emp : employees) {
            DateTime empDay = emp.Date_of_Birth__c;
            if(empDay.day() > dt.day() && empDay.day() <= dt.addDays(7).day()){
                nextSevenDays.add(emp);   
            }
        }
        System.debug('nextSevenDays---------->'+nextSevenDays);
        //For Today Birthday 
        List<Employee__c> todaydate = new List<Employee__c>();
        for (Employee__c emp : employees) {
            DateTime empDay = emp.Date_of_Birth__c;
            if(empDay.day() == dt.day()){
                todaydate.add(emp);  
            }
        }
        System.debug('todaydate---------->'+todaydate);
        return new BirthdayData(todaydate, nextSevenDays);
    }
    
    public class BirthdayData {
    @AuraEnabled public List<Employee__c> todayBirthdays;
    @AuraEnabled public List<Employee__c> nextSevenDaysBirthdays;
    
    public BirthdayData(List<Employee__c> todayBirthdays, List<Employee__c> nextSevenDaysBirthdays) {
        this.todayBirthdays = todayBirthdays;
        this.nextSevenDaysBirthdays = nextSevenDaysBirthdays;
    }
}
    
    //For Fetching Employees Work Anniversary
    @AuraEnabled(cacheable=true)
    public static void getEmployeesWorkAnniversary() {
        DateTime dt = DateTime.now();
        List<Employee__c> employees = [SELECT Id, Name, Date_Of_Joining__c 
                                       FROM Employee__c
                                       WHERE CALENDAR_MONTH(Date_Of_Joining__c) =:dt.month()];
        system.debug('dt.month()-->'+employees);
        
        if(employees.size() > 0){
            //return null;
        }
        // For next 7 days Work Anniversary
        List<Employee__c> nextSevenDays = new List<Employee__c>();
        for (Employee__c emp : employees) {
            DateTime empDay = emp.Date_Of_Joining__c;
            if(empDay.day() > dt.day() && empDay.day() <= dt.addDays(7).day()){
                nextSevenDays.add(emp);
                
            }
        }
        System.debug('nextSevenDaysWorkAnniversary---------->'+nextSevenDays);
        system.debug('size'+nextSevenDays.size());
        //For Today Work Anniversary 
        List<Employee__c> todaydate = new List<Employee__c>();
        for (Employee__c emp : employees) {
            DateTime empDay = emp.Date_Of_Joining__c;
            if(empDay.day() == dt.day()){
                todaydate.add(emp);
            }
        }
        System.debug('todaydateWorkAnniversary---------->'+todaydate);
    }  
}