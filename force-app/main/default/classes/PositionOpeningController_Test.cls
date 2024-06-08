@isTest
public class PositionOpeningController_Test {
	@isTest
     public static void getRecruitData(){
        Recruitment_Campaign__c testRE = new Recruitment_Campaign__c(
            Name= 'HR',
            Skills__c = 'Management',
            Job_Type__c ='Full Time',
            Title__c = 'Project Manager',
            Qualification__c = 'B.tech',
            Job_Description__c = 'abc',
            Job_Exp__c = '0-1 Yrs',
            Job_Title__c='test',
            Req_Experience_Skills_qualification__c = 'abcde',
            Responsibilities_and_Duties__c = 'abcdef'
        );
        insert testRE;
         
        Test.startTest();
        	PositionOpeningController.getRecruitData();
         PositionOpeningController.copyRecords(testRE.Id);
        Test.stopTest();
    }
}