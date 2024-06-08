/**
*   @Method:		getTodaysAppointments, getRelatedPhotos
*   @Purpose:       Installations Photo Feed Tab(To get the images related to Work Order which are added as part of appointments(created today))
*   @Author:        Vijay (eVerge)
*   @Date:          05-Sep-2023
**/
public class PhotoFeedController {
    @AuraEnabled
    public static List<ServiceAppointmentPhotosListWrapper> getTodaysAppointments() {
        String getAppName = getAppName();
        try {
            List<ServiceAppointmentPhotosListWrapper> sapList = new List<ServiceAppointmentPhotosListWrapper>();
            List<ServiceAppointment> saList = new List<ServiceAppointment>(); 
            if(getAppName.equalsIgnoreCase('Pella Service Console')){
                saList = [Select Id, AppointmentNumber, Status, SchedStartTime, FSSK__FSK_Work_Order__c, FSSK__FSK_Work_Order__r.WorkOrderNumber, 
                          Account.Name, FSSK__FSK_Work_Order__r.Quote_PO_Number__c, FSSK__FSK_Work_Order__r.Address From ServiceAppointment 
                          Where SchedStartTime = TODAY AND Status != 'Canceled' AND Status != 'Completed' AND RecordType.Name = 'Customer Service' 
                          Order By SchedStartTime Desc];
            }else{
                saList = [Select Id, AppointmentNumber, Status, SchedStartTime, FSSK__FSK_Work_Order__c, FSSK__FSK_Work_Order__r.WorkOrderNumber, 
                          Account.Name, FSSK__FSK_Work_Order__r.Quote_PO_Number__c, FSSK__FSK_Work_Order__r.Address From ServiceAppointment 
                          Where SchedStartTime = TODAY AND Status != 'Canceled' AND Status != 'Completed' AND RecordType.Name = 'OV/Install' 
                          Order By SchedStartTime Desc];   
            }               
            if (saList.size() > 0) {
                List<ID> woIds = new List<ID>();
                for (ServiceAppointment sa: saList) {
                    if (!woIds.contains(sa.FSSK__FSK_Work_Order__c)) {
                        woIds.add(sa.FSSK__FSK_Work_Order__c);   
                    }
                }
                //system.debug('# of WO: '+woIds.size());
                
                Map<Id,List<ContentVersion>> woIdToCvs = getRelatedPhotos(woIds);
                
                List<Id> processedIds = new List<Id>();
                for (ServiceAppointment sa: saList) {
                    if (!processedIds.contains(sa.FSSK__FSK_Work_Order__c)) {
                        ServiceAppointmentPhotosListWrapper saplw = new ServiceAppointmentPhotosListWrapper();
                        saplw.saRecord = sa;
                        if (woIdToCvs.get(sa.FSSK__FSK_Work_Order__c) != null) {
                            List<ContentVersion> cvs = woIdToCvs.get(sa.FSSK__FSK_Work_Order__c);
                            saplw.photosCount = cvs.size();
                            saplw.photos = cvs;
                        } else {
                            saplw.photosCount = 0;
                        }
                        sapList.add(saplw);   
                        processedIds.add(sa.FSSK__FSK_Work_Order__c);
                    }
                }
                
                //system.debug('sapList count: '+sapList.size());
                return sapList;
            }
            else {
                return sapList;   
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static map<Id, list<ContentVersion>> getRelatedPhotos(list<Id> lstParentIds) {
        
        map<Id, list<ContentVersion>> mapParentIdAndFiles = new map<Id, list<ContentVersion>>();
        map<Id, Id> mapCntIdParentId = new map<Id, Id>();
        
        for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN :lstParentIds]) {
            mapCntIdParentId.put(cntLink.ContentDocumentId, cntLink.LinkedEntityId);
        }
        
        if(!mapCntIdParentId.isEmpty()) {
            for(ContentVersion cv :  [SELECT Id, Title, VersionData, ContentDocumentId, FileType, ContentSize, FileExtension, VersionNumber, CreatedDate FROM ContentVersion 
                                      WHERE ContentDocumentId IN :mapCntIdParentId.keySet() AND LastModifiedDate = TODAY AND IsLatest = True AND (FileType = 'JPG' OR FileType = 'PNG') 
                                      ORDER BY LastModifiedDate DESC]) {
                                          
                                          if(!mapParentIdAndFiles.containsKey(mapCntIdParentId.get(cv.ContentDocumentId))) {
                                              mapParentIdAndFiles.put(mapCntIdParentId.get(cv.ContentDocumentId), new list<ContentVersion>());
                                          }
                                          
                                          mapParentIdAndFiles.get(mapCntIdParentId.get(cv.ContentDocumentId)).add(cv);
                                      }
        }
        
        return mapParentIdAndFiles;
    } 
    public static String getAppName() {
        UserAppInfo userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
        AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition Where DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
        system.debug('appDefinition.Label: '+appDefinition.Label);
        return appDefinition.Label;
    }
}