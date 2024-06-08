@IsTest
public class OppCampAssignmentByZoneBatchTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void testMethod2(){
         User u = TestUtil.createUser(false);
        u.AOR__C='Strategic America';
        insert u;
        system.runAs(u) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true);   
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', false);
            bf.Branch_Family_Number__c = '100';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            Cp.AOR__c=bf.Id;
            Cp.Type='AOR';
            cp.Branch_Name__c=null;
            insert Cp;
            
            Campaign testCamp=TestUtil.createCampaign('Camp1',branch.Id,true);
            
            Account acc = TestUtil.createAccount('Person Account', true);
            
           OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
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
            
            Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, false);
            testOpportunity.Zone__c = stZone.Id;
            testOpportunity.CampaignId=testCamp.Id;
            insert testOpportunity;
            
            Test.startTest();
            Database.executeBatch(new OppCampAssignmentByZoneBatch(),200);
            
            Test.stopTest();
            String jobId = System.schedule('OppCampAssignmentByZoneBatchTest Test', CRON_EXP, new OppCampAssignmentByZoneBatch());
        }
        

    }
}