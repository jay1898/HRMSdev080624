@isTest
public class CustomLookupControllerTest {
    @isTest
    public static void testMethod1(){
        
        Account acc = testUtil.createAccount('Person Account',true);
        
        WorkType wt = TestUtil.createWorkType('WT1', 'Retail', 'Hours', 2,false);
        wt.Schedule_Type__c = 'Project';
        Insert wt;
        CustomLookupController.fetchRecords('WorkType', 'name', 'WT1', null);
        
        try{
            CustomLookupController.fetchRecords('Account', 'name', 'LastName', '');           
        }
        catch(Exception e){
            system.debug('error::'+e);
        } 
        //CustomLookupController.fetchRecords('Accoumt', 'name', 'LastName', 'Test Account');
        
    }
}