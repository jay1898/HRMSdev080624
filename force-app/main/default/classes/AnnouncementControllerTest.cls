@isTest
private class AnnouncementControllerTest {

    @isTest
    static void testDeleteNotification() {
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        Notification__c testNotification = new Notification__c(Type__c='Announcement');
        insert testNotification;
        
        String jsonString ='{"isOwnerOfficerOnSupplimetalInfo": true}';
        contentVersion cvObject = new contentVersion();
        cvObject.Title = 'Post1';
        cvObject.PathOnClient = 'Post1.txt';
        cvObject.VersionData = Blob.valueOf(jsonString);
		insert cvObject;
        
        ContentDocument testDocument = [SELECT Id, Title FROM ContentDocument WHERE  LatestPublishedVersionId = :cvObject.Id LIMIT 1];
        
        // Create ContentDocumentLink
        contentDocumentLink cdlObj = new contentDocumentLink(); 
        cdlObj.LinkedEntityId = testNotification.Id;
        cdlObj.ContentDocumentId = testDocument.Id;
        cdlObj.shareType = 'V';
        cdlObj.visibility = 'AllUsers';
        insert cdlObj;
        
        // Call the method to be tested
        Test.startTest();
        AnnouncementController.deleteNotification(testNotification.Id);
        Test.stopTest();
        List<Notification__c> deletedNotifications = [SELECT Id FROM Notification__c WHERE Id = :testNotification.Id];
        System.assertEquals(0, deletedNotifications.size(), 'Notification record should be deleted');
    }
    
