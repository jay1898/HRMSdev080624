public without sharing class OpportunityTriggerHandler 
{
    public static Boolean RUN_TRIGGER = true ;
    public static Boolean RUN_UPDATE_CAMPAIGN = true ;
    public static Boolean Check_Conflict_Overriden = true ;
    public static Boolean RUN_AFTER_UPDATE = true ; //SARAN-New Attribute for 101 SOQL Error
    
    public static void updateCommunicationStage(List<Opportunity> opps, Map<Id,Opportunity> oldMap) 
    {
        for(Opportunity opp : opps){
            try
            {
                if(opp.StageName == 'Follow-Up'  ){
                    if(opp.Communication__c != oldMap.get(opp.Id).Communication__c && String.isNotBlank(opp.Communication__c) 
                       && opp.Communication__c != 'Thank you' && opp.Is_In_Communication__c == false){
                           opp.Is_In_Communication__c = true;
                       }
                    if(opp.Communication__c != oldMap.get(opp.Id).Communication__c && opp.Communication__c == '1on1'){
                        opp.Is_Communication_Completed__c = true; 
                    }
                    if(opp.Communication__c != oldMap.get(opp.Id).Communication__c && String.isNotBlank(opp.Communication__c) ){
                        if(String.isNotBlank(opp.Already_Executed_Communication__c) && opp.Already_Executed_Communication__c.contains(opp.Communication__c+',') ) {
                            if(opp.Is_Communication_Completed__c == false){
                                opp.addError( System.Label.CommunicationAlreadyExecutedError);
                            }
                            
                        }else{
                            if(String.isBlank(opp.Already_Executed_Communication__c)){
                                opp.Already_Executed_Communication__c=opp.Communication__c+',';
                            }else{
                                opp.Already_Executed_Communication__c+=opp.Communication__c+',';
                            }
                        }
                    }
                }
                else if(opp.StageName == 'Rehash' ){
                    if(opp.RehashCommunication__c != oldMap.get(opp.Id).RehashCommunication__c && String.isNotBlank(opp.RehashCommunication__c) 
                       && opp.RehashCommunication__c != 'Thank you' && opp.Is_In_Communication__c == false){
                           opp.Is_In_Communication__c = true;
                       }
                    if(opp.RehashCommunication__c != oldMap.get(opp.Id).RehashCommunication__c && opp.RehashCommunication__c == '1on1'){
                        opp.Is_Communication_Completed__c = true; 
                    }
                    if(opp.RehashCommunication__c != oldMap.get(opp.Id).RehashCommunication__c && String.isNotBlank(opp.RehashCommunication__c) ){
                        if(String.isNotBlank(opp.Already_Executed_Communication__c) && opp.Already_Executed_Communication__c.contains(opp.RehashCommunication__c+',') ) {
                            if(opp.Is_Communication_Completed__c == false){
                                opp.addError( System.Label.CommunicationAlreadyExecutedError);
                            }
                            
                        }else{
                            if(String.isBlank(opp.Already_Executed_Communication__c)){
                                opp.Already_Executed_Communication__c=opp.RehashCommunication__c+',';
                            }else{
                                opp.Already_Executed_Communication__c+=opp.RehashCommunication__c+',';
                            }
                        }
                    }
                }
                else if((opp.StageName == 'Closed' || opp.StageName == 'Closed Won'|| opp.StageName == 'Contracted')&& opp.Is_Communication_Completed__c == false){
                    opp.Is_Communication_Completed__c = true;  
                    opp.Communication__c = '1on1';
                }
            }
            catch(Exception ex){
                new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'updateCommunicationStage',  'Received Opp: ' + JSON.serialize(opp) + ', Old Opportunity: ' + (oldMap.containsKey(opp.Id)? JSON.serialize(opp): 'Old map does not Contain received Opportunity.'), ex, 'Internal' ));
            }
        }
    } 
    public static void OpportunityCommunication(List<Opportunity> opps, Map<Id,Opportunity> oldMap) 
    {
        try
        {
            // [SELECT Id, Name, Opportunity__c, Communication__c, Execution_Time__c FROM OpportunityCommunication__c];
            List<OpportunityCommunication__c> ocRecords = new List<OpportunityCommunication__c>();
            List<Communication__c> communicationList= [SELECT Id, Name, Active__c, Type__c FROM Communication__c];
            List<Communication_Component__c> comComponentList= [SELECT Id, Name, Channel__c, Order__c, Frequency__c,Deployment_Run_After_Day__c, Deployment_Run_After__c, Communication__c 
                                                                FROM Communication_Component__c];
            
            Map<String,Communication__c> mapCommunication=new Map<String,Communication__c>();
            for(Communication__c com : communicationList){
                mapCommunication.put(com.Name+'~'+com.Type__c,com);
            }
            Map<String,List<Communication_Component__c>> mapComCmp=new Map<String,List<Communication_Component__c>>();
            for(Communication_Component__c comcmp : comComponentList){
                if(!mapComCmp.containsKey(comcmp.Communication__c)){
                    mapComCmp.put(comcmp.Communication__c,new List<Communication_Component__c>());
                }
                mapComCmp.get(comcmp.Communication__c).add(comcmp);
            }
            
            for(Opportunity opp : opps){
                if(opp.StageName == 'Follow-Up'){
                    if(opp.Communication__c != oldMap.get(opp.Id).Communication__c){
                        if(mapCommunication.containsKey(opp.Communication__c+'~'+opp.StageName)){
                            Communication__c com =mapCommunication.get(opp.Communication__c+'~'+opp.StageName);
                            if(mapComCmp.containsKey(com.Id)){
                                for(Communication_Component__c cc : mapComCmp.get(com.Id)){
                                    OpportunityCommunication__c oc = new OpportunityCommunication__c();
                                    oc.Opportunity__c = opp.Id;
                                    oc.Communication__c = com.Id;
                                    oc.Contact__c = opp.ContactId__c;
                                    oc.Communication_Component__c = cc.Id;
                                    if(cc.Frequency__c == 'Immediate'){
                                        oc.Execution_Time__c = opp.Communication_Start_Date__c!=null?opp.Communication_Start_Date__c:DateTime.now();
                                    }
                                    else if(cc.Frequency__c == 'Scheduled'){
                                        oc.Execution_Time__c= opp.Communication_Start_Date__c!=null?opp.Communication_Start_Date__c:DateTime.now();
                                        if(cc.Deployment_Run_After_Day__c!=null){
                                            oc.Execution_Time__c = oc.Execution_Time__c.adddays(Integer.valueOf(cc.Deployment_Run_After_Day__c));
                                        }
                                        if(cc.Deployment_Run_After__c!=null){
                                            oc.Execution_Time__c = oc.Execution_Time__c.addHours(Integer.valueOf(cc.Deployment_Run_After__c));
                                        }
                                        
                                    }
                                    ocRecords.add(oc);
                                }
                            }
                        }
                    }
                }
                else if(opp.StageName == 'Rehash'){
                    if(opp.RehashCommunication__c != oldMap.get(opp.Id).RehashCommunication__c){
                        if(mapCommunication.containsKey(opp.RehashCommunication__c+'~'+opp.StageName)){
                            Communication__c com =mapCommunication.get(opp.RehashCommunication__c+'~'+opp.StageName);
                            if(mapComCmp.containsKey(com.Id)){
                                for(Communication_Component__c cc : mapComCmp.get(com.Id)){
                                    OpportunityCommunication__c oc = new OpportunityCommunication__c();
                                    oc.Opportunity__c = opp.Id;
                                    oc.Communication__c = com.Id;
                                    oc.Contact__c = opp.ContactId__c;
                                    oc.Communication_Component__c = cc.Id;
                                    if(cc.Frequency__c == 'Immediate'){
                                        oc.Execution_Time__c = DateTime.now();
                                    }
                                    else if(cc.Frequency__c == 'Scheduled'){
                                        oc.Execution_Time__c= DateTime.now();
                                        if(cc.Deployment_Run_After_Day__c!=null){
                                            oc.Execution_Time__c = oc.Execution_Time__c.adddays(Integer.valueOf(cc.Deployment_Run_After_Day__c));
                                        }
                                        if(cc.Deployment_Run_After__c!=null){
                                            oc.Execution_Time__c = oc.Execution_Time__c.addHours(Integer.valueOf(cc.Deployment_Run_After__c));
                                        }
                                        
                                    }
                                    ocRecords.add(oc);
                                }
                            }
                        }
                    }
                }
            }
            insert ocRecords;
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(
                new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'OpportunityCommunication', 'Received Opp: ' + JSON.serialize(opps) + ', Old Opportunity Map: ' + oldMap, ex, 'Internal'));
        }
    }
    
    
    /**
*   @Method:        postShellQuoteToPQM()
*   @Purpose:       Whenever CreateQuoteShell is checked (from ProcessBuilder or UI) then post Opportunity info on PQM 
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static void postShellQuoteToPQM(List<Opportunity> opps, Map<Id,Opportunity> oldMap) 
    {
        System.debug('UAC: postShellQuoteToPQM ENTRY ');
        try
        {
            List<Id> oppIds = new List<Id>();
            Integer i = 1 ; 
            for(Opportunity opp : opps)
            {
                System.debug('UAC: opp Quote Shell ' + opp.Create_Quote_Shell__c);
                System.debug('UAC: old Quote Shell ' + oldMap.get(opp.Id).Create_Quote_Shell__c);
                // When CreateQuoteShell is checked 
                if(opp.Create_Quote_Shell__c && opp.Create_Quote_Shell__c != oldMap.get(opp.Id).Create_Quote_Shell__c) 
                {
                    i++ ;
                    oppIds.add(opp.Id);
                    if(i < 50 && OpportunityTriggerHandler.RUN_POST_SHELL_QUOTE_PQM_FUTURE ) postShellQuoteToPQMFuture(opp.Id);
                }
            } 
            System.debug('UAC: postShellQuoteToPQM oppIds.size() '+ oppIds.size() );
            
            List<ServiceAppointment> appointments =[SELECT Opportunity__c, Opportunity__r.Account.PersonMailingStreet, Opportunity__r.Account.PersonMailingState, 
                                                    Opportunity__r.Account.PersonMailingPostalCode, Opportunity__r.Account.PersonMailingCity, 
                                                    Opportunity__r.Account.PersonMailingCountry, Status 
                                                    FROM ServiceAppointment WHERE Opportunity__c IN : oppIds AND Rehash_Appointment__c = FALSE AND Status != 'Canceled'];
            
            System.debug('UAC: appointments ' + appointments );
            if(appointments.size() == 0) return ;
            
            Id saFullDetailRTId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Hard_Assign').getRecordTypeId();
            
            for(ServiceAppointment sa : appointments)
            {
                sa.RecordTypeId = saFullDetailRTId ;
                sa.Status = 'Scheduled';
                sa.Street = sa.Opportunity__r.Account.PersonMailingStreet ;
                sa.State = sa.Opportunity__r.Account.PersonMailingState ;
                sa.PostalCode = sa.Opportunity__r.Account.PersonMailingPostalCode ;
                sa.City = sa.Opportunity__r.Account.PersonMailingCity ;
                sa.Country = sa.Opportunity__r.Account.PersonMailingCountry ;
            }
            
            ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ;
            ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = false;
            ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = false ;
            ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = TRUE ;
            
            // Update Appointments
            update appointments ; 
            
        }
        catch(Exception ex){
            new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'postShellQuoteToPQM', 'Received Opp: ' + JSON.serialize(opps) + ', Old Opportunity Map: ' + oldMap,  ex, 'Internal' ) );
        }
        System.debug('UAC: postShellQuoteToPQM ENTRY ');
    }
    
    /**
*   @Method:        postShellQuoteToPQMFuture()
*   @Purpose:       To post Opportunity info on PQM, called from postShellQuoteToPQM method 
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static Boolean RUN_POST_SHELL_QUOTE_PQM_FUTURE = TRUE ;
    
    @future(callout=true)
    public static void postShellQuoteToPQMFuture(Id oppId)
    {
        System.debug('UAC: postShellQuoteToPQMFuture ENTRY '); 
        try{
            
            // Get Opportunity information 
            List<Opportunity> opps = [  SELECT  Id,Account.RecordType.DeveloperName,Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c, Account.Legacy_Party_Id__c, Account.PersonMailingStreet, Account.PersonMailingCity, Account.PersonMailingState, Account.Mdmrecid__c, 
                                      Account.PersonMailingPostalCode, Account.PersonMailingCountry, Account.Account_Status__c, Owner.LastName, Owner.FirstName, 
                                      Description, CreatedDate, LastModifiedDate, Name, Owner.EBS_UserName__c, Account_Branch_Profile__r.Branch__r.Branch_Number__c, 
                                      Create_Quote_Shell__c,RecordTypeId,RecordType.DeveloperName,Account.Parent.Mdmrecid__c, Market_Segment__c, 
                                      Account.parent.BillingStreet,Account.parent.BillingCity,Account.parent.BillingState,Business_Segment__c,BusinessSegment__c,
                                      Account.parent.BillingPostalCode,Account.parent.BillingCountry,Account.Branch__r.Branch_Number__c,Account.Branch__r.T_C_Branch_Number__c,
                                      street__c, city__c, state__c, country__c, zipcode__c, Account.Name
                                      FROM Opportunity WHERE ID = :oppId ];
            
            // When no Opportunity found then go back 
            if(opps.size() == 0) return;
            
            Opportunity opp = opps[0];
            System.debug('UAC: opp ' + opp);
            
            String prettyJSON = createJSONForPQM(opp);
            
            // Get end point from metadata settings 
            List<Endpoint_Configuration__mdt> qsMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'QuoteShell' ]; 
            
            // Create a new HTTP request and post Opportunity info
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(qsMetaData[0].Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer '+qsMetaData[0].Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            request.setBody(prettyJSON);
            
            HttpResponse response = http.send(request);
            // If not posted successfully then retry one more time
            if(response.getStatusCode() != 200) 
            {
                response = http.send(request);
                if(response.getStatusCode() != 200) 
                {
                    new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'postToPQMFuture', prettyJSON, 'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(), null, 'Integration' ));
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    OpportunityTriggerHandler.RUN_TRIGGER = false ;
                    update new Opportunity(Id=oppId, PQM_Quote_Shell_Error_Message__c = response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody() );
                }
            }else{
                new ApexDebugLog().createLog( new ApexDebugLog.Information( 'OpportunityTriggerHandler', 'postToPQMFuture', prettyJSON, 'Success', 'Integration' ));
                EBSWrapper EW=(EBSWrapper) JSON.deserialize(response.getBody(), EBSWrapper.class);
                Opportunity opportunity=new Opportunity();
                opportunity.Id=oppId;
                opportunity.Quote_Number_Shell__c=EW.QuoteNumber;
                opportunity.Create_Quote_Shell__c = TRUE ;
                opportunity.PQM_Quote_Shell_Error_Message__c = null ;
                update opportunity;
                
            }
            System.debug('UAC: response ' + response.getBody() );
            
        }catch(Exception ex){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'postToPQMFuture', oppId, ex, 'Integration' ));}
        
        System.debug('UAC: postShellQuoteToPQMFuture EXIT ');
    }
    
    public static String createJSONForPQM(Opportunity opp)
    {
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
        
        // Write data to the JSON string.
        gen.writeStartObject(); // Parent-Level ('{')
        
        
        // Check Record Type If Repalcement run old code (changed on 22-09)
        if(opp.recordtypeId ==null || opp.RecordType.DeveloperName == 'Replacement'){
            //gen.writeStringField('SEQ_NUMBER' , ''); //TO DO
            gen.writeStringField('DESCRIPTION' , String.isBlank(opp.Name) ? '' : opp.Name );
            gen.writeStringField('MARKET_SEGMENT' , (String.isNotBlank(opp.BusinessSegment__c) && opp.BusinessSegment__c == 'Replacement' ? 'SP: Single Family Replacement' : 
                                                     (String.isBlank(opp.Market_Segment__c) ? '' : opp.Market_Segment__c)) );
            
            //gen.writeStringField('BUILDING_TYPE' , '');//TO DO
            //gen.writeStringField('NO_OF_FLOORS' , '');//TO DO
            gen.writeStringField('OPPORTUNITY_ID' , opp.Id );
            //gen.writeStringField('BUSINESS_SEGMENT' , '');//TO DO
            if(opp.BusinessSegment__c!=null)gen.writeStringField('BUSINESS_SEGMENT' , opp.BusinessSegment__c=='Replacement'?'Retail':opp.BusinessSegment__c);
            
            gen.writeStringField('PARTY_ID' , String.isBlank(opp.Account.Mdmrecid__c) ? '' : opp.Account.Mdmrecid__c );
            
            gen.writeStringField('ADDRESS1' , String.isBlank(opp.Account.PersonMailingStreet) ? '' : opp.Account.PersonMailingStreet );
            gen.writeStringField('CITY' , String.isBlank(opp.Account.PersonMailingCity) ? '' : opp.Account.PersonMailingCity);
            gen.writeStringField('STATE' , String.isBlank(opp.Account.PersonMailingState) ? '' : opp.Account.PersonMailingState );
            gen.writeStringField('POSTAL_CODE' , String.isBlank(opp.Account.PersonMailingPostalCode) ? '' : opp.Account.PersonMailingPostalCode);
            gen.writeStringField('COUNTRY' , String.isBlank(opp.Account.PersonMailingCountry) ? '' : opp.Account.PersonMailingCountry );
            //gen.writeStringField('ORDER_TYPE' , '');//TO DO
            //gen.writeStringField('PROJECT_TYPE' , '');//TO DO
            //gen.writeStringField('DELIVERY_TYPE' , '');//TO DO
            
            //uncomment after demo
            gen.writeStringField('SALES_REP' , String.isBlank(opp.Owner.EBS_UserName__c) ? '' : opp.Owner.EBS_UserName__c);
            
            gen.writeStringField('BRANCH' , String.isBlank(opp.Account_Branch_Profile__r.Branch__r.Branch_Number__c) ? '' : opp.Account_Branch_Profile__r.Branch__r.Branch_Number__c );
            //gen.writeStringField('COUNTY' , '');//TO DO
            gen.writeStringField('ACCOUNT_STATUS' , String.isBlank(opp.Account.Account_Status__c) ? '' : opp.Account.Account_Status__c );
            //gen.writeStringField('QUOTE_NUMBER' , '');//TO DO
            gen.writeStringField('SOURCE_SYSTEM' , 'SALESFORCE');
            //gen.writeNumberField('PROCESS_FLAG' , 1);//TO DO
            //gen.writeStringField('ERROR_MESSAGE' , '');//TO DO
            gen.writeDateField('CREATED_DATE' , opp.CreatedDate.date() );
            gen.writeDateField('LAST_UPDATE_DATE' , opp.LastModifiedDate.date() );
            //gen.writeStringField('FUNDING_TYPE' , '');//TO DO
            //gen.writeStringField('FLOOR_AREA' , '');//TO DO
        }else{
            gen.writeStringField('DESCRIPTION' , String.isBlank(opp.Name) ? '' : opp.Name );
            gen.writeStringField('OPPORTUNITY_ID' , opp.Id );
            if(opp.BusinessSegment__c!=null)gen.writeStringField('BUSINESS_SEGMENT' , opp.BusinessSegment__c=='Replacement'?'Retail':opp.BusinessSegment__c);
            
            if(Opp.Account.recordType.DeveloperName=='PersonAccount'){
                gen.writeStringField('PARTY_ID' , String.isBlank(opp.Account.Mdmrecid__c) ? '' : opp.Account.Mdmrecid__c );
                gen.writeStringField('MARKET_SEGMENT' , (String.isNotBlank(opp.BusinessSegment__c) && opp.BusinessSegment__c == 'Replacement' ? 'SP: Single Family Replacement' : 
                                                         (String.isBlank(opp.Market_Segment__c) ? '' : opp.Market_Segment__c)) );
                
                /*gen.writeStringField('ADDRESS1' , String.isBlank(opp.Account.PersonMailingStreet) ? '' : opp.Account.PersonMailingStreet );
                gen.writeStringField('CITY' , String.isBlank(opp.Account.PersonMailingCity) ? '' : opp.Account.PersonMailingCity);
                gen.writeStringField('STATE' , String.isBlank(opp.Account.PersonMailingState) ? '' : opp.Account.PersonMailingState );
                gen.writeStringField('POSTAL_CODE' , String.isBlank(opp.Account.PersonMailingPostalCode) ? '' : opp.Account.PersonMailingPostalCode);
                gen.writeStringField('COUNTRY' , String.isBlank(opp.Account.PersonMailingCountry) ? '' : opp.Account.PersonMailingCountry);*/
                
                If (opp.Street__c <> null)
                {
                    gen.writeStringField('ADDRESS1' , String.isBlank(opp.Street__c) ? '' : opp.Street__c );
                    gen.writeStringField('CITY' , String.isBlank(opp.City__c) ? '' : opp.City__c);
                    gen.writeStringField('STATE' , String.isBlank(opp.State__c) ? '' : opp.State__c );
                    gen.writeStringField('POSTAL_CODE' , String.isBlank(opp.Zipcode__c) ? '' : opp.Zipcode__c);
                    gen.writeStringField('COUNTRY' , String.isBlank(opp.Country__c) ? '' : opp.Country__c );   
                }
                Else
                {
                    gen.writeStringField('ADDRESS1' , String.isBlank(opp.Account.PersonMailingStreet) ? '' : opp.Account.PersonMailingStreet );
                    gen.writeStringField('CITY' , String.isBlank(opp.Account.PersonMailingCity) ? '' : opp.Account.PersonMailingCity);
                    gen.writeStringField('STATE' , String.isBlank(opp.Account.PersonMailingState) ? '' : opp.Account.PersonMailingState );
                    gen.writeStringField('POSTAL_CODE' , String.isBlank(opp.Account.PersonMailingPostalCode) ? '' : opp.Account.PersonMailingPostalCode);
                    gen.writeStringField('COUNTRY' , String.isBlank(opp.Account.PersonMailingCountry) ? '' : opp.Account.PersonMailingCountry);                       
                }
                
                
                gen.writeStringField('BRANCH' , String.isBlank(opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c) ? '' : opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c );
                gen.writeStringField('ACCOUNT_STATUS' , String.isBlank(opp.Account.Account_Status__c) ? '' : opp.Account.Account_Status__c );
                
            }else{
                gen.writeStringField('PARTY_ID' , String.isBlank(opp.Account.Parent.Mdmrecid__c) ? '' : opp.Account.Parent.Mdmrecid__c );
                gen.writeStringField('MARKET_SEGMENT' , (String.isNotBlank(opp.BusinessSegment__c) && opp.BusinessSegment__c == 'Replacement' ? 'SP: Single Family Replacement' : 
                                                         (String.isBlank(opp.Market_Segment__c) ? '' : opp.Market_Segment__c)) );
               /* gen.writeStringField('ADDRESS1' , String.isBlank(opp.Account.Parent.BillingStreet) ? '' : opp.Account.Parent.BillingStreet );
                gen.writeStringField('CITY' , String.isBlank(opp.Account.Parent.BillingCity) ? '' : opp.Account.Parent.BillingCity);
                gen.writeStringField('STATE' , String.isBlank(opp.Account.Parent.BillingState) ? '' : opp.Account.Parent.BillingState );
                gen.writeStringField('POSTAL_CODE' , String.isBlank(opp.Account.Parent.BillingPostalCode) ? '' : opp.Account.Parent.BillingPostalCode);
                gen.writeStringField('COUNTRY' , String.isBlank(opp.Account.Parent.BillingCountry) ? '' : opp.Account.Parent.BillingCountry );*/
                
                If (opp.Street__c <> null)
                {
                    gen.writeStringField('ADDRESS1' , String.isBlank(opp.Street__c) ? '' : opp.Street__c );
                    gen.writeStringField('CITY' , String.isBlank(opp.City__c) ? '' : opp.City__c);
                    gen.writeStringField('STATE' , String.isBlank(opp.State__c) ? '' : opp.State__c );
                    gen.writeStringField('POSTAL_CODE' , String.isBlank(opp.Zipcode__c) ? '' : opp.Zipcode__c);
                    gen.writeStringField('COUNTRY' , String.isBlank(opp.Country__c) ? '' : opp.Country__c );   
                }
                Else
                {
                    gen.writeStringField('ADDRESS1' , String.isBlank(opp.Account.Parent.BillingStreet) ? '' : opp.Account.Parent.BillingStreet );
                    gen.writeStringField('CITY' , String.isBlank(opp.Account.Parent.BillingCity) ? '' : opp.Account.Parent.BillingCity);
                    gen.writeStringField('STATE' , String.isBlank(opp.Account.Parent.BillingState) ? '' : opp.Account.Parent.BillingState );
                    gen.writeStringField('POSTAL_CODE' , String.isBlank(opp.Account.Parent.BillingPostalCode) ? '' : opp.Account.Parent.BillingPostalCode);
                    gen.writeStringField('COUNTRY' , String.isBlank(opp.Account.Parent.BillingCountry) ? '' : opp.Account.Parent.BillingCountry );                        
                }
                gen.writeStringField('NAME' , String.isBlank(opp.Account.Name) ? '' : opp.Account.Name );
                gen.writeStringField('BRANCH' , String.isBlank(opp.Account.Branch__r.T_C_Branch_Number__c) ? '' : opp.Account.Branch__r.T_C_Branch_Number__c );
                gen.writeStringField('ACCOUNT_STATUS' , String.isBlank(opp.Account.Account_Status__c) ? '' : opp.Account.Account_Status__c );
                
                
            }
            gen.writeStringField('SALES_REP' , String.isBlank(opp.Owner.EBS_UserName__c) ? '' : opp.Owner.EBS_UserName__c);
            gen.writeStringField('SOURCE_SYSTEM' , 'SALESFORCE');
            gen.writeDateField('CREATED_DATE' , opp.CreatedDate.date() );
            gen.writeDateField('LAST_UPDATE_DATE' , opp.LastModifiedDate.date() );
            
        }
        
        gen.writeEndObject(); // Parent-Level ('}')
        
        // Get the JSON string.
        String prettyJSON = gen.getAsString();
        System.debug('UAC: prettyJSON ' + prettyJSON );
        return prettyJSON ;
    }
    
    public class EBSWrapper{
        public string QuoteNumber;
    }
    
    
    /**
*   @Method:        postClosedOppOnPQM()
*   @Purpose:       Whenever a Stage is Closed then post that opportunity ID to PQM  
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static void postClosedOppOnPQM(List<Opportunity> opps, Map<Id,Opportunity> oldMap)
    {
        // code commented on 26-08 as no need send update to PQM
        /*System.debug('UAC: postClosedOppOnPQM ENTRY ');
try
{
List<Id> oppIds = new List<Id>();
for(Opportunity opp : opps)
{
// When Stage is changed to Closed 
if(opp.StageName == 'Closed' && opp.StageName != oldMap.get(opp.Id).StageName ) postClosedOppOnPQMFuture(opp.Id);
}
}
catch(Exception ex){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'postClosedOppOnPQM', 'Received Opp: ' + JSON.serialize(opps) + ', Old Opportunity Map: ' + oldMap, ex, 'Internal'));}
System.debug('UAC: postClosedOppOnPQM ENTRY ');
*/
    }   
    
    /**
*   @Method:        postClosedOppOnPQMFuture()
*   @Purpose:       Whenever a Stage is Closed then post that opportunity ID to PQM, this method called from postClosedOppOnPQM
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    @future(callout=true)
    public static void postClosedOppOnPQMFuture(String oppId )
    {
        /*System.debug('UAC: postClosedOppOnPQMFuture ENTRY ');
try
{
// Get Pella Credentials
List<Endpoint_Configuration__mdt> settings = [SELECT Endpoint__c, Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'ClosedOpportunity'];
if(settings.size() == 0) return ; 
Endpoint_Configuration__mdt cs = settings[0];

// Create a new Http request and send information 
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(cs.Endpoint__c + '/' + oppId );
request.setMethod('DELETE');
request.setHeader('Authorization', 'Bearer ' + cs.Token__c);
request.setHeader('Content-Type', 'application/json;charset=UTF-8');
request.setTimeout(120000);
HttpResponse response = http.send(request);

// When failed, then create ADL record 
if (response.getStatusCode() != 200) 
{
new ApexDebugLog().createLog(new ApexDebugLog.Error('OpportunityTriggerHandler','postClosedOppOnPQMFuture', cs.Endpoint__c + '/' + oppId ,'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus(),null, 'Integration'));
System.debug('UAC: The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
}
}
catch(Exception ex){  new ApexDebugLog().createLog(  new ApexDebugLog.Error( 'OpportunityTriggerHandler', 'postClosedOppOnPQMFuture', oppId, ex, 'Integration') );}
System.debug('UAC: postClosedOppOnPQMFuture EXIT ');
*/
    }
    
    /**
*   @Method:        changeOpportunityOwnerForCanceledStatus()
*   @Purpose:       Whenever Status changed to Canceled, then related Appointment status to Canceled, 
Change Opporutnity Owner as Lead Receiver if Stage is New
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static Boolean CHANGE_OWNER_FOR_CANCEL_STATUS = true ;
    public static Boolean UPDATE_OPPORTUNITY_BACK_ON_OPP_CANCELED = true ;
    public static void changeOpportunityOwnerForCanceledStatus(List<Opportunity> opps, Map<Id,Opportunity> oldMap)
    {
        System.debug('UAC: changeOpportunityOwnerForCanceledStatus ENTRY ');
        Set<Opportunity> validOpps = new Set<Opportunity>();
        Set<Id> zoneIds = new Set<Id>();
        Map<Id,Id> zoneIdToLeadReceiverId = new Map<Id,Id>();
        Map<Id,ServiceAppointment> oppIdToSA = new Map<Id,ServiceAppointment>();
        
        for(Opportunity opp : opps)
        {
            Opportunity old = oldMap.get(opp.Id);
            
            // When Status is Canceled
            if(opp.Status__c != old.Status__c && (opp.Status__c == 'Canceled' || (opp.Status__c == 'Lost' && Datetime.now() < opp.Appointment_DateTime__c) ))
            {
                if(String.isNotBlank(opp.Zone__c)) zoneIds.add(opp.Zone__c);
                validOpps.add(opp);
            }
        }
        System.debug('UAC: zoneIds ' + zoneIds );
        // When no zone found, then go back
        if(zoneIds.size() == 0) return ;
        
        // Get zone Lead Reciever 
        for(ServiceTerritory st : [SELECT Id, Lead_Receiver__c FROM ServiceTerritory WHERE ID IN :zoneIds])
        {
            zoneIdToLeadReceiverId.put(st.Id, st.Lead_Receiver__c);
        }
        System.debug('UAC: zoneIdToLeadReceiverId ' + zoneIdToLeadReceiverId );
        
        // Get related ServiceAppointment information 
        for(ServiceAppointment sa : [SELECT Id, Status, Opportunity__c FROM ServiceAppointment WHERE Opportunity__c IN :validOpps AND Rehash_Appointment__c = FALSE ])
        {
            oppIdToSA.put(sa.Opportunity__c, sa);
        }
        System.debug('UAC: oppIdToSA ' + oppIdToSA );
        
        // Iterate again over Opportunities 
        for(Opportunity opp : validOpps )
        {
            // If stage is new then change Owner as Lead Receiver
            if(zoneIdToLeadReceiverId.containsKey(opp.Zone__c) && opp.StageName == 'New') opp.OwnerId = zoneIdToLeadReceiverId.get(opp.Zone__c);
            
            // Change Appointment status to Canceled
            if(oppIdToSA.containsKey(opp.Id)) oppIdToSA.get(opp.Id).Status = 'Canceled' ; 
        }
        
        OpportunityTriggerHandler.CHANGE_OWNER_FOR_CANCEL_STATUS = false ;
        
        // Update Appointments 
        if(oppIdToSA.size() > 0) 
        {
            // THis boolean used in ServiceAppointmentTrigger to avoid recursive call for opportunity update
            OpportunityTriggerHandler.UPDATE_OPPORTUNITY_BACK_ON_OPP_CANCELED = false;
            ServiceAppointmentTriggerHandler.RUN_FOR_RTA_CANCEL_APPOINTMENT = true ;
            update oppIdToSA.values() ;
        }
        
        System.debug('UAC: changeOpportunityOwnerForCanceledStatus EXIT' );
    }
    
    /**
*   @Method:        createSA_AssignedResourceForOppOwnerChange()
*   @Purpose:       When Opportunity Owner is changed then Create Assigned Resource under related Appointment 
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static void createSA_AssignedResourceForOppOwnerChange(List<Opportunity> opps, Map<Id,Opportunity> oldMap)
    {
        System.debug('UAC: createSA_AssignedResourceForOppOwnerChange ENTRY');
        Map<Id,Id> oppIdToOwnerId = new Map<Id,Id>();
        Map<Id,Id> oppIdToSAId = new Map<Id,Id>();
        Map<Id,Id> userIdToSRId = new Map<Id,Id>();
        Set<String> existingAssignedResources = new Set<String>();
        List<AssignedResource> assignedResourcesToInsert = new List<AssignedResource>();
        //List<AssignedResource> assignedResourcesToDelete = new List<AssignedResource>();
        Set<String> saStatuses = new Set<String>{'Preference','Soft Assigned','Scheduled'};
        
        Map<Id,Opportunity> newMap=new Map<Id,Opportunity>();    
         Map<Id,ServiceAppointment> SAMap=new Map<Id,ServiceAppointment>();    
        
        for(Opportunity opp : opps)
        {
            Opportunity old = oldMap.get(opp.Id);
            // When Owner is updated 
            if(opp.OwnerId != old.OwnerId) oppIdToOwnerId.put(opp.Id, opp.OwnerId);
            
            newMap.put(opp.Id,opp);
        }
        System.debug('UAC: oppIdToOwnerId ' + oppIdToOwnerId );
        
        // Get related ServiceAppointment 
        for(ServiceAppointment sa : [   SELECT Id, Opportunity__c,SchedStartTime,SchedEndTime,OwnerId FROM ServiceAppointment 
                                     WHERE Opportunity__c IN :oppIdToOwnerId.keySet()
                                     AND Status IN :saStatuses AND SchedStartTime != NULL]) // remove on 21-07 to remove rehash condition // AND Rehash_Appointment__c = FALSE 
        {
            oppIdToSAId.put(sa.Opportunity__c, sa.Id);
            SAMap.put(sa.Opportunity__c, sa);
        }
        System.debug('UAC: oppIdToSAId ' + oppIdToSAId );
        if(oppIdToSAId.size() == 0) return ;
        
        // Get matching Service Resources
        for(ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource 
                                  WHERE RelatedRecordId IN :oppIdToOwnerId.values() AND ResourceType IN ('T', 'D') AND IsActive = TRUE ])
        {
            userIdToSRId.put(sr.RelatedRecordId, sr.Id);
        }
        System.debug('UAC: userIdToSRId ' + userIdToSRId );
        if(userIdToSRId.size() == 0) return ;
        Map<String,AssignedResource> mapAssignedResourceToDel=new Map<String,AssignedResource>();
        // Get existing AssignedResource of Appointment 
        for(AssignedResource ar : [  SELECT ServiceAppointmentId, ServiceResourceId 
                                   FROM AssignedResource 
                                   WHERE ServiceAppointmentId IN : oppIdToSAId.values()])
        {
            existingAssignedResources.add(ar.ServiceAppointmentId + '' + ar.ServiceResourceId);
            //assignedResourcesToDelete.add(ar);
            mapAssignedResourceToDel.put(ar.ServiceAppointmentId + '' + ar.ServiceResourceId,ar);
        }  
        System.debug('UAC: existingAssignedResources ' + existingAssignedResources );
        
        // 02-06-2021 Overbooking Warning
        Map<Id,List<ServiceAppointment>> ownerIdToSAs=new Map<Id,List<ServiceAppointment>>();
        Map<Id,List<ResourceAbsence>> ownerIdToRAs=new Map<Id,List<ResourceAbsence>>();
        if(OpportunityTriggerHandler.Check_Conflict_Overriden){
            for(ServiceAppointment SA : [SELECT ID,AppointmentNumber,SchedStartTime,SchedEndTime,OwnerId FROM ServiceAppointment 
                                         Where OwnerId=:oppIdToOwnerId.values() 
                                         and Status IN :saStatuses 
                                         and SchedStartTime > : DateTime.now()
                                         order by SchedStartTime])
            {
                if(!ownerIdToSAs.containsKey(SA.OwnerId)){
                    ownerIdToSAs.put(SA.OwnerId,new List<ServiceAppointment>());
                }
                ownerIdToSAs.get(SA.OwnerId).add(SA);
            }
            
            
            for(ResourceAbsence RA : [SELECT ID,AbsenceNumber,Start,End,ResourceId,Resource.RelatedRecordId FROM ResourceAbsence 
                                      Where Resource.RelatedRecordId=:oppIdToOwnerId.values() 
                                      and start > : DateTime.now()
                                      order by Start])
            {
                if(!ownerIdToRAs.containsKey(RA.Resource.RelatedRecordId)){
                    ownerIdToRAs.put(RA.Resource.RelatedRecordId,new List<ResourceAbsence>());
                }
                ownerIdToRAs.get(RA.Resource.RelatedRecordId).add(RA);
            }
        }
        //  02-06-2021 Overbooking Warning
        
        // Iterate over OppIds map 
        for(Id oppId : oppIdToOwnerId.keySet() )
        {
            Id ownerId = oppIdToOwnerId.get(oppId);
            
            // When Opporutnity has related Appointment 
            if(oppIdToSAId.containsKey(oppId) && userIdToSRId.containsKey(ownerId))
            {
                Id saId = oppIdToSAId.get(oppId);
                Id srId = userIdToSRId.get(ownerId);
                
                // When no existing AssingedResource found for new Owner then create one
                if(!existingAssignedResources.contains(saId + '' + srId)) assignedResourcesToInsert.add(new AssignedResource(ServiceAppointmentId = saId, ServiceResourceId = srId));
                if(existingAssignedResources.contains(saId + '' + srId)) mapAssignedResourceToDel.remove(saId + '' + srId);
            }
            
            
            // 02-06-2021 Overbooking Warning
            if(OpportunityTriggerHandler.Check_Conflict_Overriden){
                if(newMap.containsKey(OppId) && newMap.get(OppId).Appointment_Conflict_Override__c==false && SAMap.containsKey(oppId)){
                    ServiceAppointment currentSA=SAMap.get(OppId);
                    if(ownerIdToSAs.containsKey(ownerId)){
                        for(ServiceAppointment SA: ownerIdToSAs.get(ownerId)){
                            if((currentSA.SchedStartTime<=SA.SchedStartTime && SA.SchedStartTime<currentSA.SchedEndTime)
                               ||(currentSA.SchedStartTime<SA.SchedEndTime && SA.SchedEndTime<currentSA.SchedEndTime)
                               ||( SA.SchedStartTime<=currentSA.SchedStartTime && currentSA.SchedEndTime<=SA.SchedEndTime )){
                                   updateOpportunityConflictFlag(OppId,true); 
                                   newMap.get(OppId).addError(Label.Service_Appointment_Conflict.replace('{DateTime}',(currentSA.SchedStartTime).format('MM/dd/yyyy hh:mm a')));
                                   break; 
                               }
                        }
                    }
                    if(ownerIdToRAs.containsKey(ownerId)){
                        for(ResourceAbsence RA: ownerIdToRAs.get(ownerId)){
                            if((currentSA.SchedStartTime<=RA.Start && RA.Start<currentSA.SchedEndTime)
                               ||(currentSA.SchedStartTime<RA.END && RA.END<currentSA.SchedEndTime)
                               ||( RA.Start<=currentSA.SchedStartTime && currentSA.SchedEndTime<=RA.END )){
                                   updateOpportunityConflictFlag(OppId,true);
                                   newMap.get(OppId).addError(Label.Service_Appointment_Conflict.replace('{DateTime}',(currentSA.SchedStartTime).format('MM/dd/yyyy hh:mm a')));
                                   
                                   break;
                               }
                        }
                    }
                    
                }
                if(newMap.containsKey(OppId) && newMap.get(OppId).Appointment_Conflict_Override__c==true && SAMap.containsKey(oppId)){
                    updateOpportunityConflictFlag(OppId,false);
                }
            }
            // 02-06-2021 Overbooking Warning
        }
        System.debug('UAC: assignedResourcesToInsert ' + assignedResourcesToInsert );
        if(assignedResourcesToInsert.size() == 0) return ;
        
        // Insert assigned resources 
        AssignedResourceTriggerHandler.CHANGE_SA_OPP_STATUS_OWNER = false ;
        Database.insert(assignedResourcesToInsert, false) ;
        if(mapAssignedResourceToDel.size() > 0) delete mapAssignedResourceToDel.values();
        
        System.debug('UAC: createSA_AssignedResourceForOppOwnerChange EXIT');
    }
    
     public static void updateOpportunityConflictFlag(String OpportunityId,Boolean Flag) {
        List<Opportunity_Appointment_Flag__e> inkEvents = new List<Opportunity_Appointment_Flag__e>();
        inkEvents.add(new Opportunity_Appointment_Flag__e(OpportunityId__c=OpportunityId,Flag__c=Flag));
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(inkEvents);
        
    }//End of updateCustomerEBSCallout
    /**
*   @Method:        createSA_AssignedResourceForOppOwnerChange()
*   @Purpose:       When Opportunity Owner is changed then Create Assigned Resource under related Appointment 
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static void updateOppOwnerWithRehashAppointmentOnOppClose(List<Opportunity> opps, Map<Id,Opportunity> oldMap)
    {
        System.debug('UAC: updateOppOwnerWithRehashAppointmentOnOppClose ENTRY ');
        Set<Opportunity> validOpps = new Set<Opportunity>();
        Map<Id,Id> oppIdToSAOwnerId = new Map<Id,Id>();
        
        for(Opportunity opp : opps)
        {
            Opportunity old = oldMap.get(opp.Id);
            if(opp.StageName != old.StageName && ( opp.StageName == 'Closed Won' || opp.StageName == 'Closed') ) 
            {
                validOpps.add(opp);
            }
        }
        System.debug('UAC: validOpps ' + validOpps );
        if(validOpps.size() == 0) return ;
        
        for(ServiceAppointment sa : [   SELECT Id, OwnerId, Opportunity__c
                                     FROM ServiceAppointment 
                                     WHERE Opportunity__c IN :validOpps AND Rehash_Appointment__c = TRUE ])
        {
            oppIdToSAOwnerId.put(sa.Opportunity__c, sa.OwnerId);
        }
        System.debug('UAC: oppIdToSAOwnerId ' + oppIdToSAOwnerId );
        
        for(Opportunity opp : validOpps)
        {
            if(oppIdToSAOwnerId.containsKey(opp.Id))
            {
                if(opp.StageName == 'Closed Won') opp.OwnerId = oppIdToSAOwnerId.get(opp.Id);
                
                if(opp.StageName == 'Closed' && String.isNotBlank(opp.Prior_Opp_OwnerID__c) ) opp.OwnerId = opp.Prior_Opp_OwnerID__c ; 
            }
        }
        
        System.debug('UAC: updateOppOwnerWithRehashAppointmentOnOppClose EXIT ');
    }
    
    public static Boolean RUN_UPDATE_SA_ON_VIRTUAL_OPPORTUNITY = true ;
    public static void updateSAonVirtualOpportunity(List<Opportunity> opps, Map<Id,Opportunity> oldMap)
    {
        System.debug('UAC: updateSAonVirtualOpportunity ENTRY ');
        Set<Opportunity> validOpps = new Set<Opportunity>();
        Map<Id,ServiceAppointment> oppIdToSA = new Map<Id,ServiceAppointment>();
        List<ServiceAppointment> appointments = new List<ServiceAppointment>();
        OpportunityTriggerHandler.RUN_UPDATE_SA_ON_VIRTUAL_OPPORTUNITY = false ;
        
        for(Opportunity opp : opps)
        {
            Opportunity old = oldMap.get(opp.Id);
            if( opp.Virtual_Appointment__c != old.Virtual_Appointment__c || 
               (opp.StageName != old.StageName && opp.StageName == 'Closed') || 
               (opp.Status__c != old.Status__c && opp.Status__c != null && opp.Status__c.contains('Transferred') )) 
                validOpps.add(opp);
        }
        System.debug('UAC: validOpps ' + validOpps );
        if(validOpps.size() == 0) return ;
        
        for(ServiceAppointment sa : [   SELECT Id, Opportunity__c, Subject
                                     FROM ServiceAppointment 
                                     WHERE Opportunity__c IN :validOpps AND Rehash_Appointment__c = FALSE ])
        {
            oppIdToSA.put(sa.Opportunity__c, sa);
        }
        System.debug('UAC: oppIdToSA ' + oppIdToSA );
        
        List<Id> listSAResourceDelete=new List<Id>();
        for(Opportunity opp : validOpps)
        {
            if(oppIdToSA.containsKey(opp.Id)) 
            {
                ServiceAppointment sa = oppIdToSA.get(opp.Id);
                System.debug('UAC: sa.Subject ' + sa.Subject );
                
                sa.Subject = (opp.StageName == 'Closed' && opp.Status__c != NULL && opp.Status__c.contains('Transferred') && !sa.Subject.contains('TRANSFERRED - ') ? 'TRANSFERRED - ' + sa.Subject : (sa.Subject.contains('TRANSFERRED - ') ? sa.Subject.replaceAll('TRANSFERRED - ', '') : sa.Subject) )  ;
                appointments.add(new ServiceAppointment(Id=sa.Id, Virtual_Appointment__c = opp.Virtual_Appointment__c, Subject = sa.Subject ));
                
                // Added on 04-05-2020 , we need to release resource for this type of appointment ,so deleting Assign Resource  
                if(sa.Subject.contains('TRANSFERRED - ')){
                    listSAResourceDelete.add(sa.Id);
                }
            }
        }
        
        if(appointments.size() > 0)
        {
            ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ;
            ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = false ;
            ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = false ;
            ServiceAppointmentTriggerHandler.RUN_UPDATE_OPPORTUNITY_VIRTUAL_APPOINTMENT = false ;
            ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = TRUE ;
            update appointments ;
            // Added on 30-04-2020 , changed on 04-05-2020 we need to release resource for this type of appointment ,so deleting Assign Resource    
            Database.delete([SELECT ID FROM AssignedResource where ServiceAppointmentId in :listSAResourceDelete ]);
        }
        
        System.debug('UAC: updateSAonVirtualOpportunity EXIT ');
    }
    
    public static void updateSAonUpdate_SA_HelperChange(List<Opportunity> opps, Map<Id,Opportunity> oldMap){
        
        List<Id> oppIds = new List<Id>();
        for(Opportunity opp : opps)
        {
            // When Update_SA_Helper__c  is checked 
            if(opp.Update_SA_Helper__c  && opp.Update_SA_Helper__c  != oldMap.get(opp.Id).Update_SA_Helper__c ) 
            {
                oppIds.add(opp.Id);
            }
        } 
        if(oppIds.size()==0) return; // Added on 30-11-2022 Handle 101 SOQL
        List<ServiceAppointment> appointments =[SELECT Opportunity__c, Opportunity__r.Account.PersonMailingStreet, Opportunity__r.Account.PersonMailingState, 
                                                Opportunity__r.Account.PersonMailingPostalCode, Opportunity__r.Account.PersonMailingCity, 
                                                Opportunity__r.Account.PersonMailingCountry, Status, SchedStartTime, SchedEndTime, Start_Datetime__c, End_Datetime__c
                                                FROM ServiceAppointment WHERE Opportunity__c IN : oppIds AND Rehash_Appointment__c = FALSE AND Status != 'Canceled'];
        
        System.debug('UAC: appointments ' + appointments );
        if(appointments.size() == 0) return ;
        
        Id saFullDetailRTId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Hard_Assign').getRecordTypeId();
        
        for(ServiceAppointment sa : appointments)
        {
            sa.RecordTypeId = saFullDetailRTId ;
            sa.Status = 'Scheduled';
            sa.Street = sa.Opportunity__r.Account.PersonMailingStreet ;
            sa.State = sa.Opportunity__r.Account.PersonMailingState ;
            sa.PostalCode = sa.Opportunity__r.Account.PersonMailingPostalCode ;
            sa.City = sa.Opportunity__r.Account.PersonMailingCity ;
            sa.Country = sa.Opportunity__r.Account.PersonMailingCountry ;
            
            // In case of if somehow Salesforce automatically blanks start and end dates
            if(sa.Start_Datetime__c != null ) sa.SchedStartTime = sa.Start_Datetime__c ;
            if(sa.End_Datetime__c != null ) sa.SchedEndTime = sa.End_Datetime__c ;
        }
        
        ServiceAppointmentTriggerHandler.RESCHEDULE_BEST_MATCH = false ;
        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = false;
        ServiceAppointmentTriggerHandler.RUN_CHANGE_OWNER_AND_RESOURCE = false ;
        ServiceAppointmentTriggerHandler.CREATE_EVENT_RECORD = TRUE ;
        
        // Update Appointments
        Database.update(appointments, true) ; 
    }
    
    public static void oppRecordShare(List<Opportunity> opps, Map<Id,Opportunity> oldMap){
        
        List<Id> oppIdstoShare = new List<Id>();
        List<Id> removeOppIdstoShare = new List<Id>();
        Map<String,String> mapCampAORtoShare = new Map<String,String>();
        Map<String,String> mapCampAORtoremoveShare = new Map<String,String>();
        List<Id> campOppIdstoShare = new List<Id>();
        for(Opportunity opp : opps)
        {
            // When new record created or owner Id change 
            if(oldMap==null 
               || (opp.ownerId != oldMap.get(opp.Id).ownerId )
               || (opp.Zone__c != oldMap.get(opp.Id).Zone__c ) 
               || (opp.AccountId != oldMap.get(opp.Id).AccountId ) ) 
            {
                oppIdstoShare.add(opp.Id);
            }
            if(oldMap!=null && (opp.Zone__c != oldMap.get(opp.Id).Zone__c  || opp.AccountId != oldMap.get(opp.Id).AccountId ))
            {
                removeOppIdstoShare.add(opp.Id);
            }
            if(oldMap!=null && (opp.CampaignId != oldMap.get(opp.Id).CampaignId ))
            {
                if(oldMap.get(opp.Id).CampaignId !=null && !oppIdstoShare.contains(opp.Id) ){
                    mapCampAORtoremoveShare.put(oldMap.get(opp.Id).CampaignId,opp.AOR_Name__c);
                }
                if(opp.CampaignId !=null && !oppIdstoShare.contains(opp.Id)){
                    mapCampAORtoShare.put(opp.CampaignId,opp.AOR_Name__c);
                    campOppIdstoShare.add(opp.Id);
                }
            }
            
        } 
        if(removeOppIdstoShare.size()>0)
            OpportunityRecordShare.removeShareOppWithETM(removeOppIdstoShare);
        if(oppIdstoShare.size()>0){
            OpportunityRecordShare.shareOppRecordWithETMGroup(oppIdstoShare);
            
            // Share SMS Record With Owner 05-10-22 Dhruv
        	SMSRecordShare.shareSMSRecordWithOppOwner(oppIdstoShare);
        }
        if(mapCampAORtoremoveShare.keySet().size()>0){
            // CampaignRecordShare.removeShareCampWithAORUserByOpps(mapCampAORtoremoveShare);
        } 
        if(mapCampAORtoShare.keySet().size()>0){
            CampaignRecordShare.ShareCampWithAORUserByOpps(mapCampAORtoShare);
        }
        
        if(campOppIdstoShare.size()>0){
            CampaignRecordShare.ShareCampWithUserByOpps(campOppIdstoShare);
        }
        
        
    }
    // Sachin 
    public static void updateGeoCodes(List<Opportunity> lstNew,Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        //Check to verify if this method doesn't run for multiple records as google api doesn't support bulk operations
        if(newMap.size() == 1){
            Opportunity newOpp = newMap.get(lstNew[0].Id);
            //Check to verify if all the values are entered by the user
            if(String.isNotBlank(newOpp.City__c) && String.isNotBlank(newOpp.Street__c) && String.isNotBlank(newOpp.State__c) 
               && String.isNotBlank(newOpp.Country__c) && String.isNotBlank(newOpp.Zipcode__c)){
                   //Check to verify if the operation is update
                   if(oldMap != Null ){
                       Opportunity oldOpp = oldMap.get(lstNew[0].Id);
                       //Check to validate if there is any change in values
                       if(oldOpp.City__c != newOpp.City__c || oldOpp.Street__c != newOpp.Street__c || oldOpp.State__c != newOpp.State__c
                          || oldOpp.Country__c != newOpp.Country__c || oldOpp.Zipcode__c != newOpp.Zipcode__c){
                              if(newOpp.Geo_Location__Latitude__s != null && newOpp.Geo_Location__Longitude__s != null){
                                  if((oldOpp.Geo_Location__Latitude__s == null || oldOpp.Geo_Location__Longitude__s == null) || 
                                     (oldOpp.Geo_Location__Latitude__s == newOpp.Geo_Location__Latitude__s ||
                                      oldOpp.Geo_Location__Longitude__s == newOpp.Geo_Location__Longitude__s))
                                      GetMapLocation.getLongitde_Latitude(newOpp.Id);
                              }else
                                  GetMapLocation.getLongitde_Latitude(newOpp.Id);
                          }
                   }else{
                       GetMapLocation.getLongitde_Latitude(newOpp.Id);
                   }
               }
        }
    }
    
    /**
*   @Method:    updateOppOwnerforTC()
*   @Purpose:   When a Replacement Opportunity is Closed with a Stage of "Closed" and a Status of "Transferred to Commercial"/"Transferred to New Construction", 
*               then the record type of the Opportunity should be changed to Trade_Comm, the Stage should be set to "New," and the owner should be changed to the Commercial Lead Receiver for that Branch (not Branch Family). 
*               The Lead Receiver should be notified that they have received an Opportunity from the Replacement Segment so that they can review and assign it to the correct Salesperson
*   @Author:    Pallavi (eVerge)
*   @Date:      27/08/2020
*   @WorkID:    W-000135
*   @Updates:       
*/
    public static void updateOppOwnerforTC(List<Opportunity> opps, Map<Id,Opportunity> oldMap)
    {
        Opportunity[] oppsToClone = new Opportunity[]{};
            Opportunity[] oppsToSave = new Opportunity[]{};
                Set<String> oppsBranch =  new Set<String>();
        Id OppRecTyId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        for(Opportunity opp : opps){
            if (opp.StageName == 'Closed' && oldMap.get(opp.Id).StageName != 'Closed'
                && (opp.Status__c == 'Transferred to Commercial' || opp.Status__c == 'Transferred to New Construction')
                && opp.RecordTypeId == OppRecTyId){
                    oppsToClone.add(opp);
                    oppsBranch.add(opp.Branch__c);
                }
        }
        if(oppsToClone.size()>0){
            
            Map<String,Branch__c> branchMap = new  Map<String,Branch__c>();
            for(Branch__c brc : [select Name, Trade_Lead_Receiver__c,   Commercial_Lead_Receiver__c from 
                                 Branch__c where Name IN: oppsBranch]){
                                     branchMap.put(brc.Name, brc);
                                 }
            for (Opportunity opp : oppsToClone){
                
                Opportunity oppClone = opp.clone(false,true);
                oppClone.RecordTypeId = OppRecTyTCId ;
                oppClone.StageName = 'New';
                oppClone.Status__c = '';
                oppClone.Name = opp.Name ;
                oppClone.Email_Email_Template__c =null;
                oppClone.Appointment_DateTime__c  =null;
                oppClone.Appointment_Type__c =null; 
                oppClone.Created_From_Replacement_Opp__c = TRUE;
                oppClone.Replacement_Opportunity__c = opp.Id;
                oppClone.Create_Quote_Shell__c  = false;
                oppClone.PQM_Quote_Shell_Error_Message__c  = null;
                oppClone.Quote_Number_Shell__c  = null;
                oppClone.Zone__c = NULL; 
                oppClone.Opportunity_No__c = NULL;
                oppClone.Description = opp.Description;
                if(opp.Status__c == 'Transferred to Commercial'){
                    if(branchMap.get(opp.Branch__c).Commercial_Lead_Receiver__c!=null){
                        oppClone.OwnerId = branchMap.get(opp.Branch__c).Commercial_Lead_Receiver__c ;
                    }
                    oppClone.Type = 'Commercial' ;
                }
                else if(opp.Status__c == 'Transferred to New Construction'){
                    if(branchMap.get(opp.Branch__c).Trade_Lead_Receiver__c !=null){
                        oppClone.OwnerID = branchMap.get(opp.Branch__c).Trade_Lead_Receiver__c ;
                    }
                    oppClone.Type = 'Trade' ;
                }
                oppsToSave.add(oppClone);
            }
            insert oppsToSave;
        }
        
    }
    
    /**
*   @Method:    updateOppOwnerforTC()
*   @Purpose:   To add the Requestor to the Opp as Team Member when Approved by the Opp owner
*   @Author:    Pallavi (eVerge)
*   @Date:      27/08/2020
*   @WorkID:    W-000135
*   @Updates:       
*/
    public static void createOppTeamMember(List<Opportunity> opps, Map<Id,Opportunity> oldMap){
        
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        Set<Id> oppId = new Set<Id>();
        List<OpportunityTeamMember> otmListtoSave = new List<OpportunityTeamMember>();
        Map<String, String> appOpp = new Map<String, String>();
        Map<String, String> appOppEmail = new Map<String, String>();
        List<Opportunity> updateOpps = new List<Opportunity>();
        
        for(Opportunity opp : opps){        
            if(opp.Approved_Status__c == 'Approved' && opp.RecordTypeId == OppRecTyTCId ){
                oppId.add(opp.Id);
            }
        }
        if(oppId.size()==0) return; // Added on 30-11-2022 Handle 101 SOQL
        for(ProcessInstance pIns : [SELECT TargetObjectId, SubmittedById, SubmittedBy.Email, Status FROM ProcessInstance 
                                    WHERE TargetObjectId IN: oppId  AND Status = 'Approved' ORDER BY LastModifiedDate DESC LIMIT 1]){
                                        appOpp.put(pIns.SubmittedById,pIns.TargetObjectId);
                                        appOppEmail.put(pIns.SubmittedBy.Email, pIns.TargetObjectId);
                                    }
        
        if(appOpp.size() >0){
            for(String otmrec : appOpp.keySet()){
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.OpportunityId = appOpp.get(otmrec);
                otm.TeamMemberRole = 'Sales Rep';
                otm.UserId = otmrec;
                otmListtoSave.add(otm);
            }
            insert otmListtoSave;
        }
        List<OpportunityShare> oppShareRecords = [select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId IN : appOpp.values() and RowCause = 'Team'];
        for (OpportunityShare OppShare : oppShareRecords){
            OppShare.OpportunityAccessLevel = 'Edit';
        }
        update oppShareRecords;
        
        for(Opportunity opp : [SELECT Approved_Status__c, Id FROM Opportunity where Id IN: appOpp.values()]){
            opp.Approved_Status__c = '';
            updateOpps.add(opp);
        }
        update updateOpps ;
        if (!Test.isRunningTest()) { //SARAN - During Test Class this block will not execute
            for(OpportunityTeamMember mailOtm : [SELECT Id, UserId, User.Email,OpportunityId FROM OpportunityTeamMember 
                                                 WHERE UserId IN :appOpp.keySet() AND OpportunityId IN :appOpp.values()]){
                                                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                                     List<String> sendTo = new List<String>();
                                                     sendTo.add(mailOtm.User.Email);
                                                     mail.setToAddresses(sendTo);                                                 
                                                     mail.setSubject('Added to Opportunity Team');
                                                     mail.setHtmlBody('You have been added to an Opportunity Team:<b><p><p/> '+ 
                                                                      'To view the opportunity <a href=https://pellacorp--pelladev.lightning.force.com/'+mailOtm.OpportunityID+'>click here.</a>');
                                                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                                                 }
        }
    }
    
    /**
*   @Method:        createOppSplit()
*   @Purpose:       To Retain the Overlay credit of prevoius Opportunity Owners
*   @Author:        Pallavi (eVerge)
*   @Date:          16/09/2020
*   @WorkID:        
*   @Updates:       
*/
    public static void createOppSplit(List<Opportunity> opps,Map<Id,Opportunity> oldMap){
        
        // commented out as not able to enable opportunity split on prod
        
        Map<String, String> mapPrevOppOwner = new Map<String,String>();
        Map<String, String> mapNewOppOwner = new Map<String,String>();
        
        for(Opportunity Opp : opps){
            if(opp.OwnerId != oldMap.get(Opp.Id).OwnerId && (Opp.Type == 'Trade' || Opp.Type == 'Commercial' )){
                mapPrevOppOwner.put(opp.Id, oldMap.get(Opp.Id).OwnerId); //opp Id , previous opp owner Id
                mapNewOppOwner.put(opp.Id, opp.OwnerId);//opp Id , new opp owner Id
            }
        }
        
        if(mapNewOppOwner.size() > 0){
            List<OpportunitySplit> listOppSpl = [SELECT Id, Split, OpportunityId, SplitOwnerId,SplitPercentage,
                                                 SplitNote,SplitTypeId,SplitType.Masterlabel,SplitAmount FROM OpportunitySplit where 
                                                 SplitType.Masterlabel = 'Total Price Overlay Credit' AND 
                                                 SplitOwnerId IN : mapNewOppOwner.values() AND OpportunityId IN : mapNewOppOwner.keySet()];
            system.debug('listOppSpl : ' + listOppSpl);
            if(listOppSpl.size()>0){
                List<OpportunitySplit> deleteOppSplitOwner = new List<OpportunitySplit>();
                List<OpportunitySplit> insertOs = new List<OpportunitySplit>();
                for(OpportunitySplit os : listOppSpl){
                    deleteOppSplitOwner.add(os); //list to delete the Total Price Overlay Credit record for new owners as this will be added manually
                    OpportunitySplit osNew = new OpportunitySplit ();
                    osNew.OpportunityId = os.OpportunityId;
                    osNew.SplitOwnerId = mapPrevOppOwner.get(os.OpportunityId) ;
                    osNew.SplitPercentage = os.SplitPercentage ;
                    osNew.SplitTypeId = os.SplitTypeId;
                    osNew.SplitNote = os.SplitNote;
                    insertOs.add(osNew);
                }
                
                insert insertOs;
                delete deleteOppSplitOwner ;
            }
            
        }
    }
    
    //Method to update the EDW Last Modified 
    public static void updateEDWLastModified(List<Opportunity> lstNew,Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        //Query to fetch all related fileds of Opportunity from metadata
        List<EDW_Object_Mapping__mdt> lstoppMetadta =[select id,Field_Api_Name__c,Source_Object__c from EDW_Object_Mapping__mdt where Source_Object__c='Opportunity'];
        set<String> fieldSet = new Set<String>();
        //dynamically get the fields from the metadata and then use the same for comparison in the trigger. 
        for(EDW_Object_Mapping__mdt fields :lstoppMetadta){
            fieldSet.add(fields.Field_Api_Name__c);
        }
        for(Opportunity opp: lstNew){
            
            for(string s: fieldSet){
                if(s.indexOf('.') > -1){
                    
                }
                else{
                    if(trigger.oldMap!=null){
                        if(opp.get(s) != trigger.oldMap.get(opp.Id).get(s)){
                            opp.EDW_Last_Modified__c=Datetime.now();
                            break;
                        }
                    }
                    else{
                        if(opp.get(s)!=null)
                            opp.EDW_Last_Modified__c=Datetime.now();
                    }
                }
            }
            
            
        }
        
    }
    
    // Create or update Account branch profile record when new trade/commerical opp cretaed for person account
    public static void createOrUpdateABP(List<Opportunity> opps, Map<Id,Opportunity> oldMap){
        Id OppRecTyTCId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Trade_Comm').RecordTypeId;
        List<Id> listAccIds=new List<Id>();
        for(Opportunity opp : opps)
        {
            if((Opp.AccountId!=null && opp.RecordTypeId==OppRecTyTCId && oldMap == NULL) || 
               (Opp.AccountId!=null && opp.RecordTypeId==OppRecTyTCId &&  opp.Street__c != oldMap.get(opp.id).street__C )
               || (Opp.AccountId!=null && opp.RecordTypeId==OppRecTyTCId && oldMap != NULL && opp.AccountId != oldMap.get(opp.id).AccountId )
              ){
                  listAccIds.add(opp.AccountId);
              }
        } 
        if(listAccIds.size()>0){
            Map<Id,Account> mapAccount=new Map<Id,Account>([SELECT Id FROM Account Where Id = :listAccIds and recordType.DeveloperName='PersonAccount']);
            if(mapAccount.keyset().size()>0){
                List<Account_Branch_Profile__c> listABP=new List<Account_Branch_Profile__c>();
                Map<Id,Id> mapExistingABP=new Map<Id,Id>();
                Map<Id,Account_Branch_Profile__c> mapNewABP=new Map<Id,Account_Branch_Profile__c>();
                // Get Logged in user Territory Number
                User u=[SELECT Id,title,Trade_Branch_Number__c FROM User where Id=:userInfo.getUserId()];
                String errorMessage = Label.T_C_User_Primary_Branch_Validation;
                String primaryBranchId;
                if(u.Trade_Branch_Number__c!=null && u.Trade_Branch_Number__c!=''){
                    List<Branch__c> listBranch=[SELECT Id, Branch_Family__c FROM Branch__c Where T_C_Branch_Number__c = :u.Trade_Branch_Number__c and T_C_Branch_Number__c!=null ];
                    if(listBranch.size()>0){ 
                        primaryBranchId=listBranch[0].Id;
                        List<Branch__C> listBranchids = new List<Branch__C>();
                        if(u.title == 'Centralized Sales Group')
                            listBranchids=[SELECT Id FROM Branch__c ];
                        else 
                            listBranchids=[SELECT Id FROM Branch__c Where Branch_Family__c = :listBranch[0].Branch_Family__c];
                        for(Account_Branch_Profile__c ABP : [SELECT Id,Party_Account__c FROM Account_Branch_Profile__c WHERE Branch__c = :listBranchids AND Party_Account__c = :mapAccount.keyset() order by lastmodifieddate desc Limit 1]){
                            mapExistingABP.put(ABP.Party_Account__c,ABP.Id);   
                        }     
                    }
                }
                for(Opportunity opp : opps)
                {
                    // Added on 05-11 to skip transfer opportunity ABP Creation
                    if(opp.Replacement_Opportunity__c!=null){
                        // ABP always exist on account as it's transfer Opp
                    }
                    else if(primaryBranchId==null){
                        // Throw Error
                        Opp.addError(errorMessage, false);
                    }
                    else if(!mapExistingABP.containsKey(opp.AccountId)){
                        Account_Branch_Profile__c abf = new Account_Branch_Profile__c(Party_Account__c = opp.accountId, Branch__c = primaryBranchId);
                        listABP.add(abf);
                        mapNewABP.put(opp.accountId,abf);
                    }
                }
                if(listABP.size()>0){
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.allowSave = true;
                    dml.DuplicateRuleHeader.runAsCurrentUser = true; 
                    Database.insert(listABP, dml) ;
                }
                for(Opportunity opp : opps)
                {
                    Address__C addr;
                    if(opp.Street__c != NULL)
                        addr = createUpdateAddress(opp); 
                    if(mapExistingABP.containsKey(opp.AccountId)){
                        opp.Account_Branch_Profile__c=mapExistingABP.get(opp.AccountId);
                        if(addr != NULL && addr.MDMrecid__c == NULL){
                            List<Address_Assignment__c> AAList = ServicePOSTRTA.createAddressAssignment(addr.ID, mapExistingABP.get(opp.AccountId), NULL  );
                            if(opp.StageName == 'Proposal')opp.QuoteShellDelayFlag__c = TRUE;
                            for(Address_Assignment__c AA :AAList){
                                EBSRESTCallout.createAddressAssignmentEBSCallout(AA.Id,'Insert');  
                            }                          
                        }    
                    }else if(mapNewABP.containsKey(opp.AccountId)){
                        opp.Account_Branch_Profile__c=mapNewABP.get(opp.AccountId).Id;
                        if(addr != NULL){
                            ServicePOSTRTA.createAddressAssignment(addr.ID, mapNewABP.get(opp.AccountId).Id, NULL  );
                            if(opp.StageName == 'Proposal')opp.QuoteShellDelayFlag__c = TRUE;
                            EBSRESTCallout.createCustomerEBSCallout(opp.AccountId);
                        }
                    }    
                }
            }
        }
    }
    public static Address__c createUpdateAddress(Opportunity Opp){
        
        List<SObject> duplicateRecords = new List<SObject>();
        System.debug('UAC: Inserting Address ' );
        Address__c addr = new Address__c(Street__c = Opp.Street__c, City__c = opp.City__c  , State__c = opp.state__C, Zipcode__c = opp.Zipcode__c  , Country__c = opp.Country__c, ownerid = opp.ownerId);
        
        AddressTriggerHandler.RUN_EBS_CALLOUT = false ;
        Database.SaveResult addSaveResult = Database.insert(addr, false);
        duplicateRecords = ServicePOSTRTA.checkDuplicates(addSaveResult, NULL);
        if(duplicateRecords.size() > 0 ) 
        {
            addr.Id = duplicateRecords[0].Id ;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            Database.update(addr, dml) ;
        }       
        return addr;     
    }
    //Method to update YTD on Account
    public static void updateYTDonAccount(List<Opportunity> listOpportunity,Map<Id,Opportunity> oldMap){
        
        
        Set<String> qtAccId = new Set<String>();
        for(Opportunity opp : listOpportunity){
            if(opp.AccountId != null && (oldMap == null || oldMap.get(opp.Id).StageName != opp.StageName)){
                qtAccId.add(opp.AccountId);
                if(oldMap != null && oldMap.get(opp.Id).AccountId != opp.AccountId && oldMap.get(opp.Id).AccountId != null){
                    qtAccId.add(oldMap.get(opp.Id).AccountId);
                }
            }
            
        }
        if(qtAccId.size()==0) return; // Added on 30-11-2022 Handle 101 SOQL
        //get the current fiscal year details
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;        
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE AccountId =:qtAccId
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name = 'Branch Account'
                                 AND status in ('Booked', 'Ordered')
                                 AND BookDate__c >=: stdt AND BookDate__c <=: eddt];
        
        Decimal totalAcc = 0;
        Decimal totalOpp = 0;
        Map<String, Decimal> mapAcct = new Map<String, Decimal>();
        
        for(Quote qt : quoteList){
            if(!mapAcct.containsKey(qt.AccountId)){
                mapAcct.put(qt.AccountId, 0);
            }
            totalAcc = mapAcct.get(qt.AccountId) + (qt.Customer_Extended_Price__c == null ? 0 : qt.Customer_Extended_Price__c);
            mapAcct.put(qt.AccountId, totalAcc);            
        }
        
        List<Account> accList = new List<Account>();
        for(String accId : qtAccId){
            Account acc = new Account();
            acc.Id = accId;
            if(mapAcct.containsKey(accId)){
                acc.YTD_Sales__c = mapAcct.get(accId);
                
            }else{
                acc.YTD_Sales__c = 0;
            }
            
            accList.add(acc);
            
        }
        if(accList.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update accList; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
    }
    
    public static void updatePYTDonAccount(List<Opportunity> opportunityList, Map<Id,Opportunity> oldMap){
        Set<String> opportunityAccountIdSet = new Set<String>();
        
        for(Opportunity opportunity : opportunityList){
            if(opportunity.AccountId != null && (oldMap == null || oldMap.get(opportunity.Id).StageName != opportunity.StageName)){               
                opportunityAccountIdSet.add(opportunity.AccountId);

                if(oldMap != null && oldMap.get(opportunity.Id).AccountId != opportunity.AccountId && oldMap.get(opportunity.Id).AccountId != null){
                    opportunityAccountIdSet.add(oldMap.get(opportunity.Id).AccountId);
                }
            }
        }

        if(opportunityAccountIdSet.size() == 0) return;
          
        Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date previousYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        Date previousYearEndDate = system.today().addYears(-1);
 
        List<Quote> quotesTiedToAccountsList = [
            SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId 
            FROM Quote
            WHERE AccountId =: opportunityAccountIdSet
            AND BookDate__c >=: previousYearStartDate 
            AND BookDate__c <=: previousYearEndDate
            AND Opportunity.RecordType.Name = 'Trade_Comm'
            AND Account.RecordType.Name = 'Branch Account'
            AND Status in ('Booked', 'Ordered')
        ];

        Decimal priorYearSalesTotal = 0;
        Map<String, Decimal> accountTotalMap = new Map<String, Decimal>();

        for(Quote quote : quotesTiedToAccountsList){
            if(!accountTotalMap.containsKey(quote.AccountId)){
                 accountTotalMap.put(quote.AccountId, 0);
			}               
            priorYearSalesTotal = accountTotalMap.get(quote.AccountId) + (quote.Customer_Extended_Price__c == null ? 0 : quote.Customer_Extended_Price__c);
            
            accountTotalMap.put(quote.AccountId, priorYearSalesTotal);           
        }
        
        List<Account> updatedAccountList = new List<Account>();
        for(String accountId : opportunityAccountIdSet){
            Account newAccount = new Account();
            newAccount.Id = accountId;
            newAccount.PYTD_Sales__c = accountTotalMap.containsKey(accountId) ? accountTotalMap.get(accountId) : 0;
                        
            updatedAccountList.add(newAccount);            
        }

        if(updatedAccountList.size() > 0){
            Boolean RunAccountTriggerEnabled = AccountTriggerHandler.RUN_TRIGGER;

            AccountTriggerHandler.RUN_TRIGGER = false;
            update updatedAccountList; 
            AccountTriggerHandler.RUN_TRIGGER = RunAccountTriggerEnabled;
        }
    }
    
    /*public static void updateOpportunityWithSameAddressCount(List<Opportunity> listOpportunity,Map<Id,Opportunity> oldMap){
List<String> listCity=new List<String>();
List<String> listState=new List<String>();
List<String> listZicode=new List<String>();
List<String> listStreet=new List<String>();
for(Opportunity opp : listOpportunity){
if(opp.type=='Trade' || opp.type=='Commercial'){
if(oldMap == null || oldMap.get(opp.Id).Street__c != opp.Street__c){
if(opp.Street__c!=null && !String.isBlank(opp.Street__c)){
listStreet.add(opp.Street__c);
}
if(oldMap!=null && oldmap.get(opp.id).Street__c!=null && !String.isBlank( oldmap.get(opp.id).Street__c)){
listStreet.add(oldmap.get(opp.id).Street__c);
}
}
if(oldMap == null || oldMap.get(opp.Id).City__c != opp.City__c){
if(opp.City__c!=null && !String.isBlank(opp.City__c)){
listCity.add(opp.City__c);
}
if(oldMap!=null && oldmap.get(opp.id).City__c!=null && !String.isBlank( oldmap.get(opp.id).City__c)){
listCity.add(oldmap.get(opp.id).City__c);
}
}
if(oldMap == null || oldMap.get(opp.Id).State__c != opp.State__c){
if(opp.State__c!=null && !String.isBlank(opp.State__c)){
listState.add(opp.State__c);
}
if(oldMap!=null && oldmap.get(opp.id).State__c!=null && !String.isBlank( oldmap.get(opp.id).State__c)){
listState.add(oldmap.get(opp.id).State__c);
}
}
if(oldMap == null || oldMap.get(opp.Id).Zipcode__c != opp.Zipcode__c){
if(opp.Zipcode__c!=null && !String.isBlank(opp.Zipcode__c)){
listZicode.add(opp.Zipcode__c);
}
if(oldMap!=null && oldmap.get(opp.id).Zipcode__c!=null && !String.isBlank( oldmap.get(opp.id).Zipcode__c)){
listZicode.add(oldmap.get(opp.id).Zipcode__c);
}
}
}
}
system.debug('@@listStreet'+listStreet);
system.debug('@@listCity'+listCity);
system.debug('@@listState'+listState);
system.debug('@@listZicode'+listZicode);
Map<String,Integer> mapGroupWiseCount=new Map<String,Integer>();
Map<String,List<Opportunity>> mapAddresswiseOpps=new  Map<String,List<Opportunity>> ();

if(listStreet.size() > 0 || listCity.size() > 0 || listState.size() > 0 || listZicode.size() > 0){

List<Opportunity> listOpps=[SELECT ID,Opp_Count_With_Same_Address__c,Street__c,City__c,State__c,Zipcode__c FROM Opportunity 
Where type in('Trade','Commercial') and status__c='Open' 
and Street__c!=null and City__c!=null and State__c!=null 
and Zipcode__c!=null and Street__c IN :listStreet and City__c IN :listCity 
and State__c =:listState and Zipcode__c=:listZicode];
for(Opportunity opp:listOpps){
if(!mapGroupWiseCount.containsKey(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)){
mapGroupWiseCount.put(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c,0);
mapAddresswiseOpps.put(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c,new List<Opportunity>());
}
mapGroupWiseCount.put(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c, mapGroupWiseCount.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)+1);
mapAddresswiseOpps.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c).add(opp);
}
List<Opportunity> listOppsToUpdate=new List<Opportunity>();
for(Opportunity opp : listOpportunity){
if(opp.type=='Trade' || opp.type=='Commercial'){
if(mapGroupWiseCount.containsKey(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)){
opp.Opp_Count_With_Same_Address__c=mapGroupWiseCount.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c);
for(Opportunity oppRec : mapAddresswiseOpps.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)){
if(opp.Id!=oppRec.Id){
oppRec.Opp_Count_With_Same_Address__c=opp.Opp_Count_With_Same_Address__c;
listOppsToUpdate.add(oppRec);
}
}
}
}
}

Boolean oppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
OpportunityTriggerHandler.RUN_TRIGGER=false;
update listOppsToUpdate; 
OpportunityTriggerHandler.RUN_TRIGGER=oppTrigger;
}

}

public static void updateOpportunityWithSameAddressCountNew(List<Opportunity> listOpportunity,Map<Id,Opportunity> oldMap){
String city = '';
String state = '';
String zipcode = '';
String street = '';
String cityOld = '';
String stateOld = '';
String zipcodeOld = '';
String streetOld = '';

Integer i = 0;
for(Opportunity opp : listOpportunity){
if(i > 0) break;
i++;
if(opp.type=='Trade' || opp.type=='Commercial'){
if(oldMap == null || oldMap.get(opp.Id).Street__c != opp.Street__c 
|| oldMap.get(opp.Id).City__c != opp.City__c
|| oldMap.get(opp.Id).State__c != opp.State__c
|| oldMap.get(opp.Id).Zipcode__c != opp.Zipcode__c)
{
if(opp.Street__c!=null && !String.isBlank(opp.Street__c)){
street = '%' + opp.Street__c.replaceAll(' ', '%') + '%';
}
if(oldMap!=null && oldmap.get(opp.id).Street__c!=null && !String.isBlank( oldmap.get(opp.id).Street__c)){
streetOld = '%' + oldmap.get(opp.id).Street__c.replaceAll(' ', '%') + '%';
}

if(opp.City__c!=null && !String.isBlank(opp.City__c)){
city = '%' + opp.City__c.replaceAll(' ', '%') + '%';
}
if(oldMap!=null && oldmap.get(opp.id).City__c!=null && !String.isBlank( oldmap.get(opp.id).City__c)){
cityOld = '%' + oldmap.get(opp.id).City__c.replaceAll(' ', '%') + '%';
}

if(opp.State__c!=null && !String.isBlank(opp.State__c)){
state = opp.State__c;
}
if(oldMap!=null && oldmap.get(opp.id).State__c!=null && !String.isBlank( oldmap.get(opp.id).State__c)){
stateOld = opp.State__c;
}

if(opp.Zipcode__c!=null && !String.isBlank(opp.Zipcode__c)){
zipcode = opp.Zipcode__c;
}
if(oldMap!=null && oldmap.get(opp.id).Zipcode__c!=null && !String.isBlank( oldmap.get(opp.id).Zipcode__c)){
zipcodeOld = oldmap.get(opp.id).Zipcode__c;
}
}
}
}
System.debug('@@street :'+ street);
System.debug('@@city :'+ city);
System.debug('@@state :'+ state);
System.debug('@@zipcode :'+ zipcode);

System.debug('@@streetOld :'+ streetOld);
System.debug('@@cityOld :'+ cityOld);
System.debug('@@stateOld :'+ stateOld);
System.debug('@@zipcodeOld :'+ zipcodeOld);

Map<String,Integer> mapGroupWiseCount=new Map<String,Integer>();
Map<String,List<Opportunity>> mapAddresswiseOpps=new  Map<String,List<Opportunity>> ();
List<Opportunity> listOpps = new List<Opportunity>();

listOpps.addAll([SELECT ID,Opp_Count_With_Same_Address__c,Street__c,City__c,State__c,Zipcode__c FROM Opportunity 
Where type in('Trade','Commercial') and status__c='Open' 
and Street__c != null and City__c != null and State__c != null and Zipcode__c != null 
and Street__c LIKE :street and City__c LIKE :city 
and State__c =:state and Zipcode__c =:zipcode]);

listOpps.addAll([SELECT ID,Opp_Count_With_Same_Address__c,Street__c,City__c,State__c,Zipcode__c FROM Opportunity 
Where type in('Trade','Commercial') and status__c='Open' 
and Street__c != null and City__c != null and State__c != null and Zipcode__c != null 
and Street__c LIKE :streetOld and City__c LIKE :cityOld 
and State__c =:stateOld and Zipcode__c =:zipcodeOld]);

System.debug('@@listOpps :'+listOpps.size());

for(Opportunity opp : listOpps){
if(!mapGroupWiseCount.containsKey(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)){
mapGroupWiseCount.put(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c,0);
mapAddresswiseOpps.put(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c,new List<Opportunity>());
}
mapGroupWiseCount.put(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c, mapGroupWiseCount.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)+1);
mapAddresswiseOpps.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c).add(opp);
}
System.debug('@@mapGroupWiseCount :'+mapGroupWiseCount);

List<Opportunity> listOppsToUpdate=new List<Opportunity>();
for(Opportunity opp : listOpportunity){
if(opp.type=='Trade' || opp.type=='Commercial'){
if(mapGroupWiseCount.containsKey(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)){
System.debug('@@Inside '+ opp.Id);
opp.Opp_Count_With_Same_Address__c = mapGroupWiseCount.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c);
for(Opportunity oppRec : mapAddresswiseOpps.get(opp.Street__c+opp.City__c+opp.State__c+opp.Zipcode__c)){
if(opp.Id != oppRec.Id){
oppRec.Opp_Count_With_Same_Address__c = opp.Opp_Count_With_Same_Address__c;
listOppsToUpdate.add(oppRec);
}
}
}
}
}

Boolean oppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
OpportunityTriggerHandler.RUN_TRIGGER=false;
update listOppsToUpdate; 
OpportunityTriggerHandler.RUN_TRIGGER=oppTrigger;

}*/
}