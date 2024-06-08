@isTest
public with sharing class PQMInboundCallTest {
    
    @isTest
    public static void testDocallout() {
        String recorddata='{ "0": { "earliestLRD": null, "quotenumber": "12403929", "quotename": "Hammalian,Debbie,2454597", "salesrepusername": "ROUSEJ", "status": "Contracted", "bookdate": null, "signedContractdate": "03/11/2020", "ponumber": "751K25742", "quantity": 3, "customerextendedprice": 19679.01, "totalBACprice": 3976.92, "forecast": "True", "opportunity": "2454597", "partyid": "17916075", "brandcount": [ { "brand": "Lifestyle Without Hinged Glass Panel", "count": 3, "customerextendedprice": 12420.51, "totalBACprice": 3509.94, "productCount": [ { "producttype": "DoubleSlidingDoor", "count": 3, "customerextendedprice": 12420.51, "totalBACprice": 3509.94 } ] } ] } }';
       Apex_Debug_Log__c objLog = new  Apex_Debug_Log__c(Record_Id__c=recorddata,Message__c='postData: Received Request');
        insert objLog;
        PQMInboundCall.docallout(objLog.Id);
    }
}