@isTest
public class FixErrorRecordsTest {
    
    @isTest
    public static void FixErrorRecordsTestMethod(){
        
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        User usr = TestUtil.createUser(true);
        Account ac = TestUtil.createAccount('Person Account', true);
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false); 
        opp.CloseDate = Date.valueOf('2020-01-29');
        opp.StageName = 'New';
        opp.RecordTypeId = OppRecTyTCId ;
        opp.Appointment_DateTime__c=DateTime.now();
        opp.PQM_Quote_Shell_Error_Message__c='test';
        insert opp;
        
        Test.startTest();
        List<String> processName=new List<String>();
        processName.add('[RunFailedEBSCustomers,RunFailedQuoteShells]');
        FixErrorRecords.RunFailedQuotes(processName);
        Test.stopTest();
    }
    
}