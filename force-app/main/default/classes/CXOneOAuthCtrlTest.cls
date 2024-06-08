@IsTest
public class CXOneOAuthCtrlTest {

    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new CXOneOAuthCtrlMock());
        Test.startTest();
        CallDetailsWrapper respWrap = CXOneOAuthController.getCallDetails();
        System.assert.areEqual('test', respWrap.skill);
        Test.stopTest();
    }
}