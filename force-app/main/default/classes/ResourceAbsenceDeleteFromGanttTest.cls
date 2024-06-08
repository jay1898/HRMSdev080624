@isTest
public class ResourceAbsenceDeleteFromGanttTest {
    static testMethod void testMethod1(){
        
        DateTime startDateTime = DateTime.now().addDays(-10);
        DateTime endDateTime = startDateTime.addHours(24);
        
        User u = TestUtil.createUser(true);
        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        // Create Opreating Hours
         OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
         // Create Time Slot
         TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
         
         //createbranch
         Branch_Grouping__c bf = TestUtil.createBranchGrouping('Gale', false);
         bf.Branch_Family_Number__c = '124';
         insert bf;
         Branch__c branch = TestUtil.createBranch('Test', '123', bf.Id, true);
        
         //Create PIES Territory
         ServiceTerritory st = TestUtil.createPIESServiceTerritroy('PIES ST 1', branch.Id, oh.Id, 'Install', false );
         st.IsActive = true;
         Insert st ;
        
         //create child territory
          ServiceTerritory chst = TestUtil.createPIESZCServiceTerritroy('32926','32926', st.Id, oh.Id, false);
          chst.IsActive = true ;
          insert chst;
          ServiceTerritory chst2 = TestUtil.createPIESZCServiceTerritroy('32116','32116', st.Id, oh.Id, false);
          chst2.IsActive = true ;
          insert chst2;
         
         //Create territory zipcode
         Territory_Zipcode__c tz = TestUtil.createTZforPIES(st.Id, chst.Id, true);
         Territory_Zipcode__c tz1 = TestUtil.createTZforPIES(st.Id, chst2.Id, true);
        
         Id srRTId = Schema.SObjectType.ServiceResource.recordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
         // Create 1st Service Resource
         ServiceResource sr1 = TestUtil.createServiceResource('TestPIESOne', u.Id, branch.Id, bf.Id, false);
         sr1.RecordTypeId = srRTId ; 
         Insert sr1;
        
        ResourceAbsence ra = TestUtil.createResourceAbsence(sr1.Id,false);
        ra.Type = 'Time Block'; Insert ra ;
        Date ganttStartDate = Date.newInstance(2022, 05, 8);
        Date ganttEndDate = Date.newInstance(2022, 05, 10);
        Map<String, ResourceAbsence> additionalParameters = new Map<String, ResourceAbsence>();
        ResourceAbsenceDeleteFromGantt rag = new ResourceAbsenceDeleteFromGantt();
        rag.action(ra.Id, ra.Type, ganttStartDate, ganttEndDate, additionalParameters);
        
                    

    }

}