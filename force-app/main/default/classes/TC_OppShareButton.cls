public class TC_OppShareButton {  
    @InvocableMethod()
    public static void RunOppShare(List<Request> listRequest) {
        // Check Integration Switch settings, if disabled then go back 
        //Metadata_Control__c cs = Metadata_Control__c.getInstance();
        //if(cs != null && (cs.Disable_All__c || cs.Disable_EBS_Integration__c) ) return;
        List<Id> listOppIds=new List<Id>();
        for(Request req : listRequest){
            listOppIds.Add(req.recordId);
        }
        
        List<opportunity> lsopps = new List<opportunity>(listRequest.get(0).opplist);
        
        If (!lsopps.isEmpty())
        {
        for(Opportunity req : lsopps){
            listOppIds.Add(req.id);
        }
        }
        If (!listOppIds.isEmpty())
        {
        OpportunityRecordShare.removeShareOppWithETM(listOppIds);
        OpportunityRecordShare.shareOppRecordWithETMGroup(listOppIds);
        }
   }
    
    public with sharing class Request {
        @InvocableVariable(label='Opportunity ID')
        public Id recordId;
        @InvocableVariable
        public List<opportunity> OppList;
        
    }

}