@RestResource(urlMapping='/GetApptDetails/*')

global class serviceGetApptDetails {
    
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{

            String StartDateTimeD = RestContext.request.params.get('StartDateTime');
            String EndDateTimeD = RestContext.request.params.get('EndDateTime');
            String UserEmail =     RestContext.request.params.get('UserEmail');
            String UserID = '';
            dateTime StartDateTime;
            dateTime EndDateTime;
            if(test.isRunningTest()){
                StartDateTime=dateTime.now().addDays(-1);
                EndDateTime=dateTime.now().addDays(1);
            }
            else{
                StartDateTime= dateTime.ValueOf(StartDateTimeD);
                EndDateTime= dateTime.ValueOf(EndDateTimeD);
            }
            // Intialization of ADL object to create a ADL record
            Apex_Debug_Log__c objApex = new Apex_Debug_Log__c();
            objApex.Opportunity__c=true;
            objApex.Apex_Class__c='GetApptDetails';
            objApex.Method__c='GET';
            insert objApex;
           /* String query = 'SELECT Id, AccountId,Name, Description, LeadSource, CampaignId,OwnerId,'+
                                                         'Actual_Homeowner__c,Address__c, Appointment_DateTime__c,Appointment_DateTime_Email__c,'+
                                                        'Branch__c,Appointment_Type__c, Email__c, Initial_Appt_Date__c,LeadSource_RTA__c,'+
                                                        'Opportunity_No__c,Original_Appt_Rep__c,Number_of_Doors__c,Number_of_Windows__c,'+
                                                        'Phone__c,Sales_Order_No__c,Quote_Date__c,Response_Channel__c,Showroom_Request_Type__c,'+
                                                        'Zone__c,reqType__c,pel_campaign_code__c,Virtual_Appointment__c,Branch_Number__c,'+
                                                        'Branch_Number_From_Zone__c,Opportunity_Zone__c,Opportunity_Record_Type_Name__c,Opp_Count_With_Same_Address__c,'+
       '(SELECT Id,OwnerId,AccountId,Street,City,State,PostalCode,Country,Latitude,Longitude,SchedStartTime,SchedEndTime,DurationInMinutes,'+
        'Subject,Branch_Number__c,Email__c,End_Datetime__c,Opportunity_Homeowner_Email__c,Opportunity_No__c,Opportunity_Party_Account_Name__c,Opportunity__c,'+
         'Phone__c,Start_Datetime__c,Opportunity_Address__c,Virtual_Appointment__c FROM Appointments__r),'+
      'owner.firstname,owner.email,owner.id,owner.federationidentifier,'+
      '(SELECT Id,OwnerId,owner.email,owner.firstname,owner.lastname,Name,OpportunityId,QuoteNumber,AccountId,PO_Number__c,Quote_Number_PQM__c'+
        ' FROM Quotes)'+
       ' FROM opportunity WHERE id IN (SELECT opportunity__c FROM serviceappointment WHERE     owner.email = :UserEmail AND SchedStartTime >= :StartDateTime and SchedEndTime <= :EndDateTime ) ';
*/

String userQuery = 'SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier = :UserEmail';
            List<user> users = Database.query(userQuery);
            if (users.size() == 1) {
                UserID = users.get(0).Id;
            }
            
String query = 'SELECT Name, Description, LeadSource,'+
                                                         'Address__c, Appointment_DateTime__c,Appointment_DateTime_Email__c,'+
                                                        'Branch__c,Appointment_Type__c, Email__c, Initial_Appt_Date__c,'+
                                                        'Opportunity_No__c, Number_of_Doors__c, Number_of_Windows__c,'+
                                                        'Phone__c,Quote_Number_Shell__c,Quote_Date__c,Response_Channel__c,Showroom_Request_Type__c,'+
                                                        'reqType__c,pel_campaign_code__c,Virtual_Appointment__c,Branch_Number__c,'+
                                                        'Branch_Number_From_Zone__c,Opportunity_Zone__c,Opportunity_Record_Type_Name__c,'+
       '(SELECT owner.firstname,owner.lastname,owner.email,Status,Street,City,State,PostalCode,Country,Latitude,Longitude,DurationInMinutes,'+
        'Subject,Description,Branch_Number__c,Email__c,End_Datetime__c,Opportunity_Homeowner_Email__c,Opportunity_No__c,Opportunity_Party_Account_Name__c,'+
         'Phone__c,Start_Datetime__c,Opportunity_Address__c,Virtual_Appointment__c FROM Appointments__r),'+
      'owner.firstname,owner.lastname,owner.email,owner.federationidentifier,account.firstname,account.lastname,'+
      '(SELECT QuoteNumber,PO_Number__c,Quote_Number_PQM__c'+
        ' FROM Quotes)'+
       ' FROM opportunity WHERE id IN (SELECT opportunity__c FROM serviceappointment WHERE     owner.id = :UserID AND SchedStartTime >= :StartDateTime and SchedStartTime <= :EndDateTime ) ';
            
            
            List<opportunity> opps = Database.query(query); 
            system.debug(UserEmail);
            system.debug(opps);
            //return (opps);
            res.addHeader('Content-Type', 'application/json');
             res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(opps));
            
           }
        catch(exception e)
        {
 //           new ApexDebugLog().createLog(new ApexDebugLog.Error('ServiceGetApptDetails','doGet',req,JSON.serialize(res),e.getStackTraceString()));
 //           
             res.addHeader('Content-Type', 'application/json');
             res.statusCode = 400;
            // res.responseBody = Blob.valueOf(JSON.serialize(OrgList));;
             //res.response.responseBody = Blob.valueOf(locationJSON);
             system.debug(e.getMessage());
           // return e.getMessage();
           res.responseBody = Blob.valueOf('{"message":"'+e.getMessage()+'"}');
            
        }

    }
}