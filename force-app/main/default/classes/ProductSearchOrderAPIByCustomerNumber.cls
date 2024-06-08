public class ProductSearchOrderAPIByCustomerNumber {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 22 August 2023
    *   Purpose         : Method to get Order Data based on Customer Number.
    *   User Story      : SCS-537
    *   Input Param     : 1) customerNumber  - Customer number which needs to be searched.
                          2) numberOfRecords - number of records wants to be returned.
                          3) offset
    *   Output Param    : SerialNumberRespWrapper (Response data in Wrapper)
    */
    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper getOrderDetailsByCustomerNumber(String customerNumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;
            if(customerNumber == null) customerNumber = '018200'; // This is added only for testing purpose

            String payload                      = '"variables": {"customerNumber": "'+customerNumber + '","limit": '+numberOfRecords + ',"offset": '+offset+'}}';
            String respBody                     = GraphQLAPICtrl.getResponseFromGraphQL('Order_API_Search_By_Customer_Number__c', payload);
            if(respBody != null)  {
                respBody       = respBody.replace('"limit"', '"recLimit"');
            }
            System.debug('respBody:::'+respBody);
            ProductSearchSerialNumberRespWrapper respObj     = ProductSearchSerialNumberRespWrapper.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderAPIByCustomerNumber', 'getOrderDetailsByCustomerNumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;
        
    }
}