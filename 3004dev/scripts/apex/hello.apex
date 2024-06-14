List<Map<String, Object>> todayList = new List<Map<String, Object>>();
        List<Map<String, Object>> nextSevenDayList = new List<Map<String, Object>>();
    
        List<Employee__c> employeeList = new List<Employee__c>();
        DateTime dt = DateTime.now();
        DateTime nextdt = dt.addDays(7);
    
        if (dt.day() <= nextdt.addDays(7).day()) {
            System.debug('This month');
            employeeList = [
                SELECT Id, Name, Date_Of_Joining__c 
                FROM Employee__c
                WHERE CALENDAR_MONTH(Date_Of_Joining__c) = :dt.month() 
                AND DAY_IN_MONTH(Date_Of_Joining__c) > :dt.day() 
                ORDER BY Date_Of_Joining__c ASC
            ];
            system.debug('employeeList This month-->'+employeeList);
        } else {
            System.debug('Next month');
            employeeList = [
                SELECT Id, Name, Date_Of_Joining__c 
                FROM Employee__c
                WHERE (DAY_IN_MONTH(Date_Of_Joining__c) >= :dt.day() 
                AND CALENDAR_MONTH(Date_Of_Joining__c) = :dt.month()) 
                OR CALENDAR_MONTH(Date_Of_Joining__c) = :nextdt.month() 
                ORDER BY Date_Of_Joining__c ASC
            ];
            system.debug('employeeList Next month-->'+employeeList);
        }
        
        if (employeeList.size() > 0) {
            for (Employee__c emp : employeeList) {
                Date empDay = emp.Date_Of_Joining__c;
                // Calculate years of experience
                Integer yearsOfExperience = dt.year() - empDay.year();
                if (dt.month() < empDay.month() || (dt.month() == empDay.month() && dt.day() < empDay.day())) {
                    yearsOfExperience--;
                }
                // For next 7 days Work Anniversary
                if (
                    (
                        empDay.day() > nextdt.day() && 
                        empDay.month() < nextdt.month() &&
                        empDay.day() != dt.day()
                    ) 
                    ||
                    (
                        empDay.day() <= nextdt.day() &&
                        empDay.month() == nextdt.month() &&
                        empDay.day() != dt.day()
                    )
                ){
                    Map<String, object> sevenAnniversaryMap = new Map<String, object>();
                    sevenAnniversaryMap.put('Id', emp.Id);
                    sevenAnniversaryMap.put('Name', emp.Name);
                    sevenAnniversaryMap.put('Years_of_Experience', yearsOfExperience);
                    sevenAnniversaryMap.put('Date_Of_Joining__c',emp.Date_Of_Joining__c);
                    nextSevenDayList.add(sevenAnniversaryMap);
                }
                //For Today Work Anniversary 
                if(empDay.day() == dt.day() && empDay.month() == dt.month() && empDay.year() != dt.year()){
                    Map<String, object> anniversaryMap = new Map<String, object>();
                    anniversaryMap.put('Id', emp.Id);
                    anniversaryMap.put('Name', emp.Name);
                    anniversaryMap.put('Years_of_Experience', yearsOfExperience);
                    anniversaryMap.put('Date_Of_Joining__c',emp.Date_Of_Joining__c);                    
                    todayList.add(anniversaryMap);
                }
            }    
            System.debug('nextSevenDayListaaaa---------->'+nextSevenDayList);
            System.debug('todayListaaaaaa---------->'+todayList);
        }