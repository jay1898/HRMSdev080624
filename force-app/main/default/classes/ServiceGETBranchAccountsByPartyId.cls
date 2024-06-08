@RestResource(urlMapping='/BranchAccountsByOraclePartyId/*')
global without sharing class ServiceGETBranchAccountsByPartyId
{
    //Response class
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public List<BranchAccount> branchAccounts = new List<BranchAccount>() ;

        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    } 
    
    global class BranchAccount
    {
        public Id Id;
        public String Name ;
        public Id BranchId ;
        public List<String> ServiceTerritoryZipcodes;
    }

    @HttpGet
    global static Response getBranchAccountsByPartyId()
    {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        Response res = new Response();

        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');


        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && cs.Disable_All__c) return res ;

        Request req;
        String partyId =  restReq.requestURI.substring(restReq.requestURI.lastIndexOf('/')+1);
        system.debug('PartyId: ' + partyId);
        if(String.isBlank(partyId) || partyId == '')
        {
             res.httpStatusCode = '400';
             res.status = 'INVALID_INPUT_PARAMETER';
             res.errorMessage = 'Please provide a valid ID';
             return res;
        }
 
        Map<Id, Account> childAccountMap = new Map<Id, Account>();
        Map<Id, Id> childAccountBranchIdMap = new Map<Id, Id>();
        Id zipcodeTerritoryRecordTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();

        List<Account> accountList = [
            SELECT Id, Name, (SELECT Id, Name, Branch__c FROM ChildAccounts) 
            FROM Account 
            WHERE mdmrecid__c =: partyId
        ];

        for (Account account : accountList) {
            for (Account childAccount : account.ChildAccounts) {
                childAccountMap.put(childAccount.Id, childAccount);
                childAccountBranchIdMap.put(childAccount.Id, childAccount.Branch__c);
            }
        }

        Map<Id, List<String>> branchZipcodeMap = new Map<Id, List<String>> ();
        List<ServiceTerritory> serviceTerritoriesList = [
            SELECT Id, PostalCode, ParentTerritory.ParentTerritory.Branch__r.Id
            FROM ServiceTerritory 
            WHERE ParentTerritory.ParentTerritory.Branch__r.Id IN : childAccountBranchIdMap.values() 
            AND RecordTypeId =: zipcodeTerritoryRecordTypeId 
        ];

        for (ServiceTerritory serviceTerritory : serviceTerritoriesList) {
            if(!branchZipcodeMap.containsKey(serviceTerritory.ParentTerritory.ParentTerritory.Branch__r.Id)){
                branchZipcodeMap.put(serviceTerritory.ParentTerritory.ParentTerritory.Branch__r.Id, new List<String>());
            }
            branchZipcodeMap.get(serviceTerritory.ParentTerritory.ParentTerritory.Branch__r.Id).add(serviceTerritory.PostalCode);
        }

        for (Account childAccount : childAccountMap.values()) {
            BranchAccount branchAccount = new BranchAccount();
            branchAccount.id = childAccount.Id;
            branchAccount.name = childAccount.Name;
            branchAccount.branchId = childAccount.Branch__c;
            branchAccount.serviceTerritoryZipcodes = branchZipcodeMap.get(childAccount.Branch__c);

            res.branchAccounts.add(branchAccount);
        }

        return res;
    }
}