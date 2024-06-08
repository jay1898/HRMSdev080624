/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: TestMyOpportunitiesCtrlr to test all the logic of MyOpportunitiesCtrlr.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


@isTest
public class TestMyOpportunitiesCtrlr {
    static testMethod void testData() {
        Set<String> setOfTerritoriesIds = new Set<String>();
        Set<String> setOfBranchnumbers = new Set<String>();
         String primary; 
        //insert user
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Gale';
        testUser.Trade_Branch_Number__c='035';
        insert testUser;
        
        primary=testUser.Trade_Branch_Number__c;
        system.runAs(testUser) 
        {
       Branch__c objbranch= new Branch__c();
            objbranch.Name='Los Angeles';
            objbranch.T_C_Branch_Number__c='035';
            objbranch.Branch_Number__c='711';
            insert objbranch;
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', false);
        ac.Geo_Location__Latitude__s=41.398521;
        ac.Geo_Location__Longitude__s=-92.916481;
        ac.Branch__c=objbranch.id;
        insert ac;
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp1', ac.Id,testUser.id , false); 
        opp.Appointment_DateTime__c=DateTime.now();
        opp.Geo_Location__Latitude__s=41.398521;
        opp.Geo_Location__Longitude__s=-92.916481;
        insert opp;
        system.debug('opp==>'+opp.OwnerId+'oppBranch'+opp.Account.Branch__c);
        
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '035', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            
            List<Territory2Model> models = [Select Id from Territory2Model where State = 'Active'];
        Id activeModelId = null;
        if(models.size() == 1){
            activeModelId = models.get(0).Id;
        } 
        system.debug('test: '+activeModelId);
        
        Territory2 T22= new Territory2(Territory_Reference_Number__c=objbranch.Branch_Number__c,Territory2ModelId=activeModelId ,Name='test12',DeveloperName='Replacement12',Territory2TypeId=activetypeId,TCBranchNumber__c='035' );
        
        insert T22;
            objbranch.T_C_Branch_Number__c=T22.TCBranchNumber__c;
            update objbranch;
            setOfBranchnumbers.add(T22.TCBranchNumber__c);
            UserTerritory2Association objUserAss = new UserTerritory2Association();
            objUserAss.Territory2Id=t22.Id;
            objUserAss.RoleInTerritory2='General Manager';
            objUserAss.UserId=UserInfo.getUserId();
            objUserAss.RoleInTerritory2='primary';
            insert objUserAss;
            
            setOfTerritoriesIds.add(objUserAss.Territory2Id);
            system.debug('setOfBranchnumbers==>'+setOfBranchnumbers);
           /* if(setOfBranchnumbers!=null){
                List<MyOpportunitiesCtrlr.BranchWrapper> lstMyopp = new List<MyOpportunitiesCtrlr.BranchWrapper>();
                MyOpportunitiesCtrlr.BranchWrapper objMyopp = new MyOpportunitiesCtrlr.BranchWrapper();
                objMyopp.branchId=objbranch.id;
                objMyopp.branchName=objbranch.Name;
                objMyopp.isPrimary=true;
                 lstMyopp.add(objMyopp);
            }
           MyOpportunitiesCtrlr.OppLocation objOpp= new MyOpportunitiesCtrlr.OppLocation();
        objOpp.lat=41.398521;
        objOpp.lng=-92.916481;
        */
        MyOpportunitiesCtrlr.fetchTerritories();
        MyOpportunitiesCtrlr.fetchOpportunityLocations(objbranch.Id,true,true);
        }
        
    }
}