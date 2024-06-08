@isTest
private class OpportunityRecordShareTCBatchTest 
{
    static testMethod void testMethod1() 
    {
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
            Branch_Grouping__c bf1 = bf;
            
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
            
            Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, false);
            testOpportunity.Zone__c = stZone.Id;
            insert testOpportunity;
            

    	}

    	String CRON_EXP = '0 0 0 3 9 ? 2022' ;
		Test.startTest();
        	System.schedule('OpportunityRecordShareTCBatchTest', CRON_EXP, new OpportunityRecordShareTCBatch());
        Test.stopTest();    

    }
}