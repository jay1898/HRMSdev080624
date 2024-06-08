public class ProductSearchOrderService {
    
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
    public static ProductSearchOrderResponse getOrderDetailsBySerialNumber(String serialNumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;

            String payload = '"variables": {"serialNumber": "' + serialNumber + '","limit": ' + numberOfRecords + ',"offset": ' + offset + '}}';
            String respBody = GraphQLAPIController.getResponseFromGraphQL('Order_API_Search_By_Serial_No', payload);
            System.debug('respBody:::'+respBody);
            if(respBody != null)  {
                respBody = respBody.replace('"limit"', '"recLimit"');
            }
            ProductSearchOrderResponse respObj = ProductSearchOrderResponse.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderService', 'getOrderDetailsBySerialNumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;        
    }

    /*
    *   Created By      : Balaji Ravindran
    *   Added on        : 24 Apr 2024
    *   Purpose         : Method to get Order Data based on Id.
    *   User Story      : SCS-2032
    *   Input Param     : 1) id  - Id which needs to be searched.
    *   Output Param    : SerialNumberRespWrapper (Response data in Wrapper)
    */
    @AuraEnabled
    public static ProductSearchOrderResponse getOrderDetailsBySerialId(String Id) {
        try {
            String payload = '"variables": {"id": "'+Id + '"}}';
            String respBody = GraphQLAPIController.getResponseFromGraphQL('Order_API_Search_By_Serial_Id', payload);
            if(respBody != null)  {
                respBody = respBody.replace('"limit"', '"recLimit"');
            }
            System.debug('respBody::::'+respBody);
            ProductSearchOrderResponse respObj = ProductSearchOrderResponse.parse(respBody);
            System.debug('respObj:::'+respObj);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderService', 'getOrderDetailsBySerialId', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;        
    }

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
    public static ProductSearchOrderResponse getOrderDetailsByAddress(String addressesStr, Integer numberOfRecords, Integer offset) {
        addressesStr = addressesStr.replace('"street"', '"address1"');
        addressesStr = addressesStr.replace('"addressLine1"', '"address2"');
        addressesStr = addressesStr.replace('"zipcode"', '"postalCode"');
        List<OrderAddress> addressesForSearch = (List<OrderAddress>) System.JSON.deserialize(addressesStr, List<OrderAddress>.class);
        for(OrderAddress wrapObj : addressesForSearch) {
            if(wrapObj.address2 != null && wrapObj.address2.deleteWhitespace().length() == 0) wrapObj.address2 = null;
            if(wrapObj.city != null && wrapObj.city.deleteWhitespace().length() == 0) wrapObj.city = null;
            if(wrapObj.state != null && wrapObj.state.deleteWhitespace().length() == 0) wrapObj.state = null;
            if(wrapObj.postalCode != null && wrapObj.postalCode.deleteWhitespace().length() == 0) wrapObj.postalCode = null;
            if(wrapObj.country != null && wrapObj.country.deleteWhitespace().length() == 0) wrapObj.country = null;
        }

        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;

            String payload = '"variables": {"addresses": ' + JSON.serialize(addressesForSearch) + ',"limit": ' + numberOfRecords + ',"offset": '+ offset + '}}';
            String respBody = GraphQLAPIController.getResponseFromGraphQL('Order_API_Search_By_Address', payload);
            if(respBody != null)  {
                respBody = respBody.replace('"limit"', '"recLimit"');
            }
            ProductSearchOrderResponse respObj = ProductSearchOrderResponse.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderService', 'getOrderDetailsByAddress', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;
    }

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
    public static ProductSearchOrderResponse getOrderDetailsByCustPONumber(String custPONumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;

            String payload = '"variables": {"customerPONumber": "' + custPONumber + '","limit": ' + numberOfRecords + ',"offset": ' + offset + '}}';
            String respBody = GraphQLAPIController.getResponseFromGraphQL('Order_API_Search_By_PO_No', payload);
            if(respBody != null)  {
                respBody = respBody.replace('"limit"', '"recLimit"');
            }
            ProductSearchOrderResponse respObj = ProductSearchOrderResponse.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderService', 'getOrderDetailsByCustPONumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;        
    }


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
    public static ProductSearchOrderResponse getOrderDetailsBySalesOrderNumber(String salesOrderNumber, Integer numberOfRecords, Integer offset) {
        try {
            if(numberOfRecords == null) numberOfRecords = 500;
            if(offset == null) offset = 0;

            String payload = '"variables": {"manufacturingSystemSalesOrderNumber": "' + salesOrderNumber + '","limit": ' + numberOfRecords + ',"offset": ' + offset + '}}';
            String respBody = GraphQLAPIController.getResponseFromGraphQL('Order_API_Search_By_Sales_Order_Number', payload);
            if(respBody != null)  {
                respBody = respBody.replace('"limit"', '"recLimit"');
            }
            System.debug('respBody:::'+respBody);
            ProductSearchOrderResponse respObj = ProductSearchOrderResponse.parse(respBody);
            return respObj;
        }catch(Exception e) {
            ApexDebugLog adLog = new ApexDebugLog();
            adLog.createLog(new ApexDebugLog.Error('ProductSearchOrderService', 'getOrderDetailsBySalesOrderNumber', e.getMessage(), e.getStackTraceString(), 'Internal'));            
        }
        return null;        
    }


    /*
    *   Created By      : Rahul Sangwan
    *   Added on        : 12 Sept 2023
    *   Purpose         : Method to Change Installation Date.
    *   User Story      : SCS-901
    *   Input Param     : 1) serialNoList  - List of Order Id's.
                          2) installdate - Date to be changed.
    *   Output Param    : String (SUCCESS or Error Message)
    */
    @AuraEnabled
    public static ProductSearchOrderResponse updateInstallationDate(List<String> serialNoList, String installdate) {
        GraphServiceAuthenticateController.scope            = 'purchased_products_write';
        String payload                                      = '"variables": {"input": {"purchasedProductIds":'+JSON.serialize(serialNoList) + ',"installDate": "'+installdate + '"}}}';
        String respBody                                     = GraphQLAPIController.getResponseFromGraphQL('Order_API_Update_Install_Date', payload);
        ProductSearchOrderResponse respObj                  = ProductSearchOrderResponse.parse(respBody);
        return respObj;
    }

    public class OrderAddress {
        public String address1;
        public String address2;
        public String city;
        public String state;
        public String postalCode;
        public String country;
    }
}