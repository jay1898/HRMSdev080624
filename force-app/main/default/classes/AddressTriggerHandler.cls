public class AddressTriggerHandler 
{
    public static Boolean RUN_EBS_CALLOUT = true ; 
    public static Boolean update_Account_Address = true;
    public static void updateAddressEBSCallout(List<Address__c> newAddressList, Map<Id, Address__c> oldAddressMap) {
        for(Address__c Address : newAddressList){
            if(Address.street__c != oldAddressMap.get(Address.Id).street__c ||
               Address.City__c != oldAddressMap.get(Address.Id).City__c ||
               Address.state__c != oldAddressMap.get(Address.Id).state__c ||
               Address.Country__c != oldAddressMap.get(Address.Id).Country__c ){
                   
                   EBSRESTCallout.updateAddressEBSCallout(Address.Id);  
               }
        }
    }
    
    public static void updateAccountAddress(Map<Id, Address__c> mapAddress){
        List<Address_Assignment__c> listAddressAssignment = [SELECT Account__c, Address__c, Primary_Flag__c, Address_Usage_Type__c
                                                             FROM Address_Assignment__c WHERE Address__c IN :mapAddress.keySet()];
        Map<Id, Account> mapAccountToUpdate = new Map<Id, Account>();
        
        for(Address_Assignment__c addAss : listAddressAssignment){
            if(addAss.Primary_Flag__c){
                
                if(addAss.Address_Usage_Type__c == 'Bill To'){
                    Account acc = new Account();
                    if(mapAccountToUpdate.containsKey(addAss.Account__c)){
                        acc = mapAccountToUpdate.get(addAss.Account__c);
                    }
                    acc.Id = addAss.Account__c;
                    acc.BillingCity = mapAddress.get(addAss.Address__c).City__c;
                    acc.BillingCountry = mapAddress.get(addAss.Address__c).Country__c;
                    acc.BillingState = mapAddress.get(addAss.Address__c).State__c;
                    acc.BillingStreet = mapAddress.get(addAss.Address__c).Street__c;
                    acc.BillingPostalCode = mapAddress.get(addAss.Address__c).Zipcode__c;
                    acc.BillingCounty__c = mapAddress.get(addAss.Address__c).County__c;
                    mapAccountToUpdate.put(acc.Id, acc);
                }
                if(addAss.Address_Usage_Type__c == 'Ship To'){
                    Account acc = new Account();
                    if(mapAccountToUpdate.containsKey(addAss.Account__c)){
                        acc = mapAccountToUpdate.get(addAss.Account__c);
                    }
                    acc.Id = addAss.Account__c;
                    acc.ShippingCity = mapAddress.get(addAss.Address__c).City__c;
                    acc.ShippingCountry = mapAddress.get(addAss.Address__c).Country__c;
                    acc.ShippingState = mapAddress.get(addAss.Address__c).State__c;
                    acc.ShippingStreet = mapAddress.get(addAss.Address__c).Street__c;
                    acc.ShippingPostalCode = mapAddress.get(addAss.Address__c).Zipcode__c;
                    acc.ShippingCounty__c = mapAddress.get(addAss.Address__c).County__c;
                    mapAccountToUpdate.put(acc.Id, acc);
                }
            }
        }
        
        if(mapAccountToUpdate.keySet().size() > 0){
            Boolean currentFlag = AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER = false;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
            Database.update(mapAccountToUpdate.values(), dml);
            
            //update mapAccountToUpdate.values();
            AccountTriggerHandler.RUN_TRIGGER = currentFlag;
        }
    }
}