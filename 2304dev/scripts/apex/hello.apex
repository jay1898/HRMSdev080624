// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

        // Test data setup
        // Test data setup
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com');
        insert con;
        
        Employee__c testEmployee = new Employee__c(
            Name = 'TEST EMP',
            Username__c = 'testuserr',
            Password__c = 'Admin@1234',
            Email__c = 'testemail1@gmail.com',
            Clocked_In_Out_Status__c = 'Clock-in',
            Date_of_Birth__c = Date.today(),
            Emergency_Contact_No__c = '3454556666',
            Gender__c = 'Male',
            First_Name__c = 'AKASH',
            Last_Name__c = 'LAKKAD',
            Personal_Email__c = 'jay12246@gmail.com'
        );
        insert testEmployee;
        
        // Call the method
        Test.startTest();
        AnnouncementController.BirthdayData result = AnnouncementController.getEmployeesBirthdays();
        Test.stopTest();
        
        system.debug('resultresult-->'+result);
        // Verify the result
        System.assertEquals(1, result.todayBirthdays.size(), 'Today birthdays count should be 1');
        System.assertEquals('Test Employee', result.todayBirthdays[0].get('Name'), 'Name should match');
        System.assertEquals(Date.today(), result.todayBirthdays[0].get('Date_of_Birth__c'), 'Date of birth should match');
        
        // Call the method
        Test.startTest();
        AnnouncementController.BirthdayData result = AnnouncementController.getEmployeesBirthdays();
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(1, result.todayBirthdays.size(), 'Today birthdays count should be 1');
        System.assertEquals('Test Employee', result.todayBirthdays[0].get('Name'), 'Name should match');
        System.assertEquals(Date.today(), result.todayBirthdays[0].get('Date_of_Birth__c'), 'Date of birth should match');
        
        // Clean up test data
        //delete emp;