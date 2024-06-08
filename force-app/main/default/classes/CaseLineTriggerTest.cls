@isTest
public class CaseLineTriggerTest {

    static Case caseObj; // Declare caseObj at the class level
    static Branch__c br; // Declare br at the class level

    @TestSetup
    static void makeData() {
        // Create test data
        Account accountObj = TestUtil.createBranchAccount('Pella Account', false);
        accountObj.BillingPostalCode = '12345'; 
        insert accountObj;
        
        Contact contactObj = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.MailingPostalCode = '12345';
        insert contactObj;
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        br = TestUtil.createBranch('Albany', 'Albany', bf.Id, true);
        br.Task_Billing_Method__c = 'Bill by Task Labor';
        update br;
        
        caseObj = new Case();
        caseObj.AssignedBranch__c = br.Id;
        insert caseObj;
        
        Service_Labor_Rate__c laborRates = new Service_Labor_Rate__c();
        laborRates.Branch__c = br.Id;
        laborRates.TaskType__c = 'Check Request';
        laborRates.LaborCost__c = 150;
        laborRates.Type__c = 'Flat Rate';
        insert laborRates;
        
        Service_Action_Labor_Cost__c servAction = new Service_Action_Labor_Cost__c();
        servAction.BaseCost__c = 10;
        servAction.Service_Action__c = 'Battery Replacement';
        insert servAction; 
        
        Brand_Labor_Cost__c brandCost = new Brand_Labor_Cost__c();
        brandCost.Brand__c = 'Insynctive';
        brandCost.CostMultiplier__c = 4;
        insert brandCost; 
        
        Product_Labor_Cost__c productCost = new Product_Labor_Cost__c();
        productCost.Product__c = 'Awning';
        productCost.BaseCost__c = 20;
        insert productCost;
        
        Service_Action_Estimate__c servActionEstimate = new Service_Action_Estimate__c();
        servActionEstimate.Estimated_Minutes__c = 120;
        servActionEstimate.Number_of_Techs__c = 1;
        servActionEstimate.Brand__c = brandCost.Id;
        servActionEstimate.Service_Action__c = servAction.Id;
        insert servActionEstimate; 
        
        RecordType productServiced = [Select Id FROM RecordType WHERE Name = 'Product Serviced' AND SObjectType = 'Case_Line__c' limit 1];
        Case_Line__c caseLineRecord = new Case_Line__c();
        caseLineRecord.Case__c = caseObj.Id;
        caseLineRecord.Branch__c = br.Id;
        caseLineRecord.Task_Type__c = 'Check Request';
        caseLineRecord.Service_Action__c = 'Battery Replacement';
        caseLineRecord.Brand__c = 'Insynctive';
        caseLineRecord.Product__c = 'Awning';
        caseLineRecord.RecordTypeId = productServiced.Id;
        insert caseLineRecord;
        
        RecordType laborRec = [Select Id FROM RecordType WHERE Name = 'Labor' AND SObjectType = 'Case_Line__c' limit 1];
        Case_Line__c caseLineRecordLabor = new Case_Line__c();
        caseLineRecordLabor.Case__c = caseObj.Id;
        caseLineRecordLabor.Branch__c = br.Id;
        caseLineRecordLabor.Task_Type__c = 'Check Request';
        caseLineRecordLabor.Service_Action__c = 'Battery Replacement';
        caseLineRecordLabor.RecordTypeId = laborRec.Id;
        caseLineRecordLabor.Product_Serviced__c = caseLineRecord.Id;
        caseLineRecordLabor.Quantity__c = 1;
        insert caseLineRecordLabor;
    }

    @isTest
    public static void testCalculatorFlatRateEstimate() {
        // Retrieve the created Case_Line__c record with the related Branch__r field
        Case_Line__c caseLineRecord = [SELECT Id, Branch__c, Branch__r.Task_Billing_Method__c, Task_Type__c, Service_Action__c,Labor_Cost__c
                                       FROM Case_Line__c WHERE RecordType.Name = 'Labor' LIMIT 1];
        
        Test.startTest();
        // Perform the specific operation or invoke the method under test
        CaseLineTriggerHandlerService.calculatorLaborEstimate(new List<Case_Line__c>{ caseLineRecord });
        Test.stopTest();
        
        // Confirm price is 300 based on flat rate logic
        Case_Line__c newCaseLineRecord = [SELECT Id, Task_Billing_Method__c, Line_Price__c FROM Case_Line__c WHERE Id = :caseLineRecord.Id];
         System.assertEquals(150, newCaseLineRecord.Line_Price__c);
        System.assertEquals('Flat Rate', newCaseLineRecord.Task_Billing_Method__c);

    }
    
    @isTest
    public static void testCalculatorHourlyLaborEstimate() {
        List <Branch__c> testBranch = [Select Task_Billing_Method__c FROM Branch__c WHERE Name = 'Albany'];
        testBranch[0].Task_Billing_Method__c = 'Bill by Hourly Rate';
        update testBranch[0];
        
        
        List <Service_Labor_Rate__c> testLaborRate = [Select Type__c FROM Service_Labor_Rate__c];
        testLaborRate[0].Type__c = 'Hourly Labor';
        update testLaborRate[0];
        
        // Retrieve the created Case_Line__c record with the related Branch__r field
        Case_Line__c caseLineRecord = [SELECT Id, Branch__c, Branch__r.Task_Billing_Method__c, Task_Type__c, Service_Action__c,Labor_Cost__c
                                       FROM Case_Line__c WHERE RecordType.Name = 'Labor' LIMIT 1];
        
        Test.startTest();
        // Perform the specific operation or invoke the method under test
        CaseLineTriggerHandlerService.calculatorLaborEstimate(new List<Case_Line__c>{ caseLineRecord });
        Test.stopTest();
        
        // Confirm price is 300 based on hourly logic
        Case_Line__c newCaseLineRecord = [SELECT Id, Task_Billing_Method__c, Line_Price__c FROM Case_Line__c WHERE Id = :caseLineRecord.Id];
         System.assertEquals(300, newCaseLineRecord.Line_Price__c);
        System.assertEquals('Hourly Labor', newCaseLineRecord.Task_Billing_Method__c);
    } 
    
    @isTest
    public static void testCalculatorByTask() {
        List <Service_Labor_Rate__c> testRate = [Select Id FROM Service_Labor_Rate__c];
        delete testRate[0];
        
        // Retrieve the created Case_Line__c record with the related Branch__r field
        Case_Line__c caseLineRecord = [SELECT Id, Branch__c, Branch__r.Task_Billing_Method__c, Task_Type__c, Service_Action__c,Labor_Cost__c
                                       FROM Case_Line__c WHERE RecordType.Name = 'Labor' LIMIT 1];
        
        Test.startTest();
        // Perform the specific operation or invoke the method under test
        CaseLineTriggerHandlerService.calculatorLaborEstimate(new List<Case_Line__c>{ caseLineRecord });
        Test.stopTest();
        
        // Confirm line price is 120 based on Task logic
        Case_Line__c newCaseLineRecord = [SELECT Id, Task_Billing_Method__c, Line_Price__c FROM Case_Line__c WHERE Id = :caseLineRecord.Id];
         System.assertEquals(120, newCaseLineRecord.Line_Price__c);
    }
}