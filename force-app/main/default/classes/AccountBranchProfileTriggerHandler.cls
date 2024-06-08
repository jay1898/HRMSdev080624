/**
*   @Author:        Mayank Srivastava (eVerge)
*   @Date:          20/02/2020
*   @TaskSource:    
*   @Purpose:       Trigger handler Class for AccountBranchProfile Trigger

*   @Updates:       
*/
public without sharing class AccountBranchProfileTriggerHandler 
{
	/**
    *   @Method:        updateBrancIdsOnAccount
    *   @Purpose:       To update BranchIds on Account from all Account branch profile records which are under account
    *   @Author:        Mayank Srivastava (eVerge)
    *   @Date:          20/02/2020
    *   @TaskSource:    

    *   @Updates:       
    */
    public static void updateBrancIdsOnAccount(List<Account_Branch_Profile__c> abps) 
    {
    	Map<Id,Set<String>> accountIdToBranchIds = new Map<Id,Set<String>>();
    	Set<Id> accountIds = new Set<Id>();
    	List<Account> accountsToUpdate = new List<Account>();

        for(Account_Branch_Profile__c abp : abps)
        {
        	// Get Account Ids 
        	if(String.isNotBlank(abp.Party_Account__c)) accountIds.add(abp.Party_Account__c);
        }

        System.debug('UAC: accountIds ' + accountIds );
        if(accountIds.size() == 0) return ;
		
        // get all branch family
        Map<Id,set<Id>> familyWiseBranchAccounts=new Map<Id,set<Id>>();
        // Get all account branch profiles related to Account 
        for(Account_Branch_Profile__c abp : [	SELECT Id, Branch__r.Branch_Number__c,Branch__r.Branch_Family__c , Party_Account__c 
        										FROM Account_Branch_Profile__c 
        										WHERE Party_Account__c IN :accountIds])
        {
        	// Get existing branch Ids
        	Set<String> tempList = accountIdToBranchIds.get(abp.Party_Account__c) ;

        	// If null then initialize 
        	if(tempList == null)
        	{
        		tempList = new Set<String>();
        		accountIdToBranchIds.put(abp.Party_Account__c, tempList);
        	}
        	tempList.add(abp.Branch__r.Branch_Number__c);
            
            if(!familyWiseBranchAccounts.containsKey(abp.Branch__r.Branch_Family__c)){
                familyWiseBranchAccounts.put(abp.Branch__r.Branch_Family__c,new Set<Id>());
            }
            familyWiseBranchAccounts.get(abp.Branch__r.Branch_Family__c).add(abp.Party_Account__c);
        }
        System.debug('UAC: accountIdToBranchIds '  + accountIdToBranchIds);
		
        // Get All Trade and Commercial Branch Number
        for(Branch__c branch : [SELECT Id, Branch_Number__c,Branch_Family__c , T_C_Branch_Number__c 
                                FROM Branch__c 
                                WHERE Branch_Family__c IN :familyWiseBranchAccounts.keySet()])
        {
            for(Id accId : familyWiseBranchAccounts.get(branch.Branch_Family__c)){
                accountIdToBranchIds.get(accId).add(branch.T_C_Branch_Number__c);
            }
        }
        
        // Iterate over account Ids 
        for(Id accountId : accountIdToBranchIds.keySet() )
        {
        	// Get branch Ids for current account Id
        	String branchIds = ';' + String.join(new List<String>(accountIdToBranchIds.get(accountId)), ';' ) + ';' ;

        	// Assign Branch Numbers on Account
        	Account ac = new Account(Id=accountId, Branch_Number__c = branchIds );
        	
        	// Add into list 
        	accountsToUpdate.add(ac);
        }
        System.debug('UAC: accountsToUpdate ' + accountsToUpdate );

        // Update Accounts 	
        if(accountsToUpdate.size() > 0) update accountsToUpdate ;
    }
}