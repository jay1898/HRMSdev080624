public class PIESExcludeWeekEnds {
    @InvocableMethod(label='Exclude WeekEnds')
    public static List<FlowOutputs> excludeweekends(List<FlowInputs> request){
       
    
        Integer week_7 ; Integer weekendOffset = 0; Date offsetDate1 ; Date offsetDate2 ; Date offsetDate3 ;
        
        //if, we are adding days to sched date and its monday then weekend will come after four days from monday.
        Map<String, Integer> mapDayOfWeekback = new Map<String, Integer>{'Monday' => 4, 'Tuesday' => 3, 'Wednesday'=> 2, 'Thursday'=>1, 'Friday' => 0, 'Saturday'=>1 , 'Sunday' => 0};
		
        Map<Integer, String> mapDaycheck = new Map<Integer, String>{0=>'Sunday', 1=>'Monday', 2=>'Tuesday', 3=>'Wednesday', 4=>'Thursday', 5=>'Friday', 6=>'Saturday'};
		
        Map<String, Integer> mapInteger = new Map<String, Integer>{'Sunday' => 0, 'Monday' => 1, 'Tuesday' => 2,'Wednesday' => 3, 'Thursday' => 4, 'Friday' => 5, 'Saturday' => 6};
        set<FlowOutputs> results = new set<FlowOutputs>();
		FlowOutputs fOut = new FlowOutputs();
		
        for(FlowInputs flin : request){
          if(flin.taskoffset1 != null){
            // get sched start date from flow
            DateTime schedStartDateTime = flin.saSchedStartTime ; //07/29/2022 11:98
            String sdayOfWeek=schedStartDateTime.format('EEEE');  //Friday
            System.debug('Day : ' + sdayOfWeek);
            Integer dayOfWeek = mapInteger.get(sdayOfWeek); //5
            Date schedStartDate = Date.newInstance(schedStartDateTime.year(), schedStartDateTime.month(), schedStartDateTime.day()); //2022/04/19  
            system.debug('schedStartDate : ' + schedStartDate); //08/05/2022
            Integer dayoffset = mapDayOfWeekback.get(mapDaycheck.get(dayOfWeek));
              //convert it to date format
       /* 	Date schedStartDate = Date.newInstance(schedStartDateTime.year(), schedStartDateTime.month(), schedStartDateTime.day()); //2022/04/19
            
            //get the start week of the scheddate
            Date startOfWeek = schedStartDate.toStartOfWeek();
            system.debug(startOfWeek);
            //get th day, ex. if dayofweek = 3 then it is considered as wednesday. Please check line no 12
            Integer dayOfWeek = schedStartDate.day()-startOfWeek.day(); //-26
            system.debug('schedStartDate.day() :' + schedStartDate.day() + '@@@' + 'startOfWeek.day() :' + startOfWeek.day());  
            system.debug('dayOfWeek :' + dayOfWeek);
              
            //Integer Absoffset1 =  math.abs(flin.taskoffset1) ;
            //get the day in name like, monday, tuesday based on dayOfWeek
            Integer dayoffset = mapDayOfWeekback.get(mapDaycheck.get(dayOfWeek)); 
            system.debug('dayoffset : ' + dayoffset);*/
            //Integer dayOfWeek = mapDayOfWeekback.get(sdayOfWeek); // 0
            // 0
            if(flin.taskoffset1 > 0){  //3 > 0 
                  week_7 =  7; //to add 7 days
                  switch on(dayOfWeek){    
                      when 6{ weekendOffset = 1; } //if saturday 
                      when 0{ weekendOffset = 2; } //if sunday
                  }
             }
             else{
                 	week_7 = -7 ;  //to subtract 7 days
                    //if sunday
                    if(dayOfWeek == 0){
                     dayoffset = 6 ; //set to saturday
             }
             else dayoffset = dayOfWeek - 1 ;   //4 - dayoffset ; /
             system.debug('dayoffset : ' + dayoffset);
             } 
             //get absoulte value of offset
             Integer Absoffset1 =  math.abs(flin.taskoffset1) ; //3
            
             while(Absoffset1 > dayoffset){ //3>0
                schedStartDate = schedStartDate.addDays(week_7);  //5 + 7 = 12
                Absoffset1 = Absoffset1 - 5 ; // 3-5 = -2
                system.debug('schedStartDate : ' + schedStartDate + '::' + 'Absoffset1 :' + Absoffset1); 
            }
            if(flin.taskoffset1 > 0){
                schedStartDate = schedStartDate.addDays(Absoffset1); // 12 -2 = 10
                schedStartDate = schedStartDate.addDays(-weekendOffset); // 15 - 2 = 13
                offsetDate1 = schedStartDate;
            }
            else{
                	schedStartDate = schedStartDate.addDays(-Absoffset1);
                    if(dayOfWeek == 0){
                        if(Absoffset1 == 6){
                           	schedStartDate = schedStartDate.addDays(-2); 
                        }
                         schedStartDate = schedStartDate.addDays(-1);
                    }	
                	offsetDate1 = schedStartDate;
            }
            system.debug('schedStartDate: ' + schedStartDate);
              if(offsetDate1 != null){
                  fOut.activityDate = offsetDate1;
                  results.add(fOut);
              }
       }
       //offset 2
           if(flin.taskoffset2 != null){
            /*DateTime schedStartDateTime = flin.saSchedStartTime ; // 2022/04/19 1: 38 PM
        	Date schedStartDate = Date.newInstance(schedStartDateTime.year(), schedStartDateTime.month(), schedStartDateTime.day()); //2022/04/19
            Date startOfWeek = schedStartDate.toStartOfWeek();
            system.debug(startOfWeek);
            Integer dayOfWeek = schedStartDate.day()-startOfWeek.day(); //
            system.debug('dayOfWeek :' + dayOfWeek);
            Integer dayoffset = mapDayOfWeekback.get(mapDaycheck.get(dayOfWeek)); 
            system.debug('dayoffset : ' + dayoffset);*/
            DateTime schedStartDateTime = flin.saSchedStartTime ; //07/29/2022 11:98
            String sdayOfWeek=schedStartDateTime.format('EEEE');  //Friday
            System.debug('Day : ' + sdayOfWeek);
            Integer dayOfWeek = mapInteger.get(sdayOfWeek); //5
            Date schedStartDate = Date.newInstance(schedStartDateTime.year(), schedStartDateTime.month(), schedStartDateTime.day()); //2022/04/19  
            system.debug('schedStartDate : ' + schedStartDate); //08/05/2022
            Integer dayoffset = mapDayOfWeekback.get(mapDaycheck.get(dayOfWeek));
            if(flin.taskoffset2 > 0){
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
             Integer Absoffset1 =  math.abs(flin.taskoffset2) ;
            
             while(Absoffset1 > dayoffset){ //11 > 6, 4 > 1
                schedStartDate = schedStartDate.addDays(week_7);  //2022/04/16 + 7 = 23, 23+ 7 = 30
                Absoffset1 = Absoffset1 - 5 ; // 6
                system.debug('schedStartDate : ' + schedStartDate + '::' + 'Absoffset1 :' + Absoffset1); 
            }
            if(flin.taskoffset2 > 0){
                schedStartDate = schedStartDate.addDays(Absoffset1);
                schedStartDate = schedStartDate.addDays(-weekendOffset);
                offsetDate2 = schedStartDate;
            }
            else{
                	schedStartDate = schedStartDate.addDays(-Absoffset1);
                    if(dayOfWeek == 0){
                        if(Absoffset1 == 6){
                           	schedStartDate = schedStartDate.addDays(-2); 
                        }
                         schedStartDate = schedStartDate.addDays(-1);
                    }	
                	offsetDate2 = schedStartDate;
            }
            system.debug('schedStartDate: ' + schedStartDate);
			if(offsetDate2 != null){
                  fOut.activityDate2 = offsetDate2;
                  results.add(fOut);
              }
       }
        
	//offset 3
           if(flin.taskoffset3 != null){
            DateTime schedStartDateTime = flin.saSchedStartTime ; //07/29/2022 11:98
            String sdayOfWeek=schedStartDateTime.format('EEEE');  //Friday
            System.debug('Day : ' + sdayOfWeek);
            Integer dayOfWeek = mapInteger.get(sdayOfWeek); //5
            Date schedStartDate = Date.newInstance(schedStartDateTime.year(), schedStartDateTime.month(), schedStartDateTime.day()); //2022/04/19  
            system.debug('schedStartDate : ' + schedStartDate); //08/05/2022
            Integer dayoffset = mapDayOfWeekback.get(mapDaycheck.get(dayOfWeek));
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
       system.debug('results Line 129 :' + results);
      List<FlowOutputs> listRes = new List<FlowOutputs>(results);  
     system.debug('results in list :' + listRes);
      return listRes ;
        
    }
    public class FlowInputs{
    
    
        @InvocableVariable
        public datetime saSchedStartTime;
        
        @InvocableVariable
        public Integer taskoffset1;
        
        @InvocableVariable
        public Integer taskoffset2;
        
        @InvocableVariable
        public Integer taskoffset3;
        
    }
     public class FlowOutputs{
        
        @InvocableVariable
        public date activityDate ;
        
        @InvocableVariable
        public date activityDate2 ;
         
        @InvocableVariable
        public date activityDate3 ;
         
        /*@InvocableVariable 
        public Integer sCount ;*/
        
       
    }

}