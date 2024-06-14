List<AggregateResult> totalCounts = [SELECT COUNT(Id) counts, On_Time_Arrival__c FROM Attendance__c WHERE Employee__r.Id = 'a111s000002qFgfAAE' AND First_Clock_In_Time__c != null GROUP BY On_Time_Arrival__c ORDER BY On_Time_Arrival__c];
    Map<String, Integer> totalValues = new Map<String, Integer>();

    if (!totalCounts.isEmpty()) {
        if (totalCounts.size() > 0) {
            totalValues.put('lateArrivals', Integer.valueOf(totalCounts[0].get('counts')));
            System.debug('totalValues   0--------->'+totalValues);
            System.debug('lateArrivals--------->'+Integer.valueOf(totalCounts[0].get('counts')));

        }
        if (totalCounts.size() > 1) {
            totalValues.put('OnTimeArrivals', Integer.valueOf(totalCounts[1].get('counts')));
            System.debug('totalValues   1--------->'+totalValues);
            System.debug('OnTimeArrivals--------->'+Integer.valueOf(totalCounts[1].get('counts')));
        }
    }

    System.debug('totalValues--------->'+totalValues);

    EmployeeController.getontimeArrival('a111s000002qFgfAAE');

    List<AggregateResult> totalCounts = [SELECT COUNT(Id) counts, On_Time_Arrival__c FROM Attendance__c WHERE Employee__r.Id = 'a0z1s000000ExaLAAS' AND First_Clock_In_Time__c != null GROUP BY On_Time_Arrival__c ORDER BY On_Time_Arrival__c];
        Map<String, Integer> totalValues = new Map<String, Integer>();
    
        for(AggregateResult ar : totalCounts) {
            String arrivalType = String.valueOf(ar.get('On_Time_Arrival__c'));
            Integer count = Integer.valueOf(ar.get('counts'));
            if(count == null) {
                count = 0; // Assign 0 if count is null
            }
            totalValues.put(arrivalType, count);
        }
    
        // Check if lateArrivals and OnTimeArrivals keys exist in the map
        if(!totalValues.containsKey('lateArrivals')) {
            totalValues.put('lateArrivals', 0);
        }
        if(!totalValues.containsKey('OnTimeArrivals')) {
            totalValues.put('OnTimeArrivals', 0);
        }
    System.debug('totalValues--------->'+totalValues);