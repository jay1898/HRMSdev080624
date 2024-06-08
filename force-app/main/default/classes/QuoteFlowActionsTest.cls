@isTest
public class QuoteFlowActionsTest {
    static testMethod void SendQuoteForReviewSuccessTest () {
        User user = TestUtil.createTradeCommSalesRep();
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c = '456';
        insert branch;

        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Company_Email__c = 'test_company_email@email.com';
        account.Branch__c = branch.Id;
        insert account;

        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', account.Id, user.Id, true); 
       
        Quote quote = TestUtil.createQuote(opportunity.Id, false);        
        quote.Quote_Number_PQM__c = '123456';
        insert quote;
        
        List<QuoteFlowActions.QuoteApprovalInput> quoteList = new List<QuoteFlowActions.QuoteApprovalInput>();
       
        QuoteFlowActions.QuoteApprovalInput quoteForApproval = new QuoteFlowActions.QuoteApprovalInput();
		quoteForApproval.opportunityId = opportunity.Id;
        quoteForApproval.opportunityOwnerFullName = user.FirstName + ' ' + user.LastName;
        quoteForApproval.opportunityOwnerTitle = user.Profile.Name;
        quoteForApproval.opportunityOwnerEmail = user.Email;
        quoteForApproval.accountCompanyEmail = account.Company_Email__c;
        quoteForApproval.branchNumber = branch.T_C_Branch_Number__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteId = quote.Id;
        
        quoteList.add(quoteForApproval);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GraphqlCalloutMock());
        List<Object> results = QuoteFlowActions.SendQuoteForApproval(quoteList);
   		Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void SendQuoteForReviewNoOwnerEmailSuccessTest () {
        User user = TestUtil.createTradeCommSalesRep();
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c = '456';
        insert branch;

        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Company_Email__c = 'test_company_email@email.com';
        account.Branch__c = branch.Id;
        insert account;


        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', account.Id, user.Id, true); 
       
        Quote quote = TestUtil.createQuote(opportunity.Id, false);        
        quote.Quote_Number_PQM__c = '123456';
        insert quote;
        
        List<QuoteFlowActions.QuoteApprovalInput> quoteList = new List<QuoteFlowActions.QuoteApprovalInput>();
       
        QuoteFlowActions.QuoteApprovalInput quoteForApproval = new QuoteFlowActions.QuoteApprovalInput();
		quoteForApproval.opportunityId = opportunity.Id;
        quoteForApproval.opportunityOwnerFullName = user.FirstName + ' ' + user.LastName;
        quoteForApproval.opportunityOwnerTitle = user.Profile.Name;
        quoteForApproval.opportunityOwnerEmail = null;
        quoteForApproval.accountCompanyEmail = account.Company_Email__c;
        quoteForApproval.branchNumber = branch.T_C_Branch_Number__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteId = quote.Id;
        
        quoteList.add(quoteForApproval);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GraphqlCalloutMock());
        List<Object> results = QuoteFlowActions.SendQuoteForApproval(quoteList);
   		Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void SendQuoteForReviewNoAccountCompanyEmailSuccessTest () {
        User user = TestUtil.createTradeCommSalesRep();
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c = '456';
        insert branch;

        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Company_Email__c = 'test_company_email@email.com';
        account.Branch__c = branch.Id;
        insert account;


        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', account.Id, user.Id, true); 
       
        Quote quote = TestUtil.createQuote(opportunity.Id, false);        
        quote.Quote_Number_PQM__c = '123456';
        insert quote;
        
        List<QuoteFlowActions.QuoteApprovalInput> quoteList = new List<QuoteFlowActions.QuoteApprovalInput>();
       
        QuoteFlowActions.QuoteApprovalInput quoteForApproval = new QuoteFlowActions.QuoteApprovalInput();
		quoteForApproval.opportunityId = opportunity.Id;
        quoteForApproval.opportunityOwnerFullName = user.FirstName + ' ' + user.LastName;
        quoteForApproval.opportunityOwnerTitle = user.Profile.Name;
        quoteForApproval.opportunityOwnerEmail = user.Email;
        quoteForApproval.accountCompanyEmail = null;
        quoteForApproval.branchNumber = branch.T_C_Branch_Number__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteId = quote.Id;
        
        quoteList.add(quoteForApproval);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GraphqlCalloutMock());
        List<Object> results = QuoteFlowActions.SendQuoteForApproval(quoteList);
   		Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void SendQuoteForReviewNoTradeCommBranchNumberSuccessTest () {
        User user = TestUtil.createTradeCommSalesRep();
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        insert branch;

        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Company_Email__c = 'test_company_email@email.com';
        account.Branch__c = branch.Id;
        insert account;


        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', account.Id, user.Id, true); 
       
        Quote quote = TestUtil.createQuote(opportunity.Id, false);        
        quote.Quote_Number_PQM__c = '123456';
        insert quote;
        
        List<QuoteFlowActions.QuoteApprovalInput> quoteList = new List<QuoteFlowActions.QuoteApprovalInput>();
       
        QuoteFlowActions.QuoteApprovalInput quoteForApproval = new QuoteFlowActions.QuoteApprovalInput();
		quoteForApproval.opportunityId = opportunity.Id;
        quoteForApproval.opportunityOwnerFullName = user.FirstName + ' ' + user.LastName;
        quoteForApproval.opportunityOwnerTitle = user.Profile.Name;
        quoteForApproval.opportunityOwnerEmail = user.Email;
        quoteForApproval.accountCompanyEmail = null;
        quoteForApproval.branchNumber = branch.T_C_Branch_Number__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteId = quote.Id;
        
        quoteList.add(quoteForApproval);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GraphqlCalloutMock());
        List<Object> results = QuoteFlowActions.SendQuoteForApproval(quoteList);
   		Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void SendQuoteForReviewLeadExistsTest () {
        User user = TestUtil.createTradeCommSalesRep();
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c = '456';
        insert branch;

        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Company_Email__c = 'test_company_email@email.com';
        account.Branch__c = branch.Id;
        insert account;

        Contact contact = TestUtil.createContact(account.Id, 'Test_Contact', true); 
        
        Lead lead = TestUtil.createLead('Some', 'Test_User', false);
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        lead.Lead_Type__c = 'Commercial Builder/GC';
        lead.Street = '1234 Test Rd.';
        lead.City = 'Test City';
        lead.State = 'UT';
        lead.PostalCode = '12345';       
        insert lead;
  
        Database.LeadConvert leadConvert = new database.LeadConvert();
        leadConvert.setLeadId(lead.id);
        leadConvert.setDoNotCreateOpportunity(false);
        leadConvert.setAccountId(account.Id);
        leadConvert.setContactId(contact.Id);
        leadConvert.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
        
        System.assert(leadConvertResult.isSuccess());
        
        Lead leadRecord = [SELECT Id, Name, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId FROM Lead WHERE Id =: lead.Id];

		Quote quote = TestUtil.createQuote(leadRecord.ConvertedOpportunityId, false);        
        quote.Quote_Number_PQM__c = '123456';
        insert quote;
         
        List<QuoteFlowActions.QuoteApprovalInput> quoteList = new List<QuoteFlowActions.QuoteApprovalInput>();
       
        QuoteFlowActions.QuoteApprovalInput quoteForApproval = new QuoteFlowActions.QuoteApprovalInput();
		quoteForApproval.opportunityId = leadRecord.ConvertedOpportunityId;
        quoteForApproval.opportunityOwnerFullName = user.FirstName + ' ' + user.LastName;
        quoteForApproval.opportunityOwnerTitle = user.Profile.Name;
        quoteForApproval.opportunityOwnerEmail = user.Email;
        quoteForApproval.accountCompanyEmail = account.Company_Email__c;
        quoteForApproval.branchNumber = branch.T_C_Branch_Number__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteId = quote.Id;
        quoteForApproval.leadId = lead.Id;
         
        quoteList.add(quoteForApproval);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GraphqlCalloutMock());
        List<Object> results = QuoteFlowActions.SendQuoteForApproval(quoteList);
   		Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void SendQuoteForReviewLeadIsNullTest () {
        User user = TestUtil.createTradeCommSalesRep();
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c = '456';
        insert branch;

        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Company_Email__c = 'test_company_email@email.com';
        account.Branch__c = branch.Id;
        insert account;

  		Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', account.Id, user.Id, true); 
        Contact contact = TestUtil.createContact(account.Id, 'Test_Contact', true); 

		Quote quote = TestUtil.createQuote(opportunity.Id, false);        
        quote.Quote_Number_PQM__c = '123456';
        insert quote;
         
        List<QuoteFlowActions.QuoteApprovalInput> quoteList = new List<QuoteFlowActions.QuoteApprovalInput>();
       
        QuoteFlowActions.QuoteApprovalInput quoteForApproval = new QuoteFlowActions.QuoteApprovalInput();
		quoteForApproval.opportunityId = opportunity.Id;
        quoteForApproval.opportunityOwnerFullName = user.FirstName + ' ' + user.LastName;
        quoteForApproval.opportunityOwnerTitle = user.Profile.Name;
        quoteForApproval.opportunityOwnerEmail = user.Email;
        quoteForApproval.accountCompanyEmail = account.Company_Email__c;
        quoteForApproval.branchNumber = branch.T_C_Branch_Number__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteId = quote.Id;
        quoteForApproval.leadId = null;
         
        quoteList.add(quoteForApproval);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GraphqlCalloutMock());
        List<Object> results = QuoteFlowActions.SendQuoteForApproval(quoteList);
   		Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void SendQuoteForReviewErrorTest () {
        User user = TestUtil.createTradeCommSalesRep();
		Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c = '456';
        insert branch;

        Account account = TestUtil.createBranchAccount('Branch Account', false);
        account.Company_Email__c = 'test_company_email@email.com';
        account.Branch__c = branch.Id;
        insert account;


        Opportunity opportunity = TestUtil.createOpportunity('New Test Opp One', account.Id, user.Id, true); 
       
        Quote quote = TestUtil.createQuote(opportunity.Id, false);        
        quote.Quote_Number_PQM__c = '482167';
        insert quote;
        
        List<QuoteFlowActions.QuoteApprovalInput> quoteList = new List<QuoteFlowActions.QuoteApprovalInput>();
       
        QuoteFlowActions.QuoteApprovalInput quoteForApproval = new QuoteFlowActions.QuoteApprovalInput();
		quoteForApproval.opportunityId = opportunity.Id;
        quoteForApproval.opportunityOwnerFullName = user.FirstName + ' ' + user.LastName;
        quoteForApproval.opportunityOwnerTitle = user.Profile.Name;
        quoteForApproval.opportunityOwnerEmail = user.Email;
        quoteForApproval.accountCompanyEmail = account.Company_Email__c;
        quoteForApproval.branchNumber = branch.T_C_Branch_Number__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteNumber = quote.Quote_Number_PQM__c;
        quoteForApproval.quoteId = quote.Id;        
         
        quoteList.add(quoteForApproval);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GraphqlCalloutErrorMock());

        try {
        	List<Object> results = QuoteFlowActions.SendQuoteForApproval(quoteList);
        } catch (Exception e) {
            System.assertEquals('SendQuoteForApproval Graphql Error', e.getMessage());
        }

   		Test.stopTest();
        
        List<Apex_Debug_Log__c> logs = [
            SELECT Id, Name, Apex_Class__c, Method__c 
            FROM Apex_Debug_Log__c ORDER BY CreatedDate DESC 
            LIMIT 5 
        ];
       	Apex_Debug_Log__c topLog = logs[0];
        
        System.assertEquals('QuoteFlowActions', topLog.Apex_Class__c);
        System.assertEquals('SendQuoteForApproval Graphql Error', topLog.Method__c);
    }
}