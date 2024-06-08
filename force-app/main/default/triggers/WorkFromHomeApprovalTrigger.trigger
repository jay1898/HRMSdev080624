trigger WorkFromHomeApprovalTrigger on Work_From_Home__c (after insert) {
    
       if(Trigger.isAfter){ 
        //WorkFromHomeApproval_TH.submitForApproval(Trigger.new); 
    }

}