@isTest
public class P_ReportController_Test {
   public static String MINNEAPOLIS_REPORT_NAME = 'Hatch | Minneapolis Report.csv';
    
    @IsTest(SeeAllData=true)
    private static void testProcessOpty(){
        User usr = TestUtil.createUser(true);
        usr.Report_Access_at_Community__c = 'Hatch Report';
        update usr;
        System.runAs(usr) {
            P_ReportController.processOpty();
            P_ReportController.getTheFileUrl();
        }
    }
    
    
    
    
    @IsTest(SeeAllData=true)
    private static void testProcessOptyMinneapolis(){
        User usr = TestUtil.createUser(true);
        usr.Report_Access_at_Community__c = 'Minneapolis Report';
        update usr;
        
        Branch_Grouping__c branchG = TestUtil.createBranchGrouping('Minneapolis Branch',true);
        
        Branch__c branch = TestUtil.createBranch('Minneapolis', '12345', branchG.Id, true);
        Account ac = TestUtil.createAccount('Branch Account',false);
        ac.Branch__c = branch.Id;
        
        Opportunity op = TestUtil.createOpportunity('Test One', ac.Id, usr.Id, true);
        
        System.runAs(usr) {
            P_ReportController.processOptyMinneapolis();
           
        }
    }
}