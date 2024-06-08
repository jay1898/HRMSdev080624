@isTest
public class PQMQuoteInboundBatchTest {
	@isTest
    public static void testMathod1(){
    	//create Accout  
        Account ac = TestUtil.createAccount('Person Account', true);
        //create opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c = DateTime.now();
        opp.Status__c = 'Open';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Trade_Comm').getRecordTypeId();
        OpportunityTriggerHandler.RUN_TRIGGER= false;
        insert opp;    
        new ApexDebugLog().createLog(new ApexDebugLog.Information('PQMInbound','postData: Received Request','Request Body: [{"earliestLRD": null,"quotenumber": "24440","quotename": "Bixlerlast,Pamfirst,2158748","salesrepusername": "Lapp, Ted","status": "Active","contractdate": null,"bookdate": null,"quotedate": null,"signedContractdate": null,"ponumber": "724","quantity": 16,"customerextendedprice": 47824.06,"forecast": "True","opportunity": "'+opp.Id+'","contactname": "Pamfirst Bixlerlast","partyid": "14143645", "totalBACprice":"10.2"  , "projectname": "Bixlerlast,Pamfirst,2158748","brandcount": [{"brand": "Architect Reserve","count": 1,"customerextendedprice": 1092.12,"productCount": [{"producttype": "Casement","count": 1,"totalBACprice":"10.2","customerextendedprice": 1092.1}]},{"brand": "Architect","count": 6,"customerextendedprice": 17422.75,"productCount": [{"producttype": "DoubleHung","count": 2,"totalBACprice":"10.2","customerextendedprice": 6697.82}]}]}]', 'postData: Received Request','Integration'));
		Apex_Debug_Log__C apexId =[SELECT ID FROM Apex_Debug_Log__C limit 1];
        Order order = testUtil.createOrder('Test',ac.Id, true);
        
    }
}