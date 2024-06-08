public class AssignedResourceRecordShare {
    public static void shareSAWOwithPIESContractors(Map<String, String> mapSAARIds){
        Map<String, String > mapSRUsers = new Map<String, String>();
        Set<String> setUserEmail = new Set<String>();
        Map<String, List<String>> mapAccContIds = new Map<String, List<String>>();
        Set<String> setConEml = new Set<String>();
        Map<String, String> mapConEmail = new Map<String, String>();
        Map<String, String> mapSRUsersEmail = new Map<String, String>();
        Map<String, String> mpaUserEmIds = new Map<String, String>();
        Map<String, String> mapUserSAIds = new Map<String, String>();
        Map<String, String> mapSAWOIds = new Map<String, String>();
        Map<String, String> mapNonConSRIdUsId = new Map<String, String>();
        List<ServiceAppointmentShare> listsashare = new List<ServiceAppointmentShare>();
        List<WorkOrderShare> listwoshare = new List<WorkOrderShare>();
        List<ServiceAppointmentShare> listsasharenoncont = new List<ServiceAppointmentShare>();
        List<WorkOrderShare> listwosharenoncont = new List<WorkOrderShare>();
        //Id piesConRT = Schema.SObjectType.COntact.RecordTypeInfosByDeveloperName.get('Contractor').RecordTypeId; 
        Id piesSRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
        Id piesSART = Schema.SObjectType.ServiceAppointment.RecordTypeInfosByDeveloperName.get('OV_Install').RecordTypeId;
        for(ServiceResource sr : [SELECT Id, RelatedRecordId,RelatedRecord.Name,RelatedRecord.Email,RelatedRecord.ContactId,User_Profile__c, AccountId  FROM ServiceResource where Id IN :mapSAARIds.values() AND RecordTypeID = :piesSRRT]){
      system.debug('sr.User_Profile__c : ' + sr.User_Profile__c + '::' + sr.RelatedRecord.Name);
            if(sr.User_Profile__c != 'PIES Installer Contractor' && sr.User_Profile__c != 'PIES Order Verifier Contractor'){
                mapNonConSRIdUsId.put(sr.Id, sr.RelatedRecordId);
            }
            if(sr.User_Profile__c == 'PIES Installer Contractor' || sr.User_Profile__c == 'PIES Order Verifier Contractor'){
                 mapSRUsers.put(sr.Id, sr.RelatedRecordId)  ;
               setUserEmail.add(sr.RelatedRecord.ContactId); 
               mapSRUsersEmail.put(sr.Id, sr.RelatedRecord.ContactId)  ;
                //mpaUserEmIds.put(sr.RelatedRecord.Email,sr.RelatedRecordId);
            }
         
          system.debug('shareSAWOwithPIESContractors' + '::'  + mpaUserEmIds + '::::' + mapNonConSRIdUsId);  
        }
        for(ServiceAppointment sa :[SELECT Id, FSSK__FSK_Work_Order__c FROM ServiceAppointment WHERE Id IN :mapSAARIds.keySet() AND RecordTypeId = :piesSART] ){
          mapSAWOIds.put(sa.Id, sa.FSSK__FSK_Work_Order__c);
        }
        system.debug('Line 34: '+ mapSAWOIds);
        for(Contact c : [SELECT Id, Name, Email, AccountId FROM Contact WHERE Id IN :setUserEmail]){
            mapConEmail.put(c.Id, c.AccountId);
        }
        system.debug('shareSAWOwithPIESContractors' + '::' +mapConEmail);
        for(Contact con : [SELECT Id , name, Email, AccountId FROM Contact where AccountId IN:mapConEmail.values() ]){
            if(!mapAccContIds.containsKey(con.AccountId)){
                 mapAccContIds.put(con.AccountId, new List<String>{con.Id});
            }
            else{ mapAccContIds.get(con.AccountId).add(con.Id); }
            setConEml.add(con.Id);
         }
        for(User usr :[SELECT Id, Email,ContactId FROM User WHERE ContactId IN :setConEml AND PIES_Installer_Profile_Name__c = 'PIES Manager Contractor' ]){
            mpaUserEmIds.put(usr.ContactId, usr.Id);
        }
        system.debug('shareSAWOwithPIESContractors' + '::' + mpaUserEmIds);
        Map<String, String> mapSAShareDup = new Map<String, String>();
        for(ServiceAppointmentShare sar : [SELECT Id,UserOrGroupId from ServiceAppointmentShare WHERE parentId IN :mapSAWOIds.keySet() AND UserOrGroupId IN: mapNonConSRIdUsId.values() ]){
            mapSAShareDup.put(sar.UserOrGroupId, sar.Id);
        }
         system.debug('shareSAWOwithPIESContractors' + '::' + mapSAShareDup);
        if(mapNonConSRIdUsId.size()>0){
            for(String saId : mapSAARIds.keySet()){
                if(mapNonConSRIdUsId.containsKey(mapSAARIds.get(saId))){
                    if(!mapSAShareDup.containskey(mapNonConSRIdUsId.get(mapSAARIds.get(saId)))){
                         ServiceAppointmentShare saShare = new ServiceAppointmentShare();
                         saShare.ParentId = saId;
                         saShare.UserOrGroupId = mapNonConSRIdUsId.get(mapSAARIds.get(saId));
                         saShare.AccessLevel = 'Edit';
                         saShare.RowCause = 'Manual';
                         listsasharenoncont.add(saShare);
                    }
                    
                }
                if(mapSAWOIds.containsKey(saId)){
                    if(!mapSAShareDup.containskey(mapNonConSRIdUsId.get(mapSAARIds.get(saId)))){
                         WorkOrderShare woShare = new WorkOrderShare();
                        woShare.ParentId = mapSAWOIds.get(saId);
                        woShare.UserOrGroupId = mapNonConSRIdUsId.get(mapSAARIds.get(saId));
                        woShare.AccessLevel = 'Edit';
                        woShare.RowCause = 'Manual';
                        listwosharenoncont.add(woShare);
           }
                                       
                }
            }
            system.debug('SharewithNonCOntractors : ' + listsasharenoncont + '::::' + listwosharenoncont);
        }
        for(String saId : mapSAARIds.keySet()){
            system.debug('shareSAWOwithPIESContractors' + '::' + saId);
            if(mapSRUsers.containskey(mapSAARIds.get(saId))){
              if(mapConEmail.containsKey(mapSRUsersEmail.get(mapSAARIds.get(saId)))){
                   if(mapAccContIds.containskey(mapConEmail.get(mapSRUsersEmail.get(mapSAARIds.get(saId))))){
                        system.debug('shareSAWOwithPIESContractors :' + 'mapAccContIds : ' + mapAccContIds);
                        for(String conEml : mapAccContIds.get(mapConEmail.get(mapSRUsersEmail.get(mapSAARIds.get(saId))))){
                            system.debug('Line 45' + mapAccContIds.get(mapConEmail.get(mapSRUsersEmail.get(mapSAARIds.get(saId)))));
                            system.debug('conEml : ' + conEml);
                            if(mpaUserEmIds.containskey(conEml)){
                                ServiceAppointmentShare saShare = new ServiceAppointmentShare();
                                saShare.ParentId = saId;
                                saShare.UserOrGroupId = mpaUserEmIds.get(conEml);
                                saShare.AccessLevel = 'Edit';
                                saShare.RowCause = 'Manual';
                                listsashare.add(saShare);
                                system.debug('Line 88 :' + listsashare);
                            }
                            if(mpaUserEmIds.containskey(conEml)){
                                if(mapSAWOIds.containskey(saId)){
                                   WorkOrderShare woShare = new WorkOrderShare();
                                    woShare.ParentId = mapSAWOIds.get(saId);
                                    woShare.UserOrGroupId = mpaUserEmIds.get(conEml);
                                    woShare.AccessLevel = 'Edit';
                                    woShare.RowCause = 'Manual';
                                    listwoshare.add(woShare);
                                     system.debug('Line 98 :' + listwoshare);
                                }
                            }
                        }  
                    } 
                }
            }
        }
        
        if(listsashare.size()>0){
             //Database.Insert(listsashare, false);
             
             Database.SaveResult[] drList = Database.Insert(listsashare, false);  
            system.debug('drList :' + drList);
             for(Database.SaveResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully created with ID: ' + dr.getId());
                }
              else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                }
               }
      }
        }
        if(listwoshare.size()>0){
             system.debug('listwoshare' + listwoshare);
             Database.Insert(listwoshare, false);
           
        }
       if(listsasharenoncont.size()>0){
           system.debug('listsasharenoncont' + listsasharenoncont);
             Database.Insert(listsasharenoncont, false);
        }
      
       if(listwosharenoncont.size()>0){
           system.debug('listwosharenoncont' + listwosharenoncont);
             Database.Insert(listwosharenoncont, false);
        }
  }
     
     public static void shareSAWOwithPIESContractorsDelete(Map<Id, Id> saIds){
         Set<Id> setWOIds = new Set<Id>();
         Set<Id> setUserId = new Set<Id>();
         Set<String> setUserEmail = new Set<String>();
         Set<String> setUserName = new Set<String>();
         Map<String, String> mapConEmail = new Map<String, String>();
         Map<String, List<String>> mapAccContIds = new Map<String, List<String>>();
         Set<String> setConEml = new Set<String>();
         Map<String, String> mpaUserEmIds = new Map<String, String>();
         Map<String, String> mapNonConSRIdUsId = new Map<String, String>();
         Id piesConRT = Schema.SObjectType.COntact.RecordTypeInfosByDeveloperName.get('Contractor').RecordTypeId; 
         Id piesSRRT = Schema.SObjectType.ServiceResource.RecordTypeInfosByDeveloperName.get('Install_OV').RecordTypeId;
         for(ServiceResource sr : [SELECT Id, RelatedRecordId ,RelatedRecord.Email,RelatedRecord.Name,User_Profile__c FROM ServiceResource where Id IN :saIds.values() AND RecordTypeId = :piesSRRT]){
        
             if(sr.User_Profile__c != 'PIES Installer Contractor' && sr.User_Profile__c != 'PIES Order Verifier Contractor' && sr.User_Profile__c != 'PIES Manager Contractor' ){
                 mapNonConSRIdUsId.put(sr.Id, sr.RelatedRecordId);
             }
             if(sr.User_Profile__c == 'PIES Installer Contractor' || sr.User_Profile__c == 'PIES Order Verifier Contractor' || sr.User_Profile__c == 'PIES Manager Contractor' ){
                 setUserId.add(sr.RelatedRecordId);
              setUserEmail.add(sr.RelatedRecord.Email); 
              setUserName.add(sr.RelatedRecord.Name);
              mpaUserEmIds.put(sr.RelatedRecord.Email,sr.RelatedRecordId);  
             }
          }
         system.debug('shareSAWOwithPIESContractorsDelete: '+ mapNonConSRIdUsId);
         for(Contact c : [SELECT Id, Name, Email, AccountId FROM Contact WHERE (Name IN :setUserName AND Email IN :setUserEmail)]){
            mapConEmail.put(c.Email, c.AccountId);
         }
         for(Contact con : [SELECT Id , name, Email, AccountId FROM Contact where AccountId IN:mapConEmail.values() ]){
            if(!mapAccContIds.containsKey(con.AccountId)){
                 mapAccContIds.put(con.AccountId, new List<String>{con.Email});
            }
            else{ mapAccContIds.get(con.AccountId).add(con.Email); }
            setConEml.add(con.Email);
            system.debug('shareSAWOwithPIESContractors' + '::' + mapAccContIds + '::' + 'setConEml : ' + setConEml + con);
            
        }
        for(User usr :[SELECT Id, Email FROM User WHERE Email IN :setConEml AND PIES_Installer_Profile_Name__c = 'PIES Manager Contractor' ]){
            mpaUserEmIds.put(usr.Email, usr.Id);
            system.debug('shareSAWOwithPIESContractors' + '::' + mpaUserEmIds);
        }
         List<ServiceAppointmentShare> listSAShare=[SELECT ID from ServiceAppointmentShare where parentId in :saIds.keyset() AND (UserOrGroupId IN :mpaUserEmIds.values() OR UserOrGroupId IN :mapNonConSRIdUsId.values())];
         system.debug('listSAShare : ' + listSAShare);
         for(ServiceAppointment sa :[SELECT Id, FSSK__FSK_Work_Order__c FROM ServiceAppointment where Id IN :saIds.keyset()]){
            setWOIds.add(sa.FSSK__FSK_Work_Order__c);
            system.debug('shareSAWOwithPIESContractorsDelete :' + setWOIds);
         }
         List<WorkOrderShare> listWOShare=[SELECT ID from WorkOrderShare where parentId in :setWOIds AND (UserOrGroupId IN :mpaUserEmIds.values() OR UserOrGroupId IN :mapNonConSRIdUsId.values())];
         if(listWOShare.size()>0){
           system.debug('listWOShare: ' + listWOShare);
           Database.Delete(listWOShare, false);  
         }
         if(listSAShare.size()>0){
           system.debug('listSAShare: ' + listSAShare.size());
           Database.DeleteResult[] drList = Database.Delete(listSAShare, false);  
             for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully deleted with ID: ' + dr.getId());
                }
              else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                }
               }
      }
         }
         
    }
}