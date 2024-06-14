List<Map<String, Object>> todayList = new List<Map<String, Object>>();
List<Map<String, Object>> nextSevenDayList = new List<Map<String, Object>>();
List<Employee__c> employeeList = new List<Employee__c>();

// Create Date instances for today and next week
Date today = Date.newInstance(2024, 5, 28);
Date nextWeek = today.addDays(7);

// Query to get birthdays within the current month and next month
employeeList = [
    SELECT Id, Name, Date_of_Birth__c
    FROM Employee__c
    WHERE (CALENDAR_MONTH(Date_of_Birth__c) = :today.month() AND DAY_IN_MONTH(Date_of_Birth__c) >= :today.day())
    OR (CALENDAR_MONTH(Date_of_Birth__c) = :nextWeek.month() AND DAY_IN_MONTH(Date_of_Birth__c) <= :nextWeek.day())
    ORDER BY Date_of_Birth__c
];

System.debug('employeeList -->' + employeeList);

if (employeeList.size() > 0) {
    for (Employee__c emp : employeeList) {
        Date empBirthdayThisYear = Date.newInstance(today.year(), emp.Date_of_Birth__c.month(), emp.Date_of_Birth__c.day());

        // For Today Birthday
        if (empBirthdayThisYear == today) {
            System.debug('empDay--->' + emp.Date_of_Birth__c);
            Map<String, Object> birthdayMap = new Map<String, Object>();
            birthdayMap.put('Id', emp.Id);
            birthdayMap.put('Name', emp.Name);
            birthdayMap.put('Date_of_Birth__c', emp.Date_of_Birth__c);
            //birthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
            todayList.add(birthdayMap);
        }
        // For Next 7 Days Birthday
        else if (empBirthdayThisYear > today && empBirthdayThisYear <= nextWeek) {
            Map<String, Object> sevenBirthdayMap = new Map<String, Object>();
            sevenBirthdayMap.put('Id', emp.Id);
            sevenBirthdayMap.put('Name', emp.Name);
            sevenBirthdayMap.put('Date_of_Birth__c', emp.Date_of_Birth__c);
            //sevenBirthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
            nextSevenDayList.add(sevenBirthdayMap);
        }
    }
    System.debug('nextSevenDayList---------->' + nextSevenDayList);
    System.debug('todayList---------->' + todayList);
}