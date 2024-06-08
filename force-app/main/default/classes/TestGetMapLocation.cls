@isTest
public class TestGetMapLocation {
     @testSetup
    static void dataSetup() {
        
        callFutureMethodData();
    
    }
    
    @future
    public static  void callFutureMethodData(){
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity objOpp = TestUtil.createOpportunity('New Opp1', ac.Id, UserInfo.getUserId(), false);
        insert objOpp;
    }
    private static testMethod void callFutureMethod() {        
        Opportunity objOppRecords=[SELECT Id, Street__c,City__c,State__c,Country__c,Zipcode__c FROM Opportunity WHERE Name = 'New Opp1'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetMapLocationCalloutMock());
        GetMapLocation.getLongitde_Latitude(objOppRecords.Id);  
        Test.stopTest();
        
    }    
}