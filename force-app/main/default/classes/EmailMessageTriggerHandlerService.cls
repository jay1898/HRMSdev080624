public class EmailMessageTriggerHandlerService {
    public static void checkIsCommingBeforeUpdate(List<EmailMessage> NewListEmailMessage) {
        try {
            
            //collect all cases whose incoming is true
            Set<Id> caseToProceed = new Set<Id>();
            for(EmailMessage em : NewListEmailMessage){
                if(em.Incoming == true)
                    caseToProceed.add(em.ParentId);
            }
            //get all the valid cases collected above
            List<Case> caseData = EmailMessageTriggerHandlerModel.getCaseRecord(caseToProceed);
            List<Case> caseToUpdate = new List<Case>();
            List<Case> caseWithCompleteStatus = new List<Case>();
            Map<Id, Case> caseWithCompleteStatusMap = new Map<Id, Case>();
            Map<Id, Decimal> caseWithAmountMap = new Map<Id, Decimal>();
            Map<Id,Case> caseChildcaseMap = new Map<Id,Case>();
            //for SCS-726
            List<Case> childCaseListForInvoicingFlagTrue = new List<Case>();
            
            for(Case caseObj : caseData){
                if(caseObj.Status == Constant.CASE_STATUS_COMPLETED && caseObj.Send_To_Invoicing__c==true){
                    System.debug('Inside Child Case');
                    Case childCase = new Case();
                    childCase.ContactId = caseObj.ContactId;
                    childCase.Has_Awaiting_Parts_Alert__c = true;
                    childCase.Internal_Comments__c = 'Response on Billable Case: Please review original Case ' + String.valueOf(caseObj.CaseNumber) + '\n' +  String.valueOf( caseObj.Internal_Comments__c != null ? caseObj.Internal_Comments__c : '');
                    childCase.OwnerId = caseObj.OwnerId;
                    childCase.ParentId = caseObj.Id;
                    childCase.Status = Constant.CASE_STATUS_PENDING;
                    childCaseListForInvoicingFlagTrue.add(childCase);
                    caseChildcaseMap.put(caseObj.Id,childCase); 
                }
                else if(caseObj.Status == Constant.CASE_STATUS_COMPLETED){
                    caseWithCompleteStatus.add(caseObj); //collect case
                    caseWithCompleteStatusMap.put(caseObj.Id, caseObj);
                }
            }
            
            System.debug('Inside Child Case' + childCaseListForInvoicingFlagTrue);
            if(childCaseListForInvoicingFlagTrue.size() > 0){
                insert childCaseListForInvoicingFlagTrue;
            }
            
            for(EmailMessage em : NewListEmailMessage){
                if(caseChildcaseMap.containskey(em.ParentId)){
                    Id newParentId =  caseChildcaseMap.get(em.ParentId).Id;
                    em.ParentId = newParentId;
                    em.RelatedToId = newParentId;
                }
            }
            
            //return if no cases with status - completed
            if(caseWithCompleteStatus.size() == 0){
                System.debug('No cases found with status - completed... aboriting...');
                return;
            }
            
            
            //get case__c from case line 
            List<Case_Line__c> caseLineData= EmailMessageTriggerHandlerModel.getCaseLineRecord(caseWithCompleteStatusMap.keySet());
            Decimal totalAmount = 0.0;
            for(Case_Line__c caseLineObj : caseLineData){
                if(caseLineObj.Line_Price__c != null){
                    if(caseWithAmountMap.containsKey(caseLineObj.Case__c)){
                        caseWithAmountMap.put(caseLineObj.Case__c, caseWithAmountMap.get(caseLineObj.Case__c) + caseLineObj.Line_Price__c);
                    }else{
                        caseWithAmountMap.put(caseLineObj.Case__c, caseLineObj.Line_Price__c);
                    }
                    totalAmount += caseLineObj.Line_Price__c;
                }
            }
            
            List<Case> childCaseList = new List<Case>();
            
            
            for(Id caseId : caseWithAmountMap.keySet()){
                if(caseWithAmountMap.get(caseId) != 0){
                    if(caseWithCompleteStatusMap.containsKey(caseId)){
                        Case parentcaserecord = caseWithCompleteStatusMap.get(caseId);
                        Case childCase = new Case();
                        childCase.ContactId = parentcaserecord.ContactId;
                        childCase.Has_Awaiting_Parts_Alert__c = true;
                        childCase.Internal_Comments__c = 'Response on Billable Case: Please review original Case' + String.valueOf(parentcaserecord.CaseNumber) + '\n' +  String.valueOf( parentcaserecord.Internal_Comments__c != null ? parentcaserecord.Internal_Comments__c : '');
                        childCase.OwnerId = parentcaserecord.OwnerId;
                        childCase.ParentId = parentcaserecord.Id;
                        childCase.Status = Constant.CASE_STATUS_PENDING;
                        childCase.Subject = 'RE-OPENED : ' + String.valueOf(parentcaserecord.Subject != null ? parentcaserecord.Subject : '');
                        childCaseList.add(childCase);
                        caseChildcaseMap.put(caseId,childCase); 
                    }   
                }
            }
            
            if(childCaseList.size() > 0){
                insert childCaseList;
            }
            
            
            for(EmailMessage em : NewListEmailMessage){
                if(caseChildcaseMap.containskey(em.ParentId)){
                    Id newParentId =  caseChildcaseMap.get(em.ParentId).Id;
                    em.ParentId = newParentId;
                    em.RelatedToId = newParentId;
                }
            }
        }  catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
        }
        
    }
    
    /*public static void MailMergeCaseProcessor (List<EmailMessage> NewListEmailMessage) {
try {


//collect all cases whose incoming is true
Set<Id> caseToProceed = new Set<Id>();
for(EmailMessage em : NewListEmailMessage){
if(em.Incoming == true)
caseToProceed.add(em.ParentId);
}

//get all the valid cases collected above
List<Case> caseData = EmailMessageTriggerHandlerModel.getCaseRecord(caseToProceed);
List<String> parentIds = new List<String>();
Map<Id, Case> caseWithMergedStatusMap = new Map<Id, Case>();

for(Case caseObj : caseData){
if(caseObj.Status == Constant.CASE_STATUS_MERGED){
parentIds.add(caseObj.ParentId); //collect case
caseWithMergedStatusMap.put(caseObj.Id, caseObj);
}
}

List<Case> parentCaseData = EmailMessageTriggerHandlerModel.getParentCaseRecords(parentIds);
Map<Id, Case> parentMap = new Map<Id, Case>(parentCaseData);

//get case__c from case line 
List<Case_Line__c> caseLineData= EmailMessageTriggerHandlerModel.getParentCaseLineRecord(parentIds);
Map<String, List<Case_Line__c>> caseToCaseLineMap = new Map<String, List<Case_Line__c>>();

for(Case_Line__c caseLine : caseLineData){
if(caseToCaseLineMap.containsKey(caseLine.Case__c)){
caseToCaseLineMap.get(caseLine.Case__c).add(caseLine);
}else{
caseToCaseLineMap.put(caseLine.Case__c, new List<Case_Line__c>{caseLine});
}
}

List<Case> caseListToUpdate = new List<Case>();

for(Case parentCase : parentCaseData){
if ( parentCase.Status == Constant.CASE_STATUS_COMPLETED ){
caseListToUpdate.add( caseCompletedProcessor(parentCase,caseToCaseLineMap) );
}else if ( parentCase.Status == Constant.CASE_STATUS_CANCELLED ){
caseListToUpdate.add( caseCancelledProcessor(parentCase) );
}else if ( parentCase.Status == Constant.CASE_STATUS_CLOSED ){
caseListToUpdate.add( caseClosedProcessor(parentCase) );
}else if ( parentCase.Status == Constant.CASE_STATUS_AWAITING_PART_ORDER ){
caseListToUpdate.add( parentCase );
}else{
caseListToUpdate.add( caseOtherProcessor(parentCase) );
}
}

if(caseListToUpdate.size() > 0){
upsert caseListToUpdate;
}

Map<String, Case> parentChildMap = new Map<String, Case>();

for(Case updatedCase : caseListToUpdate){
parentChildMap.put(updatedCase.ParentId, updatedCase);
}

for(EmailMessage em : NewListEmailMessage){

if(caseWithMergedStatusMap.containsKey(em.ParentId)){
Case emailCase = caseWithMergedStatusMap.get(em.ParentId);
if(parentChildMap.containsKey(emailCase.ParentId)){
Id newParentId =  parentChildMap.get(emailCase.ParentId).Id;
em.ParentId = newParentId;
em.RelatedToId = newParentId;
}else{
Id newParentId =  emailCase.ParentId;
em.ParentId = newParentId;
em.RelatedToId = newParentId;
}
}
}
}  catch(Exception ex){
System.debug(ex.getMessage());
System.debug(ex.getLineNumber());
}
}*/
    
    public static void MailMergeCaseProcessorForClosedCase ( List<EmailMessage> NewListEmailMessage ) {
        
        Map<String, String> principalMergedCaseMap = new Map<String, String>();
        for(EmailMessage em : NewListEmailMessage){
            String mergedCaseId = getCaseIDFromEmailThreadId(em.Subject);
            if(em.ParentId != mergedCaseId){
                principalMergedCaseMap.put(mergedCaseId, em.ParentId);
            }
        }
        
        List<Case> mergedCaseList = EmailMessageTriggerHandlerModel.getMergedCaseRecords(principalMergedCaseMap.keyset());
        List<Case> principalCaseList = EmailMessageTriggerHandlerModel.getParentCaseRecords(principalMergedCaseMap.values());
        Map<Id, Case> principalCaseMap = new Map<Id, Case>(principalCaseList);
        List<Case> caseListToUpdate = new List<Case>();
        
        List<Case_Line__c> caseLineData= EmailMessageTriggerHandlerModel.getParentCaseLineRecord(principalMergedCaseMap.values());
        Map<String, List<Case_Line__c>> caseToCaseLineMap = new Map<String, List<Case_Line__c>>();
        
        for(Case_Line__c caseLine : caseLineData){
            if(caseToCaseLineMap.containsKey(caseLine.Case__c)){
                caseToCaseLineMap.get(caseLine.Case__c).add(caseLine);
            }else{
                caseToCaseLineMap.put(caseLine.Case__c, new List<Case_Line__c>{caseLine});
            }
        }
        
        for(Case mergedCase : mergedCaseList){
            if(principalMergedCaseMap.containsKey(mergedCase.Id)){
                
                String principalCaseId = principalMergedCaseMap.get(mergedCase.Id);
                
                if(principalCaseMap.containsKey(principalCaseId)){
                    Case PrincipalCase = principalCaseMap.get(principalCaseId);
                    
                    if ( PrincipalCase.Status == Constant.CASE_STATUS_COMPLETED ){
                        caseListToUpdate.add( caseCompletedProcessor(PrincipalCase,caseToCaseLineMap) );
                    }else if ( PrincipalCase.Status == Constant.CASE_STATUS_CANCELLED ){
                        caseListToUpdate.add( caseCancelledProcessor(PrincipalCase) );
                    }else if ( PrincipalCase.Status == Constant.CASE_STATUS_CLOSED ){
                        caseListToUpdate.add( caseClosedProcessor(PrincipalCase) );
                    }else if ( PrincipalCase.Status == Constant.CASE_STATUS_AWAITING_PART_ORDER ){
                        caseListToUpdate.add( PrincipalCase );
                    }else{
                        caseListToUpdate.add( caseOtherProcessor(PrincipalCase) );
                    }
                }
                
            }
        }
        
        if(caseListToUpdate.size() > 0){
            Boolean CaseTriggerFlag = CaseTriggerHandler.RUN_TRIGGER;
            CaseTriggerHandler.RUN_TRIGGER = false;
            upsert caseListToUpdate;
            CaseTriggerHandler.RUN_TRIGGER = CaseTriggerFlag;
        }
        
        for(Case c : caseListToUpdate){
            System.debug(' CaseNumber ' + c.Id);
        }
        
        Map<String, Case> parentChildMap = new Map<String, Case>();
        
        for(Case updatedCase : caseListToUpdate){
            parentChildMap.put(updatedCase.ParentId, updatedCase);
        }
        
        for(EmailMessage em : NewListEmailMessage){
            if(parentChildMap.containskey(em.ParentId)){
                Id newParentId =  parentChildMap.get(em.ParentId).Id;
                em.ParentId = newParentId;
                em.RelatedToId = newParentId;
            }
        }
        
        
    }
    
    public static String getCaseIDFromEmailThreadId (String emailSubject){
        
        Matcher matcher = Pattern.compile('ref:(.*):ref').matcher(emailSubject);
        String matches;
        
        // Find the first match
        if (matcher.find()) {
            // Extract the matched substring
            String extractedString = matcher.group(1); // Group 1 captures the text between (.*)
            System.debug(extractedString); // This will print !00D590MkQ.!500O9024qtJ
            String caseId = Cases.getCaseIdFromEmailThreadId(extractedString);
            matches = caseId;
            
        } else {
            System.debug('No match found');
        }
        
        return matches;
    }
    
    public static Case caseCompletedProcessor(Case parentCase, Map<String, List<Case_Line__c>> caseToCaseLineMap){
        //getting list of corporate queue
        List<Corporate_Queue_List__mdt> corporateQueueListData = EmailMessageTriggerHandlerModel.getCorporateQueueListMetaData();
        List<String> corporateQueueList = new List<String>();
        
        for(Corporate_Queue_List__mdt CorporateQueueObj : corporateQueueListData){
            corporateQueueList.add(CorporateQueueObj.Label);
        }
        
        Decimal totalAmount = 0.0;
        if(caseToCaseLineMap.containskey(parentCase.Id)){
            for(Case_Line__c caseLine : caseToCaseLineMap.get(parentCase.Id)){
                if(caseLine.Line_Price__c != null){
                    totalAmount += caseLine.Line_Price__c;
                }
                
            }
        }
        
        if (corporateQueueList.contains(parentCase.Assigned_Queue__c)) {
            if(totalAmount == 0 || !parentCase.Send_To_Invoicing__c){
                parentCase.Status = Constant.CASE_STATUS_PENDING;
                parentCase.Has_Awaiting_Parts_Alert__c = true;
                parentCase.Internal_Comments__c = 'Case re-opened by Customer Email - Please review – ' + String.valueOf(System.now().format()) + '\n' + String.valueOf( parentCase.Internal_Comments__c != null ? parentCase.Internal_Comments__c : '');
                parentCase.Subject = 'RE-OPENED : ' + String.valueOf(parentCase.Subject != null ? parentCase.Subject : '');
                parentCase.Case_Updated_By_Email__c = true;
                return parentCase;
            }
            else if ( totalAmount != 0 || parentCase.Send_To_Invoicing__c ){
                Case childCase = new Case();
                childCase.ContactId = parentCase.ContactId;
                childCase.Has_Awaiting_Parts_Alert__c = true;
                childCase.Internal_Comments__c = 'Response on Billable Case: Please review original Case ' + String.valueOf(parentCase.CaseNumber) + '\n' +  String.valueOf( parentCase.Internal_Comments__c != null ? parentCase.Internal_Comments__c : '');
                childCase.OwnerId = parentCase.OwnerId;
                childCase.ParentId = parentCase.Id;
                childCase.Status = Constant.CASE_STATUS_PENDING;
                return childCase;
            }
        }
        else{
            if(totalAmount == 0 && !parentCase.Send_To_Invoicing__c){
                parentCase.Status = Constant.CASE_STATUS_PENDING;
                parentCase.Has_Awaiting_Parts_Alert__c = true;
                parentCase.Internal_Comments__c = 'Case re-opened by Customer Email - Please review – ' + String.valueOf(System.now().format()) + '\n' + String.valueOf( parentCase.Internal_Comments__c != null ? parentCase.Internal_Comments__c : '');
                parentCase.Subject = 'RE-OPENED : ' + String.valueOf(parentCase.Subject != null ? parentCase.Subject : '');
                parentCase.Case_Updated_By_Email__c = true;
                return parentCase;
            }
            else if ( totalAmount != 0 || parentCase.Send_To_Invoicing__c ){
                Case childCase = new Case();
                childCase.ContactId = parentCase.ContactId;
                childCase.Has_Awaiting_Parts_Alert__c = true;
                childCase.Internal_Comments__c = 'Response on Billable Case: Please review original Case ' + String.valueOf(parentCase.CaseNumber) + '\n' +  String.valueOf( parentCase.Internal_Comments__c != null ? parentCase.Internal_Comments__c : '');
                childCase.OwnerId = parentCase.OwnerId;
                childCase.ParentId = parentCase.Id;
                childCase.Status = Constant.CASE_STATUS_PENDING;
                return childCase;
                
                
            }
        }
        
        
        return null;
    }
    
    public static Case caseCancelledProcessor(Case parentCase){
        
        parentCase.Status = Constant.CASE_STATUS_PENDING;
        parentCase.Has_Awaiting_Parts_Alert__c = true;
        parentCase.Internal_Comments__c = 'Case re-opened by Customer Email - Please review – ' + String.valueOf(System.now().format()) + '\n' + String.valueOf( parentCase.Internal_Comments__c != null ? parentCase.Internal_Comments__c : '');
        parentCase.Subject = 'RE-OPENED : ' + String.valueOf(parentCase.Subject != null ? parentCase.Subject : '');
        parentCase.Case_Updated_By_Email__c = true;
        return parentCase;
        
    }
    
    public static Case caseClosedProcessor(Case parentCase){
        
        Case childCase = new Case();
        childCase.ContactId = parentCase.ContactId;
        childCase.Has_Awaiting_Parts_Alert__c = true;
        childCase.Internal_Comments__c = 'Email received on Closed Case: Please review original Case ' + String.valueOf(parentCase.CaseNumber) + '\n' +  String.valueOf( parentCase.Internal_Comments__c != null ? parentCase.Internal_Comments__c : '');
        childCase.OwnerId = parentCase.OwnerId;
        childCase.ParentId = parentCase.Id;
        childCase.Status = Constant.CASE_STATUS_PENDING;
        return childCase;
        
    }
    
    public static Case caseAwaitingPartsOrderProcessor(Case parentCase){
        
        parentCase.Has_Awaiting_Parts_Alert__c = true;
        parentCase.Internal_Comments__c = 'Case updated by Customer Email - Please review – ' + String.valueOf(System.now().format()) + '\n' + String.valueOf( parentCase.Internal_Comments__c != null ? parentCase.Internal_Comments__c : '');
        parentCase.Case_Updated_By_Email__c = true;
        return parentCase;
        
    }
    
    public static Case caseOtherProcessor(Case parentCase){
        
        parentCase.Status = Constant.CASE_STATUS_PENDING;
        parentCase.Has_Awaiting_Parts_Alert__c = true;
        parentCase.Case_Updated_By_Email__c = true;
        return parentCase;
    }
    
    public static void checkIsBounced(List<EmailMessage> NewListEmailMessage){
        
        List<String> emailList = new List<String>();
        for(EmailMessage emailMessageObj : NewListEmailMessage){
            
            System.debug('ToAddress email --> '  + emailMessageObj.ToAddress);
            System.debug('CcAddress email --> '  + emailMessageObj.CcAddress);
            System.debug('BccAddress email --> '  + emailMessageObj.BccAddress);
            
            if(emailMessageObj.ToAddress != null){
                //To Address
                List<String> emailslisttemp = emailMessageObj.ToAddress.split(',');
                emailList.addAll(emailslisttemp);
            }
            
            if(emailMessageObj.CcAddress != null){
                //Cc Address
                List<String> emailListCc = emailMessageObj.CcAddress.split(',');
                emailList.addAll(emailListCc);
            }
            
            
            if(emailMessageObj.BccAddress != null){
                //Bcc Address
                List<String> emailListBcc = emailMessageObj.BccAddress.split(',');
                emailList.addAll(emailListBcc);
            }
            
            
            System.debug('emailList --> '  + emailList);
        }
        
        List<Contact> bouncedContactList = EmailMessageTriggerHandlerModel.getBouncedContactList(emailList);
        
        System.debug('bouncedContactList --> '  + bouncedContactList);
        Map<String, Boolean> emailBouncedMap = new Map<String, Boolean>();
        
        for(Contact con : bouncedContactList){
            emailBouncedMap.put(con.Email, true);
        }
        
        for(EmailMessage emailMessageObj : NewListEmailMessage){
            List<String> errorEmailList = new List<String>();
            
            if(emailMessageObj.ToAddress != null){
                //To Address
                for(String email : emailMessageObj.ToAddress.split(',')){
                    
                    if(emailBouncedMap.containsKey(email)){
                        errorEmailList.add(email);
                    }
                    
                }
            }
            
            if(emailMessageObj.CcAddress != null){
                //Cc Address
                for(String email : emailMessageObj.CcAddress.split(',')){
                    
                    if(emailBouncedMap.containsKey(email)){
                        errorEmailList.add(email);
                    }
                    
                }
            }
            
            if(emailMessageObj.BccAddress != null){
                //Bcc Address
                for(String email : emailMessageObj.BccAddress.split(',')){
                    
                    if(emailBouncedMap.containsKey(email)){
                        errorEmailList.add(email);
                    }
                    
                } 
            }
            
            System.debug('errorEmailList --> '  + errorEmailList);
            if(errorEmailList.size() > 0){
                String errorEmail = String.join(errorEmailList, ',');
                emailMessageObj.addError('The email address '+ errorEmail +' on this record is invalid. Please verify and update the recipient’s email address');
                continue;
            }
            
        }
    }
    
    public static void handleUndeliverableEmail(List<EmailMessage> NewListEmailMessage,  Map<Id, SObject> NewListEmailMessageMap){
        
        /*List<ContentVersion> attachmentList = EmailMessageTriggerHandlerModel.getContentVersion(NewListEmailMessageMap.KeySet());
        System.debug('attachmentList --> '+ attachmentList);
        for(ContentVersion attachment : attachmentList){
            Blob versionDataBlob = attachment.VersionData;
            String versionDataString = versionDataBlob.toString();
            System.debug('versionDataString --> '+ versionDataString);
            Pattern pattern = Pattern.compile('>>> ([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}) \\(Undeliverable\\)');
            Matcher matcher = pattern.matcher(versionDataString);
            
            if (matcher.find()) {
                String email = matcher.group(1);
                System.debug('Extracted email address: ' + email);
            } else {
                System.debug('Email address not found in the input string.');
            }
        }*/
    }
    
}