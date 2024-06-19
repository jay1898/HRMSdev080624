/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-30-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class EmployeeController {
    
    @AuraEnabled
    public static string getEmployeeByUsernameAndPassword(String username, String password) {
        Map<String,Object> returnData = new Map<String,Object>();
        try {
            Employee__c  empdetail = [SELECT Id, Name, EmpCode__c, Department__c, Role__c, Address__c, Emergency_Contact_No__c, Username__c, Password__c, Clocked_In_Out_Status__c, Image__c,Email__c FROM Employee__c WHERE Username__c = :username LIMIT 1];
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
                
            }
            
        } catch (Exception e) {
            returnData.put('status','error');    
        }
        return Json.serialize(returnData);
    }   
    /* @AuraEnabled
public static String getEmployeeByUsernameAndPassword(String username, String password) {
Map<String,Object> returnData = new Map<String,Object>();
try {
// Convert input username to lowercase
String lowercaseUsername = username.toLowerCase();

// Query for the employee record using the lowercase username
List<Employee__c> empdetails = [SELECT Id, Name, Role__c, Username__c, Password__c, Clocked_In_Out_Status__c, Image__c, Email__c FROM Employee__c WHERE Username__c = :lowercaseUsername LIMIT 1];

if(!empdetails.isEmpty()){
Employee__c empdetail = empdetails[0];
// Generating MD5 hash for the input password
Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(password));
String encodedHash = EncodingUtil.convertToHex(hash);

// Comparing the hashed input password with the stored password hash
if(encodedHash.equals(empdetail.Password__c)) {
returnData.put('status','success');
returnData.put('result',empdetail);
updateEmployeeRecord(lowercaseUsername , true); // Update the record with lowercase username
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
return JSON.serialize(returnData);
}*/
    
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
    public static List<Notification__c> getNotificationInformation(String username) {
        List<Notification__c> notificationList =[Select id,Type__c,Group_Label__c,order__c  from Notification__c Where Active__c=true and (Expiration_Date__c=null OR Expiration_Date__c>=Today) and Employee__c=null order by Group_Label__c,order__c ];
        notificationList.addAll([Select id,Type__c,Description__c,Group_Label__c,order__c  from Notification__c Where Active__c=true and (Expiration_Date__c=null OR Expiration_Date__c>=Today) and Employee__c!=null and Employee__r.Username__c=:username order by Group_Label__c,order__c ]);
        return notificationList;
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
                clockInOutRecord.ClockIn_Devices__c = 'From UI';
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
            clockInOutRecord.ClockIn_Devices__c = 'From UI';
            
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
        System.debug('leaveMap @@@@@@@@@@@ ' + leaveMap);
        return leaveMap;
        
    }
    
    @AuraEnabled
    public static String saveWFHData(Object wfhRequest, String EmpRecordId, Decimal numberOfDays) {
        try {
            system.debug('wfhRequest:::--->> '+JSON.serialize(wfhRequest));
            Datetime currentDatetime = Datetime.now();
            Date formattedDate = currentDatetime.date();
            
            // Deserialize the incoming request
            String jsonWFHList = JSON.serialize(wfhRequest);
            Map<String, Object> wfhRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonWFHList);
            
            // Extract start date, end date, and leave type from the request
            String frDate = (String) wfhRecords.get('FromDate');
            String toDate = (String) wfhRecords.get('ToDate');
            String leaveType = (String) wfhRecords.get('wfhType');
            
            Date newFromDate = Date.valueOf(frDate); 
            Date newToDate = Date.valueOf(toDate);  
            // Check if a record with the same start date, end date, and leave type already exists
            List<Work_From_Home__c> existingRecords = [SELECT Id, Name, Email__c, Employee__c, End_Date__c, Reason__c, Start_Date__c, Work_From_Home_Type__c, Applied_WFH_Date__c, Status__c, Number_of_Days__c FROM Work_From_Home__c
                                                       WHERE Employee__c = :EmpRecordId AND Status__c !='Cancelled' AND Status__c !='Rejected'
                                                       AND (
                                                           (Start_Date__c <= :newToDate AND End_Date__c >= :newFromDate)
                                                           OR (Start_Date__c <= :newFromDate AND End_Date__c >= :newFromDate)
                                                       )     ];
            system.debug('existingRecords:::--->> '+existingRecords);
            
            if (existingRecords.size() > 0 ) {
                //system.debug('WFHStatus.Status__c :::--->> '+WFHStatus.Status__c);
                throw new AuraHandledException('A record with the same start date, end date, leave type, and leave duration already exists.');
            }
            system.debug('existingRecords:::--->> '+existingRecords);
            // Create a new Work_From_Home__c record
            Work_From_Home__c wfh = new Work_From_Home__c();
            wfh.Start_Date__c = Date.valueOf(frDate);
            wfh.End_Date__c = Date.valueOf(toDate);
            wfh.Reason__c = (String) wfhRecords.get('Reason');
            wfh.Work_From_Home_Type__c = leaveType;
            wfh.Applied_WFH_Date__c = formattedDate;
            wfh.Employee__c = EmpRecordId;
            wfh.Number_of_Days__c = numberOfDays;
            wfh.Status__c = 'Pending';
            system.debug('wfh:::--->> '+JSON.serialize(wfh));
            // Insert the record
            insert wfh;
            
            // Return the ID of the inserted record
            return wfh.Id;
        } catch (Exception ex) {
            // Log the error for debugging purposes
            throw new AuraHandledException('An error occurred while saving WFH records: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String saveLeaveData(Object leaveRequest, String EmpRecordId, Decimal numberOfDays,Decimal paidLeave, Decimal unpaidLeave) {
        System.debug('All Object paid @@@@@@@@@@@ ' + paidLeave);
        System.debug('All Object unpaid @@@@@@@@@@@ ' + unpaidLeave);
        
        Employee__c EmpTEMPT = [select id,Total_Half_Days__c,name,Total_Leave_Taken__c,Total_Work_From_Home_Days__c,Number_of_Leaves__c, Leave_Balance__c FROM Employee__c WHERE Id= :EmpRecordId  ];
        System.debug('All Object unpaid1111 @@@@@@@@@@@ ' + EmpTEMPT.Number_of_Leaves__c);
        System.debug('All Object unpaid1111 @@@@@@@@@@@ ' + EmpTEMPT.Leave_Balance__c);
        
        if (numberOfDays > EmpTEMPT.Number_of_Leaves__c) {
            paidLeave = EmpTEMPT.Number_of_Leaves__c;
            unpaidLeave = numberOfDays - EmpTEMPT.Number_of_Leaves__c;
        }
        try {
            String jsonLeaveList = JSON.serialize(leaveRequest);
            Map<String, Object> leaveRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonLeaveList);
            System.debug('All Object leaveRecords @@@@@@@@@@@ ' + leaveRecords);
            String frDate = (String) leaveRecords.get('FromDate');
            String toDate = (String) leaveRecords.get('ToDate');
            String leaveType = (String) leaveRecords.get('leaveType');
            String leaveDuration = (String) leaveRecords.get('leaveDuration');
            
            Date newFromDate = Date.valueOf(frDate);
            Date newToDate = Date.valueOf(toDate);   
            
            //  // Check for existing records
            
            List<Leave_Request__c> existingRecords = [
                SELECT Id, Employee__c, From_Date__c,To_Date_Leave__c,From_Date_Leave__c, Applied_Leave_Date__c, To_Date__c, Reason_for_Leave__c, Leave_Type__c,Leave_Duration__c,Number_of_Days__c,Status__c
                FROM Leave_Request__c
                WHERE Employee__c = :EmpRecordId
                AND (
                    (From_Date__c <= :newToDate AND To_Date__c >= :newFromDate)
                    OR (From_Date__c <= :newFromDate AND To_Date__c >= :newFromDate)
                )
                
            ];
            
            system.debug('##$#existingRecords '+existingRecords);
            
            // If existing records found, throw an exception
            if (!existingRecords.isEmpty()) {
                for(Leave_Request__c leaveStatus : existingRecords){
                    system.debug('##$#leaveStatus.Status__c '+leaveStatus.Status__c);
                    // if (leaveStatus.Status__c != 'Cancelled' || leaveStatus.Status__c != 'Rejected') {
                    if (!(leaveStatus.Status__c == 'Cancelled' || leaveStatus.Status__c == 'Rejected')) {
                        system.debug('##$#leaveStatus.Status__cytre '+leaveStatus.Status__c);
                        throw new AuraHandledException('A record with the same start date, end date, leave type, and leave duration already exists.');
                    }
                    system.debug('##$#leaveStatus.hgfd '+leaveStatus.Status__c);
                }
                //throw new AuraHandledException('A record with the same start date, end date, leave type, and leave duration already exists.');
            }
            system.debug('##$#existingRecords '+existingRecords);
            Datetime currentDatetime = Datetime.now();
            Date formattedDate = currentDatetime.date();
            //List<Leave_Request__c> leaveRecord = [SELECT Id, Employee__c, From_Date__c,To_Date_Leave__c,From_Date_Leave__c, Applied_Leave_Date__c, To_Date__c, Reason_for_Leave__c, Leave_Type__c,Leave_Duration__c,Number_of_Days__c FROM Leave_Request__c WHERE Employee__c = :EmpRecordId];
            //System.debug('leaveRecord@@@@ ' + leaveRecord);
            // Null check for leaveRequest
            if (leaveRequest == null) {
                throw new AuraHandledException('Leave request is null.');
            }
            
            // Serialize and deserialize the incoming request
            System.debug('All Object darta @@@@@@@@@@@'+leaveRecords);
            // Retrieve values from the NoOfPaidAndUnpaidLeave map
            //  paidLeave = paidLeave;
            //  unpaidLeave = (Integer) leaveRecords.get('unpaidLeave');
            
            system.debug('@paidLeave-->> '+paidLeave);
            system.debug('@unpaidLeave-->> '+unpaidLeave);
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
                
                system.debug('@paidLeaveRecord-->> '+Json.serialize(paidLeaveRecord));
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
                
                system.debug('@unpaidLeaveRecord-->> '+Json.serialize(unpaidLeaveRecord));
                // Insert the record for unpaid leave
                insert unpaidLeaveRecord;
            }
            System.debug('empIdLeaveMap@@@@'+empIdLeaveMap);
            List<Employee__c> empList = [Select Id, Name,Number_of_Leaves__c from Employee__c where Id In:empIdLeaveMap.keySet() ];
            for(Employee__c emp :empList){
                if(empIdLeaveMap.get(emp.Id).Leave_Type__c == 'Paid Leave' && empIdLeaveMap.containsKey(emp.Id) ){
                    emp.Number_of_Leaves__c = emp.Number_of_Leaves__c - empIdLeaveMap.get(emp.Id).Number_of_Days__c;
                }
            }
            system.debug('@empList '+Json.serialize(empList));
            update empList;
            
            // Return the ID of the inserted record (you may want to update this based on your specific logic)
            return 'Records created successfully';
            
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateClockOutTime(String EmpRecordId, String clockOutDateTime) {
        Clock_In_Out__c clockInOutRecord = [SELECT Id, Clock_Out_Time__c, Employee__c FROM Clock_In_Out__c WHERE Employee__c = :EmpRecordId And Clock_Out_Time__c = null order by CreatedDate desc LIMIT 1];
        
        String DT = clockOutDateTime;
        
        clockInOutRecord.Clock_Out_Time__c = Datetime.valueOf(DT);
        clockInOutRecord.ClockIn_Devices__c = 'From UI';
        update clockInOutRecord;
    }

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
    
    @AuraEnabled
    public static List<Work_From_Home__c> getWorkFromHomeRecords(String employeeId) {
        return [SELECT Id, Start_Date__c, End_Date__c,Reason__c,Applied_WFH_Date__c,Number_of_Days__c,Work_From_Home_Type__c,Employee__c,Status__c FROM Work_From_Home__c WHERE Employee__c = :employeeId ORDER BY CreatedDate DESC];
    }
    
    @AuraEnabled
    public static String updateWorkFromHomeStatus(String recordId, String status) {
        Work_From_Home__c recordToUpdate = new Work_From_Home__c(Id = recordId, Status__c = status);
        update recordToUpdate;
        return status;
    }
    
    @AuraEnabled
    public static List<Leave_Request__c> getLeaveRequestRecords(String employeeId) {
        List<Leave_Request__c> leaveRequests = [SELECT Id, Applied_Leave_Date__c,Employee__r.Number_of_Leaves__c, Number_of_Days__c, From_Date__c,Leave_Type__c,Leave_Duration__c,To_Date__c,Status__c,Reason_for_Leave__c,Employee__c FROM Leave_Request__c WHERE Employee__c = :employeeId ORDER BY CreatedDate DESC];
        for (Leave_Request__c leaveRequest : leaveRequests) {
            if (leaveRequest.Leave_Duration__c == null) {
                leaveRequest.Leave_Duration__c = 'Custom';
            }
        }
        
        return leaveRequests;
        
    }
    
    @AuraEnabled
    public static Employee__c getLeaveRequests(String employeeId) { 
        return [select id,Total_Half_Days__c,name,Total_Leave_Taken__c,Total_Work_From_Home_Days__c,Number_of_Leaves__c, Leave_Balance__c from Employee__c WHERE Id = :employeeId ];
    }
    
    
    @AuraEnabled
    public static Employee__c getWFHRequests(String employeeId) {
        return [select id, Total_Work_From_Home_Days__c,Number_of_Leaves__c from Employee__c WHERE Id = :employeeId];
    }
    
    // This is used for Getting Count of Paid nad Unpaid Leave Type
    @AuraEnabled
    public static Map<String, Decimal> getLeaveCountByType(String employeeId) {
        Map<String, Decimal> leaveCountByTypeMap = new Map<String, Decimal>();
        List<AggregateResult> leaveReqAggregateList = [SELECT SUM(Number_of_Days__c) numLeaves, Leave_Type__c FROM Leave_Request__c WHERE Employee__r.Id = :employeeId AND Status__c  != 'Rejected' AND Status__c  !=  'Cancelled' GROUP BY Leave_Type__c];
        if(leaveReqAggregateList.size() > 0){
            for (AggregateResult aggResult : leaveReqAggregateList) {
                String leaveType = (String)aggResult.get('Leave_Type__c');
                Decimal leaveCount = (Decimal)aggResult.get('numLeaves');
                leaveCountByTypeMap.put(leaveType, leaveCount);
            }    
        }
        if (!leaveCountByTypeMap.isEmpty()) {
            return leaveCountByTypeMap; 
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String updateLeaveRequestStatus(String recordId, String status) {
        Leave_Request__c recordToUpdate = new Leave_Request__c(Id = recordId, Status__c = status);
        update recordToUpdate;
        return status;
    }
    
    @AuraEnabled
    Public static Integer getNumberOfNonBusinessDays(String startDate, String endDate){
        Date startDate1 = Date.valueOf(startDate);
        Date endDate1 = Date.valueOf(endDate);
        
        CalcBusinessDays calculator = new CalcBusinessDays();
        Integer count = calculator.getNoOfNonBusinessDaysBetweenDates(startDate1, endDate1);
        System.debug('Number of non-business days between ' + startDate + ' and ' + endDate + ': ' + count);
        return count; 
    }
    
    @AuraEnabled(cacheable = true)
    public static Employee__c getEmployeeDetails(String recordId){
        try {
            if (String.isNotBlank(recordId) && String.isNotEmpty(recordId)) {
                return [SELECT Id, Name, Clocked_In_Out_Status__c, Role__c, Image__c, Email__c, Emergency_Contact_No__c, Job_Title__c,Address__c, EmpCode__c, Department__c FROM Employee__c WHERE Id = :recordId LIMIT 1];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getEmployeeAllDetails(String employeeId) {
        List<Employee__c> employeeDetails = [SELECT Id, OwnerId, Name, SystemModstamp, Address__c,Loan_Policy__c, Clocked_In_Out_Status__c, Date_of_Birth__c, Department__c, Email__c, Emergency_Contact_No__c, Employment_Last_Date__c, First_Name__c, Forgot_Clock_Out__c, Gender__c, Image__c, Job_Title__c, Joining_Date__c, Last_Name__c, Manager__c, Password_Reset_Expiration__c, Password_Reset_Key__c, Password__c, Phone__c, Salary__c, Username__c, isLogin__c, Number_of_Leaves__c, Default_Active__c, Status_Approve_and_Pending__c, Role__c, Leave_Balance__c, End_Date__c, Total_Leave_Taken__c, Total_Half_Days_Leave_Duration__c, Total_Half_Days_From_Date_Leave_Duration__c, Total_Half_Days_To_Date_Leave_Duration__c, Total_Half_Days__c, Total_Work_From_Home_Days__c, sequence_number__c, Entire_Time_Sheet__c, EmpCode__c, Skills__c, Certificate__c, Professional_Summary__c, Middle_Name__c, Physically_Handicap__c, Marital_Status__c, Blood_Group__c, Personal_Email__c, Nationality__c, Skype_Id__c, About_Me__c, Hobbies__c, About_My_Job__c, Date_Of_Joining__c, In_Probation__c, Worker_Type__c, Time_Type__c, Shift__c, Weekly_Of_Policy__c, Leave_Plan__c, Holiday_Celendar__c, Business_Unit__c, Location__Street__s, Location__City__s, Location__PostalCode__s, Location__StateCode__s, Location__CountryCode__s, Location__Latitude__s, Location__Longitude__s, Location__GeocodeAccuracy__s, Location__c, Legal_Entity__c, Reports_To__c, Expanse_Policy__c 
                                             FROM Employee__c 
                                             WHERE Id = :employeeId];
        return employeeDetails;
    }
    
    @AuraEnabled
    public static List<Employee__c> fetchEmployeeDetails(String employeeId) {
        
        System.debug('employeeId::>> ' + employeeId);
        List<Employee__c> employeeDetails = new List<Employee__c>();
        
        try {
            if (String.isBlank(employeeId)) {
                throw new IllegalArgumentException('Employee Id is required.');
            }
            Id empId = (Id) employeeId;
            employeeDetails = [SELECT Id, Name, First_Name__c, Display_Name__c, Address__c,EmpCode__c, Aadhaar_Number__c,PAN_Card_Number__c, Date_of_Birth__c, Loan_Policy__c, Email__c, Emergency_Contact_No__c,  Gender__c, Last_Name__c, Phone__c, Professional_Summary__c, Middle_Name__c, Physically_Handicap__c, Marital_Status__c, Blood_Group__c, Personal_Email__c, Nationality__c, Skype_Id__c, About_Me__c, Hobbies__c, About_My_Job__c
                               FROM Employee__c 
                               WHERE Id = :empId LIMIT 1];
        } catch(Exception ex) {
            // Handle any exceptions
            system.debug('An error occurred: ' + ex.getMessage());
            throw new AuraHandledException('Error fetching employee details: ' + ex.getMessage());
        }
        System.debug('employeeDetails::>> ' + employeeDetails);
        return employeeDetails;
    }
    
    @AuraEnabled
    public static List<Map<string, object>> fetchEmpEducationData(String employeeId) {
        
        System.debug('employeeId::>> ' + employeeId);
        List<Employee_Education__c> empEducationList = new List<Employee_Education__c>();
        List<Map<string, object>> empEducationDetails = new List<Map<string, object>>();
        
        try {
            if (String.isBlank(employeeId)) {
                throw new IllegalArgumentException('Employee Id is required.');
            }
            empEducationList = [SELECT Id, Degree_Name__c, University_Name__c, Start_Date__c, End_Date__c, Employee__c FROM Employee_Education__c
                                WHERE Employee__c  = :employeeId ORDER BY End_Date__c DESC];
            
            if(empEducationList.size()>0){
                for(Employee_Education__c eduRec:empEducationList){
                    Map<string, object> empEduMap = new Map<string, object>();
                    empEduMap.put('Id',eduRec.Id);
                    empEduMap.put('Degree_Name__c',eduRec.Degree_Name__c);
                    empEduMap.put('University_Name__c',eduRec.University_Name__c);
                    empEduMap.put('Employee__c',eduRec.Employee__c);
                    
                    Datetime joinDatetime = Date.valueOf(eduRec.Start_Date__c);
                    String joinMonthYear = joinDatetime.format('yyyy');
                    empEduMap.put('FRMT_Start_Date__c',joinMonthYear);
                    empEduMap.put('Start_Date__c',eduRec.Start_Date__c);
                    
                    Datetime leaveDatetime = Date.valueOf(eduRec.End_Date__c);
                    String leaveMonthYear = leaveDatetime.format('yyyy');
                    empEduMap.put('FRMT_End_Date__c',leaveMonthYear);
                    empEduMap.put('End_Date__c',eduRec.End_Date__c);
                    
                    empEducationDetails.add(empEduMap);
                }
            }
        } catch(Exception ex) {
            // Handle any exceptions
            system.debug('An error occurred: ' + ex.getMessage());
            throw new AuraHandledException('Error fetching employee details: ' + ex.getMessage());
        }
        System.debug('empEducationDetails::>> ' + empEducationDetails);
        return empEducationDetails;
    }
    
    @AuraEnabled
    public static List<Map<string, object>> fetchEmpExperienceData(String employeeId) {
        
        System.debug('employeeId::>> ' + employeeId);
        List<Employee_Experience__c> empExperienceList = new List<Employee_Experience__c>();
        List<Map<string, object>> empExperienceDetails = new List<Map<string, object>>();
        try {
            if (String.isBlank(employeeId)) {
                throw new IllegalArgumentException('Employee Id is required.');
            }
            empExperienceList = [SELECT Id, Position__c, Company_Location__c, Company_Name__c, Join_Date__c, Leave_Date__c, Description__c,Employee__c FROM Employee_Experience__c
                                 WHERE Employee__c  = :employeeId ORDER BY Leave_Date__c DESC];
            System.debug('empExperienceList::>> ' + empExperienceList);
            if(empExperienceList.size()>0){
                for(Employee_Experience__c expRec:empExperienceList){
                    System.debug('expRec::>> ' + expRec);
                    Map<string, object> empExpMap = new Map<string, object>();
                    empExpMap.put('Id',expRec.Id);
                    empExpMap.put('Position__c',expRec.Position__c);
                    empExpMap.put('Company_Location__c',expRec.Company_Location__c);
                    empExpMap.put('Company_Name__c',expRec.Company_Name__c);
                    
                    Datetime joinDatetime = Datetime.valueOf(expRec.Join_Date__c);
                    String joinMonthYear = joinDatetime.format('MM-yyyy');
                    empExpMap.put('FRMT_Join_Date__c',joinMonthYear);
                    empExpMap.put('Join_Date__c',expRec.Join_Date__c);
                    
                    Datetime leaveDatetime = Datetime.valueOf(expRec.Leave_Date__c);
                    String leaveMonthYear = leaveDatetime.format('MM-yyyy');
                    empExpMap.put('FRMT_Leave_Date__c',leaveMonthYear);
                    empExpMap.put('Leave_Date__c',expRec.Leave_Date__c);
                    
                    empExperienceDetails.add(empExpMap);
                }
            }
            
        } catch(Exception ex) {
            // Handle any exceptions
            system.debug('An error occurred: ' + ex.getMessage());
            throw new AuraHandledException('Error fetching employee details: ' + ex.getMessage());
        }
        System.debug('empExperienceDetails::>> ' + empExperienceDetails);
        return empExperienceDetails;
    }
    
    @AuraEnabled
    public static void updateEmployeeDetails(Employee__c employeeData) {
        List<Employee__c> updatedEmployeeList  = new List<Employee__c>();
        try {
            if(employeeData.Id != null){
                
                List<Employee__c> existingEmployee = [SELECT Id, Name, First_Name__c, PAN_Card_Number__c , Aadhaar_Number__c, Display_Name__c, Address__c,  Date_of_Birth__c, Loan_Policy__c, Email__c, Emergency_Contact_No__c,  Gender__c, Last_Name__c, Phone__c, Professional_Summary__c, Middle_Name__c, Physically_Handicap__c, Marital_Status__c, Blood_Group__c, Personal_Email__c, Nationality__c, Skype_Id__c, About_Me__c, Hobbies__c, About_My_Job__c
                                                      FROM Employee__c 
                                                      WHERE Id = :employeeData.Id LIMIT 1];
                System.debug('employeeData::>> ' + employeeData);
                System.debug('existingEmployee::>> ' + existingEmployee);
                if(existingEmployee.size()>0){
                    for(Employee__c empRec : existingEmployee){
                        // Update fields with edited data
                        //Primary Details 
                        empRec.Id = employeeData.Id;
                        empRec.First_Name__c = employeeData.First_Name__c;
                        empRec.Middle_Name__c = employeeData.Middle_Name__c;
                        empRec.Last_Name__c = employeeData.Last_Name__c;
                        empRec.Gender__c = employeeData.Gender__c;
                        empRec.PAN_Card_Number__c = employeeData.PAN_Card_Number__c;
                        empRec.Aadhaar_Number__c = employeeData.Aadhaar_Number__c;
                        empRec.Date_of_Birth__c = employeeData.Date_of_Birth__c;
                        empRec.Marital_Status__c = employeeData.Marital_Status__c;
                        empRec.Blood_Group__c = employeeData.Blood_Group__c;
                        empRec.Physically_Handicap__c = employeeData.Physically_Handicap__c;
                        empRec.Nationality__c = employeeData.Nationality__c;
                        
                        // Contact Details
                        empRec.Email__c = employeeData.Email__c;
                        empRec.Personal_Email__c = employeeData.Personal_Email__c;
                        empRec.Emergency_Contact_No__c = employeeData.Emergency_Contact_No__c;
                        empRec.Skype_Id__c = employeeData.Skype_Id__c;
                        
                        // Address Details
                        empRec.Address__c = employeeData.Address__c;
                        
                        //Summary Details
                        empRec.Professional_Summary__c = employeeData.Professional_Summary__c;
                        
                        System.debug('employeeData.About_Me__c::>> ' + employeeData.About_Me__c);
                        // About Details 
                        empRec.About_Me__c = employeeData.About_Me__c;
                        empRec.About_My_Job__c = employeeData.About_My_Job__c;
                        empRec.Hobbies__c = employeeData.Hobbies__c;
                        
                        updatedEmployeeList.add(empRec);
                    } 
                }
                System.debug('updatedEmployeeList::>> ' + updatedEmployeeList);
                if(updatedEmployeeList.size()>0){
                    Update updatedEmployeeList;
                }
            }
        } catch (Exception e) {
            // Handle exception
            throw new AuraHandledException('Error updating employee data: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateEmpEducationData(String jsonData) {
        
        List<Employee_Education__c> educationRecordsToInsert = new List<Employee_Education__c>();
        List<Employee_Education__c> educationRecordsToUpdate = new List<Employee_Education__c>();
        
        // Parse JSON data
        List<Object> jsonDataList = (List<Object>) JSON.deserializeUntyped(jsonData);
        system.debug('jsonDataList>>'+jsonDataList);
        for (Object obj : jsonDataList) {
            system.debug('obj>>'+obj);
            Map<String, Object> record = (Map<String, Object>) obj;
            Employee_Education__c educationRecord = new Employee_Education__c();
            String recordId = String.valueOf(record.get('Id'));
            
            if (record.containsKey('Id')) {
                if (recordId != null && recordId.length() == 18) {
                    educationRecord.Id = recordId;
                    
                    if (record.containsKey('University_Name__c')) {
                        educationRecord.University_Name__c = String.valueOf(record.get('University_Name__c'));
                    }
                    if (record.containsKey('Degree_Name__c')) {
                        educationRecord.Degree_Name__c = String.valueOf(record.get('Degree_Name__c'));
                    }
                    if (record.containsKey('Start_Date__c')) {
                        educationRecord.Start_Date__c = Date.valueOf(String.valueOf(record.get('Start_Date__c')));
                    }
                    if (record.containsKey('End_Date__c')) {
                        educationRecord.End_Date__c = Date.valueOf(String.valueOf(record.get('End_Date__c')));
                    }
                    educationRecordsToUpdate.add(educationRecord);
                }
            }
            system.debug('educationRecord.Id>>'+educationRecord.Id);
            system.debug('recordId.length()>>'+recordId.length());
            if (educationRecord.Id == null || recordId.length() < 8 ) {
                system.debug('record>>'+record);    
                if (record.containsKey('Degree_Name__c')) {
                    educationRecord.Degree_Name__c = String.valueOf(record.get('Degree_Name__c'));
                }
                if (record.containsKey('University_Name__c')) {
                    educationRecord.University_Name__c = String.valueOf(record.get('University_Name__c'));
                }
                if (record.containsKey('Start_Date__c')) {
                    educationRecord.Start_Date__c = Date.valueOf(String.valueOf(record.get('Start_Date__c')));
                }
                if (record.containsKey('End_Date__c')) {
                    educationRecord.End_Date__c = Date.valueOf(String.valueOf(record.get('End_Date__c')));
                }
                if (record.containsKey('Employee__c')) { 
                    educationRecord.Employee__c = String.valueOf(record.get('Employee__c'));
                }
                educationRecordsToInsert.add(educationRecord);
            }
        }
        system.debug('educationRecordsToUpdate'+educationRecordsToUpdate);
        system.debug('educationRecordsToInsert'+educationRecordsToInsert);
        
        // Update records
        if (!educationRecordsToUpdate.isEmpty()) {
            update educationRecordsToUpdate;
        }
        
        // Insert records
        if (!educationRecordsToInsert.isEmpty()) {
            insert educationRecordsToInsert;
        }
    }
    
    @AuraEnabled
    public static void updateEmpExperianceData(String jsonData) {
        
        List<Employee_Experience__c> experianceRecordsToInsert = new List<Employee_Experience__c>();
        List<Employee_Experience__c> experianceRecordsToUpdate = new List<Employee_Experience__c>();
        
        // Parse JSON data
        List<Object> jsonDataList = (List<Object>) JSON.deserializeUntyped(jsonData);
        system.debug('jsonDataList>>'+jsonDataList);
        for (Object obj : jsonDataList) {
            system.debug('obj>>'+obj);
            Map<String, Object> record = (Map<String, Object>) obj;
            Employee_Experience__c experianceRecord = new Employee_Experience__c();
            String recordId = String.valueOf(record.get('Id'));
            
            if (record.containsKey('Id')) {
                if (recordId != null && recordId.length() == 18) {
                    experianceRecord.Id = recordId;
                    
                    if (record.containsKey('Position__c')) {
                        experianceRecord.Position__c = String.valueOf(record.get('Position__c'));
                    }
                    if (record.containsKey('Company_Name__c')) {
                        experianceRecord.Company_Name__c = String.valueOf(record.get('Company_Name__c'));
                    }
                    if (record.containsKey('Company_Location__c')) {
                        experianceRecord.Company_Location__c = String.valueOf(record.get('Company_Location__c'));
                    }
                    if (record.containsKey('Join_Date__c')) {
                        experianceRecord.Join_Date__c = Date.valueOf(String.valueOf(record.get('Join_Date__c')));
                    }
                    if (record.containsKey('Leave_Date__c')) {
                        experianceRecord.Leave_Date__c = Date.valueOf(String.valueOf(record.get('Leave_Date__c')));
                    }
                    experianceRecordsToUpdate.add(experianceRecord);
                }
            }
            system.debug('educationRecord.Id>>'+experianceRecord.Id);
            system.debug('recordId.length()>>'+recordId.length());
            if (experianceRecord.Id == null || recordId.length() < 8 ) {
                system.debug('record>>'+record);    
                if (record.containsKey('Position__c')) {
                    experianceRecord.Position__c = String.valueOf(record.get('Position__c'));
                }
                if (record.containsKey('Company_Name__c')) {
                    experianceRecord.Company_Name__c = String.valueOf(record.get('Company_Name__c'));
                }
                if (record.containsKey('Company_Location__c')) {
                    experianceRecord.Company_Location__c = String.valueOf(record.get('Company_Location__c'));
                }
                if (record.containsKey('Join_Date__c')) {
                    experianceRecord.Join_Date__c = Date.valueOf(String.valueOf(record.get('Join_Date__c')));
                }
                if (record.containsKey('Leave_Date__c')) {
                    experianceRecord.Leave_Date__c = Date.valueOf(String.valueOf(record.get('Leave_Date__c')));
                }
                if (record.containsKey('Employee__c')) { 
                    experianceRecord.Employee__c = String.valueOf(record.get('Employee__c'));
                }
                experianceRecordsToInsert.add(experianceRecord);
            }
        }
        system.debug('experianceRecordsToUpdate'+experianceRecordsToUpdate);
        system.debug('experianceRecordsToInsert'+experianceRecordsToInsert);
        
        // Update records
        if (!experianceRecordsToUpdate.isEmpty()) {
            update experianceRecordsToUpdate;
        }
        
        // Insert records
        if (!experianceRecordsToInsert.isEmpty()) {
            insert experianceRecordsToInsert;
        }
    }
    
    @AuraEnabled
    public static void deleteRecordById(string recordId, string objName) {
        try {
            if(recordId != null){
                Id recId = (Id)recordId;
                if (objName == 'Employee_Education__c'){
                    List<Employee_Education__c> educationRecordToDelete = [Select Id from Employee_Education__c WHERE Id = :recId];    
                    if(educationRecordToDelete.size()>0){
                        delete educationRecordToDelete;
                    }
                }
                if (objName == 'Employee_Experience__c'){
                    List<Employee_Experience__c> experienceRecordToDelete = [Select Id from Employee_Experience__c WHERE Id = :recId];
                    if(experienceRecordToDelete.size()>0){
                        delete experienceRecordToDelete;   
                    }
                    
                }    
            }
            System.debug('Employee education record deleted successfully.');
        } catch (Exception e) {
            // Handle any exceptions
            System.debug('An error occurred while deleting employee education record: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getAllPicklistValues(){
        Map<String,Object> returnMap=new Map<string,Object>();
        returnMap.put('Gender',picklistValues('Employee__c','Gender__c'));
        returnMap.put('BloodGroup',picklistValues('Employee__c','Blood_Group__c'));
        returnMap.put('Nationality',picklistValues('Employee__c','Nationality__c'));
        system.debug('returnMap: ' + returnMap);
        return JSON.serialize(returnMap);
    }
    
    @AuraEnabled
    public static Map<String, String> picklistValues(String objectName, String fieldName) {
        system.debug('objectName: ' + objectName);
        system.debug('fieldName: ' + fieldName);
        Map<String, String> values = new Map<String, String>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        system.debug('values: ' + values);
        return values;
    }
}