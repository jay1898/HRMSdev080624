/*
Created By      : Subhash Panchani
Created Date    : 28 July 2023
Purpose         : This is a Service Class for CaseQuickTextTriggerHandler. 
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class CaseQuickTextTriggerHandlerService {
    public static void checkNameQueueBeforeUpdate(Map<Id,SObject> newMap) {
        Set<String> queueList = new Set<String>();
        for(Case_Quick_Text__c cqt : (List<Case_Quick_Text__c>)newMap.values()){
            queueList.add(cqt.Queue_Name__c);
        }
        List<Group> groupList = CaseQuickTextTriggerHandlerModel.getQueue(queueList);
        
        Map<String,Group> groupMap = new  Map<String,Group>();
        for(Group gl : groupList){
            groupMap.put(gl.Name,gl);
        }
        
        for(Case_Quick_Text__c cqt : (List<Case_Quick_Text__c>)newMap.values()){
            if(!groupMap.containskey(cqt.Queue_Name__c)){
                cqt.addError('Please enter correct queue name.');
            }
        }
    }
    
     public static void checkNameQueueBeforeInsert(List<Case_Quick_Text__c> casequickText) {
        Set<String> queueList = new Set<String>();
        for(Case_Quick_Text__c cqt : casequickText){
            queueList.add(cqt.Queue_Name__c);
        }
        List<Group> groupList = CaseQuickTextTriggerHandlerModel.getQueue(queueList);
        
        Map<String,Group> groupMap = new  Map<String,Group>();
        for(Group gl : groupList){
            groupMap.put(gl.Name,gl);
        }
        
        for(Case_Quick_Text__c cqt : casequickText){
            if(!groupMap.containskey(cqt.Queue_Name__c)){
                cqt.addError('Please enter correct queue name.');
            }
        }
    }
}