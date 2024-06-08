public with sharing class LeaveAndWFHController {
    // work from home
    @AuraEnabled
    public static Map<String,Object> getWFHData(){
        Map<String,Object> wfhMap = new Map<String,Object>();
        
        Schema.DescribeFieldResult wfhTypefieldResult = Schema.Work_From_Home__c.Work_From_Home_Type__c.getDescribe();
        List<Schema.PicklistEntry> wfhTypepickListValues = wfhTypefieldResult.getPicklistValues();
        List<String> wfhTypeList = new List<String>();
        for (Schema.PicklistEntry pickListEntry : wfhTypepickListValues) {
            String wfhTypeValue = pickListEntry.getValue();
            wfhTypeList.add(wfhTypeValue);
        }
        wfhMap.put('wfhType', wfhTypeList);
        return wfhMap;
    }
    
    @AuraEnabled
    public static String saveWFHData(Object wfhRequest, String EmpRecordId, Decimal numberOfDays) {
        try {
            Datetime currentDatetime = Datetime.now();
            Date formattedDate = currentDatetime.date();
            List<Work_From_Home__c> wfhrecord = [SELECT Id, Employee__c, Start_Date__c, Applied_WFH_Date__c, Number_of_Days__c, End_Date__c, Work_From_Home_Type__c FROM Work_From_Home__c WHERE Employee__c = :EmpRecordId];
            system.debug('@@@@wfhrecord:::: '+wfhrecord);
            // Null check for wfhRequest
            if (wfhRequest == null) {
                throw new AuraHandledException('WFH request is null.');
            }
            
            // Serialize and deserialize the incoming request
            String jsonWFHList = JSON.serialize(wfhRequest);
            Map<String, Object> wfhRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonWFHList);
            system.debug('@@@@wfhRecords:::: '+wfhRecords);
            // Create a new Work_From_Home__c record
            Work_From_Home__c wfh = new Work_From_Home__c();
            String frDate = (String) wfhRecords.get('FromDate');
            String toDate = (String) wfhRecords.get('ToDate');
            
            // Null checks for frDate and toDate
            if (frDate != null) {
                wfh.Start_Date__c = Date.valueOf(frDate);
            }
            
            if (toDate != null) {
                wfh.End_Date__c = Date.valueOf(toDate);
            }
            system.debug('@@@(String) wfhRecords.ge'+(String) wfhRecords.get('Reason'));
            wfh.Reason__c = (String) wfhRecords.get('Reason');
            wfh.Work_From_Home_Type__c = (String) wfhRecords.get('wfhType');
            wfh.Applied_WFH_Date__c = formattedDate;
            wfh.Employee__c = EmpRecordId;
            wfh.Number_of_Days__c = numberOfDays;
            
            // Insert the record
            insert wfh;
            
            // Return the ID of the inserted record
            system.debug('@@@@wfh.Id:::: '+wfh.Id);
            return wfh.Id;
            
        } catch (Exception ex) {
            // Log the error for debugging purposes
            throw new AuraHandledException('An error occurred while saving WFH records: ' + ex.getMessage());
        }
    }
    
    // Leave request
    
    @AuraEnabled
    public static Map<String, Object> getLeaveData() {
        Map<String, Object> leaveMap = new Map<String, Object>();
        
        // Fetching Leave_Type__c picklist values
        Schema.DescribeFieldResult leaveTypeFieldResult = Schema.Leave_Request__c.Leave_Type__c.getDescribe();
        List<Schema.PicklistEntry> leaveTypePicklistValues = leaveTypeFieldResult.getPicklistValues();
        List<String> leaveTypeList = new List<String>();
        for (Schema.PicklistEntry pickListEntry : leaveTypePicklistValues) {
            String leaveTypeValue = pickListEntry.getValue();
            leaveTypeList.add(leaveTypeValue);
        }
        leaveMap.put('leaveType', leaveTypeList);
        
        // Fetching Leave_Duration__c picklist values
        Schema.DescribeFieldResult leaveDurationFieldResult = Schema.Leave_Request__c.Leave_Duration__c.getDescribe();
        List<Schema.PicklistEntry> leaveDurationPicklistValues = leaveDurationFieldResult.getPicklistValues();
        List<String> leaveDurationList = new List<String>();
        for (Schema.PicklistEntry pickListEntry : leaveDurationPicklistValues) {
            String leaveDurationValue = pickListEntry.getValue();
            leaveDurationList.add(leaveDurationValue);
        }
        leaveMap.put('leaveDuration', leaveDurationList);
        
        
        // Fetching From_Date_Leave__c picklist values
        Schema.DescribeFieldResult fromDateleaveDurationFieldResult = Schema.Leave_Request__c.From_Date_Leave__c.getDescribe();
        List<Schema.PicklistEntry> fromDateleaveDurationPicklistValues = fromDateleaveDurationFieldResult.getPicklistValues();
        List<String> fromDateleaveDurationList = new List<String>();
        for (Schema.PicklistEntry pickListEntry : fromDateleaveDurationPicklistValues) {
            String fromDateleaveDurationValue = pickListEntry.getValue();
            fromDateleaveDurationList.add(fromDateleaveDurationValue);
        }
        leaveMap.put('fromDateleaveDuration', fromDateleaveDurationList);
        
        // Fetching To_Date_Leave__c picklist values
        Schema.DescribeFieldResult toDateleaveDurationFieldResult = Schema.Leave_Request__c.To_Date_Leave__c.getDescribe();
        List<Schema.PicklistEntry> toDateleaveDurationPicklistValues = toDateleaveDurationFieldResult.getPicklistValues();
        List<String> toDateleaveDurationList = new List<String>();
        for (Schema.PicklistEntry pickListEntry : toDateleaveDurationPicklistValues) {
            String toDateleaveDurationValue = pickListEntry.getValue();
            toDateleaveDurationList.add(toDateleaveDurationValue);
        }
        leaveMap.put('toDateleaveDuration', toDateleaveDurationList);
        
        return leaveMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static Employee__c getLeaveRequests(String employeeId) {
        return [select id,Name,Number_of_Leaves__c from Employee__c WHERE Id = :employeeId];
    }
    
    @AuraEnabled
    public static String saveLeaveData(Object leaveRequest, String EmpRecordId, Decimal numberOfDays,Decimal paidLeave, Decimal unpaidLeave) {
        System.debug('All Object paid @@@@@@@@@@@ ' + paidLeave);
        System.debug('All Object unpaid @@@@@@@@@@@ ' + unpaidLeave);
        try {
            Datetime currentDatetime = Datetime.now();
            Date formattedDate = currentDatetime.date();
            List<Leave_Request__c> leaveRecord = [SELECT Id, Employee__c, From_Date__c,To_Date_Leave__c,From_Date_Leave__c, Applied_Leave_Date__c, To_Date__c, Reason_for_Leave__c, Leave_Type__c,Leave_Duration__c,Number_of_Days__c FROM Leave_Request__c WHERE Employee__c = :EmpRecordId];
            
            // Null check for leaveRequest
            if (leaveRequest == null) {
                throw new AuraHandledException('Leave request is null.');
            }
            
            // Serialize and deserialize the incoming request
            String jsonLeaveList = JSON.serialize(leaveRequest);
            Map<String, Object> leaveRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonLeaveList);
            System.debug('All Object darta @@@@@@@@@@@'+leaveRecords);
            
            // Retrieve values from the NoOfPaidAndUnpaidLeave map
            //  paidLeave = paidLeave;
            //  unpaidLeave = (Integer) leaveRecords.get('unpaidLeave');
            system.debug('@@@@:::: '+(String) leaveRecords.get('Reason'));
            // Create records for paid leave
            Map<String, Leave_Request__c> empIdLeaveMap = new Map<String, Leave_Request__c>();
            system.debug('@@@@paidLeave'+paidLeave);
            system.debug('@@@@unpaidLeave'+unpaidLeave);
            if (paidLeave > 0) {
                Leave_Request__c paidLeaveRecord = new Leave_Request__c();
                paidLeaveRecord.From_Date__c = Date.valueOf((String) leaveRecords.get('FromDate'));
                paidLeaveRecord.To_Date__c = Date.valueOf((String) leaveRecords.get('ToDate'));
                paidLeaveRecord.Reason_for_Leave__c = (String) leaveRecords.get('Reason');
                paidLeaveRecord.Leave_Duration__c = (String) leaveRecords.get('leaveDuration');
                paidLeaveRecord.From_Date_Leave__c = (String) leaveRecords.get('fromDateLeaveDurationOption');
                paidLeaveRecord.To_Date_Leave__c = (String) leaveRecords.get('toDateleaveDurationOption');
                paidLeaveRecord.Leave_Type__c = 'Paid Leave';
                paidLeaveRecord.Applied_Leave_Date__c = formattedDate;
                paidLeaveRecord.Employee__c = EmpRecordId;
                paidLeaveRecord.Number_of_Days__c = paidLeave;
                
                // Insert the record for paid leave
                insert paidLeaveRecord;
                system.debug('@@@@wfh.paidLeaveRecord:::: '+paidLeaveRecord.Id);
                empIdLeaveMap.put(EmpRecordId,paidLeaveRecord);
            }
            system.debug('@2empIdLeaveMap '+empIdLeaveMap);
            
            // Create records for unpaid leave
            if (unpaidLeave > 0) {
                Leave_Request__c unpaidLeaveRecord = new Leave_Request__c();
                unpaidLeaveRecord.From_Date__c = Date.valueOf((String) leaveRecords.get('FromDate'));
                unpaidLeaveRecord.To_Date__c = Date.valueOf((String) leaveRecords.get('ToDate'));
                unpaidLeaveRecord.Reason_for_Leave__c = (String) leaveRecords.get('Reason');
                unpaidLeaveRecord.Leave_Duration__c = (String) leaveRecords.get('leaveDuration');
                unpaidLeaveRecord.Leave_Type__c = 'Unpaid Leave';
                unpaidLeaveRecord.From_Date_Leave__c = (String) leaveRecords.get('fromDateLeaveDurationOption');
                unpaidLeaveRecord.To_Date_Leave__c = (String) leaveRecords.get('toDateleaveDurationOption');
                unpaidLeaveRecord.Applied_Leave_Date__c = formattedDate;
                unpaidLeaveRecord.Employee__c = EmpRecordId;
                unpaidLeaveRecord.Number_of_Days__c = unpaidLeave;
                
                // Insert the record for unpaid leave
                insert unpaidLeaveRecord;
                system.debug('@@@@unpaidLeaveRecord.Id:::: '+unpaidLeaveRecord.Id);
            }
            
            List<Employee__c> empList = [Select Id, Name,Number_of_Leaves__c from Employee__c where Id In:empIdLeaveMap.keySet()];
            for(Employee__c emp :empList){
                if(empIdLeaveMap.get(emp.Id).Leave_Type__c == 'Paid Leave' && empIdLeaveMap.containsKey(emp.Id) ){
                    emp.Number_of_Leaves__c = emp.Number_of_Leaves__c - empIdLeaveMap.get(emp.Id).Number_of_Days__c;
                }
            }
            
            update empList;
            
            // Return the ID of the inserted record (you may want to update this based on your specific logic)
            return 'Records created successfully';
            
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
        }
    }
    
    
    
}