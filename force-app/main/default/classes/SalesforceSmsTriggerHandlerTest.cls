@isTest
public without sharing class SalesforceSmsTriggerHandlerTest {

    @isTest
    public static void SalesforceSmsTriggerHandlerMethod(){
        User usr = TestUtil.createUser(true);     	
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);        
        Account ac = TestUtil.createAccount('Person Account', true);             
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false);
       
       
        
        TwilioMessage__c smsRecord = new TwilioMessage__c();
        smsRecord.Opportunity__c = opp.Id;
        smsRecord.Direction__c = 'Outbound';
        smsRecord.MessageBody__c = 'Test Record';
        smsRecord.Status__c = 'Success';
        smsRecord.Name = 'Test Record';
        smsRecord.Branch__c =branch.Id; 
        insert smsRecord;      
         List<TwilioMessage__c> smsList = new List<TwilioMessage__c>();        
        smsList.add(smsRecord);
        Map<Id,TwilioMessage__c> oldMap = new Map<Id,TwilioMessage__c>();
        oldMap.put(smsRecord.Id,smsRecord);
        
        Test.startTest();
        System.RunAs(usr)
        {          
          TestUtil.createTerritory2();          
        }
        SalesforceSmsTriggerHandler.SMSRecordShare(smsList,oldMap);
        Test.stopTest();
    }
}