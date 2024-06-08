public class RelatedListTreeGridController {
    
    public static final String FIELDS_PARAM                         = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM              = 'numberOfRecords';
    public static final String RECORD_ID_PARAM                      = 'recordId';
    public static final String RECORD_TYPE_PARAM                    = 'recordTypeName';
    public static final String SOBJECT_API_NAME_PARAM               = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM                  = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM           = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM   = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM         = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM               = 'sortedDirection';
    public static final String SORTED_BY_PARAM                      = 'sortedBy';
    public static final String RECORDS_PARAM                        = 'records';
    public static final String ICON_NAME_PARAM                      = 'iconName';
    public static Date partReadyDate                                = null;

    @AuraEnabled
    public static String initData(String jsonData){
        system.debug(jsonData);
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
        String recordId = (String)requestMap.get(RECORD_ID_PARAM);
        String recordTypeName = (String)requestMap.get(RECORD_TYPE_PARAM);
        String relatedFieldApiName = (String)requestMap.get(RELATED_FIELD_API_NAME_PARAM);
        String relatedApiFieldName = relatedFieldApiName.contains('__c') ? relatedFieldApiName : relatedFieldApiName +'__c';
        
        responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName, relatedApiFieldName));

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        responseMap.put(RECORD_TYPE_PARAM, recordTypeName);
        return JSON.serialize(responseMap);
    }
    
	@AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
		Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
		Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
		String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
        String recordType = (String)root.get(RECORD_TYPE_PARAM);
		String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
		String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);

        String relatedApiFieldName = relatedFieldApiName.contains('__c') ? relatedFieldApiName : relatedFieldApiName +'__c';
        String query;
        if(String.isBlank(recordType)) {
            query = 'Select '+fields+', (Select '+fields+' FROM Case_Lines__r WHERE RecordType.Name != \'' + String.escapeSingleQuotes('Product Serviced') +'\')'+' FROM '+sobjectApiName+' WHERE ' +relatedApiFieldName+ '= :recordId ORDER BY ' +orderBy;
        } else {
            query = 'Select '+fields+' From '+sobjectApiName+' WHERE ' +relatedApiFieldName+ '= :recordId AND RecordType.Name LIKE ' + '\'%' + String.escapeSingleQuotes(recordType.trim()) +'%\' ORDER BY ' +orderBy;
        }
        System.debug('query '+ query);
        return Database.query(query);
	}
        
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }     
        return name;
    }      
    
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }   


    @AuraEnabled
    public static List<Address_Assignment__c> getRelatedAddresses(String caseId) {
        String accountId;
        List<Address_Assignment__c> addressList     = new List<Address_Assignment__c>();        
        Case caseObj                                = [Select Id, AccountId, Account.IsPersonAccount, ContactId from Case where Id =: caseId];
        if(caseObj.AccountId != null && caseObj.Account.IsPersonAccount == true) {
			List<Id> accountBranchProfileIdList 	= new List<Id>();
            for(Account_Branch_Profile__c profileObj : [Select Id from Account_Branch_Profile__c where Party_Account__c =: caseObj.AccountId]) {
                accountBranchProfileIdList.add(profileObj.Id);
            }
			return [Select Id, Full_Address__c from Address_Assignment__c where Account_Branch_Profile__c IN: accountBranchProfileIdList AND Address_Usage_Type__c =: Constant.ADDRESS_INSTALL_STATUS];            
        }else{
            if(caseObj.AccountId != null) accountId     = caseObj.AccountId;
            else {
                accountId   = [Select Id, AccountId from Contact where Id =: caseObj.ContactId].AccountId;
            }    
            return [Select Id, Full_Address__c from Address_Assignment__c where Account__c =: accountId AND Address_Usage_Type__c =: Constant.ADDRESS_INSTALL_STATUS];
        }        
    }


    @AuraEnabled
    public static String generateProductRequest(List<String> caseLineIdList){
        Savepoint sp;
        Opportunity oppObj;
        List<Case_Line__c> caseLineList         = new List<Case_Line__c>();
        Id customerServiceOppRTId               = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer Service').getRecordTypeId();
        try{
            sp = Database.setSavepoint();
            caseLineList                        = [Select Id, RecordTypeId, RecordType.Name, Case__c, Second_Tech_Multiplier__c, Product_Serviced__c,
                                                   Line_Price__c, Description__c, Warranty__c, Task_Billing_Method__c, Task_Type__c, Service_Action__c,
                                                   Part_Ready__c , Order_Date__c, Part_Source__c, Product__c, Brand__c, Issue__c, Component__c
                                                   from Case_Line__c 
                                                   where Id IN: caseLineIdList];
            Case caseObj                        = new Case();
            caseObj                             = [Select Id, CaseNumber, AccountId, Account.Name, PQM_Quote_Id__c, AssignedBranch__c, AssignedBranch__r.T_C_Branch_Number__c, ContactEmail, ContactId, Priority, Subject, Description, Number_of_Technicians_Required__c, Opportunity__c
                                                   from Case where Id =: caseLineList[0].Case__c];
            if(caseObj.Opportunity__c != null) return caseObj.Opportunity__c;
            oppObj                          = new Opportunity();
            oppObj.Name 					= caseObj.Account.Name + ' - ' + caseObj.CaseNumber;
            oppObj.CloseDate				= Date.today().addMonths(1);
            oppObj.AccountId                = caseObj.AccountId;
            oppObj.StageName                = 'New';
            oppObj.RecordTypeId             = customerServiceOppRTId;
            oppObj.Case__c                  = caseObj.Id;
            oppObj.Quote_Number_Shell__c    = 'Test Id';
            oppObj.Type                     = 'Service';
            insert oppObj;
            caseObj.PQM_Quote_Id__c         = String.isBlank(caseObj.PQM_Quote_Id__c) ? 'Test Id' : caseObj.PQM_Quote_Id__c + ';' + 'Test Id';
            caseObj.Opportunity__c          = oppObj.Id;
            update caseObj;
            return oppObj.Id;
        }catch(Exception e) {
            Database.rollback(sp);
            return 'Error : ' + e.getMessage();
        }
//        return null;
    }
    
    
    @AuraEnabled
    public static String generateWorkOrder(List<String> caseLineIdList, String selectedAddressId){
        Savepoint sp;
        String branchNoZipCode;
        Id territoryId;
        try {
            sp = Database.setSavepoint();
            Set<Id> parentCaseLineIdSet         = new Set<Id>();
            Map<Id, Id> caseLineAndWOLIMap      = new Map<Id, Id>();
            List<Case_Line__c> parentCaseLines  = new List<Case_Line__c>();
            List<Case_Line__c> childCaseLines   = new List<Case_Line__c>();
            List<Case_Line__c> caseLineList     = new List<Case_Line__c>();
            Address_Assignment__c addressObj    = new Address_Assignment__c();
            caseLineList                        = [Select Id, RecordTypeId, RecordType.Name, Case__c, Second_Tech_Multiplier__c, Product_Serviced__c,
                                                   Line_Price__c, Description__c, Warranty__c, Task_Billing_Method__c, Task_Type__c, Service_Action__c,
                                                   Part_Ready__c , Order_Date__c, Part_Source__c, Product__c, Brand__c, Issue__c, Component__c
                                                   from Case_Line__c 
                                                   where Id IN: caseLineIdList];
            Case caseObj                        = new Case();
            caseObj                             = [Select Id, AccountId, AssignedBranch__c, AssignedBranch__r.T_C_Branch_Number__c, ContactEmail, ContactId, Priority, Subject, Description, Number_of_Technicians_Required__c
                                                   from Case where Id =: caseLineList[0].Case__c];
            if(String.isNotBlank(selectedAddressId)) {
                addressObj = [Select Id, Address__r.Street__c , Address__r.City__c , Address__r.State__c , Address__r.Country__c , Address__r.Zipcode__c 
                              from Address_Assignment__c
                              where Id =: selectedAddressId];
                if(caseObj.AssignedBranch__c != null && caseObj.AssignedBranch__r.T_C_Branch_Number__c != null && addressObj.Address__c != null && addressObj.Address__r.Zipcode__c != null) 
                branchNoZipCode = caseObj.AssignedBranch__r.T_C_Branch_Number__c + addressObj.Address__r.Zipcode__c;
            } 
            if(branchNoZipCode != null) {
                List<Service_Territory_Zipcode__c> territoryZipCodeList = new List<Service_Territory_Zipcode__c>();
                territoryZipCodeList                                    = [Select Id, Branch_Number_and_Zip__c, Service_Territory__c from Service_Territory_Zipcode__c where Branch_Number_and_Zip__c =: branchNoZipCode];
                if(!territoryZipCodeList.isEmpty()) territoryId         = territoryZipCodeList[0].Service_Territory__c;
            }
            WorkOrder woObj                     = createWorkOrder(caseObj, addressObj, territoryId);
            for(Case_Line__c lineObj : caseLineList) {
                if(lineObj.Product_Serviced__c != null) childCaseLines.add(lineObj);
                else parentCaseLines.add(lineObj);
            }
            caseLineAndWOLIMap = createWorkOrderLineItems(parentCaseLines, woObj, caseLineAndWOLIMap, territoryId);
            caseLineAndWOLIMap = createWorkOrderLineItems(childCaseLines, woObj, caseLineAndWOLIMap, territoryId);
            createSA(woObj, caseObj, addressObj, territoryId);
            return woObj.Id;
        } catch (Exception e) {
            System.debug(e);
            Database.rollback(sp);
            return('Error : '+ e.getMessage() + ' ' + e.getLineNumber());
        }
    }


    private static WorkOrder createWorkOrder(Case caseObj, Address_Assignment__c addressObj, Id territoryId) {
        WorkOrder woObj             = new WorkOrder();
        woObj.CaseId                = caseObj.Id;
        woObj.AccountId             = caseObj.AccountId;
        woObj.Branch__c             = caseObj.AssignedBranch__c ;
        woObj.Email__c              = caseObj.ContactEmail;
        woObj.ContactId             = caseObj.ContactId;
        woObj.Priority              = caseObj.Priority;
        woObj.Subject               = caseObj.Subject;
        woObj.Description           = caseObj.Description;
        woObj.Status                = 'New';
        woObj.RecordTypeId          = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        if(territoryId != null)
        woObj.ServiceTerritoryId    = territoryId;
        if(addressObj.Id != null) {
            woObj.Street            = addressObj.Address__r.Street__c;
            woObj.City              = addressObj.Address__r.City__c;
            woObj.State             = addressObj.Address__r.State__c;
            woObj.Country           = addressObj.Address__r.Country__c;
            woObj.PostalCode        = addressObj.Address__r.Zipcode__c;
        }
        insert woObj;
        return woObj;
    }


    private static Map<Id, Id> createWorkOrderLineItems(List<Case_Line__c> caseLineList, WorkOrder woObj, Map<Id, Id> caseLineAndWOLIMap, Id territoryId) {
        Boolean isLaborLineCreated          = false;
        List<WorkOrderLineItem> woliList    = new List<WorkOrderLineItem>();
        for(Case_Line__c caseLineObj : caseLineList) {
            WorkOrderLineItem woliObj       = new WorkOrderLineItem();
            woliObj.WorkOrderId             = woObj.Id;
            woliObj.SERVICE_Case_Line__c    = caseLineObj.Id ;
            if(territoryId != null)
            woliObj.ServiceTerritoryId      = territoryId;

            if(!caseLineAndWOLIMap.isEmpty() && caseLineObj.Product_Serviced__c != null && caseLineAndWOLIMap.containsKey(caseLineObj.Product_Serviced__c))
            woliObj.ParentWorkOrderLineItemId   = caseLineAndWOLIMap.get(caseLineObj.Product_Serviced__c);
            if(caseLineObj.RecordType.Name == 'Labor') {
                woliObj  = populateLaborWOLIObj(woliObj, caseLineObj); 
                isLaborLineCreated = true;
            }            
            if(caseLineObj.RecordType.Name == 'Product Serviced')   woliObj  = populateProductServicedWOLIObj(woliObj, caseLineObj);
            if(caseLineObj.RecordType.Name == 'Shipping')           woliObj  = populateShippingWOLIObj(woliObj, caseLineObj);
            if(caseLineObj.RecordType.Name == 'Parts') {
                if(partReadyDate == null || partReadyDate < caseLineObj.Part_Ready__c) partReadyDate = caseLineObj.Part_Ready__c;
                woliObj  = populatePartsWOLIObj(woliObj, caseLineObj);
            }             
            woliList.add(woliObj);
        }
        insert woliList;
        if(isLaborLineCreated) createSkillRequirement(woliList, woObj);

        for(WorkOrderLineItem woliObj : woliList) {
            caseLineAndWOLIMap.put(woliObj.SERVICE_Case_Line__c, woliObj.Id);
        }
        return caseLineAndWOLIMap;
    }


    private static WorkOrderLineItem populateLaborWOLIObj(WorkOrderLineItem woliObj, Case_Line__c caseLineObj) {
        woliObj.SERVICE_Case_Line__c                = caseLineObj.Id ;
        woliObj.SERVICE_Line_Price__c               = caseLineObj.Line_Price__c ;
        woliObj.SERVICE_Description__c              = caseLineObj.Description__c ;
        woliObj.SERVICE_Warranty__c                 = caseLineObj.Warranty__c ;
        woliObj.SERVICE_Task_Billing_Method__c      = caseLineObj.Task_Billing_Method__c ;
        woliObj.SERVICE_Task_Type__c                = caseLineObj.Task_Type__c ;
        woliObj.SERVICE_Service_Action__c           = caseLineObj.Service_Action__c ;
        woliObj.RecordTypeId                        = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Labor').getRecordTypeId();
        return woliObj;
    }


    private static WorkOrderLineItem populatePartsWOLIObj(WorkOrderLineItem woliObj, Case_Line__c caseLineObj) {
        woliObj.SERVICE_Case_Line__c                = caseLineObj.Id ;
        woliObj.SERVICE_Line_Price__c               = caseLineObj.Line_Price__c ;
        woliObj.SERVICE_Order_Date__c               = caseLineObj.Order_Date__c ;
        woliObj.SERVICE_Part_Ready__c               = caseLineObj.Part_Ready__c ;
        woliObj.SERVICE_Part_Source__c              = caseLineObj.Part_Source__c ;
        woliObj.RecordTypeId                        = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Parts').getRecordTypeId();
        return woliObj;
    }


    private static WorkOrderLineItem populateProductServicedWOLIObj(WorkOrderLineItem woliObj, Case_Line__c caseLineObj) {
        woliObj.SERVICE_Case_Line__c                = caseLineObj.Id ;
        woliObj.SERVICE_Brand__c                    = caseLineObj.Brand__c ;
        woliObj.SERVICE_Product__c                  = caseLineObj.Product__c ;
        woliObj.SERVICE_Issue__c                    = caseLineObj.Issue__c ;
        woliObj.SERVICE_Component__c                = caseLineObj.Component__c ;
        woliObj.SERVICE_Description__c              = caseLineObj.Description__c ;
        woliObj.SERVICE_Warranty__c                 = caseLineObj.Warranty__c ;
        woliObj.SERVICE_Second_Tech_Multiplier__c   = caseLineObj.Second_Tech_Multiplier__c ;
        woliObj.RecordTypeId                        = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Product Serviced').getRecordTypeId();
        return woliObj;
    }


    private static WorkOrderLineItem populateShippingWOLIObj(WorkOrderLineItem woliObj, Case_Line__c caseLineObj) {
        woliObj.SERVICE_Case_Line__c                = caseLineObj.Id ;
        woliObj.SERVICE_Line_Price__c               = caseLineObj.Line_Price__c ;
        woliObj.SERVICE_Description__c              = caseLineObj.Description__c ;
        woliObj.SERVICE_Warranty__c                 = caseLineObj.Warranty__c ;        
        woliObj.RecordTypeId                        = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        return woliObj;
    }


    private static void createSkillRequirement(List<WorkOrderLineItem> woliList, WorkOrder woObj) {
        Set<String> skillNameSet                = new Set<String>();
        Map<String, Id> skillMap                = new Map<String, Id>();
        List<SkillRequirement> skillReqList     = new List<SkillRequirement>();
        String laborRTId                        = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Labor').getRecordTypeId();
        for(WorkOrderLineItem woliObj : woliList) {
            if(woliObj.RecordTypeId == laborRTId && String.isNotBlank(woliObj.SERVICE_Task_Type__c)) {
                woliObj.SERVICE_Task_Type__c = woliObj.SERVICE_Task_Type__c.normalizeSpace();
                woliObj.SERVICE_Task_Type__c = woliObj.SERVICE_Task_Type__c.replaceAll(' ', '_');
                woliObj.SERVICE_Task_Type__c = woliObj.SERVICE_Task_Type__c.replaceAll('/', '_');
                woliObj.SERVICE_Task_Type__c = woliObj.SERVICE_Task_Type__c.replaceAll('-', '_');
                skillNameSet.add('SERVICE_' + woliObj.SERVICE_Task_Type__c);
            }
        }

        for(Skill skillObj : [Select Id, DeveloperName from Skill where DeveloperName IN: skillNameSet]) {
            skillMap.put(skillObj.DeveloperName , skillObj.Id);
        }

        for(WorkOrderLineItem woliObj : woliList) {
            if(woliObj.RecordTypeId == laborRTId && String.isNotBlank(woliObj.SERVICE_Task_Type__c) && skillMap.containsKey('SERVICE_' + woliObj.SERVICE_Task_Type__c)) {
                SkillRequirement skillReqObj    = new SkillRequirement();
                skillReqObj.RelatedRecordId     = woObj.Id;
                skillReqObj.SkillId             = skillMap.get('SERVICE_' + woliObj.SERVICE_Task_Type__c);
                skillReqList.add(skillReqObj);
            }
        }
        if(!skillReqList.isEmpty()) insert skillReqList;
    }


    private static List<ServiceAppointment> createSA(WorkOrder woObj, Case caseObj, Address_Assignment__c addressObj, Id territoryId) {
        List<ServiceAppointment> apptList   = new List<ServiceAppointment>();
        Integer noOfAppts = caseObj.Number_of_Technicians_Required__c != null && caseObj.Number_of_Technicians_Required__c > 0 ? Integer.valueOf(caseObj.Number_of_Technicians_Required__c) : 1;
        for(Integer i = 0; i < noOfAppts; i++) {
            ServiceAppointment saObj        = new ServiceAppointment();
            saObj.ParentRecordId            = woObj.Id;
            saObj.FSSK__FSK_Work_Order__c   = woObj.Id;
            saObj.RecordTypeId              = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Customer Service').getRecordTypeId();
            if(territoryId != null)
            saObj.ServiceTerritoryId        = territoryId;
            if(addressObj.Id != null) {
                saObj.Street                = addressObj.Address__r.Street__c;
                saObj.City                  = addressObj.Address__r.City__c;
                saObj.State                 = addressObj.Address__r.State__c;
                saObj.Country               = addressObj.Address__r.Country__c;
                saObj.PostalCode            = addressObj.Address__r.Zipcode__c;
            }
            if(partReadyDate != null){
                saObj.EarliestStartTime = partReadyDate;
                saObj.DueDate 			= saObj.EarliestStartTime.addDays(7);
            }                         
            apptList.add(saObj);
        }
        insert apptList;
        return apptList;
    }
}