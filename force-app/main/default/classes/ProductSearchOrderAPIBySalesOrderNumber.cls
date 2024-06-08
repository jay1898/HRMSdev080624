public class ProductSearchOrderAPIBySalesOrderNumber {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 17 August 2023
    *   Purpose         : Method to get Order Data based on Sales Order Number.
    *   User Story      : SCS-537
    *   Input Param     : 1) salesOrderNumber  - Sales Order number which needs to be searched.
                          2) numberOfRecords - number of records wants to be returned.
                          3) offset
    *   Output Param    : SerialNumberRespWrapper (Response data in Wrapper)
    */
    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper getOrderDetailsBySalesOrderNumber(String salesOrderNumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;
            if(salesOrderNumber == null) salesOrderNumber = '18542433'; // This is added only for testing purpose

            String payload                      = '"variables": {"manufacturingSystemSalesOrderNumber": "'+salesOrderNumber + '","limit": '+numberOfRecords + ',"offset": '+offset+'}}';
            String respBody                     = GraphQLAPICtrl.getResponseFromGraphQL('Order_API_Search_By_Sales_Order_Number__c', payload);
            if(respBody != null)  {
                respBody       = respBody.replace('"limit"', '"recLimit"');
            }
            System.debug('respBody:::'+respBody);
            ProductSearchSerialNumberRespWrapper respObj     = ProductSearchSerialNumberRespWrapper.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderAPIBySalesOrderNumber', 'getOrderDetailsBySalesOrderNumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;
        
    }
}