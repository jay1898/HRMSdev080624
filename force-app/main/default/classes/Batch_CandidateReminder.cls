global class Batch_CandidateReminder Implements Database.Batchable<sObject>,Schedulable, Database.stateful, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator( 'SELECT id,Email__c, CreatedDate, Full_Name__c, Status__c  FROM Candidate__c WHERE Status__c  = \'New Application\'' );
    }
    global void execute(Database.BatchableContext bc, List<Candidate__c> candidteRecords)
    {   
		List<Candidate__c> rejectedCandidateList  = new List<Candidate__c>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        //Date currentDate = Date.Today().addDays(-1);
		Date lastThreeDate = Date.Today().addDays(-2) ;
        system.debug('currentDate ::'+Date.Today());
        system.debug('lastThreeDate ::'+lastThreeDate);
        if (candidteRecords.size() > 0){
            
            for(Candidate__c candidateRec : candidteRecords){
                
                if(candidateRec.CreatedDate < Date.Today()  && candidateRec.CreatedDate >= lastThreeDate){
                    //system.debug('lastThreeDate ::Inside If--> '+candidateRec.Full_Name__c + ' Date: ' + candidateRec.CreatedDate);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                    String recipientEmail = candidateRec.Email__c;
                    system.debug('recipientEmail ::'+recipientEmail);
                    email.setToAddresses(new String[] {recipientEmail});
                    email.setSaveAsActivity(false); 
                   
                    Map<String, String> templateData = new Map<String, String>();
                    templateData.put('Name', candidateRec.Full_Name__c); 
                    
    
                    // Dynamic Content
                    EmailTemplate emailTemplate =[Select id,HtmlValue, Subject from EmailTemplate where name = 'Reminder Application Fill-Up Deadline Approaching' limit 1];
                    email.setHtmlBody(replaceDynamicContent(templateData,emailTemplate.htmlvalue));
                    email.setSubject(emailTemplate.Subject);
                    //email.setCcAddresses(new String[] { 'shrikant.shendgeitechcloud@gmail.com' });
                    mailList.add(email);
                }
               // else if (candidateRec.CreatedDate.date() != Date.Today() ) use this conditon if u want 
                /*   else if (candidateRec.CreatedDate.date() != Date.Today() ){
                    system.debug('lastThreeDate ::Inside Else--> '+candidateRec.Full_Name__c + ' Date: ' + candidateRec.CreatedDate);
                    Candidate__c  obj = new Candidate__c();
                    obj.Id = candidateRec.Id;
					obj.Status__c  = 'Reject';
                    rejectedCandidateList.add(obj);
                          system.debug('obj:::::'+obj);
                }*/
            
                
            }
            
            try{
                if(mailList.size() > 0){
                    Messaging.sendEmail(mailList);
                }
                if(rejectedCandidateList.size() > 0 ){
                    Update rejectedCandidateList;
                }
            }
            catch(Exception e){
                System.debug('Email sending failed: ' + e.getMessage());
            }
            
        }      
    }
    public static string replaceDynamicContent(Map<String,Object> inputMap,String textToReplace){
        Pattern pattrn = Pattern.compile('\\{\\{[iI][fF]\\([a-zA-Z0-9\', .\\-]*\\)\\}\\}');
        Matcher matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String conditionalVariable=matcher.group(0).replaceAll('\\{\\{[iI][fF]\\(','').replaceAll('\\)\\}\\}','');
            
            List<String> ConditionList=conditionalVariable.split(',\''); 
            String dynamicData='';
            if(ConditionList.size()>2){
                if(inputMap.get(ConditionList[0])!=null && Boolean.valueOf(inputMap.get(ConditionList[0]))){
                    dynamicData=ConditionList[1];
                }else{
                    dynamicData=ConditionList[2];
                }
            }
            if(dynamicData.length()>1 && dynamicData.substring(dynamicData.length()-1)=='\''){
                dynamicData=dynamicData.substring(0,dynamicData.length()-1);  
            }else{
                dynamicData='';
            }
            textToReplace=textToReplace.replaceAll('\\{\\{[iI][fF]\\('+conditionalVariable+'\\)\\}\\}', dynamicData);
        }  
        pattrn = Pattern.compile('\\{\\{[a-zA-Z0-9]*\\}\\}');
       matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
           String variableName=matcher.group(0).replaceAll('\\{\\{','').replaceAll('\\}\\}','');
            if(string.valueOf(inputMap.get(variableName))!=null){
               textToReplace=textToReplace.replaceAll('\\{\\{'+variableName+'\\}\\}', string.valueOf(inputMap.get(variableName)));
            }
        }   
        return textToReplace;
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }
   global void execute(SchedulableContext sc) {
        Batch_CandidateReminder b = new Batch_CandidateReminder(); 
        database.executebatch(b,1);
    }
    
    
}