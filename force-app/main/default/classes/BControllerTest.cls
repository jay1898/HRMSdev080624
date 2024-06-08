@isTest
private class BControllerTest {
/*
@IsTest
static void testFetchProfileImg() {
    List<Employee__c> employees = new List<Employee__c>();
    employees.add(new Employee__c(
        Name = 'TESTEMPPPPEEE',
        Username__c = 'testuserrt',
        Password__c = 'Admin@123433',
        Email__c = 'testemail25251@gmail.com',
        Clocked_In_Out_Status__c = 'Clock-in',
        Date_of_Birth__c = Date.today(),
        Emergency_Contact_No__c = '3454556622266',
        Gender__c = 'Male',
        First_Name__c = 'TESTEMOP',
        Last_Name__c = 'TESTEMOP',
        Personal_Email__c = 'johnhapkin34444444@gmail.com')
    );
    insert employees;

    List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();

    for(Employee__c emp : employees) {
        // Create a ContentVersion record
        ContentVersion version = new ContentVersion(
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Image Content')
        );
        insert version;

        documentLinks.add(new ContentDocumentLink(
            ContentDocumentId = version.ContentDocumentId,
            LinkedEntityId = emp.Id
        ));
    }
    insert documentLinks;

    Test.startTest();
    // Call the method
    Map<Id, String> result = AnnouncementController.fetchProfileImg();
    Test.stopTest();

    // Assert the result
    System.assertEquals(1, result.size()); // Update the expected size based on your business logic
    for(String base64Data : result.values()) {
        System.assertNotEquals(null, base64Data);
    }
}
    */
    /*
    @IsTest
    static void testFetchPostImg() {
        // Test data setup
        Notification__c notification = new Notification__c(Type__c = 'Post');
        insert notification;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Image Content'),
            File_Category__c = 'Post'
        );
        insert contentVersion;
        
        ContentDocument contentDocument = 
        [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument 
            WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id)
        ];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = notification.Id
        );
        insert contentDocumentLink;
        
        Test.startTest();
        Map<Id, List<String>> result = AnnouncementController.fetchPostImg();
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals(1, result.get(notification.Id).size());
    }
    */
    
    /*
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
        system.debug('todaydateAnniversary.size()TTTTTTTTTTTTTTT--->'+result.todaydateAnniversary.size());
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

    }*/
}