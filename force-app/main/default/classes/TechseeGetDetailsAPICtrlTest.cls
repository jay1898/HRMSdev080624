@isTest
public class TechseeGetDetailsAPICtrlTest {
    
    @TestSetup
    static void makeData(){
        Case caseObj        = new Case();
        caseObj.Status      = 'Pending';
        caseObj.Origin      = 'Tech See';
        caseObj.TechSee_Request_Id__c = '123';
        insert caseObj;
        Techsee_API_Details__c apiCSObj     = new Techsee_API_Details__c(API_Key__c = '123', API_Secret__c = '123', Endpoint_URL_Auth__c = 'https://pellaint-api.techsee.me/auth/json', Endpoint_URL_Case_Data__c = 'https://pellaint-api.techsee.me/public/vj/history');
        insert apiCSObj;
    }


    @isTest
    static void testTechseeDetails() {
        Test.setMock(HttpCalloutMock.class, new TechseeMockResponseGenrator());
        Test.startTest();
        TechseeGetDetailsAPIController.getDataFromTechsee([Select Id from Case LIMIT 1].Id);
        Test.stopTest();
    }
}