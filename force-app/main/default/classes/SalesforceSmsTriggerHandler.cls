/**
*   @Purpose:       Trigger handler class behind Salesforce SMS (TwilioMessage__c) trigger 
*   @Author:       	Heena (eVerge)
*   @Date:      	 09/07/2022
*   @TaskSource:    

*   @Updates:       
*/
public class SalesforceSmsTriggerHandler {
    
    public static void triggerSMSCreateEvent(List<TwilioMessage__c> messages){
        List<Twilio_Message_Event__e> TMEList=new List<Twilio_Message_Event__e>();
        Set<Id> setOfOppIds = new Set<Id>();
        for(TwilioMessage__c message : messages){
            if(message.Opportunity__c!=null){
                Twilio_Message_Event__e TME=new Twilio_Message_Event__e();
                TME.RecordId__c = message.Opportunity__c;
                TMEList.add(TME);
                if(message.Direction__c == 'Inbound'){
                    setOfOppIds.add(message.Opportunity__c);
                }
            }
        }
        if(TMEList.size()>0){
            EventBus.publish(TMEList); 
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [select Id, Name from EmailTemplate where DeveloperName =: Label.SMS_Email_Template_Name];
        List<CustomNotificationType> TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName=:Label.SMS_Custom_Notification_Name];
        for(TwilioMessage__c objTM : [select Id,Opportunity__c, Opportunity__r.Owner.Email,Opportunity__r.Owner.Id, Phone__c, Opportunity__r.name,Callback_Status__c,MessageBody__c,Direction__c FROM TwilioMessage__c 
                                      WHERE id In :messages AND Direction__c = 'Inbound' AND Opportunity__c!=null and Topic__c='Survey' ORDER BY CreatedDate desc])
        {
          	Messaging.SingleEmailMessage email = 
            Messaging.renderStoredEmailTemplate(et.Id, objTM.Opportunity__r.Owner.Id, objTM.Opportunity__c);
            email.setSaveAsActivity(false);
            emails.add(email); 

            Set<String> users = new Set<String>();
            users.add(objTM.Opportunity__r.Owner.Id);
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
            // Set the contents for the delinking notification
            currNotification.setTitle(Label.SMS_Push_Notification_Title);
            currNotification.setBody(objTM.Opportunity__r.name);
            currNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);
            currNotification.setTargetId(objTM.Opportunity__c);
            // Send the notification
            try {
                currNotification.send(users);
            }
            catch (Exception ex) {
                System.debug('Notification Failed: ' + ex.getMessage());
            }            
        }
        system.debug('emails: '+emails);
        if(emails.size()>0){
            try{
                // Send the email using the Email Service
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                // Check for errors and handle them as needed
                if (results[0].isSuccess()) {
                    System.debug('Email sent successfully.');
                } else {
                    System.debug('Email failed to send: ' + results[0].getErrors()[0].getMessage());
                }
                
            }catch (System.NoAccessException e) {
                
            }catch (Exception e){
                
            }
        }
        
        
        
        
    }
    public static void SMSRecordShare(List<TwilioMessage__c> messages, Map<Id,TwilioMessage__c> oldMap){
        
        List<Id> MsgIdstoShare = new List<Id>();
        List<Id> removeMsgIdstoShare = new List<Id>();        
        for(TwilioMessage__c msg : messages)
        {
            MsgIdstoShare.add(msg.Id);         
        }        
        if(MsgIdstoShare.size()>0){
            SMSRecordShare.shareSMSRecordWithETMGroup(MsgIdstoShare);
        }   
        
    }
}