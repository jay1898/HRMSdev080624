@isTest
public class UpdatePYTDSalesOnAccountTest {
    public static testMethod void testBatchUpdateOfPYTDSalesField(){
        Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date previousYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        Date todayLastYear = System.today().addYears(-1);

        Account accountOne = TestUtil.createBranchAccount('Branch Account', false);
        accountOne.PYTD_Sales__c = 0;
        insert accountOne;
        
        Account accountTwo = TestUtil.createBranchAccount('Branch Account', false);
        accountTwo.PYTD_Sales__c = 0;
        insert accountTwo;
        
        Opportunity opportunityOne = TestUtil.createOpportunity('New Opp', accountOne.Id, UserInfo.getUserId(), false); 
        opportunityOne.Appointment_DateTime__c = DateTime.now();
        opportunityOne.Status__c = 'Open';
        opportunityOne.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        insert opportunityOne;
        
        Opportunity opportunityTwo = TestUtil.createOpportunity('New Opp', accountTwo.Id, UserInfo.getUserId(), false); 
        opportunityTwo.Appointment_DateTime__c = DateTime.now();
        opportunityTwo.Status__c = 'Open';
        opportunityTwo.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        insert opportunityTwo;
        
        Associated_Account__c associacedAccountOne = new Associated_Account__c();
        associacedAccountOne.Associated_Account_Name__c = accountOne.Id;
        associacedAccountOne.Opportunity__c = opportunityOne.Id;
        insert associacedAccountOne;
        
        Associated_Account__c associatedAccountTwo = new Associated_Account__c();
        associatedAccountTwo.Associated_Account_Name__c = accountTwo.Id;
        associatedAccountTwo.Opportunity__c = opportunityTwo.Id;
        insert associatedAccountTwo;
        
        List<Quote> newQuotes = new List<Quote>();

        Quote quoteOne = TestUtil.createQuote(opportunityOne.Id, false);
        quoteOne.Quote_Number_PQM__c='8675309' ;
        quoteOne.BookDate__c = previousYearStartDate.addDays(5);
        quoteOne.Customer_Extended_Price__c = 9999;
        quoteOne.Status='Booked';
        newQuotes.add(quoteOne);
        
        Quote quoteTwo = TestUtil.createQuote(opportunityOne.Id, false);
        quoteTwo.Quote_Number_PQM__c='4242424' ;
        quoteTwo.BookDate__c = todayLastYear.addDays(-1);
        quoteTwo.Customer_Extended_Price__c = 8888;
        quoteTwo.Status='Ordered';
        newQuotes.add(quoteTwo);
        
        Quote quoteThree = TestUtil.createQuote(opportunityTwo.Id, false);
        quoteThree.Quote_Number_PQM__c='6655443' ;
        quoteThree.BookDate__c = previousYearStartDate.addDays(10);
        quoteThree.Customer_Extended_Price__c = 98765;
        quoteThree.Status='Booked';
        newQuotes.add(quoteThree);
        
        Quote quoteFour = TestUtil.createQuote(opportunityTwo.Id, false);
        quoteFour.Quote_Number_PQM__c='1122334' ;
        quoteFour.BookDate__c = todayLastYear.addDays(-1);
        quoteFour.Customer_Extended_Price__c = 43210;
        quoteFour.Status='Ordered';
        newQuotes.add(quoteFour);
        
        insert newQuotes;

        Test.startTest();       
        UpdatePYTDSalesOnAccount updatePYTDSalesOnAccount = new UpdatePYTDSalesOnAccount();
        Database.executeBatch(updatePYTDSalesOnAccount);
        Test.stopTest();
        
        List<Account> results = [SELECT Id, Name, PYTD_Sales__c FROM Account WHERE Id =: accountOne.Id OR Id =: accountTwo.Id];
        
        System.assertEquals(18887, results[0].PYTD_Sales__c);
        System.assertEquals(141975, results[1].PYTD_Sales__c);
    }
    
