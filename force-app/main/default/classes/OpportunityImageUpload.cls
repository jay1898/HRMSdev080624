public class OpportunityImageUpload {
    
	@AuraEnabled
    public static void createAttachment(String strAttachJSON,String oppId,String psiId){
       String OpId = oppId; 
       String PSIEventId = psiId ;
       system.debug('Apex->Opp Id: '+ OpId);
       system.debug('Apex->PSIID Id: '+ psiId);
       AttachClass objAttach = (AttachClass) JSON.deserialize(strAttachJSON, AttachClass.Class);
        
       Opportunity Op = [SELECT Id, PSI_Event__c,Homeowner_Docs_Added__c FROM Opportunity WHERE Id =: OpId ] ;
       Op.PSI_Event__c = psiId;
       Op.Homeowner_Docs_Added__c = true ;
       update Op;
       
       system.debug('Apex->Update PSId: '+ Op.PSI_Event__c);
        
       String base64File = EncodingUtil.urlDecode(objAttach.Body, 'UTF-8');     
       ContentVersion contentVersionRec = new ContentVersion();  
       contentVersionRec.Title = objAttach.fileName;  
       contentVersionRec.PathOnClient = '/' + objAttach.fileName;  
       contentVersionRec.FirstPublishLocationId = OpId;  
       contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);  
       contentVersionRec.IsMajorVersion = true;  
       Insert contentVersionRec; 
       system.debug('Result->conDocLink Id: '+ contentVersionRec.Id);
    }
   	public class AttachClass{
        @AuraEnabled public String fileName;
        @AuraEnabled public String contentType;
        @AuraEnabled public String Body;
    }
}