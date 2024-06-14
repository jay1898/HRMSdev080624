        List<Map<String, Object>> todayList = new List<Map<String, Object>>();
        List<Map<String, Object>> nextSevenDayList = new List<Map<String, Object>>();
        List<Employee__c> employeeList = new List<Employee__c>();
        DateTime dt = DateTime.now();
        DateTime nextdt = dt.addDays(7);
		System.debug('dt.day()' +dt.day());
        System.debug('nextdt.addDays(7).day()' +nextdt.addDays(7).day());
        if (dt.day() <= nextdt.addDays(7).day()) {
            System.debug('this month');
                    employeeList = [SELECT Id, Name, Date_of_Birth__c ,Gender__c
                                    FROM Employee__c
                                    WHERE CALENDAR_MONTH(Date_of_Birth__c) =:dt.month() AND DAY_IN_MONTH(Date_of_Birth__c) > :dt.day() ORDER BY Date_of_Birth__c ASC];
                                    system.debug('employeeList this month -->'+employeeList);
        }
        else{
            System.debug('next month');
                    employeeList = [SELECT Id, Name, Date_of_Birth__c ,Gender__c
                            FROM Employee__c
                            WHERE (DAY_IN_MONTH(Date_of_Birth__c) >= :dt.day() AND CALENDAR_MONTH(Date_of_Birth__c) =:dt.month()) OR CALENDAR_MONTH(Date_of_Birth__c) =:nextdt.month() ORDER BY Date_of_Birth__c ASC];
        					system.debug('employeeList next month-->'+employeeList);
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
					sevenBirthdayMap.put('Gender',emp.Gender__c);
                    /*if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        sevenBirthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    }
                    else{
                        sevenBirthdayMap.put('Profile_Photo', null);
                    }*/
                    nextSevenDayList.add(sevenBirthdayMap);
                }
                //For Today Birthday
                if(empDay.day() == dt.day() && empDay.month() == dt.month()){
                    System.debug('empDay--->'+empDay);
                    Map<String, object> birthdayMap = new Map<String, object>();
                    birthdayMap.put('Id', emp.Id);
                    birthdayMap.put('Name', emp.Name);
                    birthdayMap.put('Date_of_Birth__c', emp.Date_of_Birth__c);
					birthdayMap.put('Gender',emp.Gender__c);
                    /*if(!ProfilePhotoMap.isEmpty() && ProfilePhotoMap.containsKey(emp.Id)){
                        System.debug('ProfilePhotoMap.get(emp.Id)>>'+ProfilePhotoMap.get(emp.Id));
                        birthdayMap.put('Profile_Photo', ProfilePhotoMap.get(emp.Id));
                    }
                    else{
                        birthdayMap.put('Profile_Photo', null);
                    }*/
                    todayList.add(birthdayMap);
                }
            }
            System.debug('nextSevenDayListaaaa---------->'+nextSevenDayList);
            System.debug('todayListaaaaaa---------->'+todayList);
        }
