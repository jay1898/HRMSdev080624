public class CommunicationEmailService implements Messaging.InboundEmailHandler { 
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        List<Id> listOppCommIds=new List<Id>();
        Task tsk ;
        try {
            String subject = String.valueOf(email.subject)!= null? String.valueOf(email.subject): '';
            String description = String.valueOf(email.plainTextBody) != null? String.valueOf(email.plainTextBody): '';
            //System.debug('@@Sub : '+subject);
            //System.debug('@@Des : '+description);
            //System.debug('@@DesHTML : '+email.htmlBody);
            if(subject.contains('ref: ')){
                try{
                    if(subject.length() >= (subject.indexOf('ref: '))+20){
                        String recordId = subject.substring(subject.indexOf('ref: ')+5, subject.indexOf('ref: ')+20);
                        if(Schema.OpportunityCommunication__c.SObjectType==((Id)recordId).getSObjectType()){
                            tsk = new Task();
                            tsk.WhatId = recordId;
                            tsk.Subject = subject;
                            tsk.Description = description;
                            system.debug('@@Sub:recordId  :: '+recordId);
                        }
                        if(Schema.Vantage_Email__c.SObjectType==((Id)recordId).getSObjectType()){
                            tsk = new Task();
                            tsk.WhatId = recordId;
                            tsk.Subject = subject;
                            tsk.Description = description;
                            system.debug('@@Sub:recordId  :: '+recordId);
                        }
                        
                        // If Sobject Id is Opportunity then forward email to Owner Again
                        if(Schema.Opportunity.SObjectType==((Id)recordId).getSObjectType()){
                            fowardEmailToOwner(email,recordId);
                            tsk = new Task();
                            tsk.WhatId = recordId;
                            tsk.Subject = subject;
                            tsk.Description = description;
                        }
                    }
                }
                catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'CommunicationEmailService', '', subject+'--'+description, e, 'Integration' ) );}
            } 
            else if(description.contains('ref: ')){
                try{
                    if(description.length() >= (description.indexOf('ref: '))+20){
                        String recordId = description.substring(description.indexOf('ref: ')+5, description.indexOf('ref: ')+20);
                        if(Schema.OpportunityCommunication__c.SObjectType==((Id)recordId).getSObjectType()){
                            tsk = new Task();
                            tsk.WhatId = recordId;
                            tsk.Subject = subject;
                            tsk.Description = description;
                            system.debug('@@Des:recordId  :: '+recordId);
                        }
                        if(Schema.Vantage_Email__c.SObjectType==((Id)recordId).getSObjectType()){
                            tsk = new Task();
                            tsk.WhatId = recordId;
                            tsk.Subject = subject;
                            tsk.Description = description;
                            system.debug('@@Des:recordId  :: '+recordId);
                        }
                        
                        // If Sobject Id is Opportunity then forward email to Owner Again
                        if(Schema.Opportunity.SObjectType==((Id)recordId).getSObjectType()){
                            fowardEmailToOwner(email,recordId);
                            tsk = new Task();
                            tsk.WhatId = recordId;
                            tsk.Subject = subject;
                            tsk.Description = description;
                        }
                    }
                }
                catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'CommunicationEmailService', '', subject+'--'+description, e, 'Internal' ) ); }
            }
            else{
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error( 'CommunicationEmailService', '', subject+'--'+description, 'Id not Found in subject or description', 'Internal' ) 
                );
            }
            
            if(tsk!=null){
                // insert tsk;
                
                
                //  all the Opportunity communication record 
                List<OpportunityCommunication__c> oppCommList=[Select Id,Opportunity__c,Opportunity__r.ownerId,Opportunity__r.StageName from OpportunityCommunication__c where Id =:tsk.WhatId];
                if(oppCommList.size()>0){
                    tsk.OwnerId = oppCommList[0].Opportunity__r.ownerId;
                    fowardEmailToOwner(email,oppCommList[0].Opportunity__c);
                }

				List<Vantage_Email__c> vantageCommList=[Select Id,Sales_Rep_User__c from Vantage_Email__c where Id =:tsk.WhatId];
                if(vantageCommList.size()>0){
                    tsk.OwnerId = vantageCommList[0].Sales_Rep_User__c;
                    fowardEmailToSalesRep(email,vantageCommList[0].Id);
                }
                
                // check opportunity rec
                List<Opportunity> oppList=[Select Id,ownerId from Opportunity where Id =:tsk.WhatId];
                if(oppList.size()>0){
                    
                    tsk.OwnerId = oppList[0].ownerId;
                }
                
                tsk.Event_Type__c='Follow Up';
                tsk.TaskSubtype = 'Email';
                tsk.ActivityDate = Date.today();
                tsk.Status = 'Completed';
                insert tsk;
                
                if(Schema.OpportunityCommunication__c.SObjectType==(tsk.WhatId).getSObjectType()){
                    Map<Id,Opportunity> oppMap=new Map<ID,Opportunity>();
                    for(OpportunityCommunication__c oppCom : oppCommList){
                        if(!oppMap.containsKey(oppCom.Opportunity__c)){
                            // update opportunity stage to 1on1
                            Opportunity Opp=new Opportunity();
                            if(oppCom.Opportunity__r.StageName == 'Follow-Up'){
                                Opp.Communication__c='1on1';
                            }else if(oppCom.Opportunity__r.StageName == 'Rehash'){
                                Opp.rehashCommunication__c='1on1';
                            }
                            opp.Communication_1on1_Flag__c=true;
                            Opp.Id=oppCom.Opportunity__c;
                            oppMap.put(oppCom.Opportunity__c,Opp);
                        }
                    }
                    List<OpportunityCommunication__c> listOppCommToDelete=[Select Id,Opportunity__c from OpportunityCommunication__c where Opportunity__c in :oppMap.keySet() and id !=:tsk.WhatId and is_executed__c=false];
                    delete listOppCommToDelete;
                    
                    if(oppMap.values().size()>0){
                        update oppMap.values();
                    }
                }
                
                // Save attachments, if any
                List<Attachment> attachments = new List<Attachment>();
                if(email.textAttachments != null)
                {
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        Attachment attachment = new Attachment();
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = tsk.Id;
                        if(oppCommList.size()>0){
                            attachment.OwnerId = oppCommList[0].Opportunity__r.ownerId;
                        }
                        
                        attachments.add(attachment);
                    }
                }
                if(email.binaryAttachments != null)
                {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        Attachment attachment = new Attachment();
                        
                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = tsk.Id;
                        if(oppCommList.size()>0){
                            attachment.OwnerId = oppCommList[0].Opportunity__r.ownerId;
                        }
                        attachments.add(attachment);
                    }
                }
                System.debug('@attachments : ' + attachments);
                if(attachments.size() > 0)
                {
                    insert attachments;
                    System.debug('@attachments@ ' + attachments);
                }
                
            }
        }
        catch (Exception e) {
            System.debug('Query Issue: ' + e);
        }
        
        
        // Return the result for the Apex Email Service
        return result;
    }
    
    private void fowardEmailToOwner(Messaging.InboundEmail email, String oppId){
        OrgWideEmailAddress[] owea = [SELECT Id,Address FROM OrgWideEmailAddress WHERE displayName = :System.Label.Org_Wide_Communication_Email_Name];
        
        List<Opportunity> listOpp=[SELECT ID,OwnerId,Owner.Email,Email_Email_Template__c FROM Opportunity where Id=:oppId];
        if(listOpp.size()>0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            /*String[] toAddresses = new String[] {toAddress};
                mail.setToAddresses(toAddresses);*/
            mail.setTargetObjectId(listOpp[0].OwnerId);
            //mail.setSenderDisplayName('CommunicationPella');
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); 
            }
            mail.setSubject(email.subject);
            mail.setPlainTextBody(email.plainTextBody);
            mail.setHtmlBody(email.htmlBody);
            mail.setSaveAsActivity(false);
            mail.setReplyTo(listOpp[0].Email_Email_Template__c);
            //mail.setReplyTo(email.fromAddress);
            
            // Create the email attachment    
            List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
            // Save attachments, if any
            List<Attachment> attachments = new List<Attachment>();
            if(email.textAttachments != null)
            {
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(tAttachment.fileName);
                    efa.setBody(Blob.valueOf(tAttachment.body));
                    efaList.add(efa);
                }
            }
            if(email.binaryAttachments != null)
            {
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(bAttachment.fileName);
                    efa.setBody((bAttachment.body));
                    efaList.add(efa);
                }
            }
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
    private void fowardEmailToSalesRep(Messaging.InboundEmail email, String vantageSurveyId){
        OrgWideEmailAddress[] owea = [SELECT Id,Address FROM OrgWideEmailAddress WHERE displayName = :System.Label.Org_Wide_Communication_Email_Name];
        
        List<Vantage_Email__c> listOpp=[SELECT ID,Sales_Rep_User__c,Email__c FROM Vantage_Email__c where Id=:vantageSurveyId];
        if(listOpp.size()>0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            /*String[] toAddresses = new String[] {toAddress};
                mail.setToAddresses(toAddresses);*/
            mail.setTargetObjectId(listOpp[0].Sales_Rep_User__c);
            //mail.setSenderDisplayName('CommunicationPella');
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); 
            }
            mail.setSubject(email.subject);
            mail.setPlainTextBody(email.plainTextBody);
            mail.setHtmlBody(email.htmlBody);
            mail.setSaveAsActivity(false);
            String replayToEmail=listOpp[0].Email__c.split('[\\s,;]+')[0];
            mail.setReplyTo(replayToEmail);
            //mail.setReplyTo(email.fromAddress);
            
            // Create the email attachment    
            List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
            // Save attachments, if any
            List<Attachment> attachments = new List<Attachment>();
            if(email.textAttachments != null)
            {
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(tAttachment.fileName);
                    efa.setBody(Blob.valueOf(tAttachment.body));
                    efaList.add(efa);
                }
            }
            if(email.binaryAttachments != null)
            {
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(bAttachment.fileName);
                    efa.setBody((bAttachment.body));
                    efaList.add(efa);
                }
            }
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
}