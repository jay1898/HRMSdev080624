/*
Created By      : Subhash Panchani
Created Date    : 26 June 2023
Purpose         : This is a Service Class for CaseLineTriggerHandler. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseLineTriggerHandlerService {
    
    /*
    Created By      : Subhash Panchani
    Created Date    : 30 June 2023
    Purpose         : this method will calculator labor estimate based on brand/product/etc inputs from the end user
    */
    public static void calculatorLaborEstimate(List<Case_Line__c> newList) {

        Set<String> branches = new Set<String>();
        Set<String> taskBillingMethods = new Set<String>();
        Set<String> taskTypes = new Set<String>();
        Set<String> serviceActions = new Set<String>();
        set<String> brands = new Set <String>(); 
        
        
        // Collect unique branch and task billing method values from the newList
        for (Case_Line__c caseLine : [Select Branch__c, Branch__r.Task_Billing_Method__c,
                                     Task_Type__c, RecordType.Name, Service_Action__c,Product_Serviced__r.Brand__c
                                     FROM Case_Line__c 
                                     WHERE Id in :newList]) {
                                         if(caseLine.RecordType.Name == 'Labor'){                         
            branches.add(caseLine.Branch__c);
            taskBillingMethods.add(caseLine.Branch__r.Task_Billing_Method__c);
            taskTypes.add(caseLine.Task_Type__c);
            serviceActions.add(caseLine.Service_Action__c);
            brands.add(caseLine.Product_Serviced__r.Brand__c);
                                         }
        }
        
        if (branches.size() > 0){ 

        // Query Service_Labor_Rate__c records based on branch and task billing method
        List<Service_Labor_Rate__c> laborRates = CaseLineTriggerHandlerModel.getLaborRates(taskBillingMethods, branches, taskTypes);

        // get map of service action name to time estimate
        Map<String, Service_Action_Estimate__c> serviceActionToEstimate = CaseLineTriggerHandlerModel.getServiceActions(serviceActions, brands);
            system.debug('123: '+ serviceActionToEstimate);
            system.debug('123brands: '+ brands);
            system.debug('123sa: '+ serviceActions);
            
        // Create a map to store the matching Service_Labor_Rate__c records
        Map<String, Service_Labor_Rate__c> laborRateMap = new Map<String, Service_Labor_Rate__c>();
      	
        for (Service_Labor_Rate__c laborRate : laborRates) {
            String key = laborRate.Branch__c + '-' + laborRate.TaskType__c;
            laborRateMap.put(key, laborRate);
        }
            
        
        
        List <Case_Line__c> caseLinesToUpdate = new List <Case_Line__c>(); 
        // Compare fields between Case_Line__c and Service_Labor_Rate__c
        for (Case_Line__c caseLine : [Select Brand__c, Product__c, Line_Price__c, Task_Billing_Method__c, Branch__r.Task_Billing_Method__c,
                                     Branch__r.Default_Labour_Rate__c, Task_Type__c, Quantity__c,Service_Action__c, Second_Tech_Multiplier__c,
                                      Product_Serviced__r.Brand__c, Product_Serviced__r.Product__c FROM Case_Line__c WHERE Id in :newList]) {
            
            String branchKey = caseLine.Branch__c;
            String billingMethodKey = caseLine.Task_Billing_Method__c;
            String taskTypeKey = caseLine.Task_Type__c;
            String key = branchKey + '-' + taskTypeKey;
            
            Service_Labor_Rate__c laborRate = laborRateMap.get(key);
                                         if(serviceActionToEstimate.get(caseLine.Service_Action__c) != null){ 
            caseLine.Estimated_Repair_Time__c = serviceActionToEstimate.get(caseLine.Service_Action__c).Estimated_Minutes__c;
            caseLine.Number_of_Techs__c = serviceActionToEstimate.get(caseLine.Service_Action__c).Number_of_Techs__c;
            caseLine.Adjusted_Repair_Time__c = serviceActionToEstimate.get(caseLine.Service_Action__c).Estimated_Minutes__c;
                                         }
            							// Check if there is matching Service Labor Rate record. If there is not, jump to calculate labor by task
                                         if (laborRate != null) {
                                             // if the branch bills by task labor and we have a matching flat rate record, use that for cost
                                             if(caseLine.Branch__r.Task_Billing_Method__c == 'Bill by Task Labor' && laborRate.Type__c == 'Flat Rate'){ 
                                                 caseLine.Line_Price__c = laborRate.LaborCost__c;
                                                 caseLine.Task_Billing_Method__c = laborRate.Type__c;
                                              // if branch bills hourly and there's a matching hourly rate record proceed to calculations. If not use default labor rate or 150
                                             } else if (caseLine.Branch__r.Task_Billing_Method__c == 'Bill by Hourly Rate' && laborRate.Type__c == 'Hourly Labor') {
                                                 caseLine.Task_Billing_Method__c = 'Hourly Labor';
                                                 // check if matching service action record. We need this record for the repair estimate
                                                 if(serviceActionToEstimate.get(caseLine.Service_Action__c) != null){ 
                                                     Integer roundedHours = Math.round((serviceActionToEstimate.get(caseLine.Service_Action__c).Estimated_Minutes__c / 30) / 2);
                                                     Decimal secondTech = caseLine.Second_Tech_Multiplier__c ? 1 : 0;
                                                     caseLine.Line_Price__c = RoundedHours * laborRate.LaborCost__c * (secondTech + 1);
                                                   //  caseLine.Estimated_Repair_Time__c = serviceActionToEstimate.get(caseLine.Service_Action__c).Estimated_Minutes__c;
                                                   //  caseLine.Number_of_Techs__c = serviceActionToEstimate.get(caseLine.Service_Action__c).Number_of_Techs__c;
                                                 }
                                             } else if(caseLine.Branch__r.Default_Labour_Rate__c != null){ 
                                                 caseLine.Line_Price__c = caseLine.Branch__r.Default_Labour_Rate__c;
                                             } else {
                                                 caseLine.Line_Price__c = 150;
                                             }   
                                         } else {
                                             Decimal totalCost = calculatorLaborByTask(caseLine);
                                             if (totalCost != null){
                                                 caseLine.Line_Price__c = totalCost; 
                                             }    
                                         }
           caseLinesToUpdate.add(caseLine);                              
        }
         update caseLinesToUpdate;
        }
    }
    
    /*
    Created By      : Lucas Soderstrom
    Created Date    : 7 July 2023
    Purpose         : this method will calculator labor estimate by Task, using brand/product/service action values
    */
    public static Decimal calculatorLaborByTask(Case_Line__c caseLine) {
        Decimal totalCost;
        Decimal secondTech = caseLine.Second_Tech_Multiplier__c ? 1 : 0;
        list <Brand_Labor_Cost__c> brandCost = [Select CostMultiplier__c FROM Brand_Labor_Cost__c WHERE Brand__c = :caseLine.Product_Serviced__r.Brand__c];
        
        list <Product_Labor_Cost__c> productCost = [Select BaseCost__c FROM Product_Labor_Cost__c WHERE Product__c = :caseLine.Product_Serviced__r.Product__c];
        
        list <Service_Action_Labor_Cost__c> serviceActionCost = [Select BaseCost__c FROM Service_Action_Labor_Cost__c WHERE Service_Action__c = :caseLine.Service_Action__c];

        if (brandCost.size() > 0 && productCost.size() > 0 && serviceActionCost.size() > 0 && (caseLine.Quantity__c != null && caseLine.Quantity__c > 0)){ 
        totalCost = caseLine.Quantity__c * brandCost[0].CostMultiplier__c * (productCost[0].BaseCost__c + serviceActionCost[0].BaseCost__c) * (secondTech + 1);
        }
        system.debug('totalTaskCost: ' + totalCost); 
        return totalCost;
    }
    
    
        /*
    Created By      : Lucas Soderstrom
    Created Date    : 30 June 2023
    Purpose         : this method will check if any fields that impact service estimates were changed on update. If they were we will pass list to calculation engine to re-calculate
    */
    public static void checkForUpdatedFields(List<Case_Line__c> newList, Map<Id, Case_Line__c> oldMap) {
        system.debug('in 1');
        List <Case_Line__c> updatedLines = new list <Case_Line__c>(); 
        List <Case_Line__c> updatedParentLines = new list <Case_Line__c>(); 
        for (Case_Line__c caseLine : [Select Quantity__c, Task_Billing_Method__c, Brand__c, Product__c,
                                      Service_Action__c, Second_Tech_Multiplier__c, Task_Type__c, RecordType.Name
                                      FROM Case_Line__c WHERE Id in :newList]){
                                          system.debug('123: ' + caseLine.Product__c);
                                          system.debug('124: ' + oldMap.get(caseLine.Id).Product__c);  
                                          system.debug('124: ' + caseLine.RecordType.Name); 
                                          if(caseLine.RecordType.Name == 'Labor' &&
                                             (caseLine.Quantity__c != oldMap.get(caseLine.Id).Quantity__c ||
                                              caseLine.Task_Billing_Method__c != oldMap.get(caseLine.Id).Task_Billing_Method__c || 
                                              caseLine.Service_Action__c != oldMap.get(caseLine.Id).Service_Action__c ||
                                              caseLine.Task_Type__c != oldMap.get(caseLine.Id).Task_Type__c ||
                                              caseLine.Second_Tech_Multiplier__c != oldMap.get(caseLine.Id).Second_Tech_Multiplier__c)){
                                                  updatedLines.add(caseLine);
                                              } else if (caseLine.RecordType.Name == 'Product Serviced' && 
                                                         (caseLine.Brand__c != oldMap.get(caseLine.Id).Brand__c ||
                                                          caseLine.Product__c != oldMap.get(caseLine.Id).Product__c)){
                                                              updatedParentLines.add(caseLine);
                                                          }
                                      }
        
        if (!updatedParentLines.isEmpty()){
            for (Case_Line__c csLine : [Select Quantity__c, Task_Billing_Method__c, Brand__c, Product__c,
                                        Service_Action__c, Second_Tech_Multiplier__c, RecordType.Name
                                        FROM Case_Line__c 
                                        WHERE RecordType.Name = 'Labor'
                                        AND Product_Serviced__c in :updatedParentLines]){
                                            updatedLines.add(csLine);
                                        } 
        }
        system.debug('updatedLines: ' + updatedLines);
        if (!updatedLines.isEmpty()){
            calculatorLaborEstimate(updatedLines);
        }
    }
}