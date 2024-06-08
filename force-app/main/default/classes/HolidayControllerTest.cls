@isTest
private class HolidayControllerTest {
    @isTest
    static void getHolidayByYearTest() {

        Test.startTest();
        String holidayData = HolidayController.getHolidayByYear();
        Test.stopTest();

        List<HolidayController.HolidayData> holidays = (List<HolidayController.HolidayData>)JSON.deserialize(holidayData, List<HolidayController.HolidayData>.class);

        String baseOrgUrl = String.valueOf(System.Url.getOrgDomainUrl());

        if (baseOrgUrl == 'https://itechcloudsolution--itechdev.sandbox.my.salesforce.com') {
            System.assertEquals(9, holidays.size());
        }
        else if (baseOrgUrl == 'https://itechcloudsolution--itechdev.sandbox.my.salesforce.com') {
            System.assertEquals(9, holidays.size());
        } 
        else if (baseOrgUrl == 'https://itechcloudsolution--itechdev.sandbox.my.salesforce.com') {
            System.assertEquals(9, holidays.size());
        }        
    }
}