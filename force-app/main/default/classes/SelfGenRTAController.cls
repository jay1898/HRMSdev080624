public without sharing class SelfGenRTAController {
    public class RTARequest{
        String FirstName;
        String LastName;
        String Email;
        String Phone;
        String PhoneType;
        String Address;
        String Address2;
        String City;
        String State;
        String Zipcode;
        String ProjectDetail;
        String StartDateTime;
        String EndDateTime;
        String noOfDoors;
        String noOfWindows;
        String TimeZone_Code;
    }
    
    public class OppOwnerWrapper{
        public string OwnerId;
        public String OwnerName;
        public Boolean hasAppointment;
        public List<ServiceAppointment> listAppointment;
        public List<ResourceAbsence> listResourceAbsence;
    }
    
    
    @AuraEnabled
    public static Map<String,String> validateTimeBlock(String requestData) {
        Map<String,String> resultMap=new Map<String,String>();
        resultMap.put('Result', 'Success');
        RTARequest RTAReq=(RTARequest)JSON.deserialize(requestData, RTARequest.class);
        DateTime startDate,endDate;
        system.debug('@@ RTAReq.StartDateTime :: '+RTAReq.StartDateTime);
        Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(DateTime.now())/1000;
        if(String.isNotBlank(RTAReq.StartDateTime)) startDate = DateTime.valueOfGmt(RTAReq.StartDateTime.replace('T', ' ').replace('Z', '')) ;
        if(String.isNotBlank(RTAReq.EndDateTime)) endDate = DateTime.valueOfGmt(RTAReq.EndDateTime.replace('T', ' ').replace('Z', '')) ;
        if(startDate!=null && enddate!=null){ 
            //startDate=startDate.addSeconds(TimeZoneGMTdiffSec);
            //endDate=endDate.addSeconds(TimeZoneGMTdiffSec);
            RTAReq.StartDateTime= startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
            RTAReq.EndDateTime= endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
        }
        system.debug('@@ RTAReq.StartDateTime :: '+RTAReq.StartDateTime);
        // check Zipcode validation
        
       // Rekha 07/28 added trim function
       // String postalCode=String.isBlank(RTAReq.Zipcode) ? '' : RTAReq.Zipcode;
        String postalCode= ServiceUtil.trimZipCode(RTAReq.Zipcode); 
        String canadianZipcode= !postalCode.isNumeric() && postalCode.length() > 3 ? postalCode.substring(0,3) + '%' : '' ;
        List<ServiceTerritory> lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                                      ParentTerritory.ParentTerritory.Branch__c,ParentTerritory.RecordType.Name,
                                                      ParentTerritory.ParentTerritory.Branch__r.Branch_Family__c, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c 
                                                      FROM ServiceTerritory 
                                                      WHERE PostalCode != NULL AND (PostalCode=:postalCode OR PostalCode LIKE :canadianZipcode ) AND RecordType.Name='Zipcode' ];
        
        ServiceTerritory zoneST ;
        
        if(lstServiceTerritory.size()==0){
            throw new AuraHandledException(System.Label.Zipcode_Not_Found);
        }
        else if(lstServiceTerritory.size()>0){
            zoneST = lstServiceTerritory[0].ParentTerritory;
            if(lstServiceTerritory[0].ParentTerritory.RecordType.Name !='RT Zone'){
                throw new AuraHandledException(System.Label.Zipcode_Not_Belong_To_RT_Zone);
            }
            // check login user belongs to same family 
            List<ServiceResource> listSR=[SELECT ID,Primary_Branch_Family__c,isActive from ServiceResource where ServiceResource.RelatedRecordId = :UserInfo.getUserId()];
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
                
                if(!(lstServiceTerritory[0].ParentTerritory.ParentTerritory.Branch__r.Branch_Family__c!=null && listSR[0].Primary_Branch_Family__c!=null && listSR[0].Primary_Branch_Family__c==lstServiceTerritory[0].ParentTerritory.ParentTerritory.Branch__r.Branch_Family__c)){
                    List<ServiceTerritoryMember> STM=[SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId 
                                                      FROM ServiceTerritoryMember 
                                                      WHERE ServiceTerritoryId = :lstServiceTerritory[0].ParentTerritoryId 
                                                      AND ServiceResource.IsActive = TRUE 
                                                      AND ServiceResource.RelatedRecordId != NULL
                                                      AND ServiceResource.RelatedRecordId = :UserInfo.getUserId()];
                    
                    if(STM.size()==0){
                        throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_Associate_with_zipcode);
                    }
                }
            }
        }
        
        List<OppOwnerWrapper> OppOwnerList=new List<OppOwnerWrapper>();
        system.debug('@@startDate'+startDate);
        system.debug('@@endDate'+endDate);
        system.debug('@@OwnerId'+UserInfo.getUserId() );
        List<ServiceAppointment> listSAList=[SELECT ID,AppointmentNumber,SchedStartTime,SchedEndTime,OwnerId FROM ServiceAppointment 
                                             Where OwnerId=:UserInfo.getUserId() 
                                             and ((SchedStartTime<= :startDate And SchedEndTime > :startDate)
                                                  OR (SchedStartTime< :endDate AND SchedEndTime> :endDate)
                                                  OR ( SchedStartTime>= :startDate AND SchedEndTime<= :endDate ))
                                             order by SchedStartTime];
        
        system.debug('@@listSAList'+listSAList.size() );
        system.debug('@@listSAList'+listSAList.size() );
        
        List<ResourceAbsence> listRAList=[SELECT ID,AbsenceNumber,Start,End,ResourceId,Resource.RelatedRecordId FROM ResourceAbsence 
                                          Where Resource.RelatedRecordId=:Userinfo.getUserId() 
                                          and ((Start<= :startDate And End > :startDate)
                                               OR (Start< :endDate AND End> :endDate)
                                               OR ( Start>= :startDate AND End<= :endDate ))
                                          order by Start];
        
        OppOwnerWrapper OppOwner=new OppOwnerWrapper();
        OppOwner.OwnerId=Userinfo.getUserId();
        if(listSAList.size()>0){
            OppOwner.hasAppointment=true;
            OppOwner.listAppointment=listSAList;
        }
        if(listRAList.size()>0){
            OppOwner.hasAppointment=true;
            OppOwner.listResourceAbsence=listRAList;
        }
        resultMap.put('OppOwnerResult',JSON.serialize(OppOwner));
        return resultMap;
    }
    @AuraEnabled
    public static Map<String,String> submitRTARequest(String requestData) {
        Map<String,String> resultMap=new Map<String,String>();
        resultMap.put('Result', 'Success');
        RTARequest RTAReq=(RTARequest)JSON.deserialize(requestData, RTARequest.class);
        DateTime startDate,endDate;
        system.debug('@@ RTAReq.StartDateTime :: '+RTAReq.StartDateTime); 
        if(String.isNotBlank(RTAReq.StartDateTime)) startDate = DateTime.valueOfGmt(RTAReq.StartDateTime.replace('T', ' ').replace('Z', '')) ;
        if(String.isNotBlank(RTAReq.EndDateTime)) endDate = DateTime.valueOfGmt(RTAReq.EndDateTime.replace('T', ' ').replace('Z', '')) ;
        if(startDate!=null && enddate!=null){ 
            Integer TimeZoneGMTdiffSec=Userinfo.getTimeZone().getOffset(startdate)/1000;
            RTAReq.StartDateTime= startDate.addSeconds(TimeZoneGMTdiffSec).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
            RTAReq.EndDateTime= endDate.addSeconds(TimeZoneGMTdiffSec).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
        }
        // check Zipcode validation
       // String postalCode=String.isBlank(RTAReq.Zipcode) ? '' :  ServiceUtil.trimZipCode(RTAReq.Zipcode); //RTAReq.Zipcode;
       // Rekha 07/28 added trim function
        String postalCode= ServiceUtil.trimZipCode(RTAReq.Zipcode); // String.isBlank(RTAReq.Zipcode) ? '' :  RTAReq.Zipcode;
        String canadianZipcode= !postalCode.isNumeric() && postalCode.length() > 3 ? postalCode.substring(0,3) + '%' : '' ;
        List<ServiceTerritory> lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                                      ParentTerritory.ParentTerritory.Branch__c,ParentTerritory.RecordType.Name,
                                                      ParentTerritory.ParentTerritory.Branch__r.Branch_Family__c, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c , ParentTerritory.Lead_Receiver__r.Email
                                                      FROM ServiceTerritory 
                                                      WHERE PostalCode != NULL AND (PostalCode=:postalCode OR PostalCode LIKE :canadianZipcode ) AND RecordType.Name='Zipcode' ];
        
        ServiceTerritory zoneST ;
        
        if(lstServiceTerritory.size()==0){
            throw new AuraHandledException(System.Label.Zipcode_Not_Found);
        }
        else if(lstServiceTerritory.size()>0){
            zoneST = lstServiceTerritory[0].ParentTerritory;
            if(lstServiceTerritory[0].ParentTerritory.RecordType.Name !='RT Zone'){
                throw new AuraHandledException(System.Label.Zipcode_Not_Belong_To_RT_Zone);
            }
            /*List<ServiceTerritoryMember> STM=[SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId 
FROM ServiceTerritoryMember 
WHERE ServiceTerritoryId = :lstServiceTerritory[0].ParentTerritoryId 
AND ServiceResource.IsActive = TRUE 
AND ServiceResource.RelatedRecordId != NULL
AND ServiceResource.RelatedRecordId = :UserInfo.getUserId()];

if(STM.size()==0){
throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_Associate_with_zipcode);
}*/
            // check login user belongs to same family 
            List<ServiceResource> listSR=[SELECT ID,Primary_Branch_Family__c from ServiceResource where ServiceResource.RelatedRecordId = :UserInfo.getUserId()];
            if(listSR.size()==0){
                throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_Exist);
            }else{
                if(!(lstServiceTerritory[0].ParentTerritory.ParentTerritory.Branch__r.Branch_Family__c!=null && listSR[0].Primary_Branch_Family__c!=null && listSR[0].Primary_Branch_Family__c==lstServiceTerritory[0].ParentTerritory.ParentTerritory.Branch__r.Branch_Family__c)){
                    List<ServiceTerritoryMember> STM=[SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId 
                                                      FROM ServiceTerritoryMember 
                                                      WHERE ServiceTerritoryId = :lstServiceTerritory[0].ParentTerritoryId 
                                                      AND ServiceResource.IsActive = TRUE 
                                                      AND ServiceResource.RelatedRecordId != NULL
                                                      AND ServiceResource.RelatedRecordId = :UserInfo.getUserId()];
                    
                    if(STM.size()==0){
                        throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_Associate_with_zipcode);
                    }
                    //throw new AuraHandledException(System.Label.Self_Gen_Resource_Not_Associate_with_zipcode);
                }
            }
        }
        
        Map<String,String> urlStringsMap = new Map<String,String>{  'utmcampaign' => 'utmcampaign__c', 'utmcontent' => 'utmcontent__c', 
            'utmmedium' => 'utmmedium__c', 'utmsource' => 'utmsource__c', 
            'pel_campaign_code' => 'pel_campaign_code__c', 'reqType' => 'reqType__c', 
            'parentSite' => 'parentSite__c', 'EloquaID' => 'EloquaID__c' };
                
                
                
                ServicePOSTRTA.Request req=makeRequestForRTA(RTAReq);
        String reqBody=JSON.serialize(req);
        
        // Get Branch information based on BranchID
        String branchId ='';
        
        if(lstServiceTerritory.size()>0)
        {
            // Parent Territory (Zone Territory) of Zipcode territory
            zoneST = lstServiceTerritory[0].ParentTerritory;
            branchId=lstServiceTerritory[0].ParentTerritory.ParentTerritory.Branch__c;
            req.TimeZone_Code=lstServiceTerritory[0].ParentTerritory.OperatingHours.TimeZone;
        }
        System.debug('UAC: zoneST ' + zoneST );
        
        // Trim zip code if needed 
        String zip = ServiceUtil.trimZipCode(postalCode);
        
        if(String.isBlank(req.zip))
        {
            lstServiceTerritory = [ SELECT  Id, ParentTerritoryId, ParentTerritory.RecordType.DeveloperName, ParentTerritory.OperatingHours.TimeZone,
                                   ParentTerritory.ParentTerritory.Branch__c, ParentTerritory.ApptDurationMin__c, ParentTerritory.Lead_Receiver__c 
                                   FROM ServiceTerritory 
                                   WHERE ParentTerritory.Parent_Branch__c = '998' AND RecordType.Name='Zipcode' LIMIT 1 ];
        }
        
        
        // Create or Update Customer Account 
        Account ac = ServicePOSTRTA.createUpdateCustomerAccount(req, zoneST, reqBody);
        
        // Create or Update Address
        Address__c addr = ServicePOSTRTA.createUpdateAddress(req, zoneST, reqBody);
        
        // Create or Update Account Branch Profile related to Account and Branch
        Account_Branch_Profile__c abf = ServicePOSTRTA.createUpdateAccountBranchProfile(branchId, ac.Id);
        
        // Get Address Assingment for Account and AccountBranchProfile, if doesn't exists then create new one
        List<Address_Assignment__c> addressAssignments = ServicePOSTRTA.createAddressAssignment(addr.Id, abf.Id, zoneST);
        
        // Get All open opportunities under Account and Account Branch Profile
        Date cutOffFiscalYear = Date.newInstance(2019, 12, 1);
        List<Opportunity> openOpps = [SELECT Id,Opportunity_no__c FROM Opportunity WHERE Account_Branch_Profile__c = :abf.Id AND AccountId = :ac.Id AND IsClosed = FALSE AND CreatedDate > :cutOffFiscalYear ];
        System.debug('UAC: openOpps ' + openOpps );
        
        // When OPEN Opportunity Found for AccountBranchProfile and existing AddressAssignment
        if( openOpps.size() > 0 && addressAssignments.size() > 0 )
        { 
            throw new AuraHandledException(System.Label.Duplicate_Opportunity_Found.replace('<OppNo>',openOpps[0].Opportunity_No__C));
        }
        String newOppId;
        // When no Opportunity for existing Address Assignment - OR - // For New Address Assignment 
        if( (openOpps.size() == 0 && addressAssignments.size() > 0) || addressAssignments.size() == 0 )  
            newOppId=createOpportunityAndServiceAppointment(req, abf, ac, urlStringsMap, zoneST, reqBody );        
        
        // EBS Full Load Callout
        System.enqueueJob(new EBSFullLoad(ac.Id, UserInfo.getSessionId()  ));
        resultMap.put('OppId', newOppId);
        
        return resultMap;
    }
    public static ServicePOSTRTA.Request makeRequestForRTA(RTARequest requestData)
    {
        ServicePOSTRTA.Request reqRTA = new ServicePOSTRTA.Request();
        reqRTA.firstname = String.isBlank(requestData.FirstName) ? '' : requestData.FirstName;
        reqRTA.lastname = String.isBlank(requestData.LastName) ? '' : requestData.LastName;
        reqRTA.address = String.isBlank(requestData.address) ? '' : requestData.address;
        reqRTA.address = reqRTA.address +' '+ (String.isBlank(requestData.address2) ? '' : requestData.address2);
        reqRTA.city = String.isBlank(requestData.city) ? '' : requestData.city;
        reqRTA.state = String.isBlank(requestData.state) ? '' : requestData.state;
        //Rekha 07/27/2020, default country based on zipcode
        String ziptemp = ServiceUtil.trimZipCode(requestData.Zipcode);
        if (ziptemp.isnumeric())
        {
          reqRTA.country = 'US';
        }
        else
        {   
            reqRTA.country = 'CA';
        }
         
        
        reqRTA.zip =  String.isBlank(requestData.Zipcode) ? '' : requestData.Zipcode;
        reqRTA.dayphone = String.isBlank(requestData.Phone) ? '' : requestData.Phone;
        reqRTA.phonetype = String.isBlank(requestData.phonetype) ? '' : requestData.phonetype;
        reqRTA.email = String.isBlank(requestData.Email) ? '' : requestData.Email;
        reqRTA.appttype = 'Self-Gen';
        reqRTA.apptsource = 'Salesforce';
        //reqRTA.branchID = leadObj.Zone__r.ParentTerritory.Branch__r.Branch_Number__c;
        reqRTA.start = String.isBlank(String.valueOf(requestData.StartDateTime)) ? '' : String.valueOf(requestData.StartDateTime);
        reqRTA.end_z = String.isBlank(String.valueOf(requestData.EndDateTime)) ? '' : String.valueOf(requestData.EndDateTime);
        reqRTA.noOfWindows = requestData.noOfWindows == null ? 0 : Integer.valueOf(requestData.noOfWindows);
        reqRTA.noOfDoors = requestData.noOfDoors == null ? 0 : Integer.valueOf(requestData.noOfDoors);
        reqRTA.showroomreqtype='Self-Gen';
        reqRTA.virtualapptmt=false;
        reqRTA.comments=requestData.ProjectDetail;
        reqRTA.notifyemail ='N';
        reqRTA.consentsms = 'N';
        reqRTA.consentcall = 'N';
        reqRTA.consenttophone ='N';
        reqRTA.consenttomail = 'N';
        /* // Make efficient Request Attributes by checking null values 
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
}
*/
        
        return reqRTA ;
    }
    
    public static String createOpportunityAndServiceAppointment(ServicePOSTRTA.Request req, Account_Branch_Profile__c abf, Account ac, Map<String,String> urlStringsMap, ServiceTerritory zoneST, String reqBody)
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
        Opportunity opp = new Opportunity(  Name = oppName, LeadSource = req.apptsource, Account_Branch_Profile__c = abf.Id, AccountId = ac.Id, 
                                          Description = req.comments , StageName = 'Active', Type = 'FSL Sales Appointment', Opportunity_No__c = req.oppNo,
                                          Number_of_Windows__c = req.noOfWindows, Number_of_Doors__c = req.noOfDoors, Status__c = 'Active',Phone__c=req.dayphone,
                                          Phone_Number_Type_Email_Template__c = req.dayphone + ' (' + req.phonetype + ')', Email_Email_Template__c = req.email, 
                                          Appointment_Type__c = req.appttype, Appointment_DateTime__c = startDate, Appointment_DateTime_Email__c = startDateEmail,
                                          CallerId__c = req.callerId, Callcenteruid__c = req.callcenteruid, LeadSource_RTA__c = req.leadsource,
                                          Showroom_Request_Type__c = req.showroomreqtype, How_did_you_hear_about_Pella__c = req.leadsource, 
                                          Virtual_Appointment__c = req.virtualapptmt,Sales_Rep_Email_Template__c=Userinfo.getName(), recordTypeId =OppRecTyId ) ;
        
        
        // For web RTA appointments, if there is no campaign information sent from pella.com, the opps should be associated with a catch campaign id 
        if(opp.Pel_campaign_code__c == NULL && opp.LeadSource == 'Web')
        {
            List<Campaign> lstcampaign = [SELECT Id FROM Campaign WHERE Source_Code__c = 'PEL617021947'];
            if(lstcampaign.size() > 0) opp.Campaignid = lstcampaign[0].Id ;
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
            if(String.isNotBlank(zoneST.Lead_Receiver__c)){
                opp.OwnerId = zoneST.Lead_Receiver__c ;
                opp.Lead_Receiver_Email__c = zoneST.Lead_Receiver__r.Email ;               
            }
        }
        
        if(String.isNotBlank(req.marketingsource) )
        {
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Id = :req.marketingsource AND Status = 'Active' ];
            if(campaigns.size() > 0) opp.CampaignId = campaigns[0].Id ;
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
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Toll_Free_Number__c = :rtaLeadSource AND Status = 'Active' ];
            if(campaigns.size() > 0) opp.CampaignId = campaigns[0].Id ;
        }
        
        // set lead receiver for send lead receiver email in self gen case
        opp.Original_Appt_Rep__c=opp.OwnerId;
        
        opp.Appointment_Next_Day_12AM__c = nextDay12AM ;
        opp.Best_Match__c = Userinfo.getUserId() ;
        opp.OwnerId=Userinfo.getUserId();
        
        
        // Insert Opportunity
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.SaveResult listOppResult=Database.insert(opp, dml) ;
        system.debug('@@listOppResult'+JSON.serialize(listOppResult) );
        
        Id softAssignId = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('Soft_Assign').RecordTypeId;
        Id saFullDetailRTId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Hard_Assign').getRecordTypeId();
        
        // Insert Service appointment under Opporutnity
        ServiceAppointment sa = new ServiceAppointment( RecordTypeId = softAssignId, Subject = oppName, street=req.address, country=req.country, City = req.city, State = req.state, PostalCode = req.zip,
                                                       ContactId = [SELECT PersonContactId FROM Account WHERE ID = :ac.Id FOR UPDATE ].PersonContactId,
                                                       Description = req.comments, Opportunity__c = opp.Id, DueDate = endDate, EarliestStartTime = startDate, 
                                                       SchedStartTime =startDate, Start_Datetime__c = startDate, End_Datetime__c = endDate, SchedEndTime = endDate,
                                                       Virtual_Appointment__c = req.virtualapptmt );
        
        
        //sa.Status = 'Soft Assigned' ;
        sa.OwnerId = Userinfo.getUserId() ;
        
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
        
        
        if(!Test.isRunningTest()) insert sa ;
        
        Opportunity OppRec=[SELECT Id,SG_UniqueKey__c From Opportunity where Id=:opp.Id];
        // update opportunity status and flag (before 24 hours logic run immediately )
        //opp.Status__c='Active';
        //opp.StageName='Active';
        opp.Opportunity_No__c=OppRec.SG_UniqueKey__c;
        //opp.Update_SA_Helper__c=true;
        
        // update to null as we set for temporary
        opp.Original_Appt_Rep__c=null;
        //opp.OwnerId=Userinfo.getUserId();
        
        OpportunityTriggerHandler.RUN_TRIGGER = false; // ADDED THIS ATTRIBUTE TO STOP THE RECURSIVE. TOO MANY SOQL
        update opp;
        
        return opp.Id;
    }
    
    @AuraEnabled
    public static String getProjectAddress(String queryValue){
        List<Endpoint_Configuration__mdt> searchMetaData = [SELECT Endpoint__c,Token__c FROM Endpoint_Configuration__mdt WHERE DeveloperName = 'Search_Address' ]; 
        if(searchMetaData.size()>0){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(searchMetaData[0].Endpoint__c+EncodingUtil.urlEncode(queryValue, 'UTF-8')+'&country=USA');
            request.setHeader('Auth-Token', searchMetaData[0].Token__c);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            if ( response.getStatusCode() == 200) {
                return response.getBody();
            }
        }
        return '';
    }
}