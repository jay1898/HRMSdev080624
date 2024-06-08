@isTest
public class ServiceTerritoryTriggerHandlerTest {
    @isTest
    public static void ServiceResourceTriggerTest1(){
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', false);
        bf.Branch_Family_Number__c = '123';
        insert bf;
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Branch__c branch1 = TestUtil.createBranch('Test1', '110', bf.Id, true); 
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        parentST.Branch__c = branch1.Id;
        update parentST;
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, false);
        subChildST.postalcode='12122';
        insert subChildST;
        
        ServiceTerritory ST4 = TestUtil.createSubChildServiceTerritory('Sub Child2', childST.Id, oh.Id, false);
        ST4.postalcode='12122';
        ST4.IsActive = true;
        try{
            insert ST4;
        }catch(EXCEPTION ex){
            system.assert(ex.getMessage().contains((System.Label.Duplicate_ZipCode.replace(':Param1',subChildST.Name)).replace(':Param2',branch1.Name)));
        }
        
        ST4.postalcode='12123';
        insert ST4;
        
        try{
            ST4.postalcode='12122';
            update ST4;
        }catch(EXCEPTION ex){
            system.assert(ex.getMessage().contains((System.Label.Duplicate_ZipCode.replace(':Param1',subChildST.Name)).replace(':Param2',branch1.Name)));
        }
        
        ST4.postalcode='12192';
        update ST4;      
        delete ST4;
    }
    
    @isTest
    public static void ServiceResourceTriggerTest2(){
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch_Family');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true);   
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', false);
            bf.Branch_Family_Number__c = '100';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;
        }
    }
    
    @isTest
    public static void ServiceResourceTriggerTest3(){
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true);   
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', false);
            bf.Branch_Family_Number__c = '100';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;          
        }
    }
}