@isTest 
public class BatchDeleteBACHistoryLogTest
{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void DeleteBACLog()
    {
         Account ac = TestUtil.createBranchAccount('Branch Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;
        Associated_Account__c aa = new Associated_Account__c();
        aa.Associated_Account_Name__c = ac.Id;
        aa.Opportunity__c = opp.Id;
        insert aa;
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        insert q ;
        Test.setCreatedDate(q.Id, DateTime.now().addMonths(-2));
        BAC_History__c PQ=new BAC_History__c();
        PQ.Quote__c=q.Id;
        //PQ.Opportunity__c=OppNo;
        //PQ.PQM_Data__c=JSON.serialize(req);
        //PQ.salesrepusername__c=req.salesrepusername;    
        insert PQ;
        Test.setCreatedDate(PQ.Id, DateTime.now().addMonths(-2));

        Test.startTest();
        BatchDeleteBACHistoryLog obj = new BatchDeleteBACHistoryLog();
        DataBase.executeBatch(obj); 
        String jobId = System.schedule('BatchDeleteBACHistoryLog', CRON_EXP, new BatchDeleteBACHistoryLog());
        Test.stopTest();
    }
}