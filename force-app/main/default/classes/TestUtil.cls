@isTest
public class TestUtil 
{
    // firstname ='testaccount1'
    public static Account createAccount(String recordTypeName, Boolean isInsert)
    {
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Account rec = new Account(FirstName = 'Test Account 1',LastName = 'Test Account', PersonMailingStreet = 'TEst', PersonMailingCity = 'City', PersonMailingCountry = 'US', 
                                  PersonMailingState = 'NY', PersonMailingPostalCode = '12345', RecordTypeId = personAccountRTId, 
                                  PersonEmail = 'test@test.com', PersonMobilePhone = '(666) 666-6666', Is_From_Custom_UI__c=true);
        if(isInsert) insert rec;
        return rec ; 
    } 
    public static Account createBranchAccount(String recordTypeName,Boolean isInsert)
    {
        Id AccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();   
        Account rec = new Account(Name = 'Test BA', Type = 'Architectural / Design Firm',Phone ='(666) 666-6666',
                                  RecordTypeId=AccountRTId, Is_From_Custom_UI__c=true);
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static Contact createContact(String accountId, String lastName, Boolean isInsert)
    {
        Contact rec = new Contact(AccountId = accountId, LastName = lastName);
        if(isInsert) insert rec ;
        return rec ; 
    }
    
  
    public static void createTerritory2()
    {
        list<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Branch'];
        Territory2Model trrmodel = new Territory2Model();
        trrmodel.DeveloperName = 'Branch';
        trrmodel.Name = 'Test';
        insert trrmodel;
        
        Territory2 trr =  new Territory2();
        trr.Territory_Reference_Number__c = '100';       
        trr.Territory2ModelId = trrmodel.Id;
        trr.DeveloperName = 'Test';
        trr.Name = 'Test';
        trr.Territory2TypeId = terriType[0].Id;
        insert trr;        
    }
    public static Branch_Grouping__c createBranchGrouping(String branchFamilyName, Boolean isInsert)
    {
        Branch_Grouping__c rec = new Branch_Grouping__c(Name = branchFamilyName, Grouping_Type__c = 'Branch Family',Pella_Account_Owner__c=userinfo.getUserId());
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static Branch__c createBranch(String branchName, String branchNumber, String branchFamilyId, Boolean isInsert)
    {
        Branch__c rec = new Branch__c(Branch_Number__c = branchNumber, Name = branchName, Branch_Family__c = branchFamilyId );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static Account_Branch_Profile__c createAccountBranchProfile(String accountId, String branchId, Boolean isInsert)
    {
        Account_Branch_Profile__c rec = new Account_Branch_Profile__c(Party_Account__c = accountId, Branch__c = branchId);
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static Address_Assignment__c createAddressAssignment(String addressId, String accountBranchProfileId, Boolean isInsert)
    {
        Address_Assignment__c rec = new Address_Assignment__c(Address__c = addressId , Account_Branch_Profile__c = accountBranchProfileId);
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static TimeSlot createTimeSlot(String opreatingHoursId, Boolean isInsert)
    {
        TimeSlot rec = new TimeSlot(OperatingHoursId = opreatingHoursId , StartTime = Time.newInstance(12, 00, 0, 0), EndTime = Time.newInstance(18, 00, 0, 0));
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static OperatingHours createOpreatingHours(String name, Boolean isInsert)
    {
        OperatingHours rec = new OperatingHours(Name = name);
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static ServiceTerritory createParentServiceTerritory(String name, String opreatingHoursId, String branchId, Boolean isInsert)
    {
        Id parentRTId = Schema.SObjectType.ServiceTerritory.recordTypeInfosByDeveloperName.get('Parent_Territory').RecordTypeId;
        ServiceTerritory rec = new ServiceTerritory(Name = name, RecordTypeId = parentRTId, IsActive = True, Branch__c =branchId,
                                                    OperatingHoursId = opreatingHoursId,  Territory_Type__c = 'Replacement',
                                                    PostalCode = '12354', Street = 'TEst', City = 'Test', State = 'NY', Country = 'US' );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static ServiceTerritory createChildServiceTerritory(String name, String parentSTId, String opreatingHoursId, Boolean isInsert)
    {
        Id chidlRTId = Schema.SObjectType.ServiceTerritory.recordTypeInfosByDeveloperName.get('RT_Zone').RecordTypeId;
        ServiceTerritory rec = new ServiceTerritory(Name= name, RecordTypeId = chidlRTId, IsActive = True, ParentTerritoryId = parentSTId,
                                                    ApptDurationMin__c = 120, Weeks_Shown_Web__c = '3', Web_Hrs_Roll__c = 24, 
                                                    OperatingHoursId = opreatingHoursId, PostalCode = '45682', Street = 'TEst', Lead_Receiver__c = UserInfo.getUserId(),
                                                    City = 'Test', State = 'NY', Country = '');
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static ServiceTerritory createSubChildServiceTerritory(String name, String childSTId, String opreatingHoursId, Boolean isInsert)
    {
        Id subChildRTId = Schema.SObjectType.ServiceTerritory.recordTypeInfosByDeveloperName.get('Zone_Zipcode').RecordTypeId;
        ServiceTerritory rec = new ServiceTerritory(Name=name, RecordTypeId = subChildRTId, IsActive = True, ParentTerritoryId = childSTId,
                                                    ApptDurationMin__c = 120, Weeks_Shown_Web__c = '3', Web_Hrs_Roll__c = 24, 
                                                    OperatingHoursId = opreatingHoursId, PostalCode = '37335', Street = 'TEst', 
                                                    City = 'Test', State = 'NY', Country = 'US');
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static ServiceResource createServiceResource(String name, String relatedRecordId, String branchId, String branchFamilyId, Boolean isInsert)
    {
        ServiceResource rec = new ServiceResource(  Name = name, RelatedRecordId = relatedRecordId, IsActive = True,In_home_Eligible__c=true,Virtual_Eligible__c=true, 
                                                  Daily_Max_Appts__c = 2, Weekly_Max_Appts__c = 16, Maximum_Windows__c = 10, 
                                                  Oldest_Year_Built__c = '1985', Ranker__c = 1, Primary_Branch_Family__c = branchFamilyId );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static ServiceTerritoryMember createServiceTerritoryMember(String serviceResourceId, String territoryId, Boolean isInsert)
    {
        ServiceTerritoryMember rec = new ServiceTerritoryMember(ServiceResourceId = serviceResourceId, ServiceTerritoryId = territoryId, 
                                                                EffectiveStartDate = Datetime.now().addDays(-5), 
                                                                EffectiveEndDate = Datetime.now().addDays(10) );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static ServiceTerritoryMember createServiceTerritoryMember1(String serviceResourceId, String territoryId, Boolean isInsert)
    {
        ServiceTerritoryMember rec = new ServiceTerritoryMember(ServiceResourceId = serviceResourceId, ServiceTerritoryId = territoryId, 
                                                                EffectiveStartDate = Datetime.now().addDays(-4), territorytype = 'S',
                                                                EffectiveEndDate = Datetime.now().addDays(10) );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static ServiceTerritoryMember createServiceTerritoryMember2(String serviceResourceId, String territoryId, Boolean isInsert)
    {
        ServiceTerritoryMember rec = new ServiceTerritoryMember(ServiceResourceId = serviceResourceId, ServiceTerritoryId = territoryId, 
                                                                EffectiveStartDate = Datetime.now().addDays(-3), territorytype = 'S',
                                                                EffectiveEndDate = Datetime.now().addDays(10) );
        if(isInsert) insert rec ;
        return rec ; 
    }
    public static ServiceAppointment createServiceAppointment(String recordTypeDevName, String subject, String accountId, String oppId, String parentRecordId, Boolean isInsert)
    {
        Id softAssignId = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get(recordTypeDevName).RecordTypeId;
        ServiceAppointment rec = new ServiceAppointment(RecordTypeId = softAssignId, Subject = subject, 
                                                        ContactId = [SELECT PersonContactId FROM Account WHERE ID = :accountId].PersonContactId ,
                                                        Description = 'Test', Opportunity__c = oppId, ParentRecordId = parentRecordId,
                                                        SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addDays(1),
                                                        EarliestStartTime = Datetime.now(), DueDate = Datetime.now().addDays(1),
                                                        Status = 'None'  );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static Lead createLead(String firstName, String lastName, Boolean isInsert)
    {
        //added HomePhone__c,MobilePhone__c,AsstPhone__c
        Lead rec = new Lead(FirstName=firstName, LastName=lastName, Company='Test', LeadSource='Web', Status='Inquiry',HomePhone__c='1234567891',MobilePhone__c='1234567899',AsstPhone__c='1244567891');
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    //add status__c
    public static Opportunity createOpportunity(String name, String accountId, String ownerId, Boolean isInsert)
    {
        String replacementRecID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Replacement').getRecordTypeId();
        Opportunity rec = new Opportunity(Name=name,StageName='New',Amount=10,CloseDate=system.today() + 30,AccountId=accountId, OwnerId = ownerId,Status__c='New' );
        rec.RecordTypeId = replacementRecID; 
        if(isInsert) insert rec ;
        return rec ; 
    }
    //add status__c
    public static Order createOrder(String name, String accountId,Boolean isInsert)
    {
        Order rec = new Order(Name=name,Status='Draft',AccountId=accountId,effectiveDate=date.today() );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static Address__c createAddress(Boolean isInsert)
    {
        Address__c rec = new Address__c(Street__c = 'Address', City__c ='City', State__c ='NY', Zipcode__c ='12345', Country__c='US' );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static User createUser(Boolean isInsert)
    {
        User rec = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()),
                            LastName = 'Test', Email = 'test' + System.currentTimeMillis() + '@test23232323.com', Username = 'test2344@test3434.com' + System.currentTimeMillis(),
                            CompanyName = 'TEST', Title = 'Retail Sales Rep', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US'  );
        if(isInsert) insert rec ;
        return rec ; 
    }
    
    public static Apex_Debug_Log__c createApexDebugLog(Boolean isInsert)
    {
        Apex_Debug_Log__c deb = new Apex_Debug_Log__c();
        if(isInsert) insert deb ;
        return deb ; 
    }
    
    public static Communication__c createCommunication(Boolean isInsert)
    {
        Communication__c com = new Communication__c(Active__c = true, Type__c = 'Follow-Up',Name = '1on1');
        if(isInsert) insert com ;
        return com ; 
    }
    
    public static ResourceAbsence createResourceAbsence(String ResourceId, Boolean isInsert)
    {
        ResourceAbsence ra = new ResourceAbsence(ResourceId = ResourceId, Type = 'Training',Start = DateTime.now(), End = DateTime.now().addHours(24));
        if(isInsert) insert ra ;
        return ra ; 
    }
    public static AssignedResource createAssignedResource(String ServiceResourceId, String ServiceAppointmentId, Boolean isInsert)
    {
        AssignedResource ar = new AssignedResource(ServiceResourceId = ServiceResourceId, ServiceAppointmentId = ServiceAppointmentId);
        if(isInsert) insert ar ;
        return ar ; 
    }
    
    public static Quote createQuote(String OpportunityId, Boolean isInsert)
    {
        Quote qt = new Quote(OpportunityId = OpportunityId, Name = 'Test Quote');
        if(isInsert) insert qt ;
        return qt ; 
    }
    public static QuoteLineItem createQuoteLineItem(String QuoteId, String WorkLineId,String priceBookEntryId,String ProductID, Boolean isInsert ){
        QuoteLineItem qtLItem =  new QuoteLineItem(QuoteId = QuoteId, Work_Order_Line_Item__c =  WorkLineId, Product2Id = ProductID, PricebookEntryId = priceBookEntryId);
        if(isInsert) insert qtLItem ;
        return qtLItem ;
    }
  
    public static BAC_History__c createBACHistory(String queueId,decimal price,String BACtype, Boolean isInsert)
    {
        BAC_History__c BACH = new BAC_History__c(Quote__C = queueId,Price__c=price,Type__c=BACtype);
        if(isInsert) insert BACH ;
        return BACH ; 
    }
    
    
    public static Communication_Component__c createCommunicationComponent(String CommunicationId, Boolean isInsert)
    {
        Communication_Component__c comcop = new Communication_Component__c(Communication__c = CommunicationId, Channel__c = 'Email', Order__c = '1', Frequency__c = 'Scheduled' ,Deployment_Run_After__c = '1');
        if(isInsert) insert comcop ;
        return comcop ; 
    }
    
    public static RTAIntegrationConfig__c createRTAIntegrationConfig(DateTime LastExecutionTime, Boolean isInsert)
    {
        RTAIntegrationConfig__c rtaConfig = new RTAIntegrationConfig__c(Last_Execution_Time__c = LastExecutionTime);
        if(isInsert) insert rtaConfig ;
        return rtaConfig;
    }
    public static PQMIntegrationConfig__c createPQMIntegrationConfig(DateTime LastExecutionTime, Boolean isInsert)
    {
        PQMIntegrationConfig__c pqmConfig = new PQMIntegrationConfig__c(Last_Execution_Time__c = LastExecutionTime);
        if(isInsert) insert pqmConfig ;
        return pqmConfig;
    }
    
    
    public static Event createEvent(String OwnerId,  Boolean isInsert)
    {
        Event ev = new Event(Event_Type__c = 'Rehash',Type='Busy', StartDateTime = Datetime.now().addDays(-5), EndDateTime = Datetime.now().addDays(5),OwnerId = OwnerId, Location = 'Parent Territory');
        if(isInsert) insert ev ;
        return ev;
    }
    
    
    public static Campaign createCampaign(String campName,String branchId,  Boolean isInsert)
    {
        Campaign camp = new Campaign(Name=campName,Status = 'Active' , Type = 'Branch' , Branch_Name__c = branchId, IsActive = TRUE );
        if(isInsert) insert camp ;
        return camp;
    }
    
    public static RTA_Timeblock__c createRTATimeBlock(String postalCode,  Boolean isInsert)
    {
        RTA_Timeblock__c camp = new RTA_Timeblock__c(StartDate__c=DateTime.now(),EndDate__c=DateTime.now().addHours(1),zipcode__c=postalCode);
        if(isInsert) insert camp ;
        return camp;
    }
    
    public static WK52Report__c createWK52Report(String reportType,String BranchNumber,String uniqueKey,Boolean isInsert)
    {
        String reportData='[{"ToPy":-0.105,"reportLabel":"Gross Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":104,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":93},{"ToPy":-0.17,"reportLabel":"AOR Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":94,"markGreen":false,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":false,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":78},{"ToPy":0,"reportLabel":"Branch Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":0,"markGreen":false,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":false,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":0},{"ToPy":0.5,"reportLabel":"Self Gen Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":10,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":15},{"ToPy":0.2,"reportLabel":"New Prospects Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":5,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":6},{"ToPy":-0.363,"reportLabel":"Canceled Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":11,"markGreen":false,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":false,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":7},{"ToPy":-0.125,"reportLabel":"Transferred Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":8,"markGreen":false,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":false,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":7},{"ToPy":-0.11,"reportLabel":"Transfer/Can Opps","priorYearDataTotal":null,"priorYearData":null,"priorYear":0.18,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":true,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":0.16},{"ToPy":-0.42,"reportLabel":"ALT","priorYearDataTotal":null,"priorYearData":null,"priorYear":5.62,"markGreen":false,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":false,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":3.23},{"ToPy":-0.56,"reportLabel":"Appointment to Book","priorYearDataTotal":null,"priorYearData":null,"priorYear":28.94736842105263,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":12.72},{"ToPy":-0.058,"reportLabel":"Contracted","priorYearDataTotal":null,"priorYearData":null,"priorYear":34,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":32},{"ToPy":-0.19,"reportLabel":"$Contracted","priorYearDataTotal":null,"priorYearData":null,"priorYear":338280.39,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":271637.62},{"ToPy":-0.12,"reportLabel":"Branch Bookings","priorYearDataTotal":null,"priorYearData":null,"priorYear":285994.04,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":250331.82},{"ToPy":-0.28,"reportLabel":"BAC Bookings","priorYearDataTotal":null,"priorYearData":null,"priorYear":87187.02,"markGreen":false,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":false,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":62738.19},{"ToPy":0,"reportLabel":"BAC Shipments","priorYearDataTotal":null,"priorYearData":null,"priorYear":0,"markGreen":false,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":false,"IsPYCurrency":null,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":0},{"ToPy":-0.44,"reportLabel":"R90 Gross Close Ratio","priorYearDataTotal":null,"priorYearData":null,"priorYear":0.37,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":true,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":0.21},{"ToPy":0.23,"reportLabel":"R90 Gross Yield","priorYearDataTotal":null,"priorYearData":null,"priorYear":1406.528,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":true,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":1730.571},{"ToPy":1.368,"reportLabel":"R90 Average Job Size","priorYearDataTotal":null,"priorYearData":null,"priorYear":3705.002,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":true,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":8776.47},{"ToPy":0,"reportLabel":"R90 FCC %","priorYearDataTotal":null,"priorYearData":null,"priorYear":0,"markGreen":null,"IsVisibleToPy":false,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":true,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":0},{"ToPy":0.089,"reportLabel":"R12 Gross Close Ratio","priorYearDataTotal":null,"priorYearData":null,"priorYear":0.31,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":null,"IsPercentage":true,"IsCurrency":null,"actualYearDataTotal":null,"actualYearData":null,"actualYear":0.34},{"ToPy":-0.006,"reportLabel":"R12 Gross Yield","priorYearDataTotal":null,"priorYearData":null,"priorYear":3200.78,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":true,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":3180.74},{"ToPy":-0.081,"reportLabel":"R12 Average Job Size","priorYearDataTotal":null,"priorYearData":null,"priorYear":10232.42,"markGreen":false,"IsVisibleToPy":true,"IsVisiblepriorYear":false,"IsVisibleactualYear":true,"IsPYCurrency":true,"IsPercentage":false,"IsCurrency":true,"actualYearDataTotal":null,"actualYearData":null,"actualYear":9386.12}]';
        WK52Report__c report = new WK52Report__c(Branch__c=BranchNumber, Report_Type__c=reportType, Reports__c=reportData, SBM__c='test', Unique_Key__c=uniqueKey, Branch_Number__c =BranchNumber );
        if(isInsert) insert report ;
        return report;
    }
    
    
    public static OpportunityCommunication__c createOpportunityCommunication(String contactId,String oppId,String commId,String comcopId,  Boolean isInsert)
    {
        OpportunityCommunication__c oppCom = new OpportunityCommunication__c(
            Contact__c = contactId,
            Opportunity__c = oppId,
            Communication__c = commId,
            Is_Executed__c = false,
            Execution_Time__c = DateTime.now().addDays(-1),
            Communication_Component__c = comcopId);
        if(isInsert) insert oppCom ;
        return oppCom;
    }
    
    public static Pricebook2 createPricebook2(Boolean isInsert)
    {
        Pricebook2 pb = new Pricebook2(IsActive=true,name='pb1');
        if(isInsert) insert pb ;
        return pb;
    }
     public static Product2 createProduct(Boolean isInsert)
    {
        Product2 p = new Product2(IsActive=true,name='p1');
        if(isInsert) insert p ;
        return p;
    }
    
    public static PriceBookEntry createPriceBookEntry(string pricebookID, string productId, Boolean isInsert)
    {
        PricebookEntry pbe = new PricebookEntry(pricebook2id=pricebookID, product2id=productId,unitprice=1.0, isActive=true);
        if(isInsert) insert pbe ;
        return pbe;
    }
   /* public static Mogli_SMS__SMS_Template__c createMogliTemplate(string smsTempName,string smsTempText, Boolean isInsert)
    {
        Mogli_SMS__SMS_Template__c smsTemplate = new Mogli_SMS__SMS_Template__c(Mogli_SMS__Text__c=smsTempText,Mogli_SMS__Name__c=smsTempName);
        if(isInsert) insert smsTemplate ;
        return smsTemplate;
    }
    public static Mogli_SMS__SMS__c createMogliSMS(string direction,string GatewayId,String Message,String contactId,String status, Boolean isInsert)
    {
        
        Mogli_SMS__SMS__c sms = new Mogli_SMS__SMS__c(Mogli_SMS__Direction__c=direction,Mogli_SMS__Gateway__c=GatewayId,
                                                      Mogli_SMS__Message__c=Message,Mogli_SMS__Contact__c=contactId,Mogli_SMS__Status__c=status);
        if(isInsert) insert sms ;
        return sms;
    }*/
    
    public static UserTerritory2Association createUserTerritory2Association(string Uid,string terrritoryId, Boolean isInsert)
    {
        UserTerritory2Association UTA2 = new UserTerritory2Association(UserId =Uid,RoleInTerritory2='Regional Business Manager',Territory2Id=terrritoryId);
        if(isInsert) insert UTA2 ;
        return UTA2;
    }
    
    public static Id getTerritoryTypeId (string developerName)
    {
        List<Territory2Type> types= [Select Id, DeveloperName from Territory2Type Where DeveloperName = :developerName];
        if(types.size()>0){
            return types[0].Id;
        }       
        return null;
    } 
    
    
    public static Territory2 createTerritory2 (string BranchNumber, Id activetypeId, Boolean isInsert )
    {
        List<Territory2Model> models = [Select Id from Territory2Model where State = 'Active'];
        Id activeModelId = null;
        if(models.size() == 1){
            activeModelId = models.get(0).Id;
        } 
        system.debug('test: '+activeModelId);
        
        Territory2 T2= new Territory2(Territory_Reference_Number__c=BranchNumber,Territory2ModelId=activeModelId ,Name='test',DeveloperName='Replacement',Territory2TypeId=activetypeId );
        if(isInsert) insert T2;
        return T2;
    }  
    
    public static WorkOrder createWorkOrder(string subject,string workTypeId,string branch,string accountId,string quote, Boolean isInsert){
        String installOvId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('OV_Install').getRecordTypeId();
        WorkOrder wo = new WorkOrder(recordtypeId=installOvId,subject=subject,WorkTypeId=workTypeId,	Branch__c=branch,AccountId=accountId,Quote__c=quote);
        if(isInsert) insert wo;
        return wo;
    }
    
    public static WorkType createWorkType(string name,string scheduleType,string durationType,integer estimatedDuration, Boolean isInsert){
        WorkType wt = new WorkType(Name=name,Schedule_Type__c=scheduleType,DurationType=durationType,EstimatedDuration=estimatedDuration);
        if(isInsert) insert wt;
        return wt;
    }

    public static Case createCase(string conId, string accId, string branchId, Boolean isInsert, String status, String origin, String subject){
        Case caseObj       = new Case();
        caseObj.Status     = status;
        caseObj.Origin     = origin;
        caseObj.Subject = subject;
        caseObj.ContactId  = conId;
        caseObj.AccountId  = accId;
        caseObj.AssignedBranch__c = branchId;
        if(isInsert) insert caseObj;
        return caseObj;
    }
    
    public static WorkOrderLineItem createWorkOrderLineItem(string subject,string workType,string workOrder,Boolean isInsert){
        WorkOrderLineItem woli = new WorkOrderLineItem(Subject=subject,WorkTypeId=workType,WorkOrderId=workOrder);
        if(isInsert) insert woli;
        return woli;
    }
    
    public static Installer_Payout_Amount__c createInstallerPayoutAmount(string workOrderLineItem,Boolean isInsert){
        Installer_Payout_Amount__c ipa = new Installer_Payout_Amount__c(Work_Order_Line_Item__c=workOrderLineItem);
        if(isInsert) insert ipa;
        return ipa;
    }
     public static Installer_Payout__c createInstallerPayout(string branch,Boolean isInsert){
        Installer_Payout__c ip = new Installer_Payout__c(Branch__c=branch);
        if(isInsert) insert ip;
        return ip;
    }
    
    public static ServiceTerritory createPIESServiceTerritroy(String name, string branchId, string ohId, String type, Boolean isInsert){
        String installOvId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('OV_Install_Territory').getRecordTypeId(); 
        ServiceTerritory st = new ServiceTerritory(Name=name, Branch__c=branchId, OperatingHoursId=ohId, Type__c=type, recordtypeId=installOvId );
        if(isInsert) insert st;
        return st;
    }
    public static ServiceTerritory createPIESZCServiceTerritroy(String name, string zipcode, String ParentSTId, string ohid, Boolean isInsert){
        String installOvId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('Zone_Zipcode').getRecordTypeId(); 
        ServiceTerritory st = new ServiceTerritory(Name=name, postalcode=zipcode,ParentTerritoryId=ParentSTId, OperatingHoursId=ohId, recordtypeId=installOvId );
        if(isInsert) insert st;
        return st;
    }
    
    public static Territory_Zipcode__c createTZforPIES(String stId, string zipcode, Boolean isInsert){
        Territory_Zipcode__c tz = new Territory_Zipcode__c(Territory__c=stId, ZipCode__c=zipcode);
        if(isInsert) insert tz;
        return tz;
    }
    
    public static User createPIESUser(String prid, String cid, Boolean isInsert)
    {
        User rec = new User(ProfileId=prId, FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()),
                            LastName = 'Test', Email = 'test' + System.currentTimeMillis() + '@test23232323.com', Username = 'test2344@test3434.com' + System.currentTimeMillis(),
                            CompanyName = 'TEST', Title = 'Retail Sales Rep', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ContactId = cid  );
        if(isInsert) insert rec ;
        return rec ; 
    }
     public static ServiceAppointment createPIESServiceAppointment(String recordTypeDevName, String subject, String accountId, String parentRecordId, Boolean isInsert)
    {
        Id RTId = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get(recordTypeDevName).RecordTypeId;
        ServiceAppointment rec = new ServiceAppointment(RecordTypeId = RTId, Subject = subject, 
                                                        Description = 'Test PIES', ParentRecordId = parentRecordId );
        if(isInsert) insert rec ;
        return rec ; 
    }
     public static User createPIESUser2(Boolean isInsert)
    {
        User rec = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Pella System Administrator'].Id, FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()),
                            LastName = 'Test LN', Email = 'test' + System.currentTimeMillis() + '@test23232323.com', Username = 'test2344@test3434.com' + System.currentTimeMillis(),
                            CompanyName = 'TEST', Title = 'Retail Sales Rep', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US'  );
        if(isInsert) insert rec ;
        return rec ; 
    }
    public static ServiceResource createPIESServiceResource(String name, String relatedRecordId,String branchFamilyId, Boolean isInsert)
    {
        ServiceResource rec = new ServiceResource(  Name = name, RelatedRecordId = relatedRecordId, IsActive = True,
                                                    Primary_Branch_Family__c = branchFamilyId );
        if(isInsert) insert rec ;
        return rec ; 
    }
    public static Question_Template__c createQuestion_Template(Boolean isInsert)
    {
        Question_Template__c qt = new Question_Template__c(isFirstQuestion__c=true,isLastQuestion__c=true, Name='test QT', Message_Text__c = 'Need Holiday');
        if(isInsert) insert qt ;
        return qt;
    }
   
    public static Branch_Question_Junction__c createBranch_Question_Junction(Boolean isInsert, string Question_Templates, string Branch,Decimal Order)
    {
        Branch_Question_Junction__c bqj = new Branch_Question_Junction__c(Branch__c=Branch ,Question_Templates__c = Question_Templates, Order__c=Order);
        if(isInsert) insert bqj ;
        return bqj;
    }

    private static User createSalesRep (string profileName, string userTitle, string firstName, string lastName) {
        User rep = new User(ProfileId=[SELECT Id FROM Profile WHERE Name =: profileName].Id, FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()),
        FirstName = firstName, LastName = lastName, Email = 'test' + System.currentTimeMillis() + '@test1234.com', Username = 'test_sales_rep'+ System.currentTimeMillis() + '@test1234.com',
        CompanyName = 'TEST', Title = userTitle, Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', Trade_Branch_Number__c='100');

        insert rep;

        return rep;
    }
    public static User createSalesRep (string profileName, string userTitle, string firstName, string lastName, boolean isInsert) {
        User rep = new User(ProfileId=[SELECT Id FROM Profile WHERE Name =: profileName].Id, FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()),
                            FirstName = firstName, LastName = lastName, Email = 'test' + System.currentTimeMillis() + '@test1234.com', Username = 'test_sales_rep'+ System.currentTimeMillis() + '@test1234.com',
                            CompanyName = 'TEST', Title = userTitle, Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', Trade_Branch_Number__c='100');
        
        if(isInsert) insert rep ;
        
        return rep;
    }
    public static TwilioMessage__c createTwilioMessage ( String topic,String direction,String message,String phone,boolean isInsert) {
        TwilioMessage__c TW=new TwilioMessage__c(Topic__c = topic,Direction__c=direction,MessageBody__c=message,Phone__c=Phone); 
        if(isInsert) insert TW ;
        
        return TW;
    }
    
    public static User createReplacementSalesRep () {
        return createSalesRep('Replacement Sales', 'Replacement Sales Rep', 'test_trade_comm', 'sales_rep');
    }
    
    public static User createTradeCommSalesRep () {
        return createSalesRep('Trade_Comm Sales', 'Trade New Construction Sales Rep', 'test_trade_comm', 'sales_rep');
    }

    @future
    public static void insertUser(string con, string con2){
        User u1 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'PIES Manager Contractor'].Id, FederationIdentifier = 'Test' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()),
                          LastName = 'Test', Email = 'test' + System.currentTimeMillis() + '@test23232323.com', Username = 'test2344@test3434.com' + System.currentTimeMillis(),
                          CompanyName = 'TEST', Title = 'Retail Sales Rep', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ContactId = con);
        insert u1 ;
        
        User u2 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'PIES Manager Contractor'].Id, FederationIdentifier = 'Test1' + System.currentTimeMillis() + '12' + String.valueOf(Datetime.now()),
                           LastName = 'Test1', Email = 'test1' + System.currentTimeMillis() + '@test23232323.com', Username = 'test12344@test3434.com' + System.currentTimeMillis(),
                           CompanyName = 'TEST', Title = 'Retail Sales Rep', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
                           LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ContactId = con2);
        insert u2;
    }
}