@isTest
public class ReProcessDebugLogOfInboundPQMTest{
     public static String CRON_EXP = '0 0 0 3 9 ? 2022';
   
    testMethod
    static void createErrorLog(){
         
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), true); 
        
        new ApexDebugLog().createLog(new ApexDebugLog.Error('PQMInbound','postData','Request Body: [{"earliestLRD": null,"quotenumber": "24440","quotename": "Bixlerlast,Pamfirst,2158748","salesrepusername": "Lapp, Ted","status": "Active","contractdate": null,"bookdate": null,"quotedate": null,"signedContractdate": null,"ponumber": "724","quantity": 16,"customerextendedprice": 47824.06,"forecast": "True","opportunity": "'+opp.Id+'","contactname": "Pamfirst Bixlerlast","partyid": "14143645", "totalBACprice":"10.2"  , "projectname": "Bixlerlast,Pamfirst,2158748","brandcount": [{"brand": "Architect Reserve","count": 1,"customerextendedprice": 1092.12,"productCount": [{"producttype": "Casement","count": 1,"totalBACprice":"10.2","customerextendedprice": 1092.1}]},{"brand": "Architect","count": 6,"customerextendedprice": 17422.75,"productCount": [{"producttype": "DoubleHung","count": 2,"totalBACprice":"10.2","customerextendedprice": 6697.82}]}]}]','{"status":"Some Of Opportunity are incorrect :[\"2444192\",\"2451676\",\"2455491\",\"2453978\",\"2456652\",\"2453978\",\"2454358\",\"2454358\"]","httpStatusCode":"400","errorMessage":"INVALID_DATA"}', 'Integration'));
        new ApexDebugLog().createLog(new ApexDebugLog.Information('PQMInbound','postData','Request Body: [{"earliestLRD": null,"quotenumber": "24440","quotename": "Bixlerlast,Pamfirst,2158748","salesrepusername": "Lapp, Ted","status": "Active","contractdate": null,"bookdate": null,"quotedate": null,"signedContractdate": null,"ponumber": "724","quantity": 16,"customerextendedprice": 47824.06,"forecast": "True","opportunity": "'+opp.Id+'","contactname": "Pamfirst Bixlerlast","partyid": "14143645", "totalBACprice":"10.2"  , "projectname": "Bixlerlast,Pamfirst,2158748","brandcount": [{"brand": "Architect Reserve","count": 1,"customerextendedprice": 1092.12,"productCount": [{"producttype": "Casement","count": 1,"totalBACprice":"10.2","customerextendedprice": 1092.1}]},{"brand": "Architect","count": 6,"customerextendedprice": 17422.75,"productCount": [{"producttype": "DoubleHung","count": 2,"totalBACprice":"10.2","customerextendedprice": 6697.82}]}]}]', 'postData: Received Request','Integration'));
            
        //ReProcessDebugLogOfInboundPQM b = new ReProcessDebugLogOfInboundPQM(); 
       // database.executebatch(b,1);
        Test.startTest();
        String jobId = System.schedule('OppCommAlertBatchTest', CRON_EXP, new ReProcessDebugLogOfInboundPQM());
        Test.stopTest();
    }
}