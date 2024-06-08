/*
Created By: Sachin Padhiyar
Created Date: 10/22/2020 
Purpose: Test class for OMS Integration to process the JSON and insert the records on Quote.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


@isTest
public class TestOMSIntegrationAPI {
    static testMethod void testData() {
        String newJson = '[{"PoNumber": "12345","PellaToBranch": {"InitialRequestedDate": "07/17/2020","InitialEstimatedShip": "07/31/2020","InitialShipDate": "08/05/2020","ShipCompleteDate": "08/05/2020"},"BranchToCust": {"InitialScheduledDeliveryDate": "08/10/2020","FinalScheduledDeliveryDate": "08/10/2020","InitialInstallDate": "08/12/2020","FinalInstallDate": "08/12/2020"}}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OMSQuoteIntegrationInfo/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(newJson );
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Quote> quoteRecordsMap = new Map<String, Quote>();
        Apex_Debug_Log__c errorLogExRes = new Apex_Debug_Log__c();
        errorLogExRes.Apex_Class__c='OMSIntegrationAPI';
        errorLogExRes.Message__c=  'The status code : 200 Ok';
        errorLogExRes.Method__c= 'dopatch';
        errorLogExRes.Type__c= 'Information';
        insert errorLogExRes;
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=errorLogExRes.id;
        insert attach;
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:errorLogExRes.id];
        System.assertEquals(1, attachments.size());
        //Inserting Quote Object
        List<Quote> lstQuoteData =new List<Quote>();
        Quote objQuote = new Quote();
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c=DateTime.now();
        insert opp;
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='12345' ;
        q.Status='Active';
        q.PO_Number__c='12345';
        insert q ;
        quoteRecordsMap.put(q.PO_Number__c,q);
        string PoNumberUpdated = '12345';
        Quote objUpdatedQuote = new Quote();
        if(quoteRecordsMap.containskey(PoNumberUpdated))
        objUpdatedQuote.PO_Number__c=PoNumberUpdated;
        string initialDate = string.valueOf(Date.today());
        string initialEst = string.valueOf(Date.today());
        string initialShip = string.valueOf(Date.today());
        string shipComp = string.valueOf(Date.today());
        string initialScDeli = string.valueOf(Date.today());
        string initialScDe =string.valueOf(Date.today());
        string finalSc= string.valueOf(Date.today());
        string intialIns= string.valueOf(Date.today());
        
        List<String> dateParts = initialDate.split('-');
        Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        initialDate = dateWithTime.format('dd- MMM-yyyy');
        
        objUpdatedQuote.Initial_Requested_Date__c=Date.today();
        objUpdatedQuote.Initial_Estimated_Ship_Date__c=Date.today();
        objUpdatedQuote.Initial_Ship_Date__c=Date.today();
        objUpdatedQuote.Ship_Complete_Date__c=Date.today();
        objUpdatedQuote.Initial_Scheduled_Delivery_Date__c=Date.today();
        objUpdatedQuote.Final_Scheduled_Delivery_Date__c=Date.today();
        objUpdatedQuote.Initial_Install_Date__c=Date.today();
        objUpdatedQuote.Final_Install_Date__c=Date.today();
        objUpdatedQuote.id=q.id;
        lstQuoteData.add(objUpdatedQuote);
        update lstQuoteData;
        List<OMSIntegrationAPI.jSonResp> lstfinalResp = new List<OMSIntegrationAPI.jSonResp>();
        OMSIntegrationAPI.jSonResp objJson = new OMSIntegrationAPI.jSonResp();
        objJson.code = 'Failed';
        objJson.msgeText = 'Po Number not found';
        objJson.poNumber= '12345';
        lstfinalResp.add(objJson) ;
        
        //OMSIntegrationAPI.dopatch();
        OMSIntegrationAPI.dopatch();
    }
    static testMethod void testData1() {
        String newJson = '[{"PoNumber": "12345","PellaToBranch": {"InitialRequestedDate": "07/17/2020","InitialEstimatedShip": "07/31/2020","InitialShipDate": "08/05/2020","ShipCompleteDate": "08/05/2020"},"BranchToCust": {"InitialScheduledDeliveryDate": "08/10/2020","FinalScheduledDeliveryDate": "08/10/2020","InitialInstallDate": "08/12/2020","FinalInstallDate": "08/12/2020"}}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OMSQuoteIntegrationInfo/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(newJson );
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Quote> quoteRecordsMap = new Map<String, Quote>();
       
        string PoNumberUpdated = '8989';
         //Inserting Quote Object
        List<Quote> lstQuoteData =new List<Quote>();
        Quote objQuote = new Quote();
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c=DateTime.now();
        insert opp;
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        q.Status='Active';
        q.Forecasted__c=true;
        q.Ship_Complete_Date__c=system.today();
        insert q ;
        //objQuote=[select id,Name FROM Quote limit 1];
        //system.debug('objQuote=>'+objQuote);
        quoteRecordsMap.put('89899',q);
        Quote objUpdatedQuote = new Quote();
        string initialDate = string.valueOf(Date.today());
        string initialEst = string.valueOf(Date.today());
        string initialShip = string.valueOf(Date.today());
        string shipComp = string.valueOf(Date.today());
        string initialScDeli = string.valueOf(Date.today());
        string initialScDe =string.valueOf(Date.today());
        string finalSc= string.valueOf(Date.today());
        string intialIns= string.valueOf(Date.today());
        
        List<String> dateParts = initialDate.split('-');
        Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        initialDate = dateWithTime.format('dd- MMM-yyyy');
        
        objUpdatedQuote.Initial_Requested_Date__c=Date.today();
        objUpdatedQuote.Initial_Estimated_Ship_Date__c=Date.today();
        objUpdatedQuote.Initial_Ship_Date__c=Date.today();
        objUpdatedQuote.Ship_Complete_Date__c=Date.today();
        objUpdatedQuote.Initial_Scheduled_Delivery_Date__c=Date.today();
        objUpdatedQuote.Final_Scheduled_Delivery_Date__c=Date.today();
        objUpdatedQuote.Initial_Install_Date__c=Date.today();
        objUpdatedQuote.Final_Install_Date__c=Date.today();
        objUpdatedQuote.id=q.id;
        lstQuoteData.add(objUpdatedQuote);
        update lstQuoteData;
        List<OMSIntegrationAPI.jSonResp> lstfinalResp = new List<OMSIntegrationAPI.jSonResp>();
        OMSIntegrationAPI.jSonResp objJson = new OMSIntegrationAPI.jSonResp();
        //objJson.code = 'Failed';
        //objJson.msgeText = 'Po Number not found';
        //objJson.poNumber= '12345';
        lstfinalResp.add(objJson) ;
         Apex_Debug_Log__c errorLogEx = new Apex_Debug_Log__c();
        errorLogEx.Apex_Class__c='OMSIntegrationAPI';
        errorLogEx.Message__c=  'The status code : 200 Ok';
        errorLogEx.Method__c= 'dopatch';
       errorLogEx.Type__c= 'Information';
        //errorLogEx.Record_Id__c=JSON.serializePretty(lstfinalResp);
        insert errorLogEx;
        Apex_Debug_Log__c adlOnj = [select id from Apex_Debug_Log__c where id=:errorLogEx.id];
        Attachment att=new Attachment(Name='OMS Integration Response');
        att.Body=Blob.valueOf('Unit Test Attachment Body');
        att.ParentId=adlOnj.id;
        insert att; 
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:errorLogEx.id];
        System.assertEquals(1, attachments.size());
        
        OMSIntegrationAPI.dopatch();
    }
    static testMethod void testData2() {
        String newJson = '[{"PoNumber": "12345","PellaToBranch": {"InitialRequestedDate": "test","InitialEstimatedShip": "07/31/2020","InitialShipDate": "08/05/2020","ShipCompleteDate": "08/05/2020"},"BranchToCust": {"InitialScheduledDeliveryDate": "08/10/2020","FinalScheduledDeliveryDate": "08/10/2020","InitialInstallDate": "08/12/2020","FinalInstallDate": "08/12/2020"}}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OMSQuoteIntegrationInfo/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(newJson );
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Quote> quoteRecordsMap = new Map<String, Quote>();
        Apex_Debug_Log__c errorLogExRes = new Apex_Debug_Log__c();
        errorLogExRes.Apex_Class__c='OMSIntegrationAPI';
        errorLogExRes.Message__c=  'The status code : 200 Ok';
        errorLogExRes.Method__c= 'dopatch';
        errorLogExRes.Type__c= 'Information';
        insert errorLogExRes;
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=errorLogExRes.id;
        insert attach;
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:errorLogExRes.id];
        System.assertEquals(1, attachments.size());
        //Inserting Quote Object
        List<Quote> lstQuoteData =new List<Quote>();
        Quote objQuote = new Quote();
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false); 
        opp.Appointment_DateTime__c=DateTime.now();
        insert opp;
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='12345' ;
        q.Status='Active';
        q.PO_Number__c='12345';
        insert q ;
        quoteRecordsMap.put(q.PO_Number__c,q);
        string PoNumberUpdated = '12345';
        Quote objUpdatedQuote = new Quote();
        if(quoteRecordsMap.containskey(PoNumberUpdated))
        objUpdatedQuote.PO_Number__c=PoNumberUpdated;
        string initialDate = string.valueOf(Date.today());
        string initialEst = string.valueOf(Date.today());
        string initialShip = string.valueOf(Date.today());
        string shipComp = string.valueOf(Date.today());
        string initialScDeli = string.valueOf(Date.today());
        string initialScDe =string.valueOf(Date.today());
        string finalSc= string.valueOf(Date.today());
        string intialIns= string.valueOf(Date.today());
        
        List<String> dateParts = initialDate.split('-');
        Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        initialDate = dateWithTime.format('dd- MMM-yyyy');
        
        objUpdatedQuote.Initial_Requested_Date__c=Date.today();
        objUpdatedQuote.Initial_Estimated_Ship_Date__c=Date.today();
        objUpdatedQuote.Initial_Ship_Date__c=Date.today();
        objUpdatedQuote.Ship_Complete_Date__c=Date.today();
        objUpdatedQuote.Initial_Scheduled_Delivery_Date__c=Date.today();
        objUpdatedQuote.Final_Scheduled_Delivery_Date__c=Date.today();
        objUpdatedQuote.Initial_Install_Date__c=Date.today();
        objUpdatedQuote.Final_Install_Date__c=Date.today();
        objUpdatedQuote.id=q.id;
        lstQuoteData.add(objUpdatedQuote);
        update lstQuoteData;
        List<OMSIntegrationAPI.jSonResp> lstfinalResp = new List<OMSIntegrationAPI.jSonResp>();
        OMSIntegrationAPI.jSonResp objJson = new OMSIntegrationAPI.jSonResp();
        objJson.code = 'Failed';
        objJson.msgeText = 'Po Number not found';
        objJson.poNumber= '12345';
        lstfinalResp.add(objJson) ;
        
        //OMSIntegrationAPI.dopatch();
        OMSIntegrationAPI.dopatch();
        
    } 
}