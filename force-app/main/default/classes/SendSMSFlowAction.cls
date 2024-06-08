/**
 * @Name         SendSMSFlowAction 
 * @Author       Dhruv Javiya | mailto:javiyad@evergegroup.com
 * @Description  This class is used with Flows to send an SMS.  
 * History 	
 * Ver   Date         Author        Modification
 * 1.0   26-09-2022    Dhruv Javiya  Initial Version()
*/
public class SendSMSFlowAction {
    //Wrapper class 
    public class TwilioSmsFlowInput {
        @InvocableVariable public String toNum;
        @InvocableVariable public String topic;
        @InvocableVariable public Id recordId;
        @InvocableVariable public Id branchId;
        @InvocableVariable public Boolean isFirstSMS;
    }
    
     /**
    *   @Method:        sendNextSMS
    *   @Purpose:       call from Flow and Send Qualification Question SMS
    *   @Author:        Dhruv 
    *   @Date:          26-09-2022
    *   @TaskSource:    
    
    *   @Updates:       
    */ 
    @InvocableMethod(label='Send Qualification Question' description='Send Question by branch' category='Twilio')
    public static void sendNextSMS(List<TwilioSmsFlowInput> twilioSmsFlowInputList){
        
        Try{
            List<String> listBranchId=new List<String>();
            List<String> listOppIds=new List<String>();
            Map<String,String> OppWiseBranch=new Map<String,String>();
            Map<String,String> OppWisePhone=new Map<String,String>();
            Map<String,String> OppWiseTopic=new Map<String,String>();
            Map<String,Boolean> OppWiseIsFirstSMS=new Map<String,Boolean>();
            //Question Input from Flow 
            for(TwilioSmsFlowInput twilioSmsFlowInput : twilioSmsFlowInputList){
                OppWiseBranch.put(twilioSmsFlowInput.recordId,twilioSmsFlowInput.branchId);
                OppWisePhone.put(twilioSmsFlowInput.recordId,twilioSmsFlowInput.toNum);
                OppWiseTopic.put(twilioSmsFlowInput.recordId,twilioSmsFlowInput.topic);
                OppWiseIsFirstSMS.put(twilioSmsFlowInput.recordId,twilioSmsFlowInput.isFirstSMS);
                listOppIds.add(twilioSmsFlowInput.recordId);   
                listBranchId.add(twilioSmsFlowInput.branchId);   
            }    
            //Get Branch Id Wise Question Records
            List<Branch_Question_Junction__c> listBranchQuestion=[SELECT Id,Question_Templates__r.Message_Text__c,Order__c,Branch__c,branch__r.Enable_SMS_Feature__c FROM Branch_Question_Junction__c Where Branch__c = :listBranchId and branch__r.Enable_SMS_Feature__c=true order by order__c];
            
            set<String> listFieldNames=new set<String>();
            Map<String,List<Branch_Question_Junction__c>> branchWiseQuestions=new Map<String,List<Branch_Question_Junction__c>>();
            for(Branch_Question_Junction__c BQJ : listBranchQuestion){
                listFieldNames.addAll(getSalesforceFieldNames(BQJ.Question_Templates__r.Message_Text__c));
                if(!branchWiseQuestions.containsKey(BQJ.Branch__c)){
                    branchWiseQuestions.put(BQJ.Branch__c,new List<Branch_Question_Junction__c>());
                }
                branchWiseQuestions.get(BQJ.Branch__c).add(BQJ);
            }
            
            // Get Opportunity Detail And Current Question
            Map<Id,Opportunity> IdWiseOpportunityMap=new Map<Id,Opportunity>();
            Map<String,Integer> oppWiseCurrentQuestionOrder=new Map<String,Integer>();
            List<String> listFinalField=new List<String>();
            listFinalField.addAll(listFieldNames);
            String fields='';
            if(listFinalField.size()>0){
                fields=','+String.join(listFinalField,',');
            }
            List<Opportunity> listOpps=Database.query('SELECT Id '+fields+',(select id,Question_Template__c,Response__c from Question_Responses__r order by createddate desc limit 1) FROM Opportunity Where id=:listOppIds');
            Map<String,Branch_Question_Junction__c> OppWiseNextQuestionToSend=new Map<String,Branch_Question_Junction__c>();
            set<String> FirstSMSOppList=new Set<String>();
            set<String> LastSMSOppList=new Set<String>();
            for(Opportunity opp : listOpps){
                IdWiseOpportunityMap.put(opp.Id,opp);
                if(opp.Question_Responses__r.size()>0 && OppWiseBranch.containsKey(opp.Id) && branchWiseQuestions.containsKey(OppWiseBranch.get(opp.Id))){
                    // get next question 
                    List<Branch_Question_Junction__c> listQeustions=branchWiseQuestions.get(OppWiseBranch.get(opp.Id));
                    Decimal Order=-1;
                    boolean isLastSMS=true;
                    for(Branch_Question_Junction__c BQJ : listQeustions){
                        
                        if(order==BQJ.Order__c){
                            // send this question
                            OppWiseNextQuestionToSend.put(opp.Id,BQJ);
                            isLastSMS=false;
                            break;
                        }
                        
                        if(BQJ.Question_Templates__c==opp.Question_Responses__r[0].Question_Template__c){
                            Order=BQJ.Order__c+1;
                        }
                    }
                    system.debug('@@'+Order);
                    system.debug('@@'+opp.Question_Responses__r.size());
                    if(isLastSMS){
                        LastSMSOppList.add(opp.Id);
                    }
                    
                }else if(OppWiseBranch.containsKey(opp.Id) ){
                    
                    // is First SMS
                    if(OppWiseIsFirstSMS.get(opp.Id)==true){
                        FirstSMSOppList.add(opp.Id);
                    }
                    else if(branchWiseQuestions.containsKey(OppWiseBranch.get(opp.Id))){
                        // Send First Question
                        List<Branch_Question_Junction__c> listQuestions=branchWiseQuestions.get(OppWiseBranch.get(opp.Id));
                        if(listQuestions.size()>0){
                            OppWiseNextQuestionToSend.put(opp.Id,listQuestions[0]);
                        }
                    }
                    
                }
                
            }
            
            // send SMS to Opportunity   
            List<Question_Response__c> listNextQuestionToSend=new List<Question_Response__c>();
            for(String OppId : OppWiseNextQuestionToSend.keySet()){
                Question_Response__c QR=new Question_Response__c();
                QR.Opportunity__c=oppId;
                QR.Question_Template__c=OppWiseNextQuestionToSend.get(oppId).Question_Templates__c;
                listNextQuestionToSend.add(QR);
                
                
                TwilioMessenger.SendSmsParams smsParams = new TwilioMessenger.SendSmsParams();
                smsParams.branchId = OppWiseBranch.get(oppId);
                smsParams.message = getDynamicSMSText(IdWiseOpportunityMap.get(oppId),OppWiseNextQuestionToSend.get(oppId).Question_Templates__r.Message_Text__c);
                smsParams.recordId = oppId;
                smsParams.toNum =  OppWisePhone.get(oppId);
                smsParams.topic =  OppWiseTopic.get(oppId);
                
                if (System.isFuture() || System.isBatch()) {
                    //can't chain future methods together but CAN use callout/write if already in a future context
                    //TODO: Verify that batch methods also can use the non-future method
                    TwilioMessenger.sendNonFutureSms(smsParams); 
                } else {
                    TwilioMessenger.sendSms(smsParams);
                }
            }
            
            if(FirstSMSOppList.size()>0){
                List<Question_Template__c> FirstTemplate=[SELECT Id,Message_Text__c FROM Question_Template__c where isFirstQuestion__c=true limit 1];
                if(FirstTemplate.size()>0){
                    for(String OppId : FirstSMSOppList){
                        TwilioMessenger.SendSmsParams smsParams = new TwilioMessenger.SendSmsParams();
                        smsParams.branchId = OppWiseBranch.get(oppId);
                        smsParams.message = getDynamicSMSText(IdWiseOpportunityMap.get(oppId),FirstTemplate[0].Message_Text__c);
                        smsParams.recordId = oppId;
                        smsParams.toNum =  OppWisePhone.get(oppId);
                        smsParams.topic =  OppWiseTopic.get(oppId);
                        
                        if (System.isFuture() || System.isBatch()) {
                            //can't chain future methods together but CAN use callout/write if already in a future context
                            //TODO: Verify that batch methods also can use the non-future method
                            TwilioMessenger.sendNonFutureSms(smsParams); 
                            // System.enqueueJob(new SendSMSEnqueueJob(JSON.serialize(smsParams) ));
                        } else {
                            TwilioMessenger.sendSms(smsParams);
                        }
                    }
                }
                
                
            }
            List<Opportunity> listOppToUpdate=new List<Opportunity>();
            
            if(LastSMSOppList.size()>0){
                List<Question_Template__c> LastTemplate=[SELECT Id,Message_Text__c FROM Question_Template__c where isLastQuestion__c=true limit 1];
                if(LastTemplate.size()>0){
                    for(String OppId : LastSMSOppList){
                        TwilioMessenger.SendSmsParams smsParams = new TwilioMessenger.SendSmsParams();
                        smsParams.branchId = OppWiseBranch.get(oppId);
                        smsParams.message = getDynamicSMSText(IdWiseOpportunityMap.get(oppId),LastTemplate[0].Message_Text__c);
                        smsParams.recordId = oppId;
                        smsParams.toNum =  OppWisePhone.get(oppId);
                        smsParams.topic =  OppWiseTopic.get(oppId);
                        
                        if (System.isFuture() || System.isBatch()) {
                            //can't chain future methods together but CAN use callout/write if already in a future context
                            //TODO: Verify that batch methods also can use the non-future method
                            TwilioMessenger.sendNonFutureSms(smsParams); 
                        } else {
                            TwilioMessenger.sendSms(smsParams);
                        }
                        
                        listOppToUpdate.add(new Opportunity(Id =oppId,Last_SMS_Send__c=true));
                    }
                }
                
                
            }
            
            insert listNextQuestionToSend; 
            Boolean currenFlag= OpportunityTriggerHandler.RUN_TRIGGER ;
            OpportunityTriggerHandler.RUN_TRIGGER = false;
            update listOppToUpdate;
            OpportunityTriggerHandler.RUN_TRIGGER = currenFlag; 
        }catch(Exception ex){
            system.debug('@@Error in SMS Send'+ex.getMessage());
            new ApexDebugLog().createLog(new ApexDebugLog.Error('SendSMSFlowAction','sendNextSMS',JSON.serialize(twilioSmsFlowInputList),ex,'Integration'));
     
        }
        
    }
    
