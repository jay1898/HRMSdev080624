public class CustomerAddressResponse implements Comparable{

    public static final Map<String, String> USAGE_TYPE = new Map<String, String>{
        'BILLING' => 'Bill to',
        'INSTALL' => 'Install at',
        'SHIPPING' => 'Ship to',
        'BUSINESS' => 'Business'
    };

    @AuraEnabled
    public String addressUsageType;
    @AuraEnabled
    public String street;
    @AuraEnabled 
    public String city;
    @AuraEnabled 
    public String state;
    @AuraEnabled 
    public String zip;
    @AuraEnabled 
    public String branchName;
    @AuraEnabled
    public Boolean primaryFlag;
    @AuraEnabled 
    public Boolean identifyingAddress;
    @AuraEnabled
    public Integer sortingOrder;

    public CustomerAddressResponse(graphQLAddressResponse.GetStreetAddressesForPersonById addr) {
        street = String.join(addr.streets, ', ');
        city = addr.city;
        state = addr.state;
        zip = addr.postalCode; 
        addressUsageType = addr.associationType != null? USAGE_TYPE.get(addr.associationType):''; 
        identifyingAddress = addr.isIdentifying;
        primaryFlag = addr.isPrimary;
        branchName = addr.branch;
        if(identifyingAddress == true) sortingOrder = 1;
        else if(primaryFlag == true && addressUsageType == 'Ship to') sortingOrder = 2;
        else if(primaryFlag == true && addressUsageType == 'Bill to') sortingOrder = 3;
        else if(primaryFlag == true && addressUsageType == 'Install at') sortingOrder = 4;
        else if(primaryFlag == true && addressUsageType == 'Business') sortingOrder = 5;
        else sortingOrder = 6;
    }

    
    public CustomerAddressResponse(Address_Assignment__c addr) {
        addressUsageType = addr.Address_Usage_Type__c;
        street = addr.Address_Street__c;
        city = addr.Address_City__c;
        state = addr.Address_State__c;
        zip = addr.Address_Zip__c;
        primaryFlag = addr.Primary_Flag__c;
        identifyingAddress = addr.Identifying_Address__c;

        if (addr.Account_Branch_Profile__r != null && addr.Account_Branch_Profile__r.Branch__r != null && addr.Account_Branch_Profile__r.Branch__r.Name != null) {
            branchName = addr.Account_Branch_Profile__r.Branch__r.Name;
        } else if (addr.Account__r != null && addr.Account__r.Name != null) {
            branchName = addr.Account__r.Name;
        } else {
            branchName = ''; 
        }
        if(identifyingAddress == true) sortingOrder = 1;
        else if(primaryFlag == true && addressUsageType == 'Ship to') sortingOrder = 2;
        else if(primaryFlag == true && addressUsageType == 'Bill to') sortingOrder = 3;
        else if(primaryFlag == true && addressUsageType == 'Install at') sortingOrder = 4;
        else if(primaryFlag == true && addressUsageType == 'Business') sortingOrder = 5;
        else sortingOrder = 6;
    }

    public Integer compareTo(Object objToCompare) {
        CustomerAddressResponse custObj = (CustomerAddressResponse)objToCompare;
        if(sortingOrder > custObj.sortingOrder) return 1;
        else if(sortingOrder < custObj.sortingOrder) return -1;
        else return 0;        
    }
}