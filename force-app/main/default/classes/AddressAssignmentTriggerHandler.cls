public class AddressAssignmentTriggerHandler 
{
    public static Boolean runTrigger=true; 
    public static Boolean RUN_EBS_CALLOUT = true ;
    
    public static void identifyingValidation(List<Address_Assignment__c> AAList, Map<Id,Address_Assignment__c> oldMap){
        List<Id> listABP=new List<Id>();
        List<Id> listAcc=new List<Id>();
        List<Id> listAAIds=new List<Id>();
        List<Id> listParentAccounts =new List<Id>();
        List<Id> listAddressIds = new List<Id>();
        
        for(Address_Assignment__c AA :AAList){
            if((oldMap==null && AA.Identifying_Address__c ==true)|| (oldMap!=null && (AA.Identifying_Address__c != oldMap.get(AA.Id).Identifying_Address__c && AA.Identifying_Address__c ==true))){
                
                if(AA.Account_Branch_Profile__c!=null){
                    if(listABP.contains(AA.Account_Branch_Profile__c)){
                        AA.Identifying_Address__c=false;
                        continue;
                    }
                    
                    listABP.add(AA.Account_Branch_Profile__c);
                    //listAAIds.add(AA.Id);
                }
                if(AA.Account__c !=null){
                    if(listParentAccounts.contains(AA.Account__c)){
                        AA.Identifying_Address__c=false;
                        continue;
                    }
                    
                    listParentAccounts.add(AA.Account__c);
                    listAAIds.add(AA.Id);
                    listAddressIds.add(AA.Address__c);
                }
            }
        }
        
        Map<Id, Address__c> mapAddress = new Map<Id, Address__c>([SELECT Id, city__c, State__c, Country__c, Street__c, County__c,Zipcode__c FROM Address__c
                                                                         WHERE Id IN :listAddressIds]);
        Map<Id, Id> mapAAToAccount = new Map<Id, Id>();
        List<Account> listAccount = [SELECT Id,ParentId From Account Where Id in :listParentAccounts];
        for(Account AA :listAccount){
            if(String.isNotBlank(AA.ParentId)) listAcc.add(AA.ParentId);
            mapAAToAccount.put(AA.Id, AA.ParentId);
        }
        
        List<Account> parentAccounts = new List<Account>();
        for(Address_Assignment__c AA :AAList){
            if((oldMap==null && AA.Identifying_Address__c ==true)|| (oldMap!=null && (AA.Identifying_Address__c != oldMap.get(AA.Id).Identifying_Address__c && AA.Identifying_Address__c ==true))){
                
                if(AA.Account__c !=null){
                    Account acc = new Account();
                    acc.Id = mapAAToAccount.get(AA.Account__c);
                    acc.BillingCity = mapAddress.get(AA.Address__c).City__c;
                    acc.BillingCountry = mapAddress.get(AA.Address__c).Country__c;
                    acc.BillingState = mapAddress.get(AA.Address__c).State__c;
                    acc.BillingStreet = mapAddress.get(AA.Address__c).Street__c;
                    acc.BillingPostalCode = mapAddress.get(AA.Address__c).Zipcode__c;
                    acc.BillingCounty__c = mapAddress.get(AA.Address__c).County__c;
                    parentAccounts.add(acc);
                }
            }
        }
        System.debug('@@ : parentAccounts : '+parentAccounts.size());
        if(parentAccounts.size() > 0){
            Boolean currentFlag = AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER = false;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            //upsert parentAccounts; 
            Database.update(parentAccounts, dml) ;
            AccountTriggerHandler.RUN_TRIGGER = currentFlag;
            
            List<Address_Assignment__c> listAddressAssignment = [SELECT Id,Name,Identifying_Address__c,Account_Branch_Profile__r.Party_Account__c 
                                                                 FROM Address_Assignment__c WHERE Identifying_Address__c=true 
                                                                 AND Account__c in :listParentAccounts and Id not in :AAList ];
            
            for(Address_Assignment__c addressAss : listAddressAssignment){
                addressAss.Identifying_Address__c=false;
            }
            Boolean currentFlag1 =AddressAssignmentTriggerHandler.runTrigger;
            AddressAssignmentTriggerHandler.runTrigger = false;
            update listAddressAssignment;
            AddressAssignmentTriggerHandler.runTrigger = currentFlag1; 
        }
        
        Map<Id, Id> mapABPToAccount = new Map<Id, Id>();
        List<Account_Branch_Profile__c> listAccountBranch = [SELECT Id,Party_Account__c From Account_Branch_Profile__c Where Id in :listABP];
        for(Account_Branch_Profile__c ABP :listAccountBranch){
            if(String.isNotBlank(abp.Party_Account__c)) listAcc.add(ABP.Party_Account__c);
            mapABPToAccount.put(ABP.Id, ABP.Party_Account__c);
        }
        if(listAcc.size() != 0){
            List<Address_Assignment__c> listAddressAssignment = [SELECT Id,Name,Identifying_Address__c,Account_Branch_Profile__r.Party_Account__c 
                                                                 FROM Address_Assignment__c Where Identifying_Address__c=true 
                                                                 AND Account_Branch_Profile__r.Party_Account__c in :listAcc and Id not in :AAList ];
            
            for(Address_Assignment__c addressAss : listAddressAssignment){
                addressAss.Identifying_Address__c=false;
            }
            Boolean currentFlag=AddressAssignmentTriggerHandler.runTrigger;
            AddressAssignmentTriggerHandler.runTrigger=false;
            update listAddressAssignment;
            AddressAssignmentTriggerHandler.runTrigger=currentFlag;
        }
        
    }
    
    public static void primaryValidation(List<Address_Assignment__c> AAList, Map<Id,Address_Assignment__c> oldMap){
        List<Id> listParentAccounts = new List<Id>();
        Map<String, Map<String,String>> mapAddressType = new Map<String, Map<String,Id>>();
        
        for(Address_Assignment__c AA : AAList){
            if((oldMap == null && AA.Primary_Flag__c == true)|| (oldMap != null && (AA.Primary_Flag__c != oldMap.get(AA.Id).Primary_Flag__c && AA.Primary_Flag__c == true))){
                if(AA.Account__c !=null){
                    
                    if(!mapAddressType.containsKey(AA.Account__c)){
                        mapAddressType.put(AA.Account__c, new Map<String,String>());
                    }
                    if(mapAddressType.get(AA.Account__c).containsKey(AA.Address_Usage_Type__c)){
                        AA.Primary_Flag__c = false;
                        continue;
                    }
                    mapAddressType.get(AA.Account__c).put(AA.Address_Usage_Type__c,AA.Id);
                    
                    listParentAccounts.add(AA.Account__c);
                }
            }
        }
        System.debug('@@mapAddressType ' + mapAddressType);
        List<Address_Assignment__c> addressAssignmentList = [SELECT Id, Name, Identifying_Address__c, Primary_Flag__c, Address_Usage_Type__c, Account__c FROM Address_Assignment__c
                                                             WHERE Account__c IN :listParentAccounts  and Id not in :AAList ];
        
        for(Address_Assignment__c AA : addressAssignmentList){
            if(AA.Primary_Flag__c && mapAddressType.containsKey(AA.Account__c)){
                if(mapAddressType.get(AA.Account__c).containsKey(AA.Address_Usage_Type__c)){
                    System.debug('@@Inside : '+ AA.Name);
                    AA.Primary_Flag__c = false;
                }
            }
        }
        Boolean currentFlag = AddressAssignmentTriggerHandler.runTrigger;
        AddressAssignmentTriggerHandler.runTrigger = false;
        update addressAssignmentList;
        AddressAssignmentTriggerHandler.runTrigger = currentFlag;
    }
    
    public static void createOrUpdateEBSData(List<Address_Assignment__c> AAList, Map<Id,Address_Assignment__c> oldMap){
         for(Address_Assignment__c AA :AAList){
            if(oldMap==null || (AA.Status__c != oldMap.get(AA.Id).Status__c || AA.Primary_Flag__c != oldMap.get(AA.Id).Primary_Flag__c || AA.Address_Usage_Type__c != oldMap.get(AA.Id).Address_Usage_Type__c || AA.HQ_Bill_To__c != oldMap.get(AA.Id).HQ_Bill_To__c)){
                EBSRESTCallout.createAddressAssignmentEBSCallout(AA.Id,oldMap==null?'Insert':'Update');  
            }
        }
    }
    
    public static void StampIdentifyingAddressonAccount(List<Address_Assignment__c> AAList, Map<Id,Address_Assignment__c> oldMap){
        List<Id> listABP=new List<Id>();
        List<Id> listAcc=new List<Id>();
        List<Id> listAAIds=new List<Id>();
        for(Address_Assignment__c AA :AAList){
            if((oldMap==null && AA.Identifying_Address__c ==true)|| (oldMap!=null && (AA.Identifying_Address__c != oldMap.get(AA.Id).Identifying_Address__c && AA.Identifying_Address__c ==true))){
                listABP.add(AA.Account_Branch_Profile__c);
                listAAIds.add(AA.Id);
            }
        }
        Map<Id, Id> mapABPToAccount = new Map<Id, Id>();
        List<Account_Branch_Profile__c> listAccountBranch = [SELECT Id,Party_Account__c From Account_Branch_Profile__c Where Id in :listABP];
        for(Account_Branch_Profile__c ABP :listAccountBranch){
            if(String.isNotBlank(abp.Party_Account__c)) listAcc.add(ABP.Party_Account__c);
            mapABPToAccount.put(ABP.Id, ABP.Party_Account__c);
        }
        if(listAcc.size() == 0) return ;
        Map<Id,Account> listAccToUpdate=new Map<Id,Account>();
        for(Address_Assignment__c AA :[SELECT Id,Name,Identifying_Address__c,Account_Branch_Profile__r.Party_Account__c,
                                       Address__r.street__c,Address__r.city__c,Address__r.state__c,Address__r.country__c,Address__r.zipcode__c
                                       FROM Address_Assignment__c Where Identifying_Address__c=true 
                                       And Id in :listAAIds and Account_Branch_Profile__r.Party_Account__r.IsPersonAccount =true])
        {
            Account Acc=new Account();
            Acc.Id=AA.Account_Branch_Profile__r.Party_Account__c;
            Acc.PersonMailingStreet=AA.Address__r.street__c;
            Acc.PersonMailingCity=AA.Address__r.city__c;
            Acc.PersonMailingState=AA.Address__r.state__c;
            Acc.PersonMailingCountry=AA.Address__r.country__c;
            Acc.PersonMailingPostalCode=AA.Address__r.zipcode__c;
            listAccToUpdate.put(Acc.Id,Acc);
        }
        if(listAccToUpdate.keySet().size()>0){
            try{
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true; 
                DataBase.SaveResult[] Sr= Database.update(listAccToUpdate.Values(), dml); 
                system.debug('@@SR'+SR);
            }catch(Exception ex){
                system.debug('@@Error'+EX);
            }
            
        }
    }
    
    public static void updateAccountAddress(List<Address_Assignment__c> AAList, Map<Id,Address_Assignment__c> oldMap){
        Map<Id, Account> mapAccountToUpdate = new Map<Id, Account>();
        Set<String> addressIds = new Set<String>();
        for(Address_Assignment__c AA : AAList){
            addressIds.add(AA.Address__c);
        }
        Map<Id, Address__c> mapAddress = new Map<Id, Address__c>([SELECT Id, City__c, Country__c, State__c, Street__c, Zipcode__c,County__c FROM Address__c WHERE Id IN :addressIds]);
        
        for(Address_Assignment__c AA : AAList){
            if((oldMap==null || AA.Address_Usage_Type__c != oldMap.get(AA.Id).Address_Usage_Type__c || AA.Primary_Flag__c != oldMap.get(AA.Id).Primary_Flag__c) && AA.Account__c != null && AA.Primary_Flag__c && mapAddress.containsKey(AA.Address__c)){
                if(AA.Address_Usage_Type__c == 'Bill To'){
                    Account acc = new Account();
                    if(mapAccountToUpdate.containsKey(AA.Account__c)){
                        acc = mapAccountToUpdate.get(AA.Account__c);
                    }
                    acc.Id = AA.Account__c;
                    acc.BillingCity = mapAddress.get(AA.Address__c).City__c;
                    acc.BillingCountry = mapAddress.get(AA.Address__c).Country__c;
                    acc.BillingState = mapAddress.get(AA.Address__c).State__c;
                    acc.BillingStreet = mapAddress.get(AA.Address__c).Street__c;
                    acc.BillingPostalCode = mapAddress.get(AA.Address__c).Zipcode__c;
                    acc.BillingCounty__c = mapAddress.get(AA.Address__c).County__c;
                    mapAccountToUpdate.put(acc.Id, acc);
                }
                if(AA.Address_Usage_Type__c == 'Ship To'){
                    Account acc = new Account();
                    if(mapAccountToUpdate.containsKey(AA.Account__c)){
                        acc = mapAccountToUpdate.get(AA.Account__c);
                    }
                    acc.Id = AA.Account__c;
                    acc.ShippingCity = mapAddress.get(AA.Address__c).City__c;
                    acc.ShippingCountry = mapAddress.get(AA.Address__c).Country__c;
                    acc.ShippingState = mapAddress.get(AA.Address__c).State__c;
                    acc.ShippingStreet = mapAddress.get(AA.Address__c).Street__c;
                    acc.ShippingPostalCode = mapAddress.get(AA.Address__c).Zipcode__c;
                    acc.ShippingCounty__c = mapAddress.get(AA.Address__c).County__c;
                    mapAccountToUpdate.put(acc.Id, acc);
                }
            }
        }
        System.debug('@@ : '+mapAccountToUpdate);
        if(mapAccountToUpdate.keySet().size() > 0){
            Boolean currentFlag = AccountTriggerHandler.RUN_TRIGGER;
             Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            AccountTriggerHandler.RUN_TRIGGER = false;
            Database.update(mapAccountToUpdate.values(), dml);
            //upsert mapAccountToUpdate.values(); 
            AccountTriggerHandler.RUN_TRIGGER = currentFlag;
        }

    }
}