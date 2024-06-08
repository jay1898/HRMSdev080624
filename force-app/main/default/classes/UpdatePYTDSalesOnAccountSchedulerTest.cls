@isTest
public class UpdatePYTDSalesOnAccountSchedulerTest {
    public static testMethod void executeUpdatePYTDSalesOnAccount(){
        Test.startTest();       
        System.schedule('Update Account PYTD Field Test', '0 0 1 * * ? *', new UpdatePYTDSalesOnAccountScheduler());  
        Test.stopTest();
        
        CronTrigger scheduledJob = [SELECT Id, CronJobDetailId, CronJobDetail.Name, State, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'Update Account PYTD Field Test' LIMIT 1];
        
        System.assertNotEquals(null, scheduledJob);
   }
}