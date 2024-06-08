global class P_ScheduleGuntonClasses implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        scheduleClassByTime();
    }
    
    
    public static void scheduleClassByTime() {
        System.debug('executeSchedule invoked');
        DateTime toDate = System.now().addMinutes(1440);//next 24 Hours = 1440 Mins
        Integer nextDay = toDate.day();
        Integer nextMonth = toDate.month();
        Integer nextYear = toDate.year();
        Integer hrNow = toDate.hour();
        Integer minNow = toDate.minute();
        
        String schTime = '0 '+minNow+' '+hrNow+' '+nextDay+' '+nextMonth+' ? '+nextYear+'';
        DateTime dt = DateTime.now();
        String nowTime = dt.format('yyyy/MM/dd HH:mm:ss');
        try{
            System.schedule('P_ScheduleGuntonClasses : '+nowTime+': For :'+minNow, schTime , new P_ScheduleGuntonClasses());    
            
            DailyGuntonRetailOppsFeed a = new DailyGuntonRetailOppsFeed();
            Database.executeBatch(a);
            
            DailyGuntonTCAccountsFeed a1 = new DailyGuntonTCAccountsFeed();
            Database.executeBatch(a1);
            
            DailyGuntonTCActivitesFeed a2 = new DailyGuntonTCActivitesFeed();
            Database.executeBatch(a2);
            
            DailyGuntonTCOppsFeed a3 = new DailyGuntonTCOppsFeed();
            Database.executeBatch(a3);
            
            DailyGuntonTCQuotesFeed a4 = new DailyGuntonTCQuotesFeed();
            Database.executeBatch(a4);
            
            DailyGuntonTCTasksFeed a5 = new DailyGuntonTCTasksFeed();
            Database.executeBatch(a5);
        } catch(Exception ex) {
            System.debug('Message --> '+ex.getMessage()+' :: Line --> '+ex.getLineNumber());
        }
    }
}