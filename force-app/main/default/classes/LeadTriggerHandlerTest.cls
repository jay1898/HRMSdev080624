@isTest
private class LeadTriggerHandlerTest 
{
    static testMethod void testMethod1() 
    {
        List<Lead> leads = new List<Lead>();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, true);
        
        for(Integer i=0; i<100; i++)
        {
            Lead ld = TestUtil.createLead( 'TEst' +String.valueOf(i), 'LastnameTest' + String.valueOf(i), false ) ;
            ld.PostalCode = '37335';
            leads.add(ld);
        }
        if(leads.size() > 0) insert leads ;
    }
    static testMethod void eloquaLeadAssignPCC() 
    {
        User usr = TestUtil.createUser(true);
        
        List<Lead> leads = new List<Lead>();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.PCC_Lead_Receiver__c = usr.Id;
        insert branch;
        
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('11778', childST.Id, oh.Id, false);
        subChildST.PostalCode = '11778';
        insert subChildST;
        
        //Create campaing
        Campaign camp = TestUtil.createCampaign('PCC Program Request', branch.Id ,  True);
        
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        for(Integer i=0; i<100; i++)
        {
            Lead ld = TestUtil.createLead( 'TestLead' +String.valueOf(i), 'LastnameTestLead' + String.valueOf(i), false ) ;
            ld.Originating_System__c = 'Eloqua';
            ld.RecordTypeId = leadRecordTypeId ;
            ld.Business_Segment__c = 'Trade';
            ld.Lead_Type__c = 'Other Mass Retailer';
            ld.Campaign__c = camp.Id;
            ld.PostalCode = '11778';
            leads.add(ld);
        }
        if(leads.size() > 0) insert leads ;
    }
    static testMethod void eloquaLeadAssignTrade() 
    {
        User usr = TestUtil.createUser(true);
        
        List<Lead> leads = new List<Lead>();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Trade_Lead_Receiver__c = usr.Id;
        insert branch;
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('05451', childST.Id, oh.Id, false);
        subChildST.PostalCode = '05451';
        insert subChildST;
        
        //Create campaing
        Campaign camp = TestUtil.createCampaign('PCC Program Request', branch.Id ,  True);
        
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        for(Integer i=0; i<100; i++)
        {
            Lead ld = TestUtil.createLead( 'TestLead' +String.valueOf(i), 'LastnameTestLead' + String.valueOf(i), false ) ;
            ld.Originating_System__c = 'Eloqua';
            ld.RecordTypeId = leadRecordTypeId ;
            ld.Business_Segment__c = 'Trade';
            ld.Lead_Type__c = 'Other Mass Retailer';
            
            ld.PostalCode = '05451';
            leads.add(ld);
        }
        if(leads.size() > 0) insert leads ;
    }
    static testMethod void eloquaLeadAssignCommercial() 
    {
        User usr = TestUtil.createUser(true);
        List<Lead> leads = new List<Lead>();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Trade_Lead_Receiver__c = usr.Id;
        insert branch;
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('13116', childST.Id, oh.Id, false);
        subChildST.PostalCode = '13116';
        insert subChildST;
        
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        for(Integer i=0; i<100; i++)
        {
            Lead ld = TestUtil.createLead( 'TestLead' +String.valueOf(i), 'LastnameTestLead' + String.valueOf(i), false ) ;
            ld.Originating_System__c = 'Eloqua';
            ld.RecordTypeId = leadRecordTypeId ;
            ld.Business_Segment__c = 'Commercial';
            ld.Lead_Type__c = 'Commercial Building Owner';
            ld.PostalCode = '13116';
            leads.add(ld);
        }
        if(leads.size() > 0) insert leads ;
    }
    static testMethod void eloquaLeadAssignGetaQuoteCamp() 
    {
        User usr = TestUtil.createUser(true);
        
        List<Lead> leads = new List<Lead>();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Trade_Lead_Receiver__c = usr.Id;
        insert branch;
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('13116', childST.Id, oh.Id, false);
        subChildST.PostalCode = '13116';
        insert subChildST;
        
        //Create campaing
        Campaign camp = TestUtil.createCampaign('Pella.com – Get A Quote', branch.Id ,  True);
        
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        for(Integer i=0; i<100; i++)
        {
            Lead ld = TestUtil.createLead( 'TestLead' +String.valueOf(i), 'LastnameTestLead' + String.valueOf(i), false ) ;
            ld.Originating_System__c = 'Eloqua';
            ld.Campaign__c = camp.Id;
            ld.RecordTypeId = leadRecordTypeId ;
            ld.Business_Segment__c = 'Commercial';
            ld.Lead_Type__c = 'Commercial Building Owner';
            ld.PostalCode = '13116';
            leads.add(ld);
        }
        if(leads.size() > 0) insert leads ;
    }
    //Added by Satheesh Bojanapu on 10/04/2021; Leads assign test class for Lowes leads
    static testMethod void eloquaLeadAssignLowes() 
    {
        User usr = TestUtil.createUser(true);
        List<Lead> leads = new List<Lead>();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.Trade_Lead_Receiver__c = usr.Id;
        insert branch;
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Store Account
        Account account = TestUtil.createBranchAccount('Pro_Lowes', false);
        account.Branch_Number__c = 'L50';
        insert account;
        
        //Create campaing
        Campaign camp = TestUtil.createCampaign('PellatLowes.com', branch.Id , True);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);
        
        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('13116', childST.Id, oh.Id, false);
        subChildST.PostalCode = '13116';
        subChildST.Store_Account__c=account.Id;
        insert subChildST;
        
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pro_Lowes').getRecordTypeId();
        for(Integer i=0; i<100; i++)
        {
            Lead ld = TestUtil.createLead( 'TestLead' +String.valueOf(i), 'LastnameTestLead' + String.valueOf(i), false ) ;
            ld.Originating_System__c = 'Eloqua';
            ld.Campaign__c = camp.Id;
            ld.RecordTypeId = leadRecordTypeId ;
            ld.Business_Segment__c = 'Lowes';
            ld.PostalCode = '13116';
            leads.add(ld);
        }
        if(leads.size() > 0) insert leads ;
    }
 
    static testMethod void pellaProMobileLeadAssignIsATradeLeadTest() 
    {
		User user = TestUtil.createUser(true);
        User tradeLeadReceiver = TestUtil.createUser(true);

        Branch_Grouping__c branchFamily = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', branchFamily.Id, false);
        branch.Trade_Lead_Receiver__c = tradeLeadReceiver.Id;
        insert branch;

        OperatingHours operatingHours = TestUtil.createOpreatingHours('Custom', true);
        TimeSlot ts = TestUtil.createTimeSlot(operatingHours.Id, true);

        ServiceTerritory parentTerritory = TestUtil.createParentServiceTerritory('Parent Territory', operatingHours.Id, branch.Id, true);
        ServiceTerritory childTerritory = TestUtil.createChildServiceTerritory('Child', parentTerritory.Id, operatingHours.Id, true);
        ServiceTerritory subChildTerritory = TestUtil.createSubChildServiceTerritory('87120', childTerritory.Id, operatingHours.Id, false);
        subChildTerritory.PostalCode = '87120';
        insert subChildTerritory;
        
        Test.startTest();
        
        Lead lead = TestUtil.createLead('Test', 'Lead', false );
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        lead.Business_Segment__c = 'Trade';
        lead.Originating_System__c = 'Pella Pro Mobile App';
        lead.PostalCode = '87120';
        insert lead;
        
        Test.stopTest(); 

		Lead leadAfterUpdate = [SELECT Id, Name, OwnerId, Branch__r.Id FROM Lead WHERE Id =: lead.Id];

        system.assertEquals(branch.Id, leadAfterUpdate.Branch__c);
        system.assertEquals(tradeLeadReceiver.Id, leadAfterUpdate.OwnerId);        
    }
    
    static testMethod void pellaProMobileLeadAssignIsACommercialLeadTest() 
    {
		User user = TestUtil.createUser(true);
        User tradeLeadReceiver = TestUtil.createUser(true);

        Branch_Grouping__c branchFamily = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', branchFamily.Id, false);
        branch.Trade_Lead_Receiver__c = tradeLeadReceiver.Id;
        insert branch;

        OperatingHours operatingHours = TestUtil.createOpreatingHours('Custom', true);
        TimeSlot ts = TestUtil.createTimeSlot(operatingHours.Id, true);

        ServiceTerritory parentTerritory = TestUtil.createParentServiceTerritory('Parent Territory', operatingHours.Id, branch.Id, true);
        ServiceTerritory childTerritory = TestUtil.createChildServiceTerritory('Child', parentTerritory.Id, operatingHours.Id, true);
        ServiceTerritory subChildTerritory = TestUtil.createSubChildServiceTerritory('87120', childTerritory.Id, operatingHours.Id, false);
        subChildTerritory.PostalCode = '87120';
        insert subChildTerritory;
        
        Test.startTest();
        
        Lead lead = TestUtil.createLead('Test', 'Lead', false );
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        lead.Business_Segment__c = 'Commercial';
        lead.Originating_System__c = 'Pella Pro Mobile App';
        lead.PostalCode = '87120';
        insert lead;
        
        Test.stopTest(); 

		Lead leadAfterUpdate = [SELECT Id, Name, OwnerId, Branch__r.Id FROM Lead WHERE Id =: lead.Id];

        system.assertEquals(branch.Id, leadAfterUpdate.Branch__c);
        system.assertEquals(tradeLeadReceiver.Id, leadAfterUpdate.OwnerId);        
    }
    
    static testMethod void pellaProMobileLeadAssignWhenLeadIsNotAPellaProMobileTest() 
    {
		User user = TestUtil.createUser(true);
        User tradeLeadReceiver = TestUtil.createUser(true);

        Branch_Grouping__c branchFamily = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', branchFamily.Id, false);
        branch.Trade_Lead_Receiver__c = tradeLeadReceiver.Id;
        insert branch;

        OperatingHours operatingHours = TestUtil.createOpreatingHours('Custom', true);
        TimeSlot ts = TestUtil.createTimeSlot(operatingHours.Id, true);

        ServiceTerritory parentTerritory = TestUtil.createParentServiceTerritory('Parent Territory', operatingHours.Id, branch.Id, true);
        ServiceTerritory childTerritory = TestUtil.createChildServiceTerritory('Child', parentTerritory.Id, operatingHours.Id, true);
        ServiceTerritory subChildTerritory = TestUtil.createSubChildServiceTerritory('37335', childTerritory.Id, operatingHours.Id, false);
        insert subChildTerritory;
        
        Test.startTest();
        
        Lead lead = TestUtil.createLead('Test', 'Lead', false );
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        lead.Business_Segment__c = 'Commercial';
        insert lead;
        
        Test.stopTest(); 

		Lead leadAfterUpdate = [SELECT Id, Name, OwnerId, Branch__r.Id FROM Lead WHERE Id =: lead.Id];

        system.assertEquals(null, leadAfterUpdate.Branch__c);
        system.assertNotEquals(tradeLeadReceiver.Id, leadAfterUpdate.OwnerId);        
    }
}