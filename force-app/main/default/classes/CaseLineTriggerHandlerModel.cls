/*
Created By      : Subhash Panchani
Created Date    : 26 June 2023
Purpose         : This is a Model Class for CaseLineTriggerHandler. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseLineTriggerHandlerModel {
    public static List<Service_Labor_Rate__c> getLaborRates(Set<String> taskBillingMethods, Set<String> branches, Set <String>taskTypes) {
        return [SELECT Branch__c, TaskType__c, Type__c, LaborCost__c FROM Service_Labor_Rate__c WHERE Branch__c IN :branches AND TaskType__c IN :taskTypes];
    }
    
    public static Map<String, Service_Action_Estimate__c> getServiceActions(Set<String> serviceActions, Set<String> brands) {
        Map <String, Service_Action_Estimate__c> serviceActionMap = new Map <String, Service_Action_Estimate__c>(); 
        for (Service_Action_Estimate__c servAction : [SELECT Estimated_Minutes__c, Number_of_Techs__c, Service_Action__r.Service_Action__c 
                                                      FROM Service_Action_Estimate__c 
                                                      WHERE Service_Action__r.Service_Action__c IN :serviceActions
                                                     AND Brand__r.Brand__c in :brands]){
                                                          if (servAction.Service_Action__r.Service_Action__c != null){ 
                                                          serviceActionMap.put(servAction.Service_Action__r.Service_Action__c, servAction);
                                                          }
                                                      }
        return serviceActionMap;
    }
}