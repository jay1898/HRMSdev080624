public class HolidayController {

    @AuraEnabled(cacheable = true)
    public static String getHolidayByYear(){
        try {
            List<HolidayData> holidayList = new List<HolidayData>();

            List<Holiday> holidays= [SELECT Id, Name, ActivityDate, IsRecurrence FROM Holiday 
                                    WHERE ActivityDate = THIS_YEAR AND Name != 'Manual Holiday' AND IsRecurrence = false
                                    ORDER BY ActivityDate];
            
            if (holidays.size() > 0) {
                for (Holiday hd : holidays) {
                    Date d = hd.ActivityDate;
                    DateTime dt = hd.ActivityDate;

                    HolidayData h = new HolidayData();
                    h.holidayDate = d;
                    h.dateNumber = String.valueOf(dt.day());
                    h.month = dt.format('MMMM');
                    h.name = hd.Name;
                    h.dayName = dt.format('EEEE');

                    holidayList.add(h);
                }
            }
            return JSON.serialize(holidaylist);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class HolidayData {
        public Date holidayDate;
        public String dateNumber;
        public String month;
        public String name;
        public String dayName;
    }
}