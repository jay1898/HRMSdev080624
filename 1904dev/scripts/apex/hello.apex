// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

    DateTime dt = DateTime.now();
    List<Employee__c> employees = [SELECT Id, Name, Date_Of_Joining__c 
                FROM Employee__c
                WHERE CALENDAR_MONTH(Date_Of_Joining__c) =:dt.month()];
    system.debug('dt.month()-->'+employees);

if(employees.size() == 0){
    //return null;
}
// For next 7 days Work Anniversary
List<Employee__c> nextSevenDays = new List<Employee__c>();
    for (Employee__c emp : employees) {
        DateTime empDay = emp.Date_Of_Joining__c;
        if(empDay.day() > dt.day() && empDay.day() <= dt.addDays(7).day()){
            nextSevenDays.add(emp);
            
        }
    }
    System.debug('nextSevenDaysWorkAnniversary---------->'+nextSevenDays);
	system.debug('size'+nextSevenDays.size());
//For Today Work Anniversary 
List<Employee__c> todaydate = new List<Employee__c>();
    for (Employee__c emp : employees) {
        DateTime empDay = emp.Date_Of_Joining__c;
        if(empDay.day() == dt.day()){
            todaydate.add(emp);
        }
    }
    System.debug('todaydateWorkAnniversary---------->'+todaydate);