public class AccountTeamMemberTriggerHandler {
    public static void EBSCalloutOnSalesRepChange(List<AccountTeamMember> listATM, Map<Id,AccountTeamMember> oldMap){
        List<Id> listAccountIds=new List<Id>();
        Map<Id, String> mapAccountIds=new Map<Id, String>();
        
        //For Delete ATM
        if(listATM == null){   
            for(AccountTeamMember ATM : oldMap.values()){
                if(ATM.TeamMemberRole=='Inside Sales Support'){
                    listAccountIds.add(ATM.AccountId);
                    mapAccountIds.put(ATM.AccountId, 'SendNULLBody');
                }
            }
        }else{
            //For Insert or Update ATM
            for(AccountTeamMember ATM : listATM){
                if(ATM.TeamMemberRole=='Inside Sales Support' && (oldMap==null || ATM.TeamMemberRole != oldMap.get(ATM.Id).TeamMemberRole)){
                    listAccountIds.add(ATM.AccountId);
                }
            }
        }
        
        List<Account> listAcc=[SELECT ID FROM Account Where Id=:listAccountIds and RecordType.DeveloperName='Pro_Lowes' and mdmrecid__c!=null ];
        for(Account acc: listAcc){
            if(mapAccountIds.containsKey(acc.Id)){
                EBSRESTCallout.updateCustomerEBSCallout(acc.Id, mapAccountIds.get(acc.ID));
            }else{
                EBSRESTCallout.updateCustomerEBSCallout(acc.Id, 'SendNotNULLBody');
            }
        }
    }
}