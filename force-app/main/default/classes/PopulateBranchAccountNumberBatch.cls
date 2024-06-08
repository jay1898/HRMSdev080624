global class PopulateBranchAccountNumberBatch Implements Database.Batchable<sObject>, Schedulable{
 
    global Database.QueryLocator start(Database.BatchableContext bc){
         return Database.getQueryLocator(Label.T_C_Account_Share);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accList){
        List<String> listBranchIds=new list<String>();
        for(Account acc : accList)
        {
            // Get Account Ids 
            if(acc.Branch__c!=null) listBranchIds.add(acc.Branch__c);
        }
        
        if(listBranchIds.size()==0)
            return;
        
        Map<Id,Id> branchWiseBranchFamily=new Map<Id,Id>();
        for(Branch__c branch : [SELECT ID,Branch_Family__c FROM Branch__c where Id in :listBranchIds]){
            branchWiseBranchFamily.put(branch.Id,branch.Branch_Family__c);
        }
        
        Map<Id,List<String>> branchFamilyWiseBranchNumbers=new Map<Id,List<String>>();
        for(Branch__c branch : [SELECT ID,Branch_Family__c,T_C_Branch_Number__c FROM Branch__c where Branch_Family__c in :branchWiseBranchFamily.values()]){
            if(!branchFamilyWiseBranchNumbers.containsKey(branch.Branch_Family__c)){
                branchFamilyWiseBranchNumbers.put(branch.Branch_Family__c,new List<String>());
            }
            branchFamilyWiseBranchNumbers.get(branch.Branch_Family__c).add(branch.T_C_Branch_Number__c);
        }
        for(Account acc : accList)
        {
            // Get Account Ids 
            if(acc.Branch__c!=null){
                if(branchFamilyWiseBranchNumbers.containsKey(branchWiseBranchFamily.get(acc.Branch__c))){
                    acc.Branch_Number__c=';'+String.join(branchFamilyWiseBranchNumbers.get(branchWiseBranchFamily.get(acc.Branch__c)),';')+';';
                }
            }
        }
        
        
        Update accList;
        
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext sc){
        PopulateBranchAccountNumberBatch myBatchObject = new PopulateBranchAccountNumberBatch(); 
        Database.executeBatch(myBatchObject, 200);
    }
    
    
}