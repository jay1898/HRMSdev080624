@isTest
public class TestSalesQuota {
	@isTest 
    static void TestSalesQuotaUpdate() {
        Sales_Plan__c salesPlan = new Sales_Plan__c(Name='Test Plan');
        insert salesPlan;
        
        Test.startTest();
        Sales_Quota__c salesQuota = new Sales_Quota__c(Sales_Plan__c=salesPlan.id, Month__c = 'January', Quota_Amount__c = 5555);
        insert salesQuota;
        Test.stopTest();
    }
}