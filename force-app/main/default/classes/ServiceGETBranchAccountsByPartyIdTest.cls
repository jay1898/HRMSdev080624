@isTest
private class ServiceGETBranchAccountsByPartyIdTest 
{
    static testMethod void getBranchAccountsByPartyIdBranchAccountsExistForPartyId() 
    {
        Branch_Grouping__c branchFamilyOne = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c branchOne = TestUtil.createBranch('Test One', '100', branchFamilyOne.Id, true);

        Branch_Grouping__c branchFamilyTwo = TestUtil.createBranchGrouping('BranchGrouping', true);
        Branch__c branchTwo = TestUtil.createBranch('Test Two', '200', branchFamilyTwo.Id, true);

        OperatingHours operatingHoursOne = TestUtil.createOpreatingHours('Custom', true);
        ServiceTerritory parentTerritoryOne = TestUtil.createParentServiceTerritory('Parent Territory Eins', operatingHoursOne.Id, branchOne.Id, true);
        ServiceTerritory childTerritoryOne = TestUtil.createChildServiceTerritory('Child Territory One', parentTerritoryOne.Id, operatingHoursOne.Id, true);

        OperatingHours operatingHoursTwo = TestUtil.createOpreatingHours('Custom', true);
        ServiceTerritory parentTerritoryTwo = TestUtil.createParentServiceTerritory('Parent Territory Zwei', operatingHoursTwo.Id, branchTwo.Id, true);
        ServiceTerritory childTerritoryTwo = TestUtil.createChildServiceTerritory('Child Territory Two', parentTerritoryTwo.Id, operatingHoursTwo.Id, true);

        List<ServiceTerritory> subChildTerritories = new List<ServiceTerritory> ();
        ServiceTerritory subChildTerritoryOne = TestUtil.createSubChildServiceTerritory('68201', childTerritoryOne.Id, operatingHoursOne.Id, false);
        subChildTerritoryOne.PostalCode = '68201';
        ServiceTerritory subChildTerritoryTwo = TestUtil.createSubChildServiceTerritory('68206', childTerritoryOne.Id, operatingHoursOne.Id, false);
        subChildTerritoryTwo.PostalCode = '68206';
        
        ServiceTerritory subChildTerritoryThree = TestUtil.createSubChildServiceTerritory('47005', childTerritoryTwo.Id, operatingHoursTwo.Id, false);
        subChildTerritoryThree.PostalCode = '47005';
        ServiceTerritory subChildTerritoryFour = TestUtil.createSubChildServiceTerritory('47007', childTerritoryTwo.Id, operatingHoursTwo.Id, false);
        subChildTerritoryFour.PostalCode = '47007';
        
        subChildTerritories.add(subChildTerritoryOne);
        subChildTerritories.add(subChildTerritoryTwo);
        subChildTerritories.add(subChildTerritoryThree);
        subChildTerritories.add(subChildTerritoryFour);

        insert subChildTerritories;
       
        Account parentAccount = TestUtil.createBranchAccount('Pella Account', false);
        parentAccount.mdmrecid__c = '123456';
        insert parentAccount;

        Account childAccountOne = TestUtil.createBranchAccount('Branch Account', false);
        childAccountOne.parentId = parentAccount.Id;
        childAccountOne.Branch__c = branchOne.Id;
        insert childAccountOne;

        Account childAccountTwo = TestUtil.createBranchAccount('Branch Account', false);
        childAccountTwo.parentId = parentAccount.Id;
        childAccountTwo.Branch__c = branchTwo.Id;
        insert childAccountTwo;

        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        
     	restRequest.requestURI = '/BranchAccountsByOraclePartyId/' + parentAccount.mdmrecid__c;
        restRequest.httpMethod = 'GET';
        RestContext.request = restRequest;

        ServiceGetBranchAccountsByPartyId.Response response = ServiceGetBranchAccountsByPartyId.getBranchAccountsByPartyId(); 
        
        System.assertEquals('200', response.httpStatusCode);
        System.assertEquals(2, response.branchAccounts.size());

        System.assertEquals(childAccountOne.Id, response.branchAccounts[0].Id);
        System.assertEquals(childAccountOne.Name, response.branchAccounts[0].Name);
        System.assertEquals(branchOne.Id, response.branchAccounts[0].BranchId);
        System.assertEquals(new List<String>{'68201', '68206'}, response.branchAccounts[0].ServiceTerritoryZipcodes);
        
        System.assertEquals(childAccountTwo.Id, response.branchAccounts[1].Id);
        System.assertEquals(childAccountTwo.Name, response.branchAccounts[1].Name);
        System.assertEquals(branchTwo.Id, response.branchAccounts[1].BranchId);
        System.assertEquals(new List<String>{'47005', '47007'}, response.branchAccounts[1].ServiceTerritoryZipcodes);
    }

    static testMethod void getBranchAccountsByPartyIdBranchAccountsDoNotExistForPartyId() 
    {
        Account parentAccount = TestUtil.createBranchAccount('Pella Account', false);
        parentAccount.mdmrecid__c = '123456';
        insert parentAccount;

        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        
     	restRequest.requestURI = '/BranchAccountsByOraclePartyId/' + parentAccount.mdmrecid__c;
        restRequest.httpMethod = 'GET';
        RestContext.request = restRequest;

        ServiceGetBranchAccountsByPartyId.Response response = ServiceGetBranchAccountsByPartyId.getBranchAccountsByPartyId(); 
        
        System.assertEquals('200', response.httpStatusCode);
        System.assertEquals(0, response.branchAccounts.size());
    }

    static testMethod void getBranchAccountsByPartyIdNoPartyId() 
    {
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        
     	restRequest.requestURI = '/BranchAccountsByOraclePartyId/';
        restRequest.httpMethod = 'POST';
        RestContext.request = restRequest;
        
        ServiceGetBranchAccountsByPartyId.Response response = ServiceGetBranchAccountsByPartyId.getBranchAccountsByPartyId(); 
        
        System.assertEquals('400', response.httpStatusCode);
    }
}