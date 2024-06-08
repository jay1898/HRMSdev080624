@isTest 
public class BatchDeletePQMLogTest
{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void DeletePQMLog()
    {
         Apex_Debug_Log__c DL = TestUtil.createApexDebugLog(true);
        Test.setCreatedDate(DL.Id, DateTime.now().addMonths(-2));
        PQM_Quote__c PQ=new PQM_Quote__c();
        PQ.Apex_Debug_Log__c=DL.Id;
        //PQ.Opportunity__c=OppNo;
        //PQ.PQM_Data__c=JSON.serialize(req);
        //PQ.salesrepusername__c=req.salesrepusername;    
        insert PQ;
        Test.setCreatedDate(PQ.Id, DateTime.now().addMonths(-2));

        Test.startTest();
        BatchDeletePQMLog obj = new BatchDeletePQMLog();
        DataBase.executeBatch(obj); 
        String jobId = System.schedule('BatchDeletePQMLog', CRON_EXP, new BatchDeletePQMLog());
        Test.stopTest();
    }
}