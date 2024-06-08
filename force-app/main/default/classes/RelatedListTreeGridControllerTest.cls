@isTest
public class RelatedListTreeGridControllerTest {
    
    @TestSetup
    static void makeData(){

        Account acc = TestUtil.createAccount('Person Account', false);
        acc.BillingCity = 'City';
        acc.BillingStreet = 'Test Street';
        acc.BillingState = 'State';
        acc.BillingPostalCode = '123456';
        insert acc;

        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);

        Case caseObj        = new Case();
        caseObj.Status      = 'Pending';
        caseObj.Origin      = 'Email';
        caseObj.AccountId  = acc.Id;
        caseObj.Business_Segment__c = 'Trade';
        caseObj.Sales_Channel__c = 'Ecommerce';
        caseObj.Subject = 'Test Subject';
        caseObj.AssignedBranch__c = branch.Id;
        caseObj.Cc_Other_Email_Addresses__c = 'test001@gmail.com';
        insert caseObj;

        Address__c addressObj 	= TestUtil.createAddress(true);
        Account_Branch_Profile__c branchProfileObj 	= TestUtil.createAccountBranchProfile(acc.Id, branch.Id, true);
        Address_Assignment__c addAssignmentObj = TestUtil.createAddressAssignment(addressObj.Id, branchProfileObj.Id, false);
        addAssignmentObj.Account__c 	= acc.Id;
        insert addAssignmentObj;
        
    }

    @isTest public static void testInit(){
	
        Case caseObj = [Select Id, CaseNumber from Case Limit 1];

        Address_Assignment__c addressObj = [Select Id, Address__r.Street__c , Address__r.City__c , Address__r.State__c , Address__r.Country__c , Address__r.Zipcode__c from Address_Assignment__c Limit 1];

        List<Case_Line__c> caseLineList = new List<Case_Line__c>();
        Case_Line__c caseLine = new Case_Line__c();
        caseLine.Case__c = caseObj.Id;
        caseLine.Brand__c = 'Architect Series';
        caseLine.Description__c = 'Test Description';
        caseLine.Component__c = 'Product Search Warranty';
        caseLine.Product__c = 'Awning';
        caseLine.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Product Serviced').getRecordTypeId();
        caseLine.Task_Billing_Method__c = 'Flat Rate';
        caseLineList.add(caseLine);
        
        Case_Line__c caseLine1 = new Case_Line__c();
        caseLine1.Case__c = caseObj.Id;
        caseLine1.Brand__c = 'Architect Series';
        caseLine1.Description__c = 'Test Description';
        caseLine1.Component__c = 'Product Search Warranty';
        caseLine1.Product__c = 'Awning';
        caseLine1.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Labor').getRecordTypeId();
        caseLine1.Task_Billing_Method__c = 'Flat Rate';
        caseLineList.add(caseLine1);
        
        Case_Line__c caseLine2 = new Case_Line__c();
        caseLine2.Case__c = caseObj.Id;
        caseLine2.Brand__c = 'Architect Series';
        caseLine2.Description__c = 'Test Description';
        caseLine2.Component__c = 'Product Search Warranty';
        caseLine2.Product__c = 'Awning';
        caseLine2.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        caseLine2.Task_Billing_Method__c = 'Flat Rate';
        caseLineList.add(caseLine2);
        
        Case_Line__c caseLine3 = new Case_Line__c();
        caseLine3.Case__c = caseObj.Id;
        caseLine3.Brand__c = 'Architect Series';
        caseLine3.Description__c = 'Test Description';
        caseLine3.Component__c = 'Product Search Warranty';
        caseLine3.Product__c = 'Awning';
        caseLine3.RecordTypeId = Schema.SObjectType.Case_Line__c.getRecordTypeInfosByName().get('Parts').getRecordTypeId();
        caseLine3.Task_Billing_Method__c = 'Flat Rate';
        caseLineList.add(caseLine3);
        insert caseLineList;
                
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put(RelatedListTreeGridController.FIELDS_PARAM, 'Name, Case__c, Task_Billing_Method__c, Brand__c, Product__c, Quantity__c, Labor_Cost__c, Branch__c, Description__c, Issue__c, Component__c, Discount__c, Discount_Reason__c, Warranty__c, Unit_Price_Low__c, Unit_Price_High__c, Product_Serviced__c, Product_Serviced__r.Name, Line_Price_Low__c, Line_Price_High__c, Tax_Low__c, Tax_High__c, Billable_Line_Price_Low__c, Billable_Line_Price_High__c, Available_Date__c');
        requestMap.put(RelatedListTreeGridController.RELATED_FIELD_API_NAME_PARAM, 'Case');
        requestMap.put(RelatedListTreeGridController.RECORD_TYPE_PARAM, '');
        requestMap.put(RelatedListTreeGridController.RECORD_ID_PARAM, caseObj.Id);
        requestMap.put(RelatedListTreeGridController.NUMBER_OF_RECORDS_PARAM, 1);
        requestMap.put(RelatedListTreeGridController.SOBJECT_API_NAME_PARAM, 'Case_Line__c');
        requestMap.put(RelatedListTreeGridController.SORTED_BY_PARAM, 'Name');
        requestMap.put(RelatedListTreeGridController.SORTED_DIRECTION_PARAM, 'ASC');
                
        String jsonData = RelatedListTreeGridController.initData(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(RelatedListTreeGridController.RECORDS_PARAM);
        System.assert(!records.isEmpty());
        String iconName = (String)responseMap.get(RelatedListTreeGridController.ICON_NAME_PARAM);
        System.assert(String.isNotBlank(iconName));
        List<String> caseLineIdList 	= new List<String>();
        for(Case_Line__c caseLineObj : [Select Id from Case_Line__c]) {
            caseLineIdList.add(caseLineObj.Id);
        }
        
        // String workOrderId = RelatedListTreeGridController.generateWorkOrder(caseLineIdList, '');
        // Assert.areNotEqual(null, workOrderId, 'Expected Work Order Id'); // Succeeds

        String workOrderId = RelatedListTreeGridController.generateWorkOrder(caseLineIdList, addressObj.Id);
        Assert.areNotEqual(null, workOrderId, 'Expected Work Order Id'); // Succeeds

        String oppId = RelatedListTreeGridController.generateProductRequest(caseLineIdList);
        Case cse = [Select Id, Opportunity__c from Case Where Id =: caseObj.Id];
        Assert.areEqual(cse.Opportunity__c, oppId, 'Expected same Opportunity Id'); // Succeeds
    }

    @isTest 
    public static void getRelatedAddressesTest(){

        Case caseObj = [Select Id, CaseNumber from Case Limit 1];
        
        RelatedListTreeGridController.getRelatedAddresses(caseObj.Id);

        Account acc = TestUtil.createBranchAccount('Pro_Lowes', false);
        acc.BillingCity = '123 City';
        acc.BillingStreet = '123 Street';
        acc.BillingState = '123 State';
        acc.BillingPostalCode = '654321';
        insert acc;

        Contact con = TestUtil.createContact(acc.Id, 'Test456Contact', true);

        Branch__c branch = [Select Id, Name from Branch__c Limit 1];

        Case caseObjNew       = new Case();
        caseObjNew.Status     = 'New';
        caseObjNew.Origin     = 'Email';
        caseObjNew.ContactId  = con.Id;
        caseObjNew.AccountId  = acc.Id;
        caseObjNew.AssignedBranch__c = branch.Id;
        caseObjNew.Business_Segment__c = 'Trade';
        caseObjNew.Sales_Channel__c = 'Ecommerce';
        caseObjNew.Subject = 'Test Subject';
        caseObjNew.Cc_Other_Email_Addresses__c = 'test001@gmail.com';
        insert caseObjNew;

        Address__c addressObj 	= TestUtil.createAddress(false);
        addressObj.Street__c = '123 Street';
        addressObj.City__c = '123 City';
        addressObj.State__c = '123 State';
        addressObj.Zipcode__c = '654321';
        insert addressObj;

        Account_Branch_Profile__c branchProfileObj 	= TestUtil.createAccountBranchProfile(acc.Id, branch.Id, true);
        Address_Assignment__c addAssignmentObj = TestUtil.createAddressAssignment(addressObj.Id, branchProfileObj.Id, false);
        addAssignmentObj.Account__c 	= acc.Id;
        insert addAssignmentObj;

        RelatedListTreeGridController.getRelatedAddresses(caseObjNew.Id);
    }
}