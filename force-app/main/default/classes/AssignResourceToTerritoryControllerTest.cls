/**
* @description       : AssignResourceToTerritoryControllertestto cover AssignResourceToTerritoryController
* @author            : Dhruv Javiya | javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   14-04-2022    Dhruv Javiya  Initial Version()
**/
@isTest
public class AssignResourceToTerritoryControllerTest {
    static testMethod void testMethod1(){
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        insert u;
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        ServiceResource sr = TestUtil.createServiceResource('Test', u.Id, branch.Id, bf.Id, false);
        sr.Ranker__c = 10.0;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        sr.Manager__c = true;
        insert sr;
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Phoenix';
        insert oh;
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        update parentST;
        ServiceTerritory childst = TestUtil.createChildServiceTerritory('Child Territory',parentST.Id, oh.Id, true);
        
        map<String, object> STMRecords = new  map<String, object>();
        List<map<String, object>> listSTMRecords = new  List<map<String, object>>();
        STMRecords.put('actionType','Insert');
        STMRecords.put('resourceId',sr.Id);
        STMRecords.put('isPrimary',true);
        listSTMRecords.add(STMRecords);
        
        system.assertEquals(1, listSTMRecords.size()); 
        system.runAs(u){
            AssignResourceToTerritoryController.checkLoggedinUserAccess();
        }
        AssignResourceToTerritoryController.checkLoggedinUserAccess();
        AssignResourceToTerritoryController.getListOfBranchFamily();
        AssignResourceToTerritoryController.getListOfBranchByBranchFamily(bf.Id);
        AssignResourceToTerritoryController.getListOfTerritoryByBranch(branch.Id);
        AssignResourceToTerritoryController.getListOfServiceResourceByBranch(branch.Id,parentST.Id);
        AssignResourceToTerritoryController.createOrDeleteSTM(JSON.serialize(listSTMRecords), childst.Id);
    }
    static testMethod void testMethod2(){
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u1';
        u.Email='u1_'+u.Email;
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        insert u;
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping_1', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        ServiceResource sr = TestUtil.createServiceResource('Test', u.Id, branch.Id, bf.Id, false);
        sr.Ranker__c = 10.0;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('Install_OV').getRecordTypeId();
        insert sr;
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Phoenix';
        insert oh;
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        update parentST;
        ServiceTerritory childst = TestUtil.createChildServiceTerritory('Child Territory',parentST.Id, oh.Id, true);
        
        map<String, object> STMRecords = new  map<String, object>();
        List<map<String, object>> listSTMRecords = new  List<map<String, object>>();
        STMRecords.put('actionType','Delete');
        STMRecords.put('resourceId',sr.Id);
        STMRecords.put('isPrimary',true);
        listSTMRecords.add(STMRecords);
        system.assertEquals(1, listSTMRecords.size()); 
        system.runAs(u){
            AssignResourceToTerritoryController.checkLoggedinUserAccess();
        }
        AssignResourceToTerritoryController.checkLoggedinUserAccess();
        AssignResourceToTerritoryController.createOrDeleteSTM(JSON.serialize(listSTMRecords), childst.Id);
    }
}