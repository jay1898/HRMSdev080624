public class P_ReportController {
    
    public static List<String> HEADERS = new List<String>{'Opportunity Id', 'Opportunity No', 'Owner Name', 'Account FirstName', 'Account LastName', 'Account BillingStreet', 'Account BillingCity', 'Account BillingState', 'Account BillingCountry', 'Account BillingPostalCode', 'Account PersonEmail', 'Phone', 'Status', 'StageName', 'Appointment DateTime', 'CreatedDate', 'CloseDate', 'LeadSource', 'Quote Number Shell', 'Total Price Quote', 'Signed Contract Date', 'Appointment DateTime Email'};
    public static List<String> HEADERS_API_NAME = new List<String>{'Opportunity_Id', 'Opportunity_No_c', 'Owner_Name', 'Account_FirstName', 'Account_LastName', 'Account_BillingStreet', 'Account_BillingCity', 'Account_BillingState', 'Account_BillingCountry', 'Account_BillingPostalCode', 'Account_PersonEmail', 'Phone_c', 'Status_c', 'StageName', 'Appointment_DateTime_c', 'CreatedDate', 'CloseDate', 'LeadSource', 'Quote_Number_Shell_c', 'Total_Price_Quote_c', 'Signed_Contract_Date_c', 'Appointment_DateTime_Email_c'};
            
	public static String HATCH_REPORT_TYPE = 'Hatch Report';
    public static String MINNEAPOLIS_REPORT_TYPE = 'Minneapolis Report';
    public static String HATCH_REPORT_NAME = 'Hatch | (Pella Mountain West) Rich.csv';
    public static String MINNEAPOLIS_REPORT_NAME = 'Hatch | Minneapolis Report.csv';

    @AuraEnabled
    public static List<String> getTheFileUrl() {
        List<String> nameAndUrl = new List<String>();
        String lEntityId = P_ReportControllerHelper.getUserAccountId();
        Id docId = null;
        User userInfos = [Select Id, AccountId, Report_Access_at_Community__c from User Where Id=:UserInfo.getUserId() Limit 1];
        String reportName = userInfos.Report_Access_at_Community__c;
        String fileName = null;
        if(reportName == HATCH_REPORT_TYPE) {
            fileName = HATCH_REPORT_NAME;
        } else if(reportName == MINNEAPOLIS_REPORT_TYPE) {
            fileName = MINNEAPOLIS_REPORT_NAME;
        }
        
        if(lEntityId!=null) {
            List<ContentVersion> cvList = P_ReportControllerHelper.getAllFiles(lEntityId, fileName);
            if(!cvList.isEmpty()) {
                docId = cvList[0].Id;
            }
        }
        nameAndUrl.add(fileName);
        nameAndUrl.add('/sfc/servlet.shepherd/version/download/'+docId);
        return nameAndUrl;
    }
    
    public static void processOpty() {
        try{
            Set<String> userIdSet = new Set<String>();
            System.debug('HATCH ROLE ID - '+System.Label.P_Hatch_Role_Id);
            userIdSet.add(System.Label.P_Hatch_Role_Id); //'00E3i000000DeLrEAK' 011/382/388 General Manager
            
            Set<String> finalUserIdSet = P_ReportControllerHelper.getAllSubRoleIds(userIdSet, new Set<String>());
            
            List<P_ReportControllerHelper.OpportunityWrapper> csvRowList = P_ReportControllerHelper.getOpty(finalUserIdSet);
            P_ReportControllerHelper.scheduleNextProcess('processOpty');
            //P_ReportControllerHelper.createCSV(HEADERS, HEADERS_API_NAME, csvRowList, HATCH_REPORT_NAME);
            P_CreateCSVFileBatch bt = new P_CreateCSVFileBatch(csvRowList, HATCH_REPORT_NAME);
            Database.executeBatch(bt);
            
        } catch(Exception ex) {
            System.debug('processOpty => '+ex.getLineNumber() +' - '+ex.getMessage());
        }
    }
    
    public static void processOptyMinneapolis() {
        try{
            List<P_ReportControllerHelper.OpportunityWrapper> csvRowList = P_ReportControllerHelper.getOptyMinneapolis();
            P_ReportControllerHelper.scheduleNextProcess('processOptyMinneapolis');
            //P_ReportControllerHelper.createCSV(HEADERS, HEADERS_API_NAME, csvRowList, MINNEAPOLIS_REPORT_NAME);
            P_CreateCSVFileBatch bt = new P_CreateCSVFileBatch(csvRowList, MINNEAPOLIS_REPORT_NAME);
            Database.executeBatch(bt);
            
            
        } catch(Exception ex) {
            System.debug('processOptyMinneapolis => '+ex.getLineNumber() +' - '+ex.getMessage());
        }
    }
    
}