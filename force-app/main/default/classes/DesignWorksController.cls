public class DesignWorksController {
    
    @AuraEnabled
    public static boolean processDWAccess(String recordId) {
        
		/*User cUs = [SELECT Id, Branch_Name_2__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        for(DW_Branch_Access__mdt dwAcc : fetchBranchRecord()) {
            System.debug('cUs -> '+cUs.Branch_Name_2__c.toLowerCase());
            System.debug('dwA -> '+dwAcc.Branch_Name__c.toLowerCase());
            System.debug('dwAcc Is_Active__c -> '+dwAcc.Is_Active__c);
            
            System.debug('dwAcc Available_for_DW__c -> '+dwAcc.Available_for_DW__c);
            
            if(dwAcc.Branch_Name__c.toLowerCase() == cUs.Branch_Name_2__c.toLowerCase() && dwAcc.Is_Active__c && dwAcc.Available_for_DW__c ) {
                System.debug('Its true');
                return true;
            }
        }*/
        
        
		List<Opportunity> oppRec = [SELECT Id,Branch__c FROM Opportunity WHERE Id=:recordId Limit 1];  
        
        for(Design_Work__c dw : [SELECT Id FROM Design_Work__c WHERE Opportunity__c=:recordId Limit 1]) {
            return false;
        }
        
        for(DW_Branch_Access__mdt dwAcc : fetchBranchRecord()) {
            System.debug('cUs -> '+oppRec[0].Branch__c.toLowerCase());
            System.debug('dwA -> '+dwAcc.Branch_Name__c.toLowerCase());
            System.debug('dwAcc Is_Active__c -> '+dwAcc.Is_Active__c);
            
            System.debug('dwAcc Available_for_DW__c -> '+dwAcc.Available_for_DW__c);
            
            if(dwAcc.Branch_Name__c.toLowerCase() == oppRec[0].Branch__c.toLowerCase() && dwAcc.Is_Active__c && dwAcc.Available_for_DW__c ) {
                System.debug('Its true');
                return true;
            }
        }
        return false;
    } 
    
    public static List<DW_Branch_Access__mdt> fetchBranchRecord() {
        List<DW_Branch_Access__mdt> dwBranches = new List<DW_Branch_Access__mdt>();
        dwBranches = [SELECT Id, Available_for_DW__c, Branch_Name__c, Is_Active__c  FROM DW_Branch_Access__mdt];
        return dwBranches;
    }
    
    @AuraEnabled(cacheable=true)
    public static String fetchQueueId() {
        String queueId = null;
        if(!Test.isRunningTest()) {
        	queueId = [Select Id, Name, DeveloperName from Group where type='Queue' and DeveloperName='DW_Team'].Id;
        } else {
            queueId = 'TESTRUN';
        }
        return queueId;
    }
    
}