    @isTest
    static void testFetchNotificationData() {
        // Create Employee Test Data 
        
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        String dobString = '2001-05-01';
		Date dobDate = Date.valueOf(dobString);
        Employee__c employee = new Employee__c();
        employee.Name = 'TESTFRTGS';
        employee.Username__c = 'testuser';
        employee.Password__c = 'Admin@123';
        employee.Email__c = 'testemail@gmail.com';
        employee.Clocked_In_Out_Status__c = 'Clock-in';
        employee.Date_of_Birth__c = dobDate;
        employee.Emergency_Contact_No__c = '3454556622266';
        employee.Gender__c = 'Male';
        employee.First_Name__c = 'TESTEMODP';
        employee.Last_Name__c = 'TESTEMOP';
        employee.Personal_Email__c = 'johnhapkin34444444@gmail.com';
        insert employee;
        
        Attendance__c attendance = new Attendance__c();
        attendance.Employee__c = employee.Id;
        attendance.Date__c = Date.today();
        attendance.Override_Absent__c = 'P';
        insert attendance;
        
        
        // Create test data - Notification records
        Notification__c announceNotiObj = new Notification__c(); 
        announceNotiObj.Description__c = 'Notification 1';
        announceNotiObj.Employee__c = employee.Id;
        announceNotiObj.Type__c = 'Announcement';
        announceNotiObj.Content__c = 'Content 1';
        announceNotiObj.Announced_by__c = employee.Id;
        insert announceNotiObj;
		
        Notification__c postNotiObj = new Notification__c(); 
		postNotiObj.Description__c = 'Notification 2';
        postNotiObj.Employee__c = employee.Id;
        postNotiObj.Type__c = 'Post';
        postNotiObj.Content__c = 'Content 2';
        postNotiObj.Announced_by__c = employee.Id;
        insert postNotiObj;
        
        // Post Image 1---------------------------------------------------------------------------------
        String jsonString1 ='{"isOwnerOfficerOnSupplimetalInfo": true}';
        contentVersion cvObject1 = new contentVersion();
        cvObject1.Title = 'PostImage1';
        cvObject1.PathOnClient = 'PostImage1.txt';
        cvObject1.VersionData = Blob.valueOf(jsonString1);
        cvObject1.File_Category__c = 'Post';
		insert cvObject1;
        
        ContentDocument testDocument1 = [SELECT Id, Title FROM ContentDocument WHERE  LatestPublishedVersionId = :cvObject1.Id LIMIT 1];
        
        // Create ContentDocumentLink
        contentDocumentLink cdlObj1 = new contentDocumentLink(); 
        cdlObj1.LinkedEntityId = postNotiObj.Id;
        cdlObj1.ContentDocumentId = testDocument1.Id;
        cdlObj1.shareType = 'V';
        cdlObj1.visibility = 'AllUsers';
        insert cdlObj1;
        
        // Post Image 2---------------------------------------------------------------------
        String jsonString2 ='{"isOwnerOfficerOnSupplimetalInfo": true}';
        contentVersion cvObject2 = new contentVersion();
        cvObject2.Title = 'PostImage2';
        cvObject2.PathOnClient = 'PostImage2.txt';
        cvObject2.VersionData = Blob.valueOf(jsonString2);
        cvObject2.File_Category__c = 'Post';
		insert cvObject2;
        
        ContentDocument testDocument2 = [SELECT Id, Title FROM ContentDocument WHERE  LatestPublishedVersionId = :cvObject2.Id LIMIT 1];
        
        // Create ContentDocumentLink
        contentDocumentLink cdlObj2 = new contentDocumentLink(); 
        cdlObj2.LinkedEntityId = postNotiObj.Id;
        cdlObj2.ContentDocumentId = testDocument2.Id;
        cdlObj2.shareType = 'V';
        cdlObj2.visibility = 'AllUsers';
        insert cdlObj2;
        
        // Profile Photo --------------------------------------------------------
        /*String jsonString ='{"isOwnerOfficerOnSupplimetalInfo": true}';
        contentVersion cvObject3 = new contentVersion();
        cvObject3.Title = 'EmployeeProfilePhoto;
        cvObject3.PathOnClient = 'EmployeeProfilePhoto.txt';
        cvObject3.VersionData = Blob.valueOf(jsonString);
		insert cvObject3;
        
        ContentDocument testDocument3 = [SELECT Id, Title FROM ContentDocument WHERE  LatestPublishedVersionId = :cvObject3.Id LIMIT 1];
        
        // Create ContentDocumentLink
        contentDocumentLink cdlObj3 = new contentDocumentLink(); 
        cdlObj3.LinkedEntityId = testNotification.Id;
        cdlObj3.ContentDocumentId = testDocument.Id;
        cdlObj3.shareType = 'V';
        cdlObj3.visibility = 'AllUsers';
        insert cdlObj3;*/
        
       // Map<Id, String> profilePhotoMap = new Map<Id, String>();
        //Map<Id, List<Id>> postPhotoMap = new Map<Id, List<Id>>();

        Test.startTest();
        List<Map<String, Object>> notificationDataList = AnnouncementController.fetchNotificationData('Announcement', 5); // Change parameters as needed
        Test.stopTest();

        // Assert
        // Verify that the returned list is not null and contains entries
        System.assertNotEquals(null, notificationDataList, 'List should not be null');
        System.assertNotEquals(0, notificationDataList.size(), 'List should contain entries');
    }
    
    @isTest
    static void testFetchNotificationCount() {
        Notification__c notification1 = new Notification__c(Type__c = 'Announcement', Expiration_Date__c = Date.today().addDays(1));
        Notification__c notification2 = new Notification__c(Type__c = 'Announcement', Expiration_Date__c = Date.today().addDays(2));
        Notification__c notification3 = new Notification__c(Type__c = 'Announcement', Expiration_Date__c = Date.today().addDays(-1));
        insert new List<Notification__c>{notification1, notification2, notification3};

        Test.startTest();
        Integer count = AnnouncementController.fetchNotificationCount();
        Test.stopTest();
        Integer expectedCount = 2; 
        System.assertEquals(expectedCount, count, 'Notification count is incorrect');
    }
    
