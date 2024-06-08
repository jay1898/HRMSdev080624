/**
*   @Purpose:       Trigger handler class behind Lead trigger 
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
public without sharing class LeadTriggerHandler 
{
    /**
*   @Method:        populateZone
*   @Purpose:       Populate Zone__c lookup with matching Zipcode zone
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          01/04/2020
*   @TaskSource:    

*   @Updates:       
*/
    public static Boolean RUN_UPDATE_CAMPAIGN = true ;
    
    public static void populateZone(List<Lead> leads) 
    {
        Set<String> zipcodes = new Set<String>();
        Map<String,Id> zipCodeToZoneId = new Map<String,Id>();
        
        // Iterate over leads
        for(Lead ld : leads)
        {
            if(String.isBlank(ld.Zone__c) && String.isNotBlank(ld.PostalCode)) zipcodes.add(ld.PostalCode);
        }
        System.debug('UAC: zipcodes ' + zipcodes );
        
        // Go back when no postalcode found 
        if(zipcodes.size() == 0) return ;
        
        // Get related zipcode Service Territory 
        for(ServiceTerritory st : [SELECT ParentTerritoryId, PostalCode FROM ServiceTerritory WHERE PostalCode IN :zipcodes AND RecordType.Name='Zipcode'])
        {
            zipCodeToZoneId.put(st.PostalCode, st.ParentTerritoryId);
        }
        System.debug('UAC: zipCodeToZoneId ' + zipCodeToZoneId );
        
        // When no Territory found then go back 
        if(zipCodeToZoneId.size() == 0) return ;
        
        // Iterate again and update Zone lookup 
        for(Lead ld : leads)    
        {
            if(String.isBlank(ld.Zone__c) && String.isNotBlank(ld.PostalCode) && zipCodeToZoneId.containsKey(ld.PostalCode)) ld.Zone__c = zipCodeToZoneId.get(ld.PostalCode);
        }
        
    }
    
    public static void leadRecordShare(List<Lead> leads, Map<Id,Lead> oldMap){
        
        List<Id> leadIdstoShare = new List<Id>();
        List<Id> removeleadIdstoShare = new List<Id>();
        Id leadRecordTypePLId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pro_Lowes').getRecordTypeId();
        for(Lead lead : leads)
        {
            // When new record created or owner Id change 
            if((oldMap==null 
               || (lead.ownerId != oldMap.get(lead.Id).ownerId )
               || (lead.Zone__c != oldMap.get(lead.Id).Zone__c ) ) && lead.RecordTypeId != leadRecordTypePLId) 
            {
                leadIdstoShare.add(lead.Id);
            }
            if(oldMap!=null && (lead.Zone__c != oldMap.get(lead.Id).Zone__c ))
            {
                removeLeadIdstoShare.add(lead.Id);
            }
        } 
        if(removeLeadIdstoShare.size()>0)
            LeadRecordShare.removeShareLeadWithETM(removeLeadIdstoShare);
        if(leadIdstoShare.size()>0){
            LeadRecordShare.shareLeadRecordWithETMGroup(leadIdstoShare);
        }   
        
    }
    
    /**
*   @@Method:   eloquaLeadAssignment
*   @Date       Author                      Version Purpose     
*   10/01/2020  Pallavi Patil(eVerge)       Draft   Populate Owner based on Campaing/Zipcode/Lead Type/Business Segment
*   04/07/2021  Satheesh Bojanapu(eVerge)   1.0     Added logic to auto assign leads to National Accounts owners Based on Business Segment  
*/
    public static void eloquaLeadAssignment (List<Lead> leads, Map<Id,Lead> oldMap){
        
        try{
            Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
            //(v1.0) get recordTypeId of 'Lowes'
            Id leadRecordTypePLId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pro_Lowes').getRecordTypeId();
            Id zipcodeRecordTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();
            Map<Id, Lead> mapLd = new Map<Id, Lead>();
            Map<Id, String> mapZipcode = new Map<Id, String>();
            Map<Id, Id> mapLdCamp = new Map<Id, Id>();
            String csgQueue ;
            //get the queue Id
            List<QueueSobject> queueId = [SELECT Id, QueueId, Queue.Name FROM QueueSobject];
            for(QueueSobject que : queueId){
                if(que.Queue.Name == 'CSG'){csgQueue = que.QueueId;}
            }
            //Process only TC leads coming from Eloqua
            for(Lead ld : leads ){
                if(ld.RecordTypeId == leadRecordTypeId && ld.Originating_System__c == 'Eloqua'){
                    mapLd.put(ld.Id, ld);
                    mapZipcode.put(ld.Id, ld.PostalCode) ;
                    mapLdCamp.put(ld.Id, ld.Campaign__c);
                }
                //(v1.0) Process only Pro_Lowes leads
                else if(ld.RecordTypeId == leadRecordTypePLId && ld.Originating_System__c == 'Eloqua'){
                    mapLd.put(ld.Id, ld);
                    mapZipcode.put(ld.Id, ld.PostalCode) ;
                    mapLdCamp.put(ld.Id, ld.Campaign__c);
                }
            }
            system.debug('Line 93 : ' + mapZipcode);
            //get the campaigns for above processed leads
            Map <Id, String> mapCampName = new Map<Id, String>();
            List<Campaign> listCamp = [SELECT Id, Name FROM Campaign where Id IN :mapLdCamp.values()];
            for(Campaign c: listCamp){
                mapCampName.put(c.Id,c.Name);
            }   
            
            //get the T/C/PCC Lead Receiver based on the zipcode from the lead.
            //(v1.0) added store account owner in selection criteria
            List<ServiceTerritory> listSt = [SELECT Id, PostalCode,Comm_Lead_Receiver__c, Trade_Lead_Receiver__c, 
                                             PCC_Lead_Receiver__c, Store_Account_Owner__c , 
                                             Store_Account__c, Store_Account__r.store_number__C, Pro_Dealer_Store_Account__c, Pro_Dealer_Store_Owner__c 
                                             FROM ServiceTerritory 
                                             WHERE Name IN : mapZipcode.values() AND RecordTypeId =:zipcodeRecordTypeId ];
            List<Branch__C>luxuryBranch = [Select Trade_Lead_Receiver__c from Branch__C where name = 'Luxury']; 
            Map<String, ServiceTerritory> mapSTZC = new Map<String, ServiceTerritory>(); 
            
            for(ServiceTerritory ST : listSt){
                mapSTZC.put(ST.PostalCode,ST);
            }
            //Set the owner on Leads based on campaing name/Zipcode/Lead Type
            for(Lead sLd : mapLd.values()){
                //Assign to CSG Queue
                if(mapCampName.containsKey(sLd.Campaign__c) && mapCampName.get(sLd.Campaign__c) == 'Pella.com – Get A Quote' && 
                   (sLd.Business_Segment__c == 'Trade' || sLd.Business_Segment__c == 'Commercial')){
                       // Added condition to resolve owner id not blank 27-10
                       if(csgQueue!=null){
                           sLd.OwnerId = csgQueue ;
                       }
                   }
                //Assign to PCC Lead Receiver
                else if(mapCampName.containsKey(sLd.Campaign__c) && mapCampName.get(sLd.Campaign__c) == 'PCC Program Request' &&
                        (sLd.Business_Segment__c == 'Trade' || sLd.Business_Segment__c == 'Commercial')){
                            if(mapSTZC.containskey(sLd.PostalCode) &&  mapSTZC.get(sLd.PostalCode).PCC_Lead_Receiver__c != null){
                                sLd.OwnerId = mapSTZC.get(sLd.PostalCode).PCC_Lead_Receiver__c ;
                            }
                        }
                //Assign to Trade Lead Receiver
                else if((sLd.Lead_Type__c == 'RESBUILDER' || sLd.Lead_Type__c == 'Replacement Contractor' || sLd.Lead_Type__c == 'Homeowner with Contractor' 
                         || sLd.Lead_Type__c == 'Remodeling Contractor' || sLd.Lead_Type__c == 'Homeowner'|| sLd.Lead_Type__c == 'Other') && sLd.Business_Segment__c == 'Trade' ){
                             if(mapSTZC.containskey(sLd.PostalCode) &&  mapSTZC.get(sLd.PostalCode).Trade_Lead_Receiver__c != null){
                                 sLd.OwnerId = mapSTZC.get(sLd.PostalCode).Trade_Lead_Receiver__c ;
                             }
                         }
                //Assign to Trade for Design Works
                if(mapCampName.containsKey(sLd.Campaign__c) && mapCampName.get(sLd.Campaign__c) == 'pella.com/ideas/design/pella-design-works' && 
                   (sLd.Business_Segment__c == 'Trade')){
                       // Added condition to resolve owner id not blank 27-10
                       if(mapSTZC.containskey(sLd.PostalCode) &&  mapSTZC.get(sLd.PostalCode).Trade_Lead_Receiver__c != null){
                                 sLd.OwnerId = mapSTZC.get(sLd.PostalCode).Trade_Lead_Receiver__c ;
                       }
                   }

                //Assign to Commercial Lead Receiver
                else if((sLd.Lead_Type__c == 'Commercial Architect/Design' || sLd.Lead_Type__c == 'Commercial Builder/GC' 
                         || sLd.Lead_Type__c == 'Residential Architect/Design' || sLd.Lead_Type__c == 'Commercial Building Owner') && sLd.Business_Segment__c == 'Commercial'){
                             if(mapSTZC.containskey(sLd.PostalCode) &&  mapSTZC.get(sLd.PostalCode).Comm_Lead_Receiver__c != null){
                                 sLd.OwnerId = mapSTZC.get(sLd.PostalCode).Comm_Lead_Receiver__c ;
                             }
                         }
                //(v1.0) Assign to Store Account Owner
                else if((sLd.Business_Segment__c == 'Lowes')
                        && (mapCampName.containsKey(sLd.Campaign__c) && mapCampName.get(sLd.Campaign__c) == 'PellatLowes.com')){
                            if(mapSTZC.containskey(sLd.PostalCode) &&  mapSTZC.get(sLd.PostalCode).Store_Account_Owner__c != null){
                                sLd.OwnerId = mapSTZC.get(sLd.PostalCode).Store_Account_Owner__c;
                                sLd.Store_Account__c = mapSTZC.get(sLd.PostalCode).Store_Account__r.store_number__C;
                                sLd.Store_Account_Id__c = mapSTZC.get(sLd.PostalCode).Store_Account__c; //SARAN-To populate the store account on the lead
                            }
                        }
                else if((sLd.Business_Segment__c == 'Pro Dealer')
                        && (mapCampName.containsKey(sLd.Campaign__c) && mapCampName.get(sLd.Campaign__c) == 'PellaProDealer.com/contact-us')){
                            if(mapSTZC.containskey(sLd.PostalCode) &&  mapSTZC.get(sLd.PostalCode).Pro_Dealer_Store_Owner__c != null){
                                sLd.OwnerId = mapSTZC.get(sLd.PostalCode).Pro_Dealer_Store_Owner__c;
                                sLd.Store_Account__c = mapSTZC.get(sLd.PostalCode).Store_Account__r.store_number__C;
                                sLd.Store_Account_Id__c = mapSTZC.get(sLd.PostalCode).Pro_Dealer_Store_Account__c; //SARAN-To populate the store account on the lead
                            }
                        }
                else if (sLd.Business_Segment__c == 'Luxury'){
                    sLd.OwnerId =  luxuryBranch[0].Trade_Lead_Receiver__c;  
                }
            }
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(
                new ApexDebugLog.Error( 'LeadTriggerHandler', 'eloquaLeadAssignment',  JSON.serialize(leads) , ex, 'Internal'));
        }
    }
    
    public static void pellaProMobileLeadAssignment (List<Lead> leads, Map<Id,Lead> oldMap){
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade_Comm').getRecordTypeId();
        Id zipcodeRecordTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByName().get('Zipcode').getRecordTypeId();

        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<Id, String> zipcodeMap = new Map<Id, String>();

        //Process only TC leads coming from the Pella Pro Mobile App
        for(Lead lead : leads ){
            if(lead.RecordTypeId == leadRecordTypeId && lead.Originating_System__c == 'Pella Pro Mobile App'){
                leadMap.put(lead.Id, lead);
                zipcodeMap.put(lead.Id, lead.PostalCode);
            }
        }

        List<ServiceTerritory> serviceTerritoriesList = [
            SELECT Id, PostalCode, Comm_Lead_Receiver__c, Trade_Lead_Receiver__c, PCC_Lead_Receiver__c, ParentTerritory.ParentTerritory.Branch__r.Name
            FROM ServiceTerritory 
            WHERE Name IN : zipcodeMap.values() 
            AND RecordTypeId =: zipcodeRecordTypeId 
        ];

        Map<String, ServiceTerritory> serviceTeritoryZipcodeMap = new Map<String, ServiceTerritory>(); 
        
        for(ServiceTerritory serviceTerritory : serviceTerritoriesList){
            serviceTeritoryZipcodeMap.put(serviceTerritory.PostalCode, serviceTerritory);
        }
        
        for(Lead lead : leadMap.values()){
            if(lead.Business_Segment__c == 'Trade' || lead.Business_Segment__c == 'Commercial') {
                if(serviceTeritoryZipcodeMap.containskey(lead.PostalCode)){
                    if (serviceTeritoryZipcodeMap.get(lead.PostalCode).Trade_Lead_Receiver__c != null) {
                        lead.OwnerId = serviceTeritoryZipcodeMap.get(lead.PostalCode).Trade_Lead_Receiver__c;
                    }
                    
                    if (serviceTeritoryZipcodeMap.get(lead.PostalCode).ParentTerritory.ParentTerritory.Branch__r.Id != null) {
                        lead.Branch__c = serviceTeritoryZipcodeMap.get(lead.PostalCode).ParentTerritory.ParentTerritory.Branch__r.Id;
                    }
                }
            }
        }       
    }
}