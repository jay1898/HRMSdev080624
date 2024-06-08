global class UpdatePellaAccountOwnerBatch Implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Name, OwnerId,Branch_Number__c,Temp_branch_Number__c FROM Account  WHERE RecordType.DeveloperName = \'Organization\'  ');
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accList){
        List<Account> listChildAcc=[ SELECT Id,ParentId, Branch__r.Branch_Family__r.Pella_Account_Owner__c FROM Account WHERE Branch__r.Branch_Family__r.Pella_Account_Owner__c != null and parentId=:accList];
        Map<Id,Account> parentWiseChildAcc=new Map<Id,Account>();
        for(Account acc: listChildAcc){
            if(!parentWiseChildAcc.containsKey(acc.ParentId)){
                parentWiseChildAcc.put(acc.ParentId,acc);
            }
        }
        Account childAcc;
        for(Account acc : accList){
            if(parentWiseChildAcc.containsKey(acc.Id)){
                childAcc=parentWiseChildAcc.get(acc.Id);
                System.debug('@@ : '+ childAcc.Branch__r.Branch_Family__r.Pella_Account_Owner__c);
                if(childAcc.Branch__c!=null && String.isNotBlank(childAcc.Branch__r.Branch_Family__r.Pella_Account_Owner__c)){
                    acc.OwnerId = childAcc.Branch__r.Branch_Family__r.Pella_Account_Owner__c;
                    acc.Temp_branch_Number__c= acc.Branch_Number__c;
                    acc.Branch_Number__c='';
                }
            }
        }
        Update accList;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext sc){
        UpdatePellaAccountOwnerBatch myBatchObject = new UpdatePellaAccountOwnerBatch(); 
        Database.executeBatch(myBatchObject, 200);
    }
}