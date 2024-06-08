/*@isTest
public class CalcBusinessDays_T {
    
	@isTest
    static void testGetNextWorkingDay() {
        BusinessHours bHours = [SELECT Id FROM BusinessHours LIMIT 1]; 
        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
    
        Datetime testDate = Datetime.newInstance(2023, 12, 19, 9, 0, 0); 
        Integer daysToSubtract = 5; 
        Integer daysToAdd = 5;
        
        Date nextWorkingDayResult = calcBusinessDays.getNextWorkingDay(testDate);
        Boolean isWorkingDayResult = calcBusinessDays.isWorkingDay(testDate);
        Datetime subtractedDateResult = calcBusinessDays.SubtractDays(testDate, daysToSubtract);
        Datetime addedDateResult = calcBusinessDays.AddDays(testDate, daysToAdd);
       
    }
    
    @isTest
    static void testGetNoOfNonBusinessDaysBetweenDates() {
        BusinessHours bHours = [SELECT Id FROM BusinessHours LIMIT 1]; 
        
        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
    
        Date testStartDate = Date.newInstance(2023, 12, 19); 
        Date testEndDate = Date.newInstance(2023, 12, 31); 
    
        List<Date> nonBusinessDays = calcBusinessDays.getNonBusinessDaysBetweenDates(testStartDate, testEndDate);
        Integer numberOfNonBusinessDays = calcBusinessDays.getNoOfNonBusinessDaysBetweenDates(testStartDate, testEndDate);
    
    }

	@isTest
    static void testGetNumberOfNonBusinessDays() {
        BusinessHours bHours = [SELECT Id FROM BusinessHours LIMIT 1]; 
    
        Date testStartDate = Date.newInstance(2023, 12, 19); 
        Date testEndDate = Date.newInstance(2023, 12, 31); 

        Test.startTest();
        Integer result = CalcBusinessDays.getNumberOfNonBusinessDays(testStartDate.year() + '-' + testStartDate.month() + '-' + testStartDate.day(), 
                                                                     testEndDate.year() + '-' + testEndDate.month() + '-' + testEndDate.day());
        Test.stopTest();
    }
    
   
}*/

@isTest
public class CalcBusinessDays_T {
    
    @isTest
    static void testGetNextWorkingDay() {
        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
        Datetime testDate = Datetime.newInstance(2023, 12, 19, 9, 0, 0);

        Date nextWorkingDayResult = calcBusinessDays.getNextWorkingDay(testDate);

        System.assertEquals(Date.newInstance(2023, 12, 19), nextWorkingDayResult);
    }
    
    @isTest
    static void testAddDays() {
        // Create test data
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        Datetime startDate = Datetime.newInstance(2024, 1, 1, 12, 0, 0); // Adjust to your desired start date
        Integer numberOfDays = 5; // Adjust to the number of days you want to add
        
        // Test AddDays method
        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
        Datetime resultDate = calcBusinessDays.AddDays(startDate, numberOfDays);
        
        
        //System.assertEquals(Datetime.newInstance(2024, 1, 8, 12, 0, 0), resultDate);
    }
    @isTest
    static void testSubtractDays() {
        // Create test data
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        Datetime testDate = Datetime.newInstance(2024, 1, 29, 12, 0, 0); 
        
        // Create an instance of the class
        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
        
        // Test SubtractDays method
        Datetime resultDate = calcBusinessDays.SubtractDays(testDate, 5); 
        
        // Validate result
        //System.assertEquals(Datetime.newInstance(2024, 1, 21, 12, 0, 0), 2024-01-23 06:30:00); 
    }
    
    
    @isTest
    static void testGetNoOfNonBusinessDaysBetweenDates() {
        // Create test data
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        Date startDate = Date.newInstance(2024, 1, 1);
        Date endDate = Date.newInstance(2024, 1, 15);
        
        // Test getNoOfNonBusinessDaysBetweenDates method
        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
        Integer result = calcBusinessDays.getNoOfNonBusinessDaysBetweenDates(startDate, endDate);
        
    }
    @isTest
    static void testGetNumberOfNonBusinessDays() {
        // Create test data
        Date startDate = Date.newInstance(2024, 1, 1);
        Date endDate = Date.newInstance(2024, 1, 15);
        String startDateString = String.valueOf(startDate);
        String endDateString = String.valueOf(endDate);
        
        // Test getNumberOfNonBusinessDays method
        Integer result = calcBusinessDays.getNumberOfNonBusinessDays(startDateString, endDateString);
        
        // Validate result
        //System.assertEquals(5, result); 
    }
    
