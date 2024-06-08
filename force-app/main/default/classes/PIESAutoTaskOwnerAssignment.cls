public without sharing class PIESAutoTaskOwnerAssignment {
    
   
    public static void createAutoTaskansAssignOwners(Map<Id, Id> mapTaskIdWOId, Map<Id, Id> mapTaskIdSAId, Set<String> setTsIdTsType, List<Task> listTask){
        
        Set<Id> setOfUserIds = new Set<Id>();
        Set<Id> setBranchFamilyIds=new Set<Id>(); 
        Set<Id> setBranchIds=new Set<Id>(); 
        Set<String> setWOBusSeg = new Set<String>();
        Map<Id, String> mapWOIdWOSub = new Map<Id, String>();
        Map<Id, Id> mapWOIdWOOwnerId = new Map<Id, Id>(); Map<Id, String> mapWOIdStatus = new Map<Id, String>();
        List<Task> listTaskCreate = new List<Task>();
        Id piesRT = Schema.SObjectType.Task.RecordTypeInfosByDeveloperName.get('PIES_OV_Install').RecordTypeId;
        for(WorkOrder wo : [SELECT Id, Subject, Status, OwnerId, Branch__c, Branch__r.Branch_Family__c, Business_Segment_Quote__c
                             FROM WorkOrder where Id IN :mapTaskIdWOId.values()]){
            mapWOIdWOOwnerId.put(wo.Id, wo.OwnerId);
            mapWOIdWOSub.put(wo.Id, wo.Subject);
            setWOBusSeg.add(wo.Business_Segment_Quote__c); 
            mapWOIdStatus.put(wo.Id, wo.Status) ;                    
            // get Branch Family Id from WO
            if(string.isNotBlank(wo.Branch__r.Branch_Family__c))
            setBranchFamilyIds.add(wo.Branch__r.Branch_Family__c);
            // get Branch Id from wo
            if(string.isNotBlank(wo.Branch__c))
            setBranchIds.add(wo.Branch__c);
           
            
        }
        system.debug('setBranchFamilyIds : ' + setBranchFamilyIds);
        system.debug('setBranchIds : ' + setBranchIds);
        system.debug('setTsIdTsType : ' + setTsIdTsType);
        system.debug('setWOBusSeg : ' + setWOBusSeg);
        system.debug('Task Creation');
            for(Task ts : listTask){
                if(((mapWOIdStatus.get(mapTaskIdWOId.get(ts.Id))) != 'Completed') && ((mapWOIdStatus.get(mapTaskIdWOId.get(ts.Id))) != 'Canceled')){
                if(((ts.subject).contains('Review New Job') || ((ts.subject).contains('Book Order')) || ((ts.subject).contains('Review and Book Order')) || (ts.subject).contains('Purchase Product'))){
                	Task t = new Task();
                	t.Auto_Task__c = TRUE;
                	t.RecordTypeId = piesRT ;
                	t.WhatId = mapTaskIdWOId.get(ts.Id);
                	t.Appointment__c = mapTaskIdSAId.get(ts.Id);
                	if((ts.subject).contains('Review New Job')){
                    	t.ActivityDate = system.today() ;
                    	t.subject   = 'Review and Book Order'+ ' ' + '['+ MapWOIdWOSub.get(ts.WhatId) +']';
                    	t.type = 'Booking'; 
                        List<TaskByUserWrapper> lstWrapp = getOwnerId(t.type,setBranchFamilyIds,setBranchIds,setWOBusSeg);
                    	if(!lstWrapp.isEmpty()){
                    		lstWrapp.sort();
                		}
                        if(!lstWrapp.isEmpty()){
                        	for(TaskByUserWrapper tskwrp : lstWrapp){
                            	t.OwnerId  = tskwrp.UserId ;
                            	tskwrp.TaskCnt++;
                            	break;
                        	}
                    	}
                    
                    	if(t.OwnerId == null){
                        	t.OwnerId = mapWOIdWOOwnerId.get(ts.WhatId);
                    	}
                    }
                	else if(((ts.subject).contains('Book Order')) || ((ts.subject).contains('Review and Book Order'))){
                    	Date dt = system.today() ;
                    	t.ActivityDate = dt.addDays(1);
                    	t.subject = 'Purchase Product' + ' ' + '['+ MapWOIdWOSub.get(ts.WhatId) +']' ;
                    	t.type = 'Purchasing';
                        List<TaskByUserWrapper> lstWrapp = getOwnerId(t.type,setBranchFamilyIds,setBranchIds,setWOBusSeg);
                    	if(!lstWrapp.isEmpty()){
                    		lstWrapp.sort();
                		}
                    	if(!lstWrapp.isEmpty()){
                        	for(TaskByUserWrapper tskwrp : lstWrapp){
                            	t.OwnerId  = tskwrp.UserId ;
                            	tskwrp.TaskCnt++;
                            	break;
                        	}
                    	}
                        if(t.OwnerId == null){
                        	t.OwnerId = mapWOIdWOOwnerId.get(ts.WhatId);
                    	}
                	}
                	else if((ts.subject).contains('Purchase Product')){
                    	t.ActivityDate = system.today() ;
                   	 	t.subject = 'Schedule Order Fulfillment / Installation'+ ' ' + '['+ MapWOIdWOSub.get(ts.WhatId) +']' ;
                    	t.type = 'Scheduling';
                        List<TaskByUserWrapper> lstWrapp = getOwnerId(t.type,setBranchFamilyIds,setBranchIds,setWOBusSeg);
                    	if(!lstWrapp.isEmpty()){
                    		lstWrapp.sort();
                		}
                    	if(!lstWrapp.isEmpty()){
                        	for(TaskByUserWrapper tskwrp : lstWrapp){
                            	t.OwnerId  = tskwrp.UserId ;
                            	tskwrp.TaskCnt++;
                            	break;
                        	}
                    	}
                        if(t.OwnerId == null){
                        	t.OwnerId = mapWOIdWOOwnerId.get(ts.WhatId);
                    	}

                	}
                	listTaskCreate.add(t);
                	system.debug('listTaskCreate :' + listTaskCreate);
                }
            }   
        }
        if(listTaskCreate.size() > 0){
            INSERT listTaskCreate ;
        }
    }
    
    public static List<TaskByUserWrapper> getOwnerId(String tsktype, Set<Id> setBranchFamilyIds, Set<Id> setBranchIds, Set<String> setWOBusSeg){
        Set<Id> setOfUserIds = new Set<Id>(); 
        for(ServiceResource sr : [SELECT Id, Name,RelatedRecordId, Primary_Branch_Family__c, Branch__r.Branch_Family__c, Project_Coordinator__c, 
                                        Assign_Tasks_OV__c, Assign_Tasks_Booking__c,Assign_Tasks_Purchasing__c,Assign_Tasks_Recovery__c,Assign_Tasks_Scheduling__c FROM 
                                        ServiceResource WHERE (Primary_Branch_Family__c IN :setBranchFamilyIds or Branch__c IN :setBranchIds) 
                                        AND Project_Coordinator__c = TRUE and RecordType.DeveloperName = 'Install_OV' AND isActive = TRUE AND Business_Segment__c IN : setWOBusSeg AND (Assign_Tasks_Purchasing__c = TRUE 
                                        OR Assign_Tasks_OV__c = TRUE OR Assign_Tasks_Scheduling__c = TRUE OR Assign_Tasks_Recovery__c = TRUE OR Assign_Tasks_Booking__c = TRUE)]){       
                if(tsktype == 'Order Verification' && sr.Assign_Tasks_OV__c == TRUE){
                    setOfUserIds.add(sr.RelatedRecordId);
                }
                else if(tsktype == 'Scheduling' && sr.Assign_Tasks_Scheduling__c == TRUE){
                    setOfUserIds.add(sr.RelatedRecordId);
                }
                else if(tsktype =='Recovery' && sr.Assign_Tasks_Recovery__c == TRUE){
                    setOfUserIds.add(sr.RelatedRecordId);
                }
                else if(tsktype == 'Booking' && sr.Assign_Tasks_Booking__c == TRUE){
                    setOfUserIds.add(sr.RelatedRecordId);
                }
                else if(tsktype == 'Purchasing' && sr.Assign_Tasks_Purchasing__c == TRUE){
                    setOfUserIds.add(sr.RelatedRecordId);
                }                
        }
        system.debug('setOfUserIds :' + setOfUserIds);
        AggregateResult[] lstTaskCountByUserCnt = [SELECT count(Id) cntTask, OwnerId FROM Task 
                                                   WHERE OwnerId IN : setOfUserIds AND OwnerId != NULL AND ActivityDate >= Today AND ((Status != 'Completed') OR (Status != 'Closed') OR (Status != 'Canceled'))
                                                   GROUP BY OwnerId 
                                                   ORDER BY COUNT(Id) ASC];
        system.debug('lstTaskCountByUserCnt: '+ lstTaskCountByUserCnt);
        List<TaskByUserWrapper> lstWrap = new List<TaskByUserWrapper>();
        set<String> setUserIdCountFound=new set<String>();
        if(!lstTaskCountByUserCnt.isEmpty()){
            for(AggregateResult aggResult : lstTaskCountByUserCnt){
                TaskByUserWrapper obj = new TaskByUserWrapper();
                obj.UserId = (String)aggResult.get('OwnerId');
                obj.TaskCnt = (Integer)aggResult.get('cntTask');
                lstWrap.add(obj);
                setUserIdCountFound.add((String)aggResult.get('OwnerId'));
            }
        }
            system.debug('setUserIdCountFound :' + setUserIdCountFound);
            // process for not found count
            for(String userId : setOfUserIds){
                if(!setUserIdCountFound.contains(userId)){
                    system.debug('userId : ' + userId);
                    TaskByUserWrapper obj = new TaskByUserWrapper();
                    obj.UserId = userId;
                    obj.TaskCnt = 0;
                    lstWrap.add(obj);
                }
            }
        
        system.debug('lstWrap: '+lstWrap);
        return lstWrap ;    
    }
                                                 
    Public Class TaskByUserWrapper implements Comparable{
        public String UserId;
        Public Integer TaskCnt;
        
        public Integer compareTo(Object objToCompare) {
            TaskByUserWrapper compareToEmp = (TaskByUserWrapper)objToCompare;
            if (TaskCnt == compareToEmp.TaskCnt) return 0;
            if (TaskCnt > compareToEmp.TaskCnt) return 1;
            return -1;     
        }
    }
}