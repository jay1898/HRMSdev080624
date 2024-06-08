/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class ReportSheetControllerTest {

    @TestSetup
    static void makeData(){
        Contact con1=new Contact(
            LastName='test 1',
            Email='test@gmail.com'
        );
        insert con1;

        Employee__c employeeRecord = new Employee__c();
        employeeRecord.Name = 'TEST EMP';
        employeeRecord.Joining_Date__c = Date.today().addMonths(-6);
        employeeRecord.Username__c = 'testuser';
        employeeRecord.Email__c = 'test@gmail.com';
        employeeRecord.Date_of_Birth__c = Date.today();
        employeeRecord.Emergency_Contact_No__c = '9426582649';
        employeeRecord.First_Name__c = 'Test';
        employeeRecord.Last_Name__c = 'Emp';
        employeeRecord.Gender__c = 'Male';
        employeeRecord.Personal_Email__c = 'testpersonal@gmail.com';
        insert employeeRecord;
        
        Attendance__c attendance = new Attendance__c();
        attendance.Employee__c = employeeRecord.Id;
        attendance.Date__c = Date.today();
        attendance.Override_Absent__c = 'P';
        insert attendance;

        Timesheet__c ts1 = new Timesheet__c(
            Employee__c = employeeRecord.Id, 
            Project_Name__c = 'Project 1', 
            Total_Hours__c = 10, 
            Ticket_No__c = 'Ticket 1',
            Attendance__c = attendance.Id, 
            Actual_Hours__c = '10',
            Task_Type__c = 'Development',
            Date__c = attendance.Date__c,
            Task_Description__c = 'Test Task Descripton'
        );
        // insert ts;
        insert new List<Timesheet__c>{ts1};
    }
    
    @isTest
    static void getUniqueTicketHoursTest() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];

        Test.startTest();
            List<AggregateResult> result = ReportSheetController.getUniqueTicketHours(emp.Id);
        Test.stopTest();

        System.assertEquals('Project 1', result[0].get('Project_Name__c'));
        System.assertEquals(10, result[0].get('hours'));
        System.assertEquals('Ticket 1', result[0].get('Ticket_No__c'));
    }

    @isTest
    static void getOnTicketTaskWiseHoursTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Timesheet__c ts = [SELECT Id, Ticket_No__c FROM Timesheet__c WHERE Employee__c = :emp.Id LIMIT 1];

        Test.startTest();
            List<AggregateResult> result = ReportSheetController.getOnTicketTaskWiseHours(emp.Id, ts.Ticket_No__c);
        Test.stopTest();

        System.assertEquals('Development', result[0].get('Task_Type__c'));
        System.assertEquals(10, result[0].get('totalTaskHours'));
    }

    @isTest
    static void getMonthWiseUniqueTicketHoursTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Test.startTest();
            List<AggregateResult> result = ReportSheetController.getMonthWiseUniqueTicketHours(emp.Id, att.Date__c.month(), att.Date__c.year());
        Test.stopTest();

        System.assertEquals('Project 1', result[0].get('Project_Name__c'));
        System.assertEquals('Ticket 1', result[0].get('Ticket_No__c'));
        System.assertEquals(10, result[0].get('monthwisetotalHours'));
    }

    @isTest
    static void getMonthWiseProjectHoursTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Test.startTest();
            List<AggregateResult> result = ReportSheetController.getMonthWiseProjectHours(emp.Id, att.Date__c.month(), att.Date__c.year());
        Test.stopTest();

        System.assertEquals('Project 1', result[0].get('Project_Name__c'));
        System.assertEquals(10, result[0].get('monthWiseProjectHours'));
    }


    @isTest
    static void getMonthWiseTaskTypeHoursTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Test.startTest();
            List<AggregateResult> result = ReportSheetController.getMonthWiseTaskTypeHours(emp.Id, att.Date__c.month(), att.Date__c.year());
        Test.stopTest();

        System.assertEquals('Development', result[0].get('Task_Type__c'));
        System.assertEquals(10, result[0].get('monthWiseTaskHours'));
    }


    @isTest
    static void getUserProjectWiseChartTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Test.startTest();
            List<ReportSheetController.UserTimeSheetData> result = ReportSheetController.getUserProjectWiseChart(emp.Id);
        Test.stopTest();

        System.assertEquals('Project 1', result[0].taskType);
        System.assertEquals(10, result[0].totalHours);
    }

    @isTest
    static void getallTaskDetailsTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Test.startTest();
            List<ReportSheetController.DataSet> result = ReportSheetController.getallTaskDetails(emp.Id);
        Test.stopTest();

        System.assertEquals('Development', result[0].label);
        System.assertEquals(10, result[0].count);
    }

    @isTest
    static void findTicketsAssigningInMultipleProjectsTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Timesheet__c ts2 = new Timesheet__c(
            Employee__c = emp.Id, 
            Project_Name__c = 'Project 2', 
            Total_Hours__c = 5, 
            Ticket_No__c = 'DUL-Ticket-1',
            Attendance__c = att.Id, 
            Actual_Hours__c = '5',
            Task_Type__c = 'Development',
            Task_Description__c = 'Test Task Descripton',
            Date__c = att.Date__c
        );

        Timesheet__c ts3 = new Timesheet__c(
            Employee__c = emp.Id, 
            Project_Name__c = 'Project 3', 
            Total_Hours__c = 5, 
            Ticket_No__c = 'DUL-Ticket-1',
            Attendance__c = att.Id, 
            Actual_Hours__c = '5',
            Task_Type__c = 'Development',
            Task_Description__c = 'Test Task Descripton',
            Date__c = att.Date__c
        );

        insert new List<Timesheet__c>{ts2, ts3};

        Test.startTest();
            Map<String, List<Object>> result = ReportSheetController.findTicketsAssigningInMultipleProjects(emp.Id);
        Test.stopTest();

        System.assertEquals(2, result.size());
        List<Object> ticketDetails = result.get('DUL-Ticket-1');
        System.assertEquals('Invalid', ticketDetails[0]);
        System.assertEquals(10, ticketDetails[1]);
    }
    
    @isTest
    static void MonthWiseFindTicketsAssigningInMultipleProjectsTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Timesheet__c ts2 = new Timesheet__c(
            Employee__c = emp.Id, 
            Project_Name__c = 'Project 2', 
            Total_Hours__c = 5, 
            Ticket_No__c = 'DUL-Ticket-1',
            Attendance__c = att.Id, 
            Actual_Hours__c = '5',
            Task_Type__c = 'Development',
            Date__c = att.Date__c,
            Task_Description__c = 'Test Task Descripton'
        );

        Timesheet__c ts3 = new Timesheet__c(
            Employee__c = emp.Id, 
            Project_Name__c = 'Project 3', 
            Total_Hours__c = 5, 
            Ticket_No__c = 'DUL-Ticket-1',
            Attendance__c = att.Id, 
            Actual_Hours__c = '5',
            Task_Type__c = 'Development',
            Task_Description__c = 'Test Task Descripton',
            Date__c = att.Date__c
        );

        insert new List<Timesheet__c>{ts2, ts3};

        Test.startTest();
            Map<String, List<Object>> result = ReportSheetController.MonthWiseFindTicketsAssigningInMultipleProjects(emp.Id,att.Date__c.month(), att.Date__c.year());
        Test.stopTest();

        System.assertEquals(2, result.size());
        List<Object> ticketDetails = result.get('DUL-Ticket-1');
        System.assertEquals('Invalid', ticketDetails[0]);
        System.assertEquals(10, ticketDetails[1]);
    }
    
    @isTest
    static void getCurrentYearHoursReportsTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Test.startTest();
            Map<Integer, Decimal> result = ReportSheetController.getCurrentYearHoursReports(emp.Id, att.Date__c.year());
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(10, result.get(att.Date__c.month()));
        //System.assertEquals(10, result.get(Total_Hours__c));
    }

    @isTest
    static void getCurrentYearTotalHoursTest(){
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'TEST EMP' LIMIT 1];
        Attendance__c att = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c =:emp.Id LIMIT 1];

        Test.startTest();
            List<AggregateResult> result = ReportSheetController.getCurrentYearTotalHours(emp.Id, att.Date__c.year());
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(10, result[0].get('allTotalHours'));
    }
}