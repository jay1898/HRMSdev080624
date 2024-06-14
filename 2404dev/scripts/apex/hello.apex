//**************

        List<Map<String, Object>> todayList = new List<Map<String, Object>>();
        List<Map<String, Object>> nextSevenDayList = new List<Map<String, Object>>();
        List<Employee__c> employeeList = new List<Employee__c>();
        DateTime dt = DateTime.now();
        DateTime nextdt = dt.addDays(7);

        if (dt.day() <= nextdt.addDays(7).day()) {
            System.debug('this month');
                    employeeList = [SELECT Id, Name, Date_of_Birth__c 
                                    FROM Employee__c
                                    WHERE CALENDAR_MONTH(Date_of_Birth__c) =:dt.month() AND DAY_IN_MONTH(Date_of_Birth__c) > :dt.day() ORDER BY Date_of_Birth__c];
                                    system.debug('dt.month()-->'+employeeList);
        }
        else{
            System.debug('next month');
            employeeList = [SELECT Id, Name, Date_of_Birth__c 
                                    FROM Employee__c
                                    WHERE (DAY_IN_MONTH(Date_of_Birth__c) >= :dt.day() AND CALENDAR_MONTH(Date_of_Birth__c) =:dt.month()) OR CALENDAR_MONTH(Date_of_Birth__c) =:nextdt.month() ORDER BY Date_of_Birth__c];
        system.debug('dt.month()-->'+employeeList);
        }

        
        if (employeeList.size() > 0) {
           
            for (Employee__c emp : employeeList) {
                DateTime empDay = emp.Date_of_Birth__c;
                //For 7 days Birthday
                if(
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
                    Map<String, object> sevenBirthdayMap = new Map<String, object>();
                    sevenBirthdayMap.put('Id', emp.Id);
                    sevenBirthdayMap.put('Name', emp.Name);
                    sevenBirthdayMap.put('Date_of_Birth__c', emp.Date_of_Birth__c);
                    if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        sevenBirthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    }
                    else{
                        sevenBirthdayMap.put('Profile_Photo', null);
                    }
                    nextSevenDayList.add(sevenBirthdayMap);
                }

                if(empDay.day() == dt.day() && empDay.month() == dt.month()){
                    System.debug('empDay--->'+empDay);
                    Map<String, object> birthdayMap = new Map<String, object>();
                    birthdayMap.put('Id', emp.Id);
                    birthdayMap.put('Name', emp.Name);
                    birthdayMap.put('Date_of_Birth__c', emp.Date_of_Birth__c);
                    if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        birthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    }
                    else{
                        birthdayMap.put('Profile_Photo', null);
                    }
                    todayList.add(birthdayMap);
                }
            }
        }

        System.debug(dt.addDays(7).day());
        System.debug(dt.addDays(7).month());
        System.debug('todayList---->'+todayList);
        System.debug('nextSevenDayList---->'+nextSevenDayList);

        /********/
       List<Map<String, Object>> todayList = new List<Map<String, Object>>();
        List<Map<String, Object>> nextSevenDayList = new List<Map<String, Object>>();

        List<Employee__c> employeeList = new List<Employee__c>();
        DateTime dt = DateTime.now();
        DateTime nextdt = dt.addDays(7);

        if (dt.day() <= nextdt.addDays(7).day()) {
            System.debug('this month');
                    employeeList = [SELECT Id, Name, Date_Of_Joining__c 
                                    FROM Employee__c
                                    WHERE CALENDAR_MONTH(Date_Of_Joining__c) =:dt.month() AND DAY_IN_MONTH(Date_Of_Joining__c) > :dt.day() ORDER BY Date_Of_Joining__c];
                                    system.debug('dt.month()-->'+employeeList);
        }
        else{
            System.debug('next month');
            employeeList = [SELECT Id, Name, Date_Of_Joining__c 
                                    FROM Employee__c
                                    WHERE (DAY_IN_MONTH(Date_Of_Joining__c) >= :dt.day() AND CALENDAR_MONTH(Date_Of_Joining__c) =:dt.month()) OR CALENDAR_MONTH(Date_Of_Joining__c) =:nextdt.month() ORDER BY Date_Of_Joining__c];
        system.debug('employeeList-->'+employeeList);
        }
        
        if (employeeList.size() > 0) {
            
            for (Employee__c emp : employeeList) {
                DateTime empDay = emp.Date_Of_Joining__c;
                // For next 7 days Work Anniversary
                if(
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
                    sevenAnniversaryMap.put('Date_Of_Joining__c', emp.Date_Of_Joining__c);
                    Integer yearsOfExperience = dt.year() - empDay.year();       
    
                    if (dt.month() < empDay.month() || (dt.month() == empDay.month() && dt.day() < empDay.day())) {
                        yearsOfExperience--;
                    }
                    System.debug('yearsOfExperience--->'+yearsOfExperience);

                    /*if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        sevenAnniversaryMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    }
                    else{
                        sevenAnniversaryMap.put('Profile_Photo', null);
                    }*/
                    nextSevenDayList.add(sevenAnniversaryMap);
                }
                //For Today Work Anniversary 
                if(empDay.day() == dt.day() && empDay.month() == dt.month()){
                    Map<String, object> anniversaryMap = new Map<String, object>();
                    anniversaryMap.put('Id', emp.Id);
                    anniversaryMap.put('Name', emp.Name);
                    anniversaryMap.put('Date_Of_Joining__c',yearsOfExperience);

                    Integer yearsOfExperience = dt.year() - empDay.year();       
    
                    if (dt.month() < empDay.month() || (dt.month() == empDay.month() && dt.day() < empDay.day())) {
                        yearsOfExperience--;
                    }
                    System.debug('yearsOfExperience--->'+yearsOfExperience);
                    System.debug('anniversaryMap-------?'+anniversaryMap);
                    todayList.add(anniversaryMap);
                }
            }    
        System.debug('nextSevenDayListaaaa---------->'+nextSevenDayList);
        System.debug('todayListaaaaaa---------->'+todayList);
    }




///////////////////////////////////////////////////////


        Date today = Date.today();
        Date joiningDate = Date.newInstance(2018, 4, 24);
        // Get the year difference between today and joining date
        Integer yearsOfExperience = today.year() - joiningDate.year();
        
        // Adjust for cases where the anniversary hasn't been reached yet this year
        if (today.month() < joiningDate.month() || (today.month() == joiningDate.month() && today.day() < joiningDate.day())) {
            yearsOfExperience--;
        }
        System.debug('yearsOfExperience-->'+yearsOfExperience);