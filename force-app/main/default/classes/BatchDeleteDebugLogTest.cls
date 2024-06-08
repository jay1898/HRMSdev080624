@isTest 
public class BatchDeleteDebugLogTest
{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void DeleteDebugLog()
    {
         Apex_Debug_Log__c DL = TestUtil.createApexDebugLog(true);
        Test.setCreatedDate(DL.Id, DateTime.now().addMonths(-2));

        Test.startTest();
        BatchDeleteDebugLog obj = new BatchDeleteDebugLog();
        DataBase.executeBatch(obj); 
        String jobId = System.schedule('BatchDeleteDebugLog', CRON_EXP, new BatchDeleteDebugLog());
        Test.stopTest();
    }
}