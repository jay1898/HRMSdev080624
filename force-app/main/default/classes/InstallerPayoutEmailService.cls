/**
 * @description       : InstallerPayoutEmailService to manage email response
 * @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
 * @group             : eVerge
 * History 	
 * Ver   Date         Author        Modification
 * 1.0   08-03-2022    Dhruv Javiya  Initial Version()
**/
public class InstallerPayoutEmailService implements Messaging.InboundEmailHandler { 
          
    /**
    *   @Method:        handleInboundEmail
    *   @Purpose:       To update the service territory on WOLI based on the postal code
    *   @Author:        Dhruv (eVerge)
    *   @Date:          03/08/2022
    *   @TaskSource:    
    
    *   @Updates:       
    */     
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        List<Id> listOppCommIds=new List<Id>();
        Task tsk ;
        try {
            String subject = String.valueOf(email.subject)!= null? String.valueOf(email.subject): '';
            String description = String.valueOf(email.plainTextBody) != null? String.valueOf(email.plainTextBody): '';
            String descriptionhtmlBody = String.valueOf(email.htmlBody) != null? String.valueOf(email.htmlBody).stripHtmlTags(): '';
            String recordId;
            if(subject.contains('ref: ')){
                try{
                    if(subject.length() >= (subject.indexOf('ref: '))+20){
                        recordId = subject.substring(subject.indexOf('ref: ')+5, subject.indexOf('ref: ')+20);
                    }
                }
                catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'CommunicationEmailService', '', subject+'--'+description, e, 'Integration' ) );}
            } 
            else if(description.contains('ref: ')){
                try{
                    if(description.length() >= (description.indexOf('ref: '))+20){
                        recordId = description.substring(description.indexOf('ref: ')+5, description.indexOf('ref: ')+20);
                        
                    }
                }
                catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'CommunicationEmailService', '', subject+'--'+description, e, 'Internal' ) ); }
            }else if(descriptionhtmlBody.contains('ref: ')){
                try{
                    if(descriptionhtmlBody.length() >= (descriptionhtmlBody.indexOf('ref: '))+20){
                        recordId = descriptionhtmlBody.substring(descriptionhtmlBody.indexOf('ref: ')+5, descriptionhtmlBody.indexOf('ref: ')+20);
                        description=descriptionhtmlBody;
                    }
                }
                catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'CommunicationEmailService', '', subject+'--'+descriptionhtmlBody, e, 'Internal' ) ); }
            }
            else{
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error( 'CommunicationEmailService', '', subject+'--'+description, 'Id not Found in subject or description', 'Internal' ) 
                );
            }
            
            if(recordId!=null){
                
				List<String> listApproveString=Label.InstallerPayoutEmailServiceAccept.split(',');
                List<String> listRejectString=Label.InstallerPayoutEmailServiceReject.split(',');
               // Check record id is of WorkOrderLineItem
               // If yes then update status
                if(recordId.startsWithIgnoreCase('1WL')){
                    List<WorkOrderLineItem> WOLI=[SELECT ID,Status__c,Installer_Comments__c FROM WorkOrderLineItem Where Id=:recordId and Status__c='Pending Approval'];
                    if(WOLI.size()>0){
                        List<String> DescriptionLines=description.trim().split('\n');
                        if(DescriptionLines.size()>0 && DescriptionLines[0]==''){
                            DescriptionLines.remove(0);
                        }
                        if(DescriptionLines.size()>0){
                            // Update the Record Status Based On Response
                            for(String approval : listApproveString){
                                if(DescriptionLines[0].trim().startsWithIgnoreCase(approval)){
                                    WOLI[0].Status__c='Approved';
                                }
                            }
                            for(String reject : listRejectString){
                                if(DescriptionLines[0].trim().startsWithIgnoreCase(reject)){
                                    WOLI[0].Status__c='Rejected';
                                    WOLI[0].Lock_Payout_Transaction__c=false;
                                }
                            }
                            if(DescriptionLines.size()>1){
                                WOLI[0].Installer_Comments__c=DescriptionLines[1];
                            }
                            if(WOLI[0].Status__c!='Approved' && WOLI[0].Status__c!='Rejected'){
                                WOLI[0].Status__c='Inquiry';
                                WOLI[0].Lock_Payout_Transaction__c=false;
                                if(DescriptionLines.size()>0){
                                    WOLI[0].Installer_Comments__c=DescriptionLines[0];
                                }
                            }
                            Update WOLI[0];
                        } 
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('Query Issue: ' + e);
        }
        
        
        // Return the result for the Apex Email Service
        return result;
    }
    
}