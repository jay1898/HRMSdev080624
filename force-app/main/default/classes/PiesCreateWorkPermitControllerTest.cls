@istest
public class PiesCreateWorkPermitControllerTest {

    @TestSetup
    static void makeData(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Is_From_Custom_UI__c = true;
        insert acc;
        
        Branch_Grouping__c brGroup = new Branch_Grouping__c();
        brGroup.Name = 'Test Branch Grouping';
        brGroup.Branch_Family_Number__c = '000001';
        brGroup.Grouping_Type__c = 'Branch Family';
        brGroup.Pella_Account_Owner__c = UserInfo.getUserId();
        insert brGroup;
        
        Branch__c br = new Branch__c();
        br.Name = 'Test Branch';
        br.Branch_Number__c = '000001';
        br.Trade_Lead_Receiver__c = UserInfo.getUserId();
        br.Commercial_Lead_Receiver__c = UserInfo.getUserId();
        br.PCC_Lead_Receiver__c = UserInfo.getUserId();
        br.Branch_Family__c = brGroup.Id;
        br.Country__c = 'USA';
        br.Branch_Type__c = 'Sales Subsidiary';
        insert br;
            
        WorkOrder wo = new WorkOrder();
        wo.Subject = 'test subject';
        wo.City ='test city';
        wo.Country = 'US';
        wo.State = 'TE';
        wo.Branch__c = br.Id;
        wo.AccountId = acc.Id;
        insert wo;

        Work_Permit_Template__c wrkPerTemplate = new Work_Permit_Template__c();
        wrkPerTemplate.Branch__c = br.Id;
        wrkPerTemplate.City__c ='test city';
        wrkPerTemplate.County__c = 'US';
        wrkPerTemplate.State__c = 'Te';
        wrkPerTemplate.Cost_Calculation_Type__c = 'Fixed';
        wrkPerTemplate.Fixed_Fee_Amount__c = 1000;
        insert wrkPerTemplate;

        Work_Permit__c wrkPermit = new Work_Permit__c();
        wrkPermit.Status__c = 'Open';
        wrkPermit.Work_Order__c = wo.Id;
        wrkPermit.Account__c = acc.Id;
        wrkPermit.Template__c = wrkPerTemplate.Id;
        insert wrkPermit;
    }
    
    @IsTest
    static void getKnowledgeArticleTest() {
        Test.startTest();
        	WorkOrder wo = [Select Id, Subject, State, City, AccountId from WorkOrder where Subject = 'test subject'];
            WorkOrder wrkOrder = PiesCreateWorkPermitController.getWorkOrder_Server(wo.Id);
            System.assertEquals('US', wrkOrder.Country);

            Set<Id> WorkPermitSet = PiesCreateWorkPermitController.getWorkTemplatesInUse_Server(wo.Id);
            System.assertEquals(1, WorkPermitSet.size());

            Work_Permit_Template__c workPermit = [Select Id, Name, Branch__c, City__c, State__c, County__c from Work_Permit_Template__c where City__c = 'test city'];
            Branch__c br = [Select Id, Name from Branch__c where Name = 'Test Branch'];
            List<PiesCreateWorkPermitController.WorkTemplateWrap> wrkTemplateList = PiesCreateWorkPermitController.getTemplates_Server(br.Id, '', workPermit.State__c, workPermit.City__c, workPermit.County__c, wo.Id);
            System.assertEquals(1, wrkTemplateList.size());

            String jsonData = PiesCreateWorkPermitController.createWorkPermits_Server(JSON.serialize(new Set<Id>{workPermit.Id}), wo);
            System.assertNotEquals(null, jsonData);
        Test.stopTest();
    }
}