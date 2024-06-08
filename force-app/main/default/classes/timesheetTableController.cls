/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class timesheetTableController {
    
    @AuraEnabled
    public static Map<String, Object> gettimesheetData(String employeeId) {
        
        Map<String, List<String>> timeSheetPicklistMap = new Map<String, List<String>>();
        // to get picklist value of Task_Type__c
        Schema.DescribeFieldResult TaskTypefieldResult = Schema.Timesheet__c.Task_Type__c.getDescribe();
        List<Schema.PicklistEntry> TaskTypepickListValues = TaskTypefieldResult.getPicklistValues();
        List<String> taskTypeList = new List<String>();
        for (Schema.PicklistEntry pickListEntry : TaskTypepickListValues) {
            String taskTypeValue = pickListEntry.getValue();
            taskTypeList.add(taskTypeValue);
        }
        timeSheetPicklistMap.put('TaskType', taskTypeList);
        
        // to get picklist value of Actual_Hours__c
        Schema.DescribeFieldResult ActualHoursfieldResult = Schema.Timesheet__c.Actual_Hours__c.getDescribe();
        List<Schema.PicklistEntry> ActualHourspickListValues = ActualHoursfieldResult.getPicklistValues();
        List<String> actHourList = new List<String>();
        for (Schema.PicklistEntry pickListEntry : ActualHourspickListValues) {
            String taskTypeValue = pickListEntry.getValue();
            actHourList.add(taskTypeValue);
        }
        timeSheetPicklistMap.put('ActEstHour', actHourList);
        
        //to get project name from Employee_Project__c junction where matching with login employee id
        List<Employee_Project__c> projNameListBasedOnEmpId = [select Project_Name__r.Name from Employee_Project__c where Employee__c = : employeeId];
        List<String> projNameList = new List<String>();
        for(Employee_Project__c prjName : projNameListBasedOnEmpId){
            projNameList.add(prjName.Project_Name__r.Name);
        }
        timeSheetPicklistMap.put('ProjectName', projNameList);
        return timeSheetPicklistMap;
    }
    
    
    // by mahendra update on 20/08/2023 for upset record
    @AuraEnabled
    public static void saveTimesheetRecords(Object timesheetList , String EmpRecordId, Date selectedDate) {
        try {
            String jsonTimesheetList = JSON.serialize(timesheetList);
            Map<String, Object> timeSheetRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonTimesheetList);
            List<Object> DrsDetails = (List<Object>) timeSheetRecords.get('DRS');
            
            List<Timesheet__c> upsertList = new List<Timesheet__c>();
            
          Datetime currentDatetime = Datetime.now();
            String formattedDatetime = currentDatetime.format('yyyy-MM-dd HH:mm:ss');
            
            Attendance__c attendanceId = [SELECT Id FROM Attendance__c WHERE Employee__c = :EmpRecordId AND Date__c = :selectedDate LIMIT 1];
            String acc = String.valueOf(attendanceId.Id);
            
            for (Object obj : DrsDetails) {
                Map<String, Object> getMap = (Map<String, Object>) obj;
                Timesheet__c TS = new Timesheet__c();
                String recordId = (String) getMap.get('TimeSheetRecordId');
                if (String.isNotBlank(recordId)) {
                    TS.Id = recordId; // Use the existing record's Id for update
                }
                String dateString = (String) getMap.get('TimeSheetDate');
                if (dateString != null) {
                    TS.Date__c = Date.valueOf(dateString);
                }
                // String dateString = (String) getMap.get('TimeSheetDate');
                // TS.Date__c = Date.valueOf(dateString);
                TS.Employee__c = (String) getMap.get('EmployeeId');
                TS.Project_Name__c = (String) getMap.get('ProjectName');
                TS.Task_Type__c = (String) getMap.get('TaskType');
                TS.Ticket_No__c = (String) getMap.get('TicketNo');
                TS.Task_Description__c = (String) getMap.get('TaskDescription');
                TS.Component_Change__c = (String) getMap.get('ComponentChange');
                TS.Estimated_Hours__c = (String) getMap.get('EstimatedHour');
                // TS.Actual_Hours__c = (String) getMap.get('ActualHour');
                
                
                if (!String.isNotBlank(recordId)) {
                    // TS.Id = recordId;
                    TS.Attendance__c = acc; // Use the existing record's Id for update
               }
                
                String actualHoursString = (String) getMap.get('ActualHour');
                if (actualHoursString != null) {
                    // Convert the String to Decimal and assign to Actual_Hours__c
                    TS.Actual_Hours__c = actualHoursString;
                }
            // Set Total_Hours__c equal to Actual_Hours__c
                TS.Total_Hours__c = Decimal.valueOf(TS.Actual_Hours__c);
                
                upsertList.add(TS);
                
            }
            if (!upsertList.isEmpty()) {
                // Upsert the records based on Id (existing records) or external Id (new records)
                upsert upsertList Id;
            }
            else {
            }
            
        } catch (Exception ex) {
            // Log the error for debugging purposes
            
            throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getTimesheetRecordsBasedonDate(Date selectedDate , String employeeId){
        List<Map<String, Object>> drsList = new List<Map<String, Object>>();
        
        for(Timesheet__c ct : [SELECT Id, Date__c, IsLocked__c, Ticket_No__c, Task_Type__c, Actual_Hours__c, Estimated_Hours__c, Project_Name__c, Task_Description__c,Component_Change__c, Employee__c, Employee__r.Name FROM Timesheet__c 
                               WHERE Employee__c = :employeeId AND Date__c = :selectedDate]) {
                                   Map<String, Object> recordMap = new Map<String, Object>();
                                   recordMap.put('TaskType', ct.Task_Type__c);
                                   recordMap.put('EstimatedHour', String.valueOf(ct.Estimated_Hours__c));
                                   recordMap.put('ActualHour', String.valueOf(ct.Actual_Hours__c));
                                   recordMap.put('ProjectName', ct.Project_Name__c);
                                   recordMap.put('TaskDescription', ct.Task_Description__c);
                                   recordMap.put('ComponentChange', ct.Component_Change__c);
                                   recordMap.put('EmployeeId', ct.Employee__c);
                                   recordMap.put('TicketNo', ct.Ticket_No__c);
                                   recordMap.put('TimeSheetRecordId', ct.Id);
                                   recordMap.put('IsLocked', ct.IsLocked__c);
                                   drsList.add(recordMap);
                               }
        
        Map<String, List<Map<String, Object>>> result = new Map<String, List<Map<String, Object>>>();
        result.put('DRS', drsList);
        
        String jsonData = JSON.serialize(result);
        return jsonData;
    }
    
    @AuraEnabled
    public static List<Timesheet__c> getTimesheet(String employeeId){
        return [select Id, Date__c,Ticket_No__c,Component_Change__c, Task_Type__c, Actual_Hours__c, Estimated_Hours__c, Project_Name__c,Task_Description__c,Employee__c,Employee__r.Name,IsLocked__c   from Timesheet__c where Employee__c =: employeeId AND Date__c < Today];
    }
    
    @AuraEnabled
    public static List<Attendance__c> getAttendanceData(String employeeId) {
        return [SELECT Id, Name, CreatedDate, Date__c, Employee__c, Total_Clock_In_Hours__c, Total_Timesheet_Hours__c, isAddDisable__c FROM Attendance__c where Employee__c =: employeeId AND Date__c <= Today ];
        // return [SELECT Id, Name, CreatedDate, Date__c, Employee__c, Total_Clock_In_Hours__c, Total_Timesheet_Hours__c, isAddDisable__c FROM Attendance__c where Employee__c =: employeeId AND (Date__c <= Today AND Date__c =: givenDate) Limit 1];
    }
    
    @AuraEnabled
    public static Employee__c getEmployeeData(String employeeId) {
        return [SELECT Id, Name, CreatedDate FROM Employee__c where Id =: employeeId LIMIT 1];
    }
    
    // Delete exiting record from backend 
    @AuraEnabled
    public static String deleteTimeSheetRecord(String TimeSheetRecordId){
        if(String.isNotBlank(TimeSheetRecordId)){
            delete[SELECT Id from Timesheet__c WHERE Id =: TimeSheetRecordId];
            return 'sucess';
        }else {
            return 'unsucess';   
        }
    }
    
    @AuraEnabled
    public static List<Timesheet__c> getTimesheetRecords(String employeeId) {
        // Query Timesheet records including the "Is_Read_Only" field
        return [SELECT Id, Name, IsLocked__c,  Employee__c
                FROM Timesheet__c WHERE Employee__c = :employeeId LIMIT 1];
    }
    
    @AuraEnabled
    public static Boolean getIsLockedFieldValue(String employeeId) {
        try {
            Timesheet__c timesheet = [SELECT Id, Name, IsLocked__c,  Employee__c FROM Timesheet__c WHERE Employee__c = :employeeId LIMIT 1];
            return timesheet.IsLocked__c;
        } catch (Exception e) {
            return false; 
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Project_Alloted_Hour__c> getProjectAllottedHours(String recordId) {
        return [SELECT Id, Name, Alloted_Hours__c, Date__c, Project__r.Name FROM Project_Alloted_Hour__c WHERE Project__c = :recordId];
    }
    
    @AuraEnabled
    public static void saveProjectAllottedHours(List<Project_Alloted_Hour__c> projectAllottedHours) {
        upsert projectAllottedHours;
    }
    
    @AuraEnabled
    public static void deleteProjectAllottedHour(String recordId) {
        delete new Project_Alloted_Hour__c(Id = recordId);
    }
    
    /// record Table  ///
    
    @AuraEnabled(cacheable=true)
    public static List<String> getProjectNames() {
        List<Project_Name__c> projects = [SELECT Id, Name, Main_Project_Name__c, Start_Date__c, End_Date__c, isBillable__c FROM Project_Name__c WHERE isBillable__c = TRUE];
        
        List<String> projectNames = new List<String>();
        for (Project_Name__c project : projects) {
            projectNames.add(project.Name);
        }
        
        return projectNames;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Project_Name__c> getProjects() {
        return [SELECT Id, Name, Main_Project_Name__c, Start_Date__c, End_Date__c, isBillable__c FROM Project_Name__c WHERE isBillable__c = TRUE];
    }
    
    @AuraEnabled
    public static void insertProjectAllotedHour(Date selectedDate, Decimal allotedHours, String projectId) {
        Project_Alloted_Hour__c newRecord = new Project_Alloted_Hour__c(
            Date__c = selectedDate,
            Alloted_Hours__c = allotedHours,
            Project__c = projectId
        );
        insert newRecord;
    }
    
    @AuraEnabled
    public static list<Employee__c> getEployeeRole(){
        list<Employee__c> employeeRecord = [select id, Name,Role__c from Employee__c  ];
        return employeeRecord;  
    }
    
    @AuraEnabled
    public static String getProjectWiseHours(Date selectedDate) {
        Map<string, decimal> projectWiseHoursMap = new Map<string,decimal>();
        List<Timesheet__c> timesheetlist = [SELECT Id, Actual_Hours__c, Date__c, Project_Name__c FROM Timesheet__c where Date__c =:selectedDate ];
        decimal totalHourse = 0; 
        
        for(Timesheet__c timeSheetData:  timesheetlist ){
            if(timeSheetData.Project_Name__c !=null ){
                if (projectWiseHoursMap.containsKey(timeSheetData.Project_Name__c) ){
                    totalHourse += decimal.valueof(timeSheetData.Actual_Hours__c);                 
                    projectWiseHoursMap.put(timeSheetData.Project_Name__c,totalHourse);
                }else{
                    totalHourse = decimal.valueof(timeSheetData.Actual_Hours__c);                 
                    projectWiseHoursMap.put(timeSheetData.Project_Name__c,totalHourse);
                }
            }
        }
        System.debug('projectWiseHoursMap'+Json.serialize(projectWiseHoursMap));
        return Json.serialize(projectWiseHoursMap);
    }
    
    @AuraEnabled
    public static List<Project_Alloted_Hour__c> getProjectAllotedHours(Date selectedDate) {
        
        map<string, decimal> projectWiseTotalHrsMap = new map<string,decimal>();
        System.debug('@@de ');
        //Collect all DRS data from All User 
        list<Timesheet__c> timesheetlist = [SELECT Id, Actual_Hours__c, Date__c,Total_Hours__c, Project_Name__c FROM Timesheet__c where Date__c =:selectedDate];
        
        for(Timesheet__c timeSheetData:  timesheetlist ){
            if(timeSheetData.Project_Name__c !=null)
            {   
                // Create Map For Project wise Total Hours 
                if(projectWiseTotalHrsMap.containsKey(timeSheetData.Project_Name__c))
                { 
                    System.debug('@@de '+ projectWiseTotalHrsMap.get(timeSheetData.Project_Name__c) + Decimal.ValueOf(timeSheetData.Actual_Hours__c));
                    projectWiseTotalHrsMap.put(timeSheetData.Project_Name__c,projectWiseTotalHrsMap.get(timeSheetData.Project_Name__c) + Decimal.ValueOf(timeSheetData.Actual_Hours__c));
                }
                else
                {
                    projectWiseTotalHrsMap.put(timeSheetData.Project_Name__c,Decimal.ValueOf(timeSheetData.Actual_Hours__c));
                }
            }
        }
        System.debug('projectWiseTotalHrsMap :: -- >>'+projectWiseTotalHrsMap);
        
        // List of PMDD Records 
        List<Project_Alloted_Hour__c> projectAllotedHoursList = [SELECT Id, Date__c, Alloted_Hours__c, Project__c, PM_Billable_Hours__c, No_of_Dev_QA_s__c, Total__c, Sum_Of_Actual_Hours__c, Project__r.Name FROM Project_Alloted_Hour__c WHERE Date__c = :selectedDate ];
        for(Project_Alloted_Hour__c  projectActualHours: projectAllotedHoursList ){
            
            // Check that DRS Map caontains the Project Name of PMDD record 
            if(projectWiseTotalHrsMap.containsKey(projectActualHours.Project__r.Name))
            {
                // Get the Total Hours of the Project and assign it to the Sum_Of_Actual_Hours__c of PMDD object
                projectActualHours.Sum_Of_Actual_Hours__c = projectWiseTotalHrsMap.get(projectActualHours.Project__r.Name); 
            }
            else{
                // If There is No Record in DRS map , for that it assign to 0
                projectActualHours.Sum_Of_Actual_Hours__c = 0; 
            }
        }
        // Update PMDD Object 
        if(projectAllotedHoursList.size()>0){
            update projectAllotedHoursList;    
        }
        
        
        // List of Update PMDD records 
        List<Project_Alloted_Hour__c> projectAllotedHourList = [SELECT Id, Date__c, Alloted_Hours__c, Project__c, PM_Billable_Hours__c, No_of_Dev_QA_s__c,TotalHR__c, Total__c, Sum_Of_Actual_Hours__c, Project__r.Name FROM Project_Alloted_Hour__c WHERE Date__c = :selectedDate];
        return projectAllotedHourList;    
         
    }
    
    @AuraEnabled
    public static String deleteProjectAllotedHourRecord(String projectAHId){
        
        System.debug('@@projectAHId '+ projectAHId);
        if(String.isNotBlank(projectAHId)){
            delete [SELECT Id from Project_Alloted_Hour__c WHERE Id =: projectAHId];
            return 'success';
        }else {
            return 'unsuccess';   
        }
    }
    
    @AuraEnabled
    public static String saveProjectAllotedRecords(Object timesheetList , Date selectedDate, boolean isInsert) {
        try {
            List<Object> DrsDetails = new List<Object>();
            String jsonTimesheetList = JSON.serialize(timesheetList);
            system.debug('@@jsonTimesheetList '+ jsonTimesheetList);
            system.debug('@@isInsert '+ isInsert);
            if (isInsert){
                DrsDetails = (List<Object>) JSON.deserializeUntyped(jsonTimesheetList);
            }else{
                Map<String, Object> timeSheetRecords = (Map<String, Object>) JSON.deserializeUntyped(jsonTimesheetList);
                system.debug('@@timeSheetRecords '+ timeSheetRecords);
                DrsDetails = (List<Object>) timeSheetRecords.get('Pmdd');
            }
            system.debug('@@DrsDetails '+ DrsDetails);
            
            List<Project_Alloted_Hour__c> upsertList = new List<Project_Alloted_Hour__c>();
            
            Datetime currentDatetime = Datetime.now();
            String formattedDatetime = currentDatetime.format('yyyy-MM-dd HH:mm:ss');
            
            for (Object obj : DrsDetails) {
                Map<String, Object> getMap = (Map<String, Object>) obj;
                Project_Alloted_Hour__c TS = new Project_Alloted_Hour__c();
                
                String recordId = (String) getMap.get('Id');
                if (String.isNotBlank(recordId)) {
                    TS.Id = recordId; 
                }
                
                TS.Project__c = (String) getMap.get('Project__c');
                system.debug('@@ Decimal.valueOf(alloted) '+ getMap.get('Alloted_Hours__c'));
                
                String allottedHoursString = String.valueOf(getMap.get('Alloted_Hours__c'));
                if (allottedHoursString != null) {
                    TS.Alloted_Hours__c = Decimal.valueOf(allottedHoursString);
                }
                
                String numberOfDev = String.valueOf(getMap.get('No_of_Dev_QA_s__c'));
                if (numberOfDev != null && numberOfDev.isNumeric()) {
                    TS.No_of_Dev_QA_s__c = Decimal.valueOf(numberOfDev);
                }
                
                String PMBillable = String.valueOf(getMap.get('PM_Billable_Hours__c'));
                if (PMBillable != null) {
                    System.debug('PMBillable@@++'+PMBillable);
                    TS.PM_Billable_Hours__c = Decimal.valueOf(PMBillable);
                }
                
                String total = String.valueOf(getMap.get('TotalHR__c'));
                if (total != null && total.isNumeric()) {
                }
                TS.Date__c = selectedDate;
                upsertList.add(TS);
            }
            if (!upsertList.isEmpty()) {
                upsert upsertList Project_Alloted_Hour__c.Id;
                return 'success';
            }else {
                return 'no_records_to_upsert';
            }
            
        } catch (Exception ex) {
            System.debug('numberrrrr@'+ex.getLineNumber());
            return 'Error:' + ex.getMessage();
        }
    }
    
}