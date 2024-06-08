/**

**/
global with sharing class LwcDataStoreIntegration{
    
    @AuraEnabled
    global static string getFedexRate(String recordId)
    {
        system.debug('@@'+recordId);
        String partyId='4081706';
        List<Account> listAcc=[SELECT Id,mdmrecid__c FROM Account Where Id=:recordId];
        if(listAcc.size()>0){
            partyId=listAcc[0].mdmrecid__c;
        }
        List<OSC_Endpoint__mdt> searchMetaData = [SELECT Endpoint__c,UserName__c,Password__c,AppId__c FROM OSC_Endpoint__mdt WHERE DeveloperName = 'OSCConfig' ]; 
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
        str+='			and  updatedtime > \''+DateTime.now().addDays(-60)+'\' ';
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
        return response;
    }
}