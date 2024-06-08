public class PiesCreateWorkPermitController {
    
    @AuraEnabled(cacheable=true)
    public static WorkOrder getWorkOrder_Server(Id woId) {
        // return [SELECT Id, City, State, Branch__c, Branch__r.Name, (SELECT Id, Name, Template__c FROM Work_Permits__r) FROM WorkOrder WHERE Id =: woId];
        return [SELECT Id, City, State, Country, Branch__c, Branch__r.Name, AccountId FROM WorkOrder WHERE Id =: woId];
    } 
    //@AuraEnabled(cacheable=true)
    public static Set<Id> getWorkTemplatesInUse_Server(Id woId) {
        List<Work_Permit__c> lstWPQueried = [SELECT Id, Template__c FROM Work_Permit__c WHERE Work_Order__c =: woId];
        Set<Id> setTemplatesIds = new Set<Id>();
        for(Work_Permit__c iterWP: lstWPQueried) {
            if(iterWP.Template__c != null) {
                setTemplatesIds.add(iterWP.Template__c);
            }
        }
        //return JSON.serialize(setTemplatesIds);
        return setTemplatesIds;
    } 

    // @AuraEnabled(cacheable=true)
    @AuraEnabled
    public static List<WorkTemplateWrap> getTemplates_Server(String strBranch, String strName, String strState, String strCity, String strCounty, Id woId) {
        //return [SELECT Id, Name, City__c, State__c, County__c, Branch__c FROM Work_Permit_Template__c];
        String strQuery = 'SELECT Id, Work_Permit_Template_Name__c, City__c, State__c, County__c, Branch__c FROM Work_Permit_Template__c WHERE Branch__c =: strBranch ';
        if(String.isNotBlank(strName)) {
            strQuery += 'AND Work_Permit_Template_Name__c LIKE \'%'+ strName +'%\'';
        }
        if(String.isNotBlank(strState)) {
            strQuery += 'AND State__c LIKE \'%'+ strState +'%\'';
        }
        if(String.isNotBlank(strCity)) {
            strQuery += 'AND City__c LIKE \'%'+ strCity +'%\'';
        }
        if(String.isNotBlank(strCounty)) {
            strQuery += 'AND County__c LIKE \'%'+ strCounty +'%\'';
        }
        List<Work_Permit_Template__c> lstWT = Database.query(strQuery);

        Set<Id> setTemplatesIdsInUse = getWorkTemplatesInUse_Server(woId);
        List<WorkTemplateWrap> lstWrap = new List<WorkTemplateWrap>();
        for(Work_Permit_Template__c iterWT: lstWT) {
            WorkTemplateWrap objWrap = new WorkTemplateWrap();
            objWrap.strId = iterWT.Id;
            objWrap.strName = iterWT.Work_Permit_Template_Name__c;
            objWrap.strCity = iterWT.City__c;
            objWrap.strState = iterWT.State__c;
            objWrap.strCounty = iterWT.County__c;
            if(setTemplatesIdsInUse.contains(iterWT.Id)) {
                objWrap.bolAlreadySelected = true;
            } else {
                objWrap.bolAlreadySelected = false;
            }
            lstWrap.add(objWrap);
        }
        system.debug('lstWrap--'+lstWrap);
        return lstWrap;

    }
    @AuraEnabled
    public static String createWorkPermits_Server(String strSelectedTemplateIds, WorkOrder wo) {
        // List<Work_Permit_Template__c> lstTemplates = (List<Work_Permit_Template__c>) JSON.deserialize(strTemplates, List<Work_Permit_Template__c>.class);
        Set<Id> setTemplateId = ( Set<Id>) JSON.deserialize(strSelectedTemplateIds, Set<Id>.class);
        Map<Id, Work_Permit_Template__c> mapTemplates = new Map<Id, Work_Permit_Template__c>((List<Work_Permit_Template__c>)Database.query('SELECT Id, Work_Permit_Template_Name__c, Special_Instructions__c, Contact_Info__c, County__c FROM Work_Permit_Template__c WHERE Id IN: setTemplateId '));
        List<Work_Permit__c> lstWorkPermitsToCreate = new List<Work_Permit__c>();
        for(Id templateId: setTemplateId) {
            Work_Permit_Template__c objTemplate = mapTemplates.get(templateId);
            Work_Permit__c objWP = new Work_Permit__c();
            objWP.Work_Permit_Name__c = objTemplate.Work_Permit_Template_Name__c + ' Permit';
            objWP.Status__c = 'Open';
            objWP.Template__c = objTemplate.Id;
            objWP.Work_Order__c = wo.Id;
            objWP.State__c = wo.State;
            objWP.City__c = wo.City;
            objWP.County__c = objTemplate.County__c ;  //wo.Country;
            objWP.Account__c = wo.AccountId;
            objWP.Contact_Info__c = objTemplate.Contact_Info__c;
            
            objWP.Special_Instructions__c = objTemplate.Special_Instructions__c;

            lstWorkPermitsToCreate.add(objWP);
        }
        if(lstWorkPermitsToCreate != null && ! lstWorkPermitsToCreate.isEmpty()) {
            insert lstWorkPermitsToCreate;
        }
        return JSON.serialize(lstWorkPermitsToCreate);
    } 

    public class WorkTemplateWrap {

        @AuraEnabled public String  strId{get;set;}
        @AuraEnabled public String  strName{get;set;}
        @AuraEnabled public String  strCity{get;set;}
        @AuraEnabled public String  strState{get;set;}
        @AuraEnabled public String  strCounty{get;set;}
        @AuraEnabled public Boolean  bolAlreadySelected{get;set;}
    }
}