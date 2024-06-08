public with sharing class KanbanController {
    public List<String> stages {get;set;}
    public Map<String,List<Opportunity>> stagesWiseOpp {get;set;}
    public String StageName {get;set;}
    public String OppId {get;set;}
    public String ErrorMessage {get;set;}
    public String searchOppName{get;set;}
    public KanbanController(){
        stages = getPicklistValues();
        filterOpp();
    }
    /*public void loadData(){
        stagesWiseOpp=New Map<String,List<Opportunity>>();
        for(String stageName : stages){
            stagesWiseOpp.put(stageName,new List<Opportunity>());
        }
        
        
        for(Opportunity opp : [Select Id, Name,Account.Name,createddate, StageName,Communication__c,Amount,CloseDate FROM Opportunity Where StageName='Follow-Up' Order By Name  limit 200]){
            if(!stagesWiseOpp.containsKey(opp.Communication__c)){
                stagesWiseOpp.put(opp.Communication__c,new List<Opportunity>());
            }
            stagesWiseOpp.get(opp.Communication__c).add(opp);
        }
    }*/
    public void filterOpp(){
        system.debug('@@'+searchOppName);
        stagesWiseOpp=New Map<String,List<Opportunity>>();
        for(String stageName : stages){
            stagesWiseOpp.put(stageName,new List<Opportunity>());
        }
        String StageName='';
        String searchOppNameFilter='%'+(searchOppName==null?'':searchOppName)+'%';
        for(Opportunity opp : [Select Id, Name,Account.Name,createddate, StageName,Communication__c,Amount,CloseDate FROM Opportunity 
                               Where StageName='Follow-Up' and Name Like :searchOppNameFilter Order By Name  limit 200]){
            // Added on 18-01-2022 as Stage name value is different then label
            StageName=opp.Communication__c;
            if(StageName=='Thank You'){
                 StageName='No Follow-Up';
            }
            if(!stagesWiseOpp.containsKey(StageName)){
                stagesWiseOpp.put(StageName,new List<Opportunity>());
            }
            stagesWiseOpp.get(StageName).add(opp);
        }
    }
    public static List<String> getPicklistValues(){ 
        List<String> pickListValuesMap= new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Communication__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            // 18-01-2022 changed get value to label as value if different
            pickListValuesMap.add(pickListVal.getLabel());
        }     
        return pickListValuesMap;
    }
    public void updateOpportunityStage(){
        ErrorMessage='';
        try{
            if(String.isNotBlank(oppId)){
                List<Opportunity> listOpp=[SELECT Id,Communication__c From Opportunity Where Id =:oppId limit 1];
                if(listOpp.size()>0){
                    if(listOpp[0].Communication__c!=stageName){
                        listOpp[0].Communication__c = stageName;
                        update listOpp[0];
                    }
                }
            }
        }catch(Exception e){
            ApexPages.addMessages(e);
            ErrorMessage=e.getMessage();
            List<ApexPages.Message> listMessage=ApexPages.getMessages();
            for(ApexPages.Message msg :listMessage){
                ErrorMessage=msg.getDetail();
            }
            
        }
        filterOpp();
    }
    
}