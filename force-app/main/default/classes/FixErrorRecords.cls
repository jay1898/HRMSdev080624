public class FixErrorRecords {
    
    @InvocableMethod(label='Run Failed Quotes' description='Run Failed Quote Shells')
    public static void RunFailedQuotes(List<String> processName){
        List<String> pNames = processName.toString().replace('([','').replace('])','').split(',');//.split(';');
        
        Boolean isRunFailedQuoteShells = false;
        Boolean isRunFailedEBSCustomers = false; 
        for(String pn: pNames) {
            if(pn == 'RunFailedQuoteShells') {
                isRunFailedQuoteShells = true;
            }
            if(pn == 'RunFailedEBSCustomers') {
                isRunFailedEBSCustomers = true;
            }
        }
        system.debug('@@isRunFailedEBSCustomers :: '+isRunFailedEBSCustomers);
        system.debug('@@isRunFailedQuoteShells :: '+isRunFailedQuoteShells);
        if(isRunFailedQuoteShells) {
            RunFailedQuoteShells();
        }
        
        if(isRunFailedEBSCustomers) {
            RunFailedEBSCustomers();
        }
    }
    
    public static void RunFailedQuoteShells(){
        List<opportunity> oppRec = Database.query(Label.FixErrorRecords_RunFailedQuoteShells);
        List<Opportunity> listOppToUpdate=new List<Opportunity>();
        for (Opportunity opp : oppRec){
            if (opp.Create_Quote_Shell__c = false){
                opp.Create_Quote_Shell__c = true;
                listOppToUpdate.add(opp);
            }
            else if (opp.Create_Quote_Shell__c = true && opp.PQM_Quote_Shell_Error_Message__c != null){
                opp.Create_Quote_Shell__c = false;
                listOppToUpdate.add(opp);
            }
        }
        update listOppToUpdate; 
        List<Opportunity> listOppToReUpdate=new List<Opportunity>();
        for(Opportunity Opp:listOppToUpdate){
            if(opp.Create_Quote_Shell__c==false){
                opp.Create_Quote_Shell__c = true;
                listOppToReUpdate.add(opp);
            }
        }
        update listOppToReUpdate;
    }

    public static void RunFailedEBSCustomers(){
        List<account> accountRec = database.query(Label.FixErrorRecords_RunFailedEBSCustomers);
        
        for (Account acc : accountRec){
            EBSRESTCallout.createCustomerEBSCallout(acc.id);
        }
    }
}