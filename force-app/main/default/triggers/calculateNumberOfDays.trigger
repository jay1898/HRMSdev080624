trigger calculateNumberOfDays on Leave_Request__c (before insert , before update) {
   for (Leave_Request__c leaveRequest : Trigger.new) {
        System.debug('Processing Leave Request: ' + leaveRequest.Id);
        
        if (leaveRequest.From_Date__c != null && leaveRequest.To_Date__c != null) {
            Integer numberOfDays = leaveRequest.To_Date__c.daysBetween(leaveRequest.From_Date__c) + 1;

            System.debug('Number of Days: ' + numberOfDays);

            for (Integer i = 0; i < numberOfDays; i++) {
                Date currentDate = leaveRequest.From_Date__c.addDays(i);
                if (currentDate.day() != 1) {
                    leaveRequest.Number_of_Days__c++;
                }
            }

            System.debug('Updated Number of Days: ' + leaveRequest.Number_of_Days__c);
        }
    }

}