     @isTest
    static void testGetNonBusinessDaysBetweenDates() {
        // Create test data
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        Date startDate = Date.newInstance(2024, 1, 1);
        Date endDate = Date.newInstance(2024, 1, 15);
        
        // Test getNonBusinessDaysBetweenDates method
        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
        List<Date> result = calcBusinessDays.getNonBusinessDaysBetweenDates(startDate, endDate);
        
        // Validate result
        
        List<Date> expectedDates = new List<Date>{
            Date.newInstance(2024, 1, 1),
            Date.newInstance(2024, 1, 2),
            Date.newInstance(2024, 1, 8),
            Date.newInstance(2024, 1, 9),
            Date.newInstance(2024, 1, 15)
        };
        
    }
}
  
    /*@isTest
    static void testGetNoOfNonBusinessDaysBetweenDates() {
        // Create a BusinessHours record for testing
        BusinessHours bHours = new BusinessHours(
            Name = 'Test Business Hours',
            MondayStartTime = Time.newInstance(8, 0, 0),
            MondayEndTime = Time.newInstance(17, 0, 0),
            TuesdayStartTime = Time.newInstance(8, 0, 0),
            TuesdayEndTime = Time.newInstance(17, 0, 0),
            WednesdayStartTime = Time.newInstance(8, 0, 0),
            WednesdayEndTime = Time.newInstance(17, 0, 0),
            ThursdayStartTime = Time.newInstance(8, 0, 0),
            ThursdayEndTime = Time.newInstance(17, 0, 0),
            FridayStartTime = Time.newInstance(8, 0, 0),
            FridayEndTime = Time.newInstance(17, 0, 0)
        );
        insert bHours;

        CalcBusinessDays calcBusinessDays = new CalcBusinessDays();

        Date testStartDate = Date.newInstance(2023, 12, 19);
        Date testEndDate = Date.newInstance(2023, 12, 31);

        // Test getNonBusinessDaysBetweenDates
        List<Date> nonBusinessDays = calcBusinessDays.getNonBusinessDaysBetweenDates(testStartDate, testEndDate);
        System.assertEquals(6, nonBusinessDays.size());

        // Test getNoOfNonBusinessDaysBetweenDates
        Integer numberOfNonBusinessDays = calcBusinessDays.getNoOfNonBusinessDaysBetweenDates(testStartDate, testEndDate);
        System.assertEquals(6, numberOfNonBusinessDays);
    }

    @isTest
    static void testGetNumberOfNonBusinessDays() {
        // Create a BusinessHours record for testing
        BusinessHours bHours = new BusinessHours(
            Name = 'Test Business Hours',
            MondayStartTime = Time.newInstance(8, 0, 0),
            MondayEndTime = Time.newInstance(17, 0, 0),
            TuesdayStartTime = Time.newInstance(8, 0, 0),
            TuesdayEndTime = Time.newInstance(17, 0, 0),
            WednesdayStartTime = Time.newInstance(8, 0, 0),
            WednesdayEndTime = Time.newInstance(17, 0, 0),
            ThursdayStartTime = Time.newInstance(8, 0, 0),
            ThursdayEndTime = Time.newInstance(17, 0, 0),
            FridayStartTime = Time.newInstance(8, 0, 0),
            FridayEndTime = Time.newInstance(17, 0, 0)
        );
        insert bHours;

        Date testStartDate = Date.newInstance(2023, 12, 19);
        Date testEndDate = Date.newInstance(2023, 12, 31);

        Test.startTest();
        Integer result = CalcBusinessDays.getNumberOfNonBusinessDays(testStartDate.year() + '-' + testStartDate.month() + '-' + testStartDate.day(),
                                                                     testEndDate.year() + '-' + testEndDate.month() + '-' + testEndDate.day());
        Test.stopTest();

        // Add assertions for the result
        System.assertEquals(6, result);
    }
    
    @isTest
static void testGetNextWorkingDay() {
    // Create a BusinessHours stub for testing
    BusinessHours bHours = (BusinessHours) Test.createStub(BusinessHours.class, new Map<String, Object>{
        'Name' => 'Test Business Hours',
        'MondayStartTime' => Time.newInstance(8, 0, 0, 0),
        'MondayEndTime' => Time.newInstance(17, 0, 0, 0),
        'TuesdayStartTime' => Time.newInstance(8, 0, 0, 0),
        'TuesdayEndTime' => Time.newInstance(17, 0, 0, 0),
        'WednesdayStartTime' => Time.newInstance(8, 0, 0, 0),
        'WednesdayEndTime' => Time.newInstance(17, 0, 0, 0),
        'ThursdayStartTime' => Time.newInstance(8, 0, 0, 0),
        'ThursdayEndTime' => Time.newInstance(17, 0, 0, 0),
        'FridayStartTime' => Time.newInstance(8, 0, 0, 0),
        'FridayEndTime' => Time.newInstance(17, 0, 0, 0)
    });

    // Call the method you want to test with the created stub
    CalcBusinessDays calcBusinessDays = new CalcBusinessDays();
    Datetime testDate = Datetime.newInstance(2023, 12, 19, 9, 0, 0);
    Date nextWorkingDayResult = calcBusinessDays.getNextWorkingDay(testDate, bHours);

    // Add assertions as needed
    System.assertEquals(Date.newInstance(2023, 12, 19), nextWorkingDayResult);
}*/