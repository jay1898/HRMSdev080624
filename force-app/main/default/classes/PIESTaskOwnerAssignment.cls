public without sharing class  PIESTaskOwnerAssignment {
    
    @InvocableMethod(label='Owner Assignemnt')
    public static List<FlowOutputs> taskOwnerAssignment(List<FlowInputs> request){
        
        Set<FlowOutputs> results = new Set<FlowOutputs>(); String tskType = '';
        FlowOutputs fOut = new FlowOutputs();
        String workID = request[0].woId ;
        //system.debug('workID : ' + workID);
        Set<Id> setOfUserIds = new Set<Id>();Set<Id> setBranchFamilyIds=new Set<Id>(); Set<String> setWOBusSeg = new Set<String>();
        Set<Id> setBranchIds=new Set<Id>();Map<String, List<String>> BranchFamilyWiseSRMap = new Map<String, List<String>>();
        String woOwnerId = '';
        for(WorkOrder wo : [SELECT Id, OwnerId,Branch__c, Branch__r.Branch_Family__c,Business_Segment_Quote__c FROM WorkOrder where Id =: workID]){
            setWOBusSeg.add(wo.Business_Segment_Quote__c);
            woOwnerId = wo.OwnerId;
            // get Branch Family Id from WO
            if(string.isNotBlank(wo.Branch__r.Branch_Family__c))
            setBranchFamilyIds.add(wo.Branch__r.Branch_Family__c);
            // get Branch Id from wo
            if(string.isNotBlank(wo.Branch__c))
            setBranchIds.add(wo.Branch__c);
            
        }
        system.debug('setBranchFamilyIds : ' + setBranchFamilyIds);
        system.debug('setBranchIds : ' + setBranchIds);
        system.debug('taskType  : ' + request[0].tasktype);
        
        for(ServiceResource sr : [SELECT Id, Name,RelatedRecordId, Primary_Branch_Family__c, Branch__r.Branch_Family__c, Project_Coordinator__c, 
                                        Assign_Tasks_OV__c, Assign_Tasks_Booking__c,Assign_Tasks_Purchasing__c,Assign_Tasks_Recovery__c,Assign_Tasks_Scheduling__c FROM 
                                        ServiceResource WHERE (Primary_Branch_Family__c IN :setBranchFamilyIds or Branch__c IN :setBranchIds) 
                                        AND Project_Coordinator__c = TRUE and RecordType.DeveloperName = 'Install_OV' AND Business_Segment__c IN : setWOBusSeg AND isActive = TRUE AND (Assign_Tasks_Purchasing__c = TRUE 
                                        OR Assign_Tasks_OV__c = TRUE OR Assign_Tasks_Scheduling__c = TRUE OR Assign_Tasks_Recovery__c = TRUE OR Assign_Tasks_Booking__c = TRUE)]){
										
										if((request[0].tasktype == 'OV' || request[0].tasktype == 'Order Verification') && sr.Assign_Tasks_OV__c == TRUE){
												setOfUserIds.add(sr.RelatedRecordId);
										}
										else if(request[0].tasktype == 'Scheduling' && sr.Assign_Tasks_Scheduling__c == TRUE){
											setOfUserIds.add(sr.RelatedRecordId); 
										}
										else if(request[0].tasktype == 'Recovery' && sr.Assign_Tasks_Recovery__c == TRUE){
											setOfUserIds.add(sr.RelatedRecordId); 
										}
										else if(request[0].tasktype == 'Booking' && sr.Assign_Tasks_Booking__c == TRUE){
											setOfUserIds.add(sr.RelatedRecordId); 
										}
										else if(request[0].tasktype == 'Purchasing' && sr.Assign_Tasks_Purchasing__c == TRUE){
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
            if(lstWrap.size() > 0 && !lstWrap.isEmpty() ){
                lstWrap.sort();
                for(TaskByUserWrapper tskwrp : lstWrap){
                    if(results.size() == 0){
                        fOut.tskOwnerid = tskwrp.UserId ;
                        results.add(fOut);
                        tskwrp.TaskCnt++;
                        break;
                    }
                }
            }
         
        system.debug('results : ' + results);
        if(results.isEmpty()){
            fOut.tskOwnerid = woOwnerId ;
            results.add(fOut);
            system.debug('result wo owner :' + results);
        }
        List<FlowOutputs> listRes = new List<FlowOutputs>(results);  
        system.debug('results in list :' + listRes);
        return listRes ;  
    }
                                                 
    public class FlowInputs{
            @InvocableVariable
            public string tasktype;
            
            @InvocableVariable
            public string woId;
    }
    public class FlowOutputs{
           @InvocableVariable
            public string tskOwnerid;
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