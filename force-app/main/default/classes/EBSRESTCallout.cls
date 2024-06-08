/*
Created By: Anh Phan
Created Date: 11/21/2019
Purpose: EBS callout from apex to send information/data.
----------------------------------------------------------------------------------------------
Modified By: Sachin Padhiyar
Modified Date.: 4/1/2020
Purpose: Retunning status code form createCustomerEBSData method to indentify error or success. 
------------------------------------------------------------------------------------------------
*/

public class EBSRESTCallout {
    
    @future(callout=true)
    public static void updateCustomerEBSCallout(String AccId,String SetNullBody) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        updateCustomerEBSData(AccId,SetNullBody); 
        
    }//End of updateCustomerEBSCallout
    @future(callout=true)
    public static void updateCustomerEBSCallout(String AccId,boolean isOwnerChange) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        updateCustomerEBSData(AccId,isOwnerChange,''); 
        
    }//End of updateCustomerEBSCallout
    public static void updateCustomerEBSData(String accId, String SetNullBody) {
        updateCustomerEBSData(AccId,false,SetNullBody);  
    }
    public static void updateCustomerEBSData(String accId,boolean isOwnerChange,String SetNullBody) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
            if(accId == Label.Order_PLACEHOLDER_ACCOUNT) return;
            List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EBS_Customer_Parties' ]; 
            
            Account acc=[SELECT Id,mdmrecid__c,branchaccmdmrecid__c,parent.mdmrecid__c,recordType.DeveloperName FROM Account WHERE Id= :accId Limit 1];
             if((acc.recordType.DeveloperName!='BranchAccount' && acc.mdmrecid__c!=null) || (acc.recordType.DeveloperName=='BranchAccount' && acc.branchaccmdmrecid__c!=null)){
                String mdmrecId=(acc.recordType.DeveloperName=='BranchAccount'?acc.parent.mdmrecid__c:acc.mdmrecid__c);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce');
                request.setMethod('PUT');
                request.setHeader('Authorization', 'Bearer '+ebsMetaData[0].Token__c);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                request.setTimeout(120000);
                
                //request.setHeader('callingsystem', 'Salesforce');
                String reqBody = CustomerRequest.updateCustomerRequest(accId,isOwnerChange,SetNullBody);
                System.debug('UAC: EBSRESTCallout reqBody ' + reqBody );
                // Set the body as a JSON object
                request.setBody(reqBody);
                HttpResponse response = http.send(request);
                
                // Information Log
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Information(
                        'EBSRESTCallout',
                        'updateCustomerEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                        +'Method : PUT,\n'
                        + 'Req Body : '+reqBody,
                        'updateCustomerEBSData Request',
                        'Integration'
                    )
                );
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Information(
                        'EBSRESTCallout',
                        'updateCustomerEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                        +'Response Body : ' + response.getBody(),
                        'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                        'Integration'
                    )
                );
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                    new ApexDebugLog().createLog(
                        new ApexDebugLog.Error(
                            'EBSRESTCallout',
                            'updateCustomerEBSData',
                            'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                            +'Method : PUT,\n'
                            + 'Req Body : '+reqBody,
                            'The status code returned was not expected: ' + response.getStatusCode() + ': ' + response.getStatus() + ': ' + response.getBody(),
                            null,
                            'Integration'
                        )
                    );
                } else {
                    System.debug(response.getBody());
                    CustomerRequest.handleUpdateCustomerResponse(response.getBody());
                    
                }
            }
            
        }catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('EBSRESTCallout','updateCustomerEBSData',accId,ex,'Integration'));
        }
        
        
    }//End of updateCustomerEBSData
    
    @future(callout=true)
    public static void createCustomerEBSCallout(String AccId) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        createCustomerEBSData(AccId); 
        
    }//End of createCustomerEBSCallout
    
    public static string createCustomerEBSData(String accId) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return'Custom Setting Disable';
            Account acc=[SELECT Id,mdmrecid__c,branchaccmdmrecid__c,parent.mdmrecid__c,recordType.DeveloperName FROM Account WHERE Id= :accId Limit 1];
            
            List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EBS_Customer_Parties' ]; 
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String requestURL=ebsMetaData[0].Endpoint__c+'/party?callingsystem=Salesforce';
            string requetMethod='POST';
            if(acc.parent.mdmrecid__c==null || acc.RecordType.DeveloperName=='Pro_Lowes'){
                request.setEndpoint(ebsMetaData[0].Endpoint__c+'/party?callingsystem=Salesforce');
                request.setMethod('POST');
            }else{
                request.setEndpoint(ebsMetaData[0].Endpoint__c+'/'+acc.parent.mdmrecid__c+'?callingsystem=Salesforce');
                request.setMethod('PUT');
                requestURL=ebsMetaData[0].Endpoint__c+'/'+acc.parent.mdmrecid__c+'?callingsystem=Salesforce';
                requetMethod='PUT';
                
            }
            request.setHeader('Authorization', 'Bearer '+ebsMetaData[0].Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            //request.setHeader('callingsystem', 'Salesforce');
            String reqBody = CustomerRequest.createCustomerRequest(accId);
            // Set the body as a JSON object
            system.debug('Req Body :: '+reqBody);
            request.setBody(reqBody);
            
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            system.debug('response.getStatusCode() :: '+response.getStatusCode());
            system.debug('Response Body :: '+response.getBody());
            
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createCustomerEBSData',
                    'URL : '+requestURL+',\n'
                    +'Method : '+requetMethod+',\n'
                    + 'Req Body : '+reqBody,
                    'createCustomerEBSData Request',
                    'Integration'
                )
            );
            
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createCustomerEBSData',
                    'URL : '+requestURL+',\n'
                    +'Response Body : ' + response.getBody(),
                    'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                    'Integration'
                )
            );
            
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'EBSRESTCallout',
                        'createCustomerEBSData',
                        reqBody,
                        'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(),
                        null,
                        'Integration'
                    )
                );
                System.debug('The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
                return CustomerRequest.handleCustomerResponse(response.getBody());
            }
            system.debug('-----------'+ response.getStatus());
            return response.getStatus();
        }catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('EBSRESTCallout','createCustomerEBSData',accId,ex,'Integration'));
            return ex.getmessage();
        }
        
    }//End of createCustomerEBSData
    
    @future(callout=true)
    public static void createLeadEBSCallout(String leadId) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        createLeadEBSData(leadId); 
        
    }
    public static void createLeadEBSData(String leadId) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
            
            List<Endpoint_Configuration__mdt> ecMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Lead_Status_To_EBS' ]; 
            
            // Lead leadObject=[SELECT Id FROM Lead WHERE Id= :leadId Limit 1];
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ecMetaData[0].Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer '+ecMetaData[0].Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(120000);
            
            //request.setHeader('callingsystem', 'Salesforce');
            String reqBody = CustomerRequest.createLeadRequest(leadId);
            // Set the body as a JSON object
            request.setBody(reqBody);
            System.debug('reqBody :::' + reqBody);
            HttpResponse response = http.send(request);
            System.debug('respons :::' + response);
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createLeadEBSData',
                    'URL : ' + ecMetaData[0].Endpoint__c + ',\n'
                    +'Method : POST,\n'
                    + 'Req Body : '+reqBody,
                    'createLeadEBSData RequestBody',
                    'Integration'
                )
            );
            
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createLeadEBSData',
                    'URL : ' + ecMetaData[0].Endpoint__c + ',\n'
                    +'Response Body : ' + response.getBody(),
                    'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                    'Integration'
                )
            );
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'EBSRESTCallout',
                        'createLeadEBSData',
                        reqBody,
                        'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(),
                        null,
                        'Integration'
                    )
                );
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug('responsbody'+response.getBody());
            }
        }catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('EBSRESTCallout','createLeadEBSData',leadId,Ex,'Integration'));
        }
        
        
    } //End of createLeadEBSData
    
    @future(callout=true)
    public static void createOpportunityEBSCallout(String oppId) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        createOpportunityEBSData(oppId); 
        
    }
    public static void createOpportunityEBSData(String oppId) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
            
            List<Endpoint_Configuration__mdt> ecMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Lead_Status_To_EBS' ]; 
            
            // Lead leadObject=[SELECT Id FROM Lead WHERE Id= :leadId Limit 1];
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ecMetaData[0].Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer '+ecMetaData[0].Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(120000);
            
            //request.setHeader('callingsystem', 'Salesforce');
            String reqBody = CustomerRequest.createOpportunityRequest(oppId);
            // Set the body as a JSON object
            request.setBody(reqBody);
            System.debug('reqBody :::' + reqBody);
            HttpResponse response = http.send(request);
            System.debug('respons :::' + response);
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createOpportunityEBSData',
                    'URL : ' + ecMetaData[0].Endpoint__c + ',\n'
                    +'Method : POST,\n'
                    + 'Req Body : '+reqBody,
                    'createOpportunityEBSData RequestBody',
                    'Integration'
                )
            );
            
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createOpportunityEBSData',
                    'URL : ' + ecMetaData[0].Endpoint__c + ',\n'
                    +'Response Body : ' + response.getBody(),
                    'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                    'Integration'
                )
            );
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'EBSRESTCallout',
                        'createOpportunityEBSData',
                        reqBody,
                        'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(),
                        null,
                        'Integration'
                    )
                );
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug('responsbody'+response.getBody());
            }
        }catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('EBSRESTCallout','createOpportunityEBSData',oppId,Ex,'Integration'));
        }
        
        
    } //End of createOpportunityEBSData 
    
    @future(callout=true)
    public static void createAddressAssignmentEBSCallout(String AAId,String typeFor) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        createAddressAssignmentEBSData(AAId,typeFor); 
        
    }//End of createAddressAssignmentEBSCallout 
    
    public static void createAddressAssignmentEBSData(String AAId,String typeFor) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
            
            List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EBS_Customer_Account' ]; 
            Address_Assignment__c AA=[SELECT Id,HQ_Bill_To__r.MDMrecid__c,Account__r.owner.EBS_UserName__c, Name,Account__r.mdmrecid__c,Account_Branch_Profile__r.party_account__c,Account_Branch_Profile__r.mdmrecid__c,Account_Branch_Profile__r.party_account__r.mdmrecid__c, Address__c,Address__r.MDMrecid__c ,MDMrecid__c ,Account_Branch_Profile__c, Full_Address__c, Primary_Flag__c, Identifying_Address__c, Status__c, Address_Usage_Type__c, 
                                      Address__r.Name,Account__r.branchaccmdmrecid__c,Account__c,Account_Branch_Profile__r.Branch__r.Branch_Number__c, Address__r.Street__c, Address__r.City__c, Address__r.Country__c,Address__r.Address_Line_1__c,Address__r.Address_Line_3__c, Address__r.State__c, Address__r.Zipcode__c, Address__r.County__c, Address__r.Location_Id__c
                                      ,Account__r.Branch__r.T_C_Branch_Number__c,Account__r.Branch_Number__C,Account__r.RecordType.DeveloperName  FROM Address_Assignment__c where id = :AAId limit 1];
            if(AA.Account_Branch_Profile__r.MDMrecid__c!=null || AA.Account__r.branchaccmdmrecid__c!=null){
                String mdmrecId=(AA.Account__c==null?AA.Account_Branch_Profile__r.mdmrecid__c:AA.Account__r.branchaccmdmrecid__c);
                if(AA.Account__c!=null && AA.Account__r.RecordType.DeveloperName=='Pro_Lowes'){
                    mdmrecId=AA.Account__r.branchaccmdmrecid__c;
                }
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'/sites?callingsystem=Salesforce');
                if(typeFor.equalsIgnoreCase('Insert')){
                    request.setMethod('POST');
                }else{
                    request.setMethod('POST');
                }
                request.setHeader('Authorization', 'Bearer '+ebsMetaData[0].Token__c);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                //request.setHeader('callingsystem', 'Salesforce');
                String reqBody = CustomerRequest.createUpdateAARequest(AA);
                // Set the body as a JSON object
                system.debug('Req Body :: '+reqBody);
                request.setBody(reqBody);
                
                request.setTimeout(120000);
                HttpResponse response = http.send(request);
                system.debug('response.getStatusCode() :: '+response.getStatusCode());
                system.debug('Response Body :: '+response.getBody());
                
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Information(
                        'EBSRESTCallout',
                        'createAddressAssignmentEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'/sites?callingsystem=Salesforce,\n'
                        +'Method : POST,\n'
                        + 'Req Body : '+reqBody,
                        'createAddressAssignmentEBSData Request',
                        'Integration'
                    )
                );
                
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Information(
                        'EBSRESTCallout',
                        'createAddressAssignmentEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'/sites?callingsystem=Salesforce,\n'
                        +'Response Body : ' + response.getBody(),
                        'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                        'Integration'
                    )
                );
                
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    new ApexDebugLog().createLog(
                        new ApexDebugLog.Error(
                            'EBSRESTCallout',
                            'createAddressAssignmentEBSData',
                            reqBody,
                            'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(),
                            null,
                            'Integration'
                        )
                    );
                    System.debug('The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug(response.getBody());
                    CustomerRequest.handleCustomerResponse(response.getBody());
                }
            }else{
                /* new ApexDebugLog().createLog(
new ApexDebugLog.Error(
'EBSRESTCallout',
'createAddressAssignmentEBSData',
aaId,
'MDMrecid Field on related  Account branch profile is empty \n ABPId:'+AA.Account_Branch_Profile__c,
'Integration'
)
);*/
            }
        }catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error( 'EBSRESTCallout','createAddressAssignmentEBSData',aaId,ex, 'Integration'));
        }
        
    }//End of createAddressAssignmentEBSData
    
    
    @future(callout=true)
    public static void updateAddressEBSCallout(String addressId) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        updateAddressEBSData(addressId); 
        
    }//End of updateAddressEBSCallout 
    
    public static void updateAddressEBSData(String addressId) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
            
            List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EBS_Customer_Address' ]; 
            Address__c address=[SELECT Id,Address_Line_1__c,Address_Line_3__c,Street__c, City__c, State__c, Country__c, Zipcode__c, County__c, Location_Id__c, MDMrecid__c 
                                FROM Address__c WHERE Id=:addressId LIMIT 1];
            
            if(address.MDMrecid__c!=null){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(ebsMetaData[0].Endpoint__c+'/'+address.mdmrecid__c+'?callingsystem=Salesforce');
                request.setMethod('PUT');
                
                request.setHeader('Authorization', 'Bearer '+ebsMetaData[0].Token__c);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                //request.setHeader('callingsystem', 'Salesforce');
                String reqBody = CustomerRequest.createUpdateAddressRequest(address);
                // Set the body as a JSON object
                system.debug('Req Body :: '+reqBody);
                request.setBody(reqBody);
                
                request.setTimeout(120000);
                HttpResponse response = http.send(request);
                system.debug('response.getStatusCode() :: '+response.getStatusCode());
                system.debug('Response Body :: '+response.getBody());
                
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Information(
                        'EBSRESTCallout',
                        'updateAddressEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+address.mdmrecid__c+'?callingsystem=Salesforce,\n'
                        +'Method : PUT,\n'
                        + 'Req Body : '+reqBody,
                        'updateAddressEBSData Request',
                        'Integration'
                    )
                );
                
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Information(
                        'EBSRESTCallout',
                        'updateAddressEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+address.mdmrecid__c+'?callingsystem=Salesforce,\n'
                        +'Response Body : ' + response.getBody(),
                        'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                        'Integration'
                    )
                );
                
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    new ApexDebugLog().createLog(
                        new ApexDebugLog.Error(
                            'EBSRESTCallout',
                            'updateAddressEBSData',
                            reqBody,
                            'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(),
                            null,
                            'Integration'
                        )
                    );
                    System.debug('The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug(response.getBody());
                    CustomerRequest.handleCustomerResponse(response.getBody());
                }
            }else{
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'EBSRESTCallout',
                        'updateAddressEBSData',
                        address.Id,
                        'MDMrecid Field on related  Address ',
                        'Integration'
                    )
                );
            }
        }catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('EBSRESTCallout','updateAddressEBSData',addressId,ex,'Integration'));
        }
        
    }//End of updateAddressEBSData
    
    @future(callout=true)
    public static void createUpdateContactToEBSCallout(String ConId) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        createUpdateContactToEBSData(ConId); 
        
    }//End of createUpdateContactToEBSCallout
    public static void createUpdateContactToEBSData(String ConId) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
            
            List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EBS_Customer_Account' ]; 
            
            Contact con=[SELECT Id, LastName, FirstName,Contact_Type__c, Name,Org_Contact_ID__c, mdmrecid__c,Account.mdmrecid__c,Account.parent.mdmrecid__c,Account.branchaccmdmrecid__c , HomePhone FROM Contact WHERE Id= :ConId Limit 1];
            system.debug('con: '+con);
            
            String mdmrecId=con.Account.branchaccmdmrecid__c ;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
             
            request.setEndpoint(ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce');
            request.setMethod('PUT');
            request.setHeader('Authorization', 'Bearer '+ebsMetaData[0].Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(120000);
            
            //request.setHeader('callingsystem', 'Salesforce');
            String reqBody = CustomerRequest.createContactRequest(ConId);
            System.debug('UAC: EBSRESTCallout contact reqBody ' + reqBody );
            // Set the body as a JSON object
            request.setBody(reqBody);
            HttpResponse response = http.send(request);
            system.debug(' response response: '+ response);
            // Information Log
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createUpdateContactToEBSData',
                    'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                    +'Method : PUT,\n'
                    + 'Req Body : '+reqBody,
                    'updateCustomerEBSData Request',
                    'Integration'
                )
            );
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createUpdateContactToEBSData',
                    'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                    +'Response Body : ' + response.getBody(),
                    'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                    'Integration'
                )
            );
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'EBSRESTCallout',
                        'createUpdateContactToEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                        +'Method : PUT,\n'
                        + 'Req Body : '+reqBody,
                        'The status code returned was not expected: ' + response.getStatusCode() + ': ' + response.getStatus() + ': ' + response.getBody(),
                        null,
                        'Integration'
                    )
                );
            } else {
                System.debug(response.getBody());
                CustomerRequest.handleUpdateCustomerResponse(response.getBody());
                
            }
            
            
        }
        catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('EBSRESTCallout','createUpdateContactToEBSData',ConId,ex,'Integration'));
        }
        
        
    }//End of updateCustomerEBSData
    
    
    @future(callout=true)
    public static void inActiveContactToEBSCallout(String ConId,String AccountId,String orgContactId,String mdmrecId) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        inActiveContactToEBSData(ConId,AccountId,orgContactId,mdmrecId); 
        
    }//End of createUpdateContactToEBSCallout
    public static void inActiveContactToEBSData(String ConId,String AccountId,String orgContactId,String mdmrecId) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
            
            List<Endpoint_Configuration__mdt> ebsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'EBS_Customer_Account' ]; 
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
             
            request.setEndpoint(ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce');
            request.setMethod('PUT');
            request.setHeader('Authorization', 'Bearer '+ebsMetaData[0].Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(120000);
            
            //request.setHeader('callingsystem', 'Salesforce');
            String reqBody = CustomerRequest.inActiveContactRequest(ConId,AccountId,orgContactId);
            System.debug('UAC: EBSRESTCallout contact reqBody ' + reqBody );
            // Set the body as a JSON object
            request.setBody(reqBody);
            HttpResponse response = http.send(request);
            system.debug(' response response: '+ response);
            // Information Log
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createUpdateContactToEBSData',
                    'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                    +'Method : PUT,\n'
                    + 'Req Body : '+reqBody,
                    'updateCustomerEBSData Request',
                    'Integration'
                )
            );
            new ApexDebugLog().createLog(
                new ApexDebugLog.Information(
                    'EBSRESTCallout',
                    'createUpdateContactToEBSData',
                    'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                    +'Response Body : ' + response.getBody(),
                    'The status code : ' + response.getStatusCode() + ' ' + response.getStatus(),
                    'Integration'
                )
            );
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                new ApexDebugLog().createLog(
                    new ApexDebugLog.Error(
                        'EBSRESTCallout',
                        'createUpdateContactToEBSData',
                        'URL : '+ebsMetaData[0].Endpoint__c+'/'+mdmrecId+'?callingsystem=Salesforce,\n'
                        +'Method : PUT,\n'
                        + 'Req Body : '+reqBody,
                        'The status code returned was not expected: ' + response.getStatusCode() + ': ' + response.getStatus() + ': ' + response.getBody(),
                        null,
                        'Integration'
                    )
                );
            } else {
                System.debug(response.getBody());
               
                
            }
            
            
        }
        catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('EBSRESTCallout','createUpdateContactToEBSData',ConId,ex,'Integration'));
        }
        
        
    }//End of updateCustomerEBSData
}//End of EBSRESTCallout