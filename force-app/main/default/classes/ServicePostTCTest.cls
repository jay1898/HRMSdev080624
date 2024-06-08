@isTest
public class ServicePostTCTest {
    static testMethod void testMethod1(){
        User u = TestUtil.createUser(false);
        u.EBS_UserName__c = 'EBSTCTest';
        insert u;
        System.runAs(u){
            Account ac = TestUtil.createAccount('Person Account', true);
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', false);
            bf.Branch_Family_Number__c = '610';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2 t2 = TestUtil.createTerritory2(branch.Id, activetypeId, true);
            
            UserTerritory2Association UserTerritoryAssoc = TestUtil.createUserTerritory2Association(u.Id, t2.Id, true);
            
            Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
            
            Address__c ad = TestUtil.createAddress(true);
            
            Address_Assignment__c aa = new Address_Assignment__c(Address__c = ad.Id, Account_Branch_Profile__c = abp.Id, Primary_Flag__c = true, Identifying_Address__c = false, Status__c = 'Active');
            insert aa;
            
            Lead ld = new Lead(LastName = 'Demo' , FirstName = 'Test' , LeadSource = 'LeadSource' , HomePhone__c = '(317) 555-1212');
            insert ld;
            
            
            Test.startTest();
            
            String jsonStr2 = '{"byuser":"EBSTCTest","partynumber":1008339670,"orgname":"AB Builders LLC","partytype":"ORGANIZATION","partysubtype":"REMCONT","status":"A","mdmpartyid":11791781,"spokesystemcode":"EBS","spokerecid":11791781,"profiles":[{"profileattributes":[{"name":"CALL","value":"No"},{"name":"AUTOCALL","value":"Yes"},{"name":"EMAIL","value":"No"},{"name":"SMS","value":"Yes"},{"name":"MAIL","value":"Yes"}]}],"contactmethods":[{"methodvalue":"402326-3129","byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791781,"spokesystemcode":"EBS","spokerecid":14797988,"methodsubtype":"GEN"},{"methodvalue":"abbuilders1@yahoo.com","byuser":"EBSTCTest","methodname":"EMAIL","primaryflag":"Y","status":"A","mdmpartyid":11791781,"spokesystemcode":"EBS","spokerecid":14797988,"methodsubtype":"GEN"},{"methodvalue":"402326-3129","byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791781,"spokesystemcode":"EBS","spokerecid":14797988,"methodpurpose":"HOME","methodlinetype":"PHONEDAY"},{"methodvalue":"402326-3129","byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791781,"spokesystemcode":"EBS","spokerecid":14797988,"methodpurpose":"MOBILE","methodlinetype":"PHONEDAY"},{"methodvalue":"402326-3129","byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791781,"spokesystemcode":"EBS","spokerecid":14797988,"methodpurpose":"WORK","methodlinetype":"PHONEDAY"},{"methodvalue":"402326-3129","byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791781,"spokesystemcode":"EBS","spokerecid":14797988,"methodpurpose":"HOME","methodlinetype":"PHONEEVE"}],"accounts":[{"accountnumber":1004281143,"spokerecid":17426467,"spokesystemcode":"EBS","byuser":"EBSTCTest","status":"A","mdmaccountid":17426467,"mdmorgid":610,"mdmpartyid":11791781,"sites":[{"addressusagecode":"BILL_TO","identifyingaddress":"Y","siteusestatus":"A","primaryflag":"Y","status":"A","spokerecid":12224399,"spokesystemcode":"EBS","mdmaddressid":12224399,"address":{"addressline1":"315 17th St","city":"AURORA","country":"US","spokerecid":11686148,"spokesystemcode":"EBS","byuser":"EBSTCTest","mdmaddressid":11686148,"county":"HAMILTON","state":"NE","zipcode":"68818-2810"}}]}],"contacts":[{"firstname":"Adam","lastname":"Hurt","contactmethods":[{"methodvalue":"abbuilders1@yahoo.com","byuser":"EBSTCTest","methodname":"EMAIL","primaryflag":"Y","status":"A","mdmpartyid":11791820,"spokesystemcode":"EBS","spokerecid":16528896},{"methodvalue":4023263129,"byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791820,"spokesystemcode":"EBS","spokerecid":14798041,"methodsubtype":"MOBILE"},{"methodvalue":4023263129,"byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791820,"spokesystemcode":"EBS","spokerecid":14798041,"methodpurpose":"HOME","methodlinetype":"PHONEDAY"},{"methodvalue":4023263129,"byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791820,"spokesystemcode":"EBS","spokerecid":14798041,"methodpurpose":"MOBILE","methodlinetype":"PHONEDAY"},{"methodvalue":4023263129,"byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791820,"spokesystemcode":"EBS","spokerecid":14798041,"methodpurpose":"WORK","methodlinetype":"PHONEDAY"},{"methodvalue":4023263129,"byuser":"EBSTCTest","methodname":"PHONE","primaryflag":"Y","status":"A","mdmpartyid":11791820,"spokesystemcode":"EBS","spokerecid":14798041,"methodpurpose":"HOME","methodlinetype":"PHONEEVE"}],"sites":[{"identifyingaddress":"Y","status":"A","spokerecid":12224446,"spokesystemcode":"EBS","mdmaddressid":12224446,"address":{"addressline1":"315 17th St.","city":"Central City","country":"US","spokerecid":11686195,"spokesystemcode":"EBS","byuser":"EBSTCTest","mdmaddressid":11686195,"county":"Merrick","state":"NE","zipcode":68818}}],"status":"A","mdmcontactid":5154781,"contactnumber":1817308,"contactstatus":"A","mdmpartyid":11791781}]}';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestBody = Blob.valueOf(jsonStr2);
            RestContext.request = req;
            RestContext.response = res;
            ServicePostTC.postData();
            ServicePostTC.postData();
            Test.stopTest();
            
        }
        
    }
    
}