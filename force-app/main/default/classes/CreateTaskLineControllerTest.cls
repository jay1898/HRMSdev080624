/**
* @description       : CreateTaskLineControllerTest Test class for CreateTaskLineController
* @author            : Balaji Ravindran | mailto:ravindramb@evergegroup.com
* History   
* Ver   Date         Author            Modification
* 1.0   30-05-2023   Balaji Ravindran  Initial Version()
**/
@isTest
public class CreateTaskLineControllerTest {

    @TestSetup
    static void makeData(){

        Account acc = TestUtil.createBranchAccount('Pro_Lowes', false);
        acc.BillingCity = 'City';
        acc.BillingStreet = 'Test Street';
        acc.BillingState = 'State';
        acc.BillingPostalCode = '123456';
        insert acc;

        Contact con = TestUtil.createContact(acc.Id, 'TestContact', true);

        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        WorkType wt = TestUtil.createWorkType('WT1', 'OV', 'Hours', 2,true);

        Case caseObj       = new Case();
        caseObj.Status     = 'New';
        caseObj.Origin     = 'Email';
        caseObj.ContactId  = con.Id;
        caseObj.AccountId  = acc.Id;
        caseObj.AssignedBranch__c = branch.Id;
       // caseObj.Assigned_Branch__c = 'Chicago';
        caseObj.Business_Segment__c = 'Trade';
        caseObj.Sales_Channel__c = 'Ecommerce';
        caseObj.Subject = 'Test Subject';
        caseObj.Cc_Other_Email_Addresses__c = 'test001@gmail.com';
        insert caseObj;

    }
    
    @IsTest
    static void createProductServicedLineTest(){
        List<ProductSearchTableResponse> wrapperList 	= new List<ProductSearchTableResponse>();
        ProductSearchTableResponse wrapper = new ProductSearchTableResponse();
        ProductSearchTableResponse.SerialNo serialDescription = new ProductSearchTableResponse.SerialNo();
        serialDescription.value = 'Frame';
        ProductSearchTableResponse.SerialNo serialProduct = new ProductSearchTableResponse.SerialNo();
        serialProduct.value = 'Awning';
        ProductSearchTableResponse.SerialNo serialBrand = new ProductSearchTableResponse.SerialNo();
        serialDescription.value = 'Architect Series';
        ProductSearchTableResponse.cls_warranties warrantyObj = new ProductSearchTableResponse.cls_warranties();
        ProductSearchTableResponse.cls_value valueObj = new ProductSearchTableResponse.cls_value();
        valueObj.externalId = '123233';
        valueObj.isTransferable = true;
        ProductSearchTableResponse.cls_contractAddress addressObj = new ProductSearchTableResponse.cls_contractAddress();
        addressObj.address1 = 'test';
        addressObj.address2 = 'test';
        addressObj.city     = 'test';
        addressObj.country  = 'test';
        addressObj.postalCode = '111111';
        addressObj.state      = 'test';
        valueObj.contractAddress = addressObj;        
        warrantyObj.value = new List<ProductSearchTableResponse.cls_value>{valueObj};
        wrapper.warranties = warrantyObj;
        wrapper.selectedComponent = 'Frame';
        wrapper.selectedIssue = 'Test';
        wrapper.description = serialDescription;
        wrapper.product = serialProduct;
        wrapper.brand = serialBrand;
        

        Map<String, String> rowValueMap = new Map<String, String>();
        rowValueMap.put('description', 'Test Subject');
        rowValueMap.put('brand', 'Test Brand');
        rowValueMap.put('product', 'Test Product');
		wrapperList.add(wrapper);
        Test.startTest();
            Case cs = [Select Id from Case limit 1];
            List<Case_Line__c> caseLine = CreateTaskLineController.createCaseLine(cs.Id,JSON.serialize(wrapperList)); //   JSON.serialize(new List<Map<String, String>>{rowValueMap}));
        	CreateTaskLineController.createLaborCaseLine(cs.Id,JSON.serialize(wrapperList), JSON.serialize(caseLine));
        Test.stopTest();
        // confirm that 'Product Serviced' Case Line was created with correct values
        list <Case_Line__c> insertedProductServicedLines = [Select Id, RecordType.Name, Component__c, Product__c FROM Case_Line__c WHERE Case__c = :cs.Id AND RecordType.Name = 'Product Serviced'];
        system.assertEquals(insertedProductServicedLines[0].Product__c, 'Awning');
        system.assertEquals(insertedProductServicedLines[0].Component__c, 'Frame');
        
        // confirm that 'Labor' Case Line was created, connected to Product Serviced line, with no product/issue values 
        list <Case_Line__c> insertedLaborLines = [Select Id, Product_Serviced__c, RecordType.Name, Component__c, Product__c FROM Case_Line__c WHERE Case__c = :cs.Id AND RecordType.Name = 'Labor'];
        system.assertEquals(insertedLaborLines[0].Product__c, null);
        system.assertEquals(insertedLaborLines[0].Product_Serviced__c, insertedProductServicedLines[0].Id);   
    }
}