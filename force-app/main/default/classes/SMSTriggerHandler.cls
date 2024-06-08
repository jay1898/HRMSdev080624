@isTest
public class SMSTriggerHandler {
   /* public static void updateOppCommStage(List<Mogli_SMS__SMS__c> listSMS){
        List<Id> listContactId=new List<Id>();
        try{
            
            for(Mogli_SMS__SMS__c SMS : listSMS){
                // check it's inbound sms
                if(SMS.Mogli_SMS__Status__c == 'Received Successfully' && SMS.Mogli_SMS__Contact__c!=null){
                    listContactId.add(SMS.Mogli_SMS__Contact__c);
                }
            }
            if(listContactId.size()>0){
                //Set Opp Id
                set<Id> setOppId=new Set<Id>();
                // Contact Opp Map
                Map<Id,Opportunity> contactIdOppMap=new map<Id,Opportunity>();
                // check is there any contact has related opportunity with Rehash stage then move it to 1on1
                List<Opportunity> listOpportunity=[SELECT Id,StageName,Account.PersonContactId FROM Opportunity 
                                                   Where Account.PersonContactId in :listContactId
                                                   and stageName='Rehash' and RehashCommunication__c!=null 
                                                   and RehashCommunication__c not in('Thank You','1on1')];
                for(Opportunity Opp: listOpportunity){
                    Opp.rehashCommunication__c='1on1';
                    opp.Communication_1on1_Flag__c=true;
                    opp.Mogli_SMS__Mogli_Opt_Out__c=false;
                    setOppId.add(Opp.Id);
                    contactIdOppMap.put(Opp.Account.PersonContactId,Opp);
                }
                
                List<OpportunityCommunication__c> listOppCommToDelete=[Select Id,Opportunity__c from OpportunityCommunication__c where Opportunity__c in :setOppId and is_executed__c=false];
                delete listOppCommToDelete;
                
                if(contactIdOppMap.values().size()>0){
                    update contactIdOppMap.values();
                }
            }
            
        }catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('SMSTrigger','trigger',JSON.serialize(listContactId),ex,'Integration'));
            
        }
    }*/
}