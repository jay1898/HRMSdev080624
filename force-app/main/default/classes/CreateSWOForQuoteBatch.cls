public without sharing class CreateSWOForQuoteBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    public set<Id> allSuccessId=new set<Id>();
    public map<String, String> mpWOIdQtId = new Map<String, String>(); 
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<AsyncApexJob> listAA=[Select Id, Status,ApexClassId,ApexClass.Name, NumberOfErrors, 
                                   JobItemsProcessed,TotalJobItems, ExtendedStatus 
                                   From AsyncApexJob 
                                   Where ApexClass.Name='CreateSWOForQuoteBatch'
                                   And Status in ('Holding','Processing')];
        if(listAA.size()>0){
            return Database.getQueryLocator([SELECT ID FROM Quote  limit 0]); 
        }
       // List<String> quoteNumbers=Label.QuoteNumberList_ForSWOCreate.split(',');
       // Get the Quote numbers from Static file
        StaticResource qtFile = [SELECT Id, Body FROM StaticResource WHERE Name = 'QuoteNumberFile' LIMIT 1];
        //Convert the data to string
        String bodyQtFile = qtFile.Body.toString();
        System.debug('bodyQtFile : '+bodyQtFile);
        //remove the next line and get all the numbers in one line. For ex. 123,4546,7687
        List<String> listQt = bodyQtFile.split('\r\n');
        system.debug('listQt : '+ listQt + 'listQt size :' + listQt.size()  );
        system.debug([SELECT ID,OpportunityId,Branch__c,Branch_Family__c,name,Business_Segment__c,
                                         Market_Segment__c,Work_Order__c,ProjectOwner_Zip__c,ProjectOwner_Street__c,ProjectOwner_State__c,
                                         ProjectOwner_Country__c,ProjectOwner_City__c,PO_Number__c
                                         FROM Quote Where Quote_Number_PQM__c !=null and 
                                         Quote_Number_PQM__c in :listQt order by createddate asc ].size());
        return Database.getQueryLocator([SELECT ID,OpportunityId,Branch__c,Branch_Family__c,name,Business_Segment__c,
                                         Market_Segment__c,Work_Order__c,ProjectOwner_Zip__c,ProjectOwner_Street__c,ProjectOwner_State__c,
                                         ProjectOwner_Country__c,ProjectOwner_City__c,PO_Number__c
                                         FROM Quote Where Quote_Number_PQM__c!=null and 
                                         Quote_Number_PQM__c in :listQt order by createddate asc ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Quote> listQuote){
        system.debug('Line 41 listQuote : ' + listQuote.size());
        system.debug('Line 42 : ' + listQuote);
        Set<Id> listCreatedQuoteIds=new set<Id>(); // created Quote Ids set
        Set<Id> listOppIds=new set<Id>(); // opportunityIds set 
        set<Id> setBranchFamilyIds=new set<Id>(); // Branch Family Id set
        set<Id> setBranchIds=new set<Id>();// Branch Ids set 
        set<Id> setAvailbleBranchIds=new set<Id>();// available for sWO Branch Ids set
        List<String> opportunityIds =new List<String>(); 
        Map<String,Opportunity> oppIdWiseAccount =new Map<String,Opportunity>();
        for(Quote q : listQuote){// create SWO if order type is 'INSTALLED_SALES' and Status is 'Contracted' 
            listCreatedQuoteIds.add(q.Id);
            listOppIds.add(q.OpportunityId);
            // get Branch Family Id from quote
            if(string.isNotBlank(q.Branch_Family__c))
                setBranchFamilyIds.add(q.Branch_Family__c);
            // get Branch Id from quote
            if(string.isNotBlank(q.Branch__c))
                setBranchIds.add(q.Branch__c);
            if( q.OpportunityId!=null)
                opportunityIds.add(q.OpportunityId);
        }
        system.debug('opportunityIds :' + opportunityIds);
        // check if branch is available for sWO or not
        for(Branch__c branchList : [Select Id, Name, Is_Available_for_Work_Order__c From Branch__c Where Id IN :setBranchIds]){
            if(branchList.Is_Available_for_Work_Order__c)
                setAvailbleBranchIds.add(String.valueOf(branchList.Id).substring(0,15));
        }
        
        map<String, List<String>> BranchFamilyWiseSRMap = new map<String, List<String>>();
        map<Id, Id> mapUserwiseSRId = new map<Id, Id>();
        Set<Id> setOfUserIds = new Set<Id>();
        map<String, String> mapOfSRwithUser = new map<String, String>();
        
        for(Opportunity opp :[SELECT Id, AccountId,Account.Name,Account.RecordType.DeveloperName,Account.personContactId, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry FROM Opportunity WHERE Id IN :opportunityIds]){
            oppIdWiseAccount.put(opp.Id, opp);
        }
        system.debug('oppIdWiseAccount : ' + oppIdWiseAccount);
        //fetch related Quote Branch and Branch Family which has record type 'Install_OV' Service Resource and Project Cordinator is set to true 
        for(ServiceResource serviceResourceRecs : [SELECT Id, Name,RelatedRecordId, Primary_Branch_Family__c, Branch__r.Branch_Family__c, Project_Coordinator__c FROM ServiceResource WHERE (Primary_Branch_Family__c IN :setBranchFamilyIds or Branch__c IN :setBranchIds) and Project_Coordinator__c = true and RecordType.DeveloperName = 'Install_OV']){
            if(serviceResourceRecs.Primary_Branch_Family__c != null ){
                if(!BranchFamilyWiseSRMap.containsKey(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15))){
                    BranchFamilyWiseSRMap.put(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15),new List<String>());
                }
                BranchFamilyWiseSRMap.get(String.valueOf(serviceResourceRecs.Primary_Branch_Family__c).substring(0,15)).add(serviceResourceRecs.RelatedRecordId);
            }else{
                if(!BranchFamilyWiseSRMap.containsKey(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15))){
                    BranchFamilyWiseSRMap.put(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15),new List<String>());
                }
                BranchFamilyWiseSRMap.get(String.valueOf(serviceResourceRecs.Branch__r.Branch_Family__c).substring(0,15)).add(serviceResourceRecs.RelatedRecordId);
                
            }
            mapUserwiseSRId.put(serviceResourceRecs.RelatedRecordId, serviceResourceRecs.Id);
            setOfUserIds.add(serviceResourceRecs.RelatedRecordId);
            mapOfSRwithUser.put(serviceResourceRecs.Id,serviceResourceRecs.RelatedRecordId);
        }
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
        system.debug('setUserIdCountFound : ' + setUserIdCountFound);
        // process for not found count
        for(String userId : setOfUserIds){
            system.debug('userId : ' + userId);
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
        system.debug('listCreatedQuoteIds :' + listCreatedQuoteIds);
        // check existing SWO
        for(WorkOrder WO : [SELECT Id,Quote__c FROM WorkOrder where Quote__c in :listCreatedQuoteIds]){
            QuoteWiseSWO.put(WO.Quote__c,WO.Id);
        }
        // check existing SWO
        system.debug('listOppIdslistOppIds :' + listOppIds);
        for(Opportunity opp : [SELECT Id,Work_Order__c FROM Opportunity where Id in :listOppIds]){
            if(opp.Work_Order__c!=null){
                OpportunityWiseSWO.put(opp.Id,opp.Work_Order__c);
            }
        }
        // create work Order  if quote status is contracted and  order type is Install OV
        Map<String,WorkOrder> QuoteWiseSWOToCreate=new Map<String,WorkOrder>();
        for(Quote q : listQuote){
            system.debug('Line 143');
            if(!OpportunityWiseSWO.containsKey(q.OpportunityID) && setAvailbleBranchIds.contains(Q.Branch__c) ){
                system.debug('Line 145 Q Id' + Q.Id);
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
                WO.Country = q.ProjectOwner_Country__c;
                WO.State = q.ProjectOwner_State__c;
                WO.Street = q.ProjectOwner_Street__c;
                WO.PostalCode = q.ProjectOwner_Zip__c;
                
                WO.Status='New';
                // added on 15-03-2022 for update Work Type
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
                lstWrap.sort();
                // Owner Logic need to implement
                if(BranchFamilyWiseSRMap.containsKey(Q.Branch_Family__c)){
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
                
                QuoteWiseSWOToCreate.put(q.OpportunityId,WO);
            }
        }
        system.debug('QuoteWiseSWOToCreate :' + QuoteWiseSWOToCreate);
        //insert QuoteWiseSWOToCreate.values();
        Database.insert(QuoteWiseSWOToCreate.values(), false);
        
        // update created Work order in opportunity and quote
        Map<Id, Opportunity> mapOppUpdate = new Map<Id, Opportunity>(); 
        for(Quote qId : listQuote){
            if( QuoteWiseSWOToCreate.containsKey(qId.OpportunityId)){
                Opportunity opp = new Opportunity();
                opp.Id = qId.OpportunityId;
                opp.Work_Order__c = QuoteWiseSWOToCreate.get(qId.OpportunityId).Id;
                qId.Work_Order__c= QuoteWiseSWOToCreate.get(qId.OpportunityId).Id;
                qId.Primary__c=true;
                mapOppUpdate.put(opp.Id, opp);
            }
            else if(OpportunityWiseSWO.containsKey(qId.OpportunityId)){
                system.debug('OpportunityWiseSWO containsk Key :' + OpportunityWiseSWO.get(qId.OpportunityId));
                qId.Work_Order__c= OpportunityWiseSWO.get(qId.OpportunityId);
                //qId.Primary__c=true;
            }
            
        }
        // update workorder Id on Opportunity 
       Database.update(mapOppUpdate.values(), false);
        
        //Update listQuote;
        system.debug('listQuote :' + listQuote);
        Database.SaveResult[] srList = Database.update(listQuote, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated : ' + sr.getId());
                allSuccessId.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Quote that errored: ' + err.getFields());
                }
            }
        
        }
        //Get WO Id from Quote records that got successfully processed.
        for(Quote q : [SELECt Id, Work_Order__c from Quote where Id IN :allSuccessId]){
            mpWOIdQtId.put(q.Id,q.Work_Order__c);
        }
        system.debug('mpWOIdQtId :' + mpWOIdQtId);
    }
    
    public void finish(Database.BatchableContext BC){
     
      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'tangellapalligk@Pella.com','urbaslj@pella.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Processed Quotes ' + a.Status);
        String sbody = '';
        for(Id sccId : allSuccessId){
            system.debug(sccId);
            if(mpWOIdQtId.containsKey(sccId)){
                  system.debug(mpWOIdQtId.get(sccId));
                 sbody =  'Quote Id : ' + sccId + ' , ' + ' WO Id : ' +mpWOIdQtId.get(sccId) + ' ; '  + sbody  ;
            }
        }
        system.debug(sbody);
         mail.setPlainTextBody(sbody) ;
                
        system.debug(mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
   public void execute(SchedulableContext sc) {
        CreateSWOForQuoteBatch b = new CreateSWOForQuoteBatch(); 
        database.executebatch(b,100);
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
}