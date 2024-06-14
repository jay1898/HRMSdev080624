@isTest
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
    
        Integer result = CalcBusinessDays.getNumberOfNonBusinessDays(testStartDate, testEndDate);
    }
}