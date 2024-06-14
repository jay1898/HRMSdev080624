/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AnnouncementController {

    
    @AuraEnabled
    public static void deleteNotification(String currentDeletingId) {   
        try{
            System.debug('currentDeletingId>>'+currentDeletingId);
            if(currentDeletingId!= null){
                Id recordId = (Id) currentDeletingId;
                System.debug('recordId>>'+recordId);
                List<Notification__c> recordList = [SELECT Id FROM Notification__c WHERE Id =: recordId LIMIT 1 ];
                System.debug('recordList>>'+recordList);
                if(recordList.size()>0){
                    Delete recordList;
                }
            }
        }catch (Exception e) {
            throw new AuraHandledException('Error while deleting Post data: ' + e.getMessage());
        } 
    }
    
    
    @AuraEnabled
    public static List<Map<String, Object>> fetchNotificationData(String recordType, Integer limits){
        List<Map<String, Object>> notificationDataList = new List<Map<String, Object>>();
        List<Notification__c> notificationList = new List<Notification__c>();
    
        Map<Id, String> ProfilePhotoMap = fetchProfileImg();
        Map<Id, List<contentVersionWrapper>> PostPhotoMap = fetchPostImg();
        System.debug('ProfilePhotoMap>>'+JSON.serialize(ProfilePhotoMap));
        if(recordType != null){
            notificationList = [SELECT Id,CreatedDate, Active__c, Description__c, Employee__c, Expiration_Date__c, Type__c, Content__c, Announced_by__c, Announced_by__r.Name 
                                FROM Notification__c 
                                WHERE Type__c = :recordType  AND 
                                (Expiration_Date__c  = Null OR Expiration_Date__c > TODAY ) 
                                ORDER BY CreatedDate DESC LIMIT :limits];
        }
        System.debug('notificationList>>'+notificationList);
    
        if(notificationList.size()>0){
            
            for(Notification__c obj: notificationList){
                Map<String, Object> returnMap = new Map<String, Object>();
                String createdDate = obj.CreatedDate.format('dd-MM-yyyy');
                returnMap.put('Id', obj.Id);
                returnMap.put('CreatedDate', createdDate);
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
                if(!PostPhotoMap.isEmpty() && PostPhotoMap.containsKey(obj.Id)){
                    System.debug('PostPhotoMap.get(obj.Id)>>'+PostPhotoMap.get(obj.Id));
                    returnMap.put('Post_Pics', PostPhotoMap.get(obj.Id));
                }
                else{
                    returnMap.put('Post_Pics', null);
                }
               
                notificationDataList.add(returnMap);
            }
        }
        if(notificationDataList.size()>0){
           return notificationDataList;
        }
        return null;
    }
    
    @AuraEnabled
    public static void insertNotificationData(String content, String expirationDate, String annonceById, String notiType, String filedata){
        try {
            Notification__c notiObj = new Notification__c();
        	notiObj.Content__c = content;
            notiObj.Type__c = notiType;
        	notiObj.Announced_by__c = annonceById;
            if (expirationDate != null && expirationDate != '') {
                notiObj.Expiration_Date__c = Date.valueOf(expirationDate);
            } else {
                notiObj.Expiration_Date__c = null;
            }
        	insert notiObj;
            
        	if(notiType == 'Post' && String.isNotBlank(filedata) && notiObj.Id != null){
				//savePostFiles(filedata, notiObj.Id);
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        		Integer counter = 0;
                
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
            	System.debug(files);
                
                for (FileDataWP file : files) {
                    Blob fileBlob = EncodingUtil.base64Decode(file.fileContent);
                    if (fileBlob != null) {
                        counter = counter+1;
                        ContentVersion contentVersion = new ContentVersion();
                        contentVersion.Title = 'Post-'+counter;
                        contentVersion.VersionData = fileBlob;
                        contentVersion.PathOnClient = 'Post-'+counter;
                        contentVersion.FirstPublishLocationId = notiObj.Id;
                        contentVersion.File_Category__c = 'Post';
                        contentVersion.OwnerId = UserInfo.getUserId();
                        contentVersions.add(contentVersion);
                    }
                }
        
                if (!contentVersions.isEmpty()) {
                    // Insert all ContentVersions
                    insert contentVersions;
                    
                    // Create ContentDocumentLinks to share files with all users as Viewer
                    for (ContentVersion cv : contentVersions) {
                        if (cv.Id != null && cv.ContentDocumentId != null) {
                            ContentDocumentLink documentLink = new ContentDocumentLink();
                            documentLink.ContentDocumentId = cv.ContentDocumentId;
                            documentLink.LinkedEntityId = notiObj.Id;
                            documentLink.Visibility = 'AllUsers';
                            documentLink.ShareType = 'V';
                            documentLinks.add(documentLink);
                        }
                    }
        
                    if (!documentLinks.isEmpty()) {
                        // Insert all ContentDocumentLinks
                        insert documentLinks;
                    }
                }
            }
        
        } catch (Exception e) {
            throw new AuraHandledException('Error Insert Post data: ' + e.getMessage());
        }

	}
    
	
    public static void savePostFiles(String filedata, Id recordId){
        System.debug('filedata>>'+ filedata);
		System.debug('recordId>>'+ recordId);
    	List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        Integer counter = 0;
        
        List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
        System.debug(files);
        
        for (FileDataWP file : files) {
            Blob fileBlob = EncodingUtil.base64Decode(file.fileContent);
            if (fileBlob != null) {
                counter = counter+1;
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'Post-'+counter;
                contentVersion.VersionData = fileBlob;
                contentVersion.PathOnClient = 'Post-'+counter;
                //contentVersion.FirstPublishLocationId = recordId;
                contentVersion.File_Category__c = 'Post';
                contentVersions.add(contentVersion);
            }
        }
        
        if (!contentVersions.isEmpty()) {
            // Insert all ContentVersions
            insert contentVersions;
            
            
            
            // Create ContentDocumentLinks to share files with all users as Viewer
            for (ContentVersion cv : contentVersions) {
                if (cv.Id != null && cv.ContentDocumentId != null) {
                    ContentDocumentLink documentLink = new ContentDocumentLink();
                    documentLink.ContentDocumentId = cv.ContentDocumentId;
                    documentLink.LinkedEntityId = recordId;
                    documentLink.Visibility = 'AllUsers';
                    documentLink.ShareType = 'V';
                    documentLinks.add(documentLink);
                }
            }
            
            if (!documentLinks.isEmpty()) {
                // Insert all ContentDocumentLinks
                insert documentLinks;
            }
        }    
    }

    public class FileDataWP {
        public String fileContent;
    }
    
    

    @AuraEnabled
    public static void updateNotificationData(List<Map<String, String>> notificationData, String notiType, String filedata) {
        boolean hasUpadated = false;
        Id notificationId;
        List<Notification__c> recordsToUpdate = new List<Notification__c>();
        System.debug('notificationData>>'+ notificationData);
        try {
            // Collect all Notification IDs from the input data
            Set<Id> notificationIds = new Set<Id>();
            for (Map<String, String> objMap : notificationData) {
                if (objMap.containsKey('Id')) {
                    notificationIds.add((Id)objMap.get('Id'));
                }
            }
            System.debug('notificationIds>>'+ notificationIds);
            // Query all relevant Notification records in one go
            Map<Id, Notification__c> recordsById = new Map<Id, Notification__c>([
                SELECT Id, Content__c
                FROM Notification__c
                WHERE Id IN :notificationIds
            ]);
            System.debug('recordsById>>'+ recordsById);
            // Update records with new data
            for (Map<String, String> objMap : notificationData) {
                if (objMap.containsKey('Id')) {
                    notificationId = (Id)objMap.get('Id');
                    if (recordsById.containsKey(notificationId)) {
                        Notification__c recordToUpdate = recordsById.get(notificationId);
                         
                        if(objMap.containsKey('content__c')){
                            recordToUpdate.Content__c = objMap.get('content__c');
                            recordsToUpdate.add(recordToUpdate);    
                        }
                        
                    }
                }
            }
            System.debug('recordsToUpdate>>'+ recordsToUpdate);
            System.debug('hasUpadated>>'+ hasUpadated);
            // Perform update if there are records to update
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
            System.debug('Notifications updated successfully.');
            System.debug('filedata>>'+ filedata);
            System.debug('notificationId>>'+ notificationId);
            if(notiType == 'Post' && String.isNotBlank(filedata) && notificationId != null){
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        		Integer counter = 0;
                
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
            	System.debug(files);
                
                for (FileDataWP file : files) {
                    Blob fileBlob = EncodingUtil.base64Decode(file.fileContent);
                    if (fileBlob != null) {
                        counter = counter+1;
                        ContentVersion contentVersion = new ContentVersion();
                        contentVersion.Title = 'EdiPost-'+counter;
                        contentVersion.VersionData = fileBlob;
                        contentVersion.PathOnClient = 'EdiPost-'+counter;
                        contentVersion.FirstPublishLocationId = notificationId;
                        contentVersion.File_Category__c = 'Post';
                        contentVersions.add(contentVersion);
                    }
                }
        
                if (!contentVersions.isEmpty()) {
                    // Insert all ContentVersions
                    insert contentVersions;
                    
                    // Create ContentDocumentLinks to share files with all users as Viewer
                    for (ContentVersion cv : contentVersions) {
                        if (cv.Id != null && cv.ContentDocumentId != null) {
                            ContentDocumentLink documentLink = new ContentDocumentLink();
                            documentLink.ContentDocumentId = cv.ContentDocumentId;
                            documentLink.LinkedEntityId = notificationId;
                            documentLink.Visibility = 'AllUsers';
                            documentLink.ShareType = 'V';
                            documentLinks.add(documentLink);
                        }
                    }
        
                    if (!documentLinks.isEmpty()) {
                        // Insert all ContentDocumentLinks
                        insert documentLinks;
                    }
                }
            }
        } catch (Exception e) {
            // Handle any exceptions during update
            System.debug('Error occurred while updating notifications: ' + e.getMessage());
            throw new AuraHandledException('Error updating notifications: ' + e.getMessage());
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
    @AuraEnabled
    public static Map<Id, List<contentVersionWrapper>> fetchPostImg() {
        
        Map<Id, List<contentVersionWrapper>> postIdListPhotoMap = new Map<Id, List<contentVersionWrapper>>();
        //Map<Id, List<Map<Id,String>>> postIdListPhotoListMap = new Map<Id, List<Map<Id,String>>>();
        Set<Id> notificationIdSet = new Set<Id>();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        List<ContentVersion> versionList = new List<ContentVersion>();
        Map<Id, ContentDocumentLink> postIdToDocLinkMap = new Map<Id, ContentDocumentLink>();   
        Map<Id,Id> contentDocumentIdToPostMap = new Map<Id,Id>();
        Map<Id,Id> contentDocumentIdToLinkMap = new Map<Id,Id>();
        Map<Id, String> empIdProfilePhotoDataMap = new Map<Id, String>();
        Set<Id> contentVersionIds = new Set<Id>();
        
        for(Notification__c notif : [SELECT Id FROM Notification__c WHERE Type__c = 'Post']) {
            notificationIdSet.add(notif.Id);
        }
        if(!notificationIdSet.isEmpty()){
            documentLinks = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, LinkedEntityId,ContentDocument.LatestPublishedVersionId
                                FROM ContentDocumentLink
                                WHERE LinkedEntityId IN :notificationIdSet
                                //AND ContentDocument.Title = 'Employee Profile Photo'
                                ORDER BY ContentDocument.CreatedDate
                            ];
            // Iterate through query results to populate the temporary map with the most recent ContentDocumentLink per Notification__c Id
            for(ContentDocumentLink link : documentLinks) {
                //if(!postIdToDocLinkMap.containsKey(link.LinkedEntityId)) {
                    postIdToDocLinkMap.put(link.LinkedEntityId, link);
                    contentVersionIds.add(link.ContentDocument.LatestPublishedVersionId);
                    contentDocumentIdToPostMap.put(link.ContentDocumentId, link.LinkedEntityId);
                    contentDocumentIdToLinkMap.put(link.ContentDocumentId, link.Id);
                //}
            }
            System.debug('contentVersionIds.size<>>>'+contentVersionIds.size());
            System.debug('contentVersionIds>>'+contentVersionIds);
            if(!contentVersionIds.isEmpty()) {
                versionList = [SELECT Id,VersionData,ContentDocumentId 
                                            FROM ContentVersion 
                                            WHERE Id IN :contentVersionIds
                                            AND File_Category__c = 'Post'];
                System.debug('versionList>>'+versionList.size());
                if(versionList.size()>0){
                    System.debug('FOR - versionList>>'+versionList);
                    List<contentVersionWrapper> objcvWrapperLIst = new List<contentVersionWrapper>();
                    for(ContentVersion version : versionList) {
    
                        if(contentDocumentIdToPostMap.containsKey(version.ContentDocumentId)){
                            String base64Data = EncodingUtil.base64Encode(version.VersionData);
                            Id postId = contentDocumentIdToPostMap.get(version.ContentDocumentId);
                            String imageData = 'data:image/jpeg;base64,'+base64Data;
                            Id cdLink = contentDocumentIdToLinkMap.get(version.ContentDocumentId);
    
                            if(!postIdListPhotoMap.containsKey(postId)){
                                    postIdListPhotoMap.put(postId, new List<contentVersionWrapper>());
                                    //postIdListPhotoListMap.put(postId, new List<Map<Id,String>>());
                            }
                            objcvWrapperLIst.clear();
                            contentVersionWrapper objcvWrapper = new contentVersionWrapper();
                            objcvWrapper.contentzversionId = version.Id;
                            objcvWrapper.contentzversionData = imageData;
                            System.debug('objcvWrapper>>'+objcvWrapper);
                            objcvWrapperLIst.add(objcvWrapper);
                            postIdListPhotoMap.get(postId).addAll(objcvWrapperLIst);
                            
                            //postIdListPhotoListMap.get(postId).put(cdLink,imageData);
                        }
                    }
                }
            }
            
        }
        System.debug('postIdListPhotoMap>>'+ JSON.serialize(empIdProfilePhotoDataMap));
        return postIdListPhotoMap;
    }

    //For Fetching Employees Birthdays--------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static BirthdayData getEmployeesBirthdays() {
        Map<Id, String> ProfilePhotoMap = fetchProfileImg();
        
        List<Map<String, Object>> todayList = new List<Map<String, Object>>();
        List<Map<String, Object>> nextSevenDayList = new List<Map<String, Object>>();
        List<Employee__c> employeeList = new List<Employee__c>();
        DateTime dt = DateTime.now();
        DateTime nextdt = dt.addDays(7);
		System.debug('dt.day()' +dt.day());
        System.debug('nextdt.addDays(7).day()' +nextdt.addDays(7).day());
        if (dt.day() <= nextdt.addDays(7).day()) {
            System.debug('this month');
                    employeeList = [SELECT Id, Name, Date_of_Birth__c 
                                    FROM Employee__c
                                    WHERE CALENDAR_MONTH(Date_of_Birth__c) =:dt.month() AND DAY_IN_MONTH(Date_of_Birth__c) > :dt.day() ORDER BY Date_of_Birth__c];
                                    system.debug('employeeList this month -->'+employeeList);
        }
        else{
            System.debug('next month');
            employeeList = [SELECT Id, Name, Date_of_Birth__c 
                            FROM Employee__c
                            WHERE (DAY_IN_MONTH(Date_of_Birth__c) >= :dt.day() AND CALENDAR_MONTH(Date_of_Birth__c) =:dt.month()) OR CALENDAR_MONTH(Date_of_Birth__c) =:nextdt.month() ORDER BY Date_of_Birth__c];
        					system.debug('employeeList next month-->'+employeeList);
        }
        
        if (employeeList.size() > 0) {
            
            for (Employee__c emp : employeeList) {
                DateTime empDay = emp.Date_of_Birth__c;
                //For 7 days Birthday
                if(
                    (
                        empDay.day() > nextdt.day() && 
                        empDay.month() < nextdt.month() &&
                        empDay.day() != dt.day()
                    ) 
                    ||
                    (
                        empDay.day() <= nextdt.day() &&
                        empDay.month() == nextdt.month() &&
                        empDay.day() != dt.day()
                    )
                ){
                    Map<String, object> sevenBirthdayMap = new Map<String, object>();
                    sevenBirthdayMap.put('Id', emp.Id);
                    sevenBirthdayMap.put('Name', emp.Name);
                    sevenBirthdayMap.put('Date_of_Birth__c', emp.Date_of_Birth__c);
                    if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        sevenBirthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    }
                    else{
                        sevenBirthdayMap.put('Profile_Photo', null);
                    }
                    nextSevenDayList.add(sevenBirthdayMap);
                }
                //For Today Birthday
                if(empDay.day() == dt.day() && empDay.month() == dt.month()){
                    System.debug('empDay--->'+empDay);
                    Map<String, object> birthdayMap = new Map<String, object>();
                    birthdayMap.put('Id', emp.Id);
                    birthdayMap.put('Name', emp.Name);
                    birthdayMap.put('Date_of_Birth__c', emp.Date_of_Birth__c);
                    if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        birthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    }
                    else{
                        birthdayMap.put('Profile_Photo', null);
                    }
                    todayList.add(birthdayMap);
                }
            }
            System.debug('nextSevenDayListaaaa---------->'+nextSevenDayList);
            System.debug('todayListaaaaaa---------->'+todayList);
        }  
        return new BirthdayData(todayList, nextSevenDayList);
    }
    // Wrapper class for Birthdays
    public class BirthdayData {
        @AuraEnabled public List<Map<String, Object>> todayBirthdays;
        @AuraEnabled public List<Map<String, Object>> nextSevenDaysBirthdays;
        
        public BirthdayData(List<Map<String, Object>> todayBirthdays, List<Map<String, Object>> nextSevenDaysBirthdays) {
            this.todayBirthdays = todayBirthdays;
            this.nextSevenDaysBirthdays = nextSevenDaysBirthdays;
        }
    }
    
    //For Fetching Employees Work Anniversary---------------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static AnniversaryData getEmployeesWorkAnniversary() {
        Map<Id, String> ProfilePhotoMap = fetchProfileImg();
        List<Map<String, Object>> todayList = new List<Map<String, Object>>();
        List<Map<String, Object>> nextSevenDayList = new List<Map<String, Object>>();
    
        List<Employee__c> employeeList = new List<Employee__c>();
        DateTime dt = DateTime.now();
        DateTime nextdt = dt.addDays(7);
    
        if (dt.day() <= nextdt.addDays(7).day()) {
            System.debug('This month');
            employeeList = [
                SELECT Id, Name, Date_Of_Joining__c 
                FROM Employee__c
                WHERE CALENDAR_MONTH(Date_Of_Joining__c) = :dt.month() 
                AND DAY_IN_MONTH(Date_Of_Joining__c) > :dt.day() 
                ORDER BY Date_Of_Joining__c
            ];
            system.debug('employeeList This month-->'+employeeList);
        } else {
            System.debug('Next month');
            employeeList = [
                SELECT Id, Name, Date_Of_Joining__c 
                FROM Employee__c
                WHERE (DAY_IN_MONTH(Date_Of_Joining__c) >= :dt.day() 
                AND CALENDAR_MONTH(Date_Of_Joining__c) = :dt.month()) 
                OR CALENDAR_MONTH(Date_Of_Joining__c) = :nextdt.month() 
                ORDER BY Date_Of_Joining__c
            ];
            system.debug('employeeList Next month-->'+employeeList);
        }
        
        if (employeeList.size() > 0) {
            for (Employee__c emp : employeeList) {
                Date empDay = emp.Date_Of_Joining__c;
                // Calculate years of experience
                Integer yearsOfExperience = dt.year() - empDay.year();
                if (dt.month() < empDay.month() || (dt.month() == empDay.month() && dt.day() < empDay.day())) {
                    yearsOfExperience--;
                }
                // For next 7 days Work Anniversary
                if (
                    (
                        empDay.day() > nextdt.day() && 
                        empDay.month() < nextdt.month() &&
                        empDay.day() != dt.day()
                    ) 
                    ||
                    (
                        empDay.day() <= nextdt.day() &&
                        empDay.month() == nextdt.month() &&
                        empDay.day() != dt.day()
                    )
                ){
                    Map<String, object> sevenAnniversaryMap = new Map<String, object>();
                    sevenAnniversaryMap.put('Id', emp.Id);
                    sevenAnniversaryMap.put('Name', emp.Name);
                    sevenAnniversaryMap.put('Years_of_Experience', yearsOfExperience);
                    sevenAnniversaryMap.put('Date_Of_Joining__c',emp.Date_Of_Joining__c);
                    if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        sevenAnniversaryMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    } else {
                        sevenAnniversaryMap.put('Profile_Photo', null);
                    }
                    nextSevenDayList.add(sevenAnniversaryMap);
                }
                //For Today Work Anniversary 
                if(empDay.day() == dt.day() && empDay.month() == dt.month() && empDay.year() != dt.year()){
                    Map<String, object> anniversaryMap = new Map<String, object>();
                    anniversaryMap.put('Id', emp.Id);
                    anniversaryMap.put('Name', emp.Name);
                    anniversaryMap.put('Years_of_Experience', yearsOfExperience);
                    anniversaryMap.put('Date_Of_Joining__c',emp.Date_Of_Joining__c);                    
                    if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        anniversaryMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    } else {
                        anniversaryMap.put('Profile_Photo', null);
                    }
                    todayList.add(anniversaryMap);
                }
            }    
            System.debug('nextSevenDayListaaaa---------->'+nextSevenDayList);
            System.debug('todayListaaaaaa---------->'+todayList);
        }
        return new AnniversaryData(todayList, nextSevenDayList);
    }
    public class AnniversaryData {
        @AuraEnabled public List<Map<String, Object>> todaydateAnniversary;
        @AuraEnabled public List<Map<String, Object>> nextSevenDaysAnniversary;
        
        public AnniversaryData(List<Map<String, Object>> todaydateAnniversary, List<Map<String, Object>> nextSevenDaysAnniversary) {
            this.todaydateAnniversary = todaydateAnniversary;
            this.nextSevenDaysAnniversary = nextSevenDaysAnniversary;
        }
    }
    
    
    public class contentVersionWrapper{
        
        @AuraEnabled public String contentzversionId {get; set;}
        @AuraEnabled public String contentzversionData {get; set;}
    }
    
    @AuraEnabled
    public static void deletePostImage(String contentVersionId, String postId){
        System.debug('contentVersionId>>'+contentVersionId);
		Set<Id> contentDocumentIds = new Set<Id>();
        try{
            System.debug('contentVersionId>>'+contentVersionId);
            System.debug('User>>'+UserInfo.getUserId());
            System.debug('contentVersionId>>'+contentVersionId);
            if(contentVersionId!= null){
                Id recordId = (Id) contentVersionId;
                Id notificationId = (Id) postId;
                System.debug('recordId>>'+recordId);
                List<ContentDocumentLink> recordToDelete = [SELECT Id,ContentDocument.LatestPublishedVersionId, ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE ContentDocument.LatestPublishedVersionId =: recordId AND LinkedEntityId = :notificationId LIMIT 1];
                System.debug(' '+recordToDelete);
				if (recordToDelete.size()>0) {
                    for(ContentDocumentLink cdl:recordToDelete){
                        contentDocumentIds.add(cdl.ContentDocumentId);
                    }
                    delete recordToDelete;
                    System.debug('contentDocumentIds>>'+contentDocumentIds);
                    if(!contentDocumentIds.isEmpty()){
                        List<ContentDocument> contentDocuments = [SELECT Id, OwnerId FROM ContentDocument WHERE Id IN :contentDocumentIds];
                        System.debug('contentDocuments>>'+contentDocuments);
                        if(contentDocuments.size()>0){
                            delete contentDocuments;
                        }
                    }
                } 
            }
        }catch (Exception e) {
            throw new AuraHandledException('Error while deleting Post Images: ' + e.getMessage());
        } 
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getContentVersionData(Id contentVersionId) {
        if(contentVersionId!= null){
        	ContentVersion cvData = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1]; 
        	
			String base64Data = 'data:image/jpeg;base64,'+EncodingUtil.base64Encode(cvData.VersionData);
            
            Map<String, String> contentVersionMap = new Map<String, String>();
            contentVersionMap.put('Id', cvData.Id);
            contentVersionMap.put('Title', cvData.Title);
            contentVersionMap.put('VersionData', base64Data);
            contentVersionMap.put('ContentDocumentId', cvData.ContentDocumentId);
            
            return contentVersionMap;    
        }
        return null;
    }
}