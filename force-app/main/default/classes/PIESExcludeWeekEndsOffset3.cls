public class PIESExcludeWeekEndsOffset3 {
     @InvocableMethod(label='Exclude WeekEnds Offset3')
    public static List<FlowOutputs> excludeweekends(List<FlowInputs> request){
      
        Integer week_7 ; Integer weekendOffset = 0;  Date offsetDate3 ;
        
        //if, we are adding days to sched date and its monday then weekend will come after four days from monday.
        Map<String, Integer> mapDayOfWeekback = new Map<String, Integer>{'Monday' => 4, 'Tuesday' => 3, 'Wednesday'=> 2, 'Thursday'=>1, 'Friday' => 0, 'Saturday'=>1 , 'Sunday' => 0};
        Map<Integer, String> mapDaycheck = new Map<Integer, String>{0=>'Sunday', 1=>'Monday', 2=>'Tuesday', 3=>'Wednesday', 4=>'Thursday', 5=>'Friday', 6=>'Saturday'};
        List<FlowOutputs> results = new List<FlowOutputs>();	
        FlowOutputs fOut = new FlowOutputs();
        for(FlowInputs flin : request){
            if(flin.taskoffset3 != null){
            DateTime schedStartDateTime = flin.saSchedStartTime ; // 2022/04/19 1: 38 PM
        	Date schedStartDate = Date.newInstance(schedStartDateTime.year(), schedStartDateTime.month(), schedStartDateTime.day()); //2022/04/19
            Date startOfWeek = schedStartDate.toStartOfWeek();
            system.debug(startOfWeek);
            Integer dayOfWeek = schedStartDate.day()-startOfWeek.day(); //
            system.debug('dayOfWeek :' + dayOfWeek);
            Integer dayoffset = mapDayOfWeekback.get(mapDaycheck.get(dayOfWeek)); 
            system.debug('dayoffset : ' + dayoffset);
            if(flin.taskoffset3 > 0){
                  week_7 =  7;
                  switch on(dayOfWeek){    
                      when 6{ weekendOffset = 1; }
                      when 0{ weekendOffset = 2; }
                  }
             }
             else{
                 	week_7 = -7 ; 
                    if(dayOfWeek == 0){
                     dayoffset = 6 ;
             }
             else dayoffset = dayOfWeek - 1 ;   //4 - dayoffset ; /
             } 
             Integer Absoffset1 =  math.abs(flin.taskoffset3) ;
            
             while(Absoffset1 > dayoffset){ //11 > 6, 4 > 1
                schedStartDate = schedStartDate.addDays(week_7);  //2022/04/16 + 7 = 23, 23+ 7 = 30
                Absoffset1 = Absoffset1 - 5 ; // 6
                system.debug('schedStartDate : ' + schedStartDate + '::' + 'Absoffset1 :' + Absoffset1); 
            }
            if(flin.taskoffset3 > 0){
                schedStartDate = schedStartDate.addDays(Absoffset1);
                schedStartDate = schedStartDate.addDays(-weekendOffset);
                offsetDate3 = schedStartDate;
            }
            else{
                	schedStartDate = schedStartDate.addDays(-Absoffset1);
                    if(dayOfWeek == 0){
                        if(Absoffset1 == 6){
                           	schedStartDate = schedStartDate.addDays(-2); 
                        }
                         schedStartDate = schedStartDate.addDays(-1);
                    }	
                	offsetDate3 = schedStartDate;
            }
            system.debug('schedStartDate: ' + schedStartDate);
			if(offsetDate3 != null){
                  fOut.activityDate3 = offsetDate3;
                  results.add(fOut);
              }
       }
            
     }    
               
			
   
        return results ;
        
        
    }
    public class FlowInputs{
    
    	@InvocableVariable
        public datetime saSchedStartTime;
        
        @InvocableVariable
        public Integer taskoffset3;
        
    }
     public class FlowOutputs{
        
      	@InvocableVariable
        public date activityDate3 ;
         
     }

}