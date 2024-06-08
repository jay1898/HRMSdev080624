public class P_ReportControllerHelper {
    
    public static void createCSV(List<String> csvHeaders, List<String> csvFieldAPINames, List<OpportunityWrapper> csvRowList, String title){
        try{
            String headerRow = String.join(csvHeaders,',') + '\n';
            String concantenatedStr = headerRow;
            concantenatedStr = createSObjectString(csvFieldAPINames, csvRowList, concantenatedStr);
            //System.debug('concantenatedStr -- '+concantenatedStr);
            //title += '.csv';
            createFile(concantenatedStr, title);
        } catch(Exception ex) {
            System.debug('createCSV Exception => '+ex.getLineNumber() +' - '+ex.getMessage());
        }
    }
    
    public static String createSObjectString(List<String> csvFieldAPINames, List<OpportunityWrapper> csvRowList, String concantenatedStr){
        try{
            Integer i = 0;
            Integer rowListSize = csvRowList.size();
            Integer headerSize = csvFieldAPINames.size();
            for(OpportunityWrapper row :csvRowList){
                //assuming the rowList is in the correct format and each string in the list is a new record
                Map<String, Object> objFieldMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(row));
                
                Integer j = 0;
                for(String objField :csvFieldAPINames){
                    //System.debug('VALLLL -- '+String.valueOf(objFieldMap.get('Owner.Name')));
                    concantenatedStr += objFieldMap.get(objField) != null ? String.valueOf(objFieldMap.get(objField)) : '';
                    j++;
                    concantenatedStr += j != headerSize ? ',' : '';//add comma separator
                }
                i++;
                if(i != rowListSize) concantenatedStr += '\n';//add new line
            }
            return concantenatedStr;
        } catch(Exception ex) {
            System.debug('createCSV Exception => '+ex.getLineNumber() +' - '+ex.getMessage());
            return concantenatedStr;
        }
    }
    
    public static void createFile(String versionData, String fileName) {
        try{
            String lEntityId = getUserAccountId();
            if(lEntityId!=null) {
                List<ContentVersion> toDeleteCV = getAllFiles(lEntityId, fileName);
                if(!toDeleteCV.isEmpty()) {
                    Id toDeleteId = toDeleteCV[0].ContentDocumentId;
                    for(ContentDocument cd :[SELECT Id FROM ContentDocument WHERE Id=:toDeleteId]) {
                        delete cd;
                    }
                }
                
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S'; //denotes it resides on Salesforce
                cv.Title = fileName; //title of the file
                cv.PathOnClient = fileName; // full path within Salesforce this can just be the name of file to be in the library
                cv.VersionData = Blob.valueOf(versionData); //file data
                insert cv;
                
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = lEntityId;//'0011D000015YbAZQA0';
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                insert cdl;
                System.debug('CSV ID --> '+cv.Id);
            }
        } catch (Exception ex) {
            System.debug('CONTEND DOCUMENT DELETE EXCEPTION '+ex.getMessage()+''+ex.getLineNumber());
        }
        
    }
    
    public static String getUserAccountId() {
        System.debug('lEntityId = '+System.Label.P_Hatch_Account_Id);
        String lEntityId = System.Label.P_Hatch_Account_Id;
        
        System.debug('lEntityId = '+lEntityId);
        return lEntityId;
        
    }
    
    public static List<ContentVersion> getAllFiles(String lEntityId, String fileName) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        try{
            Id toReturn = null;
            Set<Id> contId = new Set<Id>();
            
            if(lEntityId!=null) {
                List<ContentDocumentLink> cdlink = [SELECT ContentDocumentId FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId =:lEntityId];
                if(cdlink.size()>0) {
                    for(ContentDocumentLink cdl : cdlink) {
                        contId.add(cdl.ContentDocumentId);
                    }
                    cvList = [SELECT Id,ContentDocumentId FROM ContentVersion 
                              WHERE ContentDocumentId IN :contId and Title=:fileName Limit 1];
                }
            }
            return cvList;
        } catch(Exception ex) {
            System.debug('getAllFiles Exception => '+ex.getLineNumber() +' - '+ex.getMessage());
            return cvList;
        }
    }
    
    public static Set<String> getAllSubRoleIds(Set<String> roleIds, Set<String> newRoleIds) {
        //00E3i000000DeLr
        Set<String> currentRoleIds = new Set<String>();
        //Set<ID> newRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        
        for(UserRole userRole :[select Id from UserRole where ParentRoleId 
                                IN :roleIds AND ParentRoleID != null]) {
                                    //System.debug('userRoleId -> '+userRole.Id);
                                    currentRoleIds.add(userRole.Id);
                                    newRoleIds.add(userRole.Id);
                                }
        
        if(currentRoleIds.size() > 0) {
            Set<String> newIds = getAllSubRoleIds(currentRoleIds, newRoleIds);
            currentRoleIds.addAll(newIds);
            return currentRoleIds;
        } else {
            return newRoleIds;
        }
    } 
    
    public static List<OpportunityWrapper> getOpty(Set<String> usRoles) {
        List<OpportunityWrapper> optyList = new List<OpportunityWrapper>();
        String queryStr = null;
        try{
            String hatchReportId = System.Label.P_Hatch_Report_Id;
            String roleIdsVal = null;
            for(String rId : usRoles) {
                //System.debug('rId --> '+rId);
                roleIdsVal = roleIdsVal == null ? '(\''+rId : roleIdsVal+'\', \''+rId ;
            }
            roleIdsVal = roleIdsVal + '\')';
            System.debug('STRING roleIdsVal --> '+roleIdsVal);
            String finalUserIdString = string.valueof(usRoles).replace(', ', '\', \'').replace('{', '(\'').replace('}', '\')');
            finalUserIdString = finalUserIdString.replace(', \'...\'','');
            
            List <Report> reportList = [SELECT Id,DeveloperName FROM Report where Id =:hatchReportId];// '00O1D000001itapUAA'
            String reportId = (String)reportList.get(0).get('Id');
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            Reports.ReportMetadata rm = results.getReportMetadata();
            
            String WHERE_CONDITION = '';
            Boolean TerritoryVal = false;
            Boolean StatusVal = false;
            Boolean ProbabilityVal = false;
            String probVal = 'all' ;
            Decimal probDVal = null;
            String actualIsClosedOrWonVal = null;
            
            for(Reports.StandardFilter rf1 : rm.getStandardFilters()){
                System.debug('Filter Name() --> '+rf1.getName());
                System.debug('Filter Value() --> '+rf1.getValue());
                if(rf1.getName() == 'terr') { //Territories all, terr2Missing
                    string actualVal = rf1.getValue() == 'all' ? 'All' : 'Missing';
                    String andSep = WHERE_CONDITION != '' ? ' and ' : '' ;
                    TerritoryVal = true;
                    //WHERE_CONDITION = WHERE_CONDITION + 'Territories = '+actualVal+andSep;
                } else if(rf1.getName() == 'open') { // Status open, closed
                    String actualVal = rf1.getValue() == 'closed' ? 'IsClosed' : 'IsWon';
                    System.debug('Status Filter Val '+rf1.getValue());
                    String andSep = WHERE_CONDITION != '' ? ' and ' : '' ;
                    if(rf1.getValue() != 'all' && rf1.getValue() != 'closedwon') {
                        actualIsClosedOrWonVal = actualVal;
                        StatusVal = true;
                        WHERE_CONDITION = WHERE_CONDITION + andSep + actualVal +' = true';
                    } else if(rf1.getValue() == 'closedwon') {
                        WHERE_CONDITION = andSep+'IsClosed = true and IsWon=true';
                    }
                    system.debug('WHERE_CONDITION 1 -> '+WHERE_CONDITION);
                    
                } else if(rf1.getName() == 'probability') {
                    String andSep = WHERE_CONDITION != '' ? ' and ' : '' ;
                    if(rf1.getValue() != '>0') {
                        probVal = rf1.getValue().contains('lt') ? '<' : '>' ;
                        probDVal = rf1.getValue().contains('lt') ? Decimal.valueOf(rf1.getValue().removeStart('lt')) : Decimal.valueOf(rf1.getValue().removeStart('gt'));
                        ProbabilityVal = true;
                        WHERE_CONDITION = WHERE_CONDITION + andSep + 'Probability' + probVal+probDVal;
                    }
                    system.debug('WHERE_CONDITION 2 -> '+WHERE_CONDITION);
                }
            }
            //String commaSep = WHERE_CONDITION != '' ? ',' : '' ;
            //WHERE_CONDITION = WHERE_CONDITION + 'Appointment_DateTime__c > '+rm.getStandardDateFilter().getStartDate() 
            //  +' and Appointment_DateTime__c < '+rm.getStandardDateFilter().getEndDate();
            
            List<String> twoDates = new List<String>();
            //rm.getStandardDateFilter().getcolumn()
            twoDates.add(rm.getStandardDateFilter().getStartDate());
            twoDates.add(rm.getStandardDateFilter().getEndDate());
            
            
            //twoDates = fetchReportFilterValues();
            String whereCondition = WHERE_CONDITION!= '' ? 'and '+WHERE_CONDITION : '';
            System.debug('whereCondition -- '+whereCondition);
            DateTime fromDate = Date.valueOf(twoDates[0]);//+'T00:00:00.000+0000');
            DateTime toDate = Date.valueOf(twoDates[1]);//.addDays(1);
            String selectFields = ' Id,Owner.UserRoleId,Zone__r.Name,'+
                'Opportunity_No__c, Owner.Name, Account.FirstName, Account.LastName, Account.PersonMailingStreet, Account.PersonMailingCity,'+
                'Account.PersonMailingState, Account.PersonMailingCountry, Account.PersonMailingPostalCode, Account.PersonEmail, Phone__c, Status__c,'+
                'StageName, Appointment_DateTime__c, CreatedDate, CloseDate, LeadSource, Quote_Number_Shell__c,Total_Price_Quote__c,'+
                'Signed_Contract_Date__c,Appointment_DateTime_Email__c ';
            
            //fromDate = 2022-01-01T01:00:00.000+0000;
            //toDate = 2022-02-28T23:59:00.000+0000;
            queryStr = 'SELECT  '+selectFields+'  FROM Opportunity WHERE Account.Owner.UserRoleId IN '+roleIdsVal+' and Appointment_DateTime__c < '+toDate+' and Appointment_DateTime__c > '+fromDate+whereCondition;
            System.debug('PRINTLN ->' +queryStr);
            List<Opportunity> allOpty = Database.query('SELECT  '+selectFields+'  FROM Opportunity WHERE Account.Owner.UserRoleId IN :usRoles and Appointment_DateTime__c < :toDate and Appointment_DateTime__c > :fromDate '+whereCondition);
            System.debug('allOpty1 SIZE-->  -- > '+allOpty.size());
            //DateTime fromDate = Date.valueOf(twoDates[0]);//+'T00:00:00.000+0000');
            //DateTime toDate = Date.valueOf(twoDates[1]).addDays(1);//+'T23:59:00.000+0000'); // Since we are s
            //2022-02-28T23:59:00.000+0000
            
            for(Opportunity op : allOpty) {
                OpportunityWrapper opty = new OpportunityWrapper();
                opty.Opportunity_Id = op.Id;
                opty.Opportunity_No_c = op.Opportunity_No__c;
                opty.Owner_Name = op.Owner.Name;
                opty.Account_FirstName = op.Account.FirstName;
                opty.Account_LastName = op.Account.LastName;
                opty.Account_BillingStreet = op.Account.PersonMailingStreet;
                opty.Account_BillingCity = op.Account.PersonMailingCity;
                opty.Account_BillingState = op.Account.PersonMailingState;
                opty.Account_BillingCountry = op.Account.PersonMailingCountry;
                opty.Account_BillingPostalCode = op.Account.PersonMailingPostalCode;
                opty.Account_PersonEmail = op.Account.PersonEmail;
                
                opty.Phone_c = op.Phone__c;
                opty.Status_c = op.Status__c;
                opty.StageName = op.StageName;
                opty.Appointment_DateTime_c = op.Appointment_DateTime__c!=null ? op.Appointment_DateTime__c : null;
                opty.CreatedDate = op.CreatedDate;
                opty.CloseDate = op.CloseDate;
                opty.LeadSource = op.LeadSource;
                opty.Quote_Number_Shell_c = op.Quote_Number_Shell__c;
                opty.Total_Price_Quote_c = op.Total_Price_Quote__c;
                opty.Signed_Contract_Date_c = op.Signed_Contract_Date__c!=null ? op.Signed_Contract_Date__c : null;
                opty.Appointment_DateTime_Email_c = op.Appointment_DateTime_Email__c!=null ? op.Appointment_DateTime_Email__c : null;
                optyList.add(opty);
            }
            
            return optyList;
        } catch (Exception ex) {
            System.debug('EXCEPTION --> '+ex.getMessage());
            System.debug('EXCEPTION 2--> '+ex.getLineNumber());
            new ApexDebugLog().createLog( new ApexDebugLog.Error( 'P_ReportController', 'getOpty',  'getOpty Query : '+queryStr, ex, 'Internal' ));
            return optyList;
        }
    }
    
    public static List<OpportunityWrapper> getOptyMinneapolis() {
        List<OpportunityWrapper> optyList = new List<OpportunityWrapper>();
        String queryStr = null;
        try{
            System.debug('getOptyMinneapolis'); 
            String WHERE_CONDITION = '';
            Boolean TerritoryVal = false;
            Boolean StatusVal = false;
            Boolean ProbabilityVal = false;
            String probVal = 'all' ;
            Decimal probDVal = null;
            String actualIsClosedOrWonVal = null;
            String hatchReportId = System.Label.P_Hatch_Minneapolis_Report_Id;//'00O1D000001jSAfUAM';
            
            List <Report> reportList = [SELECT Id,DeveloperName FROM Report where Id =:hatchReportId];// '00O1D000001itapUAA'
            
            String reportId = (String)reportList.get(0).get('Id');
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            Reports.ReportMetadata rm = results.getReportMetadata();
            System.debug('reportId -- '+reportId);
            for(Reports.StandardFilter rf1 : rm.getStandardFilters()){
                
                if(rf1.getName() == 'terr') { //Territories all, terr2Missing
                    string actualVal = rf1.getValue() == 'all' ? 'All' : 'Missing';
                    String andSep = WHERE_CONDITION != '' ? ' and ' : '' ;
                    TerritoryVal = true;
                } else if(rf1.getName() == 'open') { // Status open, closed
                    String actualVal = rf1.getValue() == 'closed' ? 'IsClosed' : 'IsWon';
                    String andSep = WHERE_CONDITION != '' ? ' and ' : '' ;
                    if(rf1.getValue() != 'all' && rf1.getValue() != 'closedwon') {
                        actualIsClosedOrWonVal = actualVal;
                        StatusVal = true;
                        WHERE_CONDITION = WHERE_CONDITION + andSep + actualVal +' = true';
                    } else if(rf1.getValue() == 'closedwon') {
                        WHERE_CONDITION = andSep+'IsClosed = true and IsWon=true';
                    }
                } else if(rf1.getName() == 'probability') {
                    String andSep = WHERE_CONDITION != '' ? ' and ' : '' ;
                    if(rf1.getValue() != '>0') {
                        probVal = rf1.getValue().contains('lt') ? '<' : '>' ;
                        probDVal = rf1.getValue().contains('lt') ? Decimal.valueOf(rf1.getValue().removeStart('lt')) : Decimal.valueOf(rf1.getValue().removeStart('gt'));
                        ProbabilityVal = true;
                        WHERE_CONDITION = WHERE_CONDITION + andSep + 'Probability' + probVal+probDVal;
                    }
                }
            }
            System.debug('WHERE_CONDITION -- '+WHERE_CONDITION);
            List<String> twoDates = new List<String>();
            twoDates.add(rm.getStandardDateFilter().getStartDate());
            twoDates.add(rm.getStandardDateFilter().getEndDate());
            
            String whereCondition = WHERE_CONDITION!= '' ? 'and '+WHERE_CONDITION : '';
            DateTime fromDate = Date.valueOf(twoDates[0]);
            DateTime toDate = Date.valueOf(twoDates[1]);
            
            System.debug('fromDate -- '+fromDate);
            
            String selectFields = ' Id,Owner.UserRoleId,Zone__r.Name,'+
                'Opportunity_No__c, Owner.Name, Account.FirstName, Account.LastName, Account.PersonMailingStreet, Account.PersonMailingCity,'+
                'Account.PersonMailingState, Account.PersonMailingCountry, Account.PersonMailingPostalCode, Account.PersonEmail, Phone__c, Status__c,'+
                'StageName, Appointment_DateTime__c, CreatedDate, CloseDate, LeadSource, Quote_Number_Shell__c,Total_Price_Quote__c,'+
                'Signed_Contract_Date__c,Appointment_DateTime_Email__c ';
            
            String BranchName = 'Minneapolis';
            
            queryStr = 'SELECT  '+selectFields+'  FROM Opportunity WHERE Branch__c =:BranchName and Appointment_DateTime__c < '+toDate+' and Appointment_DateTime__c > '+fromDate+whereCondition;
            
            List<Opportunity> allOpty = Database.query('SELECT  '+selectFields+'  FROM Opportunity WHERE Branch__c =:BranchName and Appointment_DateTime__c < :toDate and Appointment_DateTime__c > :fromDate '+whereCondition);
            System.debug('allOpty size ==> '+allOpty.size());
            for(Opportunity op : allOpty) {
                OpportunityWrapper opty = new OpportunityWrapper();
                opty.Opportunity_Id = op.Id;
                opty.Opportunity_No_c = op.Opportunity_No__c;
                opty.Owner_Name = op.Owner.Name;
                opty.Account_FirstName = op.Account.FirstName;
                opty.Account_LastName = op.Account.LastName;
                opty.Account_BillingStreet = op.Account.PersonMailingStreet;
                opty.Account_BillingCity = op.Account.PersonMailingCity;
                opty.Account_BillingState = op.Account.PersonMailingState;
                opty.Account_BillingCountry = op.Account.PersonMailingCountry;
                opty.Account_BillingPostalCode = op.Account.PersonMailingPostalCode;
                opty.Account_PersonEmail = op.Account.PersonEmail;
                
                opty.Phone_c = op.Phone__c;
                opty.Status_c = op.Status__c;
                opty.StageName = op.StageName;
                opty.Appointment_DateTime_c = op.Appointment_DateTime__c!=null ? op.Appointment_DateTime__c : null;
                opty.CreatedDate = op.CreatedDate;
                opty.CloseDate = op.CloseDate;
                opty.LeadSource = op.LeadSource;
                opty.Quote_Number_Shell_c = op.Quote_Number_Shell__c;
                opty.Total_Price_Quote_c = op.Total_Price_Quote__c;
                opty.Signed_Contract_Date_c = op.Signed_Contract_Date__c!=null ? op.Signed_Contract_Date__c : null;
                opty.Appointment_DateTime_Email_c = op.Appointment_DateTime_Email__c!=null ? op.Appointment_DateTime_Email__c : null;
                optyList.add(opty);
            }
            
            return optyList;
        } catch (Exception ex) {
            System.debug('P_ReportController Exception => '+ex.getLineNumber() +' - '+ex.getMessage());
            
            new ApexDebugLog().createLog( new ApexDebugLog.Error( 'P_ReportController', 'getOptyMinneapolis',  'getOptyMinneapolis Query : '+queryStr, ex, 'Internal' ));
            return optyList;
        }
    }
    
    public static void scheduleNextProcess(String methodName) {
        System.debug('SCHEDULED AT --> '+System.now());
        DateTime toDate = System.now().addMinutes(60);//next 10 min;
        Integer nextDay = toDate.day();
        Integer nextMonth = toDate.month();
        Integer nextYear = toDate.year();
        Integer hrNow = toDate.hour();
        Integer minNow = toDate.minute();
        
        String schTime = '0 '+minNow+' '+hrNow+' '+nextDay+' '+nextMonth+' ? '+nextYear+'';
        DateTime dt = DateTime.now();
        String nowTime = dt.format('yyyy/MM/dd HH:mm:ss');
        try{
            System.debug('schTime --> '+schTime);
			
            if(methodName == 'processOpty') {
                System.schedule('P_ReportController : '+methodName+' - '+nowTime+': For :'+minNow, schTime , new P_ReportControllerSchedule());   
            } else if(methodName == 'processOptyMinneapolis') {
                System.schedule('P_ReportController : '+methodName+' - '+nowTime+': For :'+minNow, schTime , new P_ReportControllerMinneapolisSchedule());
            }
            System.debug('SCHEDULED FOR --> '+schTime);
        } catch(Exception ex) {
            System.debug('Message --> '+ex.getMessage()+' :: Line --> '+ex.getLineNumber());
            if(methodName == 'processOpty') {
                System.schedule('P_ReportController : '+methodName+' - '+nowTime+': For :'+minNow+' - BYPASS', schTime , new P_ReportControllerSchedule());   
            } else if(methodName == 'processOptyMinneapolis') {
                System.schedule('P_ReportController : '+methodName+' - '+nowTime+': For :'+minNow+' - BYPASS', schTime , new P_ReportControllerMinneapolisSchedule());
            }
            System.debug('SCHEDULED FOR --> '+schTime);
        }
    }
    
    public class OpportunityWrapper {
        public string Opportunity_Id {get;set;} 
        public string Opportunity_No_c {get;set;} 
        public string Owner_Name {get;set;} 
        public string Account_FirstName {get;set;} 
        public string Account_LastName {get;set;} 
        public string Account_BillingStreet {get;set;} 
        public string Account_BillingCity {get;set;} 
        public string Account_BillingState {get;set;} 
        public string Account_BillingCountry {get;set;} 
        public string Account_BillingPostalCode {get;set;} 
        public string Account_PersonEmail {get;set;} 
        public string Phone_c {get;set;} 
        public string Status_c {get;set;} 
        public string StageName {get;set;} 
        public Datetime Appointment_DateTime_c {get;set;}
        public Datetime CreatedDate {get;set;} 
        public Date CloseDate {get;set;} 
        public string LeadSource {get;set;} 
        public string Quote_Number_Shell_c {get;set;} 
        public Decimal Total_Price_Quote_c {get;set;} 
        public Date Signed_Contract_Date_c {get;set;} 
        public Datetime Appointment_DateTime_Email_c {get;set;}
    }
}