    @isTest
    static void testFetchNotificationPostCount() {
        Notification__c notification1 = new Notification__c(Type__c = 'Post', Expiration_Date__c = Date.today().addDays(1));
        Notification__c notification2 = new Notification__c(Type__c = 'Post', Expiration_Date__c = Date.today().addDays(2));
        Notification__c notification3 = new Notification__c(Type__c = 'Post', Expiration_Date__c = Date.today().addDays(-1));
        insert new List<Notification__c>{notification1, notification2, notification3};

        Test.startTest();
        Integer count = AnnouncementController.fetchNotificationPostCount();
        Test.stopTest();
        Integer expectedCount = 2; 
        System.assertEquals(expectedCount, count, 'Notification count is incorrect');
    }
    
    @isTest
    static void testInsertNotificationDataWithExpirationDate() {
        
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        String dobString = '2001-05-01';
		Date dobDate = Date.valueOf(dobString);
        Employee__c employee = new Employee__c();
        employee.Name = 'TESTFRTGS';
        employee.Username__c = 'testuser';
        employee.Password__c = 'Admin@123';
        employee.Email__c = 'testemail@gmail.com';
        employee.Clocked_In_Out_Status__c = 'Clock-in';
        employee.Date_of_Birth__c = dobDate;
        employee.Emergency_Contact_No__c = '3454556622266';
        employee.Gender__c = 'Male';
        employee.First_Name__c = 'TESTEMODP';
        employee.Last_Name__c = 'TESTEMOP';
        employee.Personal_Email__c = 'johnhapkin34444444@gmail.com';
        insert employee;
        
        Attendance__c attendance = new Attendance__c();
        attendance.Employee__c = employee.Id;
        attendance.Date__c = Date.today();
        attendance.Override_Absent__c = 'P';
        insert attendance;
        
        String content = 'Test Notification';
        String expirationDate = '2024-05-31';
        String annonceById = employee.Id;
        String notiType = 'Announcement';
		Date expDate = Date.valueOf(expirationDate);
        Test.startTest();

        // Call the method
        String notificationId = AnnouncementController.insertNotificationData(content, expirationDate, annonceById, notiType);

        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, notificationId, 'Notification Id should not be null');
    }
    
    /*@isTest 
    static void testInsertNotificationDataWithoutExpirationDate() {
        // Create test data
        String content = 'Test Notification';
        String expirationDate = null; // or ''
        String annonceById = 'VRUSHABH SAVANI'; 
        String notiType = 'Announcement';

        Test.startTest();

        // Call the method
        String notificationId = AnnouncementController.insertNotificationData(content, expirationDate, annonceById, notiType);

        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, notificationId, 'Notification Id should not be null');
    }*/

    /*@isTest
    static void testFetchProfileImg() {
        // Arrange
        // Create test data - Employee records
        List<Employee__c> employees = new List<Employee__c>();
        for(Integer i = 0; i < 5; i++) {
            Employee__c emp = new Employee__c();
            emp.Date_of_Birth__c = date.parse('29/4/2024');
            emp.Email__c = 'test555@gmail.com';
            emp.Emergency_Contact_No__c = '16546516456451';
            emp.First_Name__c = 'Vrushabh';
            emp.Gender__c = 'Male';
            emp.Last_Name__c = 'Savani';
            emp.Username__c = 'V';
            emp.Personal_Email__c = 'personal@gmail.com';
            // Add any necessary fields for the Employee__c object initialization
            employees.add(emp);
        }
        insert employees;

        // Create test ContentDocumentLink records representing profile photos
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        for(Employee__c emp : employees) {
            ContentVersion cv = new ContentVersion(
                Title = 'Employee Profile Photo',
                PathOnClient = 'Test.jpg', // This is required for ContentVersion insertion
                VersionData = Blob.valueOf('Test file content') // This is required for ContentVersion insertion
            );
            insert cv;

            ContentDocumentLink link = new ContentDocumentLink(
                LinkedEntityId = emp.Id,
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId
            );
            documentLinks.add(link);
        }
        insert documentLinks;

        // Act
        Test.startTest();
        Map<Id, String> empIdProfilePhotoDataMap = AnnouncementController.fetchProfileImg();
        Test.stopTest();

        // Assert
        // Verify that the map is not null and contains entries
        System.assertNotEquals(null, empIdProfilePhotoDataMap, 'Map should not be null');
        System.assertNotEquals(0, empIdProfilePhotoDataMap.size(), 'Map should contain entries');
    }*/
    
    @isTest
    static void testFetchPostImg() {
      
        // Create a single ContentVersion
          
        
          List<Notification__c> notifications = new List<Notification__c>();
          List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
          Map<Id, List<Id>> expectedPostIdListPhotoMap = new Map<Id, List<Id>>();
        	
        for (Integer i = 0; i < 3; i++) {
          Notification__c notification = new Notification__c(Type__c = 'Post');
          notifications.add(notification);
        }
        
        insert notifications;  // Insert notifications first
        
        for (Notification__c notification : notifications) {
          ContentVersion cv = new ContentVersion(Title = 'Test File', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test file content'));
          insert cv;
          
          ContentDocument testDocument2 = [SELECT Id, Title FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id LIMIT 1];
          
          ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = notification.Id,
            ContentDocumentId = testDocument2.Id
          );
          documentLinks.add(link);
          expectedPostIdListPhotoMap.put(notification.Id, new List<Id>{link.ContentDocumentId});
        }
        
        insert documentLinks;
          
        
          Test.startTest();
          Map<Id, List<Id>> postIdListPhotoMap = AnnouncementController.fetchPostImg();
          Test.stopTest();

        /*System.assertNotEquals(null, postIdListPhotoMap, 'Map should not be null');
        System.assertNotEquals(0, postIdListPhotoMap.size(), 'Map should contain entries');

        System.assertEquals(expectedPostIdListPhotoMap.keySet(), postIdListPhotoMap.keySet(), 'Keys should match');
        for(Id postId : expectedPostIdListPhotoMap.keySet()) {
            System.assertEquals(
                expectedPostIdListPhotoMap.get(postId).size(),
                postIdListPhotoMap.get(postId).size(),
                'List sizes should match for postId: ' + postId
            );
            for(Id contentVersionId : expectedPostIdListPhotoMap.get(postId)) {
                System.assert(postIdListPhotoMap.get(postId).contains(contentVersionId), 'ContentVersionId not found for postId: ' + postId);
            }
        }*/
    }

    // Helper method to create a test ContentDocument record
    static ContentDocument createTestContentDocument() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'Test.jpg', // This is required for ContentVersion insertion
            VersionData = Blob.valueOf('Test file content') // This is required for ContentVersion insertion
            
        );
        insert cv;

        return [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
    }
    
   @isTest static void testUpdateNotificationData() {
        // Create test data
        Notification__c notification = new Notification__c(Content__c = 'Old Content', Type__c = 'Announcement');
        insert notification;

        List<Map<String, String>> notificationData = new List<Map<String, String>>();
        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put('Id', notification.Id);
        dataMap.put('content__c', 'New Content');
        notificationData.add(dataMap);

        Test.startTest();

        // Call the method
        AnnouncementController.updateNotificationData(notificationData, 'Announcement');

        Test.stopTest();

        // Retrieve the updated record
        Notification__c updatedNotification = [SELECT Id, Content__c FROM Notification__c WHERE Id = :notification.Id];

        // Assert the result
        //System.assertEquals('New Content', updatedNotification.Content__c, 'Content should be updated');
    }
    
    
     @IsTest
    static void testDeletePostImage() {
        // Create ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Fetch the created ContentDocument Id
        ContentDocument contentDocument = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion.Id LIMIT 1];

        // Create a custom object record (or any other sObject that represents the post)
        //Custom_Object__c post = new Custom_Object__c(Name = 'Test Post');
        Notification__c post = new Notification__c(Type__c = 'Post', Content__c = 'Test Post');
        insert post;

        // Create ContentDocumentLink record
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = post.Id,
            ContentDocumentId = contentDocument.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;
        
        // Retrieve test data
        ContentVersion contentVersionRec = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Notification__c postRec = [SELECT Id FROM Notification__c LIMIT 1];

        Test.startTest();
        // Call the method to be tested
        AnnouncementController.deletePostImage(contentVersionRec.Id, postRec.Id);
        Test.stopTest();

        // Verify that the ContentDocumentLink was deleted
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentVersionRec.ContentDocumentId];
        System.assertEquals(0, links.size(), 'ContentDocumentLink should be deleted');

        // Verify that the ContentDocument was deleted
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id = :contentVersionRec.ContentDocumentId];
        System.assertEquals(0, docs.size(), 'ContentDocument should be deleted');
        
    }
    
    @isTest
    static void testCreatePostFiles() {
        // Retrieve test data
        Notification__c postRec = new Notification__c( Type__c = 'Post');
        insert postRec;
        Notification__c post = [SELECT Id FROM Notification__c LIMIT 1];

        // Prepare test file data
        String fileData = '{ "fileContent": "' + EncodingUtil.base64Encode(Blob.valueOf('Test file content')) + '" }';
        
        Test.startTest();
        // Call the method to be tested
        AnnouncementController.createPostFiles(fileData, post.Id);
        Test.stopTest();

        // Verify that the ContentVersion was created
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Title = 'Post-1'];
        System.assertEquals(1, contentVersions.size(), 'ContentVersion should be created');

        // Verify that the ContentDocumentLink was created
        List<ContentDocumentLink> documentLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :post.Id];
        System.assertEquals(1, documentLinks.size(), 'ContentDocumentLink should be created');
    }

     @isTest
    static void testSavePostFiles() {
        
         // Create ContentVersion records
       	ContentVersion cv1 = new ContentVersion(
            Title = 'TestFile1.jpg',
            VersionData = Blob.valueOf('Test data 1'),
            PathOnClient = 'TestFile1.jpg'
        );
        insert cv1;

        ContentVersion cv2 = new ContentVersion(
            Title = 'TestFile2.jpg',
            VersionData = Blob.valueOf('Test data 2'),
            PathOnClient = 'TestFile2.jpg'
        );
        insert cv2;

        // Create a custom object record (or any other sObject that represents the post)
        Notification__c postRec = new Notification__c( Type__c = 'Post');
        insert postRec;
        
        
        // Retrieve test data
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :new List<Id>{cv1.Id, cv2.Id}];
        Notification__c post = [SELECT Id FROM Notification__c LIMIT 1];

        // Prepare list of ContentVersion IDs
        List<String> contentVersionIdList = new List<String>();
        for(ContentVersion cv : contentVersions) {
            contentVersionIdList.add(cv.Id);
        }

        Test.startTest();
        AnnouncementController.savePostFiles(contentVersionIdList, postRec.Id);
        Test.stopTest();

        // Verify that the ContentDocumentLink was created
        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :post.Id];
        System.assertEquals(2, documentLinks.size(), 'There should be 2 document links created');

        List<ContentVersion> updatedContentVersions = [SELECT Id, Title, FirstPublishLocationId, File_Category__c FROM ContentVersion WHERE Id IN :contentVersionIdList];
        System.assertEquals(2, updatedContentVersions.size(), 'There should be 2 updated content versions');

        for (ContentVersion updatedCv : updatedContentVersions) {
            //System.assertEquals(post.Id, updatedCv.FirstPublishLocationId, 'FirstPublishLocationId should be set to the test account Id');
            System.assertEquals('Post', updatedCv.File_Category__c, 'File_Category__c should be set to "Post"');
            System.assert(updatedCv.Title.startsWith('Post-'), 'Title should start with "Post-"');
        }
    }
    
     @isTest
    static void testGetContentVersionData() {
        
        Contact con=new Contact(LastName='test',Email='test@gmail.com');
        insert con;
        
        String dobString = '2001-05-01';
		Date dobDate = Date.valueOf(dobString);
        Employee__c employee = new Employee__c();
        employee.Name = 'TESTFRTGS';
        employee.Username__c = 'testuser';
        employee.Password__c = 'Admin@123';
        employee.Email__c = 'testemail@gmail.com';
        employee.Clocked_In_Out_Status__c = 'Clock-in';
        employee.Date_of_Birth__c = dobDate;
        employee.Emergency_Contact_No__c = '3454556622266';
        employee.Gender__c = 'Male';
        employee.First_Name__c = 'TESTEMODP';
        employee.Last_Name__c = 'TESTEMOP';
        employee.Personal_Email__c = 'johnhapkin34444444@gmail.com';
        insert employee;
        
        Attendance__c attendance = new Attendance__c();
        attendance.Employee__c = employee.Id;
        attendance.Date__c = Date.today();
        attendance.Override_Absent__c = 'P';
        insert attendance;

        
         ContentVersion cv1 = new ContentVersion(
            Title = 'Test Content',
            VersionData = Blob.valueOf('Test data'), // Sample data
            PathOnClient = 'test.jpg'
        );
        insert cv1;
        
        ContentVersion cv2 = new ContentVersion(
            Title = 'TestImage.jpg',
            VersionData = Blob.valueOf('Test image data'), // Sample data
            PathOnClient = 'TestImage.jpg'
        );
        insert cv2;
        
        ContentVersion insertedCv1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id LIMIT 1];
        ContentVersion insertedCv2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id LIMIT 1];
        
         ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = employee.Id, 
            ContentDocumentId = insertedCv2.ContentDocumentId,
            ShareType = 'I'
        );
        insert cdl;
        
        Test.startTest();
        Map<String, String> result = AnnouncementController.getContentVersionData(insertedCv1.Id);
        String result1 = AnnouncementController.fetchImage('TestImage.jpg', employee.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(insertedCv1.Id, result.get('Id'), 'Ids should match');
        System.assertEquals('Test Content', result.get('Title'), 'Titles should match');
        System.assert(result.get('VersionData').startsWith('data:image/jpeg;base64,'), 'VersionData should start with base64 prefix');
        System.assertEquals(insertedCv1.ContentDocumentId, result.get('ContentDocumentId'), 'ContentDocumentId should match');
        //System.assertNotEquals('', result1, 'Result should not be empty');
        //String expectedBase64Data = EncodingUtil.base64Encode(Blob.valueOf('Test image data'));
        //System.assertEquals(expectedBase64Data, result1, 'Base64 encoded data should match the expected value');
    }
    /*
    @IsTest
    static void testGetEmployeesWorkAnniversary() {
        // Test data setup
        Contact con1=new Contact(LastName='test1',Email='test1@gmail.com');
        insert con1;
        Contact con2=new Contact(LastName='test2',Email='test2@gmail.com');
        insert con2;
        Contact con3=new Contact(LastName='test3',Email='test3@gmail.com');
        insert con3;
        
        Employee__c emp1 = new Employee__c(
            Name = 'TESTEMPGG',
            Date_Of_Joining__c = Date.newInstance(2021, 4, 25),//Date.today(),
            Personal_Email__c = 'testemail41@gmail.com',
            Username__c = 'testuserr344',
            Password__c = 'Admin@1442346',
            Email__c = 'testemail43@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2022, 5, 5),
            Emergency_Contact_No__c = '345455446667',
            Gender__c = 'Male',
            First_Name__c = 'EMPTESTR',
            Last_Name__c = 'EMPTESTR'
        );
        insert emp1;
        
        Employee__c emp2 = new Employee__c(
            Name = 'TESTEMPTESTTTTT',
            Date_Of_Joining__c = Date.newInstance(2023, 4, 25),
            Personal_Email__c = 'testemail42@gmail.com',
            Username__c = 'testusettrr2',
            Password__c = 'Admin@1442345',
            Email__c = 'testemail42@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2023, 4, 29),
            Emergency_Contact_No__c = '345454456665',
            Gender__c = 'Male',
            First_Name__c = 'EMPTT',
            Last_Name__c = 'EMPTT'
        );
        insert emp2;
        
        Employee__c emp3 = new Employee__c(
            Name = 'TESTEMPEMP',
            Date_Of_Joining__c = Date.newInstance(2022, 5, 5),
            Personal_Email__c = 'testemail3@gmail.com',
            Username__c = 'testuserr34',
            Password__c = 'Admien@12346',
            Email__c = 'testemairl3@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2022, 5, 5),
            Emergency_Contact_No__c = '345466556667',
            Gender__c = 'Male',
            First_Name__c = 'EMPYTEST',
            Last_Name__c = 'EMPYTEST'
        );
        insert emp3;
        
            
        Attendance__c attendance1 = new Attendance__c();
        attendance1.Employee__c = emp1.Id;
        attendance1.Date__c = Date.today();
        attendance1.Override_Absent__c = 'P';
        insert attendance1;
        
        Attendance__c attendance2 = new Attendance__c();
        attendance2.Employee__c = emp2.Id;
        attendance2.Date__c = Date.today();
        attendance2.Override_Absent__c = 'P';
        insert attendance2;
        
        Attendance__c attendance3 = new Attendance__c();
        attendance3.Employee__c = emp3.Id;
        attendance3.Date__c = Date.today();
        attendance3.Override_Absent__c = 'P';
        insert attendance3;
            // Call the method
        Test.startTest();
        AnnouncementController.AnniversaryData result = AnnouncementController.getEmployeesWorkAnniversary();
        Test.stopTest();
        
    }*/
    
   
	@isTest
    static void testCheckFileSize() {
        ContentVersion cv1 = new ContentVersion(
            Title = 'Small File',
            PathOnClient = 'smallfile.txt',
            VersionData = Blob.valueOf('small file content')
           // ContentSize = 1024 // 1 KB
        );
        insert cv1;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Large File',
            PathOnClient = 'largefile.txt',
            VersionData = Blob.valueOf('large file content')
            //ContentSize = 3 * 1024 * 1024 // 3 MB
        );
        insert cv2;
        List<String> cvIdList = new List<String>{cv1.Id, cv2.Id};
        List<String> rspCVList = AnnouncementController.checkFileSize(cvIdList);
        
        //System.assertEquals(1, rspCVList.size());
        //System.assertEquals('Large File', rspCVList[0]);
        //List<ContentDocument> deletedDocs = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvIdList)];
        //System.assertEquals(0, deletedDocs.size(), 'All ContentDocuments should be deleted.');
    }
    
   @TestSetup
    static void setupdata(){
        // Test data setup
        Contact con1 = new Contact(LastName = 'testrrrr', Email = 'test1@gmail.com');
        Contact con2 = new Contact(LastName = 'testdffd', Email = 'test2@gmail.com');
        Contact con3 = new Contact(LastName = 'testddddfg', Email = 'test3@gmail.com');
        
        insert new List<Contact>{con1, con2, con3};
            
            // This will ensure that today is the work anniversary of an employee
            Employee__c testEmployee1 = new Employee__c(
                Name = 'TESTEMP',
                Username__c = 'testuserr',
                Password__c = 'Admin@1234',
                Email__c = 'testemail1@gmail.com',
                Clocked_In_Out_Status__c = 'Clock-in',
                Date_of_Birth__c = Date.today(),
                Emergency_Contact_No__c = '3454556666',
                Gender__c = 'Male',
                First_Name__c = 'TEST',
                Last_Name__c = 'TEST',
                Personal_Email__c = con1.Email,
                Date_Of_Joining__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()) // Work anniversary is today
            );
        
        Employee__c testEmployee2 = new Employee__c(
            Name = 'TESTEMPTEST',
            Username__c = 'testuserr2',
            Password__c = 'Admin@12345',
            Email__c = 'testemail2@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2023, 4, 29),
            Emergency_Contact_No__c = '3454556665',
            Gender__c = 'Male',
            First_Name__c = 'EMP',
            Last_Name__c = 'EMP',
            Personal_Email__c = con2.Email,
            Date_Of_Joining__c = Date.newInstance(2023, 4, 29));
        
        Employee__c testEmployee3 = new Employee__c(
            Name = 'TESTEMPEMP',
            Username__c = 'testuserr3',
            Password__c = 'Admin@12346',
            Email__c = 'testemail3@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2022, 5, 5),
            Emergency_Contact_No__c = '3454556667',
            Gender__c = 'Male',
            First_Name__c = 'EMPTEST',
            Last_Name__c = 'EMPTEST',
            Date_Of_Joining__c = Date.newInstance(2022, 5, 5),
            Personal_Email__c = con3.Email);
        
        insert new List<Employee__c>{testEmployee1, testEmployee2, testEmployee3};
            }
    
    @IsTest
    static void testGetEmployeesBirthdays() {
        
        // Call the method
        Test.startTest();
        AnnouncementController.BirthdayData result = AnnouncementController.getEmployeesBirthdays();
        Test.stopTest();
        
        System.assertEquals(1, result.todayBirthdays.size()); // No birthdays today
    }
    
    @IsTest
    static void testGetEmployeesBirthdaysNextSevenDays() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE First_Name__c = 'EMP' LIMIT 1];
        
        Test.setCreatedDate(emp.Id, DateTime.newInstance(2024,4,27));
        Test.startTest();
        AnnouncementController.BirthdayData result = AnnouncementController.getEmployeesBirthdays();
        Test.stopTest();
        
        System.assertEquals(0, result.nextSevenDaysBirthdays.size()); // No birthdays today
    }
    
    @IsTest
    static void testGetEmployeesBirthdaysNextSevenDaysInSameMonth() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE First_Name__c = 'EMPTEST' LIMIT 1];
        
        Test.setCreatedDate(emp.Id, DateTime.newInstance(2022,5,1));
        Test.startTest();
        AnnouncementController.BirthdayData result = AnnouncementController.getEmployeesBirthdays();
        Test.stopTest();
        
        System.assertEquals(0, result.nextSevenDaysBirthdays.size()); // No birthdays today
    }
    
    @IsTest
    static void testGetEmployeesTodayWorkAnniversary() {
        
        // Call the method
        Test.startTest();
        AnnouncementController.AnniversaryData result = AnnouncementController.getEmployeesWorkAnniversary();
        Test.stopTest();
        
        System.assertEquals(0, result.todaydateAnniversary.size()); // No birthdays today
    }
    
    @IsTest
    static void testGetEmployeesWorkAnniversary() {
        // Test data setup
        Employee__c emp1 = new Employee__c(
            Name = 'TESTEMPGG',
            Date_Of_Joining__c = Date.newInstance(2021, 4, 25),//Date.today(),
            Personal_Email__c = 'testemail41@gmail.com',
            Username__c = 'testuserr344',
            Password__c = 'Admin@1442346',
            Email__c = 'testemail43@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2022, 5, 5),
            Emergency_Contact_No__c = '345455446667',
            Gender__c = 'Male',
            First_Name__c = 'EMPTESTR',
            Last_Name__c = 'EMPTESTR'
        );
        
        Employee__c emp2 = new Employee__c(
            Name = 'TESTEMPTESTTTTT',
            Date_Of_Joining__c = Date.newInstance(2023, 4, 25),
            Personal_Email__c = 'testemail42@gmail.com',
            Username__c = 'testusettrr2',
            Password__c = 'Admin@1442345',
            Email__c = 'testemail42@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2023, 4, 29),
            Emergency_Contact_No__c = '345454456665',
            Gender__c = 'Male',
            First_Name__c = 'EMPTT',
            Last_Name__c = 'EMPTT'
        );
        
        Employee__c emp3 = new Employee__c(
            Name = 'TESTEMPEMP',
            Date_Of_Joining__c = Date.newInstance(2022, 5, 5),
            Personal_Email__c = 'testemail3@gmail.com',
            Username__c = 'testuserr34',
            Password__c = 'Admien@12346',
            Email__c = 'testemairl3@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.newInstance(2022, 5, 5),
            Emergency_Contact_No__c = '345466556667',
            Gender__c = 'Male',
            First_Name__c = 'EMPYTEST',
            Last_Name__c = 'EMPYTEST'
        );
        
        insert new List<Employee__c>{emp1, emp2, emp3};
            // Call the method
        Test.startTest();
        AnnouncementController.AnniversaryData result = AnnouncementController.getEmployeesWorkAnniversary();
        Test.stopTest();

    }
    
}