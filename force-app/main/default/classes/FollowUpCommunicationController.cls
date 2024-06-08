public class FollowUpCommunicationController {
    
    @AuraEnabled(Cacheable = true)
    public static Map<String,Object> getOpportunityDetail(String recordId){
        Map<String,Object> returnData=new Map<String,Object>();
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult =Opportunity.Communication__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getValue()!='Thank you' && f.getValue()!='1on1'){
                options.add(f.getValue());
            }
            
        }  
        returnData.put('CommunicationList',options);
        
        List<Opportunity> listOpp=[SELECT Id,Appointment_DateTime__c From Opportunity Where id=:recordId limit 1];
        if(listOpp.size()>0){
            returnData.put('AppointmentDate',listOpp[0].Appointment_DateTime__c!=null?listOpp[0].Appointment_DateTime__c.addHours(24):null); 
        }else{
            returnData.put('AppointmentDate',DateTime.now()); 
        }
        
        return returnData;
    }
    
    @AuraEnabled
    public static String saveOpportunity(String recordId, String startDate, String selectedOption){
        String message = '';
        DateTime dateVal=DateTime.valueOf(startDate.replace('T', ' ').replace('Z', ''));
        
        if(String.isNotBlank(recordId)){ 
            Opportunity opp = new Opportunity(Id = recordId, StageName = 'Follow-Up',Communication_Start_Date__c =DateTime.newInstanceGmt(dateVal.date(),dateval.time()), Communication__c = selectedOption);
            update opp;
            message = 'Success';
        } 
        return message;
    }
}