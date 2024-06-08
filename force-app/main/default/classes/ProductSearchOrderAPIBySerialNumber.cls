/*
Created By      : Rahul Sangwan
Created Date    : 19 July 2023
Purpose         : This is controller to get Order Details by Serial Number.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ProductSearchOrderAPIBySerialNumber {

    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 20 July 2023
    *   Purpose         : Method to get Order Data based on Serial Number.
    *   User Story      : SCS-416
    *   Input Param     : 1) serialNumber  - Serial number which needs to be searched.
                          2) numberOfRecords - number of records wants to be returned.
                          3) offset
    *   Output Param    : SerialNumberRespWrapper (Response data in Wrapper)
    */
    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper getOrderDetailsBySerialNumber(String serialNumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;
            if(serialNumber == null) serialNumber = 'TestSerialNumber'; // This is added only for testing purpose

            String payload                      = '"variables": {"serialNumber": "'+serialNumber + '","limit": '+numberOfRecords + ',"offset": '+offset+'}}';
            String respBody                     = GraphQLAPICtrl.getResponseFromGraphQL('Order_API_v2_Search_By_Serial_No__c', payload);
            System.debug('respBody:::'+respBody);
            if(respBody != null)  {
                respBody       = respBody.replace('"limit"', '"recLimit"');
            }
            ProductSearchSerialNumberRespWrapper respObj     = ProductSearchSerialNumberRespWrapper.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderAPIBySerialNumber', 'getOrderDetailsBySerialNumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;
        
    }


    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper getOrderDetailsBySerialNumber_v2(String serialNumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;
            if(serialNumber == null) serialNumber = 'TestSerialNumber'; // This is added only for testing purpose

            String payload                      = '"variables": {"serialNumber": "'+serialNumber + '","limit": '+numberOfRecords + ',"offset": '+offset+'}}';
            String respBody                     = GraphQLAPICtrl.getResponseFromGraphQL('Order_API_v2_Search_By_Serial_No__c', payload);
            System.debug('respBody:::'+respBody);
            if(respBody != null)  {
                respBody       = respBody.replace('"limit"', '"recLimit"');
            }
            ProductSearchSerialNumberRespWrapper respObj     = ProductSearchSerialNumberRespWrapper.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderAPIBySerialNumber', 'getOrderDetailsBySerialNumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;
        
    }
    
}