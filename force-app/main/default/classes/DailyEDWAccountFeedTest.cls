@isTest
public class DailyEDWAccountFeedTest {
   
    private static testMethod void DailyEDWAccountFeedMethods_Test1(){
        
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;   
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c br = TestUtil.createBranch('Test Branch2', '1001', bf.Id, true);
        
        Account parentAcc = TestUtil.createBranchAccount('Pella Account', false);
        parentAcc.Temp_branch_Number__c = '5';
        parentAcc.Branch_Number__c = '10';
        insert parentAcc;
        
        Account childAcc = TestUtil.createBranchAccount('Branch Account', false);
        childAcc.ParentId = parentAcc.Id;
        childAcc.Branch__c = br.Id;
        childAcc.Temp_branch_Number__c = '5';
        childAcc.Branch_Number__c = '10';
        childAcc.EDW_Last_Modified__c = DateTime.now().AddDays(-5);
        //childAcc.
        insert childAcc;
        
        Opportunity opp = TestUtil.createOpportunity('Test1001', childAcc.Id, userinfo.getUserId(), false);
        opp.CloseDate = Date.valueOf('2020-12-29');
        opp.StageName = 'New';
        opp.Status__c = 'Open';
        opp.RecordTypeId = OppRecTyTCId;
        opp.Type = 'Trade';
        opp.Market_Segment__c = 'SP: Single Family Replacement';
        opp.Approved_Status__c = 'Approved';
        insert opp;
        
        // Intialization of ADL object to create a ADL record
        Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
        objApex.Opportunity__c=true;
        objApex.Apex_Class__c='EDWDataservice';
        objApex.Method__c='GET';
        insert objApex;
        //Query to fetch the ADL record ID for Opportunity
        List<Apex_Debug_Log__c> lstApexDebug = new List<Apex_Debug_Log__c>() ;
        lstApexDebug=[select id,Name,Opportunity__c from Apex_Debug_Log__c where Opportunity__c=true ORDER BY Name DESC limit 1];
        objApex.EDW_Transaction_ID__c=lstApexDebug[0].Id;
        objApex.id=lstApexDebug[0].id;
        update objApex;
        string TxnId = lstApexDebug[0].Id;
        dateTime validFrom=DateTime.now().AddDays(-10);
        dateTime validTo=DateTime.now();
        
        set<Id> OppIds = new set<Id>();
        OppIds.add(opp.Id);
        set<Id> accountIds = new set<Id>();
        accountIds.add(parentAcc.Id);
        
        DailyEDWAccountFeed objAcc = new DailyEDWAccountFeed(validFrom,validTo,TxnId,OppIds,true,accountIds);
        Database.executeBatch( objAcc , 200);
        
    }
}