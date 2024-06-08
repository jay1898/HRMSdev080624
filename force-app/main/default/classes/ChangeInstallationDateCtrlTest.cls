@isTest
public class ChangeInstallationDateCtrlTest {

    @TestSetup
    static void makeData(){
    }
    
    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new ProductSearchOrderAPIBySerialNumberMock());
        Test.startTest();
        ChangeInstallationDateController.updateInstallationDate(new List<String>{'test'}, '18/10/2023');
        Test.stopTest();
    }
}