/*
Created By      : Subhash Panchani
Created Date    : 26 June 2023
Purpose         : This is a trigger handler for Object Case_Line__c to perform required operations.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseLineTriggerHandler {
    
    public static Boolean RUN_TRIGGER   = true;
    private static CaseLineTriggerHandler handlerObj = null;
    
    private CaseLineTriggerHandler() {
        
    }
    
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 26 June 2023
*   Purpose         : Singelton Design patter applied.
*   Input Param     : 
*   Output Param    : Object of CaseLineTriggerHandler class.
*/
    public static CaseLineTriggerHandler getInstance() {
        if(handlerObj == null) return new CaseLineTriggerHandler();
        else return handlerObj;
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 26 June 2023
*   Purpose         : Method to be called on Before Insert event.
*   Input Param     : List of Case.
*   Output Param    : void
*/
    public void onBeforeInsert(List<Case_Line__c> newList) {
      //  CaseLineTriggerHandlerService.calculatorLaborEstimate(newList);
    }
    
    /*
*   Created By      : Subhash Panchani
*   Added on        : 26 June 2023
*   Purpose         : Method to be called on Before Update event.
*   Input Param     : List of Case.
*   Output Param    : void
*/
    public void onBeforeUpdate(List<Case_Line__c> newList) {
     //  CaseLineTriggerHandlerService.calculatorLaborEstimate(newList);
    }
    
    
        /*
*   Created By      : Lucas Soderstrom
*   Added on        : 6 July 2023
*   Purpose         : Method to be called on After Insert event.
*   Input Param     : List of Case.
*   Output Param    : void
*/
    public void onAfterInsert(List<Case_Line__c> newList) {
         CaseLineTriggerHandlerService.calculatorLaborEstimate(newList);
    }
    
        /*
*   Created By      : Lucas Soderstrom
*   Added on        : 6 July 2023
*   Purpose         : Method to be called on After Insert event.
*   Input Param     : List of Case.
*   Output Param    : void
*/
    public void onAfterUpdate(List<Case_Line__c> newList, Map<Id, Case_Line__c> oldMap) {
         CaseLineTriggerHandlerService.checkForUpdatedFields(newList, oldMap);
    }    
}