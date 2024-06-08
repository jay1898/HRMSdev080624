public without sharing class QuickSWOCreateController {
    // check if selected quote records does match our criteria
    @AuraEnabled
    public static QuoteWrapper checkQuoteRecordDetails(String recordId,boolean isFromOpportunity){
        QuoteWrapper qWrapper = new QuoteWrapper();
        
        if(recordId.startsWith('006')){
            Map<String,String> QuoteNumberIdMap=new Map<String,String>();
            for(Quote quote : [Select Id, Name ,Quote_Number_PQM__c,OwnerId From Quote Where OpportunityId =: recordId ]){
                QuoteNumberIdMap.put(quote.Id,quote.Quote_Number_PQM__c);
            }
            
            Opportunity Opp=[SELECT ID,ownerId,Opportunity.Work_Order__c,Account.RecordType.DeveloperName, Account_Branch_Profile__r.Branch__c,Account_Branch_Profile__r.Branch__r.Branch_Family__c,Account.Branch__c,Account.Branch__r.Branch_Family__c,branch__c,Account.billingstreet,Account.billingcountry,Account.billingCity,Account.billingstate,Account.billingpostalcode,Account.PersonMailingstreet,Account.PersonMailingcountry,Account.PersonMailingCity,Account.PersonMailingstate,Account.PersonMailingpostalcode FROM Opportunity where id= :recordId];
            
            Quote qRec = new Quote();
            qRec.OpportunityId=Opp.Id;
            qRec.OwnerId=Opp.ownerId;
            qRec.ProjectOwner_City__c=opp.Account.BillingCity;
            qRec.ProjectOwner_Country__c=opp.Account.BillingCountry;
            qRec.ProjectOwner_State__c=opp.Account.BillingState;
            qRec.ProjectOwner_Street__c=opp.Account.BillingStreet;
            qRec.ProjectOwner_Zip__c=opp.Account.BillingPostalCode;
            if(opp.Account.RecordType.DeveloperName == 'PersonAccount' ){
                qRec.ProjectOwner_City__c=opp.Account.PersonMailingCity;
                qRec.ProjectOwner_Country__c=opp.Account.PersonMailingCountry;
                qRec.ProjectOwner_State__c=opp.Account.PersonMailingState;
                qRec.ProjectOwner_Street__c=opp.Account.PersonMailingStreet;
                qRec.ProjectOwner_Zip__c=opp.Account.PersonMailingPostalCode;
            }
            qWrapper.isProjectOwnerAddress = true;
            qWrapper.status = 'Error';
            qWrapper.isMarketSegment = true;
            qWrapper.status = 'Error';
            qWrapper.isOpportunity=true;
            qWrapper.oppBranch=opp.Account.RecordType.DeveloperName == 'PersonAccount' ?  opp.Account_Branch_Profile__r.Branch__c :opp.Account.Branch__c;
            qWrapper.oppBranchFamily=opp.Account.RecordType.DeveloperName == 'PersonAccount' ?  opp.Account_Branch_Profile__r.Branch__r.Branch_Family__c :opp.Account.Branch__r.Branch_Family__c;
            qWrapper.QuoteNumberIdMap=QuoteNumberIdMap;
            
            qWrapper.quote = qRec;
            if(String.isNotBlank(opp.Work_Order__c)){
                throw new MyException(system.label.SWO_Quote_WO_Exist);
            }
        }else{
            Quote qRec = [Select Id, OwnerId,Name,OpportunityId,Opportunity.Work_Order__c,Business_Segment__c,PO_Number__c,ProjectOwner_City__c,Branch_Family__c,Branch__c, Status, Order_Type__c,
                          ProjectOwner_Country__c,ProjectOwner_State__c,ProjectOwner_Street__c,ProjectOwner_Zip__c,Market_Segment__c,
                          Work_Order__c
                          From Quote Where Id =: recordId limit 1];
            qWrapper.quote = qRec;
            qWrapper.status = 'Success';
            if(String.isNotBlank(qRec.Opportunity.Work_Order__c)){
                if(String.isBlank(qRec.Work_Order__c)){
                    if(!isFromOpportunity && (qRec.Status != 'Contracted' && qRec.Status != 'Engineering' && qRec.Status != 'Booked' && qRec.Status != 'PendingBooked' && qRec.Status != 'PendingIntegration' && qRec.Status != 'Ordered' && qRec.Status != 'Pending Order Ack')){
                        throw new MyException(system.label.SWO_Quote_Status);
                    }
                    qRec.Work_Order__c=qRec.Opportunity.Work_Order__c;
                    update qRec;
                    qWrapper.message = system.label.SWO_Quote_WO_Success;
                    return qWrapper;
                }
                throw new MyException(system.label.SWO_Quote_WO_Exist);
            }
            if(!isFromOpportunity && (qRec.Status != 'Contracted' && qRec.Status != 'Engineering' && qRec.Status != 'Booked' && qRec.Status != 'PendingBooked' && qRec.Status != 'PendingIntegration' && qRec.Status != 'Ordered' && qRec.Status != 'Pending Order Ack')){
                throw new MyException(system.label.SWO_Quote_Status);
            }
            if(String.isBlank(qRec.Market_Segment__c)){
                qWrapper.isMarketSegment = true;
                qWrapper.status = 'Error';
            }
            if(String.isBlank(qRec.ProjectOwner_City__c) || String.isBlank(qRec.ProjectOwner_Country__c) || String.isBlank(qRec.ProjectOwner_State__c) || String.isBlank(qRec.ProjectOwner_Street__c) || String.isBlank(qRec.ProjectOwner_Zip__c)){
                qWrapper.isProjectOwnerAddress = true;
                qWrapper.status = 'Error';
            }
        }
        return qWrapper;
    }
    
    // check territory Zipcode Exist
    @AuraEnabled
    public static Map<String,String> checkTerritoryDetails(Quote q, Boolean isMarketSegment, String workTypeId){
        Map<String,String> returnMap=new Map<String,String>();
        WorkType workType=new WorkType();
        set<String> setWOZipcode=new Set<String>();
        Set<String> setWOSchType = new Set<String>();
        Map<String,WorkType> WOTypeNamewiseId=new Map<String,WorkType>(); 
        Map<String,WorkType> WOTypeMap=new Map<String,WorkType>(); 
        
        returnMap.put('result','success');
        
        for(WorkType WOType :[SELECT Id, Name,Schedule_Type__c FROM WorkType]){
            WOTypeNamewiseId.put(WOType.Name, WOType);
            WOTypeMap.put(WOType.Id, WOType);
        }
        // added on 15-03-2022 for update Work Type
        if(isMarketSegment && String.isNotBlank(workTypeId)){
            if(WOTypeMap.containsKey(workTypeId)){
                workType = WOTypeMap.get(workTypeId);
            }
            
        }else{
            if(q.Business_Segment__c == 'Trade' && (q.Market_Segment__c == 'S0' || q.Market_Segment__c == 'S1A' || q.Market_Segment__c == 'S1B' || q.Market_Segment__c == 'S1C' || q.Market_Segment__c == 'S2' || q.Market_Segment__c == 'S3' )){
                workType = WOTypeNamewiseId.containsKey('New Construction')?WOTypeNamewiseId.get('New Construction'):null;
            }else if(q.Business_Segment__c == 'Trade' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                workType = WOTypeNamewiseId.containsKey('Trade R/R')?WOTypeNamewiseId.get('Trade R/R'):null;
            }else if(q.Business_Segment__c == 'Retail' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                workType = WOTypeNamewiseId.containsKey('Retail')?WOTypeNamewiseId.get('Retail'):null;
            }else if(q.Business_Segment__c == 'Replacement' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                workType = WOTypeNamewiseId.containsKey('Retail')?WOTypeNamewiseId.get('Retail'):null;
            }else if(q.Business_Segment__c == 'Commercial' && (q.Market_Segment__c == 'MF' || q.Market_Segment__c == 'MR' || q.Market_Segment__c == 'N2' || q.Market_Segment__c == 'NR')){
                workType = WOTypeNamewiseId.containsKey('Commercial')?WOTypeNamewiseId.get('Commercial'):null;
            }
        }
        system.debug('@@'+q);
        //For new records
        if(q.Branch__c != null && WorkTypeId != null && q.ProjectOwner_Zip__c != null){
            if(q.ProjectOwner_Country__c == 'US' && q.ProjectOwner_Zip__c.length() > 5){
                setWOZipcode.add(String.valueOf(q.ProjectOwner_Zip__c).substring(0, 5)); 
            }
            else if((q.ProjectOwner_Country__c == null || q.ProjectOwner_Country__c == 'US') && (q.ProjectOwner_Zip__c.length() <= 5)){
                setWOZipcode.add(q.ProjectOwner_Zip__c);
            }
            
            if(q.ProjectOwner_Country__c == 'CA' && q.ProjectOwner_Zip__c != null ){
                setWOZipcode.add(String.valueOf(q.ProjectOwner_Zip__c).substring(0, 3));
            } 
            
            if(workType.Schedule_Type__c!=null && ((workType.Schedule_Type__c.contains('Install')) || (workType.Schedule_Type__c == 'Project') || (workType.Schedule_Type__c == 'Recovery') )){
                setWOSchType.add('Install');  
            }
            else {
                setWOSchType.add(workType.Schedule_Type__c); 
            } 
            system.debug('setWOZipcode:' + setWOZipcode);
        }
        system.debug('branch:' + q.Branch__c);
        system.debug('setWOSchType:' + setWOSchType);
        //check if Territory exists for entered zip code, banch and Type.    
        List<Territory_Zipcode__c> tzipcode =[SELECT Id, Territory__c, Territory_Type__c, ZipCode__r.Name,Territory_Branch__c
                                            FROM Territory_Zipcode__c where ZipCode__r.Name IN :setWOZipcode
                                            AND Territory_Branch__c = :q.Branch__c AND Territory_Type__c IN :setWOSchType];
        if(tzipcode.size()==0){
            returnMap.put('result','warning');
            returnMap.put('ErrorMessage',system.Label.Territory_Zipcode_Error);
        }
       
        return returnMap;
    }
    
    /**
*   @Method:        createSWORecord
*   @Purpose:       Create Service Work Order records
*   @Author:        Dhruv (eVerge)
*   @Date:          03/08/2022
*   @TaskSource:    

*   @Updates:       
*/      
    @AuraEnabled
    public static List<Quote> createSWORecord(Quote quoteRec, Boolean isMarketSegment, String workTypeId,Boolean forceCreate){
        List<Quote> listQuote = new List<Quote>();
        if(quoteRec != null)
            listQuote.add(quoteRec);
        Set<Id> listCreatedQuoteIds=new set<Id>(); // created Quote Ids set
        Set<Id> listOppIds=new set<Id>(); // opportunityIds set 
        set<Id> setBranchFamilyIds=new set<Id>(); // Branch Family Id set
        set<Id> setBranchIds=new set<Id>();// Branch Ids set 
        set<Id> setAvailbleBranchIds=new set<Id>();// available for sWO Branch Ids set
        List<String> opportunityIds =new List<String>(); 
        Map<String,Opportunity> oppIdWiseAccount =new Map<String,Opportunity>();
        /*List<Quote> listQuote = [Select Id, Name,OpportunityId,Opportunity.Work_Order__c,Business_Segment__c,PO_Number__c,ProjectOwner_City__c,Branch_Family__c,Branch__c, Status, Order_Type__c,
ProjectOwner_Country__c,ProjectOwner_State__c,ProjectOwner_Street__c,ProjectOwner_Zip__c,Market_Segment__c
From Quote Where Id =: recordId];*/
         Set<Id> listQuoteOwnerIds=new set<Id>(); // created Quote Ids set
        
        for(Quote q :listQuote){// create SWO if order type is 'INSTALLED_SALES' and Status is 'Contracted' 
            
            listCreatedQuoteIds.add(q.Id);
            listOppIds.add(q.OpportunityId);
            system.debug('q.Branch_Family__c:::'+q.Branch_Family__c);
            // get Branch Family Id from quote
            if(q.Branch_Family__c!=null)
                setBranchFamilyIds.add(q.Branch_Family__c);
            // get Branch Id from quote
            if(q.Branch__c !=null)
                setBranchIds.add(q.Branch__c);
            if( q.OpportunityId!=null)
                opportunityIds.add(q.OpportunityId);
            listQuoteOwnerIds.add(q.OwnerId);
        }
        Map<String,Branch__c> branchMap=new Map<String,Branch__c>();
        
        // check if branch is available for sWO or not
        for(Branch__c branchList : [Select Id, Name, Is_Available_for_Work_Order__c,Advance_PC_WO_Assignment__c,Default_Retail_PC_receiver__r.RelatedRecordId,Default_Trade_PC_Receiver__r.RelatedRecordId From Branch__c Where Id IN :setBranchIds]){
            if(branchList.Is_Available_for_Work_Order__c){
               	setAvailbleBranchIds.add(String.valueOf(branchList.Id).substring(0,15));
            }
            branchMap.put(String.valueOf(branchList.Id).substring(0,15),branchList);
        }
        
        map<String, List<String>> BranchFamilyWiseSRMap = new map<String, List<String>>();
        map<Id, ServiceResource> mapUserwiseSR = new map<Id, ServiceResource>();
        Set<Id> setOfUserIds = new Set<Id>();
        map<String, String> mapOfSRwithUser = new map<String, String>();
        
        for(Opportunity opp :[SELECT Id, AccountId,Account.Name,Account.RecordType.DeveloperName,Account.personContactId, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry FROM Opportunity WHERE Id IN :opportunityIds]){
            oppIdWiseAccount.put(opp.Id, opp);
        }
        Map<String,string> salesResorceWisePiesResource=new Map<String,string>();
        //fetch Owner Id Wise Resource
        for(ServiceResource serviceResourceRecs : [SELECT Id, Name,RelatedRecordId,Business_Segment__c,Mapped_Retail_PC__r.RelatedRecordId FROM ServiceResource WHERE IsActive=true and RelatedRecordId =:listQuoteOwnerIds and Mapped_Retail_PC__c!=null ]){
            salesResorceWisePiesResource.put(serviceResourceRecs.RelatedRecordId,serviceResourceRecs.Mapped_Retail_PC__r.RelatedRecordId);
        }
        //fetch related Quote Branch and Branch Family which has record type 'Install_OV' Service Resource and Project Cordinator is set to true 
        for(ServiceResource serviceResourceRecs : [SELECT Id, Name,RelatedRecordId,Business_Segment__c  ,Primary_Branch_Family__c, Branch__r.Branch_Family__c, Project_Coordinator__c FROM ServiceResource WHERE IsActive=true and (Primary_Branch_Family__c IN :setBranchFamilyIds or Branch__c IN :setBranchIds) and Project_Coordinator__c = true and RecordType.DeveloperName = 'Install_OV']){
            if(serviceResourceRecs.Primary_Branch_Family__c != null ){
                if(!BranchFamilyWiseSRMap.containsKey(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15))){
                    BranchFamilyWiseSRMap.put(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15),new List<String>());
                }
                BranchFamilyWiseSRMap.get(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15)).add(serviceResourceRecs.RelatedRecordId);
            }else if(serviceResourceRecs.Branch__r.Branch_Family__c != null){
                if(!BranchFamilyWiseSRMap.containsKey(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15))){
                    BranchFamilyWiseSRMap.put(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15),new List<String>());
                }
                BranchFamilyWiseSRMap.get(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15)).add(serviceResourceRecs.RelatedRecordId);
                
            }
            mapUserwiseSR.put(serviceResourceRecs.RelatedRecordId, serviceResourceRecs);
            setOfUserIds.add(serviceResourceRecs.RelatedRecordId);
            mapOfSRwithUser.put(serviceResourceRecs.Id,serviceResourceRecs.RelatedRecordId);
        }
        system.debug('setOfUserIds : '+ setOfUserIds);
        //work order count by owner
        Map<String, Decimal> mapCountOfWorkOrderByOwner = new Map<String, Decimal>();
        AggregateResult[] lstWorkOrderByUserCnt = [SELECT count(Id) cntWorkOrder, OwnerId FROM WorkOrder 
                                                   WHERE OwnerId IN : setOfUserIds AND OwnerId != NULL
                                                   GROUP BY OwnerId 
                                                   ORDER BY COUNT(Id) ASC];
        
        system.debug('lstWorkOrderByUserCnt: '+lstWorkOrderByUserCnt);
        List<WorkOrderByUserWrapper> lstWrap = new List<WorkOrderByUserWrapper>();
        set<String> setUserIdCountFound=new set<String>();
        // User's related Work ORder Count 
        for(AggregateResult aggResult : lstWorkOrderByUserCnt)
        {
            WorkOrderByUserWrapper obj = new WorkOrderByUserWrapper();
            obj.UserId = (String)aggResult.get('OwnerId');
            obj.WorkOrderCnt = (Integer)aggResult.get('cntWorkOrder');
            lstWrap.add(obj);
            setUserIdCountFound.add( (String)aggResult.get('OwnerId'));
            //mapCountOfWorkOrderByOwner.put((String)aggResult.get('OwnerId'), (Decimal)aggResult.get('cntWorkOrder'));
        }
        // process for not found count
        for(String userId : setOfUserIds){
            if(!setUserIdCountFound.contains(userId)){
                WorkOrderByUserWrapper obj = new WorkOrderByUserWrapper();
                obj.UserId = userId;
                obj.WorkOrderCnt = 0;
                lstWrap.add(obj);
            }
        }
        system.debug('lstWrap: '+lstWrap);
        
        // Need to  add sorting logic
        
        
        Map<String,String> QuoteWiseSWO=new Map<String,String>(); 
        Map<String,String> OpportunityWiseSWO=new Map<String,String>(); 
        // added logic on 15-03-2022 fetch all Work Type 
        Map<String,String> WOTypeNamewiseId=new Map<String,String>(); 
        for(WorkType WOType :[SELECT Id, Name FROM WorkType]){
            WOTypeNamewiseId.put(WOType.Name, WOType.Id);
        }
        // check existing SWO
        for(WorkOrder WO : [SELECT Id,Quote__c FROM WorkOrder where Quote__c in :listCreatedQuoteIds]){
            QuoteWiseSWO.put(WO.Quote__c,WO.Id);
        }
        // check existing SWO
        for(Opportunity opp : [SELECT Id,Work_Order__c FROM Opportunity where Id in :listOppIds]){
            if(opp.Work_Order__c!=null){
                OpportunityWiseSWO.put(opp.Id,opp.Work_Order__c);
            }
        }
        // create work Order  if quote status is contracted and  order type is Install OV
        Map<String,WorkOrder> QuoteWiseSWOToCreate=new Map<String,WorkOrder>();
        for(Quote q : listQuote){
             system.debug('q.Branch__c:::'+q.Branch__c);
            WorkOrder WO=new WorkOrder();
            WO.Branch__c=Q.Branch__c;
            WO.Quote__c=Q.Id;
            
            WO.Subject=Q.Business_Segment__c+'-'+Q.Name;
            //WO.Business_Segment__c=Q.Business_Segment__c;
            if(oppIdWiseAccount.containsKey(q.opportunityId)){
                WO.AccountId=oppIdWiseAccount.get(q.opportunityId).AccountId;
                WO.Subject=Q.PO_Number__c+'-'+oppIdWiseAccount.get(q.opportunityId).Account.Name;
                if(oppIdWiseAccount.get(q.opportunityId).Account.RecordType.DeveloperName=='PersonAccount'){
                    WO.ContactId=oppIdWiseAccount.get(q.opportunityId).Account.PersonContactId;
                }
            }
            WO.City = q.ProjectOwner_City__c;
            system.debug('PO Country::::::'+q.ProjectOwner_Country__c);
            WO.Country = q.ProjectOwner_Country__c;
            WO.State = q.ProjectOwner_State__c;
            WO.Street = q.ProjectOwner_Street__c;
            WO.PostalCode = q.ProjectOwner_Zip__c;
            
            if(q.Id==null){
                WO.Quote_Number__c=Q.PO_Number__c;
            }
            WO.Status='New';
            // added on 15-03-2022 for update Work Type
            if(isMarketSegment && String.isNotBlank(workTypeId)){
                WO.WorkTypeId = workTypeId;
            }else{
                if(q.Business_Segment__c == 'Trade' && (q.Market_Segment__c == 'S0' || q.Market_Segment__c == 'S1A' || q.Market_Segment__c == 'S1B' || q.Market_Segment__c == 'S1C' || q.Market_Segment__c == 'S2' || q.Market_Segment__c == 'S3' )){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('New Construction')?WOTypeNamewiseId.get('New Construction'):null;
                }else if(q.Business_Segment__c == 'Trade' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Trade R/R')?WOTypeNamewiseId.get('Trade R/R'):null;
                }else if(q.Business_Segment__c == 'Retail' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Retail')?WOTypeNamewiseId.get('Retail'):null;
                }else if(q.Business_Segment__c == 'Replacement' && (q.Market_Segment__c == 'SM' || q.Market_Segment__c == 'SP')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Retail')?WOTypeNamewiseId.get('Retail'):null;
                }else if(q.Business_Segment__c == 'Commercial' && (q.Market_Segment__c == 'MF' || q.Market_Segment__c == 'MR' || q.Market_Segment__c == 'N2' || q.Market_Segment__c == 'NR')){
                    WO.WorkTypeId = WOTypeNamewiseId.containsKey('Commercial')?WOTypeNamewiseId.get('Commercial'):null;
                }
            }
            lstWrap.sort();
            
            // Check If Branch Has Advance Logic
            if(branchMap.ContainsKey(Q.Branch__c) && branchMap.get(Q.Branch__c).Advance_PC_WO_Assignment__c == true){
                // check business segment
                if(q.Business_Segment__c == 'Replacement' || q.Business_Segment__c == 'Retail' ){
                    
                    //Assign the WO to the PC mapped to Quote’s Owner as per the setup in #3 above
                    if(salesResorceWisePiesResource.containsKey(q.OwnerId)){
                        WO.OwnerId=salesResorceWisePiesResource.get(q.OwnerId);
                        system.debug('@@PC mapped to Quote’s Owner '+ q.OwnerId);
                    }
                }
                 // get Resource who has business Segment same
                if(WO.OwnerId == null && BranchFamilyWiseSRMap.containsKey(Q.Branch_Family__c)){
                     for(WorkOrderByUserWrapper wou : lstWrap){
                         system.debug('@@wou.userId :: '+wou.userId);
                         if(BranchFamilyWiseSRMap.get(Q.Branch_Family__c).contains(wou.userId) && mapUserwiseSR.containsKey(wou.userId) && mapUserwiseSR.get(wou.userId).Business_Segment__c == q.Business_Segment__c ){
                            WO.OwnerId=wou.userId;
                            wou.WorkOrderCnt++;
                             system.debug('@@ business Segment same '+ q.OwnerId);
                            break;
                        }
                    }
                }
                // If still not found the take default PC User
                if( WO.OwnerId == null ){
                    
                    //If there are still no matches, use Branch’s ‘Default Replacement PC Receiver’ (lookup on branch)
                    if(q.Business_Segment__c == 'Replacement' || q.Business_Segment__c == 'Retail' ){
                        WO.OwnerId=branchMap.get(Q.Branch__c).Default_Retail_PC_receiver__r.RelatedRecordId;
                        system.debug('@@ default replacement '+ q.OwnerId);
                    }
                    
                    //If there are no matches, use Branch’s ‘Default Trade PC Receiver’ (lookup on branch)
                    if(q.Business_Segment__c == 'Trade' ){
                        WO.OwnerId=branchMap.get(Q.Branch__c).Default_Trade_PC_Receiver__r.RelatedRecordId;
                         system.debug('@@ default trade '+ q.OwnerId);
                    }
                    
                }
                
            }else{
                // Owner Logic need to implement
                if(!forceCreate && BranchFamilyWiseSRMap.containsKey(Q.Branch_Family__c)){
                    for(WorkOrderByUserWrapper wou : lstWrap){
                        system.debug('@@condition::::::::::'+BranchFamilyWiseSRMap.get(Q.Branch_Family__c).contains(wou.userId));
                        if(BranchFamilyWiseSRMap.get(Q.Branch_Family__c).contains(wou.userId)){
                            WO.OwnerId=wou.userId;
                            wou.WorkOrderCnt++;
                            
                            break;
                        }
                    }
                    if( WO.OwnerId == null ){
                        WO.OwnerId=BranchFamilyWiseSRMap.get(Q.Branch_Family__c)[0];
                    }
                }
            }
            QuoteWiseSWOToCreate.put(q.OpportunityId,WO);
            
        }
        try{
            insert QuoteWiseSWOToCreate.values();
        }catch(Exception e){
            system.debug('Line Number:::::::::::::'+ e.getLineNumber());
            system.debug('get Message:::::::::::::'+ e.getMessage());
            throw new MyException(e.getMessage());
        }
        
        system.debug('QuoteWiseSWOToCreate:::::::::::::'+QuoteWiseSWOToCreate);
        // update created Work order in opportunity and quote
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        for(Quote qId : listQuote){
            if( QuoteWiseSWOToCreate.containsKey(qId.OpportunityId)){
                Opportunity opp = new Opportunity();
                opp.Id = qId.OpportunityId;
                opp.Work_Order__c = QuoteWiseSWOToCreate.get(qId.OpportunityId).Id;
                oppUpdateList.add(opp);
            }
            else if(OpportunityWiseSWO.containsKey(qId.OpportunityId)){
                qId.Work_Order__c= OpportunityWiseSWO.get(qId.OpportunityId);
                //qId.Primary__c=true;
            }
            
        }
        // update workorder Id on Opportunity 
        update  oppUpdateList;
        
        if(quoteRec.Id!=null){
            Quote q = new Quote();
            q.Id = quoteRec.Id;
            q.Work_Order__c= QuoteWiseSWOToCreate.get(quoteRec.OpportunityId).Id;
            q.Primary__c=true;
            update q;
            return [SELECT Id, Work_Order__r.WorkOrderNumber FROM Quote Where Id =:quoteRec.Id];//.Work_Order__r.WorkOrderNumber;
        }
        quoteRec.Work_Order__r=[select Id,WorkOrderNumber from WorkOrder where Id= : QuoteWiseSWOToCreate.get(quoteRec.OpportunityId).Id limit 1 ];
        quoteRec.Work_Order__c=QuoteWiseSWOToCreate.get(quoteRec.OpportunityId).Id;
        return new List<Quote>{quoteRec};//.Work_Order__r.WorkOrderNumber;
        // Update QuotesToUpdate;
    }
    Public Class WorkOrderByUserWrapper implements Comparable{
        public String UserId;
        Public Integer WorkOrderCnt;
        
        public Integer compareTo(Object objToCompare) {
            WorkOrderByUserWrapper compareToEmp = (WorkOrderByUserWrapper)objToCompare;
            if (WorkOrderCnt == compareToEmp.WorkOrderCnt) return 0;
            if (WorkOrderCnt > compareToEmp.WorkOrderCnt) return 1;
            return -1;     
        }
    }
    public class QuoteWrapper{
        @AuraEnabled public boolean isMarketSegment;
        @AuraEnabled public boolean isProjectOwnerAddress;
        @AuraEnabled public boolean isOpportunity;
        @AuraEnabled public String oppBranch;
        @AuraEnabled public String oppBranchFamily;
        @AuraEnabled public String message;
        @AuraEnabled public Quote quote;
        @AuraEnabled public string status;
        @AuraEnabled public Map<String,String> QuoteNumberIdMap;
        public QuoteWrapper(){
            status = '';
            isMarketSegment = isProjectOwnerAddress = false;
            quote = new Quote();
        }
        
    }
    public class MyException extends Exception {}
}