@isTest
public class OpportunityRecordShareBatchTest{
     public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void testMethod2(){
        
        User u = TestUtil.createUser(false);
        insert u;
        
        User u2 = TestUtil.createUser(false);
        u2.AOR__C='Strategic America';
        insert u2;
        
        User u1 = TestUtil.createUser(false);
        u1.AOR__C='Gale';
        insert u1;
        system.runAs(u) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true); 
            
            Account acc = TestUtil.createAccount('Person Account', true);
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            
            Branch_Grouping__c bf1 = TestUtil.createBranchGrouping('Gale', true);
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__c=bf.Id;
            insert branch;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;
            
            //Zone Level Territory
            ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
            stZone.IsActive= true;
            stZone.PostalCode = '20000';
            stZone.Lead_Receiver__c = u.id;
            insert stZone;            
            
            //ZipCode Level Territory
            ServiceTerritory stZip = TestUtil.createSubChildServiceTerritory('Sub Child3', stZone.Id, oh.Id, false);
            stZip.IsActive= true;
            stZip.PostalCode = '30000';
            insert stZip;
            
            ServiceTerritory stZone1 = TestUtil.createChildServiceTerritory('Child5', stZip.Id, oh.Id, false);
            stZone1.IsActive= true;
            stZone1.PostalCode = '70000';
            stZone1.Lead_Receiver__c = u.id;
            insert stZone1;
            
            Campaign testCamp=TestUtil.createCampaign('Camp1',branch.Id,true);
            
            Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, false);
            testOpportunity.Zone__c = stZone.Id;
            testOpportunity.CampaignId=testCamp.Id;
            insert testOpportunity;
            
            ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', acc.Id, testOpportunity.Id, testOpportunity.Id, false);
            sa.ServiceTerritoryId = stZone.Id;
            sa.Country='US';
            insert sa;
            system.debug('@@ Share Rec'+[SELECT ID,OpportunityAccessLevel FROM OpportunityShare]);
            List<String> BranchNumbers = new List<String>();
            List<String> listAORBranchName = new List<String>();
            // Create set of parent accountIds
            for(Opportunity opp:[SELECT ID,Zone__r.ParentTerritory.Branch__r.AOR__r.Name From Opportunity]){
                if(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name != null){
                    listAORBranchName.add(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name);
                }
            }
            // get List Of AOR User
            List<User> listAORUser=[SELECT ID,Name,AOR__c FROM USER where AOR__c in :listAORBranchName];
            system.debug('@@'+listAORUser);
            
            Test.startTest();
            branch.AOR__c=bf1.Id;
            update branch;
            
            Test.stopTest(); 
        }
    }
    static testMethod void testMethod1(){
        
        User u = TestUtil.createUser(false);
        insert u;
        
        User u2 = TestUtil.createUser(false);
        u2.AOR__C='Strategic America';
        insert u2;
        
        User u1 = TestUtil.createUser(false);
        u1.AOR__C='Gale';
        insert u1;
        system.runAs(u) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true); 
            
            Account acc = TestUtil.createAccount('Person Account', true);
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            
            Branch_Grouping__c bf1 = TestUtil.createBranchGrouping('Gale', true);
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__c=bf.Id;
            insert branch;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;
            
            //Zone Level Territory
            ServiceTerritory stZone = TestUtil.createChildServiceTerritory('Child3', stParent.Id, oh.Id, false);
            stZone.IsActive= true;
            stZone.PostalCode = '20000';
            stZone.Lead_Receiver__c = u.id;
            insert stZone;            
            
            //ZipCode Level Territory
            ServiceTerritory stZip = TestUtil.createSubChildServiceTerritory('Sub Child3', stZone.Id, oh.Id, false);
            stZip.IsActive= true;
            stZip.PostalCode = '30000';
            insert stZip;
            
            ServiceTerritory stZone1 = TestUtil.createChildServiceTerritory('Child5', stZip.Id, oh.Id, false);
            stZone1.IsActive= true;
            stZone1.PostalCode = '70000';
            stZone1.Lead_Receiver__c = u.id;
            insert stZone1;
            
            Campaign testCamp=TestUtil.createCampaign('Camp1',branch.Id,true);
            
            Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, false);
            testOpportunity.Zone__c = stZone.Id;
            testOpportunity.CampaignId=testCamp.Id;
            insert testOpportunity;
            
            ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', acc.Id, testOpportunity.Id, testOpportunity.Id, false);
            sa.ServiceTerritoryId = stZone.Id;
            sa.Country='US';
            insert sa;
            system.debug('@@ Share Rec'+[SELECT ID,OpportunityAccessLevel FROM OpportunityShare]);
            List<String> BranchNumbers = new List<String>();
            List<String> listAORBranchName = new List<String>();
            // Create set of parent accountIds
            for(Opportunity opp:[SELECT ID,Zone__r.ParentTerritory.Branch__r.AOR__r.Name From Opportunity]){
                if(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name != null){
                    listAORBranchName.add(opp.Zone__r.ParentTerritory.Branch__r.AOR__r.Name);
                }
            }
            // get List Of AOR User
            List<User> listAORUser=[SELECT ID,Name,AOR__c FROM USER where AOR__c in :listAORBranchName];
            system.debug('@@'+listAORUser);
            
            Test.startTest();
            u2.AOR__C='Gale';
            update u2;
            Test.stopTest(); 
        }
    }
}