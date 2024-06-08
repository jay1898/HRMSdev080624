@isTest
public class P_ScheduleGuntonClasses_Test {
	@isTest
    public static void testAllBatch(){
        DateTime toDate = System.now().addMinutes(10);//next 10 min;
        Integer nextDay = toDate.day();
        Integer nextMonth = toDate.month();
        Integer nextYear = toDate.year();
        Integer hrNow = toDate.hour();
        Integer minNow = toDate.minute();
        
        String schTime = '0 '+minNow+' '+hrNow+' '+nextDay+' '+nextMonth+' ? '+nextYear+'';
        DateTime dt = DateTime.now();
        String nowTime = dt.format('yyyy/MM/dd HH:mm:ss');
        System.schedule('P_ScheduleGuntonClasses : '+nowTime+': For :'+minNow, schTime , new P_ScheduleGuntonClasses());
    }
}