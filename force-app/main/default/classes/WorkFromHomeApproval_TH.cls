public without sharing class WorkFromHomeApproval_TH {
    
    public static void submitForApproval(List<Work_From_Home__c> newListwfh) {        
        // Create an approval request for Work_From_Home__c 
        for (Work_From_Home__c wfhLoop : newListwfh) {
            System.debug('Submitting newListwfh: ' + newListwfh);


            if (!String.isBlank(wfhLoop.Reason__c)) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
                req.setComments('Submitting approval request using Trigger');        
                req.setObjectId(wfhLoop.Id); // Use 'Id' instead of 'id'
                
                // Specify the name of your approval process
                req.setProcessDefinitionNameOrId('04a1s00000008YV');
                System.debug('Approval Process Name: ' + req.getProcessDefinitionNameOrId());
                // Submit the approval request for Work_From_Home__c        
                Approval.ProcessResult result = Approval.process(req);
                
                if (result.isSuccess()) {
                    System.debug('Approval process submitted successfully.');
                } else {
                    System.debug('Approval process submission failed: ' + result.getErrors()[0].getMessage());
                }
            }
        }       
    }
}