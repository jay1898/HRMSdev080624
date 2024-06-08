global without sharing class EBSFullLoad implements Queueable, Database.AllowsCallouts 
{
	public String accountId ; 
	public String sessionId ; 
	public String reqBody ; 

	global EBSFullLoad(String accountId, String sessionId)
	{
		this.sessionId = sessionId ; 
		this.accountId = accountId ;
	}

    global void execute(QueueableContext context) 
    {
    	System.debug('UAC: accountId ' + accountId );
    	
    	EBSRESTCallout.createCustomerEBSData(accountId);  
    	EBSFullLoad.runEnterpriseTerritoryManagementRules(accountId, sessionId);
    	
    }

    @future(callout=true)
    public static void runEnterpriseTerritoryManagementRules(Id accountId, String sessionId)
    {

		String accountTag = '<urn:sObjects> '+
	                        	'<urn1:type>Account</urn1:type>  '+
	        					'<urn1:Id>{ACCID}</urn1:Id>   '+
                    		'</urn:sObjects> ' ;    
    	String requestTemplate = 	'<soapenv:Envelope '+
										'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+
										' xmlns:urn="urn:partner.soap.sforce.com"'+
										' xmlns:urn1="urn:sobject.partner.soap.sforce.com">'+
	                                	'<soapenv:Header> '+
	                                  		'<urn:AssignmentRuleHeader> '+ 
	                                     		'<urn:useDefaultRule>true</urn:useDefaultRule> '+
	                                     		'<urn:assignmentRuleId></urn:assignmentRuleId> '+
	                                  		'</urn:AssignmentRuleHeader>  '+
		                                  	'<urn:SessionHeader> '+
		        							'	<urn:sessionId>{SESSID}</urn:sessionId> '+
		                                  	'</urn:SessionHeader> '+
	                               		'</soapenv:Header> '+
	                               		'<soapenv:Body> '+
					        				'<urn:update> '+
					        					' {ACCLISTS}'+ 
	                                  		'</urn:update> '+
	                               		'</soapenv:Body> '+
                            		'</soapenv:Envelope>';
		
		List<String> lstAccString = new List<String>();
		lstAccString.add(accountTag.replace('{ACCID}', accountId));  
		
		requestTemplate = requestTemplate.replace('{ACCLISTS}', String.join(lstAccString, ' ')) ;
		requestTemplate = requestTemplate.replace('{SESSID}', sessionId) ;        
		HttpRequest request = new HttpRequest();
		request.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+
		    '/services/Soap/u/41.0/'+UserInfo.getOrganizationId());
		request.setMethod('POST');
		request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		request.setHeader('SOAPAction', '""');
        request.setBody(requestTemplate);
        if(!Test.isRunningTest()){
            HttpResponse res = new Http().send(request);
            System.debug('UAC: res code ' + res.getStatusCode() );
            System.debug('UAC: res body ' + res.getBody());
        }
        

		/*Opportunity opp = [SELECT Id, Appointment_Type__c, Best_Match__c FROM Opportunity WHERE AccountId = :accountId];
		ServiceAppointment sa = [SELECT Id FROM ServiceAppointment WHERE Opportunity__c = :opp.Id ];

		if(opp.Appointment_Type__c == 'RT') 
        {
            List<ServiceResource> resources = [SELECT Id, IsActive FROM ServiceResource WHERE RelatedRecordId = :opp.Best_Match__c AND IsActive = TRUE ];
            System.debug('UAC: resources ' + resources );   
            if(resources.size() == 0 ) return ;
            AssignedResourceTriggerHandler.RUN_TRIGGER = false ; 
            ServiceAppointmentTriggerHandler.RUN_TRIGGER = false ;
            insert new AssignedResource(ServiceAppointmentId = sa.Id, ServiceResourceId = resources[0].Id); 
        }*/

    }

}