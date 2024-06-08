public class LeadConvertController {
    @AuraEnabled
    public static Map<String,String> getLeadPostalCode(String leadId) {
        Map<String,String> resultMap=new Map<String,String>();
        String postalCode= '';
        Boolean appointmentType;
        List<Lead> leadList = [SELECT Id, Name, PostalCode, Status,Appointment_Type__c,Virtual_Appointment__c  FROM Lead WHERE Id =: leadId];
        if(leadList.size() > 0){
            if(leadList[0].Status == 'Qualified'){
                postalCode = leadList[0].PostalCode;
                appointmentType=leadList[0].Virtual_Appointment__c ;
                resultMap.put('AppointmentType',leadList[0].Appointment_Type__c);
            }else{
                resultMap.put('Error',System.Label.Lead_Status_Not_Qualified);
            }
            
        }
        
        List<Endpoint_Configuration__mdt> ecMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Lead_Convert' ]; 
        if(ecMetaData.size()>0 && postalCode!=''){
            resultMap.put('Result', ecMetaData[0].Endpoint__c+'?zipcode='+postalCode+'&leadid='+leadId+'&appointmenttype='+(appointmentType?RTAIntegration.VirtualAppointment:RTAIntegration.InHomeAppointment));
            return resultMap ;
        }
        return resultMap;
    }
    
    @AuraEnabled
    public static Map<String,String> convertLeadToOpp(String leadId,DateTime StartDateTime,DateTime EndDateTime) {
        Map<String,String> resultMap=new Map<String,String>();
        resultMap.put('Result', 'Success');
        
        Map<String,String> urlStringsMap = new Map<String,String>{  'utmcampaign' => 'utmcampaign__c', 'utmcontent' => 'utmcontent__c', 
                                                                    'utmmedium' => 'utmmedium__c', 'utmsource' => 'utmsource__c', 
                                                                    'pel_campaign_code' => 'pel_campaign_code__c', 'reqType' => 'reqType__c', 
                                                                    'parentSite' => 'parentSite__c', 'EloquaID' => 'EloquaID__c' };
        
        
                                                                        
        Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(DateTime.now())/1000;
                                                                        
        If(StartDateTime >= EndDateTime)throw new AuraHandledException('The Appointment Start date time must be earlier than the Appointment End date time');                                                                        
        Lead leadObj=new Lead();
        leadObj.Id=leadId;
        leadObj.Scheduled_Start__c = StartDateTime.addSeconds(TimeZoneGMTdiffSec);
        leadObj.Scheduled_End__c = EndDateTime.addSeconds(TimeZoneGMTdiffSec);
        update leadObj;
        
        leadObj = [SELECT ID, Opportunity_No__c, FirstName, LastName, Street, Country, City, State, PostalCode, HomePhone__c,Response_Channel__c,
                   			      HasOptedOutOfFax,HasOptedOutOfEmail,Text_Opt_Out__c,PersonHasOptedOutofMail__c,PersonAutoCall__c,DoNotCall,
                                  MobilePhone__c, Phone,AsstPhone__c, Email, Conversion_Comments__c, Scheduled_Start__c,
                                  Scheduled_End__c, No_of_Windows__c, No_of_Doors__c, Showroom_Request_Type__c, Campaign__c,Zone__r.ParentTerritory.Branch__r.Branch_Number__c,LeadSource_RTA__c
                                  FROM Lead WHERE Id =:leadId];
                     
        
        ServicePOSTRTA.Request req=makeRequestForRTA(leadObj);
        String reqBody=JSON.serialize(req);
        
         // Trim zip code if needed 
        String zip = ServiceUtil.trimZipCode(leadObj.PostalCode);
        
        String canadianZipcode= !zip.isNumeric() && zip.length() > 3 ? zip.substring(0,3) + '%' : '' ;

        List<ServiceTerritory> lstServiceTerritory ;
        
        lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                               ParentTerritory.ParentTerritory.Branch__c, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c 
                               FROM ServiceTerritory 
                               WHERE PostalCode != NULL AND (PostalCode=:zip OR PostalCode LIKE :canadianZipcode ) AND RecordType.Name='Zipcode' ];
        
        if(String.isBlank(req.zip))
        {
            lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                   ParentTerritory.ParentTerritory.Branch__c, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c 
                                   FROM ServiceTerritory 
                                   WHERE ParentTerritory.Parent_Branch__c = '998' AND RecordType.Name='Zipcode' LIMIT 1 ];
        }
        
        if(lstServiceTerritory.size()>0)
        {
            // check login user exist as sales resource
            List<ServiceResource> listSR=[SELECT ID,Primary_Branch_Family__c,isActive from ServiceResource where ServiceResource.RelatedRecordId = :lstServiceTerritory[0].ParentTerritory.Lead_Receiver__c];
            if(listSR.size()==0){
                throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_Exist);
            }else{
                if(listSR[0].isActive==false){
                    throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_Active);
                }
                // Check memeber exist as primary
                List<ServiceTerritoryMember> listPrimarySTM=[SELECT Id,ServiceTerritoryId,EffectiveStartDate,EffectiveEndDate,ServiceResourceId,ServiceResource.RelatedRecordId,ServiceResource.RelatedRecord.Name FROM ServiceTerritoryMember 
                                                             Where ServiceResourceId = : listSR[0].Id and TerritoryType='P' ];
                if(listPrimarySTM.size()==0){
                    throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_As_Primary_Member);
                }
            }
        }
        
        
        // Get Branch information based on BranchID
        String branchId = ServicePOSTRTA.getBranchInfo(req.branchID);
        
        
        ServiceTerritory zoneST ;
        if(lstServiceTerritory.size()>0)
        {
            // Parent Territory (Zone Territory) of Zipcode territory
            zoneST = lstServiceTerritory[0].ParentTerritory;
			req.TimeZone_Code=lstServiceTerritory[0].ParentTerritory.OperatingHours.TimeZone;
        }
        System.debug('UAC: zoneST ' + zoneST );
        
        
        // Create or Update Customer Account 
        Account ac = ServicePOSTRTA.createUpdateCustomerAccount(req, zoneST, reqBody);
        System.debug('@@ac1 : '+ac.Id);
        System.debug('@@ac2 : '+ac.PersonContactId);
        
        // Create or Update Address
        Address__c addr = ServicePOSTRTA.createUpdateAddress(req, zoneST, reqBody);
        
        // Create or Update Account Branch Profile related to Account and Branch
        Account_Branch_Profile__c abf = ServicePOSTRTA.createUpdateAccountBranchProfile(branchId, ac.Id);
        
        // Get Address Assingment for Account and AccountBranchProfile, if doesn't exists then create new one
        List<Address_Assignment__c> addressAssignments = ServicePOSTRTA.createAddressAssignment(addr.Id, abf.Id, zoneST);
        
        // Get All open opportunities under Account and Account Branch Profile
        Date cutOffFiscalYear = Date.newInstance(2019, 12, 1);
        List<Opportunity> openOpps = [SELECT Id,Opportunity_No__C FROM Opportunity WHERE Account_Branch_Profile__c = :abf.Id AND AccountId = :ac.Id AND IsClosed = FALSE AND CreatedDate > :cutOffFiscalYear ];
        System.debug('UAC: openOpps ' + openOpps );
        
        // When OPEN Opportunity Found for AccountBranchProfile and existing AddressAssignment
        if( openOpps.size() > 0 && addressAssignments.size() > 0 )
        { 
            new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadConvertController','convertLeadToOpp',reqBody,System.Label.Duplicate_Opportunity_Found.replace('<OppNo>',openOpps[0].Opportunity_No__C),'Integration'));
        	throw new AuraHandledException(System.Label.Duplicate_Opportunity_Found.replace('<OppNo>',openOpps[0].Opportunity_No__C));
        }
        createOpportunityAndSAFuture(JSON.serialize(req), abf.Id, ac.Id, urlStringsMap, zoneST.Id, reqBody );    
        
        // Attach Oppo with lead if lead exist
        /*List<Opportunity> listOpportunity=[SELECT ID,AccountId From Opportunity Where Opportunity_No__c =:req.oppNo];
        if(listOpportunity.size()>0){
            leadObj.ConvertedOpportunityId__c=listOpportunity[0].Id;
        }   */
        // Update Lead Status
        leadObj.Status = 'Converted';
        update leadObj;        
       
      
        return resultMap;
    }
    @Future(callout=true)
    public static void createOpportunityAndSAFuture(String reqString, Id abfId, Id acId, Map<String,String> urlStringsMap, String zoneSTId, String reqBody){
         ServicePOSTRTA.Request req=(ServicePOSTRTA.Request)JSON.deserialize(reqString, ServicePOSTRTA.Request.class);
         ServiceTerritory zoneST=[SELECT Id,Lead_Receiver__c From ServiceTerritory where Id=:zoneSTId];
        
        // When no Opportunity for existing Address Assignment - OR - // For New Address Assignment 
        createOpportunityAndServiceAppointment(req, abfId, acId, urlStringsMap, zoneST, reqBody );        
        // EBS Full Load Callout
        System.enqueueJob(new EBSFullLoad(acId, UserInfo.getSessionId()  ));
        
    }
    public static ServicePOSTRTA.Request makeRequestForRTA(Lead leadObj)
    {
        ServicePOSTRTA.Request reqRTA = new ServicePOSTRTA.Request();
        // Make efficient Request Attributes by checking null values 
        reqRTA.oppNo = String.isBlank(leadObj.Opportunity_No__c) ? '' : leadObj.Opportunity_No__c;
        reqRTA.firstname = String.isBlank(leadObj.FirstName) ? '' : leadObj.FirstName;
        reqRTA.lastname = String.isBlank(leadObj.LastName) ? '' : leadObj.LastName;
        reqRTA.address = String.isBlank(leadObj.Street) ? '' : leadObj.Street;
        reqRTA.country = String.isBlank(leadObj.Country) ? '' : leadObj.Country;
        if(reqRTA.country.length() == 3) reqRTA.country = reqRTA.country.left(2);
        reqRTA.city = String.isBlank(leadObj.City) ? '' : leadObj.City;
        reqRTA.state = String.isBlank(leadObj.State) ? '' : leadObj.State;
        if(reqRTA.state.length() == 3) reqRTA.state = reqRTA.state.left(2);
        reqRTA.zip =  String.isBlank(leadObj.PostalCode) ? '' : leadObj.PostalCode;
        
        String dayPhone = String.isBlank(String.valueOf(leadObj.HomePhone__c)) ? String.isBlank(String.valueOf(leadObj.MobilePhone__c))? String.isBlank(String.valueOf(leadObj.Phone))? '' : String.valueOf(leadObj.Phone): String.valueOf(leadObj.MobilePhone__c): String.valueOf(leadObj.HomePhone__c);
        String phonetype = String.isBlank(String.valueOf(leadObj.HomePhone__c)) ? String.isBlank(String.valueOf(leadObj.MobilePhone__c))? String.isBlank(String.valueOf(leadObj.Phone))? '' : 'Work': 'Mobile': 'Home';
        reqRTA.dayphone = dayPhone;
        reqRTA.phonetype = phonetype ;
        reqRTA.email = String.isBlank(leadObj.Email) ? '' : leadObj.Email;
        reqRTA.evephone = String.isBlank(leadObj.AsstPhone__c) ? '' : leadObj.AsstPhone__c;
        reqRTA.urlstring = '';
        reqRTA.branchID = leadObj.Zone__r.ParentTerritory.Branch__r.Branch_Number__c;
         reqRTA.apptsource = string.isBlank(leadObj.Response_Channel__c)?'Showroom': leadObj.Response_Channel__c;
        reqRTA.comments = String.isBlank(leadObj.Conversion_Comments__c) ? '' : leadObj.Conversion_Comments__c;
        reqRTA.destination = '' ;
        reqRTA.start = String.isBlank(String.valueOf(leadObj.Scheduled_Start__c)) ? '' : String.valueOf(leadObj.Scheduled_Start__c);
        reqRTA.end_z = String.isBlank(String.valueOf(leadObj.Scheduled_End__c)) ? '' : String.valueOf(leadObj.Scheduled_End__c);
        reqRTA.noOfWindows = leadObj.No_of_Windows__c == null ? 0 : Integer.valueOf(leadObj.No_of_Windows__c);
        reqRTA.noOfDoors = leadObj.No_of_Doors__c == null ? 0 : Integer.valueOf(leadObj.No_of_Doors__c);
        reqRTA.resource = '';
        reqRTA.notifyemail = leadObj.PersonHasOptedOutofMail__c?'N':'Y';
        reqRTA.consentsms = leadObj.Text_Opt_Out__c?'N':'Y';
        reqRTA.consentcall = leadObj.PersonAutoCall__c?'N':'Y';
        reqRTA.consenttophone = leadObj.DoNotCall?'N':'Y';
        reqRTA.consenttomail = leadObj.HasOptedOutOfEmail?'N':'Y';
        reqRTA.apptreqtype = '';
        reqRTA.appttype = 'NRT';
        reqRTA.storename = '';
        reqRTA.callerId = '';
        reqRTA.callcenteruid = '';
        reqRTA.virtualapptmt=false;
     
        reqRTA.showroomreqtype = String.isBlank(leadObj.Showroom_Request_Type__c) ? '' : leadObj.Showroom_Request_Type__c;
        if(!String.isBlank(leadObj.Campaign__c)){
            reqRTA.marketingsource = leadObj.Campaign__c;
            reqRTA.leadsource = leadObj.LeadSource_RTA__c;
        }
        
        
        return reqRTA ;
    }
    
    public static void createOpportunityAndServiceAppointment(ServicePOSTRTA.Request req, Id abfId, Id accountId, Map<String,String> urlStringsMap, ServiceTerritory zoneST, String reqBody)
    {
        
        // Get long URLString attribute from JSON
        List<String> urlStrings = ServicePOSTRTA.parseURLStrings(req.urlstring);
        //System.debug('UAC: urlStrings ' + urlStrings );
        
        // Make start date and end date
        DateTime startDate ;
        DateTime startDateEmail ;
        DateTime endDate ;
        DateTime nextDay12AM ;
        if(String.isNotBlank(req.start)) startDate = DateTime.valueOf(req.start.replace('T', ' ').replace('Z', '')) ;
        if(String.isNotBlank(req.end_z)) endDate = DateTime.valueOf(req.end_z.replace('T', ' ').replace('Z', '')) ;
        startDateEmail = startDate;
        
        if(startDate != null ) nextDay12AM = Datetime.newInstance(startDate.addDays(1).date() , Time.newInstance(0, 0, 0, 0) );
        
        
        // change timezone before save
        if(!String.isBlank(req.TimeZone_Code) && startDate != null )
        {
            TimeZone tz = TimeZone.getTimeZone(req.TimeZone_Code);
            startDate=startDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
            endDate=endDate.addSeconds((tz.getOffset(startDate)/1000)*-1);
            nextDay12AM=nextDay12AM.addSeconds((tz.getOffset(startDate)/1000)*-1);
        }
        
        // Prepare Opportunity Name 
        String oppName = req.firstname + ' ' + req.lastname + ' - ' + req.address + ', ' + req.city + ', ' + req.state + ', ' + + req.country + ' ' + req.zip ;
        //Added on 19/10/2020
        Id OppRecTyId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Replacement').RecordTypeId;

        // Create Opportunity 
        Opportunity opp = new Opportunity(  Name = oppName, LeadSource = req.apptsource, Account_Branch_Profile__c = abfId, AccountId = accountId, 
                                          Description = req.comments , StageName = 'New', Type = 'FSL Sales Appointment', Opportunity_No__c = req.oppNo,
                                          Number_of_Windows__c = req.noOfWindows, Number_of_Doors__c = req.noOfDoors, Status__c = 'New',
                                          Phone_Number_Type_Email_Template__c = req.dayphone + ' (' + req.phonetype + ')', Email_Email_Template__c = req.email, 
                                          Appointment_Type__c = req.appttype, Appointment_DateTime__c = startDate, Appointment_DateTime_Email__c = startDateEmail,
                                          CallerId__c = req.callerId, Callcenteruid__c = req.callcenteruid, LeadSource_RTA__c = req.leadsource,
                                          Showroom_Request_Type__c = req.showroomreqtype, How_did_you_hear_about_Pella__c = req.leadsource, 
                                          Virtual_Appointment__c = req.virtualapptmt, recordTypeId =OppRecTyId  ) ;
        
        
        // For web RTA appointments, if there is no campaign information sent from pella.com, the opps should be associated with a catch campaign id 
        if(opp.Pel_campaign_code__c == NULL && opp.LeadSource == 'Web')
        {
            List<Campaign> lstcampaign = [SELECT Id, Source_Code__c FROM Campaign WHERE Source_Code__c = 'PEL617021947'];
            if(lstcampaign.size() > 0) {
                opp.Campaignid = lstcampaign[0].Id ;
                opp.Pel_campaign_code__c = lstcampaign[0].Source_Code__c;
            }
        }
        
        if(endDate == null ) endDate = System.now(); 
        opp.CloseDate = endDate.date().addDays(49) ;
        
        // Iterate over JSON fields and values, and update Opportunity fields if field name found in FieldsMap
        for(String str : urlStrings)
        {
            String fieldName = str.left(str.indexOf(':'));
            //System.debug('UAC: fieldName ' + fieldName );
            
            String fieldValue = str.substring(str.indexOf(':')+1); 
            //System.debug('UAC: fieldValue ' + fieldValue );
            
            if(urlStringsMap.containsKey(fieldName)) opp.put(urlStringsMap.get(fieldName), fieldValue);  
        }
        
        if(zoneST != null) 
        {
            opp.Zone__c = zoneST.Id ;
            
            // Assign Owner from Zone Territory for All types (Call Center[RT,Preferred], Web[RT,Preferred], ShowRoom[RT,Preferred])
            if(String.isNotBlank(zoneST.Lead_Receiver__c)) opp.OwnerId = zoneST.Lead_Receiver__c ;
        }
        
        if(String.isNotBlank(req.marketingsource) )
        {
            List<Campaign> campaigns = [SELECT Id,Source_Code__c FROM Campaign WHERE Id = :req.marketingsource AND Status = 'Active' ];
            if(campaigns.size() > 0) {
                opp.CampaignId = campaigns[0].Id ;
                opp.pel_campaign_code__c = campaigns[0].Source_Code__c;
            }
        }
        
        // Find matching Campaign based on Opporutnity.Pel_campaign_code__c and populate on Opportunity 
        if( opp.LeadSource == 'Web' && String.isNotBlank(opp.Pel_campaign_code__c))
        {
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Source_Code__c = :opp.Pel_campaign_code__c AND Status = 'Active' ];
            if(campaigns.size() > 0) opp.CampaignId = campaigns[0].Id ;
        }
        
        if( opp.LeadSource == 'Call Center' && String.isNotBlank(opp.LeadSource_RTA__c))
        {
            Decimal rtaLeadSource = Decimal.valueOf(opp.LeadSource_RTA__c);
            List<Campaign> campaigns = [SELECT Id,Source_Code__c FROM Campaign WHERE Toll_Free_Number__c = :rtaLeadSource AND Status = 'Active' ];
            if(campaigns.size() > 0) {
                opp.CampaignId = campaigns[0].Id ;
                opp.pel_campaign_code__c = campaigns[0].Source_Code__c;
            }
        }
        
        
        opp.Appointment_Next_Day_12AM__c = nextDay12AM ;
		if(zoneST!=null)
            opp.Best_Match__c = zoneST.Lead_Receiver__c ;
        
        // Insert Opportunity
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.insert(opp, dml) ;
         
        Id softAssignId = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('Soft_Assign').RecordTypeId;
        Id saFullDetailRTId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Hard_Assign').getRecordTypeId();
        
        System.debug('@@ accountId: '+accountId);
        // Insert Service appointment under Opporutnity
        ServiceAppointment sa = new ServiceAppointment( RecordTypeId = softAssignId, Subject = oppName, street=req.address, country=req.country, City = req.city, State = req.state, PostalCode = req.zip,
                                                       ContactId = [SELECT PersonContactId FROM Account WHERE ID = :accountId FOR UPDATE ].PersonContactId,
                                                       Description = req.comments, Opportunity__c = opp.Id, DueDate = endDate, EarliestStartTime = startDate, 
                                                       SchedStartTime =startDate, Start_Datetime__c = startDate, End_Datetime__c = endDate, SchedEndTime = endDate,
                                                       Virtual_Appointment__c = req.virtualapptmt );
        
        
        //sa.Status = 'Soft Assigned' ;
        if(zoneST!=null)
            sa.OwnerId = zoneST.Lead_Receiver__c ;
        
        
        //changed on 15-05 to resolve the issue of Unable to lock the row issue
        List<String> listSAPlaceLead=System.Label.Soft_Assign_Placeholder_Lead_ID.split(',');
        String leadSAId;
        try{
        	leadSAId= listSAPlaceLead[Integer.valueOf( Math.random() * (listSAPlaceLead.size() - 1))];
        }catch(Exception e){
            leadSAId=listSAPlaceLead[0];
        }
        sa.ParentRecordId =leadSAId ; //System.Label.Soft_Assign_Placeholder_Lead_ID ; 
            
            
        sa.Status = 'Soft Assigned' ;
        ServiceAppointmentTriggerHandler.CREATE_ASSIGNED_RESOUCE_ON_OWNER_CHANGE = True ;
        
        try{
            if(!Test.isRunningTest()) insert sa ;
        }
        catch(DmlException de){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('LeadConvertController','createOpportunityAndServiceAppointment',reqBody,de.getMessage(),'Integration'));
        }
       
    }
}