    public static testMethod void testBatchUpdateOfPYTDSalesFieldPhoneError(){
        Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date previousYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        Date todayLastYear = System.today().addYears(-1);

        Id accountOneId;
        Id accountTwoId;
        List<User> userForTesting = [SELECT Id FROM User WHERE FirstName = 'Data_Mock' AND LastName = 'User' LIMIT 1];
        system.runAs(userForTesting[0]){    
            Account accountOne = TestUtil.createBranchAccount('Branch Account', false);
            accountOne.PYTD_Sales__c = 0;
            insert accountOne;

            Opportunity opportunityOne = TestUtil.createOpportunity('New Opp', accountOne.Id, UserInfo.getUserId(), false); 
            opportunityOne.Appointment_DateTime__c = DateTime.now();
            opportunityOne.Status__c = 'Open';
            opportunityOne.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
            insert opportunityOne;
            
            Associated_Account__c associacedAccountOne = new Associated_Account__c();
            associacedAccountOne.Associated_Account_Name__c = accountOne.Id;
            associacedAccountOne.Opportunity__c = opportunityOne.Id;
            insert associacedAccountOne;
            
            Account accountTwo = TestUtil.createBranchAccount('Branch Account', false);
            accountTwo.PYTD_Sales__c = 0;
            accountTwo.phone = '21331231312312';
            insert accountTwo;

            Opportunity opportunityTwo = TestUtil.createOpportunity('New Opp', accountTwo.Id, UserInfo.getUserId(), false); 
            opportunityTwo.Appointment_DateTime__c = DateTime.now();
            opportunityTwo.Status__c = 'Open';
            opportunityTwo.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
            insert opportunityTwo;
    
            Associated_Account__c associatedAccountTwo = new Associated_Account__c();
            associatedAccountTwo.Associated_Account_Name__c = accountTwo.Id;
            associatedAccountTwo.Opportunity__c = opportunityTwo.Id;
            insert associatedAccountTwo;
            
            List<Quote> newQuotes = new List<Quote>();
    
            Quote quoteOne = TestUtil.createQuote(opportunityOne.Id, false);
            quoteOne.Quote_Number_PQM__c='8675309' ;
            quoteOne.BookDate__c = previousYearStartDate.addDays(5);
            quoteOne.Customer_Extended_Price__c = 9999;
            quoteOne.Status='Booked';
            newQuotes.add(quoteOne);
            
            Quote quoteTwo = TestUtil.createQuote(opportunityOne.Id, false);
            quoteTwo.Quote_Number_PQM__c='4242424' ;
            quoteTwo.BookDate__c = todayLastYear.addDays(-1);
            quoteTwo.Customer_Extended_Price__c = 8888;
            quoteTwo.Status='Ordered';
            newQuotes.add(quoteTwo);
            
            Quote quoteThree = TestUtil.createQuote(opportunityTwo.Id, false);
            quoteThree.Quote_Number_PQM__c='6655443' ;
            quoteThree.BookDate__c = previousYearStartDate.addDays(10);
            quoteThree.Customer_Extended_Price__c = 98765;
            quoteThree.Status='Booked';
            newQuotes.add(quoteThree);
            
            Quote quoteFour = TestUtil.createQuote(opportunityTwo.Id, false);
            quoteFour.Quote_Number_PQM__c='1122334' ;
            quoteFour.BookDate__c = todayLastYear.addDays(-1);
            quoteFour.Customer_Extended_Price__c = 43210;
            quoteFour.Status='Ordered';
            newQuotes.add(quoteFour);
            
            insert newQuotes;
            
            accountOneId = accountOne.Id;
            accountTwoId = accountTwo.Id;
        }        

        Test.startTest();       
        UpdatePYTDSalesOnAccount updatePYTDSalesOnAccount = new UpdatePYTDSalesOnAccount();
        Database.executeBatch(updatePYTDSalesOnAccount);
        Test.stopTest();
        
        List<Account> results = [SELECT Id, Name, PYTD_Sales__c FROM Account WHERE Id =: accountOneId OR Id =: accountTwoId];
        
        System.assertEquals(18887, results[0].PYTD_Sales__c);
        System.assertEquals(0, results[1].PYTD_Sales__c);
        
         List<Apex_Debug_Log__c> logs = [
            SELECT Id, Name, Apex_Class__c, Method__c, Message__c, Record_Id__c 
            FROM Apex_Debug_Log__c ORDER BY CreatedDate DESC 
            LIMIT 5 
        ];
        Apex_Debug_Log__c topLog = logs[0];
        
        System.assertEquals('UpdatePYTDSalesOnAccount', topLog.Apex_Class__c);
        System.assertEquals('Database.update', topLog.Method__c);
        System.assertEquals('There were one or more failures in a batch update. See the list of failures for details', topLog.Record_Id__c);
        System.assertEquals('accountId {' + accountTwoId + '}: Phone # should be 10 digits - please correct the number.', topLog.Message__c);
    }
}