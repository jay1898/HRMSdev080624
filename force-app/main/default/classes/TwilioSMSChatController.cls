/**
* @description       : TwilioSMSChatController Used to hande twillio Chatter
* @author            : Dhruv Javiya | mailto:javiyad@evergegroup.com
* History   
* Ver   Date         Author        Modification
* 1.0   26-03-2023   Dhruv Javiya  Initial Version()
**/
public class TwilioSMSChatController {

    @AuraEnabled
    public static List<TwilioMessage__c> getSMSRecords(String recordId,String topic) {
        return [select Id,CreatedDate,LastModifiedDate,  Direction__c, MessageBody__c,  Phone__c,Topic__c,Callback_Status__c from TwilioMessage__c Where Topic__c=:topic and (ParentID__c=:recordId or Opportunity__c=:recordId)  Order by createddate asc];
    }
    
    @AuraEnabled
    public static String enableSendSMS(String recordId) {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        List<PermissionSetAssignment> lstPSA = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
                                                FROM PermissionSetAssignment 
                                                WHERE PermissionSet.Name = : Label.Send_Outbound_CRM_SMS_Permission_Set 
                                                AND AssigneeId=:Userinfo.getUserId()];
        if(lstPSA.size() > 0){
            List<Opportunity> listOpp=[SELECT ID,OwnerId,Account.Phone,Zone__r.ParentTerritory.Branch__r.Enable_SMS_Feature__c,First_SMS_Replied__c FROM Opportunity where id=:recordId and Account.Phone!=null and stagename not in ('Closed','Closed Won','Closed Fulfillment') and RecordType.DeveloperName='Replacement'];
            if(listOpp.size()>0){
                if(listOpp[0].OwnerId!=Userinfo.getUserId() &&  profileName != Label.Send_Outbound_CRM_SMS_Profile){
                      return 'DISABLED_REPLY';
                }
                System.debug('listOpp[0].Zone__r.ParentTerritory.Branch__r.Enable_SMS_Feature__c: ' + listOpp[0].Zone__r.ParentTerritory.Branch__r.Enable_SMS_Feature__c);
                if(listOpp[0].Zone__r.ParentTerritory.Branch__r.Enable_SMS_Feature__c){
                    if(listOpp[0].First_SMS_Replied__c!=null && (listOpp[0].First_SMS_Replied__c.equalsIgnoreCase('Y') || listOpp[0].First_SMS_Replied__c.equalsIgnoreCase('YES')) ){
                        return 'ENABLED_REPLY';
                    }
                    List<TwilioMessage__c> listSMS=[select Id,CreatedDate,LastModifiedDate,  Direction__c, MessageBody__c,  Phone__c,Topic__c from TwilioMessage__c Where Topic__c='Survey' and (ParentID__c=:recordId or Opportunity__c=:recordId)  Order by createddate asc];
                    for(TwilioMessage__c SMS: listSMS ){
                        if(SMS.Direction__c=='Inbound'){
                            if((SMS.MessageBody__c.equalsIgnoreCase('Y') || SMS.MessageBody__c.equalsIgnoreCase('YES'))){
                                return 'ENABLED_REPLY';
                            }
                            break;
                        }
                    }
                    
                }else{
                    List<TwilioMessage__c> listSMS=[select Id,CreatedDate,LastModifiedDate,  Direction__c, MessageBody__c,  Phone__c,Topic__c from TwilioMessage__c Where Topic__c='Survey' and (ParentID__c=:recordId or Opportunity__c=:recordId)  Order by createddate asc];
                    if(listSMS.size()==0){
                        return 'FIRST_QUALIFICATION_SMS';
                    }else{
                        for(TwilioMessage__c SMS: listSMS ){
                            if(SMS.Direction__c=='Inbound'){
                                if((SMS.MessageBody__c.equalsIgnoreCase('Y') || SMS.MessageBody__c.equalsIgnoreCase('YES'))){
                                    return 'ENABLED_REPLY';
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }
        return 'DISABLED_REPLY';
    }

    @AuraEnabled
    public static Datetime sendFirstSMSRecord(String topic, String body , String recordId) {
       
        List<Opportunity> listOpp=[SELECT ID,Account.Phone,Zone__r.ParentTerritory.Branch__c FROM Opportunity where id=:recordId and Account.Phone!=null and stagename not in ('Closed','Closed Won','Closed Fulfillment')];
        if(listOpp.size()>0){
            SendSMSFlowAction.TwilioSmsFlowInput TW=new SendSMSFlowAction.TwilioSmsFlowInput();
            TW.toNum=listOpp[0].Account.Phone;
            TW.topic=topic;
            TW.recordId=listOpp[0].Id;
            TW.branchId=listOpp[0].Zone__r.ParentTerritory.Branch__c;
            TW.isFirstSMS=true;
            SendSMSFlowAction.sendNextSMS(new List<SendSMSFlowAction.TwilioSmsFlowInput>{TW});
        }else {
             throw new AuraHandledException('OPP_CLOSE_ERROR');
        }
          
         return Datetime.now();
    }
    @AuraEnabled
    public static Datetime createSMSRecord(String topic, String body , String recordId) {
        
        List<Opportunity> listOpp=[SELECT ID,Account.Phone FROM Opportunity where id=:recordId and Account.Phone!=null and stagename not in ('Closed','Closed Won','Closed Fulfillment')];
        if(listOpp.size()>0){
            TwilioMessenger.sendLightningMessage(listOpp[0].Account.Phone, body, topic, recordId);
            listOpp[0].Last_SMS_Send__c=true;
            Update listOpp[0];
        }else{
            throw new AuraHandledException('OPP_CLOSE_ERROR');
        }
        return Datetime.now();
        
    }
}