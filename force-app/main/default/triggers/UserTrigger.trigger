trigger UserTrigger on User (after insert,after update,before insert,before update) {
    // Get custom settings, Check object trigger settings, if disabled then go back  
    Metadata_Control__c cs = Metadata_Control__c.getInstance();
    if(cs != null && (cs.Disable_All__c || cs.User_Disable_Trigger__c ) ) return ;
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        // to store the list of AOR user to give access
        List<String> listUser=new List<String>();
        List<String> listSharingUser=new List<String>();
        // to store the list of AOR user to remove access 
        List<String> listUserRemoveAccess=new List<String>();
        for(User u:trigger.New){
            if(Trigger.isInsert){
                if(u.AOR__c!=null){
                    listUser.add(u.Id);
                }
                if(u.ContactId!=null){
                    listSharingUser.add(u.Id);
                }
            }   
            if(Trigger.isUpdate && (u.AOR__c!=trigger.oldMap.get(u.id).aor__c)){
                if(u.AOR__c!=null){
                    listUser.add(u.Id);
                }
                if(trigger.oldMap.get(u.id).AOR__c!=null){
                    listUserRemoveAccess.add(u.id);
                }
                
            }   
            if(Trigger.isUpdate && (u.ContactId != null &&  u.IsActive && u.IsActive!=trigger.oldMap.get(u.id).IsActive)){
                listSharingUser.add(u.Id);
            }
        }
        if(listUser.size()>0 || listUserRemoveAccess.size()>0 ){
            UserTriggerHandler.addRemoveShareBranchWithAORUser(listUser, listUserRemoveAccess);
            UserTriggerHandler.addRemoveShareAORCampaingWithUser(listUser, listUserRemoveAccess);
            UserTriggerHandler.addRemoveShareOpportuniryWithAORUser(listUser, listUserRemoveAccess);
        }
        if(listSharingUser.size()>0){
            UserTriggerHandler.CreateSharingForCommunityUser(listSharingUser);
        }
        UserTriggerHandler.populateBranchName(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore &&  (Trigger.isInsert || Trigger.isUpdate))
    {
        // Method to update the EDW Last Modified
        UserTriggerHandler.updateEDWLastModified(Trigger.new, Trigger.oldMap);
        If(Trigger.isUpdate){
            UserTriggerHandler.validateUserExistAsLeadReceiver(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        
          // Method to update the User Public Group
          UserTriggerHandler.updateUserPublicGroup(Trigger.new, Trigger.oldMap);
    }
}