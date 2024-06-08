/**
*   @Name:          SMSRecordShareBatchTest
*   @Purpose:       Test class for SMSRecordShareBatch and SMSRecordShare
*   @Author:        Dhruv Javia (eVerge)
*   @Date:          07/10/2022
*      

*   @Updates:       
*/
@isTest
public without sharing class SMSRecordShareBatchTest {
    
    @TestSetup
    public static void setupData(){  
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        User testUser2 = TestUtil.createUser(false);
        testUser2.AOR__C='Strategic America';
        insert testUser2;
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);   
            branch.AOR__c = bf.Id;
            insert branch;
            
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true);   
            
            Account ac = TestUtil.createAccount('Person Account', true);    
            
            Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, testUser.Id, true);
            
            TwilioMessage__c smsRecord = new TwilioMessage__c();
            smsRecord.Opportunity__c = opp.Id;
            smsRecord.Direction__c = 'Outbound';
            smsRecord.MessageBody__c = 'Test Record';
            smsRecord.Status__c = 'Success';
            smsRecord.Name = 'Test Record';
            smsRecord.Branch__c =branch.Id; 
            
            List<TwilioMessage__c> smsList = new List<TwilioMessage__c>();        
            smsList.add(smsRecord);
            
            insert smsList;
            opp.OwnerId=testuser2.id;
            update opp;
        }
    }
    @isTest
    public static void SMSRecordShareTest(){
        Test.startTest();
        SMSRecordShareBatch obj = new SMSRecordShareBatch();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
    public static testMethod void testSchedule() {
        
        Test.StartTest();
        SMSRecordShareBatch testsche = new SMSRecordShareBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();    
    }
}