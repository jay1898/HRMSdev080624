@IsTest
public class ServiceAppointmentAssignmentBatchTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void testMethod2(){
        
        User u = TestUtil.createUser(false);
        u.AOR__C='Strategic America';
        insert u;
        system.runAs(u) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true); 
            
            Account acc = TestUtil.createAccount('Person Account', true);
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            
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
            insert testOpportunity;
            
            ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', acc.Id, testOpportunity.Id, testOpportunity.Id, false);
            sa.ServiceTerritoryId = stZone.Id;
            sa.Country='US';
            insert sa;
            
            Test.startTest();
            Database.executeBatch(new ServiceAppointmentAssignmentBatch(),2000);
            
            Test.stopTest();
            String jobId = System.schedule('ServiceAppointmentAssignmentBatchTest', CRON_EXP, new ServiceAppointmentAssignmentBatch());
        }
    }
}