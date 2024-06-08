/*
Created By      : Rahul Sangwan
Created Date    : 10 August 2023
Purpose         : This is controller to get Order Details by Address.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ProductSearchOrderAPIByAddress {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 10 August 2023
    *   Purpose         : Method to get Order Data based on Serial Number.
    *   User Story      : SCS-416
    *   Input Param     : 1) serialNumber  - Serial number which needs to be searched.
                          2) numberOfRecords - number of records wants to be returned.
                          3) offset
    *   Output Param    : SerialNumberRespWrapper (Response data in Wrapper)
    */
    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper getOrderDetailsByAddress(String addressesStr, Integer numberOfRecords, Integer offset) {
        addressesStr                            = addressesStr.replace('"street"', '"address1"');
        addressesStr                            = addressesStr.replace('"addressLine1"', '"address2"');
        addressesStr                            = addressesStr.replace('"zipcode"', '"postalCode"');
        List<AddressWrapper> addresses          = (List<AddressWrapper>) System.JSON.deserialize(addressesStr, List<AddressWrapper>.class);
        for(AddressWrapper wrapObj : addresses) {
            if(wrapObj.address2 != null && wrapObj.address2.deleteWhitespace().length() == 0) wrapObj.address2 = null;
            if(wrapObj.city != null && wrapObj.city.deleteWhitespace().length() == 0) wrapObj.city = null;
            if(wrapObj.state != null && wrapObj.state.deleteWhitespace().length() == 0) wrapObj.state = null;
            if(wrapObj.postalCode != null && wrapObj.postalCode.deleteWhitespace().length() == 0) wrapObj.postalCode = null;
            if(wrapObj.country != null && wrapObj.country.deleteWhitespace().length() == 0) wrapObj.country = null;
        }

        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;

            String payload                      = '"variables": {"addresses": '+JSON.serialize(addresses) + ',"limit": '+numberOfRecords + ',"offset": '+offset+'}}';
            String respBody                     = GraphQLAPICtrl.getResponseFromGraphQL('Order_API_Search_By_Address__c', payload);
            if(respBody != null)  {
                respBody       = respBody.replace('"limit"', '"recLimit"');
            }
            ProductSearchSerialNumberRespWrapper respObj     = ProductSearchSerialNumberRespWrapper.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderAPIByAddress', 'getOrderDetailsByAddress', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;
    }


    public class AddressWrapper {
        public String address1;
        public String address2;
        public String city;
        public String state;
        public String postalCode;
        public String country;

    }

}