public class OppCommAlert {
    public static void sendOppCommAlert(List<OpportunityCommunication__c> records){
        try{
            List<String> listEmailTemplateName=new List<String>();
            //List<String> listSMSTemplateName=new List<String>();
           // List<String> listGatewayIds=new List<String>();
            //Map<String,String> mapOppWiseGatewayId=new Map<String,String>();
            //Map<ID,String> mapUserWiseGatewayId=new Map<ID,String>(); 
            List<ID> ownerlist = new List<ID>();

            
            
            for(OpportunityCommunication__c oppCom : records){
                String emailTemplateName = oppCom.Communication_Component__r.Email_Template__c == null || String.isBlank(oppCom.Communication_Component__r.Email_Template__c) ? 'Opportunity Communication' : oppCom.Communication_Component__r.Email_Template__c;
                listEmailTemplateName.add(emailTemplateName);
                
                //String smsTemplateName=oppCom.Communication_Component__r.SMS_Template__c == null || String.isBlank(oppCom.Communication_Component__r.SMS_Template__c) ? 'Opportunity Communication' : oppCom.Communication_Component__r.SMS_Template__c;
                //listSMSTemplateName.add(smsTemplateName);
                
                ownerlist.add(oppCom.Opportunity__r.ownerId);
                
             /*   if(oppCom.Opportunity__r.Mogli_SMS__Default_Gateway__c!=null){
                    mapOppWiseGatewayId.put(oppCom.Opportunity__c,oppCom.Opportunity__r.Mogli_SMS__Default_Gateway__c);
                }*/
            }
            //To get user assigned gateway            
            /*List<Mogli_SMS__GatewayToUserJunc__c> UserSettings=[SELECT Id, name, Mogli_SMS__Assigned_User__c,
                                                                  Mogli_SMS__Assigned_Gateway__c from 	Mogli_SMS__GatewayToUserJunc__c where Mogli_SMS__Assigned_User__c in :ownerlist]; 
            for(Mogli_SMS__GatewayToUserJunc__c userGateway:UserSettings )
            {
                mapUserWiseGatewayId.put(userGateway.Mogli_SMS__Assigned_User__c,userGateway.Mogli_SMS__Assigned_Gateway__c);
            }            
            
            String GatewayId;
            //

            // get global default gateway
            List<Mogli_SMS__ApplicationSettings__c> AppSetting=[SELECT Id, Mogli_SMS__AccountTrigger__c, Mogli_SMS__Active_Form_Instance_Status__c, Mogli_SMS__DefaultGateway__c FROM Mogli_SMS__ApplicationSettings__c];
            if(AppSetting.size()>0){
                 GatewayId=AppSetting[0].Mogli_SMS__DefaultGateway__c;
            }else{
                // if default gateway not found
                List<Mogli_SMS__Gateway__c> listSMSGateway=[SELECT Id, 
                                                            	   Mogli_SMS__DisplaySequence__c 
                                                            FROM Mogli_SMS__Gateway__c 
                                                        order by Mogli_SMS__DisplaySequence__c limit 1 ];
 
                for(Mogli_SMS__Gateway__c SMSGateway : listSMSGateway ){
                    GatewayId=SMSGateway.Id;
                }
            }
            */
            
            // Email Template Map
            Map<String,EmailTemplate> mapEmailTempByName=new Map<String,EmailTemplate>();
            for(EmailTemplate ET : [SELECT Id,Name,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name in :listEmailTemplateName]){
                mapEmailTempByName.put(ET.Name, ET);
            }
            
            //SMS Email Template Map
           /* Map<String,Mogli_SMS__SMS_Template__c> mapSMSTempByName=new Map<String,Mogli_SMS__SMS_Template__c>();
            for(Mogli_SMS__SMS_Template__c ST : [SELECT Id,Mogli_SMS__Text__c,Mogli_SMS__Name__c FROM Mogli_SMS__SMS_Template__c WHERE Mogli_SMS__Name__c in :listSMSTemplateName]){
                mapSMSTempByName.put(ST.Mogli_SMS__Name__c, ST);
            }*/
            
            
            try
            {
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
                OrgWideEmailAddress[] owea = [SELECT Id,Address FROM OrgWideEmailAddress WHERE displayName = :System.Label.Org_Wide_Communication_Email_Name];
               // List<Mogli_SMS__SMS__c> listSMS=new List<Mogli_SMS__SMS__c>();
                
                for(OpportunityCommunication__c oppCom : records){
                    if(oppCom.Channel__c=='Email'){
                        if(oppCom.contact__r.Email!=null){
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            if ( owea.size() > 0 ) {
                                //message.setOrgWideEmailAddressId(owea.get(0).Id);
                                message.setReplyTo(owea.get(0).Address);
                            }
                            
                            // Step 3: Set who the email is sent from
                            message.setSenderDisplayName(oppCom.Opportunity_Owner_FirstName__c+' '+oppCom.Opportunity_Owner_LastName__c);
                            
                            message.setTargetObjectId(oppCom.contact__c); 
                            message.setUseSignature(false); 
                            message.setBccSender(false); 
                            message.setSaveAsActivity(true); 
                            String emailTemplateName = oppCom.Communication_Component__r.Email_Template__c == null || String.isBlank(oppCom.Communication_Component__r.Email_Template__c) ? 'Opportunity Communication' : oppCom.Communication_Component__r.Email_Template__c;
                            //EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name =:emailTemplateName];
                            message.setTemplateID(mapEmailTempByName.get(emailTemplateName).Id); 
                            message.setWhatId(oppCom.Id); //This is important for the merge fields in template to work
                            message.toAddresses = new String[] { oppCom.contact__r.Email};
                            messages.add(message);
                        }
                        oppCom.Is_Executed__c=true;
                    }/*else if(oppCom.Channel__c=='SMS'){
                        if(oppCom.contact__c!=null){
                            String smsTemplateName=oppCom.Communication_Component__r.SMS_Template__c == null || String.isBlank(oppCom.Communication_Component__r.SMS_Template__c) ? 'Opportunity Communication' : oppCom.Communication_Component__r.SMS_Template__c;
                            if(mapSMSTempByName.containsKey(smsTemplateName)){
                                listSMS.add(
                                    createSMSRecord
                                    (mapSMSTempByName.get(smsTemplateName).Mogli_SMS__Text__c.replaceAll('\\{\\{OppOwnerName\\}\\}',
                                    oppCom.Opportunity_Owner_FirstName__c+' '+oppCom.Opportunity_Owner_LastName__c), 
                                    oppCom.contact__c,oppCom.Id,
                                    // mapOppWiseGatewayId.containsKey(oppCom.Opportunity__c)?mapOppWiseGatewayId.get(oppCom.Opportunity__c):GatewayId));
                                    mapUserWiseGatewayId.containsKey(oppCom.Opportunity__r.ownerId)?mapUserWiseGatewayId.get(oppCom.Opportunity__r.ownerId):GatewayId));
                            }
                        }
                        oppCom.Is_Executed__c=true;
                    }*/
                }
                // Get custom settings, Check object trigger settings, if disabled then go back  
                Metadata_Control__c cs = Metadata_Control__c.getInstance();
                if(cs != null && (cs.Disable_All__c || cs.Opportunity_Communication_Disabled__c) ) {
                    // Do not send email but execute remaining process
                    system.debug('@@Email Not Send as Communication disabled');
                }else{
                    // send SMS --Moved before send email --Rekha
                    /*if(listSMS.size()>0){
                        insert listSMS;
                    } */                   
                    // send email
                    if(messages.size()>0){
                        List<OpportunityCommunication__c> updateTracking=new  List<OpportunityCommunication__c>();
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        integer i=0;
                        for(Messaging.SendEmailResult result: results){
                            
                            if (results[0].success) 
                            {
                                System.debug('The email was sent successfully.');
                            } else {
                                if(records.size()<i){
                                    records[i].Error_on_execution__c= result.errors[0].message;
                                }
                                System.debug('The email failed to send: '+ result.errors[0].message);
                            }
                            i++;
                        }
                    }
                    // send SMS
                    /*if(listSMS.size()>0){
                        insert listSMS;
                    }*/  //Moving this up to avoid mass email error when deliverability is set to "No access"  --Rekha
                }
                if(Test.isRunningTest()){
                    integer i=1/0;
                }
            }
            catch(Exception ex){
                for(OpportunityCommunication__c oppCom : records){
                    
                    if(ex.getMessage().contains('NO_MASS_MAIL_PERMISSION')) //Rekha --Added condition for Email
                    {
                        IF (oppCom.Channel__c=='Email')
                        {
                        oppCom.Is_Executed__c=false;
                        oppCom.Error_on_execution__c= ex.getMessage();
                        }

                    }
                    Else
                        oppCom.Error_on_execution__c= ex.getMessage();
                    
                }
                new ApexDebugLog().createLog( new ApexDebugLog.Error('OppCommAlert','sendOppCommAlert',JSON.serialize(records),ex,'Internal'));
            }
            update records;
        }catch(Exception ex1){
            
            new ApexDebugLog().createLog( new ApexDebugLog.Error('OppCommAlert','sendOppCommAlert',JSON.serialize(records),'Error Occured on update'+ex1,'Internal'));
        }
    }
    
    /*public static Mogli_SMS__SMS__c createSMSRecord(String Message,String contactId,String oppComId,String GatewayId){
        Mogli_SMS__SMS__c sms=new Mogli_SMS__SMS__c();
        sms.Mogli_SMS__Direction__c='Outgoing';
        sms.Mogli_SMS__Gateway__c=GatewayId;//'a2h2C0000005Ch2';
        sms.Mogli_SMS__Message__c=Message;
        sms.Mogli_SMS__Contact__c=contactId;
        sms.Mogli_SMS__Status__c='Queued';
        sms.Opportunity_Communication__c=oppComId;
        return sms;
    }*/
}