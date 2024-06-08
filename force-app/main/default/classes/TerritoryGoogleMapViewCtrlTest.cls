/**
* @description       : TerritoryGoogleMapViewCtrlTest
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* @group             : eVerge
* History 	
* Ver   Date         Author        Modification
* 1.0   14-04-2022   Dhruv Javiya  Initial Version()

**/
@isTest
public class TerritoryGoogleMapViewCtrlTest {
    
    static testMethod void testmethod1() 
    {
        User u = TestUtil.createUser(false);
        u.username=u.username+'_u3';
        u.Email='u3_'+u.Email;
        insert u;

       //createbranch
         Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
         bf.Branch_Family_Number__c = '124';
        insert bf;
        
        Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
        oh.TimeZone = 'America/Phoenix';
        insert oh;
        
        ServiceTerritory parentst = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
        parentst.PostalCode = '10000';
        parentst.IsActive = true; 
        insert parentst;
        ServiceTerritory st = TestUtil.createPIESServiceTerritroy('Service Territory', branch.Id, oh.Id,'OV', false);
        st.IsActive = true;
        insert st;
        ServiceTerritory zipcode = TestUtil.createPIESZCServiceTerritroy('Zipcode Name','123546',parentst.Id, oh.Id, true);
        
        Territory_Zipcode__c stZip = TestUtil.createTZforPIES(st.Id, zipcode.Id, true);
        
              
         // Create 1st Service Resource
        ServiceResource sr = TestUtil.createServiceResource('Test', u.Id, branch.Id, bf.Id, false);
        sr.Ranker__c = 10.0;
        insert sr;
        system.assertEquals('Test', sr.Name);
        ServiceTerritoryMember stm = TestUtil.createServiceTerritoryMember(sr.Id, st.Id, true);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(branch);
        TerritoryGoogleMapViewCtrl t2=new TerritoryGoogleMapViewCtrl(sc); 
        
    }
}