    //Replace Field name and calls from Invocable Method
    public static set<String> getSalesforceFieldNames(String textToReplace){
        system.debug('@@textToReplace :: '+textToReplace);
        set<String> listFieldName=new set<String>();
        if(textToReplace==null) return listFieldName;
        Pattern pattrn = Pattern.compile('\\{\\{[iI][fF]\\([a-zA-Z0-9\', .\\-]*\\)\\}\\}');
        Matcher matcher = pattrn.matcher(textToReplace);
       
        pattrn = Pattern.compile('\\{\\{[a-zA-Z0-9]*\\}\\}');
        matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String fieldName=matcher.group(0).replaceAll('\\{\\{','').replaceAll('\\}\\}','');
            listFieldName.add(fieldName);
        }        
        
        return listFieldName;
    }
    
    //remove curly braces calls from Invocable Method
    public static string getDynamicSMSText(Opportunity Opp,String textToReplace){
        
        Pattern pattrn = Pattern.compile('\\{\\{[iI][fF]\\([a-zA-Z0-9\', .\\-]*\\)\\}\\}');
        Matcher matcher = pattrn.matcher(textToReplace);
       
        pattrn = Pattern.compile('\\{\\{[a-zA-Z0-9]*\\}\\}');
        matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String fieldName=matcher.group(0).replaceAll('\\{\\{','').replaceAll('\\}\\}','');
            if(string.valueOf(fieldName)!=null){
                textToReplace=textToReplace.replaceAll('\\{\\{'+fieldName+'\\}\\}', string.valueOf(Opp.get(fieldName)));
            }
        }        
        
        return textToReplace;
    }
    
}