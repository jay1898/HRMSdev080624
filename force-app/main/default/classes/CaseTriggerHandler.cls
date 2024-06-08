/*
Created By      : Rahul Sangwan
Created Date    : 8 May 2023
Purpose         : This is a trigger handler for sObject Case to perform required operations.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseTriggerHandler implements ITrigger{
    
    public static Boolean RUN_TRIGGER   = true;

    public CaseTriggerHandler() {

    }

    public void bulkBefore() {
        CaseTriggerHandlerService.prepareDataBeforeEvent(Trigger.new);
    }


    public void bulkAfter() {
        CaseTriggerHandlerService.prepareDataAfterEvent(Trigger.new);
    }


    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 8 May 2023
    *   Purpose         : Method to be called on Before Insert event.
    *   Input Param     : List of Case.
    *   Output Param    : void
    */
    public void beforeInsert(List<Case> newList) {
        //assign the Case to the correct queue based on the zip code.
        CaseTriggerHandlerService.assignOwnerBasedOnZipCode(newList);
        CaseTriggerHandlerService.UpdateHasInternalComments(newList);
        CaseTriggerHandlerService.CheckCcOtherEmailAddresses(newList);
        CaseTriggerHandlerService.UpdateHasContactNotes(newList);
        CaseTriggerHandlerService.updateDescriptionOnCreationOfCase(newList);
        CaseTriggerHandlerService.CheckCaseCorporateOrBranch(newList,null);
        CaseTriggerHandlerService.updateCaseActionInfomation(newList, null);
    }


    /*
    *   Created By      : Subhash Panchani
    *   Added on        : 29 May 2023
    *   Purpose         : Method to be called on Before Update Event.
    *   Input Param     : New and Old Map of Case
    *   Output Param    : 
    */
    public void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id, SObject> oldCaseMap) {
        Map<Id,Case> oldMap = (Map<Id,Case>) oldCaseMap;
        Map<Id,Case> newMap = (Map<Id,Case>) newCaseMap;
        CaseTriggerHandlerService.caseMergeValidations(newMap.values(), oldMap);
        CaseTriggerHandlerService.caseUpdateValidations(newMap.values(), oldMap);
        CaseTriggerHandlerService.CheckCcOtherEmailAddresses(newMap.values());
        CaseTriggerHandlerService.UpdateHasContactNotes(newMap.values());
        CaseTriggerHandlerService.assignBranchBasedOnQueue(newMap, oldMap);
        CaseTriggerHandlerService.updateInvoiceCloseDate(newMap.values(), oldMap);
        CaseTriggerHandlerService.updateInternalCommentsOnCaseReopen(newMap.values(), oldMap);
        CaseTriggerHandlerService.UpdateHasInternalComments(newMap.values());
        CaseTriggerHandlerService.CheckCaseCorporateOrBranch(newMap.values(),newMap);
        CaseTriggerHandlerService.caseUpdateValidationsForClosedOrCancelledStatus(newMap, oldMap); //    DA : SCS-320/SCS-382 : 2023.07.21
        CaseTriggerHandlerService.assignBranchBasedOnContactZipCode(newMap.values(), oldMap); //SCS-1342  Update Assigned Branch on Contact Update
        //CaseTriggerHandlerService.getFirstFieldaction(newMap.values()); 
        CaseTriggerHandlerService.updateCaseActionInfomation(newMap.values(), oldMap);
       // CaseTriggerHandlerService.checkForOpenEscalationsOnCaseClose(newMap.values(), oldMap);
        system.debug('in handler');
    }


    public void beforeDelete(List<Case> oldRecords, Map<ID, SObject> oldRecordMap) {

    }

    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 23 May 2023
    *   Purpose         : Method to be called on After Insert event.
    *   Input Param     : List of Case.
    *   Output Param    : void
    */
    public void afterInsert(List<Case> newList, Map<Id, SObject> newCaseMap) {
        Map<Id,Case> newMap = (Map<Id,Case>) newCaseMap;
        CaseTriggerHandlerService.checkAndInsertContactIfNull(newList);
        //CaseTriggerHandlerService.CreateCaseStatusRecord(newList);
        CaseTriggerHandlerService.createUpdateCaseStatus(newList,null);
        CaseTriggerHandlerService.createUpdateCaseOwner(newList,null);
        //CaseTriggerHandlerService.CreateCaseQueueRecord(newList);
        try{
          //  CaseTriggerHandlerService.shareCaseWithRelatedBranches(newMap, null);
            CaseTriggerHandlerService.shareCaseWithRelatedBranches_v2(newMap, null);
           
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('CaseTriggerHandlerService', 'shareCaseWithRelatedBranches_v2', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        
    }


    public void afterUpdate(Map<Id, SObject> newCaseMap, Map<Id, SObject> oldCaseMap) {    
        Map<Id,Case> oldMap = (Map<Id,Case>) oldCaseMap;
        Map<Id,Case> newMap = (Map<Id,Case>) newCaseMap;
        
        CaseTriggerHandlerService.checkAndInsertContact(newMap);
        try{
            CaseTriggerHandlerService.shareCaseWithRelatedBranches_v2(newMap, oldMap);
           
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('CaseTriggerHandlerService', 'shareCaseWithRelatedBranches_v2', e.getMessage(), e.getStackTraceString(), 'Internal'));
        }
        CaseTriggerHandlerService.checkBranchChangeForResettingSharing(newMap, oldMap);
        CaseTriggerHandlerService.sendEmailOnCaseStatusUpdate(newMap.values(), oldMap);
        CaseTriggerHandlerService.sendEmailOnCaseStatusUpdate(newMap.values(), oldMap);
        //CaseTriggerHandlerService.CreateandUpdateCaseStatusRecord(newMap.values(),oldMap);
        CaseTriggerHandlerService.createUpdateCaseStatus(newMap.values(),oldMap);
        CaseTriggerHandlerService.createUpdateCaseOwner(newMap.values(),oldMap);
        //CaseTriggerHandlerService.CreateandUpdateQueueRecords(newMap.values(),oldMap);      
    }


    public void afterDelete(List<Case> oldRecords, Map<ID, SObject> oldRecordMap) {
    }

    public void andFinally(List<Case> newList, Map<ID, SObject> newMap) {

    }
}