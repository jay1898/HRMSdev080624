public without sharing class EmployeeController {
    
    
    @AuraEnabled
    public static string getEmployeeByUsernameAndPassword(String username, String password) {
        Map<String,Object> returnData = new Map<String,Object>();
        try {
            Employee__c  empdetail = [SELECT Id, Name, Username__c, Password__c, Clocked_In_Out_Status__c, Image__c,Email__c FROM Employee__c WHERE Username__c = :username LIMIT 1];
           if(empdetail != null){
                // Generating MD5 hash for the input password
                Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(password));
                String encodedHash = EncodingUtil.convertToHex(hash);
                
                // Comparing the hashed input password with the stored password hash
                if(encodedHash.equals(empdetail.Password__c)) {
                    returnData.put('status','success');
                    returnData.put('result',empdetail);
                    updateEmployeeRecord(username , true);
                } else {
                    returnData.put('status','error');
                }
            }
            else{
                returnData.put('status','error');
            }
            
        } catch (Exception e) {
            returnData.put('status','error');    
        }
        return Json.serialize(returnData);
    }
    
    
    @AuraEnabled
    public static Employee__c getUserRecordsDetails(String username) {
        List<Employee__c> employeeList = [SELECT Id, isLogin__c, Username__c,Email__c FROM Employee__c WHERE Username__c = :username LIMIT 1];
        if (!employeeList.isEmpty()) {
            return employeeList[0];
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Employee__c updateEmployeeRecord(string usernameId , Boolean isLogin){
        
        Employee__c  empdetail = [SELECT Id, Name, Username__c,isLogin__c,Email__c FROM Employee__c WHERE Username__c = :usernameId LIMIT 1];
        empdetail.isLogin__c = isLogin;
        update empdetail;
        return empdetail;
    }
    
    @AuraEnabled
    public static string updateData(String recordId, String ClockInOutStatus) {
        
        Employee__c  empdetail = [SELECT Id, Name, Username__c,Password__c, Clocked_In_Out_Status__c FROM Employee__c WHERE Id = :recordId LIMIT 1];
        // empdetail.Name = Name;
        empdetail.Clocked_In_Out_Status__c = ClockInOutStatus;
        update empdetail;
        
        return JSON.serialize(empdetail);
    }
    
    @AuraEnabled
    public static String insertClockinRecords(String EmpRecordId) {
        // 2023-08-25T18:00:24
        Datetime currentDatetime = Datetime.now();
        String formattedDatetime = currentDatetime.format('yyyy-MM-dd HH:mm:ss');
        Map<String, Object> returnData = new Map<String, Object>();
        
        try {
            // Id attendanceId = [SELECT Id, Employee__c, Date__c, Total_Clock_In_Hours__c FROM Attendance__c WHERE Employee__c = :EmpRecordId  AND Date__c = :Date.valueOf(formattedDatetime) LIMIT 1].Id;
            List<Attendance__c> attendanceId = [SELECT Id, Employee__c, Date__c,Total_Clock_In_Hours__c FROM Attendance__c WHERE Employee__c = :EmpRecordId  AND Date__c = :Date.valueOf(formattedDatetime) LIMIT 1];
            // if (attendanceList.isEmpty()) {
            //     throw new AuraHandledException('No associated Attendance record found for the employee.');
            // }
            
            // attendanceId = 'a075j00000ApvSnAAJ';
            if(attendanceId != null){
                
                Clock_In_Out__c clockInOutRecord = new Clock_In_Out__c();
                clockInOutRecord.Employee__c = EmpRecordId;
                clockInOutRecord.Attendance__c = attendanceId[0].Id;
                String dt = (String)formattedDatetime;
                clockInOutRecord.Clock_In_Time__c = Datetime.valueOf(dt);
                insert clockInOutRecord;
                
                returnData.put('status', 'success');
                returnData.put('result', clockInOutRecord);
            } 
            
        } catch (Exception ex) {
            returnData.put('status', 'error');
            returnData.put('error', ex.getMessage()); // Include error message in response
        }
        
        return JSON.serialize(returnData);
    }
    
    @AuraEnabled
    public static string updateClockoutRecords(String EmpRecordId, Datetime ClockOutTime) {
        // Clock_In_Out__c clockInOutRecord = [SELECT Id, Employee__c, Clock_In_Time__c, Clock_Out_Time__c, Date__c,Attendance__c FROM Clock_In_Out__c WHERE Employee__c = :EmpRecordId ORDER BY CreatedDate DESC LIMIT 1];
        List<Clock_In_Out__c> clockInOutRecords = [SELECT Id, Employee__c, Clock_In_Time__c, Clock_Out_Time__c, Date__c, Attendance__c FROM Clock_In_Out__c WHERE Employee__c = :EmpRecordId ORDER BY CreatedDate DESC LIMIT 1];
        
        if (!clockInOutRecords.isEmpty()) {
            Clock_In_Out__c clockInOutRecord = clockInOutRecords[0];
            Datetime currentDatetime = Datetime.now();
            String formattedDatetime = currentDatetime.format('yyyy-MM-dd HH:mm:ss');
            String dt = (String)formattedDatetime;
            clockInOutRecord.Clock_Out_Time__c = Datetime.valueOf(dt);
            
            
            Long timeDifferenceMillis = clockInOutRecord.Clock_Out_Time__c.getTime() - clockInOutRecord.Clock_In_Time__c.getTime();
            Integer totalMinutesWorked = (Integer)(timeDifferenceMillis / (1000 * 60));
            
            Integer hoursWorked = totalMinutesWorked / 60;
            Integer minutesWorked = totalMinutesWorked - (hoursWorked * 60);
            
            Decimal fractionalHours = Decimal.valueOf(minutesWorked) / 60.0;
            
            clockInOutRecord.Daily_Hours__c = hoursWorked + fractionalHours;
            
            update clockInOutRecord;
            
            
            // update clockInOutRecord;
            
            return JSON.serialize(clockInOutRecord);
        } else {
            // Handle the case when no records are found
            return 'No matching records found';
        }
    }
    
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
    
    // @AuraEnabled
    // public static Map<String,Object> getLeaveData(){
    //     Map<String,Object> leaveMap = new Map<String,Object>();
        
    //     Schema.DescribeFieldResult leaveTypefieldResult = Schema.Leave_Request__c.Leave_Type__c.getDescribe();
    //     List<Schema.PicklistEntry> leaveTypepickListValues = leaveTypefieldResult.getPicklistValues();
    //     List<String> leaveTypeList = new List<String>();
    //     for (Schema.PicklistEntry pickListEntry : leaveTypepickListValues) {
    //         String leaveTypeValue = pickListEntry.getValue();
    //         leaveTypeList.add(leaveTypeValue);
    //     }
    //     leaveMap.put('leaveType', leaveTypeList);
    //     return leaveMap;

    //     // Fetching Leave_Duration__c picklist values
    //     Schema.DescribeFieldResult leaveDurationFieldResult = Schema.Leave_Request__c.Leave_Duration__c.getDescribe();
    //     List<Schema.PicklistEntry> leaveDurationPicklistValues = leaveDurationFieldResult.getPicklistValues();
    //     List<String> leaveDurationList = new List<String>();
    //     for (Schema.PicklistEntry pickListEntry : leaveDurationPicklistValues) {
    //         String leaveDurationValue = pickListEntry.getValue();
    //         leaveDurationList.add(leaveDurationValue);
    //     }
    //     leaveMap.put('leaveDuration', leaveDurationList);
        
    //     return leaveMap;
    // }

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



    @AuraEnabled
public static String saveWFHData(Object wfhRequest, String EmpRecordId, Decimal numberOfDays) {
    try {
        Datetime currentDatetime = Datetime.now();
        Date formattedDate = currentDatetime.date();
        List<Work_From_Home__c> wfhrecord = [SELECT Id, Employee__c, Start_Date__c, Applied_WFH_Date__c, Number_of_Days__c, End_Date__c, Work_From_Home_Type__c FROM Work_From_Home__c WHERE Employee__c = :EmpRecordId];

        // Null check for wfhRequest
        if (wfhRequest == null) {
            throw new AuraHandledException('WFH request is null.');
        }

        // Serialize and deserialize the incoming request
        String jsonWFHList = JSON.serialize(wfhRequest);
        Map<String, Object> wfhRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonWFHList);

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

        wfh.Reason__c = (String) wfhRecords.get('Reason');
        wfh.Work_From_Home_Type__c = (String) wfhRecords.get('wfhType');
        wfh.Applied_WFH_Date__c = formattedDate;
        wfh.Employee__c = EmpRecordId;
        wfh.Number_of_Days__c = numberOfDays;

        // Insert the record
        insert wfh;

        // Return the ID of the inserted record
        return wfh.Id;
    } catch (Exception ex) {
        // Log the error for debugging purposes
        throw new AuraHandledException('An error occurred while saving WFH records: ' + ex.getMessage());
    }
}

// @AuraEnabled
// public static String saveLeaveData(Object leaveRequest, String EmpRecordId, Integer numberOfDays) {
//     try {
//         Datetime currentDatetime = Datetime.now();
//         Date formattedDate = currentDatetime.date();
//         List<Leave_Request__c> leaveRecord = [SELECT Id, Employee__c, From_Date__c, Applied_Leave_Date__c, To_Date__c, Reason_for_Leave__c, Leave_Type__c,Leave_Duration__c,Number_of_Days__c FROM Leave_Request__c WHERE Employee__c = :EmpRecordId];

//         // Null check for leaveRequest
//         if (leaveRequest == null) {
//             throw new AuraHandledException('Leave request is null.');
//         }

//         // Serialize and deserialize the incoming request
//         String jsonLeaveList = JSON.serialize(leaveRequest);
//         Map<String, Object> leaveRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonLeaveList);
//         System.debug('All Object darta @@@@@@@@@@@'+leaveRecords);
//         Leave_Request__c leave = new Leave_Request__c();
//         String frDate = (String) leaveRecords.get('FromDate');
//         String toDate = (String) leaveRecords.get('ToDate');

//         // Null checks for frDate and toDate
//         if (frDate != null) {
//             leave.From_Date__c = Date.valueOf(frDate);
//         }

//         if (toDate != null) {
//             leave.To_Date__c = Date.valueOf(toDate);
//         }

//         leave.Reason_for_Leave__c = (String) leaveRecords.get('Reason');
//         leave.Leave_Type__c = (String) leaveRecords.get('leaveType');
//         leave.Leave_Duration__c = (String) leaveRecords.get('leaveDuration');
//         leave.From_Date_Leave__c = (String) leaveRecords.get('fromDateLeaveDurationOption');
//         leave.To_Date_Leave__c = (String) leaveRecords.get('toDateleaveDurationOption');

        
//         leave.Applied_Leave_Date__c = formattedDate;
//         leave.Employee__c = EmpRecordId;
//         leave.Number_of_Days__c = numberOfDays;
//         // Insert the record
//         insert leave;

//         // Return the ID of the inserted record
//         return leave.Id;

//     } catch (Exception ex) {
//         throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
//     }
// }

@AuraEnabled
public static String saveLeaveData(Object leaveRequest, String EmpRecordId, Decimal numberOfDays,Decimal paidLeave, Decimal unpaidLeave) {
    System.debug('All Object paid @@@@@@@@@@@ ' + paidLeave);
    System.debug('All Object unpaid @@@@@@@@@@@ ' + unpaidLeave);
    try {
        Datetime currentDatetime = Datetime.now();
        Date formattedDate = currentDatetime.date();
        List<Leave_Request__c> leaveRecord = [SELECT Id, Employee__c, From_Date__c,To_Date_Leave__c,From_Date_Leave__c, Applied_Leave_Date__c, To_Date__c, Reason_for_Leave__c, Leave_Type__c,Leave_Duration__c,Number_of_Days__c FROM Leave_Request__c WHERE Employee__c = :EmpRecordId];
		System.debug('leaveRecord@@@@ ' + leaveRecord);
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

        // Create records for paid leave
        Map<String, Leave_Request__c> empIdLeaveMap = new Map<String, Leave_Request__c>();
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

    
//     @AuraEnabled
//     public static String saveWFHData(Object wfhRequest , String EmpRecordId) {
//         try {
//             Datetime currentDatetime = Datetime.now();
//             // String formattedDatetime = currentDatetime.format('yyyy-MM-dd HH:mm:ss');
//             Date formattedDate = currentDatetime.date(); 
//             List<Work_From_Home__c> wfhrecord = [select id, Employee__c, Start_Date__c, Applied_WFH_Date__c, End_Date__c from Work_From_Home__c where Employee__c = :EmpRecordId];
//             // Serialize and deserialize the incoming request
//             String jsonWFHList = JSON.serialize(wfhRequest);
//             Map<String, Object> wfhRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonWFHList);
            
//             // Create a new Work_From_Home__c record
//             Work_From_Home__c wfh = new Work_From_Home__c();
//             String frDate = (String) wfhRecords.get('FromDate');
//             String toDate = (String) wfhRecords.get('ToDate');
            
//             wfh.Start_Date__c = Date.valueOf(frDate);
//             wfh.End_Date__c = Date.valueOf(toDate);
//             wfh.Reason__c = (String) wfhRecords.get('Reason');
//             wfh.Work_From_Home_Type__c = (String) wfhRecords.get('wfhType');
//             wfh.Applied_WFH_Date__c = formattedDate;
            
//             wfh.Employee__c = EmpRecordId;
            
            
//             // Insert the record
//             insert wfh;
            
//             // Return the ID of the inserted record
//             return wfh.Id;
//         } catch (Exception ex) {
//             // Log the error for debugging purposes
//             throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
//         }
//     }

// //     @AuraEnabled
// // public static String saveLeaveData(Object leaveRequest, String EmpRecordId) {
// //     try {
// //         if (leaveRequest != null) {
// //             Datetime currentDatetime = Datetime.now();
// //             Date formattedDate = currentDatetime.date();
// //             List<Leave_Request__c> leaveRecord = [select id, Employee__c, From_Date__c, Applied_Leave_Date__c, To_Date__c, Reason_for_Leave__c, Leave_Type__c from Leave_Request__c where Employee__c = :EmpRecordId];
// //             String jsonLeaveList = JSON.serialize(leaveRequest);
// //             Map<String, Object> leaveRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonLeaveList);

// //             Leave_Request__c leave = new Leave_Request__c();
// //             String frDate = (String) leaveRecords.get('From_Date__c');
// //             String toDate = (String) leaveRecords.get('To_Date__c');

// //             if (frDate != null && toDate != null) {
// //                 leave.From_Date__c = Date.valueOf(frDate);
// //                 leave.To_Date__c = Date.valueOf(toDate);
// //                 leave.Reason_for_Leave__c = (String) leaveRecords.get('Reason_for_Leave__c');
// //                 leave.Leave_Type__c = (String) leaveRecords.get('Leave_Type__c');
// //                 leave.Employee__c = EmpRecordId;

// //                 // Insert the record
// //                 insert leave;

// //                 // Return the ID of the inserted record
// //                 return leave.Id;
// //             } else {
// //                 throw new AuraHandledException('From_Date__c or To_Date__c is null');
// //             }
// //         } else {
// //             throw new AuraHandledException('leaveRequest is null');
// //         }
// //     } catch (Exception ex) {
// //         throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
// //     }
// // }

    
// @AuraEnabled
//     public static String saveLeaveData(Object leaveRequest , String EmpRecordId) {
//         try {
//             Datetime currentDatetime = Datetime.now();
//             Date formattedDate = currentDatetime.date();
//             List<Leave_Request__c> leaveRecord = [select id, Employee__c, From_Date__c, Applied_Leave_Date__c, To_Date__c,Reason_for_Leave__c,Leave_Type__c from Leave_Request__c where Employee__c = :EmpRecordId];
//             String jsonLeaveList = JSON.serialize(leaveRequest);
//             Map<String, Object> leaveRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonLeaveList);
            
//             Leave_Request__c leave = new Leave_Request__c();
//             String frDate = (String) leaveRecords.get('FromDate');
//             String toDate = (String) leaveRecords.get('ToDate');
            
//             leave.From_Date__c = Date.valueOf(frDate);
//             leave.To_Date__c = Date.valueOf(toDate);
//             leave.Reason_for_Leave__c = (String) leaveRecords.get('Reason');
//             leave.Leave_Type__c = (String) leaveRecords.get('leaveType');
//             leave.Applied_Leave_Date__c = formattedDate;
//             leave.Employee__c = EmpRecordId;
            
//             // Insert the record
//             insert leave;
            
//             // Return the ID of the inserted record
//              return leave.Id;
            
            
//     } catch (Exception ex) {
//         throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
//     }
//     }

    
    @AuraEnabled
    public static void updateClockOutTime(String EmpRecordId, String clockOutDateTime) {
        Clock_In_Out__c clockInOutRecord = [SELECT Id, Clock_Out_Time__c, Employee__c FROM Clock_In_Out__c WHERE Employee__c = :EmpRecordId And Clock_Out_Time__c = null order by CreatedDate desc LIMIT 1];
       
        String DT = clockOutDateTime;
        
        clockInOutRecord.Clock_Out_Time__c = Datetime.valueOf(DT);
        update clockInOutRecord;
    }
    //SELECT Id, Clock_Out_Time__c, Employee__c FROM Clock_In_Out__c WHERE Employee__c = :EmpRecordId And Clock_Out_Time__c = null order by CreatedDate desc LIMIT 1
    // for since login 
    @AuraEnabled
    public static Datetime getClockInTime(String EmpRecordId) {
        List<Clock_In_Out__c> clockInOutRecord = [SELECT Id, Clock_Out_Time__c, Clock_In_Time__c, Employee__c FROM Clock_In_Out__c WHERE Employee__c = :EmpRecordId And Clock_Out_Time__c = null AND CreatedDate = TODAY order by CreatedDate desc ];
       
        if(clockInOutRecord.size()>0) return clockInOutRecord[0].Clock_In_Time__c;
        
        return null;
        
    }
@AuraEnabled
    public static String getAttendanceTotalClockInHours(String EmpRecordId) {
           String formulaFieldValue = '';
        try {
            Attendance__c attendanceData = [SELECT Id, Total_Clock_In_Out_time__c,Date__c,Employee__c
                                            FROM Attendance__c
                                            WHERE Date__c = TODAY
                                            AND Employee__c = :EmpRecordId
                                            LIMIT 1];
           if (attendanceData != null) {
                return String.valueOf(attendanceData.Total_Clock_In_Out_time__c);
            } else {
                return ('No attendance data found for the given Employee ID and today\'s date.');
            }
        } catch (Exception e) {
            return  ('Exception occurred: ' + e.getMessage());
        }
        // return formulaFieldValue;
    }


//     @AuraEnabled
// public static String getAttendanceTotalClockInHours(String EmpRecordId) {
//     String totalClockInHours = '';
//      Attendance__c attendanceData;
//     try{
  
//     attendanceData = [SELECT Id, Total_Clock_In_Hours__c,Total_Clock_In_Out_time__c,Date__c,Employee__c
//                                           FROM Attendance__c
//                                           WHERE Date__c = TODAY
//                                           AND Employee__c = :EmpRecordId
//                                           LIMIT 1];
//     }catch (QueryException e) {
//         // Handle the query exception appropriately
//         System.debug('Query Exception: ' + e.getMessage());
//         return totalClockInHours; // or null, or any other appropriate action
//     }
    
//     if (attendanceData != null) {
//         totalClockInHours = String.valueOf(attendanceData.Total_Clock_In_Out_time__c);
//     }
    
//     return totalClockInHours; 
// }
    @AuraEnabled
    public static List<Clock_In_Out__c> getClockInOutData(String employeeId) {
        // Date oneDayBeforeToday = Date.today().addDays(-1);
        // Date oneDayBeforeToday = Date.today();
        List<Clock_In_Out__c> clockInOutList = [SELECT Id, Name, CreatedDate, Clock_In_Time__c, Clock_Out_Time__c, Date__c  FROM Clock_In_Out__c WHERE Employee__c = :employeeId And Clock_Out_Time__c = null  And Clock_In_Time__c != TODAY order by Clock_In_Time__c desc];
        return clockInOutList;
    }
    
    @AuraEnabled
    public static String getUserEmailAndSendEmail(String username) {
        
        Employee__c employee = [SELECT Id, Name, Email__c,Password_Reset_Key__c,Username__c FROM Employee__c WHERE Username__c =:username LIMIT 1];
        if (employee != null) {
            Blob hashValue = Crypto.generateDigest('MD5', Blob.valueOf(employee.Id));
            employee.Password_Reset_Key__c = EncodingUtil.convertToHex(hashValue);
            
            List<Employee__c> employeesToUpdate = new List<Employee__c>();
            employeesToUpdate.add(employee);
            
            update employeesToUpdate; // Perform the update outside of the loop
            
            String email = sendRestPasswordEmail(employee);
            return email;
        } else {
            // Handle the case where no employee with the given username is found
            return 'Employee not found';
        }
    }
    
    @AuraEnabled
    public static String sendRestPasswordEmail(Employee__c employee){
        if (employee != null) {
            // String email = '';
            // email = employee.Email__c;
            
            // // Create an email message
            // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // // Set the recipient's email address
            // mail.setToAddresses(new String[]{email});
            
            // // Set the email subject and body
            // String emailBody = '<p>Forgot your password? No worries! We have got you covered,</p><p></p><p> Click the "Reset Password" link below:</p> https://itechcloudsolution--itechdev.sandbox.my.site.com/hrms/s/?forgetPass=true&UserName='+employee.Username__c+'&UniqueEmpTempId='+employee.Password_Reset_Key__c;
            // mail.setSubject('Password Reset Request');
            // mail.setHtmlBody(emailBody);
            
            //mail.setPlainTextBody('https://itechcloudsolution--itechuat.sandbox.my.site.com/s/?forgetPass=true&UserName='+employee.Username__c+'&UniqueEmpTempId='+employee.Password_Reset_Key__c);
            
            // Send the email
            
            EmailTemplate template = [SELECT Id,Name  FROM EmailTemplate WHERE Name  = 'Forgot Password Send Email' LIMIT 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if (template!=Null) {
                Contact con=[SELECT id from contact where email!=Null limit 1]; 
                // Sending the welcome email to the new employee
                if (employee.Email__c != null) {
                    mail.setTemplateId(template.Id);
                    mail.setWhatId(employee.Id);
                    mail.setTargetObjectId(con.Id); 
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setToAddresses(new List<String> { employee.Email__c });
                    
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                    
                    // Check the results for success or errors
                    for (Messaging.SendEmailResult result : results) {
                        if (result.isSuccess()) {
                            // Email was sent successfully
                            } else {
                            // Handle email send error
                            }
                    }
                }
            }
            else {
                }
            return employee.Email__c;
        }
        return null;
    }
    
    @AuraEnabled
    public static String updatePassword(String username, String newPassword) {
        try {
            Employee__c employee = [SELECT Id,Password__c FROM Employee__c WHERE Username__c = :username LIMIT 1];
            if (employee != null) {
                // employee.Password__c = newPassword; // Update the password field
                // Generate MD5 hash for the new password
                Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(newPassword));
                String encodedHash = EncodingUtil.convertToHex(hash);
                
                employee.Password__c = encodedHash; // Store the MD5 hash as the password
                update employee;
                return 'Password updated successfully';
            } else {
                return 'Employee not found';
            }
        } catch (Exception ex) {
            
            return 'Error updating password: ' + ex.getMessage();
            
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Work_From_Home__c> getWorkFromHomeRecords(String employeeId) {
        return [SELECT Id, Start_Date__c, End_Date__c,Reason__c,Applied_WFH_Date__c,Work_From_Home_Type__c,Employee__c,Status__c FROM Work_From_Home__c WHERE Employee__c = :employeeId];
    }

    @AuraEnabled
    public static String updateWorkFromHomeStatus(String recordId, String status) {
        Work_From_Home__c recordToUpdate = new Work_From_Home__c(Id = recordId, Status__c = status);
        update recordToUpdate;
        return status;
    }

    @AuraEnabled(cacheable=true)
    public static List<Leave_Request__c> getLeaveRequestRecords(String employeeId) {
        return [SELECT Id, Applied_Leave_Date__c,Employee__r.Number_of_Leaves__c, Number_of_Days__c, From_Date__c,Leave_Type__c,Leave_Duration__c,To_Date__c,Status__c,Reason_for_Leave__c,Employee__c FROM Leave_Request__c WHERE Employee__c = :employeeId];
    }
    
      @AuraEnabled(cacheable=true)
    public static Employee__c getLeaveRequests(String employeeId) {
        return [select id,Total_Half_Days__c,name,Total_Leave_Taken__c,Total_Work_From_Home_Days__c,Number_of_Leaves__c from Employee__c WHERE Id = :employeeId];
    }

     @AuraEnabled
    public static String updateLeaveRequestStatus(String recordId, String status) {
        Leave_Request__c recordToUpdate = new Leave_Request__c(Id = recordId, Status__c = status);
        update recordToUpdate;
        return status;
    }
    

}