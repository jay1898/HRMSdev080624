@isTest
public class ProductSearchControllerTest {
    
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

        Case caseObj = testUtil.createCase(con.Id, acc.Id, branch.Id, false, 'New', 'Email', 'Test Subject');
        insert caseObj;
        
        Address__c addressObj = TestUtil.createAddress(true);
        Account_Branch_Profile__c branchProfileObj = TestUtil.createAccountBranchProfile(acc.Id, branch.Id, true);
        Address_Assignment__c addAssignmentObj = TestUtil.createAddressAssignment(addressObj.Id, branchProfileObj.Id, false);
        addAssignmentObj.Account__c = acc.Id;
        insert addAssignmentObj;       
    }

    @IsTest
    static void getAllAddressesTest(){
        Case cse = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        Test.startTest();
          List<ProductSearchController.ProductAddress> testAddresses = ProductSearchController.getAllAdressesByCaseId(cse.Id);
          Assert.areEqual(1, testAddresses.size(), 'Expected One Address value');
        Test.stopTest();        
    }

    @IsTest
    static void getUserSettingsTest(){
        Test.startTest();
          User_Component_Setting__c userCompSettings = ProductSearchController.getUserSettings('[{"label":"Serial Number","fieldName":"serialNo","visible":true,"upBool":false,"dwBool":false},{"label":"Customer PO Number","fieldName":"customerPONumber","visible":true,"upBool":false,"dwBool":false},{"label":"PO Line Number","fieldName":"orderLineNumber","visible":true,"upBool":false,"dwBool":false},{"label":"Room Location","fieldName":"roomLocation","visible":true,"upBool":false,"dwBool":false},{"label":"Shipped Date","fieldName":"shippedDate","visible":true,"upBool":false,"dwBool":false},{"label":"Ordered Date","fieldName":"orderDate","visible":true,"upBool":false,"dwBool":false},{"label":"Installed Date","fieldName":"installDate","visible":true,"upBool":false,"dwBool":false},{"label":"PO Item Description","fieldName":"itemDescription","visible":true,"upBool":false,"dwBool":false},{"label":"Brand","fieldName":"brand","visible":true,"upBool":false,"dwBool":false},{"label":"Config Type","fieldName":"configType","visible":false,"upBool":false,"dwBool":false},{"label":"Frame Height","fieldName":"frameHeight","visible":true,"upBool":false,"dwBool":false},{"label":"Frame Width","fieldName":"frameWidth","visible":true,"upBool":false,"dwBool":false},{"label":"Quantity","fieldName":"orderLineQuantity","visible":true,"upBool":false,"dwBool":false},{"label":"PO Quote Line Number","fieldName":"quoteLineNumber","visible":true,"upBool":false,"dwBool":false},{"label":"Interior Color","fieldName":"interiorColor","visible":true,"upBool":false,"dwBool":false},{"label":"Exterior Color","fieldName":"exteriorColor","visible":true,"upBool":false,"dwBool":false},{"label":"Product","fieldName":"product","visible":true,"upBool":false,"dwBool":false},{"label":"Manufacturing System Sales Order Number","fieldName":"manufacturingSystemSalesOrderNumber","visible":false,"upBool":false,"dwBool":false},{"label":"Manufacturing System Sales Order Line Number","fieldName":"manufacturingSystemSalesOrderLineNumber","visible":false,"upBool":false,"dwBool":false},{"label":"Installed At Address","fieldName":"installAddress","visible":false,"upBool":false,"dwBool":false},{"label":"Current Owner","fieldName":"currentOwner","visible":false,"upBool":false,"dwBool":false}]');
          Assert.areNotEqual(null, userCompSettings, 'Expected User Component Settings');

          User_Component_Setting__c userCompSettingsUpdate = ProductSearchController.updateUserSettings('[{"label":"Serial Number","fieldName":"serialNo","visible":true,"upBool":false,"dwBool":false},{"label":"Customer PO Number","fieldName":"customerPONumber","visible":false,"upBool":false,"dwBool":false},{"label":"PO Line Number","fieldName":"orderLineNumber","visible":false,"upBool":false,"dwBool":false},{"label":"Room Location","fieldName":"roomLocation","visible":true,"upBool":false,"dwBool":false},{"label":"Shipped Date","fieldName":"shippedDate","visible":true,"upBool":false,"dwBool":false},{"label":"Ordered Date","fieldName":"orderDate","visible":true,"upBool":false,"dwBool":false},{"label":"Installed Date","fieldName":"installDate","visible":true,"upBool":false,"dwBool":false},{"label":"PO Item Description","fieldName":"itemDescription","visible":true,"upBool":false,"dwBool":false},{"label":"Brand","fieldName":"brand","visible":true,"upBool":false,"dwBool":false},{"label":"Config Type","fieldName":"configType","visible":false,"upBool":false,"dwBool":false},{"label":"Frame Height","fieldName":"frameHeight","visible":true,"upBool":false,"dwBool":false},{"label":"Frame Width","fieldName":"frameWidth","visible":true,"upBool":false,"dwBool":false},{"label":"Quantity","fieldName":"orderLineQuantity","visible":true,"upBool":false,"dwBool":false},{"label":"PO Quote Line Number","fieldName":"quoteLineNumber","visible":true,"upBool":false,"dwBool":false},{"label":"Interior Color","fieldName":"interiorColor","visible":true,"upBool":false,"dwBool":false},{"label":"Exterior Color","fieldName":"exteriorColor","visible":true,"upBool":false,"dwBool":false},{"label":"Product","fieldName":"product","visible":true,"upBool":false,"dwBool":false},{"label":"Manufacturing System Sales Order Number","fieldName":"manufacturingSystemSalesOrderNumber","visible":false,"upBool":false,"dwBool":false},{"label":"Manufacturing System Sales Order Line Number","fieldName":"manufacturingSystemSalesOrderLineNumber","visible":false,"upBool":false,"dwBool":false},{"label":"Installed At Address","fieldName":"installAddress","visible":false,"upBool":false,"dwBool":false},{"label":"Current Owner","fieldName":"currentOwner","visible":false,"upBool":false,"dwBool":false}]');
          Assert.areNotEqual(userCompSettings.Setting_JSON__c, userCompSettingsUpdate.Setting_JSON__c, 'Expected User Component Settings Updated');
        Test.stopTest();        
    }

    @IsTest
    static void getLastSearchedItemsTest(){
        Test.startTest();
          User_Component_Setting__c userCompSettings = ProductSearchController.getLastSearchedItems('Serial Number');
          Assert.areEqual('Product Search Term', userCompSettings.Component__c, 'Expected Component as Product Search Term');

          User_Component_Setting__c userCompSettingsUpdate = ProductSearchController.updateSearchTermUserSettings('Serial Number','Test 2');
          Assert.areEqual('Test 2', userCompSettingsUpdate.Setting_JSON__c, 'Expected updated last search items');
        Test.stopTest();        
    }    
}