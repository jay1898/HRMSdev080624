@isTest
public class UnlockTimeBlockBatchTest 
{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    @isTest
    public static void RTAIntegrationTest1(){
      
        RTA_Timeblock__c TimeBlock=TestUtil.createRTATimeBlock('12345',false);
        insert Timeblock;
        Test.setCreatedDate(Timeblock.Id, DateTime.now().addHours(-1));

        Test.startTest();
        UnlockTimeBlockBatch BatchApex = new UnlockTimeBlockBatch();  
        DataBase.executeBatch(BatchApex);
        
        String jobId = System.schedule('OppCommAlertBatchTest', CRON_EXP, new UnlockTimeBlockBatch());
        
        Test.stopTest();
    }
    
   
   
}