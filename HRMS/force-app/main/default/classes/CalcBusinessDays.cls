/**
 *CalcBusinessDays Class 
 *easily skip weekends and holidays from your logic 
 **/
public class CalcBusinessDays{
    public BusinessHours bHours;
    
    //Constructor to set business hour name     
    public CalcBusinessDays(String businessHoursName){       
        bHours = [SELECT Id FROM BusinessHours WHERE Name =: businessHoursName];
    }
     
 	// if business hour name not provided in paramaterized constructor, return default hours 
    public CalcBusinessDays(){        
        bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
    }
    
    public Datetime AddDays(Datetime dSartDate, Integer iDays){        
        dSartDate = BusinessHours.nextStartDate(bHours.Id, dSartDate);  
        for (Integer i = 0; i < iDays; i++){         
            dSartDate = dSartDate.addDays(1);           
            if (!BusinessHours.isWithin(bHours.Id, dSartDate)){                
                dSartDate = BusinessHours.nextStartDate(bHours.Id, dSartDate);
            }
        }
        return dSartDate;
    }    
  
    public Datetime SubtractDays(Datetime dStartDate, Integer iDays){        
        dStartDate = getPreviousWorkingDay(dStartDate);
        for (Integer i = 0; i < iDays; i++){            
            dStartDate = dStartDate.addDays(-1);
            if (!BusinessHours.isWithin(bHours.Id, dStartDate)){           
             dStartDate = getPreviousWorkingDay(dStartDate);
            }
        }
        return dStartDate;
    }
    
    /**
     * Recursive function to get previous working day
     * If date passed to this function is on a working day, this will return same date otherwise previous working day     
      ********************
     * For Example,
     * if passed day is Monday, this will return Monday
     * else if passed day is Sunday,then this will return Friday
      ********************    
     **/
    public Datetime getPreviousWorkingDay(Datetime d){   
         //Check if new date is within working days
        if (!BusinessHours.isWithin(bHours.Id, d)){           
            d = d.addDays(-1);
            return getPreviousWorkingDay(d);
        } else{           
            return d;
        }
    }
    
    /**
     * Function to get next working day
     * If date passed to this function is on a working day, this will return same date otherwise return next working day     
      ********************
     * For Example, 
     * if passed day is Monday, this will return Monday
     * else if passed day is Sunday, then this will return Monday
      ********************
    **/
    public Date getNextWorkingDay(Datetime d){
        return BusinessHours.nextStartDate(bHours.Id, d).date();
    }
  
    //Check if provided date is working day or not    
    public Boolean isWorkingDay(Datetime d){
        return BusinessHours.isWithin(bHours.Id, d);
    }
  
    
    //Get numbe of business days between two dates 
    public Integer getNoOfNonBusinessDaysBetweenDates(Date dStartDate, Date dEndDate){
        Integer count = 0;
        while(dStartDate <= dEndDate){
            if(!BusinessHours.isWithin(bHours.Id, dStartDate)){
                // Convert Date to Datetime
                Datetime dateTimeValue = Datetime.newInstance(dStartDate.year(), dStartDate.month(), dStartDate.day());
                
                // Format the Datetime to include day and date
                Integer weekNumber = Integer.valueOf(dateTimeValue.format('W'));
                // Get the day of the week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
                Integer dayOfWeek = dStartDate.toStartOfWeek().daysBetween(dStartDate) + 1;
                if (!(weekNumber >= 5 && dayOfWeek == 6)) {
                    count++;
                }
            }
            dStartDate = dStartDate.addDays(1);
        }
        return count; 
    }
    //  public static BusinessHours getBusinessHours(String businessHoursName) {
    //     BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE Name =: businessHoursName LIMIT 1];
    //     return bHours;
    // }
    @AuraEnabled(cacheable=true)
    public static Integer getNumberOfNonBusinessDays(Date startDate, Date endDate) {
        CalcBusinessDays calculator = new CalcBusinessDays();
        return calculator.getNoOfNonBusinessDaysBetweenDates(startDate, endDate);
    }
    
    //Get numbe of business days between two dates 
    public List<Date> getNonBusinessDaysBetweenDates(Date dStartDate, Date dEndDate){
        Integer count = 0;
        List<Date> listDates=new List<Date>();
        while(dStartDate <= dEndDate){
            if(!BusinessHours.isWithin(bHours.Id, dStartDate)){
                // Convert Date to Datetime
                Datetime dateTimeValue = Datetime.newInstance(dStartDate.year(), dStartDate.month(), dStartDate.day());
                
                // Format the Datetime to include day and date
                Integer weekNumber = Integer.valueOf(dateTimeValue.format('W'));
                // Get the day of the week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
                Integer dayOfWeek = dStartDate.toStartOfWeek().daysBetween(dStartDate) + 1;
                if (!(weekNumber >= 5 && dayOfWeek == 6)) {
                   listDates.add(dStartDate);
                }
            }
            dStartDate = dStartDate.addDays(1);
        }
        return listDates;
    }
 }