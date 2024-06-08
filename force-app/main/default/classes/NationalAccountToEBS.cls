public class NationalAccountToEBS {
    @InvocableMethod()
    public static void sendAccountDetailToEBS(List<Request> listRequest) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        for(Request req : listRequest){
            EBSRESTCallout.createCustomerEBSCallout(req.recordId);
        }
   }
    
    public with sharing class Request {
        @InvocableVariable(label='Store Account ID' required=true)
        public Id recordId;
    }
}