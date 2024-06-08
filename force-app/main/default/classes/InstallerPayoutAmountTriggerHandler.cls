/**
 * @description       : InstallerPayoutAmountTriggerHandler to manage related Payout AMount 
 * @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
 * @group             : eVerge
 * History 	
 * Ver   Date         Author        Modification
 * 1.0   14-03-2022    Dhruv Javiya  Initial Version()
**/
public class InstallerPayoutAmountTriggerHandler {
          
    /**
    *   @Method:        updateWOLITotalPayout
    *   @Purpose:       To update related payout Amount to parent record
    *   @Author:        Dhruv (eVerge)
    *   @Date:          03/14/2022
    *   @TaskSource:    
    
    *   @Updates:       
    */     
    public static void updateWOLITotalPayout(set<String> workOrderItemId ){
        List<WorkOrderLineItem> WOLItoUpdate = new List<WorkOrderLineItem>();
        map<String , Decimal> mapOfWOLIWiseTotalAmount = new map<String, Decimal>();
        // fetch sum of all child records payment 
        for(AggregateResult ipaTotalPayout : [SELECT SUM(Payout_Amount__c)payout,Work_Order_Line_Item__c FROM Installer_Payout_Amount__c Where Work_Order_Line_Item__c IN :workOrderItemId Group By Work_Order_Line_Item__c]){
            mapOfWOLIWiseTotalAmount.put(String.valueOf(ipaTotalPayout.get('Work_Order_Line_Item__c')),(Decimal)ipaTotalPayout.get('payout'));
        }
        // update sum in Parent records
        for(String workOrderlineId :mapOfWOLIWiseTotalAmount.keySet()){
            WorkOrderLineItem updateWOLI = new WorkOrderLineItem();
            updateWOLI.Id = workOrderlineId;
            updateWOLI.Total_Payout_Amount__c = (mapOfWOLIWiseTotalAmount.get(workOrderlineId));
            WOLItoUpdate.add(updateWOLI);
        }
        if(!WOLItoUpdate.isEmpty())
            update WOLItoUpdate;
    }
}