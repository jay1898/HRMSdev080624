/*
Created By      : Rahul Sangwan
Created Date    : 8 August 2023
Purpose         : This is controller to get Order Details by Customer PO Number.
----------------------------------------------------------------------------------------------
Modified By     :
Modified Date.  : 
Purpose         : 
----------------------------------------------------------------------------------------------
*/
public class ProductSearchOrderAPIByCustomerPONumber {
    
    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 8 Aug 2023
    *   Purpose         : Method to get Order Data based on Serial Number.
    *   User Story      : SCS-416
    *   Input Param     : 1) custPONumber       - Customer PO Number which needs to be searched.
                          2) numberOfRecords    - number of records wants to be returned.
                          3) offset
    *   Output Param    : SerialNumberRespWrapper (Response data in Wrapper)
    */
    @AuraEnabled
    public static ProductSearchSerialNumberRespWrapper getOrderDetailsByCustPONumber(String custPONumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;
            if(custPONumber == null) custPONumber = '182GNSU46'; // This is added only for testing purpose

            String payload                      = '"variables": {"customerPONumber": "'+custPONumber + '","limit": '+numberOfRecords + ',"offset": '+offset+'}}';
            String respBody                     = GraphQLAPICtrl.getResponseFromGraphQL('Order_API_Search_By_PO_No__c', payload);
            if(respBody != null)  {
                respBody       = respBody.replace('"limit"', '"recLimit"');
            }
            ProductSearchSerialNumberRespWrapper respObj     = ProductSearchSerialNumberRespWrapper.parse(respBody);
            System.debug('respObj::::'+respObj);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderAPIBySerialNumber', 'getOrderDetailsBySerialNumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;        
    }

}