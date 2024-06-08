public class VoiceAnswerScreenWrapper {

    @AuraEnabled
    public List<CustDetails> custDetailsList ;
    @AuraEnabled
    public List<Case> caseList;
    @AuraEnabled
    public Boolean maxCaseRecordsCrossed;
    @AuraEnabled
    public List<Address_Assignment__c> addressList;
    @AuraEnabled
    public Boolean isCaseNoSearch;
    @AuraEnabled
    public String caseNo;
    @AuraEnabled
    public String poNo;
    @AuraEnabled
    public String quoteNo;
    @AuraEnabled
    public String orderNo;

    public class CustDetails implements Comparable{
        @AuraEnabled
        public String custId;
        @AuraEnabled
        public String custName;
        @AuraEnabled
        public String custPhone;
        @AuraEnabled
        public String custEmail;
        @AuraEnabled
        public String custAddress;
        @AuraEnabled
        public String custCity;
        @AuraEnabled
        public String custState;
        @AuraEnabled
        public String custZip;
        @AuraEnabled
        public String custAccount;
        @AuraEnabled
        public String custAccountName;

        public CustDetails(String custId,String custName, String custPhone, String custEmail, String custAddress, String custCity, String custState, String custZip, String custAccount, String custAccountName) {
            this.custId         = custId;
            this.custName       = custName;
            this.custPhone      = custPhone;
            this.custEmail      = custEmail;
            this.custAddress    = custAddress;
            this.custCity       = custCity;
            this.custState      = custState;
            this.custZip        = custZip;
            this.custAccount    = custAccount;
            this.custAccountName    = custAccountName;
        }

        public Integer compareTo(Object objToCompare) {
            CustDetails custObj = (CustDetails)objToCompare;
            if (custName == custObj.custName) return 0;
            else if (custName > custObj.custName) return 1;
            else return -1;        
        }
    }
}