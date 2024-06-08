global with sharing class OSCIntegrationController{
    @AuraEnabled
    global static string getDatePeriod()
    {
        List<OSC_Endpoint__mdt> searchMetaData = [SELECT Endpoint__c,Since_No_Of_Days__C,UserName__c,Password__c,AppId__c FROM OSC_Endpoint__mdt WHERE DeveloperName = 'OSCConfig' ]; 
        if(searchMetaData.size()>0){
            return String.valueOf(Date.today().addDays((Integer)searchMetaData[0].Since_No_Of_Days__C*-1));
        }
        return String.valueOf(Date.today());
    }
    //Get Accoount Name
    @AuraEnabled
    global static string getAccountName(String recordId)
    {
        List<Account> listAcc=[SELECT Id, Name FROM Account Where Id=:recordId];
        if(listAcc.size()>0){
            return listAcc[0].Name;
        }
        return null;
    }

    @AuraEnabled
    global static string getOSCIntegrationData(String recordId)
    {
        system.debug('@@'+recordId);
        String partyId='4081706';
        List<Account> listAcc=[SELECT Id,mdmrecid__c FROM Account Where Id=:recordId];
        if(listAcc.size()>0){
            partyId=listAcc[0].mdmrecid__c;
        }
        List<OSC_Endpoint__mdt> searchMetaData = [SELECT Endpoint__c,Since_No_Of_Days__C,UserName__c,Password__c,AppId__c FROM OSC_Endpoint__mdt WHERE DeveloperName = 'OSCConfig' ]; 
        if(searchMetaData.size()==0){
            return null;
        }
        
        String str = '<?xml version="1.0"?>	';
        str+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="urn:messages.ws.rightnow.com/v1_4">';
        str+='	<soapenv:Header>';
        str+='	<ns7:ClientInfoHeader xmlns:ns7="urn:messages.ws.rightnow.com/v1_4" soapenv:mustUnderstand="0">';
        str+='	<ns7:AppID>'+searchMetaData[0].AppId__c+'</ns7:AppID>';
        str+='	</ns7:ClientInfoHeader>';
        str+='	<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" mustUnderstand="1">';
        str+='	<wsse:UsernameToken>';
        str+='	<wsse:Username>'+searchMetaData[0].Username__c+'</wsse:Username>';
        str+='	<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+searchMetaData[0].Password__c+'</wsse:Password>';
        str+='	</wsse:UsernameToken>';
        str+='	</wsse:Security>';
        str+='	</soapenv:Header>';
        str+='   <soapenv:Body>';
        str+='      <v1:QueryCSV>';
        str+='         <v1:Query>Select Id "IncidentId", ';
        str+='         	referenceNumber "Event Number",';
        str+='         	subject "Subject",';
        str+='			StatusWithType.Status.Name "Status",';
        str+='			Incident.CustomFields.c.event_subject_type.LookupName "Event Sub Name", ';
        str+='			UpdatedTime "Time Last Updated",';
        str+='			Incident.CustomFields.c.order_num "Order Number", ';
        str+='			Incident.CustomFields.c.po_num "PO Number", ';
        str+='			createdTime "Created Date", ';
        str+='			Incident.CustomFields.c.Quote_num "Quote Number" ';
        str+='			from Incident Where  ParentOrganization.customfields.c.party_id =\''+partyId+'\' ';
        str+='			and  updatedtime > \''+DateTime.now().addDays((Integer)searchMetaData[0].Since_No_Of_Days__C*-1)+'\' ';
        str+='			ORDER by createdtime desc </v1:Query>';
        str+='      </v1:QueryCSV>';
        str+='   </soapenv:Body>';
        str+='</soapenv:Envelope>';
        
        system.debug('@@str '+str);
        //str='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="urn:messages.ws.rightnow.com/v1_4"> 	<soapenv:Header> 	<ns7:ClientInfoHeader xmlns:ns7="urn:messages.ws.rightnow.com/v1_4" soapenv:mustUnderstand="0"> 	<ns7:AppID>Salesforce</ns7:AppID> 	</ns7:ClientInfoHeader> 	<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" mustUnderstand="1"> 	<wsse:UsernameToken> 	<wsse:Username>SalesforceAPI</wsse:Username> 	<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">cH&dY7tCjY&^shW7</wsse:Password> 	</wsse:UsernameToken> 	</wsse:Security> 	</soapenv:Header>    <soapenv:Body>       <v1:QueryCSV>          <v1:Query>Select Id "IncidentId",          referenceNumber "IncidentNumber",          subject, StatusWithType.Status.Name Status, Incident.CustomFields.c.order_num, Incident.CustomFields.c.event_subject_type.LookupName "event_subject_type", Incident.CustomFields.c.event_type.Name,Incident.Organization.Name "OrganizationName" , Incident.PrimaryContact.ParentContact.CustomFields.c.party_id pri_ebs_party_id, createdTime, UpdatedTime, ParentOrganization.customfields.c.party_id from Incident Where  ParentOrganization.customfields.c.party_id =\'4081706\' ORDER by createdtime desc</v1:Query>       </v1:QueryCSV>    </soapenv:Body> </soapenv:Envelope>';
        // Instantiate a new request
        HttpRequest request = new HttpRequest();
        
        // Set request parameters
        request.setMethod('POST');
        request.setHeader('SOAPAction','QueryCSV');
        
        request.setEndpoint(searchMetaData[0].Endpoint__c);
        
        request.setBody(str);
        
        // Set the content to XML
        request.setHeader('Content-Type', 'text/xml');
        HttpResponse res=new Http().send(request);
        system.debug('@@'+res.getbody());
        
        XMLSerializer ser=new XMLSerializer();
        String response=ser.XMLToJSON(res.getbody(),new Set<string>{'Row'});
        system.debug('@@response'+ response);
        
        // Information Log
        new ApexDebugLog().createLog(
            new ApexDebugLog.Information(
                'OSCIntegrationController',
                'OSCIntegrationData',
                'URL : '+searchMetaData[0].Endpoint__c+',\n'
                +'Method : POST,\n'
                + 'Req Body : '+str,
                'OSCIntegrationData Request',
                'Integration'
            )
        );
        
        new ApexDebugLog().createLog(
            new ApexDebugLog.Information(
                'OSCIntegrationController',
                'OSCIntegrationData',
                'URL : '+searchMetaData[0].Endpoint__c+',\n'
                +'Response Body : ' + res.getBody(),
                'The status code : ' + res.getStatusCode() + ' ' + res.getStatus(),
                'Integration'
            )
        );
        if (res.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         res.getStatusCode() + ' ' + res.getStatus());
            new ApexDebugLog().createLog(
                new ApexDebugLog.Error(
                    'OSCIntegrationController',
                    'OSCIntegrationData',
                    'URL : '+searchMetaData[0].Endpoint__c+',\n'
                    +'Method : POST,\n'
                    + 'Req Body : '+str,
                    'The status code returned was not expected: ' + res.getStatusCode() + ': ' + res.getStatus() + ': ' + res.getBody(),
                    null,
                    'Integration'
                )
            );
        }
        return response;
        
    }
    /*
    @AuraEnabled
    public static AccountInfo getAccountInfo(String recordId)
    {
        AccountInfo accInfo = new AccountInfo();

        List<Account> listAcc = [SELECT Id, Name FROM Account Where Id=:recordId];
        if(listAcc.size()>0){
            accInfo.accountName = listAcc[0].Name;
        }

        List<OSC_Endpoint__mdt> searchMetaData = [SELECT Endpoint__c,Since_No_Of_Days__C,UserName__c,Password__c,AppId__c FROM OSC_Endpoint__mdt WHERE DeveloperName = 'OSCConfig' ]; 
        accInfo.DateBeforeSixtyDays = String.valueOf(Date.today()); 
        if(searchMetaData.size()>0){
            accInfo.DateBeforeSixtyDays = String.valueOf(Date.today().addDays((Integer)searchMetaData[0].Since_No_Of_Days__C*-1));
        }

        return accInfo ;
    }*/

    /*@AuraEnabled
    public static AccountInfo getOSCServiceData(String recordId)
    {
        System.debug('UAC: accountId '+ recordId);
        
        String partyId='4081706';

        AccountInfo accInfo = new AccountInfo();

        List<Account> listAcc = [SELECT Id, Name, mdmrecid__c FROM Account Where Id=:recordId];
        if(listAcc.size()>0){
            accInfo.accountName = listAcc[0].Name;
            partyId = listAcc[0].mdmrecid__c;
        }

        List<OSC_Endpoint__mdt> searchMetaData = [SELECT Endpoint__c,Since_No_Of_Days__C,UserName__c,Password__c,AppId__c FROM OSC_Endpoint__mdt WHERE DeveloperName = 'OSCConfig' ]; 
        accInfo.DateBeforeSixtyDays = String.valueOf(Date.today()); 
        if(searchMetaData.size()>0){
            accInfo.DateBeforeSixtyDays = String.valueOf(Date.today().addDays((Integer)searchMetaData[0].Since_No_Of_Days__C*-1));
        }

        String str = '<?xml version="1.0"?>	';
        str+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="urn:messages.ws.rightnow.com/v1_4">';
        str+='	<soapenv:Header>';
        str+='	<ns7:ClientInfoHeader xmlns:ns7="urn:messages.ws.rightnow.com/v1_4" soapenv:mustUnderstand="0">';
        str+='	<ns7:AppID>'+searchMetaData[0].AppId__c+'</ns7:AppID>';
        str+='	</ns7:ClientInfoHeader>';
        str+='	<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" mustUnderstand="1">';
        str+='	<wsse:UsernameToken>';
        str+='	<wsse:Username>'+searchMetaData[0].Username__c+'</wsse:Username>';
        str+='	<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+searchMetaData[0].Password__c+'</wsse:Password>';
        str+='	</wsse:UsernameToken>';
        str+='	</wsse:Security>';
        str+='	</soapenv:Header>';
        str+='   <soapenv:Body>';
        str+='      <v1:QueryCSV>';
        str+='         <v1:Query>Select Id "IncidentId", ';
        str+='         	referenceNumber "Event Number",';
        str+='         	subject "Subject",';
        str+='			StatusWithType.Status.Name "Status",';
        str+='			Incident.CustomFields.c.event_subject_type.LookupName "Event Sub Name", ';
        str+='			UpdatedTime "Time Last Updated",';
        str+='			Incident.CustomFields.c.order_num "Order Number", ';
        str+='			Incident.CustomFields.c.po_num "PO Number", ';
        str+='			createdTime "Created Date", ';
        str+='			Incident.CustomFields.c.Quote_num "Quote Number" ';
        str+='			from Incident Where  ParentOrganization.customfields.c.party_id =\''+partyId+'\' ';
        str+='			and  updatedtime > \''+DateTime.now().addDays((Integer)searchMetaData[0].Since_No_Of_Days__C*-1)+'\' ';
        str+='			ORDER by createdtime desc </v1:Query>';
        str+='      </v1:QueryCSV>';
        str+='   </soapenv:Body>';
        str+='</soapenv:Envelope>';
        
        //system.debug('@@str '+str);
        //str='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="urn:messages.ws.rightnow.com/v1_4"> 	<soapenv:Header> 	<ns7:ClientInfoHeader xmlns:ns7="urn:messages.ws.rightnow.com/v1_4" soapenv:mustUnderstand="0"> 	<ns7:AppID>Salesforce</ns7:AppID> 	</ns7:ClientInfoHeader> 	<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" mustUnderstand="1"> 	<wsse:UsernameToken> 	<wsse:Username>SalesforceAPI</wsse:Username> 	<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">cH&dY7tCjY&^shW7</wsse:Password> 	</wsse:UsernameToken> 	</wsse:Security> 	</soapenv:Header>    <soapenv:Body>       <v1:QueryCSV>          <v1:Query>Select Id "IncidentId",          referenceNumber "IncidentNumber",          subject, StatusWithType.Status.Name Status, Incident.CustomFields.c.order_num, Incident.CustomFields.c.event_subject_type.LookupName "event_subject_type", Incident.CustomFields.c.event_type.Name,Incident.Organization.Name "OrganizationName" , Incident.PrimaryContact.ParentContact.CustomFields.c.party_id pri_ebs_party_id, createdTime, UpdatedTime, ParentOrganization.customfields.c.party_id from Incident Where  ParentOrganization.customfields.c.party_id =\'4081706\' ORDER by createdtime desc</v1:Query>       </v1:QueryCSV>    </soapenv:Body> </soapenv:Envelope>';
        // Instantiate a new request
        HttpRequest request = new HttpRequest();
        
        // Set request parameters
        request.setMethod('POST');
        request.setHeader('SOAPAction','QueryCSV');
        
        request.setEndpoint(searchMetaData[0].Endpoint__c);
        
        request.setBody(str);
        
        // Set the content to XML
        request.setHeader('Content-Type', 'text/xml');
        HttpResponse res=new Http().send(request);
        
        XMLSerializer ser=new XMLSerializer();
        String response=ser.XMLToJSON(res.getbody(),new Set<string>{'Row'});
        System.debug('UAC: OSCResponse '+ response);
        
        OSCResponse oscRes = (OSCResponse)JSON.deserialize(response, OSCResponse.class);
        System.debug('UAC: oscRes ' + oscRes.Envelope.Body.QueryCSVResponse.CSVTableSet.CSVTables.CSVTable.Rows.Row );

        List<Result> results = new List<Result>();
        accInfo.results = results;

        for(Row rowData : oscRes.Envelope.Body.QueryCSVResponse.CSVTableSet.CSVTables.CSVTable.Rows.Row )
        {
            System.debug('UAC: rowData ' + rowData );
            Integer startIndex = rowData.value.indexOf('"') ;
            Integer endIndex = rowData.value.indexOf('"', startIndex + 1) ;
            String originalSubject ;
            String fakeSubject ;

            // When Multiple commas are in Subject then replace commas in subject with double pipe || sign 
            System.debug('UAC: ' + startIndex + ' endIndex ' + endIndex );
            if(startIndex > 0 && endIndex > 0)
            {
                originalSubject = rowData.value.subString(startIndex, endIndex+1);
                System.debug('UAC: originalSubject ' + originalSubject);
                fakeSubject = originalSubject.replace(',', '||');
                System.debug('UAC: fakeSubject ' + fakeSubject);
                rowData.value = rowData.value.replace(originalSubject, fakeSubject);
            }

            List<String> colValues = rowData.value.split(',');

            Result rs = new Result();
            rs.fullString = rowData.value ;
            rs.incidentId = colValues[0];
            rs.eventNumber = colValues[1];
            rs.subject = colValues[2].replace('||', ','); // Replace double Pipe with commas again
            rs.status = colValues[3];
            rs.eventSubName = colValues[4];
            System.debug('UAC: lastUpdated ' + colValues[5].left(4) + ' month ' + colValues[5].subString(5,7) + ' day ' + colValues[5].subString(8,10) );
            rs.lastUpdated = Date.newInstance(Integer.valueOf(colValues[5].left(4)), Integer.valueOf(colValues[5].subString(5,7)), Integer.valueOf(colValues[5].subString(8,10)));  //(Datetime)JSON.deserialize('"' + colValues[5].replace('Z', '') + '"', Datetime.class); 
            rs.orderNumber = colValues[6];
            rs.pONumber = colValues[7] ;
            rs.createdDate = Date.newInstance(Integer.valueOf(colValues[8].left(4)), Integer.valueOf(colValues[8].subString(5,7)), Integer.valueOf(colValues[8].subString(8,10)));  
            if(colValues.size() > 9) rs.quoteNumber = colValues[9];
            results.add(rs);
        }
        return accInfo ;
    }
    
    public class AccountInfo 
    {
        @AuraEnabled public String DateBeforeSixtyDays ;
        @AuraEnabled public String accountName ;
        @AuraEnabled public List<Result> results = new List<Result>();
    }

    public class Result 
    {
        @AuraEnabled public String incidentId ;
        @AuraEnabled public String eventNumber ;
        @AuraEnabled public String subject ;
        @AuraEnabled public String status ;
        @AuraEnabled public String eventSubName ;
        @AuraEnabled public Date lastUpdated ;
        @AuraEnabled public String orderNumber ;
        @AuraEnabled public String quoteNumber ;
        @AuraEnabled public String pONumber ;
        @AuraEnabled public Date createdDate ;
        @AuraEnabled public String fullString ;
    }
    public class OSCResponse {
        public Envelope Envelope;
    }
    
    public class Row {
        public String value;
    }
    
    public class Rows {
        public List<Row> Row;
    }
    
    public class Name {
        public String value;
    }
    
    public class Columns {
        public String value;
    }
    
    public class CSVTable {
        public Rows Rows;
        public Name Name;
        public Columns Columns;
    }
    
    public class CSVTables {
        public CSVTable CSVTable;
    }
    
    public class CSVTableSet {
        public CSVTables CSVTables;
    }
    
    public class QueryCSVResponse {
        public String n0;
        public String xsi;
        public CSVTableSet CSVTableSet;
    }
    
    public class Body {
        public QueryCSVResponse QueryCSVResponse;
    }
    
    public class Token {
        public String value;
    }
    
    public class NextRequestAfter {
        public String value;
    }
    
    public class APIAccessResponseHeader {
        public String n0;
        public Token Token;
        public String xsi;
        public NextRequestAfter NextRequestAfter;
    }
    
    public class Header {
        public APIAccessResponseHeader APIAccessResponseHeader;
    }
    
    public class Envelope {
        public Body Body;
        public Header Header;
        public String soapenv;
    }   */ 
}