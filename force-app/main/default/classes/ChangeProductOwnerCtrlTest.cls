@isTest
public class ChangeProductOwnerCtrlTest {

    @TestSetup
    static void makeData(){
    }
    
    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ChangeProductOwnerController.updateProductOwner(new List<String>{'test'}, 'test');
        Test.stopTest();
    }
}