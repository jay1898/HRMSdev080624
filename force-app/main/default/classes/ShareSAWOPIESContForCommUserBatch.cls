global class ShareSAWOPIESContForCommUserBatch implements Database.Batchable<sObject>, Database.Stateful{
    private List<String> UIDs;
    private Map<Id,Set<Id>> mapUserWiseUserList;
    public ShareSAWOPIESContForCommUserBatch(List<String> userIds) {
        //set userId from execute batch param
        UIDs = userIds;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //get Contact Account of User with Profile name is PIES Manager Contractor
        //String query = 'SELECT Id, Contact.AccountId FROM User WHERE Id = \'' + UID + '\' AND PIES_Installer_Profile_Name__c = \'PIES Manager Contractor\'';
        Map<Id,Set<Id>> mapUserbyAcc = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> mapUserbyCon = new Map<Id,Set<Id>>();
        mapUserWiseUserList = new Map<Id,Set<Id>>();
        List<User> lstUsers = [SELECT Id, Contact.AccountId FROM User WHERE Id In: UIDs AND PIES_Installer_Profile_Name__c = 'PIES Manager Contractor' ];//Database.query(query);
        Set<Id> accountIds = new Set<Id>();
        if(!lstUsers.isEmpty()){
            for (User u : lstUsers) {
                accountIds.add(u.Contact.AccountId);
                if(!mapUserbyAcc.containsKey(u.Contact.AccountId)){
                    mapUserbyAcc.put(u.Contact.AccountId, new Set<Id>{u.id});
                }
                else{
                    mapUserbyAcc.get(u.Contact.AccountId).add(u.id);
                }
            }
        }    
        else{
            return Database.getQueryLocator([SELECT ID,ServiceAppointmentId,ServiceAppointment.WorkTypeId FROM AssignedResource Limit 0]);
        }
        
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE AccountId IN :accountIds];
        if(!contacts.isEmpty()){
            for (Contact c : contacts) {
                //if(!mapUserbyCon.containsKey(c.Id)){
                  mapUserbyCon.put(c.Id, mapUserbyAcc.get(c.AccountId));
                //}
            }
        }
        /*Set<Id> contactIds = new Set<Id>();
        if(!contacts.isEmpty()){
            for (Contact c : contacts) {
                contactIds.add(c.Id);
            }
        }*/
        
        List<User> users = [SELECT Id,ContactId FROM User WHERE ContactId IN :contacts];
        if(!users.isEmpty()){
            for(User u : users){
                if(mapUserbyCon.containsKey(u.ContactId) /*&& !mapUserWiseUserList.containsKey(u.Id)*/){
                  mapUserWiseUserList.put(u.Id,mapUserbyCon.get(u.ContactId));
                }
            }
        }
       //get AssignedResource form user
        return Database.getQueryLocator([SELECT ID,ServiceAppointmentId,ServiceAppointment.FSSK__FSK_Work_Order__c, ServiceResource.RelatedRecordId FROM AssignedResource Where ServiceResource.RelatedRecord.ContactId!=null and ServiceResource.RelatedRecordId =:users and ServiceResource.RecordType.DeveloperName='Install_OV'  and ServiceAppointment.RecordType.DeveloperName='OV_Install' ]);//  and id='03r6T00000039uMQAQ' related id where clause remaining
    }
    
    global void execute(Database.BatchableContext bc, List<AssignedResource> scope) {
        //create sharing records for ServiceAppointment and WorkOrder
        Map<String,ServiceAppointmentShare> listsasharenoncont = new Map<String,ServiceAppointmentShare>();
        Map<String,WorkOrderShare> listwosharenoncont = new Map<String,WorkOrderShare>();
        for(AssignedResource AR : scope){
            if(mapUserWiseUserList != null && mapUserWiseUserList.containsKey(AR.ServiceResource.RelatedRecordId)){
                for(ID userId : mapUserWiseUserList.get(AR.ServiceResource.RelatedRecordId)){
                    ServiceAppointmentShare saShare = new ServiceAppointmentShare();
                    saShare.ParentId = AR.ServiceAppointmentId;
                    saShare.UserOrGroupId = userId;
                    saShare.AccessLevel = 'Edit';
                    saShare.RowCause = 'Manual';
                    //listsasharenoncont.add(saShare);
                    listsasharenoncont.put(saShare.UserOrGroupId+'-'+saShare.UserOrGroupId,saShare);
                    
                    WorkOrderShare woShare = new WorkOrderShare();
                    woShare.ParentId = AR.ServiceAppointment.FSSK__FSK_Work_Order__c;
                    woShare.UserOrGroupId = userId;
                    woShare.AccessLevel = 'Edit';
                    woShare.RowCause = 'Manual';
                    //listwosharenoncont.add(woShare);
                    listwosharenoncont.put(woShare.UserOrGroupId+'-'+woShare.UserOrGroupId,woShare);
                } 
            }
        } 
        Database.insert(listwosharenoncont.values(),false);
        Database.insert(listsasharenoncont.values(),false);
    }
    
    global void finish(Database.BatchableContext bc) {
        // Your finish logic goes here
    }
}